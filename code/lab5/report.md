# 操作系统实验报告

## 实验基本信息

| 项目 | 内容 |
|------|------|
| **实验名称** | Lab 5: 用户进程与系统调用 |
| **小组成员** | 2413993-徐锐、2413340-戴璐、2413410-韩芳逸 |
| **完成日期** | 2026-11-23 |

### 小组分工

练习如何分工？

| 成员 | 负责的练习/模块 |
|------|----------------|
| 2413410-韩芳逸 | 功能模块一：用户态系统调用功能 |
| 2413993-徐锐 |  |
| 2413340-戴璐 |  |

实验报告如何分工？

本报告由负责功能模块一的同学完成“实验目的、整体逻辑分析、功能模块一、测试与验证、总结”部分；功能模块二至四的详细内容由对应负责人补充。

---

## 一、实验目的

<!-- 说明本次实验的主要目标和预期成果 -->

本实验的主要目的是：

1. 理解用户程序如何通过 `ecall` 从用户态陷入内核态，并由系统调用分发层获得内核服务。
2. 掌握系统调用号、寄存器传参、返回值写回以及 `sepc` 前移这一条完整链路。
3. 理解第一个用户进程如何由内核线程经 `kernel_execve` 构造 `trapframe` 并借助 `sret` 进入用户态。
4. 了解 `fork`、`exec`、`wait`、`exit` 等进程生命周期操作在内核中的协作关系。
5. 学习使用 AI 辅助开发操作系统核心功能，并通过编译、运行和 `make grade` 验证生成代码。

---

## 二、实验环境

你们使用的 AI 工具

| 成员 | AI 编程工具 | 底层模型 | 备注 |
|------|------------|---------|------|
| 2413410-韩芳逸 | Claude Code（VS Code 扩展） | DeepSeek-V4-Flash | 负责功能模块一 |
| 2413993-徐锐 | [待补充] | [待补充] | |
| 2413340-戴璐 | [待补充] | [待补充] | |

**说明：**
- **AI 编程工具**：指具体使用的终端工具、编辑器插件、桌面应用或浏览器界面
- **底层模型**：指该工具使用的大语言模型及版本

---

## 三、实验整体逻辑分析

### 3.1 本章节的逻辑主线

本章围绕“用户态如何获得内核服务”“第一个用户进程如何被启动”“用户进程如何被复制”“进程如何退出”四条主线展开，解决的是“内核已经能管理内存、创建和调度内核线程，但还没有真正的用户程序在运行”这一问题。

整条链路可以概括为：

```text
用户程序 → 用户库封装 → ecall（U→S）→ __alltraps → trap → exception_handler
        → syscall → sys_* → do_* → 返回值写回 trapframe → __trapret → sret（S→U）
```

其中，用户库只负责把系统调用号和参数放进约定寄存器并执行 `ecall`；真正的语义判断、权限检查和资源更新全部在内核态完成；异常返回路径负责把结果带回用户程序。另一条支线是启动链：`proc_init → kernel_thread(init_main) → init_main → kernel_thread(user_main) → kernel_execve → do_execve → load_icode → __trapret → sret`，第一次把执行流从内核态送入用户态。

### 3.2 功能的逐步实现

1. **首先补齐实验 2/3/4 的依赖代码**：物理内存管理器、`page_init()`、页表操作、`RESTORE_ALL` 上下文恢复、调度与 `switch_to`。这些是用户进程能够被创建、映射和调度的基础；没有它们，lab5 的进程管理代码无法编译，也无法运行。
2. **接着实现用户态系统调用入口**（功能模块一）：`exception_handler` 识别 `CAUSE_USER_ECALL` 并前移 `epc`，`syscall` 完成分发表调用，各 `sys_*` 把请求翻译为内核语义。系统调用是所有后续用户态行为的统一入口，因此先实现它。
3. **然后创建并启动第一个用户进程**（功能模块二）：`alloc_proc`、`kernel_thread`、`proc_init`、`init_main`、`user_main`、`kernel_execve`、`do_execve`、`load_icode` 负责把内核线程转换为 ELF 用户程序，并通过 `trapframe + __trapret` 首次进入用户态。
4. **再实现用户进程复制**（功能模块三）：`do_fork`、`copy_mm`、`dup_mmap`、`copy_range` 复制 PCB、内核栈、`trapframe` 和用户地址空间，使 `fork` 能够产生可独立运行的子进程。
5. **最后补充其余进程控制**（功能模块四）：`do_exit`、`do_yield`、`do_kill` 与 `do_wait` 共同构成进程生命周期的收尾闭环，使 `exit`、`yield`、`kill`、`wait` 测试能够完成。

---

## 四、实验内容与实现

<!-- 
说明：本部分按照 exercises 文档中的练习顺序组织
每个功能模块或者练习中可能包含多项任务，请根据实际情况调整
-->


---

### 功能模块：用户态系统调用功能

**负责人：** 2413410-韩芳逸

#### 模块功能描述

**需要实现/修改的函数：**

```c
void exception_handler(struct trapframe *tf);   // kern/trap/trap.c
void syscall(void);                             // kern/syscall/syscall.c
static int sys_exit(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_fork(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_wait(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_exec(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_yield(uint64_t arg[]);           // kern/syscall/syscall.c
static int sys_kill(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_getpid(uint64_t arg[]);          // kern/syscall/syscall.c
static int sys_putc(uint64_t arg[]);            // kern/syscall/syscall.c
static int sys_pgdir(uint64_t arg[]);           // kern/syscall/syscall.c
```

**功能说明：**

这一模块负责把用户态通过 `ecall` 发起的请求接入内核，再把内核的处理结果写回用户寄存器。它处在整条调用链的“控制流转接”位置：

- 向下，它依赖 `do_exit`、`do_fork`、`do_wait`、`do_execve`、`do_yield`、`do_kill` 等进程管理入口，以及 `user_mem_check`、`cputchar`、`print_pgdir` 等基础能力；
- 向上，它为用户库提供 `exit`、`fork`、`wait`、`exec`、`yield`、`kill`、`getpid` 以及 `cprintf` 等接口所需的系统调用语义；
- 与异常返回路径配合，`exception_handler` 在分发完成后把结果留在 `trapframe` 中，`__trapret` 恢复寄存器并 `sret` 回到用户态。

需要处理的主要场景包括：合法系统调用、非法/未实现系统调用号、用户态缺页、非法指令和断点异常。所有涉及用户指针的参数都不能直接信任，必须结合 `user_mem_check` 和当前进程的地址空间做合法性判断。

#### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

````markdown
### [PROMPT]

**任务**：修改 Lab5 工程 `lab5_new` 中的 `kern/trap/trap.c` 与 `kern/syscall/syscall.c`，实现“用户态系统调用”功能模块。该模块负责把用户程序通过 `ecall` 发起的请求接入内核并返回结果：`exception_handler()` 需要识别 `CAUSE_USER_ECALL`，先把 `epc` 前移以避免重复执行同一条 `ecall`，再把控制权交给 `syscall()`；`syscall()` 从当前进程的 `trapframe` 中取出系统调用号和参数，按分发表调用对应的 `sys_*` 处理函数，并把返回值写回 `a0`；`sys_exit()`、`sys_fork()`、`sys_wait()`、`sys_exec()`、`sys_yield()`、`sys_kill()`、`sys_getpid()`、`sys_putc()`、`sys_pgdir()` 则把统一编号的系统调用翻译成具体内核语义。

**操作要求**：你必须在项目中修改实际文件，而不是仅展示代码。只在 `kern/trap/trap.c` 的 `//lab3 请补充你在lab3中的代码`、`//lab5 function1 YOUR CODE update exception_handler` 和 `kern/syscall/syscall.c` 的 `//lab5 function1 YOUR CODE` 标记处补全本模块，保留已有的 `idt_init()`、`trap_in_kernel()`、`print_trapframe()`、`trap_dispatch()`、`trap()`、`syscalls[]` 分发表和 `NUM_SYSCALLS`。不要实现功能模块二/三/四中的进程创建、复制、退出细节，也不要在本模块里重写 `do_*` 函数。不得删除现有注释与 `YOUR CODE` 标记。

**输出要求**：直接进行文件操作，使用下面 `[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 部分的信息；以工程中的真实定义为准，不要引入文件系统、设备管理等本实验范围之外的功能。实现完成后报告实际编译与运行结果，未执行的验证不要写成通过。

### [RELY]

```c
struct pushregs {
    uintptr_t zero, ra, sp, gp, tp, t0, t1, t2, s0, s1,
              a0, a1, a2, a3, a4, a5, a6, a7,
              s2, s3, s4, s5, s6, s7, s8, s9, s10, s11,
              t3, t4, t5, t6;
};
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;   // sstatus
    uintptr_t epc;      // sepc
    uintptr_t tval;     // stval
    uintptr_t cause;    // scause
};

#define SYS_exit 1
#define SYS_fork 2
#define SYS_wait 3
#define SYS_exec 4
#define SYS_yield 10
#define SYS_kill 12
#define SYS_getpid 18
#define SYS_putc 30
#define SYS_pgdir 31

#define CAUSE_USER_ECALL          0x8
#define CAUSE_ILLEGAL_INSTRUCTION 0x2
#define CAUSE_BREAKPOINT          0x3
#define CAUSE_LOAD_PAGE_FAULT     0xd
#define CAUSE_STORE_PAGE_FAULT    0xf
```

- 全局状态：`current` 指向当前进程，`current->tf` 指向本次陷入保存的 `trapframe`。
- 用户态约定：`a0` 保存系统调用号，`a1`~`a5` 依次保存最多 5 个参数；`ecall` 固定 4 字节。
- 可调用接口：`do_exit`、`do_fork`、`do_wait`、`do_execve`、`do_yield`、`do_kill`、`find_proc`、`user_mem_check`、`cputchar`、`print_pgdir`、`trap_in_kernel`、`print_trapframe`。
- 错误码：非法/未实现的系统调用返回 `-E_INVAL`。

### [GUARANTEE]

必须实现或修改以下接口，签名和返回类型保持不变：

```c
void exception_handler(struct trapframe *tf);
void syscall(void);
static int sys_exit(uint64_t arg[]);
static int sys_fork(uint64_t arg[]);
static int sys_wait(uint64_t arg[]);
static int sys_exec(uint64_t arg[]);
static int sys_yield(uint64_t arg[]);
static int sys_kill(uint64_t arg[]);
static int sys_getpid(uint64_t arg[]);
static int sys_putc(uint64_t arg[]);
static int sys_pgdir(uint64_t arg[]);
```

不要新增对外接口，也不要修改 `kern/syscall/syscall.h` 中已有的函数声明。

### [SPECIFICATION]

#### exception_handler

**Pre-Condition**：`tf` 指向本次异常保存的中断帧；`current` 在用户进程运行阶段有效。

**Post-Condition**：用户态 `ecall` 已被分发到 `syscall()`，并且 `tf->epc` 已指向 `ecall` 的下一条指令；其他异常被识别、打印或按既定策略处理。

**Case 1（`CAUSE_USER_ECALL`）**：先把 `tf->epc` 增加 4，再调用 `syscall()`；不能把 `epc` 前移放在分发之后。

**Case 2（非法指令 / 断点）**：打印异常地址，并按指令低两位判断指令长度，把 `epc` 前移相应长度。

**Case 3（用户态缺页）**：本实验没有实现按需分页，将当前进程标记为 `PF_EXITING`，由 `trap()` 在返回用户态前调用 `do_exit(-E_KILLED)` 结束该进程，避免原地反复触发异常。

**Case 4（其他异常）**：调用 `print_trapframe(tf)` 输出现场。

#### syscall

**Pre-Condition**：`current != NULL` 且 `current->tf` 指向本次系统调用的中断帧；分发表 `syscalls[]` 已初始化。

**Post-Condition**：合法且已实现的系统调用执行完成，返回值写入 `tf->gpr.a0`；非法编号或空项返回 `-E_INVAL`。

**Case 1（合法编号且已实现）**：从 `gpr.a1`~`gpr.a5` 取出 5 个参数，调用 `syscalls[num](arg)`，把返回值写回 `gpr.a0`。

**Case 2（编号越界或未实现）**：不访问分发表越界项，直接把 `gpr.a0` 置为 `-E_INVAL`。

#### sys_exit / sys_fork / sys_wait / sys_exec / sys_yield / sys_kill / sys_getpid / sys_putc / sys_pgdir

- `sys_exit`：调用 `do_exit((int)arg[0])`。
- `sys_fork`：以 `current->tf` 和 `current->tf->gpr.sp` 为模板调用 `do_fork(0, stack, tf)`，不设置 `CLONE_VM`。
- `sys_wait`：把 `arg[0]`、`arg[1]` 转为 `pid` 和用户指针后调用 `do_wait`；用户指针合法性由 `do_wait` 内部检查。
- `sys_exec`：把四个参数转换为名字指针、长度、二进制指针和大小后调用 `do_execve`。
- `sys_yield`：返回 `do_yield()`。
- `sys_kill`：调用 `do_kill((int)arg[0])`。
- `sys_getpid`：返回 `current->pid`。
- `sys_putc`：调用 `cputchar((int)arg[0])` 后返回 0。
- `sys_pgdir`：调用 `print_pgdir()` 后返回 0。

**Requirements**：
- 参数位置必须与用户态 `user/libs/syscall.c` 的寄存器约定一致；`syscalls[]` 是稀疏数组，必须判空。
- `sys_*` 只做参数转换和调用内核语义入口，进程状态、页表、进程树的真正修改由 `do_*` 完成。
- 涉及用户指针的 `do_*` 路径必须经过 `user_mem_check()`。
````

#### 实现迭代过程

本模块的实现经历了 3 次迭代和一次完整验证，过程如下：

---

##### 第一次迭代：按规格生成核心分发逻辑

**最终结果：**

生成的 `exception_handler`、`syscall` 和九个 `sys_*` 函数基本符合规格，但 `kern/syscall/syscall.c` 直接编译失败：

```text
kern/syscall/syscall.c:12:29: error: 'sys_exit' undeclared here (not in a function)
kern/syscall/syscall.c:13:29: error: 'sys_fork' undeclared here (not in a function)
...
```

**遇到的问题：**
- 问题1：`syscalls[]` 分发表在文件顶部，而 `sys_*` 函数定义在它之后，C 语言要求先声明后使用，导致九个处理函数全部“未声明”。
- 问题2：链接阶段出现 `undefined reference to 'print_pgdir'`，`sys_pgdir()` 无法完成链接。

**问题解决策略：**
- 针对问题1：在提示词中补充“分发表位于文件顶部，必须为所有 `sys_*` 提供前置声明”，并在 `syscalls[]` 之前加入九个 `static` 原型声明。
- 针对问题2：在 `kern/mm/pmm.c` 中补上 `print_pgdir()` 的完整实现——遍历 `current->mm->pgdir`（内核阶段退回 `boot_pgdir_va`），用 `get_pgtable_items()` 和 `perm2str()` 按连续区间打印权限。

---

##### 第二次迭代：补齐用户态异常处理边界

**遇到的问题：**
- 问题3：最初只处理了 `CAUSE_USER_ECALL`，`faultread` / `faultreadkernel` / `testbss` 这类程序发生用户态缺页后会不断重试同一条指令，输出大量 trapframe，甚至拖慢整个测试。
- 问题4：`RESTORE_ALL` 若沿用 lab3 的纯内核版本，从用户态返回时会错误地改写 `sscratch`，导致下一次陷入无法找回内核栈。

**问题解决策略：**
- 针对问题3：在 `exception_handler` 中增加缺页分支——用户态缺页时置 `current->flags |= PF_EXITING`，由 `trap()` 在返回用户态前执行 `do_exit(-E_KILLED)`；内核态缺页才打印现场。
- 针对问题4：把 `[RELY]` 中的 `RESTORE_ALL` 要求写清楚——根据 `sstatus.SPP` 分流，仅在返回用户态时把内核栈顶写入 `sscratch`，返回内核态时保持 `sscratch` 为 0。

---

##### 第三次迭代：修正 `sys_pgdir` 的页表遍历

**遇到的问题：**
- 问题5：`make grade` 中 `pgdir` 用例耗时 88 秒并最终超时，缺少 `init check memory pass.`。原因是内核启动页表把整个 1GB 内核空间映射成一级大页，遍历程序却把该一级页表项当作“指向下一级页表”的指针，读取了错误的物理内存并打印出海量无效区间。
- 问题6：在打印过程中内核处于关中断状态，时钟中断无法推进，`DEBUG_GRADE` 的 EOT 终止逻辑也不会触发，因此只能等外部超时。

**问题解决策略：**
- 针对问题5：在 `print_pgdir()` 中先用 `PTE_TABLE(pgdir[i])` 判断一级页表项是否为“下一级页表”；若是 1GB 叶子大页，只打印一行 `PDE` 区间，不再解引用。二级页表项则继续用 `get_pgtable_items()` 合并连续区间。
- 针对问题6：修正后输出量从数万行降到十余行，`pgdir` 用例恢复到 1.1 秒，`make grade` 全部通过。

---

##### 最终结果

经过 3 次迭代，该模块最终：

- ✅ 编译通过（`make` 成功生成 `bin/ucore.img`）
- ✅ `make qemu` 能够启动第一个用户程序并完成 `exit` 测试
- ✅ `make grade` 全部 13 个用户程序测试通过，总分 **130/130**

**关键改进点总结：**

1. 在 `[RELY]` 中明确 `syscalls[]` 位于文件顶部，要求为所有 `sys_*` 提供前置声明，避免“先使用后定义”。
2. 在 `[SPECIFICATION]` 中补充用户态缺页的处理策略，避免没有按需分页时陷入死循环。
3. 在 `[GUARANTEE]` 之外补充 `print_pgdir()` 的依赖说明，避免链接失败。
4. 明确 `RESTORE_ALL` 必须根据 `SPP` 区分用户态/内核态返回，保证 `sscratch` 语义正确。
5. 在 `sys_pgdir` 的规格中加入“一级页表项可能是大页叶子”的边界条件，修正页表遍历逻辑。

---

### 功能模块：创建加载第一个用户进程功能

**负责人：** [待补充]

[由负责功能模块二的同学补充]

---

### 功能模块：复制用户进程功能

**负责人：** [待补充]

[由负责功能模块三的同学补充]

---

### 功能模块：其余系统调用功能

**负责人：** [待补充]

[由负责功能模块四的同学补充]

---

## 五、测试与验证

<!-- 根据该实验的具体情况，提供完整的测试运行截图，应包含：
- 编译及运行成功的输出（make qemu），可能有多个
- 测试通过的结果（make grade），只有一个
-->

> 本节内容暂缓填写：待其余功能模块合并完成后，再补充 `make qemu` 与 `make grade` 的完整运行结果和测试截图。

---

## 六、实验总结与收获

### 对操作系统的理解

1. **本实验中重要的知识点及其对应的 OS 原理：**

   - **系统调用与特权级切换**：`ecall` 把 CPU 从 U 态提升到 S 态，`__alltraps` 保存现场，`exception_handler` 识别异常原因，`syscall` 按号分发，最后 `sret` 返回 U 态。这对应 OS 原理中“用户态通过受控入口获得内核服务”的机制。本实验的 `syscall` 是一张函数指针表，用户库和内核通过寄存器约定耦合，体现了 ABI 与内核接口分层。
   - **进程控制块与内核栈**：`proc_struct` 保存状态、PID、内核栈、`trapframe`、`context` 和地址空间信息；每个进程有独立内核栈，`trapframe` 位于栈顶，用于在用户态/内核态之间保存和恢复现场。这对应 OS 中 PCB 与内核栈管理执行实体的原理。
   - **进程复制**：`do_fork` 复制 PCB 和内核栈，`copy_mm` 决定共享还是复制地址空间，`dup_mmap` 复制 vma，`copy_range` 逐页复制并建立新映射。这对应 OS 中 `fork` 的写时复制/地址空间复制语义；本实验采用“直接复制物理页”，尚未实现 COW。
   - **程序装载与首次进入用户态**：`load_icode` 解析 ELF、建立用户页表、映射代码/数据/栈，并改写 `trapframe` 的 `epc`、`sp`、`status`；`kernel_execve` 手动跳转到 `__trapret`，复用异常返回路径完成第一次 U 态切换。这对应 OS 中 `exec` 与进程映像替换的原理，也说明“从内核线程启动用户程序”需要一个伪造的返回现场。
   - **进程退出与等待**：`do_exit` 释放用户地址空间、转为僵尸态、唤醒父进程并把子进程过继给 `initproc`；`do_wait` 回收僵尸子进程的 PCB 和内核栈。这对应 OS 中僵尸进程、孤儿进程和父子进程回收的机制。

2. **OS 原理中重要、但本实验尚未对应实现的知识点：**

   - **按需分页与缺页异常处理**：本实验在 `load_icode` 中一次性映射全部用户栈页，缺页只做“杀死进程”处理，没有实现按需分配、页面置换和 COW。
   - **文件系统与可执行文件加载**：用户程序通过链接进内核镜像的二进制符号加载，而不是从磁盘文件系统读取，`exec` 没有真正的路径解析与文件读取。
   - **完整的信号/异常语义**：用户态缺页、非法指令目前只做简单终止或打印，没有信号传递、用户态异常处理回调等机制。
   - **多核与并发控制**：本实验使用关中断临界区保护进程管理结构，尚未涉及多核自旋锁、每 CPU 调度队列等。

### AI 协作开发的经验

这一次与 AI 协作最大的体会是：**提示词要把“项目当前状态”说清楚，尤其是哪些代码是骨架、哪些函数还没实现**。lab5 工程同时保留了 lab2、lab3、lab4 的历史标记，AI 如果不知道这些位置需要回填旧代码，就会直接报大量“未定义”错误。把“先补齐依赖代码，再实现新模块”写进提示词后，编译才顺利起来。

第二个体会是：**测试反馈比主观判断可靠**。系统调用分发、`epc` 前移这些逻辑肉眼看起来都对，但只有跑 `make grade` 才能暴露 `pgdir` 用例的 1GB 大页误判问题。AI 生成的代码在简单路径上通常没问题，真正的 bug 往往藏在“一级页表项既可能是下一级页表，也可能是大页叶子”这类边界条件里。遇到这种情况，把失败用例、耗时、缺失的输出一起交给 AI 分析，比只说“跑不过”有效得多。

第三个体会是：**环境与验证结果要如实记录**。编译警告、超时、panic 都是重要线索；不能把“应该能过”写成“已经通过”。本模块最终以 `make grade` 的 130/130 作为验收依据，并把迭代中遇到的真实错误写进报告，便于后续复盘。
