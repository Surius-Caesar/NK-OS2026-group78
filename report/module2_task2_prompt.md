# 任务二提示词（第一版）

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
