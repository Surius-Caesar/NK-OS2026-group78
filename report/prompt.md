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