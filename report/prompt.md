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