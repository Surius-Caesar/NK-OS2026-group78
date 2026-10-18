# 操作系统实验报告

## 实验基本信息

| 项目 | 内容 |
|------|------|
| **实验名称** | Lab 2: 物理内存管理 |
| **小组成员** | 2413410-韩芳逸、2413993-徐锐、[学号-姓名] |
| **完成日期** | 2026-10-17 |

### 小组分工

练习如何分工？

| 成员 | 负责的练习/模块 |
|------|----------------|
| 2413410-韩芳逸 | 功能模块一：物理内存初始化（`page_init()`） |
| 2413993-徐锐 | 功能模块二：任务一，任务二，任务三 |
| [学号-姓名] | [待补充] |

实验报告如何分工？

---

## 一、实验目的

<!-- 说明本次实验的主要目标和预期成果 -->

本实验的主要目的是：

1. 理解物理内存在操作系统启动链路中的角色：内核如何从设备树（DTB）发现物理内存、如何用 `Page` 描述符数组组织物理页、如何把可用页面交给物理内存管理器。
2. 掌握虚拟地址、物理地址、物理页号（PPN）与 `Page` 描述符地址四者之间的区别和换算关系，理解 Sv39 分页下内核高地址虚拟空间与物理地址之间的固定偏移 `PHYSICAL_MEMORY_OFFSET`。
3. 掌握 `struct pmm_manager` 抽象接口，理解 `init/init_memmap/alloc_pages/free_pages/nr_free_pages/check` 各成员的职责，以及物理内存管理器与上层分配逻辑的解耦方式。
4. 通过阅读 First-Fit 实现，理解连续物理页的初始化、分配、回收以及相邻空闲块合并的完整过程，并能分析其碎片问题。
5. 能够独立设计 Best-Fit 连续物理内存分配算法并接入现有框架，进一步了解 Buddy System（页级按 2 的幂拆分/合并）与 SLUB（页级之上的任意大小对象分配）两种分配思想。


---

## 二、实验环境

你们使用的 AI 工具

| 成员 | AI 编程工具 | 底层模型 | 备注 |
|------|------------|---------|------|
| 2413410-韩芳逸 | Claude Code（VS Code 扩展） | DeepSeek-V4-Flash | 用于代码阅读、提示词迭代、编译与 QEMU 验证 |
| 2413993-徐锐 | Codex(VScode插件)，ChatGPT桌面版 | GPT6 | |
| [学号-姓名] | | | |

**说明：**
- **AI 编程工具**：指具体使用的终端工具、编辑器插件、桌面应用或浏览器界面
- **底层模型**：指该工具使用的大语言模型及版本

---

## 三、实验整体逻辑分析

### 2.1 本章节的逻辑主线

本章围绕**物理内存的发现、组织与分配**这一核心主题展开，要解决的问题是：内核启动后，如何知道机器上有多少可用物理内存，如何把这些内存组织成可管理的页，并在此基础上提供页面分配与回收能力，为后续虚拟内存、进程管理等子系统打下基础。

整条实现链可以分为两条交织的线索：

- **元数据线索（地址与描述符）**：从设备树获取物理内存范围 → 设置内核虚拟/物理地址偏移 `va_pa_offset` → 确定可管理页号上界 `npage` → 在内核镜像结尾 `end` 之后建立 `Page` 描述符数组 `pages` → 把 OpenSBI、内核镜像、描述符数组自身占用的页面标记为保留。
- **分配器线索（策略与数据结构）**：选定 `pmm_manager` → 把剩余完整空闲页注册为空闲块 → 实现分配/释放/合并策略（First-Fit、Best-Fit，扩展任务中的 Buddy、SLUB）→ 由检查函数验证分配器的正确性。

两条线索在 `init_memmap()` 处汇合：`page_init()` 负责"有哪些页可管"，分配器负责"这些页怎么分配"。整体调用链为：

```
kern_init() → dtb_init() → pmm_init()
    → init_pmm_manager()    选定并初始化 pmm_manager
    → page_init()           探测内存、建立描述符、注册空闲页
    → init_memmap()         pmm_manager->init_memmap()
    → check_alloc_page()    pmm_manager->check()
后续：alloc_pages()/free_pages() 提供页面级内存服务
```

### 2.2 功能的逐步实现

本章实验按照"先建立元数据，再实现分配策略，最后扩展更复杂的分配器"的顺序逐步实现：

1. **首先实现功能模块一：物理内存初始化（`page_init()`）** → 这是后续一切物理内存管理的基础。没有正确的 `pages`、`npage`、`va_pa_offset` 和初始空闲页链表，分配器就无从谈起；同时该函数还决定了哪些页面是保留的，直接影响内核自身的安全。
2. **接着理解 First-Fit 分配器（思考题）** → 框架已提供 `default_pmm.c` 的完整实现作为参照。通过阅读 `default_init`、`default_init_memmap`、`default_alloc_pages`、`default_free_pages`，掌握空闲链表、`property` 块长度、相邻块合并等约定，为自行实现 Best-Fit 建立接口和状态约定上的参照。
3. **然后实现并接入 Best-Fit 分配器** → 在相同的 `pmm_manager` 接口下替换分配策略，需要自行设计内部空闲链表和注册结构 `best_fit_pmm_manager`，并在 `init_pmm_manager()` 中切换管理器。这一步验证了"分配算法可插拔"的抽象设计，也暴露了 First-Fit 在减少外部碎片方面的不足。
4. **最后完成 Buddy System 与 SLUB 扩展任务** → Buddy System 在页级用 2 的幂大小的块进行拆分与合并，与前两种连续分配算法形成对比；SLUB 则在页级分配之上再构建任意大小对象的缓存层，形成"页分配器 + 对象分配器"的两层架构。二者都需要自行设计提示词和测试，是对分配器设计能力的综合检验。



---

## 四、实验内容与实现

<!-- 
说明：本部分按照 exercises 文档中的练习顺序组织
每个功能模块或者练习中可能包含多项任务，请根据实际情况调整
-->

### 功能模块：物理内存初始化

**负责人：** 2413410-韩芳逸

#### 模块功能描述

**需要实现/修改的函数：**

```c
// kern/mm/pmm.c
static void page_init(void);
```

**功能说明：**

本模块位于内核物理内存管理链路的起点：

```
pmm_init() -> init_pmm_manager() -> page_init() -> init_memmap() -> check_alloc_page()
```

`page_init()` 根据设备树（DTB）报告的物理内存范围，建立内核可管理的 `Page` 描述符布局，并把排除 OpenSBI 占用区、内核镜像、描述符数组自身以及页对齐空隙之后的完整空闲页面交给当前 `pmm_manager`，为后续页面分配提供正确的初始状态。它不接收参数、不返回结果，由 `pmm_init()` 在 `init_pmm_manager()` 与 `check_alloc_page()` 之间调用。

具体需要完成三件事：

1. **设置地址转换基准**：把 `va_pa_offset` 设为 `PHYSICAL_MEMORY_OFFSET`，且必须在任何 `PADDR()` 调用之前完成。内核代码运行在 `KERNBASE` 起始的高地址虚拟空间，对应物理地址从 `KERNEL_BEGIN_PADDR` 开始，两者相差该固定偏移。
2. **建立页描述符数组**：读取 `get_memory_base()` 与 `get_memory_size()`，确定物理页号上界 `npage = PPN(mem_base + mem_size)`；把 `pages` 放在内核镜像结尾符号 `end` 之后并按页对齐；为 `[nbase, npage)` 中的每个物理页建立描述符，先显式清零、再置 `PG_reserved` 并令引用计数为 0。这样 OpenSBI 占用区、内核镜像和描述符数组自身都不会被后续分配器使用。
3. **注册空闲页**：空闲区起点为描述符数组末尾的物理地址向上按页对齐，末端为 DTB 报告的内存末端向下按页对齐（且不超过框架上界 `PHYSICAL_MEMORY_END`）；只有区间非空时才调用 `init_memmap()`，内存末尾不足一页的部分不交给分配器。最后用 `cprintf()` 输出探测到的物理内存范围。

需要处理的主要场景：

| 场景 | 处理方式 |
|------|----------|
| DTB 提供有效的物理内存信息 | 建立完整描述符布局，注册空闲区，打印内存范围 |
| DTB 信息无效（基址或大小为 0，或基址不是 `DRAM_BASE`） | 调用 `panic()` 终止初始化 |
| 没有可用完整页面（空闲区间为空） | 不调用 `init_memmap()`，函数正常返回 |

与其他模块的交互：

- 由 `pmm_init()` 调用，执行完后再由 `check_alloc_page()` 验证分配器；
- 通过 `init_memmap()` 把空闲页交给当前 `pmm_manager`（本阶段为 `default_pmm_manager`）；
- 通过 `PADDR()` 与 `pa2page()` 在虚拟地址、物理地址、物理页号和描述符地址之间换算；
- 正确设置 `pages`、`npage`、`va_pa_offset`，供后续 `page2ppn()`、`page2pa()`、`pa2page()` 及分配器检查函数使用。

**关键实现细节：**

- **严格区分四类地址**：`pages` 保存虚拟地址；描述符数组末尾先用 `PADDR()` 转成物理地址，再做 `ROUNDUP`；空闲区端点均在物理地址上计算；物理页号只从物理地址提取（`PPN()`）。
- **`npage` 不截断**：`npage` 必须等于 DTB 内存末端对应的页号，不能取 `min(mem_end, PHYSICAL_MEMORY_END) >> PGSHIFT`。`PHYSICAL_MEMORY_END` 只用于收缩空闲区末端；描述符数组需要覆盖 `[nbase, npage)` 的完整区间，否则可管理范围与设备树报告的范围不一致，无法通过验收。
- **描述符先清零**：描述符数组位于 `end` 之后，`kern_init()` 中的 `memset(edata, 0, end - edata)` 不会清理该区域，因此不能假设其内容为 0，必须显式清零 `flags` 后再置保留位，避免残留的 `PG_property` 位干扰分配器。

**最终实现（kern/mm/pmm.c）：**

```c
//lab2 function1 YOUR CODE

/* page_init - detect physical memory and build the Page descriptor array */
static void page_init(void) {
    extern char end[];

    // get the physical memory range reported by the device tree
    uint64_t mem_base = get_memory_base();
    uint64_t mem_size = get_memory_size();
    if (mem_base == 0 || mem_size == 0 || mem_base != DRAM_BASE) {
        panic("page_init: invalid physical memory info (base = 0x%lx, size = 0x%lx)",
              mem_base, mem_size);
    }
    uint64_t mem_end = mem_base + mem_size;

    // set the kernel virtual/physical offset before any PADDR() is used
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // npage is the exclusive upper bound of manageable page numbers. It must
    // follow the memory end reported by the device tree and must NOT be
    // truncated by PHYSICAL_MEMORY_END.
    npage = PPN(mem_end);
    if (npage <= nbase) {
        panic("page_init: no manageable physical page");
    }

    // the descriptor array starts at the page-aligned end of the kernel image
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
    size_t nr_pages = npage - nbase;

    // the area after `end` is not zeroed by kern_init(), so clear the array
    // explicitly and mark every page frame as reserved
    memset(pages, 0, nr_pages * sizeof(struct Page));
    for (size_t i = 0; i < nr_pages; i ++) {
        SetPageReserved(&pages[i]);
    }

    // compute the free page range in physical address space: it starts after
    // the descriptor array and ends at the page-aligned memory end, but never
    // beyond the physical memory limit of the framework
    uintptr_t pages_end_pa =
        PADDR((uintptr_t)pages + nr_pages * sizeof(struct Page));
    uintptr_t free_start_pa = ROUNDUP(pages_end_pa, PGSIZE);
    uintptr_t free_end_pa = ROUNDDOWN((uintptr_t)mem_end, PGSIZE);
    if (free_end_pa > PHYSICAL_MEMORY_END) {
        free_end_pa = PHYSICAL_MEMORY_END;
    }

    // only hand over complete free pages; an empty range is legal
    if (free_end_pa > free_start_pa) {
        struct Page *base = pa2page(free_start_pa);
        size_t n = (free_end_pa - free_start_pa) >> PGSHIFT;
        init_memmap(base, n);
    }

    cprintf("physical memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_base,
            mem_base + mem_size - 1);
}
```

#### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

````markdown

**任务**：修改文件 `kern/mm/pmm.c`，实现内核的物理内存探测与页描述符初始化功能，即在该文件中标有 `//lab2 function1 YOUR CODE` 的位置补全静态函数 `page_init()`。该功能把设备树探测到的物理内存范围转换成内核可管理的物理页描述符布局，并把排除 OpenSBI、内核镜像和描述符数组自身占用空间后的完整空闲页面交给当前 `pmm_manager` 管理，为后续页面分配提供正确的初始状态。

`page_init()` 是 `pmm_init()` 中 `init_pmm_manager()` 与 `check_alloc_page()` 之间的一个阶段。本任务只涉及 `kern/mm/pmm.c` 一个文件，不涉及物理内存管理器的选择（仍保持 `default_pmm_manager`），也不涉及任何页面分配/回收算法。

**操作要求**：你必须在项目中修改实际文件，而不是仅展示代码。主函数体只能补全在 `kern/mm/pmm.c` 的 `//lab2 function1 YOUR CODE` 标记处，并保留文件中现有代码与注释；可在该标记附近新增 static 辅助函数、内部宏定义和 static 变量，但不得改动任何公开接口。不要删除或改写 `init_pmm_manager()`、`init_memmap()`、`alloc_pages()`、`free_pages()`、`nr_free_pages()`、`pmm_init()`、`check_alloc_page()` 的现有逻辑（`pmm_init()` 中对 `page_init()` 的调用点已存在）。不得修改 `kern/mm/pmm.h`、`kern/mm/memlayout.h`、`kern/mm/mmu.h`、`kern/driver/dtb.c`、`kern/driver/dtb.h`、`kern/mm/default_pmm.c` 以及 `tools/` 下的任何文件。

**输出要求**：直接进行文件操作。使用下面 [RELY]、[GUARANTEE]、[SPECIFICATION] 中提供的信息，以工程真实代码为准，不要凭记忆改写宏名或结构体名。不要引入与本功能无关的机制（页表建立、中断、时钟、新的 pmm_manager 等），也不要额外生成测试代码。

[RELY]
//  宏定义

// kern/mm/mmu.h
#define PGSIZE          4096                    // bytes mapped by a page
#define PGSHIFT         12                      // log2(PGSIZE)
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)

// libs/defs.h（二者内部使用 typeof(a)，对 end 这类数组符号必须先把参数转成整型或指针类型，例如 (uintptr_t)end 或 (void *)end）
#define ROUNDDOWN(a, n) ({ size_t __a = (size_t)(a); (typeof(a))(__a - __a % (n)); })
#define ROUNDUP(a, n)   ({ size_t __n = (size_t)(n); (typeof(a))(ROUNDDOWN((size_t)(a) + __n - 1, __n)); })

// kern/mm/memlayout.h
#define KERNBASE                0xFFFFFFFFC0200000  // 内核虚拟地址起点
#define KERNEL_BEGIN_PADDR      0x80200000          // 内核镜像起始物理地址
#define PHYSICAL_MEMORY_OFFSET  0xFFFFFFFF40000000  // 内核虚拟地址与物理地址之间的固定偏移量
#define PHYSICAL_MEMORY_END     0x88000000          // 框架默认 128MiB 配置下的映射上界（KERNTOP = KERNBASE + KMEMSIZE 对应的物理地址）；它只用于收缩可交给分配器的空闲区末端，不得用于截断 npage。设备树报告的末端可能大于它（例如 -m 256M 时 DTB 末端为 0x90000000）

// libs/riscv.h
#define DRAM_BASE               0x80000000          // 本框架固定假设 DRAM 从该物理地址开始

// kern/mm/pmm.h：由内核虚拟地址求物理地址（参数小于 KERNBASE 时 panic，且依赖 va_pa_offset 已被正确设置）
// 注意：本工程中 KADDR 宏被整体注释掉了，不存在可用的反向转换宏。
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

// kern/mm/memlayout.h：本任务只涉及"保留"标志位
#define PG_reserved                 0       // 置 1 表示该页被保留，不可分配
#define SetPageReserved(page)       ((page)->flags |= (1UL << PG_reserved))
#define ClearPageReserved(page)     ((page)->flags &= ~(1UL << PG_reserved))
#define PageReserved(page)          (((page)->flags >> PG_reserved) & 1)

//数据结构

// kern/mm/memlayout.h：每个物理页对应一个描述符，其布局决定了描述符数组的物理占用
struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};

// 全局变量（定义在 kern/mm/pmm.c，本函数需要正确设置前三个）
struct Page *pages;                        // Page 描述符数组的起始虚拟地址
size_t npage = 0;                          // 设备树报告的内存末端对应的物理页号（可管理页号开区间上界）
uint64_t va_pa_offset;                     // 虚拟地址与物理地址之间的偏移量
const size_t nbase = DRAM_BASE / PGSIZE;   // DRAM 起始位置对应的物理页号，DRAM_BASE = 0x80000000

//可用函数

// kern/driver/dtb.h：设备树探测出的物理内存信息（dtb_init() 已在 kern_init() 中调用）
uint64_t get_memory_base(void);
uint64_t get_memory_size(void);

// kern/debug/assert.h
#define panic(...)  __panic(__FILE__, __LINE__, __VA_ARGS__)

// libs/stdio.h
int cprintf(const char *fmt, ...);

// kern/mm/pmm.c 内已存在的包装函数（static，位于同一文件，可直接调用）：
//   static void init_memmap(struct Page *base, size_t n) {
//       pmm_manager->init_memmap(base, n);
//   }
// 即把 base 起的 n 个连续页交给当前 pmm_manager 注册为初始空闲区；
// 本任务不需要直接访问 pmm_manager 结构体。

// kern/mm/pmm.h 内的地址转换与描述符访问函数（已实现，直接调用）：
static inline ppn_t page2ppn(struct Page *page);        // page - pages + nbase
static inline uintptr_t page2pa(struct Page *page);     // page2ppn(page) << PGSHIFT
static inline struct Page *pa2page(uintptr_t pa);       // &pages[PPN(pa) - nbase]，PPN(pa) >= npage 时 panic
static inline void set_page_ref(struct Page *page, int val);

// 链接脚本 tools/kernel.ld 提供的符号（在函数内用 extern char end[]; 声明）：
//   etext / edata / end —— 内核各段结尾的虚拟地址，其中 end 是内核镜像结尾的虚拟地址

//调用关系（kern/mm/pmm.c 现有代码）
void pmm_init(void) {
    init_pmm_manager();   // 选定 pmm_manager 并调用其 init()
    page_init();          // <== 你要实现的函数
    check_alloc_page();   // pmm_manager->check()
    /* ...输出 satp 地址... */
}

[GUARANTEE]
必须实现或修改的接口：
```c
static void page_init(void);
```
要求定义在 `kern/mm/pmm.c` 中 `//lab2 function1 YOUR CODE` 标记处（位于 `pmm_init()` 定义之前，保证调用点可见），签名与声明完全一致：不接收参数，不返回结果。

你可以根据需要添加：
- 辅助函数（建议设为 static，放在该标记附近）
- 内部使用的宏定义
- 模块内部的静态变量

[SPECIFICATION]
## page_init
**Pre-Condition**:
- 由 `pmm_init()` 调用；在此之前 `init_pmm_manager()` 已经选定 `pmm_manager` 并调用过它的 `init()`，此时空闲页面数为 0。
- `dtb_init()` 已经在 `kern_init()` 中执行完毕，设备树报告的物理内存基址与大小可以通过 `get_memory_base()` 与 `get_memory_size()` 获得。
- 内核已经在 Sv39 分页模式下运行：内核代码与数据位于以 `KERNBASE` 开头的高地址虚拟空间，对应物理地址从 `KERNEL_BEGIN_PADDR` 开始，两者相差 `PHYSICAL_MEMORY_OFFSET`。
- 全局变量 `pages` 为 NULL、`npage` 为 0，描述符数组尚未建立。

**Post-Condition**:
- `va_pa_offset` 必须精确等于 `PHYSICAL_MEMORY_OFFSET`（内核虚拟地址减去它即得到对应物理地址），且必须在任何 `PADDR()` 调用之前完成赋值。
- `npage` 必须精确等于 `PPN(mem_base + mem_size)`，即 `(get_memory_base() + get_memory_size()) >> PGSHIFT`，且必须大于 `nbase`。它是可管理物理页号的开区间上界（最后一个可管理页的页号加一），**不受 `PHYSICAL_MEMORY_END` 约束**：即使设备树报告的末端超过 `PHYSICAL_MEMORY_END`，`npage` 也取设备树末端对应的页号，不得截断。
- `pages` 指向一个连续、按页对齐的 `Page` 描述符数组，其虚拟地址不早于内核镜像结尾符号 `end` 所在地址向上按页对齐的边界；数组条目数等于 `npage - nbase`，恰好覆盖 `[nbase, npage)` 中的每个物理页，物理页号与数组下标的对应关系与工程中既有 `pa2page()` / `page2ppn()` 的实现保持一致。
- 在空闲区建立之前，数组中的每个描述符都必须显式清零（`flags = 0`），随后处于保留状态（`PG_reserved` 为 1）且引用计数为 0。描述符数组位于 `end` 之后，该区域未被 `kern_init()` 清零，不能假设其初始内容为 0。
- 当前 `pmm_manager` 只接管排除 OpenSBI 占用区、内核镜像、描述符数组自身占用空间以及页对齐空隙之后的**完整空闲页面**，且这些页面已按 `init_memmap()` 的接口约定完成注册；此后 `pa2page()` 与 `page2pa()` 对 `[nbase, npage)` 内的任何物理页都能正确互换。
- 输出探测到的物理内存范围，函数正常返回。

  **Case 1（设备树提供了有效的物理内存信息）**:
  - 触发条件：`get_memory_base() == DRAM_BASE` 且 `get_memory_size()` 非 0。
  - 执行行为与最终状态：建立完整的描述符布局并注册空闲区——物理页号落在 `[nbase, npage)` 内的每个物理页都有对应的描述符；OpenSBI 占用区、内核镜像、描述符数组自身以及页对齐产生的空隙所对应的页面保持保留状态，只有描述符数组之后、空闲区末端之前的完整空闲页面被交给当前 `pmm_manager`。函数在输出探测到的物理内存范围后正常返回。

  **Case 2（设备树信息无效）**:
  - 触发条件：`get_memory_base()` 返回 0、`get_memory_size()` 返回 0，或基址与框架固定的 `DRAM_BASE` 不一致。
  - 执行行为与最终状态：通过 `panic()` 终止初始化，不得继续建立描述符数组，也不得注册任何空闲页面。

  **Case 3（没有可用完整页面）**:
  - 触发条件：计算出的空闲区间为空（区间终点不超过起点），包括描述符数组末尾的物理地址已经不小于空闲区末端的情况。
  - 执行行为与最终状态：不得调用 `init_memmap()`，并且不得因该情况 `panic()`；函数仍正常返回，空闲页面数为 0，描述符数组保持全部保留状态。

**Requirements**:
- 必须严格区分虚拟地址、物理地址、物理页号和 Page 描述符地址。物理页号只能从物理地址提取；描述符数组（pages）的虚拟地址可以按页对齐，但空闲区端点和页号计算必须在物理地址上进行。不得对虚拟地址直接取物理页号。`pa2page()` 接受物理地址并返回描述符的虚拟地址；`init_memmap()` 接受描述符的虚拟地址与页数；反向换算由 `page2pa()` / `page2ppn()` 完成。
- 描述符数组的虚拟地址必须按 `PGSIZE` 对齐且不早于 `end` 向上按页对齐的地址，推荐直接取 `ROUNDUP((uintptr_t)end, PGSIZE)`；由于 `ROUNDUP` 使用 `typeof`，必须先将其参数转换为整型。数组条目数为可管理物理页号区间的长度 `npage - nbase`，使得既有 `&pages[PPN(pa) - nbase]` 对每个可管理物理页都落在数组范围内。
- **`npage` 不得被 `PHYSICAL_MEMORY_END` 截断**。`npage` 是设备树内存末端对应的页号，描述符数组与 `pa2page()` 的索引都建立在 `[nbase, npage)` 这一完整区间上；若把 `npage` 改成 `min(mem_end, PHYSICAL_MEMORY_END) >> PGSHIFT`，可管理范围就不再与设备树报告的内存范围一致，工程验收会判定失败。"不超过框架可管理内存上界"这一限制只能用于收缩可交给分配器的空闲区末端。
- 空闲区起点为描述符数组末尾的物理地址（用 `PADDR()` 转换后）向上按页对齐后的地址；空闲区末端为设备树报告的内存末端向下按页对齐后的地址，并且不超过 `PHYSICAL_MEMORY_END`；只有该区间非空时才调用 `init_memmap()`，交给它的页面必须满足 `init_memmap()` 接口的约定：起点描述符及其覆盖的每个页都处于保留状态、引用计数为 0。内存末尾不足一页的部分不得交给分配器。
- 初始化结束后，OpenSBI 占用区、内核镜像、描述符数组所覆盖页面对应的描述符必须仍为保留状态；这些页面不得进入空闲区。
- `PADDR()` 只接受不小于 `KERNBASE` 的内核虚拟地址，且必须在 `va_pa_offset` 设置完成后使用；本工程不存在可用的 `KADDR` 宏，不要使用它，也不要自行引入等价的新宏。
- `page_init()` 执行期间不得调用 `alloc_pages()` / `free_pages()` 等分配或释放接口。
- 物理内存范围使用 `cprintf()` 输出，包含内存大小、内存起点与内存末端三个十六进制值（参考格式如下，具体措辞不限）：
  ```
  physical memory map:
    memory: 0x0000000008000000, [0x0000000080000000, 0x0000000087ffffff].
  ```

````

#### 实现迭代过程

本模块的实现经历了 2 次迭代，过程如下：

---

##### 第一次迭代

第一版提示词给出了 `page_init()` 的完整职责、可用宏与函数、内存布局要求和三个场景的处理方式。AI 据此生成了首版实现：读取 DTB 信息、设置 `va_pa_offset`、按 `end` 对齐建立描述符数组、将描述符置为保留状态、计算描述符数组之后的空闲区并调用 `init_memmap()`。编译通过，`make qemu` 输出与手册样张一致，`check_alloc_page() succeeded!`。

在核对实验手册、框架代码与 `tools/test_lab2.c` 的验收条件后，发现第一版提示词存在以下问题：

**遇到的问题：**

- 问题1：`npage` 是否应被 `PHYSICAL_MEMORY_END` 截断存在歧义。手册中"结合内核能够管理的地址上界确定物理页号范围"的表述容易被理解为 `npage = min(mem_end, PHYSICAL_MEMORY_END) >> PGSHIFT`，但 `tools/test_lab2.c` 明确断言 `npage == PPN(mem_base + mem_size)`。描述符数组需要覆盖 `[nbase, npage)` 的完整区间，截断会使可管理范围与设备树报告的内存范围不一致。原提示词对该规则的说明理由也不准确（误称截断会破坏 `pa2page()` 的索引关系）。
- 问题2：描述符数组位于内核符号 `end` 之后，而 `kern_init()` 的 `memset(edata, 0, end - edata)` 只清零到 `end`，该区域不保证为 0。原提示词只要求"置为保留状态、引用计数为 0"，没有明确要求先清零 `flags`，残留的 `PG_property` 位可能让保留页被误认为空闲块头。
- 问题3：有效性检查只判断基址与大小非 0。若 DTB 返回非 0 但非 `DRAM_BASE` 的基址，`npage - nbase` 会作为 `size_t` 下溢成极大值，描述符初始化循环将越界写入。框架的 `pa2page()`/`page2ppn()` 固定以 `nbase = DRAM_BASE / PGSIZE` 为基准，因此基址必须与 `DRAM_BASE` 一致。
- 问题4：对"没有可用完整页面"的边界描述不完整，未覆盖描述符数组末尾已经越过内存末端的情况；同时 `PHYSICAL_MEMORY_END` 被称为"DRAM 物理末端"也不准确——它只是框架默认 128MiB 配置下的映射上界，使用 `-m` 指定更大内存时 DTB 报告的末端会超过它。

**问题解决策略：**

- 针对问题1：在 `[RELY]` 和 `[SPECIFICATION]` 中明确写出 `npage = PPN(mem_base + mem_size)` 且**不得截断**，并说明 `PHYSICAL_MEMORY_END` 只用于收缩空闲区末端；同时修正了原提示词中错误的理由。
- 针对问题2：在 Post-Condition 与 Requirements 中要求先显式清零 `flags`（`memset` 整个描述符数组）再 `SetPageReserved`，并说明 `end` 之后未被清零。
- 针对问题3：把 Case 1/2 的有效性条件改为 `mem_base == DRAM_BASE && mem_size != 0`，并把 `DRAM_BASE` 补充进 `[RELY]`。
- 针对问题4：完善 Case 3 的触发条件；修正 `PHYSICAL_MEMORY_END` 的措辞；澄清 `[GUARANTEE]` 中"只能在标记处补全"与"允许新增 static 辅助函数"的关系。

---

##### 第二次迭代

按上述四点修订提示词后，AI 生成了最终版本，主要变化为：

- 使用 `PPN(mem_end)` 设置 `npage`，并增加 `npage <= nbase` 的防御性检查；
- 增加 `mem_base != DRAM_BASE` 的有效性判断；
- 用 `memset(pages, 0, nr_pages * sizeof(struct Page))` 清零整个描述符数组，再统一 `SetPageReserved`；
- 空闲区端点严格在物理地址上计算：`PADDR(pages + nr_pages * sizeof(struct Page))` 后 `ROUNDUP`，末端 `ROUNDDOWN(mem_end)` 并截断到 `PHYSICAL_MEMORY_END`；
- 仅在 `free_end_pa > free_start_pa` 时调用 `init_memmap()`；
- 最后输出 `physical memory map` 与内存范围。

**最终结果：**



**关键改进点总结（如有）：**

1. 在 `[RELY]` 中补充 `DRAM_BASE`，并把有效性条件明确为基址必须等于 `DRAM_BASE`，消除了 `npage - nbase` 下溢的风险。
2. 在 `[SPECIFICATION]` 中明确 `npage` 必须严格等于 `PPN(mem_base + mem_size)`、不得被 `PHYSICAL_MEMORY_END` 截断，统一了手册描述与验收脚本之间的歧义。
3. 明确要求描述符数组先清零再置保留位，避免 `end` 之后未初始化内存中的残留标志位影响分配器。
4. 补充了 `PADDR()` 必须在 `va_pa_offset` 赋值之后调用、空闲区端点必须在物理地址上计算等约束，避免虚拟地址/物理地址混用。

#### 扩展任务 Challenge：硬件的可用物理内存范围的获取方法


如果 OS 无法提前获知内存范围，最可靠的首选方案是**依赖固件或引导程序传递描述**：在 RISC-V 架构中，由 Bootloader 通过寄存器传入设备树（DTB），内核解析 `/memory` 节点获取基址与大小；在 x86 架构中，则通过 BIOS 的 E820 中断或 UEFI 的 `GetMemoryMap` 获取内存映射表。固件在自检阶段已排除了 MMIO 空洞和保留区，信息最可靠。若缺乏固件支持，可退而求其次读取 ACPI/SMBIOS 表或 DRAM 控制器寄存器；若只能主动探测，则必须在已知窗口内利用缺页异常机制进行安全的读写测试，以防误触 MMIO 导致系统挂起。无论采用何种方式获取原始内存范围，OS 最终都必须从中扣除 OpenSBI/固件、内核镜像等保留区，才能得到真正可用的物理内存交由页面分配器管理。

---

### 功能模块：物理内存分配功能

**负责人：** 2413993-徐锐，

#### 模块功能描述

**需要实现/修改的函数：**

```c
// 任务一：理解已有 First-Fit 实现，无需修改
// 任务二：实现 Best-Fit，保留已有测试
static void best_fit_init(void);
static void best_fit_init_memmap(struct Page *base, size_t n);
static struct Page *best_fit_alloc_pages(size_t n);
static void best_fit_free_pages(struct Page *base, size_t n);
static size_t best_fit_nr_free_pages(void);
static void init_pmm_manager(void);//选择Best-fit分配器
// 任务三：实现 Buddy System 及其测试
static void buddy_init(void);
static void buddy_init_memmap(struct Page *base, size_t n);
static struct Page *buddy_alloc_pages(size_t n);
static void buddy_free_pages(struct Page *base, size_t n);
static size_t buddy_nr_free_pages(void);
static void buddy_check(void);
static void init_pmm_manager(void);//选择Buddy system分配器
// 任务四：
```

**功能说明：**

- 该模块在系统中的作用

  以页为单位分配和回收连续物理内存，为内核提供物理页面管理服务。

- 需要处理哪些主要场景
  初始空闲页登记、连续页申请、空闲块拆分、页面回收和相邻空闲块合并。

- 如何与其他模块交互
  `page_init()` 通过 `init_memmap()` 交付可用页；内核通过 `alloc_pages()`、`free_pages()` 申请和释放页面。这些接口由 `pmm_manager` 转发到选定的分配器实现。

#### 任务一：理解 first-fit 连续物理内存分配算法

First-Fit 始终维护一条**按物理地址递增排列的空闲块链表**，每个结点代表一个连续空闲块，由块首页记录页数。

1. **初始化：** `default_init()` 建立空链表；`page_init()` 确定可用页面后，由 `default_init_memmap()` 将它们登记为空闲块。

   ```mermaid
   %%{init: {"themeVariables": {"fontSize": "13px"}, "flowchart": {"nodeSpacing": 15, "rankSpacing": 20}}}%%
   flowchart TD
       A[default_init：空链表，nr_free = 0] --> B[page_init：排除保留区]
       B --> C[default_init_memmap：重置可用页描述符]
       C --> D[设置块首页与页数，按地址入链表]
       D --> E[nr_free 加 n，完成登记]
   ```

2. **分配：** `default_alloc_pages(n)` 从链表头找到第一个至少有 `n` 页的块，取出前 `n` 页；若有剩余，就把剩余块留在原位置。找不到合适块则申请失败。

   ```mermaid
   %%{init: {"themeVariables": {"fontSize": "13px"}, "flowchart": {"nodeSpacing": 15, "rankSpacing": 20}}}%%
   flowchart TD
       A[default_alloc_pages：申请 n 页] --> B{nr_free 足够？}
       B -- 否 --> X[返回 NULL]
       B -- 是 --> C[从头查找首个足够大的块]
       C --> D{找到？}
       D -- 否 --> X
       D -- 是 --> E[摘下该块，取前 n 页]
       E --> F{有剩余？}
       F -- 是 --> G[设置剩余块，插回原位置]
       F -- 否 --> H[nr_free 减 n，清除已分配首页标记]
       G --> H
       H --> I[返回首页描述符]
   ```

3. **回收：** `default_free_pages(base, n)` 将归还区间按地址插回链表，再依次与物理相邻的前驱、后继合并，供后续申请使用。

   ```mermaid
   %%{init: {"themeVariables": {"fontSize": "13px"}, "flowchart": {"nodeSpacing": 15, "rankSpacing": 20}}}%%
   flowchart TD
       A[default_free_pages：归还 n 页] --> B[重置描述符，设置块首页与页数]
       B --> C[按地址入链表，nr_free 加 n]
       C --> D{与前驱物理相邻？}
       D -- 是 --> E[合并到前驱，更新首页]
       D -- 否 --> F{与后继物理相邻？}
       E --> F
       F -- 是 --> G[吸收后继，移除后继结点]
       F -- 否 --> H[回收完成]
       G --> H
   ```

> [!note]
>
> 原有的first fit算法是否有进一步的改进空间？
>
> 答：有。
>
> 1. **加速查找。** 当前链表最差要遍历所有空闲块。可以使用按地址排序的平衡树，并在每个子树记录“最大空闲块页数”。查找时跳过不可能满足申请的子树，优先查低地址部分，仍能找到地址最小的合适块，将查找复杂度从 \(O(k)\) 降到 \(O(\log k)\)。
> 2. **加强释放合法性检查。** 当前断言不能完整识别重复释放，尤其是释放空闲块内部页的情况。当调用者错误释放时，可能会出现块重合与后续数据覆盖的问题。可以增加逐页分配状态或位图，检查越界、重复释放和释放区间重叠，提高可靠性。

#### 任务二：实现 Best-Fit 连续物理内存分配算法

##### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

````markdown
[PROMPT]
**任务：** 在 `code/lab2/lab2_new` 中实现并接入 Best-Fit 连续物理页分配器，提供初始化、空闲区登记、连续页分配、回收合并和页数查询功能。
**操作要求：** 在 `kern/mm/best_fit_pmm.c` 的 `lab2`、`YOUR CODE` 标记处补全实现，并在 `kern/mm/pmm.c` 的 `init_pmm_manager()` 中切换为 `best_fit_pmm_manager`。保留已有代码和注释，不修改两个测试函数、First-Fit、`page_init()` 及其他文件。
**输出要求：** 将实现写入上述位置。完成后简要说明改动与验证结果；无法运行时如实说明，不得伪造通过结果。
[RELY]
阅读 `default_pmm.c`、`pmm.h`、`memlayout.h`、`libs/list.h` 和 Best-Fit 的两个测试函数，以工程实际定义为准：
- `Page` 描述一个物理页；空闲块首页通过 `property` 记录页数，以 `PG_property` 标记，并通过 `page_link` 入链表。
- 测试直接访问、清空和恢复 `free_list`、`nr_free`，它们必须是本文件中可访问的真实管理状态，不能依赖测试未同步维护的其他状态。
- `best_fit_pmm.h` 已声明 `best_fit_pmm_manager`；公共分配接口通过 `pmm_manager` 调用具体实现。
[GUARANTEE]
实现以下接口，内部函数名可自行调整：
```c
static void best_fit_init(void);
static void best_fit_init_memmap(struct Page *base, size_t n);
static struct Page *best_fit_alloc_pages(size_t n);
static void best_fit_free_pages(struct Page *base, size_t n);
static size_t best_fit_nr_free_pages(void);
static void init_pmm_manager(void);  // 现有函数，仅修改管理器选择
```
定义 `const struct pmm_manager best_fit_pmm_manager`，注册全部接口，`.check` 使用已有 `best_fit_check()`。允许添加静态状态、辅助函数、宏和必要的前向声明。
[SPECIFICATION]
## best_fit_init
**Pre-Condition：** 尚未登记本轮可用页面。
**Post-Condition：** 空闲链表为空，空闲页数为 0。
## best_fit_init_memmap
**Pre-Condition：** 管理器已初始化；`n > 0`，区间合法、连续、已保留且未登记。
**Post-Condition：** 归入区间解除保留，引用计数清零，正确设置空闲块首页及页数，空闲页总数增加 n。
## best_fit_alloc_pages
**Pre-Condition：** `n > 0`，管理状态有效。
**Post-Condition：** 成功时交付连续 n 页，失败时不改变空闲状态。
**Case 1：** 存在合适块时，选择所有足够大的块中最小者，同大小选地址最低者；交付低地址端 n 页，剩余部分保持可用，空闲页数减少 n，清除已分配首页的空闲块标记，返回首页描述符。
**Case 2：** 空闲页总数不足，或不存在足够大的连续块时，返回 `NULL`。
## best_fit_free_pages
**Pre-Condition：** `n > 0`，区间合法、连续、非保留且未释放，不要求与单次申请边界相同。
**Post-Condition：** 重置归还页的状态和引用计数，空闲页数增加 n，归还区间重新可分配。
**Case 1：** 与两侧均不物理相邻时，成为独立空闲块。
**Case 2：** 与前驱、后继的一侧或两侧物理相邻时，合并为一个块，仅保留最终首页结点和标记；合并不重复增加页数。
## best_fit_nr_free_pages
**Pre-Condition：** 管理器已初始化。
**Post-Condition：** 返回真实空闲页总数，不修改状态。
## init_pmm_manager
**Pre-Condition：** Best-Fit 管理器已完整定义。
**Post-Condition：** 当前管理器为 `best_fit_pmm_manager`，保留原有输出并调用其初始化接口。
## 模块约束与验收
**Requirements：** 空闲链表按地址有序，块间不重叠，每块只有首页入链并标记，首页页数正确。算法复杂度不限。在具备工具链的环境中执行 `make clean`、`make qemu`，确认输出使用 Best-Fit 且原有自检通过，不得修改测试。
````

##### 实现迭代过程

本模块任务的实现经历了0次迭代，一次成功。

**最终结果：**

经过0次迭代，该模块最终：

- ✅ 编译通过

- ✅ 功能符合预期

![](images\模块2任务2.png)

看到确实使用了best-fit调度算法，且成功编译、接入并通过现有自检。

> [!Note]
>
> 实现的Best-fit算法是否存在优化空间？
>
> 答：经分析后存在。
>
> 1. 提高分配查找的效率
>
>    最简单的办法是新增维护一条按内存容量从小到大排序的链表，那么只需要找到第一个符合条件的块即可退出；但是会增加同步地址链表的成本，应为需要同步更新大小链表。
>
> 2. 加强释放合法性检查
>
>    同first-fit算法一样，目前释放时没有检测释放起点是否为空闲块内部的情况，有待加强。

---

### 任务三：buddy system（伙伴系统）分配算法

##### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

*实现buddy system的提示词：*

````markdown
[PROMPT]
**任务：** 在 `code/lab2/lab2_new` 中从零实现并接入 Buddy System 物理页分配器。
**操作要求：** 新建 `kern/mm/buddy_pmm.c`、`buddy_pmm.h`，在 `pmm.c` 中引入头文件并切换管理器；仅在必要时调整构建规则。保留其他分配器、已有测试、`page_init()` 和公共数据结构。
**输出要求：** 写入代码，简述实现与验证结果；无法运行时如实说明，不得伪造通过结果。
[RELY]
阅读 `default_pmm.c`、`pmm.c`、`pmm.h`、`memlayout.h`、`libs/list.h` 和构建规则，以工程实际定义为准.
- 通过 `pmm_manager` 接入；空闲块首页使用 `property`、`PG_property`、`page_link` 管理。
- 统一以物理页号 `page2ppn()` 计算对齐和伙伴，不与描述符数组下标混用。
- n 页请求向上取整为最小的 `s = 2^k >= n`，释放传原请求 n，实际增减 s 页；不支持部分释放。
[GUARANTEE]
实现以下接口，内部函数名可自行调整：
```c
static void buddy_init(void);
static void buddy_init_memmap(struct Page *base, size_t n);
static struct Page *buddy_alloc_pages(size_t n);
static void buddy_free_pages(struct Page *base, size_t n);
static size_t buddy_nr_free_pages(void);
static void buddy_check(void);
static void init_pmm_manager(void);  // 现有函数，仅修改管理器选择
```
定义并在头文件声明 `const struct pmm_manager buddy_pmm_manager`，注册全部接口。允许添加静态状态和辅助函数，不依赖堆分配器；`.check` 暂用无成功输出的占位函数，后续由我说明后补全。
[SPECIFICATION]
## buddy_init
**Pre-Condition：** 尚未登记本轮可用页面。
**Post-Condition：** 各阶空闲链表与辅助状态初始化，空闲页数为 0。
## buddy_init_memmap
**Pre-Condition：** 管理器已初始化；`n > 0`，区间合法、连续、已保留且未登记。
**Post-Condition：** 解除保留、清零引用计数，按物理对齐拆成整幂块，恰好登记 n 页。支持非整幂长度、未对齐起点和多段登记，不遗漏页面、不跨空洞。
## buddy_alloc_pages
**Pre-Condition：** `n > 0`，管理状态有效。
**Post-Condition：** 成功返回 s 页连续且按 s 页对齐的块，空闲页数减少 s，已分配页不再属于空闲块；失败不改变状态。
**Case 1：** 对应阶有块则取出，否则逐级拆分更高阶块，剩余伙伴归入对应链表。
**Case 2：** 无合适块、请求超出支持范围或取整会溢出，返回 `NULL`。
## buddy_free_pages
**Pre-Condition：** base 为成功分配的首页，n 为原请求页数，该块尚未释放且可归还。
**Post-Condition：** 重置归还页状态与引用计数，空闲页数增加 s，合并不重复计数。
**Case 1：** 伙伴页号为 `page2ppn(base) ^ (1UL << k)`；先检查有效管理范围，再访问描述符。
**Case 2：** 仅与同阶空闲伙伴递归合并，直到无法合并或达到最大阶；不得与非伙伴、已分配块或保留页合并。
## buddy_nr_free_pages
**Pre-Condition：** 管理器已初始化。
**Post-Condition：** 返回真实空闲页总数，不修改状态。
## init_pmm_manager
**Pre-Condition：** Buddy 管理器已完整定义。
**Post-Condition：** 选择 `buddy_pmm_manager`，保留原有输出并调用初始化接口。
## 模块约束与验收
**Requirements：** 空闲块大小为 2 的幂、正确对齐且互不重叠；仅首页入链并标记，元数据与页数统计一致。时空复杂度不限。具备环境时执行 `make clean`、`make`、`make qemu`，确认编译及启动正常；占位自检不算测试通过。
````

*测试buddy system的提示词：*

````markdown
[PROMPT]
**任务：** 针对 `task3_realize.md` 生成的 Buddy System 模块，设计并实现测试，检验核心行为和边界情况。
**操作要求：** 补全 `kern/mm/buddy_pmm.c` 中的 `buddy_check()`，允许添加测试辅助函数。保留其他分配器及已有测试；发现实现错误时说明原因并仅作必要修复，不改变接口契约。
**输出要求：** 写入测试，简述覆盖范围及其有效性，报告实际编译运行结果；无法运行时如实说明，不得伪造通过结果。
[RELY]
阅读给定的提示词、Buddy 实现、`pmm.c/.h`、`memlayout.h` 和已有分配器测试，以第一份提示词的契约为判定依据：

- 请求向上取整，释放传原请求，统计按实际块大小变化。
- 伙伴关系以物理页号计算，相邻块不一定是伙伴。
- 使用真实分配器与合法页面；测试结束后须恢复内存管理状态。
[GUARANTEE]
实现以下接口，辅助函数可自行设计：
```c
static void buddy_check(void);
```
由 `buddy_pmm_manager.check` 调用，使用断言检验实际结果；全部通过后才输出 `buddy_check() succeeded!`。覆盖公共分配接口与可控小内存池，不以模拟分配器替代被测实现。
[SPECIFICATION]
## 测试环境
**Pre-Condition：** Buddy 管理器已初始化并登记可用页面。
**Post-Condition：** 测试使用合法隔离区域，完整保存、恢复管理状态及必要元数据；所有临时页面归还，原空闲页数恢复，公共接口仍可正常使用。
## 基本分配与取整
**Pre-Condition：** 测试区容量足够，初始页数已记录。
**Post-Condition：** 分别申请并释放 1、2、4、3、5 页，检查连续性、物理对齐、互不重叠及计数；3、5 页分别实际占用 4、8 页，释放后恢复。
## 拆分与合并
**Pre-Condition：** 受控池仅含一个物理对齐的 8 页空闲块。
**Post-Condition：** 拆成 8 个单页后耗尽，按不同顺序释放后可重新申请完整 8 页块，计数正确。
**Case 1：** 分别先释放低地址和高地址伙伴，均能递归合并。
**Case 2：** 仅释放相邻非伙伴时不能合并；伙伴仍被占用时不能合并，释放后才能合并。
## 登记与失败边界
**Pre-Condition：** 受控池及登记区间满足接口前置条件。
**Post-Condition：** 验证登记无遗漏、无越界，失败请求不改变空闲块集合与计数。
**Case 1：** 覆盖单页、非整幂长度、未对齐起点和含保留空洞的多段登记，分配结果不得包含区间外页面。
**Case 2：** 覆盖空池、请求过大、总量足够但无合适阶块、取整溢出及边界伙伴越界情况；非法输入不混入正常启动测试。
## 状态一致性与验收
**Pre-Condition：** 各用例使用满足契约的分配、释放序列。
**Post-Condition：** 链表、首页标记和阶数一致，空闲块对齐且不重叠，空闲页数等于块大小之和，不遗留可合并伙伴。
**Requirements：** 增加有界且混合分配与释放两种操作的序列，用独立占用记录检查重叠和计数，最终全部归还。具备环境时执行 `make clean`、`make`、`make qemu`，确认测试入口执行、断言通过且内核继续启动。简述各用例如何发现拆分、合并、越界、计数和状态恢复错误。
````

---

**最终结果：**

经过0次迭代，该模块最终：

- ✅ 编译通过

- ✅ 功能符合预期

![](images\模块2任务3.png)  

buddy system成功通过测试。

测试的主要场景：

1. **基本分配与释放。** 测试申请不同大小的内存块，检查返回页面连续、地址对齐且各块互不重叠；释放后检查空闲页数恢复，验证基本功能及页数统计是否正确。

2. **非整幂请求向上取整。** 申请 3 页、5 页时，检查实际分别占用 4 页、8 页，并在按原请求页数释放后恢复容量，验证取整策略与释放接口的一致性。

3. **逐级拆分。** 将一个对齐的 8 页块逐步分配为 8 个单页，检查无重复、无遗漏，第 9 次申请失败，验证高阶块能否正确拆分及剩余伙伴是否正确登记。

4. **伙伴递归合并。** 按不同顺序释放单页，检查最终能否重新申请完整的 8 页块，验证合并是否支持两种释放顺序，以及能否逐级恢复高阶块。

5. **禁止错误合并。** 检查相邻但不是伙伴的块不能合并，伙伴仍被占用时也不能合并，验证实现依据的是伙伴关系和空闲状态，而非此前的仅判断地址相邻。

6. **登记区间与边界。** 测试单页、非整幂长度、未对齐起点及带保留空洞的多段区间，检查登记页无遗漏、分配不越界且不包含保留页，验证初始化和范围检查是否正确。

7. **失败请求处理。** 测试空池、内存不足、总量足够但无合适阶块、请求过大及取整溢出，检查返回 `NULL` 且管理状态不变，验证失败处理不会破坏后续分配。

8. **混合操作与状态恢复。** 交替执行不同大小的分配和释放，用独立记录检查块重叠、链表与页数统计；最终全部释放并再次分配，验证多次操作后没有内存泄漏或状态损坏。

1,2测试基本功能和各函数接口一致性；3,4,5测试核心机制；6,7测试边界处理和失败正常退出；8测试多次使用仍保持稳定性。因此可以有效检验生成的 Buddy System 实现。





### 任务四

##### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

---

**最终结果：**

经过0次迭代，该模块最终：

- ✅ 编译通过

- ✅ 功能符合预期

---

###### 第一次迭代（如有）

[按照和第一次迭代相同的格式]

---

###### 第二次迭代（如有）

[按照和第一次迭代相同的格式]

---

###### 第三次迭代（如有）

[按照和第一次迭代相同的格式]

---

### 练习：

**负责人：**2413410-韩芳逸，2413993-徐锐

#### 功能模块一

#### 功能模块二

任务一、任务二、任务三问题回答均见前文[功能模块：物理内存分配功能详述](#功能模块物理内存分配功能)。

任务四...

---

### Challenge：[Challenge标题]

**负责人：** [学号-姓名]

[按照Challenge的具体要求进行解答]

---

## 五、测试与验证

<!-- 根据该实验的具体情况，提供完整的测试运行截图，应包含：
- 编译及运行成功的输出（make qemu），可能有多个
- 测试通过的结果（make grade），只有一个
-->



**测试截图：**

![测试结果截图](./images/test_result.png)

> 截图待补充：`make qemu` 的完整输出、`make grade` 的 `check page init: OK`、以及多内存规模运行结果。

---

## 六、实验总结与收获

### 对操作系统的理解

#### 1. 本实验重要知识点与 OS 原理知识点的对应关系

| 本实验中的知识点 | 对应的 OS 原理知识点 | 含义、关系与差异 |
|------------------|----------------------|------------------|
| 通过设备树（DTB）获取物理内存基址与大小 | 物理内存探测（BIOS `E820`、`UEFI` 内存描述表、`ACPI`） | 二者都是"由固件/硬件描述告诉内核有哪些物理内存"。实验在 RISC-V + OpenSBI 环境下读取 DTB；x86 上通常由 bootloader 传递内存映射表。差异在信息来源与格式，思想一致。 |
| `Page` 描述符数组 `pages[]` 与 `npage` | 物理页框管理（Linux 的 `struct page`、页帧数据库） | 都是"每个物理页一个元数据对象"，用统一数组/结构体记录引用计数、标志位和空闲链。实验中的描述符数组直接放在内核 `end` 之后静态预留；Linux 则动态建立 `vmemmap`，规模更大、支持稀疏内存与 NUMA。 |
| First-Fit 连续分配 + 相邻空闲块合并 | 动态分区分配算法、外部碎片与紧凑 | 实验用空闲链表按地址有序组织空闲块，分配时取第一个满足大小的块，释放时与前后相邻块合并。OS 原理中讨论首次适应、最佳适应、最坏适应等策略及其碎片特性，实验把其中两种落地为可运行代码。 |
| Best-Fit 分配器 | 最佳适应（Best-Fit）算法 | 选择能满足要求且最小的空闲块，理论上能减少大块被浪费，但会产生大量难以利用的小碎片，且需要遍历整个空闲链表。实验要求自行设计内部状态并接入 `pmm_manager`，体现了策略与机制分离。 |
| `struct pmm_manager` 接口抽象 | 内存管理子系统的机制/策略分离、面向对象式的接口抽象 | 框架把 `init/init_memmap/alloc_pages/free_pages/nr_free_pages/check` 定义成函数指针表，不同算法只需实现同一组接口即可替换。OS 原理中的"机制与策略分离"在这里表现为分配器可插拔。 |
| 区分虚拟地址、物理地址、PPN、描述符地址 | 地址空间、分页机制、地址转换 | 实验在 Sv39 分页已开启的前提下，用 `PADDR()`、`PPN()`、`pa2page()`、`page2pa()` 完成换算；`PHYSICAL_MEMORY_OFFSET` 对应内核直接映射。OS 原理中的多级页表、TLB、页表项权限等概念是这一层换算的完整背景。 |
| 保留 OpenSBI、内核镜像与描述符数组 | 内核映像布局、保留内存区（reserved memory）、内存黑洞 | 实验通过"先全部置保留，再把空闲区交给分配器"的方式保证内核自身不被分配。OS 原理中对应 memblock/reserved regions、`memblock_reserve` 等机制，还需处理内存空洞与热插拔。 |
| Buddy System 与 SLUB（扩展任务） | 伙伴系统、slab/slub 对象分配器 | Buddy 用 2 的幂大小块和伙伴合并解决外部碎片并支持快速拆分；SLUB 在页分配器之上按对象大小建立缓存，解决小对象内部碎片与分配效率问题。二者共同构成 Linux 物理内存管理的两层结构，实验只要求体现主体思想。 |

#### 2. OS 原理中很重要、但本实验没有对应上的知识点

- **虚拟内存与页表的动态建立**：实验沿用启动时的 boot page table，只做固定偏移的直接映射，没有实现按需建立/修改页表、页表项权限控制与地址空间隔离。
- **缺页异常与按需调页**：没有实现 page fault 处理、写时复制（COW）、页面换入换出。
- **页面置换算法**：LRU、Clock、工作集等置换策略在本实验中无从体现。
- **内存回收与 swap**：没有反向映射、页回收、swap 分区等机制。
- **多核并发与锁**：实验为单核顺序执行，未涉及分配器的自旋锁、每 CPU 缓存（per-CPU pageset）与并发安全。
- **NUMA 与稀疏内存**：实验假设物理内存从 `DRAM_BASE` 开始连续分布，未处理内存空洞、内存热插拔与 NUMA 节点。
- **slab 的对象构造/析构与缓存着色**：SLUB 扩展任务只要求体现主体思想，未覆盖对象构造函数、缓存对齐等细节。

### AI 协作开发的经验



---
