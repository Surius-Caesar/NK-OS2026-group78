# 任务三提示词：实现 Buddy System

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
