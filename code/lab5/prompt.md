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
