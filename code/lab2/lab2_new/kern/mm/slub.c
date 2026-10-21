#include <pmm.h>
#include <slub.h>
#include <stdio.h>

/* One page per small-object slab. Larger objects own a page allocation. */
#define SLUB_MAGIC 0x534c554250414745ULL
#define SLUB_LARGE ((size_t)-1)
#define SLUB_ALIGN sizeof(uintptr_t)

static const size_t class_sizes[] = {
    8, 16, 32, 64, 128, 256, 512, 1024, 2048,
};
#define NR_CLASSES (sizeof(class_sizes) / sizeof(class_sizes[0]))

struct slub_page {
    uint64_t magic;
    struct Page *page;
    struct slub_page *next;
    void *free_head;
    size_t page_count;          /* Original alloc_pages() request. */
    size_t class_index;         /* SLUB_LARGE for direct page allocations. */
    size_t capacity;
    size_t inuse;
};

static struct slub_page *slabs[NR_CLASSES];
static bool initialized;

static size_t
payload_offset(void) {
    return (sizeof(struct slub_page) + SLUB_ALIGN - 1) & ~(SLUB_ALIGN - 1);
}

static struct slub_page *
new_slab(size_t class_index) {
    struct Page *page = alloc_page();
    if (page == NULL) return NULL;

    struct slub_page *slab = (struct slub_page *)(page2pa(page) + va_pa_offset);
    size_t size = class_sizes[class_index];
    size_t capacity = (PGSIZE - payload_offset()) / size;
    assert(capacity > 0);

    slab->magic = SLUB_MAGIC;
    slab->page = page;
    slab->next = slabs[class_index];
    slab->page_count = 1;
    slab->class_index = class_index;
    slab->capacity = capacity;
    slab->inuse = 0;
    slab->free_head = NULL;

    /* A free slot stores its successor in its first machine word. */
    for (size_t i = capacity; i > 0; i--) {
        void *slot = (char *)slab + payload_offset() + (i - 1) * size;
        *(void **)slot = slab->free_head;
        slab->free_head = slot;
    }
    slabs[class_index] = slab;
    return slab;
}

void
slub_init(void) {
    assert(!initialized);
    for (size_t i = 0; i < NR_CLASSES; i++) slabs[i] = NULL;
    initialized = 1;
}

void *
slub_alloc(size_t size) {
    assert(initialized);
    if (size == 0) return NULL;

    for (size_t i = 0; i < NR_CLASSES; i++) {
        if (size <= class_sizes[i]) {
            struct slub_page *slab = slabs[i];
            while (slab != NULL && slab->free_head == NULL) slab = slab->next;
            if (slab == NULL) slab = new_slab(i);
            if (slab == NULL) return NULL;

            void *slot = slab->free_head;
            slab->free_head = *(void **)slot;
            slab->inuse++;
            return slot;
        }
    }

    /* Check before adding the header and rounding to whole pages. */
    if (size > (size_t)-1 - payload_offset() - (PGSIZE - 1)) return NULL;
    size_t pages_needed = (size + payload_offset() + PGSIZE - 1) / PGSIZE;
    struct Page *page = alloc_pages(pages_needed);
    if (page == NULL) return NULL;

    struct slub_page *large = (struct slub_page *)(page2pa(page) + va_pa_offset);
    large->magic = SLUB_MAGIC;
    large->page = page;
    large->next = NULL;
    large->free_head = NULL;
    large->page_count = pages_needed;
    large->class_index = SLUB_LARGE;
    large->capacity = 1;
    large->inuse = 1;
    return (char *)large + payload_offset();
}

void
slub_free(void *ptr) {
    if (ptr == NULL) return;
    assert(initialized);

    struct slub_page *slab = (struct slub_page *)
        ((uintptr_t)ptr & ~((uintptr_t)PGSIZE - 1));
    assert(slab->magic == SLUB_MAGIC);

    if (slab->class_index == SLUB_LARGE) {
        assert(ptr == (char *)slab + payload_offset() && slab->inuse == 1);
        struct Page *page = slab->page;
        size_t count = slab->page_count;
        slab->magic = 0;
        free_pages(page, count);
        return;
    }

    size_t index = slab->class_index;
    assert(index < NR_CLASSES && slab->inuse > 0);
    size_t offset = (uintptr_t)ptr - (uintptr_t)slab;
    assert(offset >= payload_offset() &&
           offset < payload_offset() + slab->capacity * class_sizes[index] &&
           (offset - payload_offset()) % class_sizes[index] == 0);

    *(void **)ptr = slab->free_head;
    slab->free_head = ptr;
    if (--slab->inuse != 0) return;

    /* The last object has gone: remove this slab before returning its page. */
    struct slub_page **link = &slabs[index];
    while (*link != slab) {
        assert(*link != NULL);
        link = &(*link)->next;
    }
    *link = slab->next;
    struct Page *page = slab->page;
    slab->magic = 0;
    free_page(page);
}

struct test_object {
    void *ptr;
    size_t size;
    unsigned char pattern;
};

static void
test_fill(struct test_object *object) {
    assert(object->ptr != NULL);
    assert((uintptr_t)object->ptr % sizeof(uintptr_t) == 0);
    for (size_t i = 0; i < object->size; i++) {
        ((unsigned char *)object->ptr)[i] = object->pattern;
    }
}

static void
test_contents(const struct test_object *object) {
    assert(object->ptr != NULL);
    for (size_t i = 0; i < object->size; i++) {
        assert(((const unsigned char *)object->ptr)[i] == object->pattern);
    }
}

static void
test_disjoint(const struct test_object *objects, size_t count) {
    for (size_t i = 0; i < count; i++) {
        if (objects[i].ptr == NULL) continue;
        uintptr_t first = (uintptr_t)objects[i].ptr;
        for (size_t j = i + 1; j < count; j++) {
            if (objects[j].ptr == NULL) continue;
            uintptr_t second = (uintptr_t)objects[j].ptr;
            assert(first + objects[i].size <= second ||
                   second + objects[j].size <= first);
        }
    }
}

void
slub_check(void) {
    assert(initialized);
    size_t baseline = nr_free_pages();

    /* Exercise class boundaries, the largest slab class, and direct pages. */
    const size_t sizes[] = {
        1, 7, 8, 9, 15, 16, 17, 31, 32, 33,
        127, 128, 129, 1024, 1025, 2048, 2049,
        PGSIZE - sizeof(struct slub_page),
        PGSIZE - sizeof(struct slub_page) + 1,
        PGSIZE - 1, PGSIZE, PGSIZE + 1, 2 * PGSIZE + 13,
    };
    struct test_object objects[sizeof(sizes) / sizeof(sizes[0])];
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
        objects[i].size = sizes[i];
        objects[i].pattern = (unsigned char)(i + 1);
        objects[i].ptr = slub_alloc(sizes[i]);
        assert(objects[i].ptr != NULL);
        test_fill(&objects[i]);
        test_disjoint(objects, i + 1);
    }
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
        test_contents(&objects[i]);
    }
    for (size_t i = sizeof(sizes) / sizeof(sizes[0]); i > 0; i--) {
        slub_free(objects[i - 1].ptr);
    }
    assert(nr_free_pages() == baseline);

    /* Several objects share one slab; a released slot is immediately reusable. */
    struct test_object shared[4];
    for (size_t i = 0; i < 4; i++) {
        shared[i].size = 32;
        shared[i].pattern = (unsigned char)(0x41 + i);
        shared[i].ptr = slub_alloc(shared[i].size);
        assert(shared[i].ptr != NULL);
        test_fill(&shared[i]);
        assert(nr_free_pages() == baseline - 1);
    }
    test_disjoint(shared, 4);
    void *released = shared[1].ptr;
    slub_free(released);
    shared[1].ptr = NULL;
    assert(nr_free_pages() == baseline - 1);
    for (size_t i = 0; i < 4; i++) {
        if (shared[i].ptr != NULL) test_contents(&shared[i]);
    }
    shared[1].ptr = slub_alloc(32);
    assert(shared[1].ptr == released);
    test_fill(&shared[1]);
    test_disjoint(shared, 4);
    for (size_t i = 0; i < 4; i++) test_contents(&shared[i]);
    for (size_t i = 0; i < 4; i++) slub_free(shared[i].ptr);
    assert(nr_free_pages() == baseline);

    /* Invalid sizes and NULL release leave live objects and page count intact. */
    struct test_object guard = {slub_alloc(64), 64, 0xa5};
    assert(guard.ptr != NULL);
    test_fill(&guard);
    size_t while_guard = nr_free_pages();
    assert(slub_alloc(0) == NULL);
    assert(slub_alloc((size_t)-1) == NULL);
    assert(slub_alloc((size_t)-2) == NULL);
    slub_free(NULL);
    assert(nr_free_pages() == while_guard);
    test_contents(&guard);
    slub_free(guard.ptr);
    assert(nr_free_pages() == baseline);

    /* Fixed mixed sequence checks that frees do not disturb survivors. */
    const size_t mixed_sizes[] = {8, 31, 64, 5000, 2030, PGSIZE + 17, 7, 1024};
    struct test_object mixed[sizeof(mixed_sizes) / sizeof(mixed_sizes[0])];
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
        mixed[i].size = mixed_sizes[i];
        mixed[i].pattern = (unsigned char)(0x80 + i);
        mixed[i].ptr = slub_alloc(mixed[i].size);
        assert(mixed[i].ptr != NULL);
        test_fill(&mixed[i]);
    }
    const size_t replace_at[] = {1, 3, 5};
    const size_t replace_size[] = {16, 5001, 2049};
    for (size_t i = 0; i < 3; i++) {
        size_t index = replace_at[i];
        slub_free(mixed[index].ptr);
        mixed[index].ptr = NULL;
        for (size_t j = 0; j < sizeof(mixed) / sizeof(mixed[0]); j++) {
            if (mixed[j].ptr != NULL) test_contents(&mixed[j]);
        }
        mixed[index].size = replace_size[i];
        mixed[index].pattern = (unsigned char)(0xd0 + i);
        mixed[index].ptr = slub_alloc(mixed[index].size);
        assert(mixed[index].ptr != NULL);
        test_fill(&mixed[index]);
        test_disjoint(mixed, sizeof(mixed) / sizeof(mixed[0]));
    }
    for (size_t i = 0; i < sizeof(mixed) / sizeof(mixed[0]); i++) {
        test_contents(&mixed[i]);
    }
    for (size_t i = sizeof(mixed) / sizeof(mixed[0]); i > 0; i--) {
        slub_free(mixed[i - 1].ptr);
    }
    assert(nr_free_pages() == baseline);
    cprintf("slub_check() succeeded!\n");
}
