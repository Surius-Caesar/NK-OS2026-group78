#include <buddy_pmm.h>
#include <list.h>
#include <stdio.h>
#include <string.h>

// property stores block SIZE, not order. Limit also fits its unsigned int.
#define BUDDY_MAX_ORDER 20
#define BUDDY_MAX_PAGES (1UL << BUDDY_MAX_ORDER)
static struct buddy_state {
    list_entry_t lists[BUDDY_MAX_ORDER + 1];
    size_t nr_free;
    ppn_t first, end;
} buddy;

static void buddy_check(void);

static int
request_order(size_t n) {
    if (n == 0 || n > BUDDY_MAX_PAGES) return -1;
    int order = 0;
    for (size_t size = 1; size < n; size <<= 1) order++;
    return order;
}

static void
buddy_init(void) {
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) list_init(&buddy.lists[k]);
    buddy.nr_free = 0;
    buddy.first = npage;
    buddy.end = nbase;
}

// Validate the entire candidate before forming/dereferencing its descriptor.
// Reserved holes have no free-head flag and can never be merged across.
static struct Page *
free_partner(ppn_t ppn, int k) {
    size_t size = 1UL << k;
    if (ppn < nbase || ppn < buddy.first || ppn >= npage ||
        ppn >= buddy.end || size > npage - ppn || size > buddy.end - ppn)
        return NULL;
    struct Page *p = pages + (ppn - nbase);
    return !PageReserved(p) && PageProperty(p) && p->property == size ? p : NULL;
}

static void
insert_merge(struct Page *base, int k) {
    while (k < BUDDY_MAX_ORDER) {
        struct Page *other = free_partner(page2ppn(base) ^ (1UL << k), k);
        if (other == NULL) break;
        list_del_init(&other->page_link);
        ClearPageProperty(other);
        other->property = 0;
        if (other < base) base = other;
        k++;
    }
    base->property = 1UL << k;
    SetPageProperty(base);
    list_add(&buddy.lists[k], &base->page_link);
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    ppn_t start = page2ppn(base);
    assert(start >= nbase && start < npage && n <= npage - start);
    for (struct Page *p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    if (start < buddy.first) buddy.first = start;
    if (start + n > buddy.end) buddy.end = start + n;
    buddy.nr_free += n;
    while (n != 0) {
        int k = 0;
        while (k < BUDDY_MAX_ORDER && (1UL << (k + 1)) <= n &&
               (page2ppn(base) & ((1UL << (k + 1)) - 1)) == 0) k++;
        size_t size = 1UL << k;
        insert_merge(base, k);
        base += size;
        n -= size;
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    int k = request_order(n);
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
    int found = k;
    while (found <= BUDDY_MAX_ORDER && list_empty(&buddy.lists[found])) found++;
    if (found > BUDDY_MAX_ORDER) return NULL;
    struct Page *base = le2page(list_next(&buddy.lists[found]), page_link);
    list_del_init(&base->page_link);
    ClearPageProperty(base);
    base->property = 0;
    while (found > k) {
        found--;
        struct Page *other = base + (1UL << found);
        other->property = 1UL << found;
        SetPageProperty(other);
        list_add(&buddy.lists[found], &other->page_link);
    }
    buddy.nr_free -= 1UL << k;
    return base;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    int k = request_order(n);
    assert(k >= 0);
    size_t size = 1UL << k;
    ppn_t start = page2ppn(base);
    assert(start >= buddy.first && start < buddy.end &&
           size <= buddy.end - start && (start & (size - 1)) == 0);
    for (struct Page *p = base; p < base + size; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    buddy.nr_free += size;
    insert_merge(base, k);
}

static size_t
buddy_nr_free_pages(void) { return buddy.nr_free; }

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

// Independent per-page oracle for a real 32-page allocation. No fake Page array.
#define TEST_PAGES 32
static struct Page *test_base;
static unsigned char allowed[TEST_PAGES], occupied[TEST_PAGES];
static struct buddy_state saved_state, failure_state;
static struct Page saved_pages[TEST_PAGES], failure_pages[TEST_PAGES];

static void
check_consistency(void) {
    size_t total = 0, blocks = 0;
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
        list_entry_t *head = &buddy.lists[k];
        for (list_entry_t *le = list_next(head); le != head; le = list_next(le)) {
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
            assert(list_prev(list_next(le)) == le && list_next(list_prev(le)) == le);
            struct Page *p = le2page(le, page_link);
            size_t size = 1UL << k;
            ppn_t ppn = page2ppn(p);
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
            assert((ppn & (size - 1)) == 0 && PageProperty(p) && p->property == size);
            if (k < BUDDY_MAX_ORDER) assert(free_partner(ppn ^ size, k) == NULL);
            for (size_t i = 0; i < size; i++) {
                assert(!PageReserved(p + i) && page_ref(p + i) == 0);
                if (i != 0) assert(!PageProperty(p + i));
            }
            // Every other block is disjoint, including blocks of another order.
            for (int j = k; j <= BUDDY_MAX_ORDER; j++) {
                list_entry_t *h = &buddy.lists[j];
                for (list_entry_t *q = list_next(h); q != h; q = list_next(q)) {
                    struct Page *other = le2page(q, page_link);
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
                }
            }
            total += size;
        }
    }
    assert(total == nr_free_pages());
}

static void
check_pool(void) {
    unsigned char seen[TEST_PAGES] = {0};
    check_consistency();
    size_t expected = 0;
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
        list_entry_t *h = &buddy.lists[k];
        for (list_entry_t *le = list_next(h); le != h; le = list_next(le)) {
            struct Page *p = le2page(le, page_link);
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
            size_t offset = p - test_base;
            for (size_t i = 0; i < (1UL << k); i++) {
                assert(allowed[offset+i] && !occupied[offset+i] && !seen[offset+i]);
                seen[offset+i] = 1;
            }
        }
    }
    for (int i = 0; i < TEST_PAGES; i++) {
        assert(seen[i] == (allowed[i] && !occupied[i]));
        if (seen[i]) expected++;
        assert(!PageReserved(test_base+i) == !!allowed[i]);
    }
    assert(expected == nr_free_pages());
}

static void
pool_reset(void) {
    buddy_init();
    memset(allowed, 0, sizeof(allowed));
    memset(occupied, 0, sizeof(occupied));
    for (int i = 0; i < TEST_PAGES; i++) {
        test_base[i].flags = test_base[i].property = 0;
        set_page_ref(test_base+i, 7); // registration must clear old references
        SetPageReserved(test_base+i);
    }
}

static void
pool_register(int offset, int n) {
    buddy_init_memmap(test_base+offset, n);
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
    check_pool();
}

// Assert exact state preservation, not just unchanged free-page counts.
static void
expect_failure(size_t n) {
    memcpy(&failure_state, &buddy, sizeof(buddy));
    memcpy(failure_pages, test_base, sizeof(failure_pages));
    assert(alloc_pages(n) == NULL);
    assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
    assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
    check_pool();
}

static struct Page *
pool_alloc(size_t n) {
    struct Page *p = alloc_pages(n);
    if (p != NULL) {
        // Deliberately compute rounding independently of request_order().
        size_t size = 1;
        while (size < n) size *= 2;
        assert(p >= test_base && p + size <= test_base + TEST_PAGES);
        assert((page2ppn(p) % size) == 0);
        for (size_t i = 0; i < size; i++) {
            size_t at = p - test_base + i;
            assert(allowed[at] && !occupied[at] && !PageProperty(p+i));
            assert(page_ref(p+i) == 0);
            assert(page2pa(p+i) == page2pa(p) + i*PGSIZE);
            occupied[at] = 1;
        }
    }
    check_pool();
    return p;
}

static void
pool_free(struct Page *p, size_t n) {
    size_t size = 1;
    while (size < n) size *= 2;
    for (size_t i = 0; i < size; i++) {
        size_t at = p - test_base + i;
        assert(at < TEST_PAGES && occupied[at]);
        occupied[at] = 0;
        set_page_ref(p+i, 3); // free must reset references
    }
    free_pages(p, n); // original request, not the rounded size
    check_pool();
}

static void
buddy_check(void) {
    check_consistency();
    size_t original = nr_free_pages();
    test_base = alloc_pages(TEST_PAGES);
    assert(test_base != NULL && nr_free_pages() == original - TEST_PAGES);
    memcpy(&saved_state, &buddy, sizeof(buddy));
    memcpy(saved_pages, test_base, sizeof(saved_pages));

    pool_reset();
    expect_failure(1); // empty pool
    pool_register(0, TEST_PAGES);
    size_t requests[] = {1, 2, 4, 3, 5};
    struct Page *blocks[5];
    size_t used = 0;
    for (int i = 0; i < 5; i++) {
        blocks[i] = pool_alloc(requests[i]);
        assert(blocks[i] != NULL);
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
        assert(nr_free_pages() == TEST_PAGES - used);
    }
    for (int i = 4; i >= 0; i--) pool_free(blocks[i], requests[i]);
    assert(nr_free_pages() == TEST_PAGES);
    expect_failure(TEST_PAGES+1);
    expect_failure(BUDDY_MAX_PAGES+1);
    expect_failure((size_t)-1); // rounding overflow input
    expect_failure(((size_t)-1 >> 1)+1);

    // One aligned block: exhaust by splitting, then merge in both directions.
    for (int reverse = 0; reverse < 2; reverse++) {
        pool_reset();
        pool_register(0, 8);
        struct Page *singles[8];
        for (int i = 0; i < 8; i++) { singles[i] = pool_alloc(1); assert(singles[i]); }
        expect_failure(1);
        for (int i = 0; i < 8; i++) pool_free(singles[reverse ? 7-i : i], 1);
        struct Page *whole = pool_alloc(8);
        assert(whole == test_base);
        pool_free(whole, 8);
    }

    pool_reset();
    pool_register(0, 8);
    struct Page *single[8] = {0};
    for (int i = 0; i < 8; i++) {
        struct Page *p = pool_alloc(1);
        assert(p != NULL);
        single[p-test_base] = p;
    }
    pool_free(single[1], 1);
    pool_free(single[2], 1); // adjacent, but XOR partners are 0 and 3
    assert(nr_free_pages() == 2);
    expect_failure(2);
    pool_free(single[0], 1);
    struct Page *pair = pool_alloc(2);
    assert(pair == test_base); // 2 cannot merge while 3 remains occupied
    pool_free(pair, 2);
    for (int i = 3; i < 8; i++) pool_free(single[i], 1);
    struct Page *whole = pool_alloc(8);
    assert(whole == test_base);
    pool_free(whole, 8);

    // Unaligned length 5, isolated single page, reserved holes, reverse-order
    // adjacent registrations, and partners below/above the managed envelope.
    pool_reset();
    pool_register(1, 5);
    pool_register(9, 1);
    pool_register(18, 2);
    pool_register(16, 2); // must coalesce across registration boundaries
    pool_register(31, 1);
    struct Page *registered[11];
    for (int i = 0; i < 11; i++) { registered[i] = pool_alloc(1); assert(registered[i]); }
    expect_failure(1);
    for (int i = 10; i >= 0; i--) pool_free(registered[i], 1);
    assert(nr_free_pages() == 11);
    expect_failure(8); // enough pages, no order-3 block

    // Bounded deterministic mixed requests, with a separate occupancy oracle.
    pool_reset();
    pool_register(0, TEST_PAGES);
    struct Page *slots[8] = {0};
    size_t sizes[8] = {0};
    unsigned int random = 0x13579bdu;
    int successes = 0, failures = 0, releases = 0;
    for (int step = 0; step < 256; step++) {
        random = random * 1664525u + 1013904223u;
        unsigned int slot = (random >> 16) % 8;
        if (slots[slot]) {
            pool_free(slots[slot], sizes[slot]);
            slots[slot] = NULL;
            releases++;
        } else {
            size_t n = ((random >> 8) % 9) + 1;
            memcpy(&failure_state, &buddy, sizeof(buddy));
            memcpy(failure_pages, test_base, sizeof(failure_pages));
            slots[slot] = pool_alloc(n);
            sizes[slot] = n;
            if (slots[slot]) successes++;
            else {
                failures++;
                assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
                assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
            }
        }
    }
    assert(successes && failures && releases);
    for (int i = 0; i < 8; i++) if (slots[i]) pool_free(slots[i], sizes[i]);
    assert(nr_free_pages() == TEST_PAGES);
    whole = pool_alloc(TEST_PAGES);
    assert(whole == test_base);
    pool_free(whole, TEST_PAGES);

    // Restore original list heads at their original addresses, plus all arena
    // metadata, before returning the allocation to the real global allocator.
    memcpy(test_base, saved_pages, sizeof(saved_pages));
    memcpy(&buddy, &saved_state, sizeof(buddy));
    free_pages(test_base, TEST_PAGES);
    assert(nr_free_pages() == original);
    check_consistency();
    struct Page *probe = alloc_pages(3);
    assert(probe != NULL && nr_free_pages() == original - 4);
    free_pages(probe, 3);
    assert(nr_free_pages() == original);
    check_consistency();
    cprintf("buddy_check() succeeded!\n");
}
