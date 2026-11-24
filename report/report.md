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
| 2413993-徐锐 | |
| 2413340-戴璐 | 功能模块二、功能模块三  |

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
| 2413340-戴璐 | Codex | GPT6 | |

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

**负责人：** 2413340-戴璐

#### 模块功能描述

**需要实现/修改的函数：**

```c
static struct proc_struct *alloc_proc(void);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);
static int init_main(void *arg);
static int user_main(void *arg);
static int kernel_execve(const char *name, unsigned char *binary, size_t size);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
static int load_icode(unsigned char *binary, size_t size);
int do_wait(int pid, int *code_store);
```

**功能说明：**

- **该模块在整个系统中的作用**：这一部分负责把系统从“只有内核线程在运行”推进到“第一个用户程序真正开始执行”。proc_init 先建立 idleproc，再由它创建 init_main 所在的内核线程；init_main 继续创建 user_main，并通过 do_wait 等待后续用户进程退出，保证第一个用户进程建立后，内核仍然能够收束整个启动流程。user_main 的职责不是长期执行业务逻辑，而是充当一个过渡内核线程，它通过嵌入到镜像中的用户程序二进制符号，调用 kernel_execve 把自己从内核线程转换成用户进程。kernel_execve 负责搭出从内核态回到用户态所需的执行上下文，do_execve 负责回收旧地址空间并触发新程序加载，load_icode 则负责解析 ELF、建立新的虚拟内存布局、装入代码段和数据段、创建用户栈并设置 trapframe，最终让 CPU 能从用户程序入口开始执行。
- **需要处理的主要场景**：内核线程创建与首次调度、普通构建或 `TEST` 构建选择嵌入的用户程序、ELF 段与用户栈装载、内核线程执行 `exec`、父进程等待及回收僵尸子进程，以及创建或装载失败后的清理。
- **与其他模块的交互关系**：依赖 `do_fork`、`copy_thread` 和调度器建立线程；依赖虚拟内存接口建立页表；通过 `__trapret`、`RESTORE_ALL`、`sret` 进入用户态；与 `do_exit` 的僵尸态及唤醒逻辑配合完成回收。从启动路径上看，proc_init、kernel_thread、init_main、user_main、kernel_execve、do_execve、load_icode 和 do_wait 组成了从内核启动到用户程序启动的完整对外接口；从用户可见行为上看，系统最终应该表现为第一个用户程序能够被正确装入、正确切换到用户态、并且在退出后被父进程正确等待和回收。init_main 还应该持续作为系统启动后的收尾控制点，确保用户进程链路结束后内核状态稳定。

#### 最终提示词

以下是经过迭代优化后，最终成功实现该功能的提示词：

````markdown
## module2

### [PROMPT]

**任务**：完善 Lab5 的“创建加载第一个用户进程”模块，贯通 `proc_init → init_main → user_main → kernel_execve → do_execve → load_icode → __trapret → sret`，通过构造可供中断返回路径恢复的 trapframe，使 `sret` 一次完成跳转到 ELF 程序入口和从 S 态降到 U 态；并通过 `do_wait` 等待、回收退出的子进程。检查 `alloc_proc`、`kernel_thread`、`init_main`、`user_main`、`kernel_execve`、`do_execve`、`load_icode`、`do_wait` 及其依赖的 `copy_thread`，修正不符合下述规格的现有实现。

**操作要求**：修改项目实际文件 `code/lab5/lab5_new/kern/process/proc.c` 中模块二相关实现，不重复定义已有函数，不改动功能模块三、四及 Challenge。保留 `lab5 function2` 标记注释；完成对应区域时，把其中的 `YOUR CODE` 替换为 `MY CODE:2413340`。保持 `proc.h` 中的公开接口和现有结构体布局。中文注释。

**输出要求**：直接进行文件操作，使用下面`[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]`部分的信息；以工程的真实定义为准，不要引入文件系统、设备管理等本实验范围之外的功能。完成后在 `code/lab5/lab5_new` 下执行 `make`，环境允许时再运行首个用户程序或执行 `make grade`。列出所用命令与失败信息，未执行的验证不得写成通过。

### [RELY]

- `kern/process/proc.c`：`proc_init` 已建立 `idleproc`，再用 `kernel_thread(init_main, "Hello world!!", 0)` 建立 `initproc`；`init_main` 当前创建 `user_main` 并调用 `do_wait(0, NULL)`。
- `kern/process/entry.S`：`kernel_thread_entry` 将 `s1` 放入 `a0` 后跳转到 `s0`，线程函数返回时调用 `do_exit`。`copy_thread` 将 trapframe 放在新进程内核栈顶，并设置 `context.ra = forkret`、`context.sp = proc->tf`。
- `KERNEL_EXECVE` 和 `KERNEL_EXECVE2` 使用链接进内核的用户 ELF 二进制符号；`user_main` 在 `TEST` 构建下选择测试程序，普通构建下选择 `exit`。
- `kern/trap/trapentry.S` 已有 `__trapret`、`RESTORE_ALL`、`sret`；`RESTORE_ALL` 根据 `SSTATUS_SPP` 区分返回 S 态或 U 态，并在返回 U 态前将内核栈指针写入 `sscratch`。
- `kern/process/proc.h` 定义 `proc_struct`、`PROC_SLEEPING`、`PROC_ZOMBIE`、`WT_CHILD`、`PF_EXITING` 和父子进程链接；`do_exit` 负责置僵尸态及唤醒父进程，`do_wait` 负责最终回收内核栈和 PCB。
- `libs/elf.h` 定义 `elfhdr`、`proghdr`、`ELF_PT_LOAD` 及 `p_filesz/p_memsz`；`kern/mm/memlayout.h` 定义 `USTACKTOP`、`USTACKSIZE`。可使用 `mm_create`、`setup_pgdir`、`mm_map`、`pgdir_alloc_page`、`exit_mmap`、`put_pgdir`、`mm_destroy`、`user_mem_check`、`flush_tlb` 等现有接口。

### [GUARANTEE]

必须保持以下接口的签名与返回类型：

```c
static struct proc_struct *alloc_proc(void);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);
static int init_main(void *arg);
static int user_main(void *arg);
static int kernel_execve(const char *name, unsigned char *binary, size_t size);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
static int load_icode(unsigned char *binary, size_t size);
int do_wait(int pid, int *code_store);
```

- 首个用户程序从有效 ELF 映像装入，其入口、用户栈、页表和 trapframe 一致，最终由 `sret` 同时把 PC 设为 ELF 入口并从 S 态切换到 U 态。
- 内核线程仍可沿 `do_fork → copy_thread → forkret → forkrets → __trapret` 首次运行；`exec` 成功后当前进程的名称、`mm`、`pgdir`、`tf` 与新映像一致。
- `do_wait(0, NULL)` 等待任一子进程；指定 PID 只等待当前进程的子进程；僵尸子进程及其资源仅回收一次。
- 保留模块二以外的接口、进程树约定及数据布局。

### [SPECIFICATION]

#### alloc_proc

**Pre-Condition**：内核内存分配器可用。
**Post-Condition**：成功时返回状态为 `PROC_UNINIT`、各指针和链接处于安全初值的 PCB；分配失败返回 `NULL`。
**Case 1**：供 `proc_init` 创建 idle 进程，或供 `do_fork` 创建新线程/进程。
**Case 2**：内存不足时不返回半初始化 PCB。
**Requirements**：初始 `mm` 为空，内核线程页表指向启动页表；初始化 `pid`、`tf`、`context`、等待状态及父子链接。

#### kernel_thread

**Pre-Condition**：`fn` 为有效入口函数，当前进程可创建子线程。
**Post-Condition**：返回新线程 PID 或负错误码；首次运行时执行 `fn(arg)`，返回后进入 `do_exit`。
**Case 1**：`proc_init` 创建 `init_main`，`init_main` 创建 `user_main`。
**Case 2**：创建失败时不让未完成的线程进入可运行队列。
**Requirements**：按 `kernel_thread_entry` 的 `s0/s1` 约定构造 trapframe；设置返回 S 态所需的 `SSTATUS_SPP`、`SSTATUS_SPIE`；与 `do_fork`、`copy_thread` 的首次运行上下文保持一致。

#### init_main

**Pre-Condition**：当前执行者是 `initproc` 内核线程，进程创建与调度机制可用。
**Post-Condition**：创建 `user_main` 线程，等待其及启动阶段其他子进程退出并回收，最后输出收尾信息。
**Case 1**：子进程退出后，`do_wait(0, NULL)` 成功并继续检查是否还有子进程。
**Case 2**：创建失败时报告错误；没有待回收子进程时结束等待。
**Requirements**：等待循环必须符合 `do_wait` 的实际返回语义，不遗漏僵尸子进程。

#### user_main

**Pre-Condition**：作为过渡内核线程运行，嵌入的用户程序符号存在。
**Post-Condition**：成功时当前线程被转换为用户进程，控制流进入用户程序；失败时进入明确的错误路径。
**Case 1**：普通构建使用 `KERNEL_EXECVE(exit)`。
**Case 2**：定义 `TEST` 时使用 `KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE)`。
**Requirements**：保留现有测试程序选择机制，成功的 `exec` 不应回到原来的内核线程函数继续执行。

#### kernel_execve

**Pre-Condition**：当前内核线程有有效的 `current->tf`，`name` 和嵌入 ELF 数据有效。
**Post-Condition**：调用 `do_execve` 完成装载后，将 `sp` 指向预先构造的 trapframe，形成可供 `__trapret` 恢复的中断返回现场；`sret` 依据恢复的 `sepc` 和 `sstatus.SPP`，一次完成 PC 跳转到用户程序入口与特权级降至 U 态；失败时返回错误。
**Case 1**：装载成功，`sp` 指向 `current->tf`，返回路径恢复用户入口和用户栈。
**Case 2**：装载失败，不跳入 trap 返回路径。
**Requirements**：不能只调用 `do_execve`；必须让 `__trapret` 从 `current->tf` 恢复返回现场后执行 `sret`。核对切换 `sp` 后的控制流与编译器约束。

#### do_execve

**Pre-Condition**：当前进程和 trapframe 有效；程序名可按调用来源安全读取。
**Post-Condition**：成功时旧映像被新映像替换，进程名称与新程序一致；失败时遵守现有错误及退出约定。
**Case 1**：首次从内核线程执行时 `current->mm == NULL`。
**Case 2**：已有用户映像时，先切回内核页表并正确解除旧 `mm` 的引用，再装载新映像。
**Requirements**：检查名称指针并限制名称长度；旧地址空间回收、`current->mm` 更新及新映像装载顺序须一致。

#### load_icode

**Pre-Condition**：`current->mm == NULL`，`binary` 与 `size` 描述待装载 ELF。
**Post-Condition**：建立用户页表、可装载段和用户栈；构造返回用户态所需的 trapframe：`current->tf->epc` 为 ELF 入口（由 `__trapret` 恢复到 `sepc`），`gpr.sp` 为用户栈顶，清除 `status` 中的 `SSTATUS_SPP`、设置 `SSTATUS_SPIE`；切换 `satp` 并刷新 TLB。
**Case 1**：`p_filesz < p_memsz` 时，文件内容正确复制，剩余 BSS 区域为零。
**Case 2**：存在跨页的装载段时，每页内容、映射范围及用户权限正确。
**Case 3**：ELF 无效、字段越界、地址溢出或页面分配失败时，清理已建立的 VMA、页表和 `mm`，不留下半初始化地址空间。
**Requirements**：读取 ELF 头、程序头和段内容前结合 `size` 检查边界；验证用户虚拟地址范围；按 ELF 段权限与当前页表接口建立映射；用户栈须可由 U 态读写。

#### do_wait

**Pre-Condition**：`pid == 0` 表示任一子进程，非零表示指定子进程；`code_store` 可为 `NULL`。
**Post-Condition**：找到僵尸子进程时按需写入退出码，摘除链接并释放内核栈及 PCB，返回 0；无符合条件的子进程时返回错误。
**Case 1**：子进程尚在运行时，父进程以 `WT_CHILD` 睡眠，被唤醒后重新查找。
**Case 2**：指定 PID 不存在或不是当前进程的子进程时，不回收无关进程。
**Case 3**：`code_store` 不可写，或等待进程收到退出标志时，按现有错误与退出约定处理。
**Requirements**：与 `do_exit` 的僵尸态和父进程唤醒逻辑一致；避免丢失唤醒、重复摘链或重复释放。
````
#### 实现迭代过程

本模块根据提示词检查并完善已有实现，在 WSL Ubuntu 中运行后发现启动收尾问题，并据此修正。迭代过程如下：

---

##### 第一次迭代：发现并修复 initproc 退出问题

**遇到的问题：**

- 问题1：根据提示词检查代码，补充 `load_icode()` 的 ELF 边界和页权限检查、`do_wait()` 的睡眠前中断保护后，使用 WSL Ubuntu 编译并启动 QEMU。`exit` 用户程序完成 `fork`、`waitpid`，输出 `exit pass.` 和 `init check memory pass.`，随后却报 `kernel panic at kern/process/proc.c:508: initproc exit.`。
- 原因：`init_main()` 的 `while (do_wait(0, NULL) == 0)` 在没有子进程可等待时结束，打印收尾信息后直接 `return 0`。`kern/process/entry.S` 中的 `kernel_thread_entry` 随即把返回值传给 `do_exit()`；而 `do_exit()` 明确禁止 `initproc` 退出。

**问题解决策略：**

- 针对问题1：在 `init_main()` 打印收尾信息后持续调用 `schedule()`，避免返回到 `kernel_thread_entry` 的 `do_exit()`，使 `initproc` 继续作为系统的收尾控制点。重新构建并启动 QEMU 后，再次看到 `waitpid 3 ok.`、`exit pass.`、`all user-mode processes have quit.` 和 `init check memory pass.`；随后持续出现时钟中断输出，5 秒观察窗口内未再出现该 panic，QEMU 由 `timeout` 主动终止。

---

##### 最终结果

- :white_check_mark: 首个用户程序在 QEMU 中启动、执行 `fork/wait` 并输出 `exit pass.`；修复后观察窗口内未再出现 `initproc exit` panic。
- :white_check_mark: 使用 WSL Ubuntu 的 RISC-V 工具链完成编译。仓库现有 `kern/mm/kmalloc.c` 有指针类型诊断，完整重编译时仅在命令行加入 `-Wno-error=int-conversion` 将其降为警告，未修改该文件。

**关键改进点总结：**

1. 本次问题表明，`init_main()` 的提示词还应明确“收尾后不能返回并导致 `initproc` 退出”，使后续使用提示词时覆盖用户程序退出后的内核控制流。
2. 用实际 QEMU 输出确认 `sret` 后用户程序可以运行，并把 `exit pass.` 之后的 panic 与用户程序本身的运行结果分开分析。

---

### 功能模块：复制用户进程功能

**负责人：** 2413340-戴璐
#### 模块功能描述

**需要实现/修改的函数：**

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) (kern/process/proc.c)
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc) (kern/process/proc.c)
int dup_mmap(struct mm_struct *to, struct mm_struct *from) (kern/mm/vmm.c)
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) (kern/mm/pmm.c)
```

**功能说明：**
这一部分负责把父进程的执行环境复制成一个新的子进程，使子进程拥有自己的进程控制块、内核栈、trapframe 和用户地址空间映像。`do_fork` 是整条链路的总入口，它需要把子进程创建出来并接入进程树，同时准备好后续调度所需的执行上下文；`copy_mm` 是在 `lab4` 已有实现基础上的更新点，它决定新进程是与父进程共享地址空间还是复制地址空间，在本实验的普通 fork 路径中主要体现为复制用户地址空间；`dup_mmap` 负责按 `vma` 粒度复制父进程的合法虚拟内存区域；`copy_range` 则负责按页粒度复制页面内容并建立新的页表映射。整体上，这条链路保证了子进程既能继承父进程看到的程序和数据，又能在之后独立运行、独立调度、独立退出。

#### 最终提示词

以下为根据当前 Lab5 代码及实验文档设计、已用于检查和完善模块三代码的提示词：

````markdown
## module3

### [PROMPT]

**任务**：完善 Lab5 的“复制用户进程”模块，检查并修正 `do_fork()`、`copy_mm()`、`dup_mmap()`、`copy_range()` 的现有实现，使用户态 `fork` 能复制进程控制块、内核栈、trapframe、VMA 和已映射的用户页面。父进程获得子进程 PID，子进程从同一用户执行位置继续并获得返回值 0；内核线程及 `CLONE_VM` 路径仍可使用同一创建框架。

**操作要求**：修改项目实际文件，仅处理 `code/lab5/lab5_new/kern/process/proc.c`、`kern/mm/vmm.c`、`kern/mm/pmm.c` 中 `lab5 function3 YOUR CODE` 标记对应的上述四个函数。它们已有实现，应按下述规格检查并修正，不重复添加函数。保留标记注释，将模块三标记中的 `YOUR CODE` 替换为 `MY CODE:2413340`；保持已有函数签名、结构体布局，以及功能模块一、二 的代码不变。新添加的注释应为中文。

**输出要求**：说明各函数的改动、失败路径及验证结果。在 `code/lab5/lab5_new` 下执行 `make`；环境允许时运行 `forktest`、`forktree` 等相关用例或 `make grade`。未执行或被其他错误阻断的测试不得记为通过。

### [RELY]

- `kern/syscall/syscall.c`：`sys_fork()` 以 `do_fork(0, current->tf->gpr.sp, current->tf)` 发起普通用户进程复制；系统调用返回值写入父进程 trapframe 的 `a0`。
- `kern/process/proc.c`：已有 `alloc_proc()`、`setup_kstack()`、`put_kstack()`、`copy_thread()`、`get_pid()`、`hash_proc()`、`set_links()`、`wakeup_proc()`、`forkret()`。`copy_thread()` 把 trapframe 放在子进程内核栈顶，将子进程的 `gpr.a0` 置 0，并设置首次调度的 `context.ra/sp`。`proc_struct` 通过 `parent/cptr/optr/yptr` 维护进程树，通过 `list_link/hash_link` 接入进程表。
- `copy_mm()` 可使用 `current->mm`、`mm_create()`、`setup_pgdir()`、`lock_mm()/unlock_mm()`、`dup_mmap()`、`mm_count_inc()`、`set_mm_count()`、`exit_mmap()`、`put_pgdir()`、`mm_destroy()`；`CLONE_VM` 在 `libs/unistd.h` 中定义。
- `kern/mm/vmm.c`：`mm_struct` 持有按地址排序的 `mmap_list` 和页表；`vma_struct` 保存 `[vm_start, vm_end)` 与 `vm_flags`。可使用 `vma_create()`、`insert_vma_struct()`、`copy_range()`。普通 `fork` 使用逐 VMA、逐页复制；共享 `mm` 的路径在 `copy_mm()` 中处理。
- `kern/mm/pmm.c`：可使用 `get_pte()`、`pte2page()`、`alloc_page()`、`page2kva()`、`page_insert()`、`free_page()`；`PTE_USER` 覆盖用户页的 `R/W/X/U/V` 权限位。`copy_range()` 的 `share` 参数为真时建立到同一物理页的映射，为假时复制整页。未映射页面可以跳过。
- `kern/process/proc.h` 定义 `MAX_PROCESS`、`PROC_UNINIT`、`PROC_RUNNABLE` 和 `proc_struct`；`-E_NO_FREE_PROC` 表示进程数达到上限，`-E_NO_MEM` 表示分配失败。调度器只应看到初始化完成且已唤醒的子进程。

### [GUARANTEE]

必须保持以下接口及其返回类型：

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
int dup_mmap(struct mm_struct *to, struct mm_struct *from);
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share);
```

- 普通用户态 `fork` 成功后，父进程得到唯一正 PID，子进程的 `a0` 为 0；子进程有独立 PCB、内核栈、trapframe、VMA、页表和用户物理页，复制时刻的页面内容与父进程一致，之后双方写入互不影响。
- `CLONE_VM` 路径正确增加同一 `mm` 的引用计数，不把共享地址空间误当作普通 `fork` 的独立副本；内核线程的 `current->mm == NULL` 路径不复制用户地址空间。
- 子进程完成 PID、父子关系、哈希表及进程表挂接后才成为可运行状态。任何失败都返回负错误码，并撤销本次创建中已取得的资源和引用，不留下可见的半初始化进程。
- 保持 `copy_thread()`、进程树、页表接口和模块三以外的代码约定；不实现 Copy on Write 扩展练习。

### [SPECIFICATION]

#### do_fork

**Pre-Condition**：`current` 和 `tf` 有效；`clone_flags` 决定地址空间共享方式，`stack` 是新进程的初始栈指针参数；进程管理器已初始化。
**Post-Condition**：成功时返回子进程 PID；子进程具有独立内核栈和 trapframe，已接入进程树及调度器，首次运行通过现有 trap 返回路径继续执行。失败时返回负错误码且无残留子进程。
**Case 1**：普通用户进程 `fork` 使用 `clone_flags == 0`，父进程得到新 PID，子进程以 `a0 == 0` 从相同用户执行位置继续。
**Case 2**：内核线程创建时父进程没有用户 `mm`，仍应建立 PCB、内核栈和首次运行现场，不访问不存在的用户页表。
**Case 3**：达到 `MAX_PROCESS`、PCB 或内核栈分配失败、地址空间复制失败时，返回相应错误并按逆序清理已分配资源。
**Requirements**：保持 `copy_thread()` 的返回值与栈语义；在合适的关中断临界区完成 PID 分配、哈希表和进程树挂接，初始化完成后才调用 `wakeup_proc()`。

#### copy_mm

**Pre-Condition**：子进程 PCB 已分配但未发布；`current` 指向父进程，`proc->mm` 尚未绑定用户地址空间。
**Post-Condition**：无用户 `mm` 时子进程沿用内核页表；设置 `CLONE_VM` 时子进程共享父进程 `mm` 且引用计数增加一次；普通 `fork` 时子进程获得独立的 `mm`、页表及用户映射。
**Case 1**：`current->mm == NULL`，返回成功且不尝试复制用户空间。
**Case 2**：`clone_flags & CLONE_VM`，共享同一 `mm`，`pgdir` 与该 `mm` 对应，退出时由引用计数决定最终回收时机。
**Case 3**：普通 `fork` 创建新 `mm` 和页表，锁定父 `mm` 后调用 `dup_mmap()`；复制失败时解锁并清理新地址空间，不更改父进程映像。
**Requirements**：复制成功后才把新 `mm/pgdir` 发布到子进程并设置引用计数；锁与引用计数在所有返回路径上保持平衡。

#### dup_mmap

**Pre-Condition**：`from` 有有效且按地址排序的 VMA 链表和页表；`to` 是已创建页表、尚未包含父进程 VMA 的目标 `mm`。
**Post-Condition**：目标 `mm` 中的 VMA 区间、顺序和权限与源一致；每个已映射用户页由 `copy_range()` 复制，未映射区间保持未映射。
**Case 1**：多个 VMA 或含空洞的 VMA 被逐一复制，目标区间不重叠且权限不变。
**Case 2**：VMA 创建或页复制失败时返回错误，由调用者清理已插入的目标 VMA 和页面；源 `mm` 不受影响。
**Requirements**：普通 `fork` 的 `copy_range(..., false)` 不共享物理页；不得把 `CLONE_VM` 的共享语义混入此函数。

#### copy_range

**Pre-Condition**：`start/end` 为页对齐的有效用户地址，区间为 `[start, end)`；`from/to` 是有效页表，`share` 指定是否共享物理页。
**Post-Condition**：源区间中每个有效用户页在目标页表建立相应映射；普通复制时目标页内容与源页一致且物理页独立；共享模式下双方映射同一物理页并保持正确引用计数和权限。
**Case 1**：源页表项不存在或页面未映射时跳过，目标对应地址仍未映射。
**Case 2**：`share == false` 时分配目标页、复制完整 `PGSIZE` 字节并建立映射，之后父子写入互不影响。
**Case 3**：`share == true` 时复用源物理页并建立目标映射，不复制页面内容。
**Case 4**：目标页表或物理页分配、映射失败时返回 `-E_NO_MEM`，释放当前尚未接入页表的新页；已接入的映射由上层失败清理路径回收。
**Requirements**：从源 PTE 保留实际用户访问权限；遍历只覆盖 `[start, end)`，跳过缺失页表时不越过尚需检查的页；通过 `page_insert()` 维护映射和引用计数，不引入 COW。
````

#### 实现迭代过程

本模块按提示词检查已有实现，并在 WSL Ubuntu 的临时工程副本中编译、运行。`forktree` 停滞的定位与修复也记录在下面；该问题最终落在模块三依赖的进程退出路径。

---

##### 第一次迭代：核对复制路径与错误传播

**遇到的问题：**

- 问题1：原有 `copy_range()` 先用 `get_pte(to, start, 1)` 建立或查询目标页表，随后 `page_insert()` 再次查询同一位置，操作重复；跳过缺失页表的注释写成 4MB，但工程的 `PTSIZE` 是 2MB。
- 问题2：`dup_mmap()`、`copy_mm()` 把下层复制失败统一改写成 `-E_NO_MEM`，未保留实际返回值；`do_fork()` 在挂接子进程后先恢复中断，再调用 `wakeup_proc()`，发布与转为可运行状态分属两个临界区。

**问题解决策略：**

- 针对问题1：删去重复的目标 PTE 查询，交由 `page_insert()` 建立映射并维护页面引用计数；将缺失末级页表的注释改为 2MB。普通复制仍分配新物理页、复制完整页面；`share` 路径仍映射源物理页。
- 针对问题2：逐层返回复制函数的实际错误码；在 `do_fork()` 的同一关中断临界区内完成 PID、哈希表、进程树挂接和唤醒。保留已有的失败清理顺序及 `copy_thread()` 中子进程 `a0 = 0` 的约定。

---

##### 第二次迭代：定位并修复 forktree 停滞

**遇到的问题：**

- 问题1：QEMU 运行 `forktest` 输出 `forktest pass.`，但 `forktree` 只输出根进程 `0002: I am ''`，延长观察到 20 秒仍没有子进程输出。恢复修改前的模块三 `pmm.c`、`vmm.c` 进行对照后，现象仍在，说明不能仅按页面复制问题处理。
- 定位：QEMU 异常日志显示停滞期间持续发生用户态 `ecall`。在临时副本的 `forktree` 中加入定位输出后，根进程的两次 `fork` 分别返回 PID 3 和 4；停滞发生在根进程随后退出时。检查 `do_exit()` 发现，过继子进程的循环误写成 `proc->cptr = proc->optr`，没有更新循环条件 `current->cptr`，导致父进程有存活子进程时无限循环。`forktest` 先等待子进程，因而没有触发这条路径。

**问题解决策略：**

- 针对问题1：将 `do_exit()` 中该行改为 `current->cptr = proc->optr`，使循环逐个摘下当前进程的子进程，再过继给 `initproc`。这一行属于功能模块四的退出代码，但它是模块三 `forktree` 场景必经的依赖路径，因此在定位原因后作最小修复。重新运行原始 `forktree`，输出了从空路径到四层路径的 31 个进程节点，随后出现 `all user-mode processes have quit.` 和 `init check memory pass.`；修复后再次运行 `forktest`，仍输出 `forktest pass.`。

---

##### 第三次迭代：处理验证环境阻断

**遇到的问题：**

- 问题1：直接执行 `make grade` 时，仓库中的 `tools/grade.sh` 使用 CRLF 换行，WSL 的 `sh` 无法解析；只转换 `/tmp` 中的脚本副本后，评分构建又被现有 `kern/mm/kmalloc.c` 的指针类型诊断阻断。

**问题解决策略：**

- 针对问题1：在 WSL 临时工程副本中编译并运行单项用例，命令行加入 `-Wno-error=int-conversion`，只把上述诊断降为警告，不修改 `kmalloc.c` 或仓库评分脚本。`forktest` 与 `forktree` 均实际运行并观察到预期输出；评分脚本仍未完整运行，因此不报告 `make grade` 分数。

---

##### 最终结果

- :white_check_mark: 模块三的四个函数按提示词完成检查和局部修正，保留接口及 `MY CODE:2413340` 标记；WSL 临时副本可在上述临时编译选项下完成构建。
- :white_check_mark: QEMU 中 `forktest` 输出 `forktest pass.`；修复 `do_exit` 后，`forktree` 输出完整的 31 个进程节点及启动收尾信息，不再停滞。修复后再次运行 `forktest`，未出现回归。
- :question: `make grade` 仍被脚本换行及现有编译诊断阻断，未获得完整评分结果；上述运行结果也不覆盖所有错误路径和边界条件。

**关键改进点总结：**

1. `forktest` 覆盖了父进程先等待子进程的路径；`forktree` 覆盖父进程先退出、子进程成为孤儿的路径。两者结合才暴露进程树过继循环的错误。
2. `do_exit` 遍历子进程时必须更新 `current->cptr`，否则循环条件不变，内核会一直停在退出流程。定位输出应先确认 `fork` 本身是否成功，再沿父进程的后续控制流排查。
3. 模块三的复制逻辑依赖模块四的退出与过继逻辑；出现跨模块故障时，应记录实际修改范围及验证证据。完整评分未运行成功时，不填写总分。

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
