## module2

### [PROMPT]

**任务**：修改 Lab4 工程 `lab4_new/kern/process/proc.c`，实现“进程创建及初始化”功能模块。该模块负责把系统中“已经能运行内核代码”的状态推进到“能够创建并登记多个内核线程”：`alloc_proc()` 负责得到一个干净、安全的进程控制块；`proc_init()` 负责把当前执行现场包装成 `idleproc` 并创建第一个真正的内核线程 `initproc`；`kernel_thread()` 负责把函数入口和参数整理成线程首次运行所需的临时中断帧；`do_fork()` 负责把内核栈、PID、哈希表/链表和状态位组合成一个可运行实体；`copy_thread()` 负责把中断帧和上下文安放到新线程自己的内核栈上；`copy_mm()` 在本实验阶段承担地址空间处理接口的占位作用。

**操作要求**：你必须在项目中修改实际文件，而不是仅展示代码。只在 `kern/process/proc.c` 中 `//LAB4 function2 YOUR CODE` 标记处补全本模块，保留已有的 `set_proc_name()`、`get_proc_name()`、`get_pid()`、`forkret()`、`hash_proc()`、`find_proc()`、`setup_kstack()`、`put_kstack()`、`init_main()` 等现有代码，不要修改功能模块一、功能模块三或其他文件中的逻辑。不得删除现有注释与 `YOUR CODE` 标记。

**输出要求**：直接进行文件操作，使用下面 `[RELY]`、`[GUARANTEE]`、`[SPECIFICATION]` 部分的信息；以工程中的真实定义为准，不要引入本实验范围之外的用户进程、文件系统或调度策略逻辑。实现完成后报告实际编译与运行结果，未执行的验证不要写成通过。

### [RELY]

```c
// kern/process/proc.h
enum proc_state { PROC_UNINIT = 0, PROC_SLEEPING, PROC_RUNNABLE, PROC_ZOMBIE };
struct context { uintptr_t ra, sp, s0, s1, s2, s3, s4, s5,
                             s6, s7, s8, s9, s10, s11; };
struct proc_struct {
    enum proc_state state; int pid; int runs; uintptr_t kstack;
    volatile bool need_resched; struct proc_struct *parent;
    struct mm_struct *mm; struct context context; struct trapframe *tf;
    uintptr_t pgdir; uint32_t flags; char name[PROC_NAME_LEN + 1];
    list_entry_t list_link, hash_link;
};
#define PROC_NAME_LEN 15
#define MAX_PROCESS   4096

// kern/trap/trap.h：gpr 中 s0=x8、s1=x9、a0=x10、sp=x2
struct trapframe { struct pushregs gpr; uintptr_t status, epc, badvaddr, cause; };

// 常量
#define KSTACKPAGE 2
#define KSTACKSIZE (KSTACKPAGE * PGSIZE)
#define CLONE_VM   0x00000100
#define SSTATUS_SIE  0x00000002
#define SSTATUS_SPIE 0x00000020
#define SSTATUS_SPP  0x00000100
```

- 全局状态：`proc_list`、`hash_list[]`、`idleproc`、`initproc`、`current`、`nr_process`。
- 可直接调用：`kmalloc`/`kfree`；`setup_kstack`（设置 `kstack`，成功返回 0）/`put_kstack`；`get_pid`、`hash_proc`、`find_proc`（PID 与哈希表管理）；`set_proc_name`、`wakeup_proc`（置 `PROC_RUNNABLE`）；`list_init`、`list_add`（插到 `listelm` 之后）；`memset`。
- 关键符号：`boot_pgdir_pa`（内核页表根物理地址）、`bootstack`、`read_csr(sstatus)`；`kernel_thread_entry` 把 `s1` 移入 `a0` 后跳转 `s0`；首次运行链路为 `forkret → forkrets → __trapret`，其中 `forkret` 调用 `forkrets(current->tf)`。
- 错误码：`-E_NO_MEM`、`-E_NO_FREE_PROC`。

### [GUARANTEE]

必须实现或修改以下接口，签名和返回类型保持不变：

```c
static struct proc_struct *alloc_proc(void);
void proc_init(void);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
static void copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf);
static int copy_mm(uint32_t clone_flags, struct proc_struct *proc);
```

你可以根据需要添加：

- `static` 辅助函数（只在本模块内部使用，不改变公开接口）
- 模块内部使用的宏定义或静态变量

不要新增对外接口，也不要修改 `proc.h` 中已有的函数声明。

### [SPECIFICATION]

#### alloc_proc

**Pre-Condition**：
- 物理内存分配器和 `kmalloc` 已经初始化，可以分配 `sizeof(struct proc_struct)` 字节的内存。

**Post-Condition**：
- 成功时返回一个所有字段都处于安全初始状态的 PCB；失败时返回 `NULL`。
- 新 PCB 尚未加入 `proc_list` 或 `hash_list`，也不持有内核栈。

**Case 1（分配成功）**：
- PCB 的全部字段先被清零，避免后续代码读到未初始化字段。
- 状态为 `PROC_UNINIT`，PID 为 `-1`，`runs`、`flags`、`need_resched` 为 0。
- `kstack` 为 0，`tf` 为 `NULL`，`parent`/`mm` 为 `NULL`。
- `pgdir` 指向内核当前页表的根物理地址 `boot_pgdir_pa`，因为当前阶段所有内核线程共享内核地址空间。
- `context` 中 `ra`、`sp` 等寄存器均为 0。

**Case 2（分配失败）**：
- 返回 `NULL`，不修改任何全局进程管理状态。

#### proc_init

**Pre-Condition**：
- `pmm_init()`、`vmm_init()` 已经完成，`bootstack` 可用，`kmalloc` 可用。
- 当前执行现场就是即将成为 `idleproc` 的内核上下文。

**Post-Condition**：
- `proc_list` 和 `hash_list` 全部初始化为空链表。
- `idleproc` 存在且可用：PID 为 0、状态为 `PROC_RUNNABLE`、`kstack` 为 `bootstack`、`need_resched` 已置位、`current == idleproc`。
- `initproc` 存在且可用：PID 为 1、状态为 `PROC_RUNNABLE`、`parent == idleproc`、`context.ra` 与 `context.sp` 均非 0，并已登记进 `proc_list` 和 `hash_list`。
- 两个线程都设置了可读的名字。

**Case 1（创建 idleproc）**：
- 使用 `alloc_proc()` 得到 PCB；它直接复用当前执行现场和启动栈，而不是通过 `do_fork()` 复制出来。
- 不能把 `idleproc` 加入 `proc_list`：调度器在找不到可运行线程时要把它作为保底线程使用，若它同时出现在就绪链表中会导致选择逻辑混乱。
- `nr_process` 需要把 `idleproc` 计入。

**Case 2（创建 initproc）**：
- 通过 `kernel_thread(init_main, "...", 0)` 创建；`kernel_thread` 返回新线程 PID，必须用 `find_proc()` 找到对应 PCB 并保存到 `initproc`。
- 创建失败时必须通过 `panic()` 终止初始化，不能留下只有 `idleproc` 的半初始化系统。

**Requirements**：
- `proc_init` 结束前 `current` 必须指向 `idleproc`，这样后续 `cpu_idle()` 和测试代码看到的当前线程才是正确的。
- `idleproc` 的 `need_resched` 必须置位，调度器第一次进入时才能切换到 `initproc`。

#### kernel_thread

**Pre-Condition**：
- `fn` 是合法的内核函数入口；`arg` 是传给它的参数；`do_fork()` 可用。

**Post-Condition**：
- 成功时返回新线程 PID；失败时返回 `do_fork()` 的负错误码。
- 新线程首次运行时从 `kernel_thread_entry` 进入，并以 `fn(arg)` 的形式执行。

**Case 1（正常创建）**：
- 构造一个临时 `struct trapframe` 并清零。
- `gpr.s0` 保存函数入口 `fn`，`gpr.s1` 保存参数 `arg`，`epc` 指向 `kernel_thread_entry`。
- `status` 从当前 `sstatus` 读取后设置 `SSTATUS_SPP` 和 `SSTATUS_SPIE`、清除 `SSTATUS_SIE`：首次 `sret` 返回内核态并打开中断，但构造线程期间保持关中断。
- 以 `clone_flags | CLONE_VM` 调用 `do_fork()`，内核线程的栈参数传 0。

**Case 2（do_fork 失败）**：
- 直接把负错误码返回给调用者，不修改全局状态。

#### do_fork

**Pre-Condition**：
- `current` 指向当前有效进程；`tf` 指向已经构造好的中断帧模板。
- 物理内存分配器和 `kmalloc` 可用。

**Post-Condition**：
- 成功时返回新进程 PID；新 PCB 已设置 `parent`、内核栈、中断帧、上下文、唯一 PID，并已加入 `proc_list` 与对应哈希链，状态为 `PROC_RUNNABLE`。
- 失败时返回负错误码，且不留下占用的 PCB、内核栈或链表节点。

**Case 1（进程数已达上限）**：
- `nr_process >= MAX_PROCESS` 时返回 `-E_NO_FREE_PROC`。

**Case 2（PCB 分配失败）**：
- `alloc_proc()` 返回 `NULL` 时返回 `-E_NO_MEM`。

**Case 3（内核栈分配失败）**：
- `setup_kstack()` 失败时释放刚分配的 PCB，返回 `-E_NO_MEM`。

**Case 4（地址空间处理失败）**：
- `copy_mm()` 失败时释放内核栈和 PCB，返回 `-E_NO_MEM`。

**Case 5（正常创建）**：
- 调用 `copy_thread()` 在新线程内核栈上放置中断帧和首次运行上下文。
- 在关中断的临界区内分配 PID、加入哈希表与 `proc_list`、递增 `nr_process`，保证其他执行流不会看到“有 PID 但尚未挂入链表”或“已挂入链表但 PID 未分配”的中间状态。
- 登记完成后调用 `wakeup_proc()` 把新进程置为就绪态。

**Requirements**：
- 失败路径必须严格配对：哪一步已经成功，就只释放哪些资源。
- 新进程加入 `proc_list` 的顺序要与后续调度器的遍历方式保持一致。

#### copy_thread

**Pre-Condition**：
- `proc->kstack` 已经指向一个完整的、未使用的内核栈。
- `tf` 是调用者提供的模板中断帧。

**Post-Condition**：
- `proc->tf` 指向新内核栈顶部的一块 `struct trapframe` 空间，其内容为模板的副本。
- `proc->context.ra == (uintptr_t)forkret`，`proc->context.sp == (uintptr_t)proc->tf`。
- `proc->tf` 中的 `gpr.a0` 为 0，表示子线程的返回值是 0。

**Case 1（内核线程，`esp == 0`）**：
- `gpr.sp` 设置为 `proc->tf`，使线程第一次运行时使用中断帧下方尚未使用的内核栈空间。

**Case 2（显式指定栈，`esp != 0`）**：
- `gpr.sp` 使用调用者传入的 `esp`。

**Requirements**：
- 中断帧必须放在内核栈顶部而不是覆盖正在使用的栈内容，且地址满足 RISC-V 的栈对齐要求。
- 首次运行链路必须是 `switch_to -> context.ra(forkret) -> forkrets(current->tf) -> __trapret`，不能直接让 `context.ra` 指向 `kernel_thread_entry`。

#### copy_mm

**Pre-Condition**：
- 本实验只创建内核线程，`current->mm == NULL`。

**Post-Condition**：
- 返回 0；`proc->mm` 仍为 `NULL`，不复制也不销毁任何用户地址空间。
- 函数保持完整形态，便于后续实验扩展为用户进程的 `mm` 复制。

**Case 1（当前阶段）**：
- 不执行任何地址空间操作，直接成功返回。

**Requirements**：
- 使用断言明确当前阶段只应处理内核线程，避免后续误以为这里真的复制了用户地址空间。

## module3

### [PROMPT]

在 `code/lab4/lab4_new` 中实现 Lab 4 功能模块三。仅修改 `kern/process/proc.c`、`kern/schedule/sched.c` 和 `kern/process/switch.S` 中标有 `LAB4 function3` 的区域。

直接修改源码。模块二就绪后执行 `make qemu` 和 `make grade`，确认 `initproc` 实际执行到 `init_main`。报告实际验证结果及未完成验证的原因。

### [RELY]

- 模块二负责初始化 `idleproc`、`current` 和 `proc_list`，创建可运行的 `initproc`，并准备首次执行所需的 `context` 和 `trapframe`。
- 调度使用 `PROC_RUNNABLE`、`need_resched`、`runs`、`list_next()` 和 `le2proc()`。临界区使用 `local_intr_save()` 和 `local_intr_restore()`。
- `proc->pgdir` 保存页表根物理地址。Sv39 的 `satp` 写法参考 `enable_paging()`，写入后调用 `flush_tlb()`。

### [GUARANTEE]

保持四个接口的签名和调用约定。调度和切换的关键步骤在关中断状态下执行，各调用在返回时恢复进入前的中断状态。切换后 `current`、页表和寄存器上下文属于同一目标线程。

### [SPECIFICATION]

#### cpu_idle

- **Pre-Condition**：当前线程为已初始化的 `idleproc`。
- **Post-Condition**：持续循环。
- **Case**：`current->need_resched` 为真时调用 `schedule()`，否则继续等待。

#### schedule

- **Pre-Condition**：`current`、`idleproc` 和 `proc_list` 已初始化。
- **Post-Condition**：清除当前线程的 `need_resched`，选中线程的 `runs` 加一。选中不同线程时调用 `proc_run()`。
- **Case**：当前为 `idleproc` 时从链表头开始，否则从当前节点的下一项开始循环扫描。选中首个 `PROC_RUNNABLE` 线程，找不到时选 `idleproc`。

#### proc_run

- **Pre-Condition**：目标线程可运行，页表根和上下文已准备好。
- **Post-Condition**：目标线程接管 CPU。原线程恢复执行后，恢复其进入本函数前的中断状态。
- **Case**：目标等于 `current` 时直接返回。否则在关中断后保存原 `current`、更新 `current`，按 `((uint64_t)SATP_MODE_SV39 << 60) | (proc->pgdir >> RISCV_PGSHIFT)` 写入 `satp`，刷新 TLB 后调用 `switch_to()`。禁用遗留的 `lsatp()` 写法。

#### switch_to

- **Pre-Condition**：`a0`、`a1` 分别指向原线程和目标线程的 `struct context`。
- **Post-Condition**：按结构体布局保存原线程的 `ra`、`sp` 和 `s0–s11`，恢复目标线程的对应寄存器并执行 `ret`。
- **Case**：已运行线程从原调用点继续。新线程经 `forkret → forkrets → __trapret` 恢复至 `kernel_thread_entry`。
