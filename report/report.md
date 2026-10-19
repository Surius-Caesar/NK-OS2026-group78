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
**负责人：** 2413410-[韩芳逸]

#### 模块功能描述

**需要实现/修改的函数：**

```c
static void page_init(void);
```

**本模块依赖的框架函数与符号（已提供，无需实现）：**

```c
uint64_t get_memory_base(void);
uint64_t get_memory_size(void);
static void init_memmap(struct Page *base, size_t n);
static inline struct Page *pa2page(uintptr_t pa);
```

此外还使用 `PADDR()`、`ROUNDUP()`、`ROUNDDOWN()`、`panic()`、`cprintf()` 等框架提供的宏和函数。

**功能说明：**

`page_init()` 位于物理内存初始化的调用链 `pmm_init() -> init_pmm_manager() -> page_init() -> init_memmap()` 中间，负责把设备树探测到的物理内存信息转换成内核可以管理的页描述符布局。它不接收参数、不返回结果，由 `pmm_init()` 在物理内存管理器初始化完成后调用。

本模块主要完成以下工作：

1. **物理内存探测**：通过 `get_memory_base()` 和 `get_memory_size()` 取得设备树报告的内存基址和大小；基址或大小为 0 时说明探测失败，用 `panic()` 终止初始化。
2. **全局状态建立**：设置 `va_pa_offset = PHYSICAL_MEMORY_OFFSET`，使虚拟地址和物理地址可以正确互转；根据内存末端确定 `npage`，并让 `pages` 指向 `end` 之后按页对齐处的 `Page` 描述符数组。
3. **描述符布局**：描述符数组覆盖物理页号区间 `[nbase, npage)`，数组长度为 `npage - nbase`；每个描述符的 `ref`、`property` 清零，`flags` 只置保留位，防止尚未完成布局的页面被提前分配。
4. **已用空间排除**：OpenSBI 占用区 `[0x80000000, 0x80200000)`、内核镜像 `[0x80200000, KernelEnd)` 以及描述符数组本身所在的页面都保持保留状态，不进入空闲区。
5. **空闲区注册**：把描述符数组末尾的物理地址向上按页对齐作为空闲区起点，把内存末端向下按页对齐作为空闲区终点；两者之间非空时，通过 `pa2page()` 找到起始描述符，再用 `init_memmap()` 把这段连续完整页面交给当前 `pmm_manager`。
6. **边界处理**：设备树范围超过 `PHYSICAL_MEMORY_END` 时只管理上界以内的部分；描述符数组之后不足一个完整页面时不调用 `init_memmap()`；最后输出探测到的物理内存范围。

初始化完成后，`page2pa()`、`pa2page()` 依赖的 `pages`、`npage`、`nbase` 均已就绪，后续 `alloc_pages()`、`free_pages()` 可以通过 `pmm_manager` 的空闲页链表完成页面分配与回收。

关键地址关系如下：

| 项目 | 含义 |
| --- | --- |
| `PHYSICAL_MEMORY_OFFSET` | 虚拟地址与物理地址之间的固定偏移 |
| `nbase = DRAM_BASE / PGSIZE` | DRAM 起始物理地址对应的页号 |
| `npage` | 可管理物理内存上界对应的页号 |
| `end` | 内核镜像结束的虚拟地址 |
| `pages` | 描述符数组起始的虚拟地址，位于 `end` 之后并按页对齐 |
| `pages + (npage - nbase)` | 描述符数组末尾，需经 `PADDR()` 转成物理地址 |

#### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

````markdown
# 功能模块一 任务一：物理内存探测与页描述符初始化

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
````

#### 实现迭代过程

本模块直接使用上述最终版提示词完成实现，没有进行第二次及后续迭代。生成代码后重点检查了以下几点：

- `va_pa_offset` 在第一次使用 `PADDR()` 之前完成设置；
- `pages` 位于 `end` 之后并按页对齐，描述符数组长度为 `npage - nbase`；
- 所有描述符先初始化并置保留位，之后才把空闲区交给 `init_memmap()`；
- 空闲区起点取描述符数组物理末尾向上对齐处，终点取内存末端向下对齐处；
- 设备树信息无效、没有完整空闲页等分支均按要求处理。

**最终结果：**

- ✅ 编译通过
- ✅ 所有相关测试通过
- ✅ 功能符合预期


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
