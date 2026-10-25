## module1

[PROMPT]

**任务**：修改 `kern/mm/pmm.c`，实现 `page_init()`（以及必要的 `static` 辅助函数），完成物理内存探测与 Page 描述符初始化。函数应根据设备树报告的内存范围，建立覆盖全部可管理物理页的 `Page` 描述符数组，并把排除 OpenSBI、内核镜像和描述符数组自身占用空间后的完整空闲页面交给当前 `pmm_manager` 管理。

**操作要求**：你必须在项目中修改实际文件，保留现有代码，只补全 `page_init()` 的实现；不要修改 `dtb.c`、`default_pmm.c`、测试函数等无关文件。

**输出要求**：直接进行文件操作。以工程中真实的宏、类型和函数为准，使用下面 [RELY]、[GUARANTEE]、[SPECIFICATION] 提供的信息，不要引入无关功能。

[RELY]

宏定义（`kern/mm/memlayout.h`、`kern/mm/mmu.h`、`libs/riscv.h`、`libs/defs.h`）：

```c
#define PGSIZE                 4096
#define PGSHIFT                12
#define PPN(la)                (((uintptr_t)(la)) >> PGSHIFT)
#define DRAM_BASE              0x80000000
#define PHYSICAL_MEMORY_OFFSET 0xFFFFFFFF40000000
#define PHYSICAL_MEMORY_END    0x88000000
```

框架还提供 `PADDR(kva)` 地址转换宏，以及 `ROUNDUP`、`ROUNDDOWN` 页对齐宏。

数据结构（`kern/mm/memlayout.h`）：

```c
struct Page {
    int ref;
    uint64_t flags;
    unsigned int property;
    list_entry_t page_link;
};
```

页面状态宏：`SetPageReserved(page)`、`ClearPageReserved(page)`、`PageReserved(page)`。

全局变量（`kern/mm/pmm.c`、`kern/mm/pmm.h`）：

```c
struct Page *pages;
size_t npage;
uint64_t va_pa_offset;
const size_t nbase = DRAM_BASE / PGSIZE;
```

可用函数与符号：

```c
uint64_t get_memory_base(void);
uint64_t get_memory_size(void);
static void init_memmap(struct Page *base, size_t n);
static inline struct Page *pa2page(uintptr_t pa);
void panic(const char *fmt, ...);
void cprintf(const char *fmt, ...);
extern char end[];
```

[GUARANTEE]

必须实现或修改的接口：

```c
static void page_init(void);
```

你可以根据需要添加 `static` 辅助函数或内部静态变量，但不要改变现有公开接口。

[SPECIFICATION]

## page_init

**Pre-Condition**:
- `pmm_manager` 已由 `init_pmm_manager()` 初始化；
- `dtb_init()` 已把设备树中的内存基址和大小保存下来，可通过 `get_memory_base()`、`get_memory_size()` 获取；
- 内核符号 `end` 是虚拟地址，涉及物理占用计算时必须先用 `PADDR()` 转换。

**Post-Condition**:
- `va_pa_offset` 等于 `PHYSICAL_MEMORY_OFFSET`，保证后续虚拟地址与物理地址可以正确互转；
- `npage` 表示可管理物理内存上界对应的页号，`Page` 描述符数组覆盖 `[nbase, npage)` 中的全部物理页，数组长度为 `npage - nbase`；
- `pages` 指向 `end` 之后按页对齐处的描述符数组，数组中的描述符初始都处于保留状态；
- 当前 `pmm_manager` 只接管描述符数组之后、内存末端之前的完整空闲页；
- 输出探测到的物理内存范围。

**Case 1（正常情况）**：设备树内存范围有效时，先设置 `va_pa_offset` 并确定可管理上界，再在 `end` 之后按页对齐放置描述符数组；将每个描述符的 `ref`、`property` 清零、`flags` 只置保留位，随后计算描述符数组的物理占用，把其后的地址向上按页对齐作为空闲区起点，把内存末端向下按页对齐作为空闲区终点；二者之间非空时，通过 `pa2page()` 找到起始描述符并用 `init_memmap()` 注册这段连续空闲页。最后输出：

```
physical memory map:
  memory: 0x%016lx, [0x%016lx, 0x%016lx].
```

三个值依次为内存大小、内存起始物理地址、内存结束物理地址（末字节地址）。

**Case 2（范围超过可管理上界）**：设备树报告的内存超过了框架能够管理的上界（`PHYSICAL_MEMORY_END`）时，只管理上界以内的部分，超出部分不计入 `npage`，也不加入空闲区。

**Case 3（设备树信息无效）**：内存基址或大小为 0 时，说明探测失败，应通过 `panic()` 终止初始化，不能带着无效范围继续建立描述符。

**Case 4（没有完整空闲页）**：描述符数组之后到内存末端不足一个完整页面时，不得调用 `init_memmap()`，但仍应完成全局变量的设置和内存范围输出。

**Requirements**:
- 全程区分虚拟地址、物理地址、物理页号和 `Page` 描述符地址：`end` 与 `pages` 是虚拟地址，计算描述符数组占用大小时必须转换为物理地址；`PADDR()` 依赖 `va_pa_offset`，必须先设置 `va_pa_offset` 再使用它；
- 描述符数组起点和空闲区起点都向上按页对齐，空闲区终点向下按页对齐，末尾不足一页的部分不参与管理；
- 必须先初始化所有描述符并标记为保留，再交给 `init_memmap()`，确保 OpenSBI 占用区、内核镜像和描述符数组所在的页面不会被后续分配出去；
- 不修改现有测试函数和分配器实现。
## module2_task2

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

### best_fit_init

**Pre-Condition：** 尚未登记本轮可用页面。

**Post-Condition：** 空闲链表为空，空闲页数为 0。

### best_fit_init_memmap

**Pre-Condition：** 管理器已初始化；`n > 0`，区间合法、连续、已保留且未登记。

**Post-Condition：** 归入区间解除保留，引用计数清零，正确设置空闲块首页及页数，空闲页总数增加 n。

### best_fit_alloc_pages

**Pre-Condition：** `n > 0`，管理状态有效。

**Post-Condition：** 成功时交付连续 n 页，失败时不改变空闲状态。

**Case 1：** 存在合适块时，选择所有足够大的块中最小者，同大小选地址最低者；交付低地址端 n 页，剩余部分保持可用，空闲页数减少 n，清除已分配首页的空闲块标记，返回首页描述符。

**Case 2：** 空闲页总数不足，或不存在足够大的连续块时，返回 `NULL`。

### best_fit_free_pages

**Pre-Condition：** `n > 0`，区间合法、连续、非保留且未释放，不要求与单次申请边界相同。

**Post-Condition：** 重置归还页的状态和引用计数，空闲页数增加 n，归还区间重新可分配。

**Case 1：** 与两侧均不物理相邻时，成为独立空闲块。

**Case 2：** 与前驱、后继的一侧或两侧物理相邻时，合并为一个块，仅保留最终首页结点和标记；合并不重复增加页数。

### best_fit_nr_free_pages

**Pre-Condition：** 管理器已初始化。

**Post-Condition：** 返回真实空闲页总数，不修改状态。

### init_pmm_manager

**Pre-Condition：** Best-Fit 管理器已完整定义。

**Post-Condition：** 当前管理器为 `best_fit_pmm_manager`，保留原有输出并调用其初始化接口。

### 模块约束与验收

**Requirements：** 空闲链表按地址有序，块间不重叠，每块只有首页入链并标记，首页页数正确。算法复杂度不限。在具备工具链的环境中执行 `make clean`、`make qemu`，确认输出使用 Best-Fit 且原有自检通过，不得修改测试。

## module2_task3_realise

[PROMPT]

**任务：** 在 `code/lab2/lab2_new` 中从零实现并接入 Buddy System 物理页分配器。

**操作要求：** 新建 `kern/mm/buddy_pmm.c`、`buddy_pmm.h`，在 `pmm.c` 中引入头文件并切换管理器；仅在必要时调整构建规则。保留其他分配器、已有测试、`page_init()` 和公共数据结构。

**输出要求：** 写入代码，简述实现与验证结果；无法运行时如实说明，不得伪造通过结果。

[RELY]

阅读 `default_pmm.c`、`pmm.c`、`pmm.h`、`memlayout.h`、`libs/list.h` 和构建规则，以工程实际定义为准：

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

### buddy_init

**Pre-Condition：** 尚未登记本轮可用页面。

**Post-Condition：** 各阶空闲链表与辅助状态初始化，空闲页数为 0。

### buddy_init_memmap

**Pre-Condition：** 管理器已初始化；`n > 0`，区间合法、连续、已保留且未登记。

**Post-Condition：** 解除保留、清零引用计数，按物理对齐拆成整幂块，恰好登记 n 页。支持非整幂长度、未对齐起点和多段登记，不遗漏页面、不跨空洞。

### buddy_alloc_pages

**Pre-Condition：** `n > 0`，管理状态有效。

**Post-Condition：** 成功返回 s 页连续且按 s 页对齐的块，空闲页数减少 s，已分配页不再属于空闲块；失败不改变状态。

**Case 1：** 对应阶有块则取出，否则逐级拆分更高阶块，剩余伙伴归入对应链表。

**Case 2：** 无合适块、请求超出支持范围或取整会溢出，返回 `NULL`。

### buddy_free_pages

**Pre-Condition：** base 为成功分配的首页，n 为原请求页数，该块尚未释放且可归还。

**Post-Condition：** 重置归还页状态与引用计数，空闲页数增加 s，合并不重复计数。

**Case 1：** 伙伴页号为 `page2ppn(base) ^ (1UL << k)`；先检查有效管理范围，再访问描述符。

**Case 2：** 仅与同阶空闲伙伴递归合并，直到无法合并或达到最大阶；不得与非伙伴、已分配块或保留页合并。

### buddy_nr_free_pages

**Pre-Condition：** 管理器已初始化。

**Post-Condition：** 返回真实空闲页总数，不修改状态。

### init_pmm_manager

**Pre-Condition：** Buddy 管理器已完整定义。

**Post-Condition：** 选择 `buddy_pmm_manager`，保留原有输出并调用初始化接口。

### 模块约束与验收

**Requirements：** 空闲块大小为 2 的幂、正确对齐且互不重叠；仅首页入链并标记，元数据与页数统计一致。时空复杂度不限。具备环境时执行 `make clean`、`make`、`make qemu`，确认编译及启动正常；占位自检不算测试通过。

## module2_task3_test

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

### 测试环境

**Pre-Condition：** Buddy 管理器已初始化并登记可用页面。

**Post-Condition：** 测试使用合法隔离区域，完整保存、恢复管理状态及必要元数据；所有临时页面归还，原空闲页数恢复，公共接口仍可正常使用。

### 基本分配与取整

**Pre-Condition：** 测试区容量足够，初始页数已记录。

**Post-Condition：** 分别申请并释放 1、2、4、3、5 页，检查连续性、物理对齐、互不重叠及计数；3、5 页分别实际占用 4、8 页，释放后恢复。

### 拆分与合并

**Pre-Condition：** 受控池仅含一个物理对齐的 8 页空闲块。

**Post-Condition：** 拆成 8 个单页后耗尽，按不同顺序释放后可重新申请完整 8 页块，计数正确。

**Case 1：** 分别先释放低地址和高地址伙伴，均能递归合并。

**Case 2：** 仅释放相邻非伙伴时不能合并；伙伴仍被占用时不能合并，释放后才能合并。

### 登记与失败边界

**Pre-Condition：** 受控池及登记区间满足接口前置条件。

**Post-Condition：** 验证登记无遗漏、无越界，失败请求不改变空闲块集合与计数。

**Case 1：** 覆盖单页、非整幂长度、未对齐起点和含保留空洞的多段登记，分配结果不得包含区间外页面。

**Case 2：** 覆盖空池、请求过大、总量足够但无合适阶块、取整溢出及边界伙伴越界情况；非法输入不混入正常启动测试。

### 状态一致性与验收

**Pre-Condition：** 各用例使用满足契约的分配、释放序列。

**Post-Condition：** 链表、首页标记和阶数一致，空闲块对齐且不重叠，空闲页数等于块大小之和，不遗留可合并伙伴。

**Requirements：** 增加有界且混合分配与释放两种操作的序列，用独立占用记录检查重叠和计数，最终全部归还。具备环境时执行 `make clean`、`make`、`make qemu`，确认测试入口执行、断言通过且内核继续启动。简述各用例如何发现拆分、合并、越界、计数和状态恢复错误。
## Challenge：SLUB

以下两份提示词分别用于生成 SLUB 模块和生成对应测试。
*实现 SLUB 的提示词：*

````markdown
[PROMPT]
**任务：** 在 `code/lab2/lab2_new` 中从零实现简化的 SLUB 内存对象分配模块，在现有物理页分配器之上支持任意正整数大小的内核对象申请和释放，并接入内核初始化流程。
**操作要求：** 新建 `kern/mm/slub.c`、`kern/mm/slub.h`，在 `kern/mm/pmm.c` 的 `pmm_init()` 中于物理页管理器初始化和空闲页登记完成后调用 `slub_init()`；只在构建规则确实未收录新文件时调整构建规则。保留 Buddy、Best-Fit、First-Fit 及其测试，不修改 `struct Page`、`struct pmm_manager`、`page_init()` 和页分配公共接口。必须修改项目中的实际文件。
**输出要求：** 直接写入代码，说明最终接口、大小类别和页回收策略；在具备工具链的环境中报告实际编译与启动结果，无法运行时如实说明。
[RELY]
阅读 `pmm.h`、`pmm.c`、`memlayout.h`、`mmu.h`、`buddy_pmm.c`、`kern/init/init.c` 和 `Makefile`，以工程真实定义为准：
- 页级接口是 `struct Page *alloc_pages(size_t n)`、`void free_pages(struct Page *base, size_t n)` 和 `size_t nr_free_pages(void)`；`PGSIZE` 为一页字节数，`page2pa()` 可得到物理地址，`va_pa_offset` 是现有内核映射的虚实地址偏移。
- 当前 `pmm_manager` 为 Buddy；其非整幂页请求会向上取整，释放时仍传原请求页数。SLUB 不得自行修改页分配器的空闲块或页数统计。
- 工程没有可依赖的堆分配器；`kern/mm/*.c` 由现有构建规则收录。使用已有断言、输出和内存操作接口前先核对其声明，不引入标准 C 库或 Linux 内核专有设施。
[GUARANTEE]
新增并在 `slub.h` 声明以下公开接口：
```c
void slub_init(void);
void *slub_alloc(size_t size);
void slub_free(void *ptr);
```
允许在 `slub.c` 内定义静态缓存状态、页头/对象元数据和辅助函数；修改现有 `void pmm_init(void)` 以完成初始化接入。所有公开签名与头文件一致，不将对象指针误作 `struct Page *` 交给 `free_pages()`。
[SPECIFICATION]
## slub_init
**Pre-Condition：** 物理页管理器已初始化，`page_init()` 已登记可用页；本模块尚未使用。
**Post-Condition：** 各大小类别和内部状态可用；不预占无用物理页，原有页分配器状态保持有效。重复初始化若不支持，应显式拒绝而非丢失已分配对象。
## slub_alloc
**Pre-Condition：** 模块已初始化；`size` 是调用者所需的有效载荷字节数。
**Post-Condition：** 成功时返回满足 `sizeof(uintptr_t)` 对齐、可访问至少 `size` 字节且由本模块独占管理的内核虚拟地址；同时存在多个未释放对象时，其有效载荷互不重叠。失败返回 `NULL`，不泄漏页或破坏已有对象及缓存状态。
**Case 1：** `size == 0` 时返回 `NULL`，状态不变。
**Case 2：** 小对象由页分配器提供的页面承载，按固定大小类别复用对象槽；同一页面中的对象可独立释放和再次分配，不因某个槽释放而影响其他在用对象。
**Case 3：** 大于单页可容纳对象上限的申请仍须被支持，可直接向页分配器申请足够的连续页；保存释放时所需的页首页和原请求页数，使任意正整数大小（包括跨页大小）都有明确的归还路径。
**Case 4：** 大小计算溢出、页分配器无法供页或其他资源不足时返回 `NULL`，已取得但尚未交付的资源必须归还。
## slub_free
**Pre-Condition：** `ptr == NULL`，或 `ptr` 是尚未释放且由 `slub_alloc()` 返回的原始对象指针；重复释放和非法指针不属于公开接口的正常调用。
**Post-Condition：** 对象不再占用，其他在用对象的数据不变；相应槽可复用。当一页中所有小对象均已释放时，该页归还给页分配器；大对象释放时归还其整段页，页数参数与申请时一致。`NULL` 不产生任何操作。
## pmm_init 与模块约束
**Pre-Condition：** 原有 `pmm_init()` 负责选择页管理器、登记物理内存并运行页级自检。
**Post-Condition：** 原有页级行为和启动输出仍正常，SLUB 仅在底层页分配器就绪后初始化，可供后续内核代码调用。
**Requirements：** 元数据不得覆盖交付给调用者的有效载荷；空闲槽、在用槽和页归属关系始终一致。实现可简化缓存管理，但必须体现“页级分配 + 对象分配”两层结构。算法复杂度不限。执行 `make` 和 `make qemu` 检查编译与启动。
````

*测试 SLUB 的提示词：*

````markdown
[PROMPT]
**任务：** 针对上一份提示词生成的实际 SLUB 模块，在内核中实现可运行的自检，验证不同大小对象的分配、数据隔离、复用和页回收，并给出测试覆盖说明。
**操作要求：** 阅读生成的 `slub.c/.h`，在 `kern/mm/slub.c` 中实现 `slub_check()`，按需要添加静态测试辅助函数；在 `pmm_init()` 中于 `slub_init()` 之后调用它。保留原有页分配器测试。若发现实现缺陷，只做满足既定接口契约所需的修复，并说明修复原因。必须修改项目中的实际文件。
**输出要求：** 写入测试代码，报告每组断言检验的性质和真实的编译、QEMU 运行结果；未运行或失败时如实说明，不得仅凭打印成功字样声称通过。
[RELY]
以第一份提示词的规格、已生成的 `slub.c/.h` 以及工程中的 `pmm.h`、`memlayout.h`、`pmm.c` 为依据：
- `slub_alloc(size)` 返回的对象至少可写 `size` 字节，按 `sizeof(uintptr_t)` 对齐；`slub_free(NULL)` 无操作，零大小及大小溢出申请返回 `NULL`。
- 小对象共享底层页面且逐对象释放，页面完全空闲后归还；大对象可跨页，释放后归还全部占用页。Buddy 对非整幂页请求的真实消耗可能大于请求页数，测试不得假定两者相等。
- `nr_free_pages()` 可观察底层可用页数；测试必须用真实 SLUB 与页分配接口，不用假实现替代。测试期间分配的对象须全部释放，最终页数恢复到测试前基线。
[GUARANTEE]
在 `slub.h` 声明并实现：
```c
void slub_check(void);
```
由 `pmm_init()` 在 `slub_init()` 后调用。使用工程现有断言检查结果，仅所有断言通过后输出 `slub_check() succeeded!`。测试辅助函数应限制在模块内。
[SPECIFICATION]
## 测试入口与状态恢复
**Pre-Condition：** 页管理器和 SLUB 均已初始化，记录 `nr_free_pages()` 基线。
**Post-Condition：** 所有测试对象均释放，底层空闲页数恢复基线，原页级自检与内核后续启动不受影响。失败断言必须使测试停止，不得打印成功消息。
## 不同大小与数据隔离
**Pre-Condition：** 测试使用有限数量的合法申请，内存足够时继续后续检查。
**Post-Condition：** 覆盖 1 字节、对齐边界两侧、多个大小类别、单页对象上限两侧、`PGSIZE` 附近和跨页对象；每个成功返回值满足对齐和可写范围，填入不同标记后交错检查，任意两段有效载荷不得重叠。
## 共享页面、复用与归还
**Pre-Condition：** 记录页数变化和各对象指针，确保所有对象都有明确归属。
**Post-Condition：** 多个同类小对象可并存；释放其中一个后，其余对象内容保持不变，再次申请可以正常使用空闲容量；释放该页所有对象后底层页数恢复。跨页大对象释放后对应页数恢复，反复申请与释放不累积泄漏。
## 边界与失败路径
**Pre-Condition：** 保留已有对象并记录其内容与可用页数。
**Post-Condition：** `slub_alloc(0)` 与会造成大小计算溢出的请求返回 `NULL`；`slub_free(NULL)` 不改变状态，已有对象内容仍正确。资源不足测试若需执行，应使用有界、可恢复的分配过程，失败后检查已分配对象仍可释放且页数恢复，不得无上限耗尽内核内存。
## 混合序列与验收
**Pre-Condition：** 采用固定且有界的不同大小对象序列。
**Post-Condition：** 交错申请、写入、部分释放、重新申请和逆序释放后，存活对象内容始终正确，最终空闲页数等于基线。
**Requirements：** 测试必须由断言验证结果，不能仅打印地址或成功语句。结合实际缓存类别边界选取大小；若实现使用了不同内部类别，按真实边界调整数值但保留上述行为覆盖。执行 `make`、`make qemu`，确认自检实际运行且内核继续启动；简述每组用例如何发现对象重叠、错误复用、跨页归还、计数或泄漏问题。
````
