#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*
 * First-Fit：按物理地址从低到高，选择第一个能满足申请的空闲块。
 * free_list 是带哨兵头结点的双向循环链表，只链接各空闲块的首页。
 * 首页的 property 保存块内连续页数，PG_property 标记它是空闲块首页。
 * nr_free 是空闲页总数，不是空闲块数。
 * Page 是物理页的描述符；描述符在 pages 数组中的顺序对应物理页顺序，
 * 因而 p + n 对应向后 n 个物理页，而不是向后 n 个字节。
 */
// free_area_t 定义于 memlayout.h，包含 free_list（链表头）和 nr_free（页数）。
// static 使这个管理状态仅在本 C 文件内可见；它并不存放实际物理页的数据。
static free_area_t free_area;

// 宏只是成员访问的简写，不会另外创建链表或计数器。
#define free_list (free_area.free_list)
// nr 是 number 的常用缩写；nr_free 表示 number of free pages（空闲页数）。
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    // 初始化管理结构，此时尚未登记任何可分配的物理页。
    // 空循环链表的头结点 prev、next 都指向自身；头结点不代表物理页。
    list_init(&free_list);  // 将头结点的 prev、next 都设为 &free_list。
    nr_free = 0;           // 尚未调用 init_memmap 登记可用页，因此计数为 0。
}

static void
default_init_memmap(struct Page *base, size_t n) {
    // base：待登记区间的首个 Page 描述符指针，不是物理地址。
    // n：区间包含的物理页数；size_t 是用于数量/大小的无符号整数类型。
    // 将 base 开始的连续 n 页登记为空闲块；调用者已排除内核等占用页面。
    assert(n > 0);
    struct Page *p = base;  // p 是逐页处理描述符的游标，base 始终保留区间起点。
    for (; p != base + n; p ++) {  // 遍历 [base, base+n)，p++ 前进一个描述符。
        // page_init() 先将页面标为保留；这里解除保留并初始化描述符。
        assert(PageReserved(p));
        p->flags = p->property = 0;  // 同时清除状态位和旧块长，包括保留标记。
        set_page_ref(p, 0);          // 等价于 p->ref = 0：当前没有引用。
    }
    // 只有首页记录整个空闲块的长度并设置 PG_property，内部页不入链表。
    base->property = n;
    SetPageProperty(base);  // 将 base->flags 的 PG_property 位置 1，不是设置块长。
    nr_free += n;          // 新登记了 n 个可分配页。
    // 按描述符地址（也就是对应物理页的顺序）插入，维持链表有序。
    // 此初始化函数只登记空闲块，不执行相邻块合并。
    if (list_empty(&free_list)) {
        // page_link 是嵌在 Page 内的链表结点，含 prev、next 两个指针。
        // list_add(a,b) 把 b 插在 a 后面；此处插到哨兵之后，成为首个块。
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;  // le（list entry）只指向链表结点，不是 Page。
        while ((le = list_next(le)) != &free_list) {
            // le 指向结构体内部的链表结点，le2page 反推出所属 Page 的地址。
            struct Page* page = le2page(le, page_link);
            if (base < page) {  // 同一描述符数组内，指针大小反映对应物理页的先后。
                // 遇到第一个地址更大的块，插在它之前。
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                // 已到最后一个块且新块地址更大，list_add 将其插在当前结点之后。
                list_add(le, &(base->page_link));
            }
        }
    }
}

static struct Page *
default_alloc_pages(size_t n) {
    // n 是申请的连续物理页数；返回首页的 Page *，失败返回 NULL。
    assert(n > 0);
    // 总空闲页数不足时直接失败；总数足够也可能因缺少连续空间而失败。
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;       // 保存最终选中的块首页，NULL 表示尚未找到。
    list_entry_t *le = &free_list;  // 从哨兵出发，第一次 list_next 得到首个空闲块。
    // 每次从头遍历，回到哨兵表示遍历结束。
    while ((le = list_next(le)) != &free_list) {
        // 用 page_link 成员在 Page 内的偏移，从结点地址还原所属描述符地址。
        struct Page *p = le2page(le, page_link);  // p 是当前候选空闲块的首页。
        // 找到第一个足够大的块立即停止，这就是 First-Fit 的选择规则。
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        // 先保存原位置的前驱，再摘下整个块，准备分配低地址端的 n 页。
        list_entry_t* prev = list_prev(&(page->page_link));  // 可能是哨兵，也可能是前一块。
        list_del(&(page->page_link));  // 修改相邻结点的链接，不删除描述符或物理页。
        // 例如原块 5 页、申请 2 页：前 2 页分配，后 3 页作为新空闲块。
        // 恰好够用时不需要拆分，也不会产生新的链表结点。
        if (page->property > n) {
            struct Page *p = page + n;  // 此处 p 是剩余块首页，与遍历时的 p 作用域不同。
            p->property = page->property - n;  // 原块页数减去已分配页数。
            SetPageProperty(p);               // 剩余块有了新的首页。
            // 剩余块放回原位置，地址顺序仍然正确。
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;  // 无论是否拆分，只扣除实际分配的 n 页。
        // 已分配的首页不再是空闲块首页。旧 property 数值不必清零，
        // 只有带 PG_property 标记的空闲块首页才用 property 表示块长。
        ClearPageProperty(page);
    }
    // 未找到连续 n 页时 page 仍为 NULL；成功时返回首页描述符而非数据地址。
    return page;
}

static void
default_free_pages(struct Page *base, size_t n) {
    // base 是归还区间的首个描述符，n 是连续页数；无需与原申请的块长相同，
    // 但整个归还区间必须确实属于尚未释放的页面。
    // 调用者必须归还合法且尚未释放的连续页面；这些断言不是完整的合法性检查。
    assert(n > 0);
    struct Page *p = base;  // 先逐页重置；后面复用 p 指向前驱或后继空闲块首页。
    for (; p != base + n; p ++) {
        // 保留页不能回收，已有空闲块首页标记也不应再次回收。
        // 注意：空闲块内部页同样没有首页标记，不能仅据此判断页面已分配。
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;        // 清除该描述符状态；不会修改物理页中存放的数据。
        set_page_ref(p, 0);  // 将引用计数 ref 清零。
    }
    // 将归还区间先组织成一个独立空闲块；这里只重置描述符，不清零页内容。
    base->property = n;
    SetPageProperty(base);  // 标记刚归还区间的首页。
    nr_free += n;          // 仅在这里增加页数，后续合并不再增加。

    // 与初始化登记时相同：先按地址插入，才能只检查前驱和后继来寻找相邻块。
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;  // 插入阶段的遍历游标，作用域限于这个 else。
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);  // 当前已有空闲块的首页。
            if (base < page) {
                list_add_before(le, &(base->page_link));  // 新块放在地址更大的块之前。
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));  // 当前已是末块，新块追加到它之后。
            }
        }
    }

    // 先尝试向低地址合并。链表前驱可能与本块之间隔着已分配页，
    // 所以必须检查“前驱起点 + 前驱页数 == 本块起点”，不能只看链表相邻。
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {  // 哨兵不属于 Page，必须先排除它才能使用 le2page。
        p = le2page(le, page_link);  // p 指向前驱空闲块首页。
        if (p + p->property == base) {  // 前驱区间的末尾（不含）恰好等于归还区间起点。
            p->property += base->property;  // 两块的连续页数相加。
            ClearPageProperty(base);        // 原 base 变成合并块内部页，清除首页标记。
            list_del(&(base->page_link));   // 仅保留低地址的 p 作为链表中的块代表。
            // 合并后首页变为前驱，后面的向后合并必须以这个新首页为准。
            base = p;
        }
    }

    // 再尝试向高地址合并，因此一次回收可以把前、中、后三块合成一块。
    le = list_next(&(base->page_link));
    if (le != &free_list) {  // 若下一结点是哨兵，说明当前块已经是最后一块。
        p = le2page(le, page_link);  // p 此时指向后继空闲块首页。
        if (base + base->property == p) {  // 当前块末尾（不含）等于后继起点。
            base->property += p->property;  // 合并后仍由 base 代表整个块。
            // 后继不再单独代表一个空闲块，清除首页标记并移除其链表结点。
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}

static size_t
default_nr_free_pages(void) {
    // 合并仅改变块的组织，不改变空闲页总数；回收时 nr_free 只增加一次 n。
    return nr_free;
}

// 基础自检：检查单页分配、页面不重复、空闲区耗尽以及回收后再次分配。
static void
basic_check(void) {
    // alloc_page()/free_page(p) 是 alloc_pages(1)/free_pages(p,1) 的宏简写。
    // 公共接口再通过当前 pmm_manager 的函数指针调用本文件中的分配/回收函数。
    // assert(条件) 在条件不成立时报告失败；这里的赋值表达式还会实际执行申请。
    struct Page *p0, *p1, *p2;  // 保存三个已申请页的描述符，以便比较和回收。
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    // page2pa 将描述符转换为对应物理页的起始地址；PGSIZE 是每页字节数。
    // npage 是物理页号上界（不含），npage * PGSIZE 就是相应地址上界。
    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    // 暂存原链表头中的两个链接，再将当前头重置为空，隔离其他空闲块。
    // 这里只保存头结点，不复制所有链表结点；测试结束后会恢复这些链接。
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;  // 同时备份原空闲页数，与隔离后的链表匹配。
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;  // 保存再次申请到的页；预期就是刚归还的 p0。
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    // 测试区的三个页此时都已分配，先恢复原空闲区，再把这三个页归还。
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
// 综合自检：核对链表统计，并用连续 5 页验证拆分、First-Fit 选择和回收合并。
static void
default_check(void) {
    int count = 0, total = 0;  // count 统计块数；total 统计各块 property 之和（页数）。
    list_entry_t *le = &free_list;  // 遍历游标，最后也用于核对测试前后的统计结果。
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    // p0 初始指向连续 5 页的首页；p1 保存子块，p2 保留中间页的位置。
    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    // 暂存并隔离其他空闲块，后续只观察刚申请的这 5 页。
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;  // 原空闲区计数，稍后连同链表一起恢复。
    nr_free = 0;

    // 用 0..4 表示最初 5 页：先归还第 2、3、4 页，此时最大空闲块只有 3 页。
    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;  // 保存第 1 页，它仍被占用，暂时隔开前后空闲块。
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    // 此时空闲块为第 0 页和第 2..4 页；申请 1 页应首先选择低地址的第 0 页。
    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    // 再申请 2 页：跳过仅有 1 页的块，从第 2..4 页中取前 2 页，留下第 4 页。
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);  // 归还第 2、3 页，与仍空闲的第 4 页向后合并。
    free_page(p2);      // 归还第 1 页，连接第 0 页和第 2..4 页，最终恢复连续 5 页。

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;  // 隔离区已全部取出，恢复原空闲区的计数。

    free_list = free_list_store;
    free_pages(p0, 5);  // 恢复原链表后，再把测试申请的整个 5 页区间归还。

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;  // 用最终统计抵消最初统计，检查是否恢复原状。
    }
    assert(count == 0);
    assert(total == 0);
}

// 注册统一接口：pmm.c 中的 alloc_pages/free_pages 等通过函数指针调用本实现。
const struct pmm_manager default_pmm_manager = {
    // .字段 = 函数名 是结构体的指定初始化；函数名在此作为函数指针保存。
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};
