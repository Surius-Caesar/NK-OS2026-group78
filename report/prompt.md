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