## module1

### [PROMPT]

**任务**：实现 Lab3 的 `RESTORE_ALL` 和 `__alltraps`，完成“保存上下文 → 调用 C 语言处理函数 → 恢复上下文 → 按处理后的 Trap frame 恢复执行”的 Trap 处理流程。

**操作要求**：修改实际文件，仅补全 `lab3_new/kern/trap/trapentry.S` 中两处 `lab3 function1 YOUR CODE` 对应的 `RESTORE_ALL` 和 `__alltraps` 实现。保留标记注释；将 `YOUR CODE` 替换为`MY CODE:2413993`。

**输出要求**：完成文件修改后，在 `lab3_new` 下执行 `make obj/kern/trap/trapentry.o`，报告改动和编译结果。

### [RELY]

- `lab3_new/kern/trap/trapentry.S`：已有 `SAVE_ALL`、`__alltraps`、`__trapret` 和 `sret`。
- 现有 Trap frame 布局：以帧首地址为基址，第 `0` 至 `31` 个 `REGBYTES` 槽依次对应 `x0` 至 `x31`，第 `32` 至 `35` 槽依次为 `status`（`sstatus`）、`epc`（`sepc`）、`badvaddr`、`cause`。`SAVE_ALL` 通过 `sscratch` 保存分配帧之前的 `sp` 至第 `2` 槽，随后清零 `sscratch`。RV64 下 `REGBYTES=8`，帧大小为 288 字节。
- `lab3_new/kern/trap/trap.c`：`void trap(struct trapframe *tf)`。
- 工程提供 `LOAD`、`STORE`、`REGBYTES` 汇编宏，RV64 下分别对应 `ld`、`sd`、`8`。RISC-V 调用约定使用 `a0` 传递首参数，调用时 `sp` 须按 16 字节对齐；`sret` 根据 `sepc` 和 `sstatus` 恢复执行位置、特权级及中断状态。

### [GUARANTEE]

必须实现的接口：

```asm
.macro RESTORE_ALL
__alltraps:
```

- `RESTORE_ALL` 与现有 `SAVE_ALL` 的实际布局一致。
- `__alltraps` 将有效的 Trap frame 指针交给 `trap()`，处理完成后衔接已有 `__trapret` 返回流程。
- 修改范围限定为两处模块一待实现区域，保留其余代码、接口和数据布局。

### [SPECIFICATION]

#### RESTORE_ALL

**Pre-Condition**：`sp` 指向由 `SAVE_ALL` 建立的有效 Trap frame，`trap()` 已返回，帧中内容可能已被处理函数合法更新。

**Post-Condition**：可写通用寄存器及返回所需的 `sstatus`、`sepc` 与当前帧一致；`x0` 保持为零，`sp` 恢复为帧中保存的原栈指针，后续可执行 `sret`。

**Case 1**：处理函数未修改帧时，恢复被打断的寄存器状态，后续从帧中记录的执行位置继续运行。

**Case 2**：处理函数合法修改 `epc` 或其他可恢复字段时，使用修改后的值返回。

**Requirements**：正确恢复帧中保存的原 `sp`，在帧访问完成前保持基址有效；临时寄存器最终也须恢复。CSR 恢复范围为 `sstatus`、`sepc`，返回特权级由帧中的 `status` 决定。

#### __alltraps

**Pre-Condition**：处理器进入当前框架的 Trap 入口，内核栈有效且满足调用约定；已有 `SAVE_ALL` 可建立完整 Trap frame。

**Post-Condition**：`trap()` 被调用一次，首参数指向当前 Trap frame；其返回后，`sp` 仍指向该帧，执行流进入 `__trapret`，恢复现场并通过 `sret` 返回。

**Case 1**：发生中断时，C 处理函数能读取完整现场；处理完成后恢复现场并返回。

**Case 2**：发生异常且 C 处理函数更新帧中 `epc` 时，返回流程使用更新后的地址。

**Requirements**：遵守首参数及栈对齐约定，保留入口四字节对齐，保持 Trap frame 完整；中断和异常的具体处理交给 `trap()`。
---

## module2

### [PROMPT]
**任务**：修改 `kern/trap/trap.c`，实现 Lab3 功能模块二中的中断处理 `interrupt_handler()`，使内核能对时钟中断、各类软件/外部中断进行正确分类与处理，并能在处理完成后顺利返回 `__trapret`。

**操作要求**：必须修改项目中的实际文件。仅在 `//lab3 function2 YOUR CODE` 标记处补全 `interrupt_handler()`，并将该注释中的 `YOUR CODE` 替换为 `MY CODE:2413410`。保留其他所有已有函数与代码，不修改函数签名，不修改 `print_ticks()`、`trap_dispatch()`、`trap()` 等规定以外的函数；`exception_handler()` 不在本次任务范围内，不要实现或修改。

**输出要求**：直接进行文件操作，使用下面 [RELY]、[GUARANTEE]、[SPECIFICATION] 的信息，不引入无关功能。

### [RELY]
- `kern/trap/trap.h`：`struct trapframe { struct pushregs gpr; uintptr_t status, epc, badvaddr, cause; }`。
- `tf->cause` 最高位为 1 表示中断，低 63 位为中断原因编号。
- `kern/trap/trap.c` 已有：`#define TICK_NUM 100`、`static void print_ticks()`（输出 `100 ticks`）、`void print_trapframe(struct trapframe *tf)`。
- `libs/riscv.h`：`IRQ_U_SOFT=0`、`IRQ_S_SOFT=1`、`IRQ_M_SOFT=3`、`IRQ_U_TIMER=4`、`IRQ_S_TIMER=5`、`IRQ_M_TIMER=7`、`IRQ_U_EXT=8`、`IRQ_S_EXT=9`、`IRQ_M_EXT=11`。
- `kern/driver/clock.h`：`extern volatile size_t ticks;`、`void clock_set_next_event(void);`。
- `libs/sbi.h`：`void sbi_shutdown(void);`。
- 框架未预定义 `SHUTDOWN_AFTER`，需要在本文件中定义（取 10）。

### [GUARANTEE]
必须实现的接口（位置在 `trap_dispatch()` 之前）：

```c
void interrupt_handler(struct trapframe *tf);
```

可以添加 `static` 辅助变量或文件内宏，不得改变上述签名，不得新增其他对外接口。

### [SPECIFICATION]

#### interrupt_handler

**Pre-Condition**：`tf` 指向 `__alltraps` 保存的完整 Trap frame，`tf->cause` 最高位为 1，低 63 位为中断原因。

**Post-Condition**：对应中断已被处理；返回后 `trap()` 正常返回到 `__trapret`，上下文与 `ticks` 状态一致。

**Case 1（时钟中断 `IRQ_S_TIMER`）**：调用 `clock_set_next_event()` 设置下一次时钟事件；`ticks` 自增 1；当 `ticks % TICK_NUM == 0` 时调用 `print_ticks()` 输出一次统计信息；累计统计输出次数达到 `SHUTDOWN_AFTER` 后调用 `sbi_shutdown()`。

**Case 2（软件中断）**：对 `IRQ_U_SOFT`、`IRQ_S_SOFT`、`IRQ_M_SOFT` 分别输出对应的提示信息，其中 `IRQ_S_SOFT` 必须输出 `Supervisor software interrupt`。

**Case 3（其他可识别的中断）**：对用户/机器时钟中断、用户/监管者/机器外部中断输出对应的提示信息即可，不做额外处理。

**Case 4（无法识别的中断）**：输出 `Unknown interrupt: cause <原因编号>`，并调用 `print_trapframe(tf)` 输出完整 Trap frame。

**Requirements**：`ticks` 每收到一次时钟中断必须自增，且必须先设置下一次时钟事件再返回，否则只能收到一次时钟中断。
