## 功能模块一：用户态系统调用功能

### [PROMPT]

**任务**：修改 Lab5 工程 `lab5_new` 中的 `kern/trap/trap.c` 与 `kern/syscall/syscall.c`，实现“用户态系统调用”功能模块。该模块负责把用户程序通过 `ecall` 发起的请求接入内核并返回结果：`exception_handler()` 需要识别 `CAUSE_USER_ECALL`，先把 `epc` 前移以避免重复执行同一条 `ecall`，再把控制权交给 `syscall()`；`syscall()` 从当前进程的 `trapframe` 中取出系统调用号和参数，按分发表调用对应的 `sys_*` 处理函数，并把返回值写回 `a0`；`sys_exit()`、`sys_fork()`、`sys_wait()`、`sys_exec()`、`sys_yield()`、`sys_kill()`、`sys_getpid()`、`sys_putc()`、`sys_pgdir()` 则把统一编号的系统调用翻译成具体内核语义，分别落到 `do_exit()`、`do_fork()`、`do_wait()`、`do_execve()`、`do_yield()`、`do_kill()`、当前进程 PID、控制台输出和页表打印上。

**操作要求**：你必须在项目中修改实际文件，而不是仅展示代码。只在 `kern/trap/trap.c` 的 `//lab3 请补充你在lab3中的代码`、`//lab5 function1 YOUR CODE update exception_handler` 和 `kern/syscall/syscall.c` 的 `//lab5 function1 YOUR CODE` 标记处补全本模块，保留已有的 `idt_init()`、`trap_in_kernel()`、`print_trapframe()`、`trap_dispatch()`、`trap()`、`syscalls[]` 分发表和 `NUM_SYSCALLS`。不要实现功能模块二/三/四中的进程创建、复制、退出细节，也不要在本模块里重写 `do_*` 函数。不得删除现有注释与 `YOUR CODE` 标记。

**输出要求**：直接进行文件操作，使用下面 `[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 部分的信息；以工程中的真实定义为准，不要引入文件系统、设备管理等本实验范围之外的功能。实现完成后报告实际编译与运行结果，未执行的验证不要写成通过。

### [RELY]

```c
// introspect：trapframe 的通用寄存器布局（x0~x31）
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

// 系统调用号（libs/unistd.h）
#define SYS_exit 1
#define SYS_fork 2
#define SYS_wait 3
#define SYS_exec 4
#define SYS_yield 10
#define SYS_kill 12
#define SYS_getpid 18
#define SYS_putc 30
#define SYS_pgdir 31

// 异常原因（libs/riscv.h）
#define CAUSE_USER_ECALL          0x8
#define CAUSE_ILLEGAL_INSTRUCTION 0x2
#define CAUSE_BREAKPOINT          0x3
#define CAUSE_LOAD_PAGE_FAULT     0xd
#define CAUSE_STORE_PAGE_FAULT    0xf
```

- 全局状态：`current` 指向当前进程，`current->tf` 指向本次陷入保存的 `trapframe`。
- 用户态约定（`user/libs/syscall.c`）：`a0` 保存系统调用号，`a1`~`a5` 依次保存最多 5 个参数；`ecall` 触发异常，返回后在用户态读取 `a0`。
- 可调用接口：`do_exit(error_code)`、`do_fork(clone_flags, stack, tf)`、`do_wait(pid, code_store)`、`do_execve(name, len, binary, size)`、`do_yield()`、`do_kill(pid)`；`find_proc()`；`user_mem_check(mm, addr, len, write)`；`cputchar(c)`；`print_pgdir()`。
- `trap_in_kernel(tf)` 通过 `tf->status & SSTATUS_SPP` 判断陷入前是否处于内核态；`print_trapframe(tf)` 用于打印异常现场。
- 错误码：非法/未实现的系统调用返回 `-E_INVAL`；`do_kill()` 对不存在的 PID 返回 `-E_INVAL`；`do_wait()` 对非自己的子进程返回 `-E_BAD_PROC`。

### [GUARANTEE]

必须实现或修改以下接口，签名和返回类型保持不变：

```c
void exception_handler(struct trapframe *tf);          // kern/trap/trap.c
void syscall(void);                                    // kern/syscall/syscall.c
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

你可以根据需要添加：

- `static` 辅助函数（只在本模块内部使用，不改变公开接口）
- 模块内部使用的宏定义或静态变量

不要新增对外接口，也不要修改 `kern/syscall/syscall.h` 中已有的函数声明。

### [SPECIFICATION]

#### exception_handler

**Pre-Condition**：
- `tf` 指向本次异常保存的中断帧；`current` 在用户进程运行阶段有效。

**Post-Condition**：
- 用户态 `ecall` 已被分发到 `syscall()`，并且 `tf->epc` 已经指向 `ecall` 的下一条指令；其他异常被识别、打印或按既定策略处理，函数返回后由通用返回路径恢复现场。

**Case 1（`CAUSE_USER_ECALL`）**：
- 先把 `tf->epc` 增加 4（RISC-V `ecall` 固定为 4 字节指令），再调用 `syscall()`；不能把 `epc` 前移放在分发之后，否则用户态可能重复执行同一条 `ecall`。

**Case 2（非法指令 / 断点）**：
- 打印异常地址，并按指令低两位判断是 32 位还是 16 位压缩指令，把 `epc` 前移相应长度，避免返回后原地反复触发。

**Case 3（用户态缺页）**：
- 本实验没有实现按需分页，用户态非法访问不应让内核陷入死循环；将当前进程标记为 `PF_EXITING`，由 `trap()` 在返回用户态前调用 `do_exit(-E_KILLED)` 结束该进程。

**Case 4（其他异常）**：
- 调用 `print_trapframe(tf)` 输出现场，便于定位问题。

#### syscall

**Pre-Condition**：
- `current != NULL` 且 `current->tf` 指向本次系统调用的中断帧；分发表 `syscalls[]` 已按 `SYS_*` 编号完成初始化。

**Post-Condition**：
- 合法且已实现的系统调用执行完成，返回值写入 `tf->gpr.a0`；非法编号或分发表空项返回 `-E_INVAL`。

**Case 1（合法编号且已实现）**：
- 从 `gpr.a1`~`gpr.a5` 取出 5 个参数放入局部数组，调用 `syscalls[num](arg)`，把返回值写回 `gpr.a0`。

**Case 2（编号越界或未实现）**：
- 不访问分发表越界项，直接把 `gpr.a0` 置为 `-E_INVAL`。

**Requirements**：
- 参数位置必须与用户态 `user/libs/syscall.c` 的寄存器约定一致；`syscalls[]` 是稀疏数组，空项必须判空。

#### sys_exit

**Pre-Condition**：`arg[0]` 是用户传入的退出码。
**Post-Condition**：当前进程进入退出流程，正常情况下不再返回用户态。
**Case 1**：调用 `do_exit((int)arg[0])`，其返回值仅在异常情况下出现。

#### sys_fork

**Pre-Condition**：当前进程处于用户态系统调用上下文，`current->tf` 是父进程的中断帧。
**Post-Condition**：成功时返回子进程 PID 给父进程，子进程在用户态从 0 返回。
**Case 1**：以父进程当前用户栈指针 `tf->gpr.sp` 和中断帧 `tf` 为模板调用 `do_fork(0, stack, tf)`，不设置 `CLONE_VM`，表示复制地址空间。

#### sys_wait

**Pre-Condition**：`arg[0]` 是目标 PID（0 表示任意子进程），`arg[1]` 是用户态退出码指针或 `NULL`。
**Post-Condition**：成功回收到一个僵尸子进程时返回 0，并把退出码写回用户指针；参数非法返回 `-E_INVAL`，非自己的子进程返回 `-E_BAD_PROC`。
**Case 1**：把参数转为 `int pid` 与 `int *store` 后调用 `do_wait()`；用户指针合法性由 `do_wait()` 内部的 `user_mem_check()` 保证。

#### sys_exec

**Pre-Condition**：四个参数依次为用户态程序名指针、名字长度、ELF 二进制指针和大小。
**Post-Condition**：成功时当前进程映像被替换，失败时返回负错误码。
**Case 1**：把参数转换为对应类型后调用 `do_execve(name, len, binary, size)`。

#### sys_yield

**Pre-Condition**：无需额外参数。
**Post-Condition**：当前进程被标记为需要重新调度，返回 0。
**Case 1**：直接返回 `do_yield()`。

#### sys_kill

**Pre-Condition**：`arg[0]` 是目标进程 PID。
**Post-Condition**：成功向目标进程设置退出标志并返回 0；目标已处于退出状态返回 `-E_KILLED`；目标不存在返回 `-E_INVAL`。
**Case 1**：把参数转为 `int pid` 后调用 `do_kill(pid)`。

#### sys_getpid

**Pre-Condition**：`current` 有效。
**Post-Condition**：返回当前进程 PID。
**Case 1**：直接返回 `current->pid`。

#### sys_putc

**Pre-Condition**：`arg[0]` 是待输出字符。
**Post-Condition**：字符已交给内核控制台输出，返回 0。
**Case 1**：调用 `cputchar((int)arg[0])` 后返回 0；用户态不能直接调用控制台接口。

#### sys_pgdir

**Pre-Condition**：当前进程地址空间有效。
**Post-Condition**：当前页表内容被打印到控制台，返回 0。
**Case 1**：调用 `print_pgdir()` 后返回 0。

**Requirements**：
- `sys_*` 只能做参数转换和调用内核语义入口，进程状态、页表、进程树的真正修改由 `do_*` 完成，保证返回值写回与进程上下文切换一致。
- 用户指针不能直接信任：涉及用户指针的 `do_*` 路径必须经过 `user_mem_check()`。

## 功能模块二：创建加载第一个用户进程功能

## module2

### [PROMPT]

**任务**：完善 Lab5 的“创建加载第一个用户进程”模块，贯通 `proc_init → init_main → user_main → kernel_execve → do_execve → load_icode → __trapret → sret`，通过构造可供中断返回路径恢复的 trapframe，使 `sret` 一次完成跳转到 ELF 程序入口和从 S 态降到 U 态；并通过 `do_wait` 等待、回收退出的子进程。检查 `alloc_proc`、`kernel_thread`、`init_main`、`user_main`、`kernel_execve`、`do_execve`、`load_icode`、`do_wait` 及其依赖的 `copy_thread`，修正不符合下述规格的现有实现。

**操作要求**：修改项目实际文件 `code/lab5/lab5_new/kern/process/proc.c` 中模块二相关实现，不重复定义已有函数，不改动功能模块三、四及 Challenge。保留 `lab5 function2` 标记注释；完成对应区域时，把其中的 `YOUR CODE` 替换为 `MY CODE:2413340`。保持 `proc.h` 中的公开接口和现有结构体布局。

**输出要求**：说明各修改点、原因及实际验证结果；在 `code/lab5/lab5_new` 下执行 `make`，环境允许时再运行首个用户程序或执行 `make grade`。列出所用命令与失败信息，未执行的验证不得写成通过。

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

## 功能模块三：复制用户进程功能

## module3

### [PROMPT]

**任务**：完善 Lab5 的“复制用户进程”模块，检查并修正 `do_fork()`、`copy_mm()`、`dup_mmap()`、`copy_range()` 的现有实现，使用户态 `fork` 能复制进程控制块、内核栈、trapframe、VMA 和已映射的用户页面。父进程获得子进程 PID，子进程从同一用户执行位置继续并获得返回值 0；内核线程及 `CLONE_VM` 路径仍可使用同一创建框架。

**操作要求**：修改项目实际文件，仅处理 `code/lab5/lab5_new/kern/process/proc.c`、`kern/mm/vmm.c`、`kern/mm/pmm.c` 中 `lab5 function3 YOUR CODE` 标记对应的上述四个函数。它们已有实现，应按下述规格检查并修正，不重复添加函数。保留标记注释，将模块三标记中的 `YOUR CODE` 替换为 `MY CODE:2413340`；保持已有函数签名、结构体布局，以及功能模块一、二、四和 Challenge 的代码不变。

**输出要求**：说明各函数的改动、失败路径及验证结果。在 `code/lab5/lab5_new` 下执行 `make`；环境允许时运行 `forktest`、`forktree` 等相关用例或 `make grade`。如需针对仓库现有工具链问题临时调整构建命令，须列明命令和限制；未执行或被其他错误阻断的测试不得记为通过。

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
