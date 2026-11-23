
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000a6517          	auipc	a0,0xa6
ffffffffc020004e:	36e50513          	addi	a0,a0,878 # ffffffffc02a63b8 <buf>
ffffffffc0200052:	000ab617          	auipc	a2,0xab
ffffffffc0200056:	81260613          	addi	a2,a2,-2030 # ffffffffc02aa864 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	5cc050ef          	jal	ra,ffffffffc020562e <memset>
    dtb_init();
ffffffffc0200066:	558000ef          	jal	ra,ffffffffc02005be <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	4e2000ef          	jal	ra,ffffffffc020054c <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	5ea58593          	addi	a1,a1,1514 # ffffffffc0205658 <etext>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	60250513          	addi	a0,a0,1538 # ffffffffc0205678 <etext+0x20>
ffffffffc020007e:	116000ef          	jal	ra,ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	15a000ef          	jal	ra,ffffffffc02001dc <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	7f8020ef          	jal	ra,ffffffffc020287e <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0f1000ef          	jal	ra,ffffffffc020097a <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0ef000ef          	jal	ra,ffffffffc020097c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	2ad030ef          	jal	ra,ffffffffc0203b3e <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	3e8040ef          	jal	ra,ffffffffc020447e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	460000ef          	jal	ra,ffffffffc02004fa <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	0d1000ef          	jal	ra,ffffffffc020096e <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	6a9040ef          	jal	ra,ffffffffc0204f4a <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	715d                	addi	sp,sp,-80
ffffffffc02000a8:	e486                	sd	ra,72(sp)
ffffffffc02000aa:	e0a6                	sd	s1,64(sp)
ffffffffc02000ac:	fc4a                	sd	s2,56(sp)
ffffffffc02000ae:	f84e                	sd	s3,48(sp)
ffffffffc02000b0:	f452                	sd	s4,40(sp)
ffffffffc02000b2:	f056                	sd	s5,32(sp)
ffffffffc02000b4:	ec5a                	sd	s6,24(sp)
ffffffffc02000b6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000b8:	c901                	beqz	a0,ffffffffc02000c8 <readline+0x22>
ffffffffc02000ba:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000bc:	00005517          	auipc	a0,0x5
ffffffffc02000c0:	5c450513          	addi	a0,a0,1476 # ffffffffc0205680 <etext+0x28>
ffffffffc02000c4:	0d0000ef          	jal	ra,ffffffffc0200194 <cprintf>
readline(const char *prompt) {
ffffffffc02000c8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ca:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000cc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ce:	4aa9                	li	s5,10
ffffffffc02000d0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000d2:	000a6b97          	auipc	s7,0xa6
ffffffffc02000d6:	2e6b8b93          	addi	s7,s7,742 # ffffffffc02a63b8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000de:	0ee000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000e2:	00054a63          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e6:	00a95a63          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc02000ea:	029a5263          	bge	s4,s1,ffffffffc020010e <readline+0x68>
        c = getchar();
ffffffffc02000ee:	0de000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc02000f2:	fe055ae3          	bgez	a0,ffffffffc02000e6 <readline+0x40>
            return NULL;
ffffffffc02000f6:	4501                	li	a0,0
ffffffffc02000f8:	a091                	j	ffffffffc020013c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000fa:	03351463          	bne	a0,s3,ffffffffc0200122 <readline+0x7c>
ffffffffc02000fe:	e8a9                	bnez	s1,ffffffffc0200150 <readline+0xaa>
        c = getchar();
ffffffffc0200100:	0cc000ef          	jal	ra,ffffffffc02001cc <getchar>
        if (c < 0) {
ffffffffc0200104:	fe0549e3          	bltz	a0,ffffffffc02000f6 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200108:	fea959e3          	bge	s2,a0,ffffffffc02000fa <readline+0x54>
ffffffffc020010c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010e:	e42a                	sd	a0,8(sp)
ffffffffc0200110:	0ba000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i ++] = c;
ffffffffc0200114:	6522                	ld	a0,8(sp)
ffffffffc0200116:	009b87b3          	add	a5,s7,s1
ffffffffc020011a:	2485                	addiw	s1,s1,1
ffffffffc020011c:	00a78023          	sb	a0,0(a5)
ffffffffc0200120:	bf7d                	j	ffffffffc02000de <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200122:	01550463          	beq	a0,s5,ffffffffc020012a <readline+0x84>
ffffffffc0200126:	fb651ce3          	bne	a0,s6,ffffffffc02000de <readline+0x38>
            cputchar(c);
ffffffffc020012a:	0a0000ef          	jal	ra,ffffffffc02001ca <cputchar>
            buf[i] = '\0';
ffffffffc020012e:	000a6517          	auipc	a0,0xa6
ffffffffc0200132:	28a50513          	addi	a0,a0,650 # ffffffffc02a63b8 <buf>
ffffffffc0200136:	94aa                	add	s1,s1,a0
ffffffffc0200138:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020013c:	60a6                	ld	ra,72(sp)
ffffffffc020013e:	6486                	ld	s1,64(sp)
ffffffffc0200140:	7962                	ld	s2,56(sp)
ffffffffc0200142:	79c2                	ld	s3,48(sp)
ffffffffc0200144:	7a22                	ld	s4,40(sp)
ffffffffc0200146:	7a82                	ld	s5,32(sp)
ffffffffc0200148:	6b62                	ld	s6,24(sp)
ffffffffc020014a:	6bc2                	ld	s7,16(sp)
ffffffffc020014c:	6161                	addi	sp,sp,80
ffffffffc020014e:	8082                	ret
            cputchar(c);
ffffffffc0200150:	4521                	li	a0,8
ffffffffc0200152:	078000ef          	jal	ra,ffffffffc02001ca <cputchar>
            i --;
ffffffffc0200156:	34fd                	addiw	s1,s1,-1
ffffffffc0200158:	b759                	j	ffffffffc02000de <readline+0x38>

ffffffffc020015a <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e022                	sd	s0,0(sp)
ffffffffc020015e:	e406                	sd	ra,8(sp)
ffffffffc0200160:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200162:	3ec000ef          	jal	ra,ffffffffc020054e <cons_putc>
    (*cnt)++;
ffffffffc0200166:	401c                	lw	a5,0(s0)
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc020016a:	2785                	addiw	a5,a5,1
ffffffffc020016c:	c01c                	sw	a5,0(s0)
}
ffffffffc020016e:	6402                	ld	s0,0(sp)
ffffffffc0200170:	0141                	addi	sp,sp,16
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe050513          	addi	a0,a0,-32 # ffffffffc020015a <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	082050ef          	jal	ra,ffffffffc020520a <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
{
ffffffffc020019a:	8e2a                	mv	t3,a0
ffffffffc020019c:	f42e                	sd	a1,40(sp)
ffffffffc020019e:	f832                	sd	a2,48(sp)
ffffffffc02001a0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb850513          	addi	a0,a0,-72 # ffffffffc020015a <cputch>
ffffffffc02001aa:	004c                	addi	a1,sp,4
ffffffffc02001ac:	869a                	mv	a3,t1
ffffffffc02001ae:	8672                	mv	a2,t3
{
ffffffffc02001b0:	ec06                	sd	ra,24(sp)
ffffffffc02001b2:	e0ba                	sd	a4,64(sp)
ffffffffc02001b4:	e4be                	sd	a5,72(sp)
ffffffffc02001b6:	e8c2                	sd	a6,80(sp)
ffffffffc02001b8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001be:	04c050ef          	jal	ra,ffffffffc020520a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	4512                	lw	a0,4(sp)
ffffffffc02001c6:	6125                	addi	sp,sp,96
ffffffffc02001c8:	8082                	ret

ffffffffc02001ca <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001ca:	a651                	j	ffffffffc020054e <cons_putc>

ffffffffc02001cc <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc02001cc:	1141                	addi	sp,sp,-16
ffffffffc02001ce:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001d0:	3b2000ef          	jal	ra,ffffffffc0200582 <cons_getc>
ffffffffc02001d4:	dd75                	beqz	a0,ffffffffc02001d0 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
ffffffffc02001d8:	0141                	addi	sp,sp,16
ffffffffc02001da:	8082                	ret

ffffffffc02001dc <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02001dc:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001de:	00005517          	auipc	a0,0x5
ffffffffc02001e2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205688 <etext+0x30>
{
ffffffffc02001e6:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e8:	fadff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001ec:	00000597          	auipc	a1,0x0
ffffffffc02001f0:	e5e58593          	addi	a1,a1,-418 # ffffffffc020004a <kern_init>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	4b450513          	addi	a0,a0,1204 # ffffffffc02056a8 <etext+0x50>
ffffffffc02001fc:	f99ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200200:	00005597          	auipc	a1,0x5
ffffffffc0200204:	45858593          	addi	a1,a1,1112 # ffffffffc0205658 <etext>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	4c050513          	addi	a0,a0,1216 # ffffffffc02056c8 <etext+0x70>
ffffffffc0200210:	f85ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200214:	000a6597          	auipc	a1,0xa6
ffffffffc0200218:	1a458593          	addi	a1,a1,420 # ffffffffc02a63b8 <buf>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	4cc50513          	addi	a0,a0,1228 # ffffffffc02056e8 <etext+0x90>
ffffffffc0200224:	f71ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200228:	000aa597          	auipc	a1,0xaa
ffffffffc020022c:	63c58593          	addi	a1,a1,1596 # ffffffffc02aa864 <end>
ffffffffc0200230:	00005517          	auipc	a0,0x5
ffffffffc0200234:	4d850513          	addi	a0,a0,1240 # ffffffffc0205708 <etext+0xb0>
ffffffffc0200238:	f5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020023c:	000ab597          	auipc	a1,0xab
ffffffffc0200240:	a2758593          	addi	a1,a1,-1497 # ffffffffc02aac63 <end+0x3ff>
ffffffffc0200244:	00000797          	auipc	a5,0x0
ffffffffc0200248:	e0678793          	addi	a5,a5,-506 # ffffffffc020004a <kern_init>
ffffffffc020024c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200254:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200256:	3ff5f593          	andi	a1,a1,1023
ffffffffc020025a:	95be                	add	a1,a1,a5
ffffffffc020025c:	85a9                	srai	a1,a1,0xa
ffffffffc020025e:	00005517          	auipc	a0,0x5
ffffffffc0200262:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205728 <etext+0xd0>
}
ffffffffc0200266:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200268:	b735                	j	ffffffffc0200194 <cprintf>

ffffffffc020026a <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc020026a:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020026c:	00005617          	auipc	a2,0x5
ffffffffc0200270:	4ec60613          	addi	a2,a2,1260 # ffffffffc0205758 <etext+0x100>
ffffffffc0200274:	04f00593          	li	a1,79
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	4f850513          	addi	a0,a0,1272 # ffffffffc0205770 <etext+0x118>
{
ffffffffc0200280:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200282:	1cc000ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0200286 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200286:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200288:	00005617          	auipc	a2,0x5
ffffffffc020028c:	50060613          	addi	a2,a2,1280 # ffffffffc0205788 <etext+0x130>
ffffffffc0200290:	00005597          	auipc	a1,0x5
ffffffffc0200294:	51858593          	addi	a1,a1,1304 # ffffffffc02057a8 <etext+0x150>
ffffffffc0200298:	00005517          	auipc	a0,0x5
ffffffffc020029c:	51850513          	addi	a0,a0,1304 # ffffffffc02057b0 <etext+0x158>
{
ffffffffc02002a0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002a2:	ef3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002a6:	00005617          	auipc	a2,0x5
ffffffffc02002aa:	51a60613          	addi	a2,a2,1306 # ffffffffc02057c0 <etext+0x168>
ffffffffc02002ae:	00005597          	auipc	a1,0x5
ffffffffc02002b2:	53a58593          	addi	a1,a1,1338 # ffffffffc02057e8 <etext+0x190>
ffffffffc02002b6:	00005517          	auipc	a0,0x5
ffffffffc02002ba:	4fa50513          	addi	a0,a0,1274 # ffffffffc02057b0 <etext+0x158>
ffffffffc02002be:	ed7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc02002c2:	00005617          	auipc	a2,0x5
ffffffffc02002c6:	53660613          	addi	a2,a2,1334 # ffffffffc02057f8 <etext+0x1a0>
ffffffffc02002ca:	00005597          	auipc	a1,0x5
ffffffffc02002ce:	54e58593          	addi	a1,a1,1358 # ffffffffc0205818 <etext+0x1c0>
ffffffffc02002d2:	00005517          	auipc	a0,0x5
ffffffffc02002d6:	4de50513          	addi	a0,a0,1246 # ffffffffc02057b0 <etext+0x158>
ffffffffc02002da:	ebbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    return 0;
}
ffffffffc02002de:	60a2                	ld	ra,8(sp)
ffffffffc02002e0:	4501                	li	a0,0
ffffffffc02002e2:	0141                	addi	sp,sp,16
ffffffffc02002e4:	8082                	ret

ffffffffc02002e6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002e6:	1141                	addi	sp,sp,-16
ffffffffc02002e8:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ea:	ef3ff0ef          	jal	ra,ffffffffc02001dc <print_kerninfo>
    return 0;
}
ffffffffc02002ee:	60a2                	ld	ra,8(sp)
ffffffffc02002f0:	4501                	li	a0,0
ffffffffc02002f2:	0141                	addi	sp,sp,16
ffffffffc02002f4:	8082                	ret

ffffffffc02002f6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002f6:	1141                	addi	sp,sp,-16
ffffffffc02002f8:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002fa:	f71ff0ef          	jal	ra,ffffffffc020026a <print_stackframe>
    return 0;
}
ffffffffc02002fe:	60a2                	ld	ra,8(sp)
ffffffffc0200300:	4501                	li	a0,0
ffffffffc0200302:	0141                	addi	sp,sp,16
ffffffffc0200304:	8082                	ret

ffffffffc0200306 <kmonitor>:
{
ffffffffc0200306:	7115                	addi	sp,sp,-224
ffffffffc0200308:	ed5e                	sd	s7,152(sp)
ffffffffc020030a:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020030c:	00005517          	auipc	a0,0x5
ffffffffc0200310:	51c50513          	addi	a0,a0,1308 # ffffffffc0205828 <etext+0x1d0>
{
ffffffffc0200314:	ed86                	sd	ra,216(sp)
ffffffffc0200316:	e9a2                	sd	s0,208(sp)
ffffffffc0200318:	e5a6                	sd	s1,200(sp)
ffffffffc020031a:	e1ca                	sd	s2,192(sp)
ffffffffc020031c:	fd4e                	sd	s3,184(sp)
ffffffffc020031e:	f952                	sd	s4,176(sp)
ffffffffc0200320:	f556                	sd	s5,168(sp)
ffffffffc0200322:	f15a                	sd	s6,160(sp)
ffffffffc0200324:	e962                	sd	s8,144(sp)
ffffffffc0200326:	e566                	sd	s9,136(sp)
ffffffffc0200328:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020032a:	e6bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	52250513          	addi	a0,a0,1314 # ffffffffc0205850 <etext+0x1f8>
ffffffffc0200336:	e5fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc020033a:	000b8563          	beqz	s7,ffffffffc0200344 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033e:	855e                	mv	a0,s7
ffffffffc0200340:	025000ef          	jal	ra,ffffffffc0200b64 <print_trapframe>
ffffffffc0200344:	00005c17          	auipc	s8,0x5
ffffffffc0200348:	57cc0c13          	addi	s8,s8,1404 # ffffffffc02058c0 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020034c:	00005917          	auipc	s2,0x5
ffffffffc0200350:	52c90913          	addi	s2,s2,1324 # ffffffffc0205878 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200354:	00005497          	auipc	s1,0x5
ffffffffc0200358:	52c48493          	addi	s1,s1,1324 # ffffffffc0205880 <etext+0x228>
        if (argc == MAXARGS - 1)
ffffffffc020035c:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035e:	00005b17          	auipc	s6,0x5
ffffffffc0200362:	52ab0b13          	addi	s6,s6,1322 # ffffffffc0205888 <etext+0x230>
        argv[argc++] = buf;
ffffffffc0200366:	00005a17          	auipc	s4,0x5
ffffffffc020036a:	442a0a13          	addi	s4,s4,1090 # ffffffffc02057a8 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020036e:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200370:	854a                	mv	a0,s2
ffffffffc0200372:	d35ff0ef          	jal	ra,ffffffffc02000a6 <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	dd65                	beqz	a0,ffffffffc0200370 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020037e:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200380:	e1bd                	bnez	a1,ffffffffc02003e6 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc0200382:	fe0c87e3          	beqz	s9,ffffffffc0200370 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200386:	6582                	ld	a1,0(sp)
ffffffffc0200388:	00005d17          	auipc	s10,0x5
ffffffffc020038c:	538d0d13          	addi	s10,s10,1336 # ffffffffc02058c0 <commands>
        argv[argc++] = buf;
ffffffffc0200390:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200392:	4401                	li	s0,0
ffffffffc0200394:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200396:	23e050ef          	jal	ra,ffffffffc02055d4 <strcmp>
ffffffffc020039a:	c919                	beqz	a0,ffffffffc02003b0 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020039c:	2405                	addiw	s0,s0,1
ffffffffc020039e:	0b540063          	beq	s0,s5,ffffffffc020043e <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003a2:	000d3503          	ld	a0,0(s10)
ffffffffc02003a6:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003a8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc02003aa:	22a050ef          	jal	ra,ffffffffc02055d4 <strcmp>
ffffffffc02003ae:	f57d                	bnez	a0,ffffffffc020039c <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003b0:	00141793          	slli	a5,s0,0x1
ffffffffc02003b4:	97a2                	add	a5,a5,s0
ffffffffc02003b6:	078e                	slli	a5,a5,0x3
ffffffffc02003b8:	97e2                	add	a5,a5,s8
ffffffffc02003ba:	6b9c                	ld	a5,16(a5)
ffffffffc02003bc:	865e                	mv	a2,s7
ffffffffc02003be:	002c                	addi	a1,sp,8
ffffffffc02003c0:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003c4:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc02003c6:	fa0555e3          	bgez	a0,ffffffffc0200370 <kmonitor+0x6a>
}
ffffffffc02003ca:	60ee                	ld	ra,216(sp)
ffffffffc02003cc:	644e                	ld	s0,208(sp)
ffffffffc02003ce:	64ae                	ld	s1,200(sp)
ffffffffc02003d0:	690e                	ld	s2,192(sp)
ffffffffc02003d2:	79ea                	ld	s3,184(sp)
ffffffffc02003d4:	7a4a                	ld	s4,176(sp)
ffffffffc02003d6:	7aaa                	ld	s5,168(sp)
ffffffffc02003d8:	7b0a                	ld	s6,160(sp)
ffffffffc02003da:	6bea                	ld	s7,152(sp)
ffffffffc02003dc:	6c4a                	ld	s8,144(sp)
ffffffffc02003de:	6caa                	ld	s9,136(sp)
ffffffffc02003e0:	6d0a                	ld	s10,128(sp)
ffffffffc02003e2:	612d                	addi	sp,sp,224
ffffffffc02003e4:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003e6:	8526                	mv	a0,s1
ffffffffc02003e8:	230050ef          	jal	ra,ffffffffc0205618 <strchr>
ffffffffc02003ec:	c901                	beqz	a0,ffffffffc02003fc <kmonitor+0xf6>
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02003f2:	00040023          	sb	zero,0(s0)
ffffffffc02003f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003f8:	d5c9                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc02003fa:	b7f5                	j	ffffffffc02003e6 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc02003fc:	00044783          	lbu	a5,0(s0)
ffffffffc0200400:	d3c9                	beqz	a5,ffffffffc0200382 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc0200402:	033c8963          	beq	s9,s3,ffffffffc0200434 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc0200406:	003c9793          	slli	a5,s9,0x3
ffffffffc020040a:	0118                	addi	a4,sp,128
ffffffffc020040c:	97ba                	add	a5,a5,a4
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200416:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0x11e>
ffffffffc020041a:	b7b5                	j	ffffffffc0200386 <kmonitor+0x80>
ffffffffc020041c:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200422:	d1a5                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc0200424:	8526                	mv	a0,s1
ffffffffc0200426:	1f2050ef          	jal	ra,ffffffffc0205618 <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	d9a9                	beqz	a1,ffffffffc0200382 <kmonitor+0x7c>
ffffffffc0200432:	bf55                	j	ffffffffc02003e6 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200434:	45c1                	li	a1,16
ffffffffc0200436:	855a                	mv	a0,s6
ffffffffc0200438:	d5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc020043c:	b7e9                	j	ffffffffc0200406 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020043e:	6582                	ld	a1,0(sp)
ffffffffc0200440:	00005517          	auipc	a0,0x5
ffffffffc0200444:	46850513          	addi	a0,a0,1128 # ffffffffc02058a8 <etext+0x250>
ffffffffc0200448:	d4dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
ffffffffc020044c:	b715                	j	ffffffffc0200370 <kmonitor+0x6a>

ffffffffc020044e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020044e:	000aa317          	auipc	t1,0xaa
ffffffffc0200452:	39230313          	addi	t1,t1,914 # ffffffffc02aa7e0 <is_panic>
ffffffffc0200456:	00033e03          	ld	t3,0(t1)
{
ffffffffc020045a:	715d                	addi	sp,sp,-80
ffffffffc020045c:	ec06                	sd	ra,24(sp)
ffffffffc020045e:	e822                	sd	s0,16(sp)
ffffffffc0200460:	f436                	sd	a3,40(sp)
ffffffffc0200462:	f83a                	sd	a4,48(sp)
ffffffffc0200464:	fc3e                	sd	a5,56(sp)
ffffffffc0200466:	e0c2                	sd	a6,64(sp)
ffffffffc0200468:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020046a:	020e1a63          	bnez	t3,ffffffffc020049e <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020046e:	4785                	li	a5,1
ffffffffc0200470:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200474:	8432                	mv	s0,a2
ffffffffc0200476:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200478:	862e                	mv	a2,a1
ffffffffc020047a:	85aa                	mv	a1,a0
ffffffffc020047c:	00005517          	auipc	a0,0x5
ffffffffc0200480:	48c50513          	addi	a0,a0,1164 # ffffffffc0205908 <commands+0x48>
    va_start(ap, fmt);
ffffffffc0200484:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200486:	d0fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020048a:	65a2                	ld	a1,8(sp)
ffffffffc020048c:	8522                	mv	a0,s0
ffffffffc020048e:	ce7ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc0200492:	00006517          	auipc	a0,0x6
ffffffffc0200496:	4d650513          	addi	a0,a0,1238 # ffffffffc0206968 <default_pmm_manager+0x5b0>
ffffffffc020049a:	cfbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020049e:	4501                	li	a0,0
ffffffffc02004a0:	4581                	li	a1,0
ffffffffc02004a2:	4601                	li	a2,0
ffffffffc02004a4:	48a1                	li	a7,8
ffffffffc02004a6:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004aa:	4ca000ef          	jal	ra,ffffffffc0200974 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004ae:	4501                	li	a0,0
ffffffffc02004b0:	e57ff0ef          	jal	ra,ffffffffc0200306 <kmonitor>
    while (1)
ffffffffc02004b4:	bfed                	j	ffffffffc02004ae <__panic+0x60>

ffffffffc02004b6 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004b6:	715d                	addi	sp,sp,-80
ffffffffc02004b8:	832e                	mv	t1,a1
ffffffffc02004ba:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004bc:	85aa                	mv	a1,a0
{
ffffffffc02004be:	8432                	mv	s0,a2
ffffffffc02004c0:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004c2:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004c4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004c6:	00005517          	auipc	a0,0x5
ffffffffc02004ca:	46250513          	addi	a0,a0,1122 # ffffffffc0205928 <commands+0x68>
{
ffffffffc02004ce:	ec06                	sd	ra,24(sp)
ffffffffc02004d0:	f436                	sd	a3,40(sp)
ffffffffc02004d2:	f83a                	sd	a4,48(sp)
ffffffffc02004d4:	e0c2                	sd	a6,64(sp)
ffffffffc02004d6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004d8:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004da:	cbbff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004de:	65a2                	ld	a1,8(sp)
ffffffffc02004e0:	8522                	mv	a0,s0
ffffffffc02004e2:	c93ff0ef          	jal	ra,ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004e6:	00006517          	auipc	a0,0x6
ffffffffc02004ea:	48250513          	addi	a0,a0,1154 # ffffffffc0206968 <default_pmm_manager+0x5b0>
ffffffffc02004ee:	ca7ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc02004f2:	60e2                	ld	ra,24(sp)
ffffffffc02004f4:	6442                	ld	s0,16(sp)
ffffffffc02004f6:	6161                	addi	sp,sp,80
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004fa:	67e1                	lui	a5,0x18
ffffffffc02004fc:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd570>
ffffffffc0200500:	000aa717          	auipc	a4,0xaa
ffffffffc0200504:	2ef73823          	sd	a5,752(a4) # ffffffffc02aa7f0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200508:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050c:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020050e:	953e                	add	a0,a0,a5
ffffffffc0200510:	4601                	li	a2,0
ffffffffc0200512:	4881                	li	a7,0
ffffffffc0200514:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200518:	02000793          	li	a5,32
ffffffffc020051c:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200520:	00005517          	auipc	a0,0x5
ffffffffc0200524:	42850513          	addi	a0,a0,1064 # ffffffffc0205948 <commands+0x88>
    ticks = 0;
ffffffffc0200528:	000aa797          	auipc	a5,0xaa
ffffffffc020052c:	2c07b023          	sd	zero,704(a5) # ffffffffc02aa7e8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200530:	b195                	j	ffffffffc0200194 <cprintf>

ffffffffc0200532 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200532:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200536:	000aa797          	auipc	a5,0xaa
ffffffffc020053a:	2ba7b783          	ld	a5,698(a5) # ffffffffc02aa7f0 <timebase>
ffffffffc020053e:	953e                	add	a0,a0,a5
ffffffffc0200540:	4581                	li	a1,0
ffffffffc0200542:	4601                	li	a2,0
ffffffffc0200544:	4881                	li	a7,0
ffffffffc0200546:	00000073          	ecall
ffffffffc020054a:	8082                	ret

ffffffffc020054c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020054c:	8082                	ret

ffffffffc020054e <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020054e:	100027f3          	csrr	a5,sstatus
ffffffffc0200552:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200554:	0ff57513          	zext.b	a0,a0
ffffffffc0200558:	e799                	bnez	a5,ffffffffc0200566 <cons_putc+0x18>
ffffffffc020055a:	4581                	li	a1,0
ffffffffc020055c:	4601                	li	a2,0
ffffffffc020055e:	4885                	li	a7,1
ffffffffc0200560:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc0200564:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200566:	1101                	addi	sp,sp,-32
ffffffffc0200568:	ec06                	sd	ra,24(sp)
ffffffffc020056a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020056c:	408000ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0200570:	6522                	ld	a0,8(sp)
ffffffffc0200572:	4581                	li	a1,0
ffffffffc0200574:	4601                	li	a2,0
ffffffffc0200576:	4885                	li	a7,1
ffffffffc0200578:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020057c:	60e2                	ld	ra,24(sp)
ffffffffc020057e:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc0200580:	a6fd                	j	ffffffffc020096e <intr_enable>

ffffffffc0200582 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200582:	100027f3          	csrr	a5,sstatus
ffffffffc0200586:	8b89                	andi	a5,a5,2
ffffffffc0200588:	eb89                	bnez	a5,ffffffffc020059a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020058a:	4501                	li	a0,0
ffffffffc020058c:	4581                	li	a1,0
ffffffffc020058e:	4601                	li	a2,0
ffffffffc0200590:	4889                	li	a7,2
ffffffffc0200592:	00000073          	ecall
ffffffffc0200596:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200598:	8082                	ret
int cons_getc(void) {
ffffffffc020059a:	1101                	addi	sp,sp,-32
ffffffffc020059c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020059e:	3d6000ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc02005a2:	4501                	li	a0,0
ffffffffc02005a4:	4581                	li	a1,0
ffffffffc02005a6:	4601                	li	a2,0
ffffffffc02005a8:	4889                	li	a7,2
ffffffffc02005aa:	00000073          	ecall
ffffffffc02005ae:	2501                	sext.w	a0,a0
ffffffffc02005b0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005b2:	3bc000ef          	jal	ra,ffffffffc020096e <intr_enable>
}
ffffffffc02005b6:	60e2                	ld	ra,24(sp)
ffffffffc02005b8:	6522                	ld	a0,8(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005be:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02005c0:	00005517          	auipc	a0,0x5
ffffffffc02005c4:	3a850513          	addi	a0,a0,936 # ffffffffc0205968 <commands+0xa8>
void dtb_init(void) {
ffffffffc02005c8:	fc86                	sd	ra,120(sp)
ffffffffc02005ca:	f8a2                	sd	s0,112(sp)
ffffffffc02005cc:	e8d2                	sd	s4,80(sp)
ffffffffc02005ce:	f4a6                	sd	s1,104(sp)
ffffffffc02005d0:	f0ca                	sd	s2,96(sp)
ffffffffc02005d2:	ecce                	sd	s3,88(sp)
ffffffffc02005d4:	e4d6                	sd	s5,72(sp)
ffffffffc02005d6:	e0da                	sd	s6,64(sp)
ffffffffc02005d8:	fc5e                	sd	s7,56(sp)
ffffffffc02005da:	f862                	sd	s8,48(sp)
ffffffffc02005dc:	f466                	sd	s9,40(sp)
ffffffffc02005de:	f06a                	sd	s10,32(sp)
ffffffffc02005e0:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02005e2:	bb3ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005e6:	0000b597          	auipc	a1,0xb
ffffffffc02005ea:	a1a5b583          	ld	a1,-1510(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc02005ee:	00005517          	auipc	a0,0x5
ffffffffc02005f2:	38a50513          	addi	a0,a0,906 # ffffffffc0205978 <commands+0xb8>
ffffffffc02005f6:	b9fff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005fa:	0000b417          	auipc	s0,0xb
ffffffffc02005fe:	a0e40413          	addi	s0,s0,-1522 # ffffffffc020b008 <boot_dtb>
ffffffffc0200602:	600c                	ld	a1,0(s0)
ffffffffc0200604:	00005517          	auipc	a0,0x5
ffffffffc0200608:	38450513          	addi	a0,a0,900 # ffffffffc0205988 <commands+0xc8>
ffffffffc020060c:	b89ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200610:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200614:	00005517          	auipc	a0,0x5
ffffffffc0200618:	38c50513          	addi	a0,a0,908 # ffffffffc02059a0 <commands+0xe0>
    if (boot_dtb == 0) {
ffffffffc020061c:	120a0463          	beqz	s4,ffffffffc0200744 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200620:	57f5                	li	a5,-3
ffffffffc0200622:	07fa                	slli	a5,a5,0x1e
ffffffffc0200624:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200628:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020062a:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020062e:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200630:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200634:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200638:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063c:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200640:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200644:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200646:	8ec9                	or	a3,a3,a0
ffffffffc0200648:	0087979b          	slliw	a5,a5,0x8
ffffffffc020064c:	1b7d                	addi	s6,s6,-1
ffffffffc020064e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200652:	8dd5                	or	a1,a1,a3
ffffffffc0200654:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200656:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065a:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc020065c:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe35689>
ffffffffc0200660:	10f59163          	bne	a1,a5,ffffffffc0200762 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200664:	471c                	lw	a5,8(a4)
ffffffffc0200666:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200668:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020066e:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200672:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200676:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067a:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067e:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200682:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200686:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068a:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020068e:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200692:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200694:	01146433          	or	s0,s0,a7
ffffffffc0200698:	0086969b          	slliw	a3,a3,0x8
ffffffffc020069c:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a0:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006a2:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006a6:	8c49                	or	s0,s0,a0
ffffffffc02006a8:	0166f6b3          	and	a3,a3,s6
ffffffffc02006ac:	00ca6a33          	or	s4,s4,a2
ffffffffc02006b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02006b4:	8c55                	or	s0,s0,a3
ffffffffc02006b6:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006ba:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006bc:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006be:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006c0:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02006c4:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02006c6:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c8:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02006cc:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006ce:	00005917          	auipc	s2,0x5
ffffffffc02006d2:	32290913          	addi	s2,s2,802 # ffffffffc02059f0 <commands+0x130>
ffffffffc02006d6:	49bd                	li	s3,15
        switch (token) {
ffffffffc02006d8:	4d91                	li	s11,4
ffffffffc02006da:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006dc:	00005497          	auipc	s1,0x5
ffffffffc02006e0:	30c48493          	addi	s1,s1,780 # ffffffffc02059e8 <commands+0x128>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006e4:	000a2703          	lw	a4,0(s4)
ffffffffc02006e8:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ec:	0087569b          	srliw	a3,a4,0x8
ffffffffc02006f0:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006f4:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006f8:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006fc:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200700:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200702:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200706:	0087171b          	slliw	a4,a4,0x8
ffffffffc020070a:	8fd5                	or	a5,a5,a3
ffffffffc020070c:	00eb7733          	and	a4,s6,a4
ffffffffc0200710:	8fd9                	or	a5,a5,a4
ffffffffc0200712:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200714:	09778c63          	beq	a5,s7,ffffffffc02007ac <dtb_init+0x1ee>
ffffffffc0200718:	00fbea63          	bltu	s7,a5,ffffffffc020072c <dtb_init+0x16e>
ffffffffc020071c:	07a78663          	beq	a5,s10,ffffffffc0200788 <dtb_init+0x1ca>
ffffffffc0200720:	4709                	li	a4,2
ffffffffc0200722:	00e79763          	bne	a5,a4,ffffffffc0200730 <dtb_init+0x172>
ffffffffc0200726:	4c81                	li	s9,0
ffffffffc0200728:	8a56                	mv	s4,s5
ffffffffc020072a:	bf6d                	j	ffffffffc02006e4 <dtb_init+0x126>
ffffffffc020072c:	ffb78ee3          	beq	a5,s11,ffffffffc0200728 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200730:	00005517          	auipc	a0,0x5
ffffffffc0200734:	33850513          	addi	a0,a0,824 # ffffffffc0205a68 <commands+0x1a8>
ffffffffc0200738:	a5dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020073c:	00005517          	auipc	a0,0x5
ffffffffc0200740:	36450513          	addi	a0,a0,868 # ffffffffc0205aa0 <commands+0x1e0>
}
ffffffffc0200744:	7446                	ld	s0,112(sp)
ffffffffc0200746:	70e6                	ld	ra,120(sp)
ffffffffc0200748:	74a6                	ld	s1,104(sp)
ffffffffc020074a:	7906                	ld	s2,96(sp)
ffffffffc020074c:	69e6                	ld	s3,88(sp)
ffffffffc020074e:	6a46                	ld	s4,80(sp)
ffffffffc0200750:	6aa6                	ld	s5,72(sp)
ffffffffc0200752:	6b06                	ld	s6,64(sp)
ffffffffc0200754:	7be2                	ld	s7,56(sp)
ffffffffc0200756:	7c42                	ld	s8,48(sp)
ffffffffc0200758:	7ca2                	ld	s9,40(sp)
ffffffffc020075a:	7d02                	ld	s10,32(sp)
ffffffffc020075c:	6de2                	ld	s11,24(sp)
ffffffffc020075e:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc0200760:	bc15                	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200762:	7446                	ld	s0,112(sp)
ffffffffc0200764:	70e6                	ld	ra,120(sp)
ffffffffc0200766:	74a6                	ld	s1,104(sp)
ffffffffc0200768:	7906                	ld	s2,96(sp)
ffffffffc020076a:	69e6                	ld	s3,88(sp)
ffffffffc020076c:	6a46                	ld	s4,80(sp)
ffffffffc020076e:	6aa6                	ld	s5,72(sp)
ffffffffc0200770:	6b06                	ld	s6,64(sp)
ffffffffc0200772:	7be2                	ld	s7,56(sp)
ffffffffc0200774:	7c42                	ld	s8,48(sp)
ffffffffc0200776:	7ca2                	ld	s9,40(sp)
ffffffffc0200778:	7d02                	ld	s10,32(sp)
ffffffffc020077a:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	24450513          	addi	a0,a0,580 # ffffffffc02059c0 <commands+0x100>
}
ffffffffc0200784:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200786:	b439                	j	ffffffffc0200194 <cprintf>
                int name_len = strlen(name);
ffffffffc0200788:	8556                	mv	a0,s5
ffffffffc020078a:	603040ef          	jal	ra,ffffffffc020558c <strlen>
ffffffffc020078e:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200790:	4619                	li	a2,6
ffffffffc0200792:	85a6                	mv	a1,s1
ffffffffc0200794:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200796:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200798:	65b040ef          	jal	ra,ffffffffc02055f2 <strncmp>
ffffffffc020079c:	e111                	bnez	a0,ffffffffc02007a0 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc020079e:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02007a0:	0a91                	addi	s5,s5,4
ffffffffc02007a2:	9ad2                	add	s5,s5,s4
ffffffffc02007a4:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007a8:	8a56                	mv	s4,s5
ffffffffc02007aa:	bf2d                	j	ffffffffc02006e4 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007ac:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007b0:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007b4:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02007b8:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007bc:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c0:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c4:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007c8:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007cc:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007d4:	00eaeab3          	or	s5,s5,a4
ffffffffc02007d8:	00fb77b3          	and	a5,s6,a5
ffffffffc02007dc:	00faeab3          	or	s5,s5,a5
ffffffffc02007e0:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007e2:	000c9c63          	bnez	s9,ffffffffc02007fa <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02007e6:	1a82                	slli	s5,s5,0x20
ffffffffc02007e8:	00368793          	addi	a5,a3,3
ffffffffc02007ec:	020ada93          	srli	s5,s5,0x20
ffffffffc02007f0:	9abe                	add	s5,s5,a5
ffffffffc02007f2:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02007f6:	8a56                	mv	s4,s5
ffffffffc02007f8:	b5f5                	j	ffffffffc02006e4 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02007fa:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007fe:	85ca                	mv	a1,s2
ffffffffc0200800:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200802:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200806:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080a:	0187971b          	slliw	a4,a5,0x18
ffffffffc020080e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200812:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200816:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200818:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020081c:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200820:	8d59                	or	a0,a0,a4
ffffffffc0200822:	00fb77b3          	and	a5,s6,a5
ffffffffc0200826:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200828:	1502                	slli	a0,a0,0x20
ffffffffc020082a:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020082c:	9522                	add	a0,a0,s0
ffffffffc020082e:	5a7040ef          	jal	ra,ffffffffc02055d4 <strcmp>
ffffffffc0200832:	66a2                	ld	a3,8(sp)
ffffffffc0200834:	f94d                	bnez	a0,ffffffffc02007e6 <dtb_init+0x228>
ffffffffc0200836:	fb59f8e3          	bgeu	s3,s5,ffffffffc02007e6 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020083a:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020083e:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	1b650513          	addi	a0,a0,438 # ffffffffc02059f8 <commands+0x138>
           fdt32_to_cpu(x >> 32);
ffffffffc020084a:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084e:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200852:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0187de1b          	srliw	t3,a5,0x18
ffffffffc020085a:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085e:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200862:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200866:	0187d693          	srli	a3,a5,0x18
ffffffffc020086a:	01861f1b          	slliw	t5,a2,0x18
ffffffffc020086e:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200872:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200876:	0106561b          	srliw	a2,a2,0x10
ffffffffc020087a:	010f6f33          	or	t5,t5,a6
ffffffffc020087e:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200882:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200886:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020088a:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020088e:	0186f6b3          	and	a3,a3,s8
ffffffffc0200892:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200896:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020089a:	0107581b          	srliw	a6,a4,0x10
ffffffffc020089e:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008a2:	8361                	srli	a4,a4,0x18
ffffffffc02008a4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008a8:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02008ac:	01e6e6b3          	or	a3,a3,t5
ffffffffc02008b0:	00cb7633          	and	a2,s6,a2
ffffffffc02008b4:	0088181b          	slliw	a6,a6,0x8
ffffffffc02008b8:	0085959b          	slliw	a1,a1,0x8
ffffffffc02008bc:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c0:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008c4:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02008c8:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02008cc:	0088989b          	slliw	a7,a7,0x8
ffffffffc02008d0:	011b78b3          	and	a7,s6,a7
ffffffffc02008d4:	005eeeb3          	or	t4,t4,t0
ffffffffc02008d8:	00c6e733          	or	a4,a3,a2
ffffffffc02008dc:	006c6c33          	or	s8,s8,t1
ffffffffc02008e0:	010b76b3          	and	a3,s6,a6
ffffffffc02008e4:	00bb7b33          	and	s6,s6,a1
ffffffffc02008e8:	01d7e7b3          	or	a5,a5,t4
ffffffffc02008ec:	016c6b33          	or	s6,s8,s6
ffffffffc02008f0:	01146433          	or	s0,s0,a7
ffffffffc02008f4:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02008f6:	1702                	slli	a4,a4,0x20
ffffffffc02008f8:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008fa:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02008fc:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02008fe:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200900:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200904:	0167eb33          	or	s6,a5,s6
ffffffffc0200908:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020090a:	88bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020090e:	85a2                	mv	a1,s0
ffffffffc0200910:	00005517          	auipc	a0,0x5
ffffffffc0200914:	10850513          	addi	a0,a0,264 # ffffffffc0205a18 <commands+0x158>
ffffffffc0200918:	87dff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020091c:	014b5613          	srli	a2,s6,0x14
ffffffffc0200920:	85da                	mv	a1,s6
ffffffffc0200922:	00005517          	auipc	a0,0x5
ffffffffc0200926:	10e50513          	addi	a0,a0,270 # ffffffffc0205a30 <commands+0x170>
ffffffffc020092a:	86bff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020092e:	008b05b3          	add	a1,s6,s0
ffffffffc0200932:	15fd                	addi	a1,a1,-1
ffffffffc0200934:	00005517          	auipc	a0,0x5
ffffffffc0200938:	11c50513          	addi	a0,a0,284 # ffffffffc0205a50 <commands+0x190>
ffffffffc020093c:	859ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	16050513          	addi	a0,a0,352 # ffffffffc0205aa0 <commands+0x1e0>
        memory_base = mem_base;
ffffffffc0200948:	000aa797          	auipc	a5,0xaa
ffffffffc020094c:	ea87b823          	sd	s0,-336(a5) # ffffffffc02aa7f8 <memory_base>
        memory_size = mem_size;
ffffffffc0200950:	000aa797          	auipc	a5,0xaa
ffffffffc0200954:	eb67b823          	sd	s6,-336(a5) # ffffffffc02aa800 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200958:	b3f5                	j	ffffffffc0200744 <dtb_init+0x186>

ffffffffc020095a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020095a:	000aa517          	auipc	a0,0xaa
ffffffffc020095e:	e9e53503          	ld	a0,-354(a0) # ffffffffc02aa7f8 <memory_base>
ffffffffc0200962:	8082                	ret

ffffffffc0200964 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200964:	000aa517          	auipc	a0,0xaa
ffffffffc0200968:	e9c53503          	ld	a0,-356(a0) # ffffffffc02aa800 <memory_size>
ffffffffc020096c:	8082                	ret

ffffffffc020096e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020096e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200972:	8082                	ret

ffffffffc0200974 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200974:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200978:	8082                	ret

ffffffffc020097a <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020097a:	8082                	ret

ffffffffc020097c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020097c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200980:	00000797          	auipc	a5,0x0
ffffffffc0200984:	4bc78793          	addi	a5,a5,1212 # ffffffffc0200e3c <__alltraps>
ffffffffc0200988:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020098c:	000407b7          	lui	a5,0x40
ffffffffc0200990:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200994:	8082                	ret

ffffffffc0200996 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200996:	610c                	ld	a1,0(a0)
{
ffffffffc0200998:	1141                	addi	sp,sp,-16
ffffffffc020099a:	e022                	sd	s0,0(sp)
ffffffffc020099c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	11a50513          	addi	a0,a0,282 # ffffffffc0205ab8 <commands+0x1f8>
{
ffffffffc02009a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009a8:	fecff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ac:	640c                	ld	a1,8(s0)
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	12250513          	addi	a0,a0,290 # ffffffffc0205ad0 <commands+0x210>
ffffffffc02009b6:	fdeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009ba:	680c                	ld	a1,16(s0)
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	12c50513          	addi	a0,a0,300 # ffffffffc0205ae8 <commands+0x228>
ffffffffc02009c4:	fd0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02009c8:	6c0c                	ld	a1,24(s0)
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	13650513          	addi	a0,a0,310 # ffffffffc0205b00 <commands+0x240>
ffffffffc02009d2:	fc2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02009d6:	700c                	ld	a1,32(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	14050513          	addi	a0,a0,320 # ffffffffc0205b18 <commands+0x258>
ffffffffc02009e0:	fb4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02009e4:	740c                	ld	a1,40(s0)
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	14a50513          	addi	a0,a0,330 # ffffffffc0205b30 <commands+0x270>
ffffffffc02009ee:	fa6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009f2:	780c                	ld	a1,48(s0)
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	15450513          	addi	a0,a0,340 # ffffffffc0205b48 <commands+0x288>
ffffffffc02009fc:	f98ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a00:	7c0c                	ld	a1,56(s0)
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	15e50513          	addi	a0,a0,350 # ffffffffc0205b60 <commands+0x2a0>
ffffffffc0200a0a:	f8aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a0e:	602c                	ld	a1,64(s0)
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	16850513          	addi	a0,a0,360 # ffffffffc0205b78 <commands+0x2b8>
ffffffffc0200a18:	f7cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a1c:	642c                	ld	a1,72(s0)
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	17250513          	addi	a0,a0,370 # ffffffffc0205b90 <commands+0x2d0>
ffffffffc0200a26:	f6eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a2a:	682c                	ld	a1,80(s0)
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	17c50513          	addi	a0,a0,380 # ffffffffc0205ba8 <commands+0x2e8>
ffffffffc0200a34:	f60ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a38:	6c2c                	ld	a1,88(s0)
ffffffffc0200a3a:	00005517          	auipc	a0,0x5
ffffffffc0200a3e:	18650513          	addi	a0,a0,390 # ffffffffc0205bc0 <commands+0x300>
ffffffffc0200a42:	f52ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a46:	702c                	ld	a1,96(s0)
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	19050513          	addi	a0,a0,400 # ffffffffc0205bd8 <commands+0x318>
ffffffffc0200a50:	f44ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a54:	742c                	ld	a1,104(s0)
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	19a50513          	addi	a0,a0,410 # ffffffffc0205bf0 <commands+0x330>
ffffffffc0200a5e:	f36ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a62:	782c                	ld	a1,112(s0)
ffffffffc0200a64:	00005517          	auipc	a0,0x5
ffffffffc0200a68:	1a450513          	addi	a0,a0,420 # ffffffffc0205c08 <commands+0x348>
ffffffffc0200a6c:	f28ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a70:	7c2c                	ld	a1,120(s0)
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	1ae50513          	addi	a0,a0,430 # ffffffffc0205c20 <commands+0x360>
ffffffffc0200a7a:	f1aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a7e:	604c                	ld	a1,128(s0)
ffffffffc0200a80:	00005517          	auipc	a0,0x5
ffffffffc0200a84:	1b850513          	addi	a0,a0,440 # ffffffffc0205c38 <commands+0x378>
ffffffffc0200a88:	f0cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a8c:	644c                	ld	a1,136(s0)
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	1c250513          	addi	a0,a0,450 # ffffffffc0205c50 <commands+0x390>
ffffffffc0200a96:	efeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a9a:	684c                	ld	a1,144(s0)
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	1cc50513          	addi	a0,a0,460 # ffffffffc0205c68 <commands+0x3a8>
ffffffffc0200aa4:	ef0ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200aa8:	6c4c                	ld	a1,152(s0)
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	1d650513          	addi	a0,a0,470 # ffffffffc0205c80 <commands+0x3c0>
ffffffffc0200ab2:	ee2ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200ab6:	704c                	ld	a1,160(s0)
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	1e050513          	addi	a0,a0,480 # ffffffffc0205c98 <commands+0x3d8>
ffffffffc0200ac0:	ed4ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200ac4:	744c                	ld	a1,168(s0)
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	1ea50513          	addi	a0,a0,490 # ffffffffc0205cb0 <commands+0x3f0>
ffffffffc0200ace:	ec6ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200ad2:	784c                	ld	a1,176(s0)
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	1f450513          	addi	a0,a0,500 # ffffffffc0205cc8 <commands+0x408>
ffffffffc0200adc:	eb8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200ae0:	7c4c                	ld	a1,184(s0)
ffffffffc0200ae2:	00005517          	auipc	a0,0x5
ffffffffc0200ae6:	1fe50513          	addi	a0,a0,510 # ffffffffc0205ce0 <commands+0x420>
ffffffffc0200aea:	eaaff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aee:	606c                	ld	a1,192(s0)
ffffffffc0200af0:	00005517          	auipc	a0,0x5
ffffffffc0200af4:	20850513          	addi	a0,a0,520 # ffffffffc0205cf8 <commands+0x438>
ffffffffc0200af8:	e9cff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200afc:	646c                	ld	a1,200(s0)
ffffffffc0200afe:	00005517          	auipc	a0,0x5
ffffffffc0200b02:	21250513          	addi	a0,a0,530 # ffffffffc0205d10 <commands+0x450>
ffffffffc0200b06:	e8eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b0a:	686c                	ld	a1,208(s0)
ffffffffc0200b0c:	00005517          	auipc	a0,0x5
ffffffffc0200b10:	21c50513          	addi	a0,a0,540 # ffffffffc0205d28 <commands+0x468>
ffffffffc0200b14:	e80ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b18:	6c6c                	ld	a1,216(s0)
ffffffffc0200b1a:	00005517          	auipc	a0,0x5
ffffffffc0200b1e:	22650513          	addi	a0,a0,550 # ffffffffc0205d40 <commands+0x480>
ffffffffc0200b22:	e72ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b26:	706c                	ld	a1,224(s0)
ffffffffc0200b28:	00005517          	auipc	a0,0x5
ffffffffc0200b2c:	23050513          	addi	a0,a0,560 # ffffffffc0205d58 <commands+0x498>
ffffffffc0200b30:	e64ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b34:	746c                	ld	a1,232(s0)
ffffffffc0200b36:	00005517          	auipc	a0,0x5
ffffffffc0200b3a:	23a50513          	addi	a0,a0,570 # ffffffffc0205d70 <commands+0x4b0>
ffffffffc0200b3e:	e56ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b42:	786c                	ld	a1,240(s0)
ffffffffc0200b44:	00005517          	auipc	a0,0x5
ffffffffc0200b48:	24450513          	addi	a0,a0,580 # ffffffffc0205d88 <commands+0x4c8>
ffffffffc0200b4c:	e48ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b50:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b52:	6402                	ld	s0,0(sp)
ffffffffc0200b54:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b56:	00005517          	auipc	a0,0x5
ffffffffc0200b5a:	24a50513          	addi	a0,a0,586 # ffffffffc0205da0 <commands+0x4e0>
}
ffffffffc0200b5e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b60:	e34ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b64 <print_trapframe>:
{
ffffffffc0200b64:	1141                	addi	sp,sp,-16
ffffffffc0200b66:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b68:	85aa                	mv	a1,a0
{
ffffffffc0200b6a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b6c:	00005517          	auipc	a0,0x5
ffffffffc0200b70:	24c50513          	addi	a0,a0,588 # ffffffffc0205db8 <commands+0x4f8>
{
ffffffffc0200b74:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b76:	e1eff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	e1bff0ef          	jal	ra,ffffffffc0200996 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b80:	10043583          	ld	a1,256(s0)
ffffffffc0200b84:	00005517          	auipc	a0,0x5
ffffffffc0200b88:	24c50513          	addi	a0,a0,588 # ffffffffc0205dd0 <commands+0x510>
ffffffffc0200b8c:	e08ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b90:	10843583          	ld	a1,264(s0)
ffffffffc0200b94:	00005517          	auipc	a0,0x5
ffffffffc0200b98:	25450513          	addi	a0,a0,596 # ffffffffc0205de8 <commands+0x528>
ffffffffc0200b9c:	df8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200ba0:	11043583          	ld	a1,272(s0)
ffffffffc0200ba4:	00005517          	auipc	a0,0x5
ffffffffc0200ba8:	25c50513          	addi	a0,a0,604 # ffffffffc0205e00 <commands+0x540>
ffffffffc0200bac:	de8ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bb0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bb4:	6402                	ld	s0,0(sp)
ffffffffc0200bb6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bb8:	00005517          	auipc	a0,0x5
ffffffffc0200bbc:	25850513          	addi	a0,a0,600 # ffffffffc0205e10 <commands+0x550>
}
ffffffffc0200bc0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bc2:	dd2ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200bc6 <interrupt_handler>:

//lab3 请补充你在lab3中的代码
void interrupt_handler(struct trapframe *tf)
{
    // scause 最高位表示中断，去掉它以取得中断原因编号。
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200bc6:	11853583          	ld	a1,280(a0)
{
ffffffffc0200bca:	1141                	addi	sp,sp,-16
ffffffffc0200bcc:	e022                	sd	s0,0(sp)
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200bce:	0586                	slli	a1,a1,0x1
{
ffffffffc0200bd0:	e406                	sd	ra,8(sp)
ffffffffc0200bd2:	47ad                	li	a5,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200bd4:	8185                	srli	a1,a1,0x1
{
ffffffffc0200bd6:	842a                	mv	s0,a0
ffffffffc0200bd8:	00b7ec63          	bltu	a5,a1,ffffffffc0200bf0 <interrupt_handler+0x2a>
ffffffffc0200bdc:	00005697          	auipc	a3,0x5
ffffffffc0200be0:	37468693          	addi	a3,a3,884 # ffffffffc0205f50 <commands+0x690>
ffffffffc0200be4:	00259713          	slli	a4,a1,0x2
ffffffffc0200be8:	9736                	add	a4,a4,a3
ffffffffc0200bea:	431c                	lw	a5,0(a4)
ffffffffc0200bec:	97b6                	add	a5,a5,a3
ffffffffc0200bee:	8782                	jr	a5
        break;
    case IRQ_M_EXT:
        cprintf("Machine external interrupt\n");
        break;
    default:
        cprintf("Unknown interrupt: cause %d\n", (int)cause);
ffffffffc0200bf0:	2581                	sext.w	a1,a1
ffffffffc0200bf2:	00005517          	auipc	a0,0x5
ffffffffc0200bf6:	33e50513          	addi	a0,a0,830 # ffffffffc0205f30 <commands+0x670>
ffffffffc0200bfa:	d9aff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200bfe:	8522                	mv	a0,s0
        break;
    }
}
ffffffffc0200c00:	6402                	ld	s0,0(sp)
ffffffffc0200c02:	60a2                	ld	ra,8(sp)
ffffffffc0200c04:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200c06:	bfb9                	j	ffffffffc0200b64 <print_trapframe>
}
ffffffffc0200c08:	6402                	ld	s0,0(sp)
ffffffffc0200c0a:	60a2                	ld	ra,8(sp)
        cprintf("User software interrupt\n");
ffffffffc0200c0c:	00005517          	auipc	a0,0x5
ffffffffc0200c10:	22c50513          	addi	a0,a0,556 # ffffffffc0205e38 <commands+0x578>
}
ffffffffc0200c14:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c16:	d7eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c1a:	6402                	ld	s0,0(sp)
ffffffffc0200c1c:	60a2                	ld	ra,8(sp)
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c1e:	00005517          	auipc	a0,0x5
ffffffffc0200c22:	23a50513          	addi	a0,a0,570 # ffffffffc0205e58 <commands+0x598>
}
ffffffffc0200c26:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c28:	d6cff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c2c:	6402                	ld	s0,0(sp)
ffffffffc0200c2e:	60a2                	ld	ra,8(sp)
        cprintf("Machine software interrupt\n");
ffffffffc0200c30:	00005517          	auipc	a0,0x5
ffffffffc0200c34:	24850513          	addi	a0,a0,584 # ffffffffc0205e78 <commands+0x5b8>
}
ffffffffc0200c38:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c3e:	6402                	ld	s0,0(sp)
ffffffffc0200c40:	60a2                	ld	ra,8(sp)
        cprintf("User timer interrupt\n");
ffffffffc0200c42:	00005517          	auipc	a0,0x5
ffffffffc0200c46:	25650513          	addi	a0,a0,598 # ffffffffc0205e98 <commands+0x5d8>
}
ffffffffc0200c4a:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4c:	d48ff06f          	j	ffffffffc0200194 <cprintf>
        clock_set_next_event();
ffffffffc0200c50:	8e3ff0ef          	jal	ra,ffffffffc0200532 <clock_set_next_event>
        ticks++;
ffffffffc0200c54:	000aa797          	auipc	a5,0xaa
ffffffffc0200c58:	b9478793          	addi	a5,a5,-1132 # ffffffffc02aa7e8 <ticks>
ffffffffc0200c5c:	6398                	ld	a4,0(a5)
ffffffffc0200c5e:	0705                	addi	a4,a4,1
ffffffffc0200c60:	e398                	sd	a4,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200c62:	639c                	ld	a5,0(a5)
ffffffffc0200c64:	06400713          	li	a4,100
ffffffffc0200c68:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200c6c:	cfb9                	beqz	a5,ffffffffc0200cca <interrupt_handler+0x104>
}
ffffffffc0200c6e:	60a2                	ld	ra,8(sp)
ffffffffc0200c70:	6402                	ld	s0,0(sp)
        current->need_resched = 1;
ffffffffc0200c72:	000aa797          	auipc	a5,0xaa
ffffffffc0200c76:	bd67b783          	ld	a5,-1066(a5) # ffffffffc02aa848 <current>
ffffffffc0200c7a:	4705                	li	a4,1
ffffffffc0200c7c:	ef98                	sd	a4,24(a5)
}
ffffffffc0200c7e:	0141                	addi	sp,sp,16
ffffffffc0200c80:	8082                	ret
ffffffffc0200c82:	6402                	ld	s0,0(sp)
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
        cprintf("Machine timer interrupt\n");
ffffffffc0200c86:	00005517          	auipc	a0,0x5
ffffffffc0200c8a:	22a50513          	addi	a0,a0,554 # ffffffffc0205eb0 <commands+0x5f0>
}
ffffffffc0200c8e:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c90:	d04ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c94:	6402                	ld	s0,0(sp)
ffffffffc0200c96:	60a2                	ld	ra,8(sp)
        cprintf("User external interrupt\n");
ffffffffc0200c98:	00005517          	auipc	a0,0x5
ffffffffc0200c9c:	23850513          	addi	a0,a0,568 # ffffffffc0205ed0 <commands+0x610>
}
ffffffffc0200ca0:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200ca2:	cf2ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200ca6:	6402                	ld	s0,0(sp)
ffffffffc0200ca8:	60a2                	ld	ra,8(sp)
        cprintf("Supervisor external interrupt\n");
ffffffffc0200caa:	00005517          	auipc	a0,0x5
ffffffffc0200cae:	24650513          	addi	a0,a0,582 # ffffffffc0205ef0 <commands+0x630>
}
ffffffffc0200cb2:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200cb4:	ce0ff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200cb8:	6402                	ld	s0,0(sp)
ffffffffc0200cba:	60a2                	ld	ra,8(sp)
        cprintf("Machine external interrupt\n");
ffffffffc0200cbc:	00005517          	auipc	a0,0x5
ffffffffc0200cc0:	25450513          	addi	a0,a0,596 # ffffffffc0205f10 <commands+0x650>
}
ffffffffc0200cc4:	0141                	addi	sp,sp,16
        cprintf("Supervisor software interrupt\n");
ffffffffc0200cc6:	cceff06f          	j	ffffffffc0200194 <cprintf>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200cca:	06400593          	li	a1,100
ffffffffc0200cce:	00005517          	auipc	a0,0x5
ffffffffc0200cd2:	15a50513          	addi	a0,a0,346 # ffffffffc0205e28 <commands+0x568>
ffffffffc0200cd6:	cbeff0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0200cda:	bf51                	j	ffffffffc0200c6e <interrupt_handler+0xa8>

ffffffffc0200cdc <exception_handler>:

//lab5 function1 YOUR CODE update exception_handler
void exception_handler(struct trapframe *tf)
{
ffffffffc0200cdc:	1101                	addi	sp,sp,-32
ffffffffc0200cde:	e426                	sd	s1,8(sp)
    switch (tf->cause)
ffffffffc0200ce0:	11853483          	ld	s1,280(a0)
{
ffffffffc0200ce4:	e822                	sd	s0,16(sp)
ffffffffc0200ce6:	ec06                	sd	ra,24(sp)
ffffffffc0200ce8:	47bd                	li	a5,15
ffffffffc0200cea:	842a                	mv	s0,a0
ffffffffc0200cec:	0297e163          	bltu	a5,s1,ffffffffc0200d0e <exception_handler+0x32>
ffffffffc0200cf0:	00005697          	auipc	a3,0x5
ffffffffc0200cf4:	2c868693          	addi	a3,a3,712 # ffffffffc0205fb8 <commands+0x6f8>
ffffffffc0200cf8:	00249713          	slli	a4,s1,0x2
ffffffffc0200cfc:	9736                	add	a4,a4,a3
ffffffffc0200cfe:	431c                	lw	a5,0(a4)
ffffffffc0200d00:	97b6                	add	a5,a5,a3
ffffffffc0200d02:	8782                	jr	a5
        break;
    case CAUSE_FETCH_PAGE_FAULT:
    case CAUSE_LOAD_PAGE_FAULT:
    case CAUSE_STORE_PAGE_FAULT:
        // 本实验没有实现按需分页：用户态非法访问直接终止该进程。
        if (current != NULL && !trap_in_kernel(tf))
ffffffffc0200d04:	000aa717          	auipc	a4,0xaa
ffffffffc0200d08:	b4473703          	ld	a4,-1212(a4) # ffffffffc02aa848 <current>
ffffffffc0200d0c:	e741                	bnez	a4,ffffffffc0200d94 <exception_handler+0xb8>
        {
            print_trapframe(tf);
        }
        break;
    default:
        print_trapframe(tf);
ffffffffc0200d0e:	8522                	mv	a0,s0
        break;
    }
}
ffffffffc0200d10:	6442                	ld	s0,16(sp)
ffffffffc0200d12:	60e2                	ld	ra,24(sp)
ffffffffc0200d14:	64a2                	ld	s1,8(sp)
ffffffffc0200d16:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200d18:	b5b1                	j	ffffffffc0200b64 <print_trapframe>
        tf->epc += 4;
ffffffffc0200d1a:	10853783          	ld	a5,264(a0)
}
ffffffffc0200d1e:	6442                	ld	s0,16(sp)
ffffffffc0200d20:	60e2                	ld	ra,24(sp)
ffffffffc0200d22:	64a2                	ld	s1,8(sp)
        tf->epc += 4;
ffffffffc0200d24:	0791                	addi	a5,a5,4
ffffffffc0200d26:	10f53423          	sd	a5,264(a0)
}
ffffffffc0200d2a:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200d2c:	4060406f          	j	ffffffffc0205132 <syscall>
        cprintf("Breakpoint at 0x%08x\n", tf->epc);
ffffffffc0200d30:	10853583          	ld	a1,264(a0)
ffffffffc0200d34:	00005517          	auipc	a0,0x5
ffffffffc0200d38:	26c50513          	addi	a0,a0,620 # ffffffffc0205fa0 <commands+0x6e0>
ffffffffc0200d3c:	c58ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += (*(const uint16_t *)tf->epc & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200d40:	10843783          	ld	a5,264(s0)
ffffffffc0200d44:	460d                	li	a2,3
ffffffffc0200d46:	4691                	li	a3,4
ffffffffc0200d48:	0007d703          	lhu	a4,0(a5)
ffffffffc0200d4c:	8b0d                	andi	a4,a4,3
ffffffffc0200d4e:	00c70363          	beq	a4,a2,ffffffffc0200d54 <exception_handler+0x78>
ffffffffc0200d52:	4689                	li	a3,2
ffffffffc0200d54:	97b6                	add	a5,a5,a3
}
ffffffffc0200d56:	60e2                	ld	ra,24(sp)
        tf->epc += (*(const uint16_t *)tf->epc & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200d58:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d5c:	6442                	ld	s0,16(sp)
ffffffffc0200d5e:	64a2                	ld	s1,8(sp)
ffffffffc0200d60:	6105                	addi	sp,sp,32
ffffffffc0200d62:	8082                	ret
        cprintf("Illegal instruction at 0x%08x\n", tf->epc);
ffffffffc0200d64:	10853583          	ld	a1,264(a0)
ffffffffc0200d68:	00005517          	auipc	a0,0x5
ffffffffc0200d6c:	21850513          	addi	a0,a0,536 # ffffffffc0205f80 <commands+0x6c0>
ffffffffc0200d70:	c24ff0ef          	jal	ra,ffffffffc0200194 <cprintf>
        tf->epc += (*(const uint16_t *)tf->epc & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200d74:	10843783          	ld	a5,264(s0)
ffffffffc0200d78:	468d                	li	a3,3
ffffffffc0200d7a:	0007d703          	lhu	a4,0(a5)
ffffffffc0200d7e:	8b0d                	andi	a4,a4,3
ffffffffc0200d80:	02d70663          	beq	a4,a3,ffffffffc0200dac <exception_handler+0xd0>
ffffffffc0200d84:	97a6                	add	a5,a5,s1
ffffffffc0200d86:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d8a:	60e2                	ld	ra,24(sp)
ffffffffc0200d8c:	6442                	ld	s0,16(sp)
ffffffffc0200d8e:	64a2                	ld	s1,8(sp)
ffffffffc0200d90:	6105                	addi	sp,sp,32
ffffffffc0200d92:	8082                	ret
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200d94:	10053783          	ld	a5,256(a0)
ffffffffc0200d98:	1007f793          	andi	a5,a5,256
        if (current != NULL && !trap_in_kernel(tf))
ffffffffc0200d9c:	fbad                	bnez	a5,ffffffffc0200d0e <exception_handler+0x32>
            current->flags |= PF_EXITING;
ffffffffc0200d9e:	0b072783          	lw	a5,176(a4)
ffffffffc0200da2:	0017e793          	ori	a5,a5,1
ffffffffc0200da6:	0af72823          	sw	a5,176(a4)
ffffffffc0200daa:	b7c5                	j	ffffffffc0200d8a <exception_handler+0xae>
        tf->epc += (*(const uint16_t *)tf->epc & 0x3) == 0x3 ? 4 : 2;
ffffffffc0200dac:	4491                	li	s1,4
ffffffffc0200dae:	bfd9                	j	ffffffffc0200d84 <exception_handler+0xa8>

ffffffffc0200db0 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200db0:	1101                	addi	sp,sp,-32
ffffffffc0200db2:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200db4:	000aa417          	auipc	s0,0xaa
ffffffffc0200db8:	a9440413          	addi	s0,s0,-1388 # ffffffffc02aa848 <current>
ffffffffc0200dbc:	6018                	ld	a4,0(s0)
{
ffffffffc0200dbe:	ec06                	sd	ra,24(sp)
ffffffffc0200dc0:	e426                	sd	s1,8(sp)
ffffffffc0200dc2:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dc4:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200dc8:	cf1d                	beqz	a4,ffffffffc0200e06 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200dce:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200dd2:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200dd4:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dd8:	0206c463          	bltz	a3,ffffffffc0200e00 <trap+0x50>
        exception_handler(tf);
ffffffffc0200ddc:	f01ff0ef          	jal	ra,ffffffffc0200cdc <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200de0:	601c                	ld	a5,0(s0)
ffffffffc0200de2:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200de6:	e499                	bnez	s1,ffffffffc0200df4 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200de8:	0b07a703          	lw	a4,176(a5)
ffffffffc0200dec:	8b05                	andi	a4,a4,1
ffffffffc0200dee:	e329                	bnez	a4,ffffffffc0200e30 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200df0:	6f9c                	ld	a5,24(a5)
ffffffffc0200df2:	eb85                	bnez	a5,ffffffffc0200e22 <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200df4:	60e2                	ld	ra,24(sp)
ffffffffc0200df6:	6442                	ld	s0,16(sp)
ffffffffc0200df8:	64a2                	ld	s1,8(sp)
ffffffffc0200dfa:	6902                	ld	s2,0(sp)
ffffffffc0200dfc:	6105                	addi	sp,sp,32
ffffffffc0200dfe:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e00:	dc7ff0ef          	jal	ra,ffffffffc0200bc6 <interrupt_handler>
ffffffffc0200e04:	bff1                	j	ffffffffc0200de0 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e06:	0006c863          	bltz	a3,ffffffffc0200e16 <trap+0x66>
}
ffffffffc0200e0a:	6442                	ld	s0,16(sp)
ffffffffc0200e0c:	60e2                	ld	ra,24(sp)
ffffffffc0200e0e:	64a2                	ld	s1,8(sp)
ffffffffc0200e10:	6902                	ld	s2,0(sp)
ffffffffc0200e12:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200e14:	b5e1                	j	ffffffffc0200cdc <exception_handler>
}
ffffffffc0200e16:	6442                	ld	s0,16(sp)
ffffffffc0200e18:	60e2                	ld	ra,24(sp)
ffffffffc0200e1a:	64a2                	ld	s1,8(sp)
ffffffffc0200e1c:	6902                	ld	s2,0(sp)
ffffffffc0200e1e:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200e20:	b35d                	j	ffffffffc0200bc6 <interrupt_handler>
}
ffffffffc0200e22:	6442                	ld	s0,16(sp)
ffffffffc0200e24:	60e2                	ld	ra,24(sp)
ffffffffc0200e26:	64a2                	ld	s1,8(sp)
ffffffffc0200e28:	6902                	ld	s2,0(sp)
ffffffffc0200e2a:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200e2c:	2220406f          	j	ffffffffc020504e <schedule>
                do_exit(-E_KILLED);
ffffffffc0200e30:	555d                	li	a0,-9
ffffffffc0200e32:	7b4030ef          	jal	ra,ffffffffc02045e6 <do_exit>
            if (current->need_resched)
ffffffffc0200e36:	601c                	ld	a5,0(s0)
ffffffffc0200e38:	bf65                	j	ffffffffc0200df0 <trap+0x40>
	...

ffffffffc0200e3c <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200e3c:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200e40:	00011463          	bnez	sp,ffffffffc0200e48 <__alltraps+0xc>
ffffffffc0200e44:	14002173          	csrr	sp,sscratch
ffffffffc0200e48:	712d                	addi	sp,sp,-288
ffffffffc0200e4a:	e002                	sd	zero,0(sp)
ffffffffc0200e4c:	e406                	sd	ra,8(sp)
ffffffffc0200e4e:	ec0e                	sd	gp,24(sp)
ffffffffc0200e50:	f012                	sd	tp,32(sp)
ffffffffc0200e52:	f416                	sd	t0,40(sp)
ffffffffc0200e54:	f81a                	sd	t1,48(sp)
ffffffffc0200e56:	fc1e                	sd	t2,56(sp)
ffffffffc0200e58:	e0a2                	sd	s0,64(sp)
ffffffffc0200e5a:	e4a6                	sd	s1,72(sp)
ffffffffc0200e5c:	e8aa                	sd	a0,80(sp)
ffffffffc0200e5e:	ecae                	sd	a1,88(sp)
ffffffffc0200e60:	f0b2                	sd	a2,96(sp)
ffffffffc0200e62:	f4b6                	sd	a3,104(sp)
ffffffffc0200e64:	f8ba                	sd	a4,112(sp)
ffffffffc0200e66:	fcbe                	sd	a5,120(sp)
ffffffffc0200e68:	e142                	sd	a6,128(sp)
ffffffffc0200e6a:	e546                	sd	a7,136(sp)
ffffffffc0200e6c:	e94a                	sd	s2,144(sp)
ffffffffc0200e6e:	ed4e                	sd	s3,152(sp)
ffffffffc0200e70:	f152                	sd	s4,160(sp)
ffffffffc0200e72:	f556                	sd	s5,168(sp)
ffffffffc0200e74:	f95a                	sd	s6,176(sp)
ffffffffc0200e76:	fd5e                	sd	s7,184(sp)
ffffffffc0200e78:	e1e2                	sd	s8,192(sp)
ffffffffc0200e7a:	e5e6                	sd	s9,200(sp)
ffffffffc0200e7c:	e9ea                	sd	s10,208(sp)
ffffffffc0200e7e:	edee                	sd	s11,216(sp)
ffffffffc0200e80:	f1f2                	sd	t3,224(sp)
ffffffffc0200e82:	f5f6                	sd	t4,232(sp)
ffffffffc0200e84:	f9fa                	sd	t5,240(sp)
ffffffffc0200e86:	fdfe                	sd	t6,248(sp)
ffffffffc0200e88:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200e8c:	100024f3          	csrr	s1,sstatus
ffffffffc0200e90:	14102973          	csrr	s2,sepc
ffffffffc0200e94:	143029f3          	csrr	s3,stval
ffffffffc0200e98:	14202a73          	csrr	s4,scause
ffffffffc0200e9c:	e822                	sd	s0,16(sp)
ffffffffc0200e9e:	e226                	sd	s1,256(sp)
ffffffffc0200ea0:	e64a                	sd	s2,264(sp)
ffffffffc0200ea2:	ea4e                	sd	s3,272(sp)
ffffffffc0200ea4:	ee52                	sd	s4,280(sp)

    #lab3:填写你在lab3中实现的代码
    # 当前 sp 指向完整 trapframe，按调用约定作为 trap(tf) 的首参数。
    move a0, sp
ffffffffc0200ea6:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ea8:	f09ff0ef          	jal	ra,ffffffffc0200db0 <trap>

ffffffffc0200eac <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200eac:	6492                	ld	s1,256(sp)
ffffffffc0200eae:	6932                	ld	s2,264(sp)
ffffffffc0200eb0:	1004f413          	andi	s0,s1,256
ffffffffc0200eb4:	e401                	bnez	s0,ffffffffc0200ebc <__trapret+0x10>
ffffffffc0200eb6:	1200                	addi	s0,sp,288
ffffffffc0200eb8:	14041073          	csrw	sscratch,s0
ffffffffc0200ebc:	10049073          	csrw	sstatus,s1
ffffffffc0200ec0:	14191073          	csrw	sepc,s2
ffffffffc0200ec4:	60a2                	ld	ra,8(sp)
ffffffffc0200ec6:	61e2                	ld	gp,24(sp)
ffffffffc0200ec8:	7202                	ld	tp,32(sp)
ffffffffc0200eca:	72a2                	ld	t0,40(sp)
ffffffffc0200ecc:	7342                	ld	t1,48(sp)
ffffffffc0200ece:	73e2                	ld	t2,56(sp)
ffffffffc0200ed0:	6406                	ld	s0,64(sp)
ffffffffc0200ed2:	64a6                	ld	s1,72(sp)
ffffffffc0200ed4:	6546                	ld	a0,80(sp)
ffffffffc0200ed6:	65e6                	ld	a1,88(sp)
ffffffffc0200ed8:	7606                	ld	a2,96(sp)
ffffffffc0200eda:	76a6                	ld	a3,104(sp)
ffffffffc0200edc:	7746                	ld	a4,112(sp)
ffffffffc0200ede:	77e6                	ld	a5,120(sp)
ffffffffc0200ee0:	680a                	ld	a6,128(sp)
ffffffffc0200ee2:	68aa                	ld	a7,136(sp)
ffffffffc0200ee4:	694a                	ld	s2,144(sp)
ffffffffc0200ee6:	69ea                	ld	s3,152(sp)
ffffffffc0200ee8:	7a0a                	ld	s4,160(sp)
ffffffffc0200eea:	7aaa                	ld	s5,168(sp)
ffffffffc0200eec:	7b4a                	ld	s6,176(sp)
ffffffffc0200eee:	7bea                	ld	s7,184(sp)
ffffffffc0200ef0:	6c0e                	ld	s8,192(sp)
ffffffffc0200ef2:	6cae                	ld	s9,200(sp)
ffffffffc0200ef4:	6d4e                	ld	s10,208(sp)
ffffffffc0200ef6:	6dee                	ld	s11,216(sp)
ffffffffc0200ef8:	7e0e                	ld	t3,224(sp)
ffffffffc0200efa:	7eae                	ld	t4,232(sp)
ffffffffc0200efc:	7f4e                	ld	t5,240(sp)
ffffffffc0200efe:	7fee                	ld	t6,248(sp)
ffffffffc0200f00:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f02:	10200073          	sret

ffffffffc0200f06 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f06:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200f08:	b755                	j	ffffffffc0200eac <__trapret>

ffffffffc0200f0a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f0a:	000a6797          	auipc	a5,0xa6
ffffffffc0200f0e:	8ae78793          	addi	a5,a5,-1874 # ffffffffc02a67b8 <free_area>
ffffffffc0200f12:	e79c                	sd	a5,8(a5)
ffffffffc0200f14:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f16:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f1a:	8082                	ret

ffffffffc0200f1c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200f1c:	000a6517          	auipc	a0,0xa6
ffffffffc0200f20:	8ac56503          	lwu	a0,-1876(a0) # ffffffffc02a67c8 <free_area+0x10>
ffffffffc0200f24:	8082                	ret

ffffffffc0200f26 <default_check>:

// below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200f26:	715d                	addi	sp,sp,-80
ffffffffc0200f28:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f2a:	000a6417          	auipc	s0,0xa6
ffffffffc0200f2e:	88e40413          	addi	s0,s0,-1906 # ffffffffc02a67b8 <free_area>
ffffffffc0200f32:	641c                	ld	a5,8(s0)
ffffffffc0200f34:	e486                	sd	ra,72(sp)
ffffffffc0200f36:	fc26                	sd	s1,56(sp)
ffffffffc0200f38:	f84a                	sd	s2,48(sp)
ffffffffc0200f3a:	f44e                	sd	s3,40(sp)
ffffffffc0200f3c:	f052                	sd	s4,32(sp)
ffffffffc0200f3e:	ec56                	sd	s5,24(sp)
ffffffffc0200f40:	e85a                	sd	s6,16(sp)
ffffffffc0200f42:	e45e                	sd	s7,8(sp)
ffffffffc0200f44:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f46:	2a878d63          	beq	a5,s0,ffffffffc0201200 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200f4a:	4481                	li	s1,0
ffffffffc0200f4c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f4e:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200f52:	8b09                	andi	a4,a4,2
ffffffffc0200f54:	2a070a63          	beqz	a4,ffffffffc0201208 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0200f58:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f5c:	679c                	ld	a5,8(a5)
ffffffffc0200f5e:	2905                	addiw	s2,s2,1
ffffffffc0200f60:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f62:	fe8796e3          	bne	a5,s0,ffffffffc0200f4e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200f66:	89a6                	mv	s3,s1
ffffffffc0200f68:	655000ef          	jal	ra,ffffffffc0201dbc <nr_free_pages>
ffffffffc0200f6c:	6f351e63          	bne	a0,s3,ffffffffc0201668 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f70:	4505                	li	a0,1
ffffffffc0200f72:	5cd000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0200f76:	8aaa                	mv	s5,a0
ffffffffc0200f78:	42050863          	beqz	a0,ffffffffc02013a8 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f7c:	4505                	li	a0,1
ffffffffc0200f7e:	5c1000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0200f82:	89aa                	mv	s3,a0
ffffffffc0200f84:	70050263          	beqz	a0,ffffffffc0201688 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f88:	4505                	li	a0,1
ffffffffc0200f8a:	5b5000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0200f8e:	8a2a                	mv	s4,a0
ffffffffc0200f90:	48050c63          	beqz	a0,ffffffffc0201428 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f94:	293a8a63          	beq	s5,s3,ffffffffc0201228 <default_check+0x302>
ffffffffc0200f98:	28aa8863          	beq	s5,a0,ffffffffc0201228 <default_check+0x302>
ffffffffc0200f9c:	28a98663          	beq	s3,a0,ffffffffc0201228 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200fa0:	000aa783          	lw	a5,0(s5)
ffffffffc0200fa4:	2a079263          	bnez	a5,ffffffffc0201248 <default_check+0x322>
ffffffffc0200fa8:	0009a783          	lw	a5,0(s3)
ffffffffc0200fac:	28079e63          	bnez	a5,ffffffffc0201248 <default_check+0x322>
ffffffffc0200fb0:	411c                	lw	a5,0(a0)
ffffffffc0200fb2:	28079b63          	bnez	a5,ffffffffc0201248 <default_check+0x322>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200fb6:	000aa797          	auipc	a5,0xaa
ffffffffc0200fba:	8727b783          	ld	a5,-1934(a5) # ffffffffc02aa828 <pages>
ffffffffc0200fbe:	40fa8733          	sub	a4,s5,a5
ffffffffc0200fc2:	00006617          	auipc	a2,0x6
ffffffffc0200fc6:	52e63603          	ld	a2,1326(a2) # ffffffffc02074f0 <nbase>
ffffffffc0200fca:	8719                	srai	a4,a4,0x6
ffffffffc0200fcc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fce:	000aa697          	auipc	a3,0xaa
ffffffffc0200fd2:	8526b683          	ld	a3,-1966(a3) # ffffffffc02aa820 <npage>
ffffffffc0200fd6:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd8:	0732                	slli	a4,a4,0xc
ffffffffc0200fda:	28d77763          	bgeu	a4,a3,ffffffffc0201268 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200fde:	40f98733          	sub	a4,s3,a5
ffffffffc0200fe2:	8719                	srai	a4,a4,0x6
ffffffffc0200fe4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fe6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fe8:	4cd77063          	bgeu	a4,a3,ffffffffc02014a8 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200fec:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ff0:	8799                	srai	a5,a5,0x6
ffffffffc0200ff2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ff6:	30d7f963          	bgeu	a5,a3,ffffffffc0201308 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200ffa:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ffc:	00043c03          	ld	s8,0(s0)
ffffffffc0201000:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201004:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201008:	e400                	sd	s0,8(s0)
ffffffffc020100a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020100c:	000a5797          	auipc	a5,0xa5
ffffffffc0201010:	7a07ae23          	sw	zero,1980(a5) # ffffffffc02a67c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201014:	52b000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201018:	2c051863          	bnez	a0,ffffffffc02012e8 <default_check+0x3c2>
    free_page(p0);
ffffffffc020101c:	4585                	li	a1,1
ffffffffc020101e:	8556                	mv	a0,s5
ffffffffc0201020:	55d000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_page(p1);
ffffffffc0201024:	4585                	li	a1,1
ffffffffc0201026:	854e                	mv	a0,s3
ffffffffc0201028:	555000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_page(p2);
ffffffffc020102c:	4585                	li	a1,1
ffffffffc020102e:	8552                	mv	a0,s4
ffffffffc0201030:	54d000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    assert(nr_free == 3);
ffffffffc0201034:	4818                	lw	a4,16(s0)
ffffffffc0201036:	478d                	li	a5,3
ffffffffc0201038:	28f71863          	bne	a4,a5,ffffffffc02012c8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020103c:	4505                	li	a0,1
ffffffffc020103e:	501000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201042:	89aa                	mv	s3,a0
ffffffffc0201044:	26050263          	beqz	a0,ffffffffc02012a8 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201048:	4505                	li	a0,1
ffffffffc020104a:	4f5000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020104e:	8aaa                	mv	s5,a0
ffffffffc0201050:	3a050c63          	beqz	a0,ffffffffc0201408 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201054:	4505                	li	a0,1
ffffffffc0201056:	4e9000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020105a:	8a2a                	mv	s4,a0
ffffffffc020105c:	38050663          	beqz	a0,ffffffffc02013e8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201060:	4505                	li	a0,1
ffffffffc0201062:	4dd000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201066:	36051163          	bnez	a0,ffffffffc02013c8 <default_check+0x4a2>
    free_page(p0);
ffffffffc020106a:	4585                	li	a1,1
ffffffffc020106c:	854e                	mv	a0,s3
ffffffffc020106e:	50f000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201072:	641c                	ld	a5,8(s0)
ffffffffc0201074:	20878a63          	beq	a5,s0,ffffffffc0201288 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201078:	4505                	li	a0,1
ffffffffc020107a:	4c5000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020107e:	30a99563          	bne	s3,a0,ffffffffc0201388 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0201082:	4505                	li	a0,1
ffffffffc0201084:	4bb000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201088:	2e051063          	bnez	a0,ffffffffc0201368 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020108c:	481c                	lw	a5,16(s0)
ffffffffc020108e:	2a079d63          	bnez	a5,ffffffffc0201348 <default_check+0x422>
    free_page(p);
ffffffffc0201092:	854e                	mv	a0,s3
ffffffffc0201094:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201096:	01843023          	sd	s8,0(s0)
ffffffffc020109a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020109e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02010a2:	4db000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_page(p1);
ffffffffc02010a6:	4585                	li	a1,1
ffffffffc02010a8:	8556                	mv	a0,s5
ffffffffc02010aa:	4d3000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_page(p2);
ffffffffc02010ae:	4585                	li	a1,1
ffffffffc02010b0:	8552                	mv	a0,s4
ffffffffc02010b2:	4cb000ef          	jal	ra,ffffffffc0201d7c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02010b6:	4515                	li	a0,5
ffffffffc02010b8:	487000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc02010bc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02010be:	26050563          	beqz	a0,ffffffffc0201328 <default_check+0x402>
ffffffffc02010c2:	651c                	ld	a5,8(a0)
ffffffffc02010c4:	8385                	srli	a5,a5,0x1
ffffffffc02010c6:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02010c8:	54079063          	bnez	a5,ffffffffc0201608 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02010cc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010ce:	00043b03          	ld	s6,0(s0)
ffffffffc02010d2:	00843a83          	ld	s5,8(s0)
ffffffffc02010d6:	e000                	sd	s0,0(s0)
ffffffffc02010d8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02010da:	465000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc02010de:	50051563          	bnez	a0,ffffffffc02015e8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02010e2:	08098a13          	addi	s4,s3,128
ffffffffc02010e6:	8552                	mv	a0,s4
ffffffffc02010e8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02010ea:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02010ee:	000a5797          	auipc	a5,0xa5
ffffffffc02010f2:	6c07ad23          	sw	zero,1754(a5) # ffffffffc02a67c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02010f6:	487000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02010fa:	4511                	li	a0,4
ffffffffc02010fc:	443000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201100:	4c051463          	bnez	a0,ffffffffc02015c8 <default_check+0x6a2>
ffffffffc0201104:	0889b783          	ld	a5,136(s3)
ffffffffc0201108:	8385                	srli	a5,a5,0x1
ffffffffc020110a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020110c:	48078e63          	beqz	a5,ffffffffc02015a8 <default_check+0x682>
ffffffffc0201110:	0909a703          	lw	a4,144(s3)
ffffffffc0201114:	478d                	li	a5,3
ffffffffc0201116:	48f71963          	bne	a4,a5,ffffffffc02015a8 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020111a:	450d                	li	a0,3
ffffffffc020111c:	423000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0201120:	8c2a                	mv	s8,a0
ffffffffc0201122:	46050363          	beqz	a0,ffffffffc0201588 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201126:	4505                	li	a0,1
ffffffffc0201128:	417000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020112c:	42051e63          	bnez	a0,ffffffffc0201568 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201130:	418a1c63          	bne	s4,s8,ffffffffc0201548 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201134:	4585                	li	a1,1
ffffffffc0201136:	854e                	mv	a0,s3
ffffffffc0201138:	445000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_pages(p1, 3);
ffffffffc020113c:	458d                	li	a1,3
ffffffffc020113e:	8552                	mv	a0,s4
ffffffffc0201140:	43d000ef          	jal	ra,ffffffffc0201d7c <free_pages>
ffffffffc0201144:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201148:	04098c13          	addi	s8,s3,64
ffffffffc020114c:	8385                	srli	a5,a5,0x1
ffffffffc020114e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201150:	3c078c63          	beqz	a5,ffffffffc0201528 <default_check+0x602>
ffffffffc0201154:	0109a703          	lw	a4,16(s3)
ffffffffc0201158:	4785                	li	a5,1
ffffffffc020115a:	3cf71763          	bne	a4,a5,ffffffffc0201528 <default_check+0x602>
ffffffffc020115e:	008a3783          	ld	a5,8(s4)
ffffffffc0201162:	8385                	srli	a5,a5,0x1
ffffffffc0201164:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201166:	3a078163          	beqz	a5,ffffffffc0201508 <default_check+0x5e2>
ffffffffc020116a:	010a2703          	lw	a4,16(s4)
ffffffffc020116e:	478d                	li	a5,3
ffffffffc0201170:	38f71c63          	bne	a4,a5,ffffffffc0201508 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201174:	4505                	li	a0,1
ffffffffc0201176:	3c9000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020117a:	36a99763          	bne	s3,a0,ffffffffc02014e8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020117e:	4585                	li	a1,1
ffffffffc0201180:	3fd000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201184:	4509                	li	a0,2
ffffffffc0201186:	3b9000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc020118a:	32aa1f63          	bne	s4,a0,ffffffffc02014c8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020118e:	4589                	li	a1,2
ffffffffc0201190:	3ed000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    free_page(p2);
ffffffffc0201194:	4585                	li	a1,1
ffffffffc0201196:	8562                	mv	a0,s8
ffffffffc0201198:	3e5000ef          	jal	ra,ffffffffc0201d7c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020119c:	4515                	li	a0,5
ffffffffc020119e:	3a1000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc02011a2:	89aa                	mv	s3,a0
ffffffffc02011a4:	48050263          	beqz	a0,ffffffffc0201628 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02011a8:	4505                	li	a0,1
ffffffffc02011aa:	395000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc02011ae:	2c051d63          	bnez	a0,ffffffffc0201488 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02011b2:	481c                	lw	a5,16(s0)
ffffffffc02011b4:	2a079a63          	bnez	a5,ffffffffc0201468 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02011b8:	4595                	li	a1,5
ffffffffc02011ba:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02011bc:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02011c0:	01643023          	sd	s6,0(s0)
ffffffffc02011c4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02011c8:	3b5000ef          	jal	ra,ffffffffc0201d7c <free_pages>
    return listelm->next;
ffffffffc02011cc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02011ce:	00878963          	beq	a5,s0,ffffffffc02011e0 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02011d2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011d6:	679c                	ld	a5,8(a5)
ffffffffc02011d8:	397d                	addiw	s2,s2,-1
ffffffffc02011da:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02011dc:	fe879be3          	bne	a5,s0,ffffffffc02011d2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02011e0:	26091463          	bnez	s2,ffffffffc0201448 <default_check+0x522>
    assert(total == 0);
ffffffffc02011e4:	46049263          	bnez	s1,ffffffffc0201648 <default_check+0x722>
}
ffffffffc02011e8:	60a6                	ld	ra,72(sp)
ffffffffc02011ea:	6406                	ld	s0,64(sp)
ffffffffc02011ec:	74e2                	ld	s1,56(sp)
ffffffffc02011ee:	7942                	ld	s2,48(sp)
ffffffffc02011f0:	79a2                	ld	s3,40(sp)
ffffffffc02011f2:	7a02                	ld	s4,32(sp)
ffffffffc02011f4:	6ae2                	ld	s5,24(sp)
ffffffffc02011f6:	6b42                	ld	s6,16(sp)
ffffffffc02011f8:	6ba2                	ld	s7,8(sp)
ffffffffc02011fa:	6c02                	ld	s8,0(sp)
ffffffffc02011fc:	6161                	addi	sp,sp,80
ffffffffc02011fe:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201200:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201202:	4481                	li	s1,0
ffffffffc0201204:	4901                	li	s2,0
ffffffffc0201206:	b38d                	j	ffffffffc0200f68 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201208:	00005697          	auipc	a3,0x5
ffffffffc020120c:	df068693          	addi	a3,a3,-528 # ffffffffc0205ff8 <commands+0x738>
ffffffffc0201210:	00005617          	auipc	a2,0x5
ffffffffc0201214:	df860613          	addi	a2,a2,-520 # ffffffffc0206008 <commands+0x748>
ffffffffc0201218:	0c600593          	li	a1,198
ffffffffc020121c:	00005517          	auipc	a0,0x5
ffffffffc0201220:	e0450513          	addi	a0,a0,-508 # ffffffffc0206020 <commands+0x760>
ffffffffc0201224:	a2aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201228:	00005697          	auipc	a3,0x5
ffffffffc020122c:	e9068693          	addi	a3,a3,-368 # ffffffffc02060b8 <commands+0x7f8>
ffffffffc0201230:	00005617          	auipc	a2,0x5
ffffffffc0201234:	dd860613          	addi	a2,a2,-552 # ffffffffc0206008 <commands+0x748>
ffffffffc0201238:	09100593          	li	a1,145
ffffffffc020123c:	00005517          	auipc	a0,0x5
ffffffffc0201240:	de450513          	addi	a0,a0,-540 # ffffffffc0206020 <commands+0x760>
ffffffffc0201244:	a0aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201248:	00005697          	auipc	a3,0x5
ffffffffc020124c:	e9868693          	addi	a3,a3,-360 # ffffffffc02060e0 <commands+0x820>
ffffffffc0201250:	00005617          	auipc	a2,0x5
ffffffffc0201254:	db860613          	addi	a2,a2,-584 # ffffffffc0206008 <commands+0x748>
ffffffffc0201258:	09200593          	li	a1,146
ffffffffc020125c:	00005517          	auipc	a0,0x5
ffffffffc0201260:	dc450513          	addi	a0,a0,-572 # ffffffffc0206020 <commands+0x760>
ffffffffc0201264:	9eaff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201268:	00005697          	auipc	a3,0x5
ffffffffc020126c:	eb868693          	addi	a3,a3,-328 # ffffffffc0206120 <commands+0x860>
ffffffffc0201270:	00005617          	auipc	a2,0x5
ffffffffc0201274:	d9860613          	addi	a2,a2,-616 # ffffffffc0206008 <commands+0x748>
ffffffffc0201278:	09400593          	li	a1,148
ffffffffc020127c:	00005517          	auipc	a0,0x5
ffffffffc0201280:	da450513          	addi	a0,a0,-604 # ffffffffc0206020 <commands+0x760>
ffffffffc0201284:	9caff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201288:	00005697          	auipc	a3,0x5
ffffffffc020128c:	f2068693          	addi	a3,a3,-224 # ffffffffc02061a8 <commands+0x8e8>
ffffffffc0201290:	00005617          	auipc	a2,0x5
ffffffffc0201294:	d7860613          	addi	a2,a2,-648 # ffffffffc0206008 <commands+0x748>
ffffffffc0201298:	0ad00593          	li	a1,173
ffffffffc020129c:	00005517          	auipc	a0,0x5
ffffffffc02012a0:	d8450513          	addi	a0,a0,-636 # ffffffffc0206020 <commands+0x760>
ffffffffc02012a4:	9aaff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012a8:	00005697          	auipc	a3,0x5
ffffffffc02012ac:	db068693          	addi	a3,a3,-592 # ffffffffc0206058 <commands+0x798>
ffffffffc02012b0:	00005617          	auipc	a2,0x5
ffffffffc02012b4:	d5860613          	addi	a2,a2,-680 # ffffffffc0206008 <commands+0x748>
ffffffffc02012b8:	0a600593          	li	a1,166
ffffffffc02012bc:	00005517          	auipc	a0,0x5
ffffffffc02012c0:	d6450513          	addi	a0,a0,-668 # ffffffffc0206020 <commands+0x760>
ffffffffc02012c4:	98aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free == 3);
ffffffffc02012c8:	00005697          	auipc	a3,0x5
ffffffffc02012cc:	ed068693          	addi	a3,a3,-304 # ffffffffc0206198 <commands+0x8d8>
ffffffffc02012d0:	00005617          	auipc	a2,0x5
ffffffffc02012d4:	d3860613          	addi	a2,a2,-712 # ffffffffc0206008 <commands+0x748>
ffffffffc02012d8:	0a400593          	li	a1,164
ffffffffc02012dc:	00005517          	auipc	a0,0x5
ffffffffc02012e0:	d4450513          	addi	a0,a0,-700 # ffffffffc0206020 <commands+0x760>
ffffffffc02012e4:	96aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e8:	00005697          	auipc	a3,0x5
ffffffffc02012ec:	e9868693          	addi	a3,a3,-360 # ffffffffc0206180 <commands+0x8c0>
ffffffffc02012f0:	00005617          	auipc	a2,0x5
ffffffffc02012f4:	d1860613          	addi	a2,a2,-744 # ffffffffc0206008 <commands+0x748>
ffffffffc02012f8:	09f00593          	li	a1,159
ffffffffc02012fc:	00005517          	auipc	a0,0x5
ffffffffc0201300:	d2450513          	addi	a0,a0,-732 # ffffffffc0206020 <commands+0x760>
ffffffffc0201304:	94aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201308:	00005697          	auipc	a3,0x5
ffffffffc020130c:	e5868693          	addi	a3,a3,-424 # ffffffffc0206160 <commands+0x8a0>
ffffffffc0201310:	00005617          	auipc	a2,0x5
ffffffffc0201314:	cf860613          	addi	a2,a2,-776 # ffffffffc0206008 <commands+0x748>
ffffffffc0201318:	09600593          	li	a1,150
ffffffffc020131c:	00005517          	auipc	a0,0x5
ffffffffc0201320:	d0450513          	addi	a0,a0,-764 # ffffffffc0206020 <commands+0x760>
ffffffffc0201324:	92aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(p0 != NULL);
ffffffffc0201328:	00005697          	auipc	a3,0x5
ffffffffc020132c:	ec868693          	addi	a3,a3,-312 # ffffffffc02061f0 <commands+0x930>
ffffffffc0201330:	00005617          	auipc	a2,0x5
ffffffffc0201334:	cd860613          	addi	a2,a2,-808 # ffffffffc0206008 <commands+0x748>
ffffffffc0201338:	0ce00593          	li	a1,206
ffffffffc020133c:	00005517          	auipc	a0,0x5
ffffffffc0201340:	ce450513          	addi	a0,a0,-796 # ffffffffc0206020 <commands+0x760>
ffffffffc0201344:	90aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free == 0);
ffffffffc0201348:	00005697          	auipc	a3,0x5
ffffffffc020134c:	e9868693          	addi	a3,a3,-360 # ffffffffc02061e0 <commands+0x920>
ffffffffc0201350:	00005617          	auipc	a2,0x5
ffffffffc0201354:	cb860613          	addi	a2,a2,-840 # ffffffffc0206008 <commands+0x748>
ffffffffc0201358:	0b300593          	li	a1,179
ffffffffc020135c:	00005517          	auipc	a0,0x5
ffffffffc0201360:	cc450513          	addi	a0,a0,-828 # ffffffffc0206020 <commands+0x760>
ffffffffc0201364:	8eaff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201368:	00005697          	auipc	a3,0x5
ffffffffc020136c:	e1868693          	addi	a3,a3,-488 # ffffffffc0206180 <commands+0x8c0>
ffffffffc0201370:	00005617          	auipc	a2,0x5
ffffffffc0201374:	c9860613          	addi	a2,a2,-872 # ffffffffc0206008 <commands+0x748>
ffffffffc0201378:	0b100593          	li	a1,177
ffffffffc020137c:	00005517          	auipc	a0,0x5
ffffffffc0201380:	ca450513          	addi	a0,a0,-860 # ffffffffc0206020 <commands+0x760>
ffffffffc0201384:	8caff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201388:	00005697          	auipc	a3,0x5
ffffffffc020138c:	e3868693          	addi	a3,a3,-456 # ffffffffc02061c0 <commands+0x900>
ffffffffc0201390:	00005617          	auipc	a2,0x5
ffffffffc0201394:	c7860613          	addi	a2,a2,-904 # ffffffffc0206008 <commands+0x748>
ffffffffc0201398:	0b000593          	li	a1,176
ffffffffc020139c:	00005517          	auipc	a0,0x5
ffffffffc02013a0:	c8450513          	addi	a0,a0,-892 # ffffffffc0206020 <commands+0x760>
ffffffffc02013a4:	8aaff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013a8:	00005697          	auipc	a3,0x5
ffffffffc02013ac:	cb068693          	addi	a3,a3,-848 # ffffffffc0206058 <commands+0x798>
ffffffffc02013b0:	00005617          	auipc	a2,0x5
ffffffffc02013b4:	c5860613          	addi	a2,a2,-936 # ffffffffc0206008 <commands+0x748>
ffffffffc02013b8:	08d00593          	li	a1,141
ffffffffc02013bc:	00005517          	auipc	a0,0x5
ffffffffc02013c0:	c6450513          	addi	a0,a0,-924 # ffffffffc0206020 <commands+0x760>
ffffffffc02013c4:	88aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013c8:	00005697          	auipc	a3,0x5
ffffffffc02013cc:	db868693          	addi	a3,a3,-584 # ffffffffc0206180 <commands+0x8c0>
ffffffffc02013d0:	00005617          	auipc	a2,0x5
ffffffffc02013d4:	c3860613          	addi	a2,a2,-968 # ffffffffc0206008 <commands+0x748>
ffffffffc02013d8:	0aa00593          	li	a1,170
ffffffffc02013dc:	00005517          	auipc	a0,0x5
ffffffffc02013e0:	c4450513          	addi	a0,a0,-956 # ffffffffc0206020 <commands+0x760>
ffffffffc02013e4:	86aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013e8:	00005697          	auipc	a3,0x5
ffffffffc02013ec:	cb068693          	addi	a3,a3,-848 # ffffffffc0206098 <commands+0x7d8>
ffffffffc02013f0:	00005617          	auipc	a2,0x5
ffffffffc02013f4:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206008 <commands+0x748>
ffffffffc02013f8:	0a800593          	li	a1,168
ffffffffc02013fc:	00005517          	auipc	a0,0x5
ffffffffc0201400:	c2450513          	addi	a0,a0,-988 # ffffffffc0206020 <commands+0x760>
ffffffffc0201404:	84aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201408:	00005697          	auipc	a3,0x5
ffffffffc020140c:	c7068693          	addi	a3,a3,-912 # ffffffffc0206078 <commands+0x7b8>
ffffffffc0201410:	00005617          	auipc	a2,0x5
ffffffffc0201414:	bf860613          	addi	a2,a2,-1032 # ffffffffc0206008 <commands+0x748>
ffffffffc0201418:	0a700593          	li	a1,167
ffffffffc020141c:	00005517          	auipc	a0,0x5
ffffffffc0201420:	c0450513          	addi	a0,a0,-1020 # ffffffffc0206020 <commands+0x760>
ffffffffc0201424:	82aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201428:	00005697          	auipc	a3,0x5
ffffffffc020142c:	c7068693          	addi	a3,a3,-912 # ffffffffc0206098 <commands+0x7d8>
ffffffffc0201430:	00005617          	auipc	a2,0x5
ffffffffc0201434:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206008 <commands+0x748>
ffffffffc0201438:	08f00593          	li	a1,143
ffffffffc020143c:	00005517          	auipc	a0,0x5
ffffffffc0201440:	be450513          	addi	a0,a0,-1052 # ffffffffc0206020 <commands+0x760>
ffffffffc0201444:	80aff0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(count == 0);
ffffffffc0201448:	00005697          	auipc	a3,0x5
ffffffffc020144c:	ef868693          	addi	a3,a3,-264 # ffffffffc0206340 <commands+0xa80>
ffffffffc0201450:	00005617          	auipc	a2,0x5
ffffffffc0201454:	bb860613          	addi	a2,a2,-1096 # ffffffffc0206008 <commands+0x748>
ffffffffc0201458:	0fc00593          	li	a1,252
ffffffffc020145c:	00005517          	auipc	a0,0x5
ffffffffc0201460:	bc450513          	addi	a0,a0,-1084 # ffffffffc0206020 <commands+0x760>
ffffffffc0201464:	febfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free == 0);
ffffffffc0201468:	00005697          	auipc	a3,0x5
ffffffffc020146c:	d7868693          	addi	a3,a3,-648 # ffffffffc02061e0 <commands+0x920>
ffffffffc0201470:	00005617          	auipc	a2,0x5
ffffffffc0201474:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206008 <commands+0x748>
ffffffffc0201478:	0f000593          	li	a1,240
ffffffffc020147c:	00005517          	auipc	a0,0x5
ffffffffc0201480:	ba450513          	addi	a0,a0,-1116 # ffffffffc0206020 <commands+0x760>
ffffffffc0201484:	fcbfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201488:	00005697          	auipc	a3,0x5
ffffffffc020148c:	cf868693          	addi	a3,a3,-776 # ffffffffc0206180 <commands+0x8c0>
ffffffffc0201490:	00005617          	auipc	a2,0x5
ffffffffc0201494:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206008 <commands+0x748>
ffffffffc0201498:	0ee00593          	li	a1,238
ffffffffc020149c:	00005517          	auipc	a0,0x5
ffffffffc02014a0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0206020 <commands+0x760>
ffffffffc02014a4:	fabfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014a8:	00005697          	auipc	a3,0x5
ffffffffc02014ac:	c9868693          	addi	a3,a3,-872 # ffffffffc0206140 <commands+0x880>
ffffffffc02014b0:	00005617          	auipc	a2,0x5
ffffffffc02014b4:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206008 <commands+0x748>
ffffffffc02014b8:	09500593          	li	a1,149
ffffffffc02014bc:	00005517          	auipc	a0,0x5
ffffffffc02014c0:	b6450513          	addi	a0,a0,-1180 # ffffffffc0206020 <commands+0x760>
ffffffffc02014c4:	f8bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02014c8:	00005697          	auipc	a3,0x5
ffffffffc02014cc:	e3868693          	addi	a3,a3,-456 # ffffffffc0206300 <commands+0xa40>
ffffffffc02014d0:	00005617          	auipc	a2,0x5
ffffffffc02014d4:	b3860613          	addi	a2,a2,-1224 # ffffffffc0206008 <commands+0x748>
ffffffffc02014d8:	0e800593          	li	a1,232
ffffffffc02014dc:	00005517          	auipc	a0,0x5
ffffffffc02014e0:	b4450513          	addi	a0,a0,-1212 # ffffffffc0206020 <commands+0x760>
ffffffffc02014e4:	f6bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02014e8:	00005697          	auipc	a3,0x5
ffffffffc02014ec:	df868693          	addi	a3,a3,-520 # ffffffffc02062e0 <commands+0xa20>
ffffffffc02014f0:	00005617          	auipc	a2,0x5
ffffffffc02014f4:	b1860613          	addi	a2,a2,-1256 # ffffffffc0206008 <commands+0x748>
ffffffffc02014f8:	0e600593          	li	a1,230
ffffffffc02014fc:	00005517          	auipc	a0,0x5
ffffffffc0201500:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206020 <commands+0x760>
ffffffffc0201504:	f4bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201508:	00005697          	auipc	a3,0x5
ffffffffc020150c:	db068693          	addi	a3,a3,-592 # ffffffffc02062b8 <commands+0x9f8>
ffffffffc0201510:	00005617          	auipc	a2,0x5
ffffffffc0201514:	af860613          	addi	a2,a2,-1288 # ffffffffc0206008 <commands+0x748>
ffffffffc0201518:	0e400593          	li	a1,228
ffffffffc020151c:	00005517          	auipc	a0,0x5
ffffffffc0201520:	b0450513          	addi	a0,a0,-1276 # ffffffffc0206020 <commands+0x760>
ffffffffc0201524:	f2bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201528:	00005697          	auipc	a3,0x5
ffffffffc020152c:	d6868693          	addi	a3,a3,-664 # ffffffffc0206290 <commands+0x9d0>
ffffffffc0201530:	00005617          	auipc	a2,0x5
ffffffffc0201534:	ad860613          	addi	a2,a2,-1320 # ffffffffc0206008 <commands+0x748>
ffffffffc0201538:	0e300593          	li	a1,227
ffffffffc020153c:	00005517          	auipc	a0,0x5
ffffffffc0201540:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206020 <commands+0x760>
ffffffffc0201544:	f0bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201548:	00005697          	auipc	a3,0x5
ffffffffc020154c:	d3868693          	addi	a3,a3,-712 # ffffffffc0206280 <commands+0x9c0>
ffffffffc0201550:	00005617          	auipc	a2,0x5
ffffffffc0201554:	ab860613          	addi	a2,a2,-1352 # ffffffffc0206008 <commands+0x748>
ffffffffc0201558:	0de00593          	li	a1,222
ffffffffc020155c:	00005517          	auipc	a0,0x5
ffffffffc0201560:	ac450513          	addi	a0,a0,-1340 # ffffffffc0206020 <commands+0x760>
ffffffffc0201564:	eebfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201568:	00005697          	auipc	a3,0x5
ffffffffc020156c:	c1868693          	addi	a3,a3,-1000 # ffffffffc0206180 <commands+0x8c0>
ffffffffc0201570:	00005617          	auipc	a2,0x5
ffffffffc0201574:	a9860613          	addi	a2,a2,-1384 # ffffffffc0206008 <commands+0x748>
ffffffffc0201578:	0dd00593          	li	a1,221
ffffffffc020157c:	00005517          	auipc	a0,0x5
ffffffffc0201580:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206020 <commands+0x760>
ffffffffc0201584:	ecbfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201588:	00005697          	auipc	a3,0x5
ffffffffc020158c:	cd868693          	addi	a3,a3,-808 # ffffffffc0206260 <commands+0x9a0>
ffffffffc0201590:	00005617          	auipc	a2,0x5
ffffffffc0201594:	a7860613          	addi	a2,a2,-1416 # ffffffffc0206008 <commands+0x748>
ffffffffc0201598:	0dc00593          	li	a1,220
ffffffffc020159c:	00005517          	auipc	a0,0x5
ffffffffc02015a0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0206020 <commands+0x760>
ffffffffc02015a4:	eabfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02015a8:	00005697          	auipc	a3,0x5
ffffffffc02015ac:	c8868693          	addi	a3,a3,-888 # ffffffffc0206230 <commands+0x970>
ffffffffc02015b0:	00005617          	auipc	a2,0x5
ffffffffc02015b4:	a5860613          	addi	a2,a2,-1448 # ffffffffc0206008 <commands+0x748>
ffffffffc02015b8:	0db00593          	li	a1,219
ffffffffc02015bc:	00005517          	auipc	a0,0x5
ffffffffc02015c0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0206020 <commands+0x760>
ffffffffc02015c4:	e8bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015c8:	00005697          	auipc	a3,0x5
ffffffffc02015cc:	c5068693          	addi	a3,a3,-944 # ffffffffc0206218 <commands+0x958>
ffffffffc02015d0:	00005617          	auipc	a2,0x5
ffffffffc02015d4:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206008 <commands+0x748>
ffffffffc02015d8:	0da00593          	li	a1,218
ffffffffc02015dc:	00005517          	auipc	a0,0x5
ffffffffc02015e0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0206020 <commands+0x760>
ffffffffc02015e4:	e6bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015e8:	00005697          	auipc	a3,0x5
ffffffffc02015ec:	b9868693          	addi	a3,a3,-1128 # ffffffffc0206180 <commands+0x8c0>
ffffffffc02015f0:	00005617          	auipc	a2,0x5
ffffffffc02015f4:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206008 <commands+0x748>
ffffffffc02015f8:	0d400593          	li	a1,212
ffffffffc02015fc:	00005517          	auipc	a0,0x5
ffffffffc0201600:	a2450513          	addi	a0,a0,-1500 # ffffffffc0206020 <commands+0x760>
ffffffffc0201604:	e4bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201608:	00005697          	auipc	a3,0x5
ffffffffc020160c:	bf868693          	addi	a3,a3,-1032 # ffffffffc0206200 <commands+0x940>
ffffffffc0201610:	00005617          	auipc	a2,0x5
ffffffffc0201614:	9f860613          	addi	a2,a2,-1544 # ffffffffc0206008 <commands+0x748>
ffffffffc0201618:	0cf00593          	li	a1,207
ffffffffc020161c:	00005517          	auipc	a0,0x5
ffffffffc0201620:	a0450513          	addi	a0,a0,-1532 # ffffffffc0206020 <commands+0x760>
ffffffffc0201624:	e2bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201628:	00005697          	auipc	a3,0x5
ffffffffc020162c:	cf868693          	addi	a3,a3,-776 # ffffffffc0206320 <commands+0xa60>
ffffffffc0201630:	00005617          	auipc	a2,0x5
ffffffffc0201634:	9d860613          	addi	a2,a2,-1576 # ffffffffc0206008 <commands+0x748>
ffffffffc0201638:	0ed00593          	li	a1,237
ffffffffc020163c:	00005517          	auipc	a0,0x5
ffffffffc0201640:	9e450513          	addi	a0,a0,-1564 # ffffffffc0206020 <commands+0x760>
ffffffffc0201644:	e0bfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(total == 0);
ffffffffc0201648:	00005697          	auipc	a3,0x5
ffffffffc020164c:	d0868693          	addi	a3,a3,-760 # ffffffffc0206350 <commands+0xa90>
ffffffffc0201650:	00005617          	auipc	a2,0x5
ffffffffc0201654:	9b860613          	addi	a2,a2,-1608 # ffffffffc0206008 <commands+0x748>
ffffffffc0201658:	0fd00593          	li	a1,253
ffffffffc020165c:	00005517          	auipc	a0,0x5
ffffffffc0201660:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206020 <commands+0x760>
ffffffffc0201664:	debfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201668:	00005697          	auipc	a3,0x5
ffffffffc020166c:	9d068693          	addi	a3,a3,-1584 # ffffffffc0206038 <commands+0x778>
ffffffffc0201670:	00005617          	auipc	a2,0x5
ffffffffc0201674:	99860613          	addi	a2,a2,-1640 # ffffffffc0206008 <commands+0x748>
ffffffffc0201678:	0c900593          	li	a1,201
ffffffffc020167c:	00005517          	auipc	a0,0x5
ffffffffc0201680:	9a450513          	addi	a0,a0,-1628 # ffffffffc0206020 <commands+0x760>
ffffffffc0201684:	dcbfe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201688:	00005697          	auipc	a3,0x5
ffffffffc020168c:	9f068693          	addi	a3,a3,-1552 # ffffffffc0206078 <commands+0x7b8>
ffffffffc0201690:	00005617          	auipc	a2,0x5
ffffffffc0201694:	97860613          	addi	a2,a2,-1672 # ffffffffc0206008 <commands+0x748>
ffffffffc0201698:	08e00593          	li	a1,142
ffffffffc020169c:	00005517          	auipc	a0,0x5
ffffffffc02016a0:	98450513          	addi	a0,a0,-1660 # ffffffffc0206020 <commands+0x760>
ffffffffc02016a4:	dabfe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02016a8 <default_free_pages>:
{
ffffffffc02016a8:	1141                	addi	sp,sp,-16
ffffffffc02016aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016ac:	10058363          	beqz	a1,ffffffffc02017b2 <default_free_pages+0x10a>
    for (; p != base + n; p++)
ffffffffc02016b0:	00659693          	slli	a3,a1,0x6
ffffffffc02016b4:	96aa                	add	a3,a3,a0
ffffffffc02016b6:	87aa                	mv	a5,a0
ffffffffc02016b8:	02d50063          	beq	a0,a3,ffffffffc02016d8 <default_free_pages+0x30>
ffffffffc02016bc:	6798                	ld	a4,8(a5)
ffffffffc02016be:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016c0:	eb69                	bnez	a4,ffffffffc0201792 <default_free_pages+0xea>
ffffffffc02016c2:	6798                	ld	a4,8(a5)
ffffffffc02016c4:	8b09                	andi	a4,a4,2
ffffffffc02016c6:	e771                	bnez	a4,ffffffffc0201792 <default_free_pages+0xea>
        p->flags = 0;
ffffffffc02016c8:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02016cc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02016d0:	04078793          	addi	a5,a5,64
ffffffffc02016d4:	fed794e3          	bne	a5,a3,ffffffffc02016bc <default_free_pages+0x14>
    base->property = n;
ffffffffc02016d8:	2581                	sext.w	a1,a1
ffffffffc02016da:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016dc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016e0:	4789                	li	a5,2
ffffffffc02016e2:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016e6:	000a5717          	auipc	a4,0xa5
ffffffffc02016ea:	0d270713          	addi	a4,a4,210 # ffffffffc02a67b8 <free_area>
ffffffffc02016ee:	4b10                	lw	a2,16(a4)
    list_entry_t *le = &free_list;
ffffffffc02016f0:	86ba                	mv	a3,a4
ffffffffc02016f2:	87ba                	mv	a5,a4
    nr_free += n;
ffffffffc02016f4:	9db1                	addw	a1,a1,a2
ffffffffc02016f6:	cb0c                	sw	a1,16(a4)
    while ((le = list_next(le)) != &free_list && le2page(le, page_link) < base)
ffffffffc02016f8:	a029                	j	ffffffffc0201702 <default_free_pages+0x5a>
ffffffffc02016fa:	fe878713          	addi	a4,a5,-24
ffffffffc02016fe:	00a77563          	bgeu	a4,a0,ffffffffc0201708 <default_free_pages+0x60>
ffffffffc0201702:	679c                	ld	a5,8(a5)
ffffffffc0201704:	fed79be3          	bne	a5,a3,ffffffffc02016fa <default_free_pages+0x52>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201708:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc020170a:	01850613          	addi	a2,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020170e:	e390                	sd	a2,0(a5)
ffffffffc0201710:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201712:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201714:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0201716:	00d70d63          	beq	a4,a3,ffffffffc0201730 <default_free_pages+0x88>
        if (p + p->property == base)
ffffffffc020171a:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020171e:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc0201722:	02081313          	slli	t1,a6,0x20
ffffffffc0201726:	01a35613          	srli	a2,t1,0x1a
ffffffffc020172a:	962e                	add	a2,a2,a1
ffffffffc020172c:	04c50163          	beq	a0,a2,ffffffffc020176e <default_free_pages+0xc6>
    if (le != &free_list)
ffffffffc0201730:	00d78c63          	beq	a5,a3,ffffffffc0201748 <default_free_pages+0xa0>
        if (base + base->property == p)
ffffffffc0201734:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201736:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020173a:	02061593          	slli	a1,a2,0x20
ffffffffc020173e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201742:	972a                	add	a4,a4,a0
ffffffffc0201744:	00e68563          	beq	a3,a4,ffffffffc020174e <default_free_pages+0xa6>
}
ffffffffc0201748:	60a2                	ld	ra,8(sp)
ffffffffc020174a:	0141                	addi	sp,sp,16
ffffffffc020174c:	8082                	ret
            base->property += p->property;
ffffffffc020174e:	ff87a703          	lw	a4,-8(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201752:	ff078693          	addi	a3,a5,-16
ffffffffc0201756:	9e39                	addw	a2,a2,a4
ffffffffc0201758:	c910                	sw	a2,16(a0)
ffffffffc020175a:	5775                	li	a4,-3
ffffffffc020175c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201760:	6398                	ld	a4,0(a5)
ffffffffc0201762:	679c                	ld	a5,8(a5)
}
ffffffffc0201764:	60a2                	ld	ra,8(sp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201766:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201768:	e398                	sd	a4,0(a5)
ffffffffc020176a:	0141                	addi	sp,sp,16
ffffffffc020176c:	8082                	ret
            p->property += base->property;
ffffffffc020176e:	491c                	lw	a5,16(a0)
ffffffffc0201770:	0107883b          	addw	a6,a5,a6
ffffffffc0201774:	ff072c23          	sw	a6,-8(a4)
ffffffffc0201778:	57f5                	li	a5,-3
ffffffffc020177a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020177e:	01853803          	ld	a6,24(a0)
ffffffffc0201782:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201784:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0201786:	00c83423          	sd	a2,8(a6)
    return listelm->next;
ffffffffc020178a:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020178c:	01063023          	sd	a6,0(a2)
ffffffffc0201790:	b745                	j	ffffffffc0201730 <default_free_pages+0x88>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201792:	00005697          	auipc	a3,0x5
ffffffffc0201796:	bd668693          	addi	a3,a3,-1066 # ffffffffc0206368 <commands+0xaa8>
ffffffffc020179a:	00005617          	auipc	a2,0x5
ffffffffc020179e:	86e60613          	addi	a2,a2,-1938 # ffffffffc0206008 <commands+0x748>
ffffffffc02017a2:	05900593          	li	a1,89
ffffffffc02017a6:	00005517          	auipc	a0,0x5
ffffffffc02017aa:	87a50513          	addi	a0,a0,-1926 # ffffffffc0206020 <commands+0x760>
ffffffffc02017ae:	ca1fe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(n > 0);
ffffffffc02017b2:	00005697          	auipc	a3,0x5
ffffffffc02017b6:	bae68693          	addi	a3,a3,-1106 # ffffffffc0206360 <commands+0xaa0>
ffffffffc02017ba:	00005617          	auipc	a2,0x5
ffffffffc02017be:	84e60613          	addi	a2,a2,-1970 # ffffffffc0206008 <commands+0x748>
ffffffffc02017c2:	05500593          	li	a1,85
ffffffffc02017c6:	00005517          	auipc	a0,0x5
ffffffffc02017ca:	85a50513          	addi	a0,a0,-1958 # ffffffffc0206020 <commands+0x760>
ffffffffc02017ce:	c81fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02017d2 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017d2:	c941                	beqz	a0,ffffffffc0201862 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc02017d4:	000a5597          	auipc	a1,0xa5
ffffffffc02017d8:	fe458593          	addi	a1,a1,-28 # ffffffffc02a67b8 <free_area>
ffffffffc02017dc:	0105a803          	lw	a6,16(a1)
ffffffffc02017e0:	872a                	mv	a4,a0
ffffffffc02017e2:	02081793          	slli	a5,a6,0x20
ffffffffc02017e6:	9381                	srli	a5,a5,0x20
ffffffffc02017e8:	00a7ee63          	bltu	a5,a0,ffffffffc0201804 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017ec:	87ae                	mv	a5,a1
ffffffffc02017ee:	a801                	j	ffffffffc02017fe <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc02017f0:	ff87a683          	lw	a3,-8(a5)
ffffffffc02017f4:	02069613          	slli	a2,a3,0x20
ffffffffc02017f8:	9201                	srli	a2,a2,0x20
ffffffffc02017fa:	00e67763          	bgeu	a2,a4,ffffffffc0201808 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017fe:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0201800:	feb798e3          	bne	a5,a1,ffffffffc02017f0 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201804:	4501                	li	a0,0
}
ffffffffc0201806:	8082                	ret
    return listelm->prev;
ffffffffc0201808:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020180c:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201810:	fe878513          	addi	a0,a5,-24
            rest->property = page->property - n;
ffffffffc0201814:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201818:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020181c:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0201820:	02c77863          	bgeu	a4,a2,ffffffffc0201850 <default_alloc_pages+0x7e>
            struct Page *rest = page + n;
ffffffffc0201824:	071a                	slli	a4,a4,0x6
ffffffffc0201826:	972a                	add	a4,a4,a0
            rest->property = page->property - n;
ffffffffc0201828:	41c686bb          	subw	a3,a3,t3
ffffffffc020182c:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020182e:	00870613          	addi	a2,a4,8
ffffffffc0201832:	4689                	li	a3,2
ffffffffc0201834:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201838:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(rest->page_link));
ffffffffc020183c:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201840:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201844:	e290                	sd	a2,0(a3)
ffffffffc0201846:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020184a:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc020184c:	01173c23          	sd	a7,24(a4)
ffffffffc0201850:	41c8083b          	subw	a6,a6,t3
ffffffffc0201854:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201858:	5775                	li	a4,-3
ffffffffc020185a:	17c1                	addi	a5,a5,-16
ffffffffc020185c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201860:	8082                	ret
{
ffffffffc0201862:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201864:	00005697          	auipc	a3,0x5
ffffffffc0201868:	afc68693          	addi	a3,a3,-1284 # ffffffffc0206360 <commands+0xaa0>
ffffffffc020186c:	00004617          	auipc	a2,0x4
ffffffffc0201870:	79c60613          	addi	a2,a2,1948 # ffffffffc0206008 <commands+0x748>
ffffffffc0201874:	02e00593          	li	a1,46
ffffffffc0201878:	00004517          	auipc	a0,0x4
ffffffffc020187c:	7a850513          	addi	a0,a0,1960 # ffffffffc0206020 <commands+0x760>
{
ffffffffc0201880:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201882:	bcdfe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201886 <default_init_memmap>:
{
ffffffffc0201886:	1141                	addi	sp,sp,-16
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	c5c9                	beqz	a1,ffffffffc0201914 <default_init_memmap+0x8e>
    for (; p != base + n; p++)
ffffffffc020188c:	00659693          	slli	a3,a1,0x6
ffffffffc0201890:	96aa                	add	a3,a3,a0
ffffffffc0201892:	87aa                	mv	a5,a0
ffffffffc0201894:	00d50f63          	beq	a0,a3,ffffffffc02018b2 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201898:	6798                	ld	a4,8(a5)
ffffffffc020189a:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc020189c:	cf29                	beqz	a4,ffffffffc02018f6 <default_init_memmap+0x70>
        p->flags = p->property = 0;
ffffffffc020189e:	0007a823          	sw	zero,16(a5)
ffffffffc02018a2:	0007b423          	sd	zero,8(a5)
ffffffffc02018a6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02018aa:	04078793          	addi	a5,a5,64
ffffffffc02018ae:	fef695e3          	bne	a3,a5,ffffffffc0201898 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02018b2:	2581                	sext.w	a1,a1
ffffffffc02018b4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018b6:	4789                	li	a5,2
ffffffffc02018b8:	00850713          	addi	a4,a0,8
ffffffffc02018bc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018c0:	000a5717          	auipc	a4,0xa5
ffffffffc02018c4:	ef870713          	addi	a4,a4,-264 # ffffffffc02a67b8 <free_area>
ffffffffc02018c8:	4b10                	lw	a2,16(a4)
    list_entry_t *le = &free_list;
ffffffffc02018ca:	86ba                	mv	a3,a4
ffffffffc02018cc:	87ba                	mv	a5,a4
    nr_free += n;
ffffffffc02018ce:	9db1                	addw	a1,a1,a2
ffffffffc02018d0:	cb0c                	sw	a1,16(a4)
    while ((le = list_next(le)) != &free_list && le2page(le, page_link) < base)
ffffffffc02018d2:	a029                	j	ffffffffc02018dc <default_init_memmap+0x56>
ffffffffc02018d4:	fe878713          	addi	a4,a5,-24
ffffffffc02018d8:	00a77563          	bgeu	a4,a0,ffffffffc02018e2 <default_init_memmap+0x5c>
    return listelm->next;
ffffffffc02018dc:	679c                	ld	a5,8(a5)
ffffffffc02018de:	fed79be3          	bne	a5,a3,ffffffffc02018d4 <default_init_memmap+0x4e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018e2:	6398                	ld	a4,0(a5)
    list_add_before(le, &(base->page_link));
ffffffffc02018e4:	01850693          	addi	a3,a0,24
    prev->next = next->prev = elm;
ffffffffc02018e8:	e394                	sd	a3,0(a5)
}
ffffffffc02018ea:	60a2                	ld	ra,8(sp)
ffffffffc02018ec:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02018ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018f0:	ed18                	sd	a4,24(a0)
ffffffffc02018f2:	0141                	addi	sp,sp,16
ffffffffc02018f4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02018f6:	00005697          	auipc	a3,0x5
ffffffffc02018fa:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0206390 <commands+0xad0>
ffffffffc02018fe:	00004617          	auipc	a2,0x4
ffffffffc0201902:	70a60613          	addi	a2,a2,1802 # ffffffffc0206008 <commands+0x748>
ffffffffc0201906:	45ed                	li	a1,27
ffffffffc0201908:	00004517          	auipc	a0,0x4
ffffffffc020190c:	71850513          	addi	a0,a0,1816 # ffffffffc0206020 <commands+0x760>
ffffffffc0201910:	b3ffe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(n > 0);
ffffffffc0201914:	00005697          	auipc	a3,0x5
ffffffffc0201918:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206360 <commands+0xaa0>
ffffffffc020191c:	00004617          	auipc	a2,0x4
ffffffffc0201920:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206008 <commands+0x748>
ffffffffc0201924:	45dd                	li	a1,23
ffffffffc0201926:	00004517          	auipc	a0,0x4
ffffffffc020192a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0206020 <commands+0x760>
ffffffffc020192e:	b21fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201932 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201932:	c94d                	beqz	a0,ffffffffc02019e4 <slob_free+0xb2>
{
ffffffffc0201934:	1141                	addi	sp,sp,-16
ffffffffc0201936:	e022                	sd	s0,0(sp)
ffffffffc0201938:	e406                	sd	ra,8(sp)
ffffffffc020193a:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020193c:	e9c1                	bnez	a1,ffffffffc02019cc <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020193e:	100027f3          	csrr	a5,sstatus
ffffffffc0201942:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201944:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201946:	ebd9                	bnez	a5,ffffffffc02019dc <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201948:	000a5617          	auipc	a2,0xa5
ffffffffc020194c:	a6060613          	addi	a2,a2,-1440 # ffffffffc02a63a8 <slobfree>
ffffffffc0201950:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201952:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201954:	679c                	ld	a5,8(a5)
ffffffffc0201956:	02877a63          	bgeu	a4,s0,ffffffffc020198a <slob_free+0x58>
ffffffffc020195a:	00f46463          	bltu	s0,a5,ffffffffc0201962 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020195e:	fef76ae3          	bltu	a4,a5,ffffffffc0201952 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201962:	400c                	lw	a1,0(s0)
ffffffffc0201964:	00459693          	slli	a3,a1,0x4
ffffffffc0201968:	96a2                	add	a3,a3,s0
ffffffffc020196a:	02d78a63          	beq	a5,a3,ffffffffc020199e <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc020196e:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201970:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201972:	00469793          	slli	a5,a3,0x4
ffffffffc0201976:	97ba                	add	a5,a5,a4
ffffffffc0201978:	02f40e63          	beq	s0,a5,ffffffffc02019b4 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc020197c:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020197e:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201980:	e129                	bnez	a0,ffffffffc02019c2 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201982:	60a2                	ld	ra,8(sp)
ffffffffc0201984:	6402                	ld	s0,0(sp)
ffffffffc0201986:	0141                	addi	sp,sp,16
ffffffffc0201988:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020198a:	fcf764e3          	bltu	a4,a5,ffffffffc0201952 <slob_free+0x20>
ffffffffc020198e:	fcf472e3          	bgeu	s0,a5,ffffffffc0201952 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201992:	400c                	lw	a1,0(s0)
ffffffffc0201994:	00459693          	slli	a3,a1,0x4
ffffffffc0201998:	96a2                	add	a3,a3,s0
ffffffffc020199a:	fcd79ae3          	bne	a5,a3,ffffffffc020196e <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020199e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02019a0:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02019a2:	9db5                	addw	a1,a1,a3
ffffffffc02019a4:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc02019a6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02019a8:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02019aa:	00469793          	slli	a5,a3,0x4
ffffffffc02019ae:	97ba                	add	a5,a5,a4
ffffffffc02019b0:	fcf416e3          	bne	s0,a5,ffffffffc020197c <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02019b4:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02019b6:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02019b8:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02019ba:	9ebd                	addw	a3,a3,a5
ffffffffc02019bc:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02019be:	e70c                	sd	a1,8(a4)
ffffffffc02019c0:	d169                	beqz	a0,ffffffffc0201982 <slob_free+0x50>
}
ffffffffc02019c2:	6402                	ld	s0,0(sp)
ffffffffc02019c4:	60a2                	ld	ra,8(sp)
ffffffffc02019c6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02019c8:	fa7fe06f          	j	ffffffffc020096e <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02019cc:	25bd                	addiw	a1,a1,15
ffffffffc02019ce:	8191                	srli	a1,a1,0x4
ffffffffc02019d0:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019d2:	100027f3          	csrr	a5,sstatus
ffffffffc02019d6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019d8:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019da:	d7bd                	beqz	a5,ffffffffc0201948 <slob_free+0x16>
        intr_disable();
ffffffffc02019dc:	f99fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc02019e0:	4505                	li	a0,1
ffffffffc02019e2:	b79d                	j	ffffffffc0201948 <slob_free+0x16>
ffffffffc02019e4:	8082                	ret

ffffffffc02019e6 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019e6:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019e8:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019ea:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019ee:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019f0:	34e000ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
	if (!page)
ffffffffc02019f4:	c91d                	beqz	a0,ffffffffc0201a2a <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019f6:	000a9697          	auipc	a3,0xa9
ffffffffc02019fa:	e326b683          	ld	a3,-462(a3) # ffffffffc02aa828 <pages>
ffffffffc02019fe:	8d15                	sub	a0,a0,a3
ffffffffc0201a00:	8519                	srai	a0,a0,0x6
ffffffffc0201a02:	00006697          	auipc	a3,0x6
ffffffffc0201a06:	aee6b683          	ld	a3,-1298(a3) # ffffffffc02074f0 <nbase>
ffffffffc0201a0a:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201a0c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201a10:	83b1                	srli	a5,a5,0xc
ffffffffc0201a12:	000a9717          	auipc	a4,0xa9
ffffffffc0201a16:	e0e73703          	ld	a4,-498(a4) # ffffffffc02aa820 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a1a:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201a1c:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a30 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201a20:	000a9697          	auipc	a3,0xa9
ffffffffc0201a24:	e206b683          	ld	a3,-480(a3) # ffffffffc02aa840 <va_pa_offset>
ffffffffc0201a28:	9536                	add	a0,a0,a3
}
ffffffffc0201a2a:	60a2                	ld	ra,8(sp)
ffffffffc0201a2c:	0141                	addi	sp,sp,16
ffffffffc0201a2e:	8082                	ret
ffffffffc0201a30:	86aa                	mv	a3,a0
ffffffffc0201a32:	00005617          	auipc	a2,0x5
ffffffffc0201a36:	9be60613          	addi	a2,a2,-1602 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0201a3a:	07100593          	li	a1,113
ffffffffc0201a3e:	00005517          	auipc	a0,0x5
ffffffffc0201a42:	9da50513          	addi	a0,a0,-1574 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0201a46:	a09fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201a4a <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201a4a:	1101                	addi	sp,sp,-32
ffffffffc0201a4c:	ec06                	sd	ra,24(sp)
ffffffffc0201a4e:	e822                	sd	s0,16(sp)
ffffffffc0201a50:	e426                	sd	s1,8(sp)
ffffffffc0201a52:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a54:	01050713          	addi	a4,a0,16
ffffffffc0201a58:	6785                	lui	a5,0x1
ffffffffc0201a5a:	0cf77363          	bgeu	a4,a5,ffffffffc0201b20 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a5e:	00f50493          	addi	s1,a0,15
ffffffffc0201a62:	8091                	srli	s1,s1,0x4
ffffffffc0201a64:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a66:	10002673          	csrr	a2,sstatus
ffffffffc0201a6a:	8a09                	andi	a2,a2,2
ffffffffc0201a6c:	e25d                	bnez	a2,ffffffffc0201b12 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a6e:	000a5917          	auipc	s2,0xa5
ffffffffc0201a72:	93a90913          	addi	s2,s2,-1734 # ffffffffc02a63a8 <slobfree>
ffffffffc0201a76:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a7a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201a7c:	4398                	lw	a4,0(a5)
ffffffffc0201a7e:	08975e63          	bge	a4,s1,ffffffffc0201b1a <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201a82:	00f68b63          	beq	a3,a5,ffffffffc0201a98 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a86:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a88:	4018                	lw	a4,0(s0)
ffffffffc0201a8a:	02975a63          	bge	a4,s1,ffffffffc0201abe <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201a8e:	00093683          	ld	a3,0(s2)
ffffffffc0201a92:	87a2                	mv	a5,s0
ffffffffc0201a94:	fef699e3          	bne	a3,a5,ffffffffc0201a86 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201a98:	ee31                	bnez	a2,ffffffffc0201af4 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a9a:	4501                	li	a0,0
ffffffffc0201a9c:	f4bff0ef          	jal	ra,ffffffffc02019e6 <__slob_get_free_pages.constprop.0>
ffffffffc0201aa0:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201aa2:	cd05                	beqz	a0,ffffffffc0201ada <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201aa4:	6585                	lui	a1,0x1
ffffffffc0201aa6:	e8dff0ef          	jal	ra,ffffffffc0201932 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201aaa:	10002673          	csrr	a2,sstatus
ffffffffc0201aae:	8a09                	andi	a2,a2,2
ffffffffc0201ab0:	ee05                	bnez	a2,ffffffffc0201ae8 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201ab2:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ab6:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201ab8:	4018                	lw	a4,0(s0)
ffffffffc0201aba:	fc974ae3          	blt	a4,s1,ffffffffc0201a8e <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201abe:	04e48763          	beq	s1,a4,ffffffffc0201b0c <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201ac2:	00449693          	slli	a3,s1,0x4
ffffffffc0201ac6:	96a2                	add	a3,a3,s0
ffffffffc0201ac8:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201aca:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201acc:	9f05                	subw	a4,a4,s1
ffffffffc0201ace:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201ad0:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201ad2:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201ad4:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201ad8:	e20d                	bnez	a2,ffffffffc0201afa <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201ada:	60e2                	ld	ra,24(sp)
ffffffffc0201adc:	8522                	mv	a0,s0
ffffffffc0201ade:	6442                	ld	s0,16(sp)
ffffffffc0201ae0:	64a2                	ld	s1,8(sp)
ffffffffc0201ae2:	6902                	ld	s2,0(sp)
ffffffffc0201ae4:	6105                	addi	sp,sp,32
ffffffffc0201ae6:	8082                	ret
        intr_disable();
ffffffffc0201ae8:	e8dfe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
			cur = slobfree;
ffffffffc0201aec:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201af0:	4605                	li	a2,1
ffffffffc0201af2:	b7d1                	j	ffffffffc0201ab6 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201af4:	e7bfe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201af8:	b74d                	j	ffffffffc0201a9a <slob_alloc.constprop.0+0x50>
ffffffffc0201afa:	e75fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
}
ffffffffc0201afe:	60e2                	ld	ra,24(sp)
ffffffffc0201b00:	8522                	mv	a0,s0
ffffffffc0201b02:	6442                	ld	s0,16(sp)
ffffffffc0201b04:	64a2                	ld	s1,8(sp)
ffffffffc0201b06:	6902                	ld	s2,0(sp)
ffffffffc0201b08:	6105                	addi	sp,sp,32
ffffffffc0201b0a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201b0c:	6418                	ld	a4,8(s0)
ffffffffc0201b0e:	e798                	sd	a4,8(a5)
ffffffffc0201b10:	b7d1                	j	ffffffffc0201ad4 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201b12:	e63fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc0201b16:	4605                	li	a2,1
ffffffffc0201b18:	bf99                	j	ffffffffc0201a6e <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201b1a:	843e                	mv	s0,a5
ffffffffc0201b1c:	87b6                	mv	a5,a3
ffffffffc0201b1e:	b745                	j	ffffffffc0201abe <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201b20:	00005697          	auipc	a3,0x5
ffffffffc0201b24:	90868693          	addi	a3,a3,-1784 # ffffffffc0206428 <default_pmm_manager+0x70>
ffffffffc0201b28:	00004617          	auipc	a2,0x4
ffffffffc0201b2c:	4e060613          	addi	a2,a2,1248 # ffffffffc0206008 <commands+0x748>
ffffffffc0201b30:	06300593          	li	a1,99
ffffffffc0201b34:	00005517          	auipc	a0,0x5
ffffffffc0201b38:	91450513          	addi	a0,a0,-1772 # ffffffffc0206448 <default_pmm_manager+0x90>
ffffffffc0201b3c:	913fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201b40 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201b40:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201b42:	00005517          	auipc	a0,0x5
ffffffffc0201b46:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206460 <default_pmm_manager+0xa8>
{
ffffffffc0201b4a:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201b4c:	e48fe0ef          	jal	ra,ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201b50:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b52:	00005517          	auipc	a0,0x5
ffffffffc0201b56:	92650513          	addi	a0,a0,-1754 # ffffffffc0206478 <default_pmm_manager+0xc0>
}
ffffffffc0201b5a:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b5c:	e38fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201b60 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b60:	1101                	addi	sp,sp,-32
ffffffffc0201b62:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b64:	6905                	lui	s2,0x1
{
ffffffffc0201b66:	e822                	sd	s0,16(sp)
ffffffffc0201b68:	ec06                	sd	ra,24(sp)
ffffffffc0201b6a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b6c:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd1>
{
ffffffffc0201b70:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b72:	04a7f963          	bgeu	a5,a0,ffffffffc0201bc4 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b76:	4561                	li	a0,24
ffffffffc0201b78:	ed3ff0ef          	jal	ra,ffffffffc0201a4a <slob_alloc.constprop.0>
ffffffffc0201b7c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b7e:	c929                	beqz	a0,ffffffffc0201bd0 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b80:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b84:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201b86:	00f95763          	bge	s2,a5,ffffffffc0201b94 <kmalloc+0x34>
ffffffffc0201b8a:	6705                	lui	a4,0x1
ffffffffc0201b8c:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b8e:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201b90:	fef74ee3          	blt	a4,a5,ffffffffc0201b8c <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b94:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b96:	e51ff0ef          	jal	ra,ffffffffc02019e6 <__slob_get_free_pages.constprop.0>
ffffffffc0201b9a:	e488                	sd	a0,8(s1)
ffffffffc0201b9c:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201b9e:	c525                	beqz	a0,ffffffffc0201c06 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ba0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ba4:	8b89                	andi	a5,a5,2
ffffffffc0201ba6:	ef8d                	bnez	a5,ffffffffc0201be0 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201ba8:	000a9797          	auipc	a5,0xa9
ffffffffc0201bac:	c6078793          	addi	a5,a5,-928 # ffffffffc02aa808 <bigblocks>
ffffffffc0201bb0:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201bb2:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201bb4:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201bb6:	60e2                	ld	ra,24(sp)
ffffffffc0201bb8:	8522                	mv	a0,s0
ffffffffc0201bba:	6442                	ld	s0,16(sp)
ffffffffc0201bbc:	64a2                	ld	s1,8(sp)
ffffffffc0201bbe:	6902                	ld	s2,0(sp)
ffffffffc0201bc0:	6105                	addi	sp,sp,32
ffffffffc0201bc2:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201bc4:	0541                	addi	a0,a0,16
ffffffffc0201bc6:	e85ff0ef          	jal	ra,ffffffffc0201a4a <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201bca:	01050413          	addi	s0,a0,16
ffffffffc0201bce:	f565                	bnez	a0,ffffffffc0201bb6 <kmalloc+0x56>
ffffffffc0201bd0:	4401                	li	s0,0
}
ffffffffc0201bd2:	60e2                	ld	ra,24(sp)
ffffffffc0201bd4:	8522                	mv	a0,s0
ffffffffc0201bd6:	6442                	ld	s0,16(sp)
ffffffffc0201bd8:	64a2                	ld	s1,8(sp)
ffffffffc0201bda:	6902                	ld	s2,0(sp)
ffffffffc0201bdc:	6105                	addi	sp,sp,32
ffffffffc0201bde:	8082                	ret
        intr_disable();
ffffffffc0201be0:	d95fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201be4:	000a9797          	auipc	a5,0xa9
ffffffffc0201be8:	c2478793          	addi	a5,a5,-988 # ffffffffc02aa808 <bigblocks>
ffffffffc0201bec:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201bee:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201bf0:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201bf2:	d7dfe0ef          	jal	ra,ffffffffc020096e <intr_enable>
		return bb->pages;
ffffffffc0201bf6:	6480                	ld	s0,8(s1)
}
ffffffffc0201bf8:	60e2                	ld	ra,24(sp)
ffffffffc0201bfa:	64a2                	ld	s1,8(sp)
ffffffffc0201bfc:	8522                	mv	a0,s0
ffffffffc0201bfe:	6442                	ld	s0,16(sp)
ffffffffc0201c00:	6902                	ld	s2,0(sp)
ffffffffc0201c02:	6105                	addi	sp,sp,32
ffffffffc0201c04:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c06:	45e1                	li	a1,24
ffffffffc0201c08:	8526                	mv	a0,s1
ffffffffc0201c0a:	d29ff0ef          	jal	ra,ffffffffc0201932 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201c0e:	b765                	j	ffffffffc0201bb6 <kmalloc+0x56>

ffffffffc0201c10 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201c10:	c169                	beqz	a0,ffffffffc0201cd2 <kfree+0xc2>
{
ffffffffc0201c12:	1101                	addi	sp,sp,-32
ffffffffc0201c14:	e822                	sd	s0,16(sp)
ffffffffc0201c16:	ec06                	sd	ra,24(sp)
ffffffffc0201c18:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201c1a:	03451793          	slli	a5,a0,0x34
ffffffffc0201c1e:	842a                	mv	s0,a0
ffffffffc0201c20:	e3d9                	bnez	a5,ffffffffc0201ca6 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c22:	100027f3          	csrr	a5,sstatus
ffffffffc0201c26:	8b89                	andi	a5,a5,2
ffffffffc0201c28:	e7d9                	bnez	a5,ffffffffc0201cb6 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c2a:	000a9797          	auipc	a5,0xa9
ffffffffc0201c2e:	bde7b783          	ld	a5,-1058(a5) # ffffffffc02aa808 <bigblocks>
    return 0;
ffffffffc0201c32:	4601                	li	a2,0
ffffffffc0201c34:	cbad                	beqz	a5,ffffffffc0201ca6 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201c36:	000a9697          	auipc	a3,0xa9
ffffffffc0201c3a:	bd268693          	addi	a3,a3,-1070 # ffffffffc02aa808 <bigblocks>
ffffffffc0201c3e:	a021                	j	ffffffffc0201c46 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c40:	01048693          	addi	a3,s1,16
ffffffffc0201c44:	c3a5                	beqz	a5,ffffffffc0201ca4 <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201c46:	6798                	ld	a4,8(a5)
ffffffffc0201c48:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201c4a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201c4c:	fe871ae3          	bne	a4,s0,ffffffffc0201c40 <kfree+0x30>
				*last = bb->next;
ffffffffc0201c50:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201c52:	ee2d                	bnez	a2,ffffffffc0201ccc <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201c54:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201c58:	4098                	lw	a4,0(s1)
ffffffffc0201c5a:	08f46963          	bltu	s0,a5,ffffffffc0201cec <kfree+0xdc>
ffffffffc0201c5e:	000a9697          	auipc	a3,0xa9
ffffffffc0201c62:	be26b683          	ld	a3,-1054(a3) # ffffffffc02aa840 <va_pa_offset>
ffffffffc0201c66:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201c68:	8031                	srli	s0,s0,0xc
ffffffffc0201c6a:	000a9797          	auipc	a5,0xa9
ffffffffc0201c6e:	bb67b783          	ld	a5,-1098(a5) # ffffffffc02aa820 <npage>
ffffffffc0201c72:	06f47163          	bgeu	s0,a5,ffffffffc0201cd4 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c76:	00006517          	auipc	a0,0x6
ffffffffc0201c7a:	87a53503          	ld	a0,-1926(a0) # ffffffffc02074f0 <nbase>
ffffffffc0201c7e:	8c09                	sub	s0,s0,a0
ffffffffc0201c80:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201c82:	000a9517          	auipc	a0,0xa9
ffffffffc0201c86:	ba653503          	ld	a0,-1114(a0) # ffffffffc02aa828 <pages>
ffffffffc0201c8a:	4585                	li	a1,1
ffffffffc0201c8c:	9522                	add	a0,a0,s0
ffffffffc0201c8e:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c92:	0ea000ef          	jal	ra,ffffffffc0201d7c <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c96:	6442                	ld	s0,16(sp)
ffffffffc0201c98:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c9a:	8526                	mv	a0,s1
}
ffffffffc0201c9c:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c9e:	45e1                	li	a1,24
}
ffffffffc0201ca0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ca2:	b941                	j	ffffffffc0201932 <slob_free>
ffffffffc0201ca4:	e20d                	bnez	a2,ffffffffc0201cc6 <kfree+0xb6>
ffffffffc0201ca6:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201caa:	6442                	ld	s0,16(sp)
ffffffffc0201cac:	60e2                	ld	ra,24(sp)
ffffffffc0201cae:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201cb0:	4581                	li	a1,0
}
ffffffffc0201cb2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201cb4:	b9bd                	j	ffffffffc0201932 <slob_free>
        intr_disable();
ffffffffc0201cb6:	cbffe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cba:	000a9797          	auipc	a5,0xa9
ffffffffc0201cbe:	b4e7b783          	ld	a5,-1202(a5) # ffffffffc02aa808 <bigblocks>
        return 1;
ffffffffc0201cc2:	4605                	li	a2,1
ffffffffc0201cc4:	fbad                	bnez	a5,ffffffffc0201c36 <kfree+0x26>
        intr_enable();
ffffffffc0201cc6:	ca9fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201cca:	bff1                	j	ffffffffc0201ca6 <kfree+0x96>
ffffffffc0201ccc:	ca3fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201cd0:	b751                	j	ffffffffc0201c54 <kfree+0x44>
ffffffffc0201cd2:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201cd4:	00004617          	auipc	a2,0x4
ffffffffc0201cd8:	7ec60613          	addi	a2,a2,2028 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc0201cdc:	06900593          	li	a1,105
ffffffffc0201ce0:	00004517          	auipc	a0,0x4
ffffffffc0201ce4:	73850513          	addi	a0,a0,1848 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0201ce8:	f66fe0ef          	jal	ra,ffffffffc020044e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201cec:	86a2                	mv	a3,s0
ffffffffc0201cee:	00004617          	auipc	a2,0x4
ffffffffc0201cf2:	7aa60613          	addi	a2,a2,1962 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc0201cf6:	07700593          	li	a1,119
ffffffffc0201cfa:	00004517          	auipc	a0,0x4
ffffffffc0201cfe:	71e50513          	addi	a0,a0,1822 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0201d02:	f4cfe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201d06 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201d06:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201d08:	00004617          	auipc	a2,0x4
ffffffffc0201d0c:	7b860613          	addi	a2,a2,1976 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc0201d10:	06900593          	li	a1,105
ffffffffc0201d14:	00004517          	auipc	a0,0x4
ffffffffc0201d18:	70450513          	addi	a0,a0,1796 # ffffffffc0206418 <default_pmm_manager+0x60>
pa2page(uintptr_t pa)
ffffffffc0201d1c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201d1e:	f30fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201d22 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc0201d22:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201d24:	00004617          	auipc	a2,0x4
ffffffffc0201d28:	7bc60613          	addi	a2,a2,1980 # ffffffffc02064e0 <default_pmm_manager+0x128>
ffffffffc0201d2c:	07f00593          	li	a1,127
ffffffffc0201d30:	00004517          	auipc	a0,0x4
ffffffffc0201d34:	6e850513          	addi	a0,a0,1768 # ffffffffc0206418 <default_pmm_manager+0x60>
pte2page(pte_t pte)
ffffffffc0201d38:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201d3a:	f14fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0201d3e <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d3e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d42:	8b89                	andi	a5,a5,2
ffffffffc0201d44:	e799                	bnez	a5,ffffffffc0201d52 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d46:	000a9797          	auipc	a5,0xa9
ffffffffc0201d4a:	aea7b783          	ld	a5,-1302(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201d4e:	6f9c                	ld	a5,24(a5)
ffffffffc0201d50:	8782                	jr	a5
{
ffffffffc0201d52:	1141                	addi	sp,sp,-16
ffffffffc0201d54:	e406                	sd	ra,8(sp)
ffffffffc0201d56:	e022                	sd	s0,0(sp)
ffffffffc0201d58:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201d5a:	c1bfe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d5e:	000a9797          	auipc	a5,0xa9
ffffffffc0201d62:	ad27b783          	ld	a5,-1326(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201d66:	6f9c                	ld	a5,24(a5)
ffffffffc0201d68:	8522                	mv	a0,s0
ffffffffc0201d6a:	9782                	jalr	a5
ffffffffc0201d6c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d6e:	c01fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201d72:	60a2                	ld	ra,8(sp)
ffffffffc0201d74:	8522                	mv	a0,s0
ffffffffc0201d76:	6402                	ld	s0,0(sp)
ffffffffc0201d78:	0141                	addi	sp,sp,16
ffffffffc0201d7a:	8082                	ret

ffffffffc0201d7c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201d7c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d80:	8b89                	andi	a5,a5,2
ffffffffc0201d82:	e799                	bnez	a5,ffffffffc0201d90 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d84:	000a9797          	auipc	a5,0xa9
ffffffffc0201d88:	aac7b783          	ld	a5,-1364(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201d8c:	739c                	ld	a5,32(a5)
ffffffffc0201d8e:	8782                	jr	a5
{
ffffffffc0201d90:	1101                	addi	sp,sp,-32
ffffffffc0201d92:	ec06                	sd	ra,24(sp)
ffffffffc0201d94:	e822                	sd	s0,16(sp)
ffffffffc0201d96:	e426                	sd	s1,8(sp)
ffffffffc0201d98:	842a                	mv	s0,a0
ffffffffc0201d9a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d9c:	bd9fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201da0:	000a9797          	auipc	a5,0xa9
ffffffffc0201da4:	a907b783          	ld	a5,-1392(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201da8:	739c                	ld	a5,32(a5)
ffffffffc0201daa:	85a6                	mv	a1,s1
ffffffffc0201dac:	8522                	mv	a0,s0
ffffffffc0201dae:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201db0:	6442                	ld	s0,16(sp)
ffffffffc0201db2:	60e2                	ld	ra,24(sp)
ffffffffc0201db4:	64a2                	ld	s1,8(sp)
ffffffffc0201db6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201db8:	bb7fe06f          	j	ffffffffc020096e <intr_enable>

ffffffffc0201dbc <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201dbc:	100027f3          	csrr	a5,sstatus
ffffffffc0201dc0:	8b89                	andi	a5,a5,2
ffffffffc0201dc2:	e799                	bnez	a5,ffffffffc0201dd0 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dc4:	000a9797          	auipc	a5,0xa9
ffffffffc0201dc8:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201dcc:	779c                	ld	a5,40(a5)
ffffffffc0201dce:	8782                	jr	a5
{
ffffffffc0201dd0:	1141                	addi	sp,sp,-16
ffffffffc0201dd2:	e406                	sd	ra,8(sp)
ffffffffc0201dd4:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dd6:	b9ffe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dda:	000a9797          	auipc	a5,0xa9
ffffffffc0201dde:	a567b783          	ld	a5,-1450(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201de2:	779c                	ld	a5,40(a5)
ffffffffc0201de4:	9782                	jalr	a5
ffffffffc0201de6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201de8:	b87fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201dec:	60a2                	ld	ra,8(sp)
ffffffffc0201dee:	8522                	mv	a0,s0
ffffffffc0201df0:	6402                	ld	s0,0(sp)
ffffffffc0201df2:	0141                	addi	sp,sp,16
ffffffffc0201df4:	8082                	ret

ffffffffc0201df6 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201df6:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201dfa:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0201dfe:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e00:	078e                	slli	a5,a5,0x3
{
ffffffffc0201e02:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e04:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201e08:	6094                	ld	a3,0(s1)
{
ffffffffc0201e0a:	f04a                	sd	s2,32(sp)
ffffffffc0201e0c:	ec4e                	sd	s3,24(sp)
ffffffffc0201e0e:	e852                	sd	s4,16(sp)
ffffffffc0201e10:	fc06                	sd	ra,56(sp)
ffffffffc0201e12:	f822                	sd	s0,48(sp)
ffffffffc0201e14:	e456                	sd	s5,8(sp)
ffffffffc0201e16:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201e18:	0016f793          	andi	a5,a3,1
{
ffffffffc0201e1c:	892e                	mv	s2,a1
ffffffffc0201e1e:	8a32                	mv	s4,a2
ffffffffc0201e20:	000a9997          	auipc	s3,0xa9
ffffffffc0201e24:	a0098993          	addi	s3,s3,-1536 # ffffffffc02aa820 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201e28:	efbd                	bnez	a5,ffffffffc0201ea6 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e2a:	14060c63          	beqz	a2,ffffffffc0201f82 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e2e:	100027f3          	csrr	a5,sstatus
ffffffffc0201e32:	8b89                	andi	a5,a5,2
ffffffffc0201e34:	14079963          	bnez	a5,ffffffffc0201f86 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e38:	000a9797          	auipc	a5,0xa9
ffffffffc0201e3c:	9f87b783          	ld	a5,-1544(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201e40:	6f9c                	ld	a5,24(a5)
ffffffffc0201e42:	4505                	li	a0,1
ffffffffc0201e44:	9782                	jalr	a5
ffffffffc0201e46:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e48:	12040d63          	beqz	s0,ffffffffc0201f82 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201e4c:	000a9b17          	auipc	s6,0xa9
ffffffffc0201e50:	9dcb0b13          	addi	s6,s6,-1572 # ffffffffc02aa828 <pages>
ffffffffc0201e54:	000b3503          	ld	a0,0(s6)
ffffffffc0201e58:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e5c:	000a9997          	auipc	s3,0xa9
ffffffffc0201e60:	9c498993          	addi	s3,s3,-1596 # ffffffffc02aa820 <npage>
ffffffffc0201e64:	40a40533          	sub	a0,s0,a0
ffffffffc0201e68:	8519                	srai	a0,a0,0x6
ffffffffc0201e6a:	9556                	add	a0,a0,s5
ffffffffc0201e6c:	0009b703          	ld	a4,0(s3)
ffffffffc0201e70:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e74:	4685                	li	a3,1
ffffffffc0201e76:	c014                	sw	a3,0(s0)
ffffffffc0201e78:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e7a:	0532                	slli	a0,a0,0xc
ffffffffc0201e7c:	16e7f763          	bgeu	a5,a4,ffffffffc0201fea <get_pte+0x1f4>
ffffffffc0201e80:	000a9797          	auipc	a5,0xa9
ffffffffc0201e84:	9c07b783          	ld	a5,-1600(a5) # ffffffffc02aa840 <va_pa_offset>
ffffffffc0201e88:	6605                	lui	a2,0x1
ffffffffc0201e8a:	4581                	li	a1,0
ffffffffc0201e8c:	953e                	add	a0,a0,a5
ffffffffc0201e8e:	7a0030ef          	jal	ra,ffffffffc020562e <memset>
    return page - pages + nbase;
ffffffffc0201e92:	000b3683          	ld	a3,0(s6)
ffffffffc0201e96:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e9a:	8699                	srai	a3,a3,0x6
ffffffffc0201e9c:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e9e:	06aa                	slli	a3,a3,0xa
ffffffffc0201ea0:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ea4:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ea6:	77fd                	lui	a5,0xfffff
ffffffffc0201ea8:	068a                	slli	a3,a3,0x2
ffffffffc0201eaa:	0009b703          	ld	a4,0(s3)
ffffffffc0201eae:	8efd                	and	a3,a3,a5
ffffffffc0201eb0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201eb4:	10e7ff63          	bgeu	a5,a4,ffffffffc0201fd2 <get_pte+0x1dc>
ffffffffc0201eb8:	000a9a97          	auipc	s5,0xa9
ffffffffc0201ebc:	988a8a93          	addi	s5,s5,-1656 # ffffffffc02aa840 <va_pa_offset>
ffffffffc0201ec0:	000ab403          	ld	s0,0(s5)
ffffffffc0201ec4:	01595793          	srli	a5,s2,0x15
ffffffffc0201ec8:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ecc:	96a2                	add	a3,a3,s0
ffffffffc0201ece:	00379413          	slli	s0,a5,0x3
ffffffffc0201ed2:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201ed4:	6014                	ld	a3,0(s0)
ffffffffc0201ed6:	0016f793          	andi	a5,a3,1
ffffffffc0201eda:	ebad                	bnez	a5,ffffffffc0201f4c <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201edc:	0a0a0363          	beqz	s4,ffffffffc0201f82 <get_pte+0x18c>
ffffffffc0201ee0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ee4:	8b89                	andi	a5,a5,2
ffffffffc0201ee6:	efcd                	bnez	a5,ffffffffc0201fa0 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ee8:	000a9797          	auipc	a5,0xa9
ffffffffc0201eec:	9487b783          	ld	a5,-1720(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201ef0:	6f9c                	ld	a5,24(a5)
ffffffffc0201ef2:	4505                	li	a0,1
ffffffffc0201ef4:	9782                	jalr	a5
ffffffffc0201ef6:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ef8:	c4c9                	beqz	s1,ffffffffc0201f82 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201efa:	000a9b17          	auipc	s6,0xa9
ffffffffc0201efe:	92eb0b13          	addi	s6,s6,-1746 # ffffffffc02aa828 <pages>
ffffffffc0201f02:	000b3503          	ld	a0,0(s6)
ffffffffc0201f06:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f0a:	0009b703          	ld	a4,0(s3)
ffffffffc0201f0e:	40a48533          	sub	a0,s1,a0
ffffffffc0201f12:	8519                	srai	a0,a0,0x6
ffffffffc0201f14:	9552                	add	a0,a0,s4
ffffffffc0201f16:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f1a:	4685                	li	a3,1
ffffffffc0201f1c:	c094                	sw	a3,0(s1)
ffffffffc0201f1e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f20:	0532                	slli	a0,a0,0xc
ffffffffc0201f22:	0ee7f163          	bgeu	a5,a4,ffffffffc0202004 <get_pte+0x20e>
ffffffffc0201f26:	000ab783          	ld	a5,0(s5)
ffffffffc0201f2a:	6605                	lui	a2,0x1
ffffffffc0201f2c:	4581                	li	a1,0
ffffffffc0201f2e:	953e                	add	a0,a0,a5
ffffffffc0201f30:	6fe030ef          	jal	ra,ffffffffc020562e <memset>
    return page - pages + nbase;
ffffffffc0201f34:	000b3683          	ld	a3,0(s6)
ffffffffc0201f38:	40d486b3          	sub	a3,s1,a3
ffffffffc0201f3c:	8699                	srai	a3,a3,0x6
ffffffffc0201f3e:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f40:	06aa                	slli	a3,a3,0xa
ffffffffc0201f42:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f46:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f48:	0009b703          	ld	a4,0(s3)
ffffffffc0201f4c:	068a                	slli	a3,a3,0x2
ffffffffc0201f4e:	757d                	lui	a0,0xfffff
ffffffffc0201f50:	8ee9                	and	a3,a3,a0
ffffffffc0201f52:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f56:	06e7f263          	bgeu	a5,a4,ffffffffc0201fba <get_pte+0x1c4>
ffffffffc0201f5a:	000ab503          	ld	a0,0(s5)
ffffffffc0201f5e:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f62:	1ff97913          	andi	s2,s2,511
ffffffffc0201f66:	96aa                	add	a3,a3,a0
ffffffffc0201f68:	00391513          	slli	a0,s2,0x3
ffffffffc0201f6c:	9536                	add	a0,a0,a3
}
ffffffffc0201f6e:	70e2                	ld	ra,56(sp)
ffffffffc0201f70:	7442                	ld	s0,48(sp)
ffffffffc0201f72:	74a2                	ld	s1,40(sp)
ffffffffc0201f74:	7902                	ld	s2,32(sp)
ffffffffc0201f76:	69e2                	ld	s3,24(sp)
ffffffffc0201f78:	6a42                	ld	s4,16(sp)
ffffffffc0201f7a:	6aa2                	ld	s5,8(sp)
ffffffffc0201f7c:	6b02                	ld	s6,0(sp)
ffffffffc0201f7e:	6121                	addi	sp,sp,64
ffffffffc0201f80:	8082                	ret
            return NULL;
ffffffffc0201f82:	4501                	li	a0,0
ffffffffc0201f84:	b7ed                	j	ffffffffc0201f6e <get_pte+0x178>
        intr_disable();
ffffffffc0201f86:	9effe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f8a:	000a9797          	auipc	a5,0xa9
ffffffffc0201f8e:	8a67b783          	ld	a5,-1882(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201f92:	6f9c                	ld	a5,24(a5)
ffffffffc0201f94:	4505                	li	a0,1
ffffffffc0201f96:	9782                	jalr	a5
ffffffffc0201f98:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f9a:	9d5fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201f9e:	b56d                	j	ffffffffc0201e48 <get_pte+0x52>
        intr_disable();
ffffffffc0201fa0:	9d5fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0201fa4:	000a9797          	auipc	a5,0xa9
ffffffffc0201fa8:	88c7b783          	ld	a5,-1908(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0201fac:	6f9c                	ld	a5,24(a5)
ffffffffc0201fae:	4505                	li	a0,1
ffffffffc0201fb0:	9782                	jalr	a5
ffffffffc0201fb2:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0201fb4:	9bbfe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0201fb8:	b781                	j	ffffffffc0201ef8 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201fba:	00004617          	auipc	a2,0x4
ffffffffc0201fbe:	43660613          	addi	a2,a2,1078 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0201fc2:	10f00593          	li	a1,271
ffffffffc0201fc6:	00004517          	auipc	a0,0x4
ffffffffc0201fca:	54250513          	addi	a0,a0,1346 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0201fce:	c80fe0ef          	jal	ra,ffffffffc020044e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fd2:	00004617          	auipc	a2,0x4
ffffffffc0201fd6:	41e60613          	addi	a2,a2,1054 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0201fda:	10200593          	li	a1,258
ffffffffc0201fde:	00004517          	auipc	a0,0x4
ffffffffc0201fe2:	52a50513          	addi	a0,a0,1322 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0201fe6:	c68fe0ef          	jal	ra,ffffffffc020044e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fea:	86aa                	mv	a3,a0
ffffffffc0201fec:	00004617          	auipc	a2,0x4
ffffffffc0201ff0:	40460613          	addi	a2,a2,1028 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0201ff4:	0fe00593          	li	a1,254
ffffffffc0201ff8:	00004517          	auipc	a0,0x4
ffffffffc0201ffc:	51050513          	addi	a0,a0,1296 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0202000:	c4efe0ef          	jal	ra,ffffffffc020044e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202004:	86aa                	mv	a3,a0
ffffffffc0202006:	00004617          	auipc	a2,0x4
ffffffffc020200a:	3ea60613          	addi	a2,a2,1002 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc020200e:	10c00593          	li	a1,268
ffffffffc0202012:	00004517          	auipc	a0,0x4
ffffffffc0202016:	4f650513          	addi	a0,a0,1270 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020201a:	c34fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020201e <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc020201e:	1141                	addi	sp,sp,-16
ffffffffc0202020:	e022                	sd	s0,0(sp)
ffffffffc0202022:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202024:	4601                	li	a2,0
{
ffffffffc0202026:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202028:	dcfff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
    if (ptep_store != NULL)
ffffffffc020202c:	c011                	beqz	s0,ffffffffc0202030 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc020202e:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202030:	c511                	beqz	a0,ffffffffc020203c <get_page+0x1e>
ffffffffc0202032:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202034:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202036:	0017f713          	andi	a4,a5,1
ffffffffc020203a:	e709                	bnez	a4,ffffffffc0202044 <get_page+0x26>
}
ffffffffc020203c:	60a2                	ld	ra,8(sp)
ffffffffc020203e:	6402                	ld	s0,0(sp)
ffffffffc0202040:	0141                	addi	sp,sp,16
ffffffffc0202042:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202044:	078a                	slli	a5,a5,0x2
ffffffffc0202046:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202048:	000a8717          	auipc	a4,0xa8
ffffffffc020204c:	7d873703          	ld	a4,2008(a4) # ffffffffc02aa820 <npage>
ffffffffc0202050:	00e7ff63          	bgeu	a5,a4,ffffffffc020206e <get_page+0x50>
ffffffffc0202054:	60a2                	ld	ra,8(sp)
ffffffffc0202056:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	fff80537          	lui	a0,0xfff80
ffffffffc020205c:	97aa                	add	a5,a5,a0
ffffffffc020205e:	079a                	slli	a5,a5,0x6
ffffffffc0202060:	000a8517          	auipc	a0,0xa8
ffffffffc0202064:	7c853503          	ld	a0,1992(a0) # ffffffffc02aa828 <pages>
ffffffffc0202068:	953e                	add	a0,a0,a5
ffffffffc020206a:	0141                	addi	sp,sp,16
ffffffffc020206c:	8082                	ret
ffffffffc020206e:	c99ff0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>

ffffffffc0202072 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202072:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202074:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202078:	f486                	sd	ra,104(sp)
ffffffffc020207a:	f0a2                	sd	s0,96(sp)
ffffffffc020207c:	eca6                	sd	s1,88(sp)
ffffffffc020207e:	e8ca                	sd	s2,80(sp)
ffffffffc0202080:	e4ce                	sd	s3,72(sp)
ffffffffc0202082:	e0d2                	sd	s4,64(sp)
ffffffffc0202084:	fc56                	sd	s5,56(sp)
ffffffffc0202086:	f85a                	sd	s6,48(sp)
ffffffffc0202088:	f45e                	sd	s7,40(sp)
ffffffffc020208a:	f062                	sd	s8,32(sp)
ffffffffc020208c:	ec66                	sd	s9,24(sp)
ffffffffc020208e:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202090:	17d2                	slli	a5,a5,0x34
ffffffffc0202092:	e3ed                	bnez	a5,ffffffffc0202174 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202094:	002007b7          	lui	a5,0x200
ffffffffc0202098:	842e                	mv	s0,a1
ffffffffc020209a:	0ef5ed63          	bltu	a1,a5,ffffffffc0202194 <unmap_range+0x122>
ffffffffc020209e:	8932                	mv	s2,a2
ffffffffc02020a0:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202194 <unmap_range+0x122>
ffffffffc02020a4:	4785                	li	a5,1
ffffffffc02020a6:	07fe                	slli	a5,a5,0x1f
ffffffffc02020a8:	0ec7e663          	bltu	a5,a2,ffffffffc0202194 <unmap_range+0x122>
ffffffffc02020ac:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02020ae:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02020b0:	000a8c97          	auipc	s9,0xa8
ffffffffc02020b4:	770c8c93          	addi	s9,s9,1904 # ffffffffc02aa820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b8:	000a8c17          	auipc	s8,0xa8
ffffffffc02020bc:	770c0c13          	addi	s8,s8,1904 # ffffffffc02aa828 <pages>
ffffffffc02020c0:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc02020c4:	000a8d17          	auipc	s10,0xa8
ffffffffc02020c8:	76cd0d13          	addi	s10,s10,1900 # ffffffffc02aa830 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020cc:	00200b37          	lui	s6,0x200
ffffffffc02020d0:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02020d4:	4601                	li	a2,0
ffffffffc02020d6:	85a2                	mv	a1,s0
ffffffffc02020d8:	854e                	mv	a0,s3
ffffffffc02020da:	d1dff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc02020de:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc02020e0:	cd29                	beqz	a0,ffffffffc020213a <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc02020e2:	611c                	ld	a5,0(a0)
ffffffffc02020e4:	e395                	bnez	a5,ffffffffc0202108 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc02020e6:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020e8:	ff2466e3          	bltu	s0,s2,ffffffffc02020d4 <unmap_range+0x62>
}
ffffffffc02020ec:	70a6                	ld	ra,104(sp)
ffffffffc02020ee:	7406                	ld	s0,96(sp)
ffffffffc02020f0:	64e6                	ld	s1,88(sp)
ffffffffc02020f2:	6946                	ld	s2,80(sp)
ffffffffc02020f4:	69a6                	ld	s3,72(sp)
ffffffffc02020f6:	6a06                	ld	s4,64(sp)
ffffffffc02020f8:	7ae2                	ld	s5,56(sp)
ffffffffc02020fa:	7b42                	ld	s6,48(sp)
ffffffffc02020fc:	7ba2                	ld	s7,40(sp)
ffffffffc02020fe:	7c02                	ld	s8,32(sp)
ffffffffc0202100:	6ce2                	ld	s9,24(sp)
ffffffffc0202102:	6d42                	ld	s10,16(sp)
ffffffffc0202104:	6165                	addi	sp,sp,112
ffffffffc0202106:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202108:	0017f713          	andi	a4,a5,1
ffffffffc020210c:	df69                	beqz	a4,ffffffffc02020e6 <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc020210e:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202112:	078a                	slli	a5,a5,0x2
ffffffffc0202114:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202116:	08e7ff63          	bgeu	a5,a4,ffffffffc02021b4 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc020211a:	000c3503          	ld	a0,0(s8)
ffffffffc020211e:	97de                	add	a5,a5,s7
ffffffffc0202120:	079a                	slli	a5,a5,0x6
ffffffffc0202122:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202124:	411c                	lw	a5,0(a0)
ffffffffc0202126:	fff7871b          	addiw	a4,a5,-1
ffffffffc020212a:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc020212c:	cf11                	beqz	a4,ffffffffc0202148 <unmap_range+0xd6>
        *ptep = 0;
ffffffffc020212e:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202132:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202136:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202138:	bf45                	j	ffffffffc02020e8 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020213a:	945a                	add	s0,s0,s6
ffffffffc020213c:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202140:	d455                	beqz	s0,ffffffffc02020ec <unmap_range+0x7a>
ffffffffc0202142:	f92469e3          	bltu	s0,s2,ffffffffc02020d4 <unmap_range+0x62>
ffffffffc0202146:	b75d                	j	ffffffffc02020ec <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202148:	100027f3          	csrr	a5,sstatus
ffffffffc020214c:	8b89                	andi	a5,a5,2
ffffffffc020214e:	e799                	bnez	a5,ffffffffc020215c <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202150:	000d3783          	ld	a5,0(s10)
ffffffffc0202154:	4585                	li	a1,1
ffffffffc0202156:	739c                	ld	a5,32(a5)
ffffffffc0202158:	9782                	jalr	a5
    if (flag)
ffffffffc020215a:	bfd1                	j	ffffffffc020212e <unmap_range+0xbc>
ffffffffc020215c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020215e:	817fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202162:	000d3783          	ld	a5,0(s10)
ffffffffc0202166:	6522                	ld	a0,8(sp)
ffffffffc0202168:	4585                	li	a1,1
ffffffffc020216a:	739c                	ld	a5,32(a5)
ffffffffc020216c:	9782                	jalr	a5
        intr_enable();
ffffffffc020216e:	801fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202172:	bf75                	j	ffffffffc020212e <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202174:	00004697          	auipc	a3,0x4
ffffffffc0202178:	3a468693          	addi	a3,a3,932 # ffffffffc0206518 <default_pmm_manager+0x160>
ffffffffc020217c:	00004617          	auipc	a2,0x4
ffffffffc0202180:	e8c60613          	addi	a2,a2,-372 # ffffffffc0206008 <commands+0x748>
ffffffffc0202184:	13500593          	li	a1,309
ffffffffc0202188:	00004517          	auipc	a0,0x4
ffffffffc020218c:	38050513          	addi	a0,a0,896 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0202190:	abefe0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202194:	00004697          	auipc	a3,0x4
ffffffffc0202198:	3b468693          	addi	a3,a3,948 # ffffffffc0206548 <default_pmm_manager+0x190>
ffffffffc020219c:	00004617          	auipc	a2,0x4
ffffffffc02021a0:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206008 <commands+0x748>
ffffffffc02021a4:	13600593          	li	a1,310
ffffffffc02021a8:	00004517          	auipc	a0,0x4
ffffffffc02021ac:	36050513          	addi	a0,a0,864 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02021b0:	a9efe0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc02021b4:	b53ff0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>

ffffffffc02021b8 <exit_range>:
{
ffffffffc02021b8:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021ba:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02021be:	fc86                	sd	ra,120(sp)
ffffffffc02021c0:	f8a2                	sd	s0,112(sp)
ffffffffc02021c2:	f4a6                	sd	s1,104(sp)
ffffffffc02021c4:	f0ca                	sd	s2,96(sp)
ffffffffc02021c6:	ecce                	sd	s3,88(sp)
ffffffffc02021c8:	e8d2                	sd	s4,80(sp)
ffffffffc02021ca:	e4d6                	sd	s5,72(sp)
ffffffffc02021cc:	e0da                	sd	s6,64(sp)
ffffffffc02021ce:	fc5e                	sd	s7,56(sp)
ffffffffc02021d0:	f862                	sd	s8,48(sp)
ffffffffc02021d2:	f466                	sd	s9,40(sp)
ffffffffc02021d4:	f06a                	sd	s10,32(sp)
ffffffffc02021d6:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021d8:	17d2                	slli	a5,a5,0x34
ffffffffc02021da:	20079a63          	bnez	a5,ffffffffc02023ee <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc02021de:	002007b7          	lui	a5,0x200
ffffffffc02021e2:	24f5e463          	bltu	a1,a5,ffffffffc020242a <exit_range+0x272>
ffffffffc02021e6:	8ab2                	mv	s5,a2
ffffffffc02021e8:	24c5f163          	bgeu	a1,a2,ffffffffc020242a <exit_range+0x272>
ffffffffc02021ec:	4785                	li	a5,1
ffffffffc02021ee:	07fe                	slli	a5,a5,0x1f
ffffffffc02021f0:	22c7ed63          	bltu	a5,a2,ffffffffc020242a <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02021f4:	c00009b7          	lui	s3,0xc0000
ffffffffc02021f8:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02021fc:	ffe00937          	lui	s2,0xffe00
ffffffffc0202200:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202204:	5cfd                	li	s9,-1
ffffffffc0202206:	8c2a                	mv	s8,a0
ffffffffc0202208:	0125f933          	and	s2,a1,s2
ffffffffc020220c:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc020220e:	000a8d17          	auipc	s10,0xa8
ffffffffc0202212:	612d0d13          	addi	s10,s10,1554 # ffffffffc02aa820 <npage>
    return KADDR(page2pa(page));
ffffffffc0202216:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020221a:	000a8717          	auipc	a4,0xa8
ffffffffc020221e:	60e70713          	addi	a4,a4,1550 # ffffffffc02aa828 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0202222:	000a8d97          	auipc	s11,0xa8
ffffffffc0202226:	60ed8d93          	addi	s11,s11,1550 # ffffffffc02aa830 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020222a:	c0000437          	lui	s0,0xc0000
ffffffffc020222e:	944e                	add	s0,s0,s3
ffffffffc0202230:	8079                	srli	s0,s0,0x1e
ffffffffc0202232:	1ff47413          	andi	s0,s0,511
ffffffffc0202236:	040e                	slli	s0,s0,0x3
ffffffffc0202238:	9462                	add	s0,s0,s8
ffffffffc020223a:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed0>
        if (pde1 & PTE_V)
ffffffffc020223e:	001a7793          	andi	a5,s4,1
ffffffffc0202242:	eb99                	bnez	a5,ffffffffc0202258 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202244:	12098463          	beqz	s3,ffffffffc020236c <exit_range+0x1b4>
ffffffffc0202248:	400007b7          	lui	a5,0x40000
ffffffffc020224c:	97ce                	add	a5,a5,s3
ffffffffc020224e:	894e                	mv	s2,s3
ffffffffc0202250:	1159fe63          	bgeu	s3,s5,ffffffffc020236c <exit_range+0x1b4>
ffffffffc0202254:	89be                	mv	s3,a5
ffffffffc0202256:	bfd1                	j	ffffffffc020222a <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc0202258:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020225c:	0a0a                	slli	s4,s4,0x2
ffffffffc020225e:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202262:	1cfa7263          	bgeu	s4,a5,ffffffffc0202426 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202266:	fff80637          	lui	a2,0xfff80
ffffffffc020226a:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc020226c:	000806b7          	lui	a3,0x80
ffffffffc0202270:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202272:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202276:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202278:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020227a:	18f5fa63          	bgeu	a1,a5,ffffffffc020240e <exit_range+0x256>
ffffffffc020227e:	000a8817          	auipc	a6,0xa8
ffffffffc0202282:	5c280813          	addi	a6,a6,1474 # ffffffffc02aa840 <va_pa_offset>
ffffffffc0202286:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020228a:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc020228c:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202290:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202292:	00080337          	lui	t1,0x80
ffffffffc0202296:	6885                	lui	a7,0x1
ffffffffc0202298:	a819                	j	ffffffffc02022ae <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020229a:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc020229c:	002007b7          	lui	a5,0x200
ffffffffc02022a0:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02022a2:	08090c63          	beqz	s2,ffffffffc020233a <exit_range+0x182>
ffffffffc02022a6:	09397a63          	bgeu	s2,s3,ffffffffc020233a <exit_range+0x182>
ffffffffc02022aa:	0f597063          	bgeu	s2,s5,ffffffffc020238a <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02022ae:	01595493          	srli	s1,s2,0x15
ffffffffc02022b2:	1ff4f493          	andi	s1,s1,511
ffffffffc02022b6:	048e                	slli	s1,s1,0x3
ffffffffc02022b8:	94da                	add	s1,s1,s6
ffffffffc02022ba:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc02022bc:	0017f693          	andi	a3,a5,1
ffffffffc02022c0:	dee9                	beqz	a3,ffffffffc020229a <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc02022c2:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022c6:	078a                	slli	a5,a5,0x2
ffffffffc02022c8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02022ca:	14b7fe63          	bgeu	a5,a1,ffffffffc0202426 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022ce:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc02022d0:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc02022d4:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02022d8:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02022dc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02022de:	12bef863          	bgeu	t4,a1,ffffffffc020240e <exit_range+0x256>
ffffffffc02022e2:	00083783          	ld	a5,0(a6)
ffffffffc02022e6:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02022e8:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc02022ec:	629c                	ld	a5,0(a3)
ffffffffc02022ee:	8b85                	andi	a5,a5,1
ffffffffc02022f0:	f7d5                	bnez	a5,ffffffffc020229c <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02022f2:	06a1                	addi	a3,a3,8
ffffffffc02022f4:	fed59ce3          	bne	a1,a3,ffffffffc02022ec <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02022f8:	631c                	ld	a5,0(a4)
ffffffffc02022fa:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02022fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202300:	8b89                	andi	a5,a5,2
ffffffffc0202302:	e7d9                	bnez	a5,ffffffffc0202390 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202304:	000db783          	ld	a5,0(s11)
ffffffffc0202308:	4585                	li	a1,1
ffffffffc020230a:	e032                	sd	a2,0(sp)
ffffffffc020230c:	739c                	ld	a5,32(a5)
ffffffffc020230e:	9782                	jalr	a5
    if (flag)
ffffffffc0202310:	6602                	ld	a2,0(sp)
ffffffffc0202312:	000a8817          	auipc	a6,0xa8
ffffffffc0202316:	52e80813          	addi	a6,a6,1326 # ffffffffc02aa840 <va_pa_offset>
ffffffffc020231a:	fff80e37          	lui	t3,0xfff80
ffffffffc020231e:	00080337          	lui	t1,0x80
ffffffffc0202322:	6885                	lui	a7,0x1
ffffffffc0202324:	000a8717          	auipc	a4,0xa8
ffffffffc0202328:	50470713          	addi	a4,a4,1284 # ffffffffc02aa828 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc020232c:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202330:	002007b7          	lui	a5,0x200
ffffffffc0202334:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202336:	f60918e3          	bnez	s2,ffffffffc02022a6 <exit_range+0xee>
            if (free_pd0)
ffffffffc020233a:	f00b85e3          	beqz	s7,ffffffffc0202244 <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc020233e:	000d3783          	ld	a5,0(s10)
ffffffffc0202342:	0efa7263          	bgeu	s4,a5,ffffffffc0202426 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202346:	6308                	ld	a0,0(a4)
ffffffffc0202348:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020234a:	100027f3          	csrr	a5,sstatus
ffffffffc020234e:	8b89                	andi	a5,a5,2
ffffffffc0202350:	efad                	bnez	a5,ffffffffc02023ca <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202352:	000db783          	ld	a5,0(s11)
ffffffffc0202356:	4585                	li	a1,1
ffffffffc0202358:	739c                	ld	a5,32(a5)
ffffffffc020235a:	9782                	jalr	a5
ffffffffc020235c:	000a8717          	auipc	a4,0xa8
ffffffffc0202360:	4cc70713          	addi	a4,a4,1228 # ffffffffc02aa828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202364:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202368:	ee0990e3          	bnez	s3,ffffffffc0202248 <exit_range+0x90>
}
ffffffffc020236c:	70e6                	ld	ra,120(sp)
ffffffffc020236e:	7446                	ld	s0,112(sp)
ffffffffc0202370:	74a6                	ld	s1,104(sp)
ffffffffc0202372:	7906                	ld	s2,96(sp)
ffffffffc0202374:	69e6                	ld	s3,88(sp)
ffffffffc0202376:	6a46                	ld	s4,80(sp)
ffffffffc0202378:	6aa6                	ld	s5,72(sp)
ffffffffc020237a:	6b06                	ld	s6,64(sp)
ffffffffc020237c:	7be2                	ld	s7,56(sp)
ffffffffc020237e:	7c42                	ld	s8,48(sp)
ffffffffc0202380:	7ca2                	ld	s9,40(sp)
ffffffffc0202382:	7d02                	ld	s10,32(sp)
ffffffffc0202384:	6de2                	ld	s11,24(sp)
ffffffffc0202386:	6109                	addi	sp,sp,128
ffffffffc0202388:	8082                	ret
            if (free_pd0)
ffffffffc020238a:	ea0b8fe3          	beqz	s7,ffffffffc0202248 <exit_range+0x90>
ffffffffc020238e:	bf45                	j	ffffffffc020233e <exit_range+0x186>
ffffffffc0202390:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202392:	e42a                	sd	a0,8(sp)
ffffffffc0202394:	de0fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202398:	000db783          	ld	a5,0(s11)
ffffffffc020239c:	6522                	ld	a0,8(sp)
ffffffffc020239e:	4585                	li	a1,1
ffffffffc02023a0:	739c                	ld	a5,32(a5)
ffffffffc02023a2:	9782                	jalr	a5
        intr_enable();
ffffffffc02023a4:	dcafe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02023a8:	6602                	ld	a2,0(sp)
ffffffffc02023aa:	000a8717          	auipc	a4,0xa8
ffffffffc02023ae:	47e70713          	addi	a4,a4,1150 # ffffffffc02aa828 <pages>
ffffffffc02023b2:	6885                	lui	a7,0x1
ffffffffc02023b4:	00080337          	lui	t1,0x80
ffffffffc02023b8:	fff80e37          	lui	t3,0xfff80
ffffffffc02023bc:	000a8817          	auipc	a6,0xa8
ffffffffc02023c0:	48480813          	addi	a6,a6,1156 # ffffffffc02aa840 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023c4:	0004b023          	sd	zero,0(s1)
ffffffffc02023c8:	b7a5                	j	ffffffffc0202330 <exit_range+0x178>
ffffffffc02023ca:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02023cc:	da8fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02023d0:	000db783          	ld	a5,0(s11)
ffffffffc02023d4:	6502                	ld	a0,0(sp)
ffffffffc02023d6:	4585                	li	a1,1
ffffffffc02023d8:	739c                	ld	a5,32(a5)
ffffffffc02023da:	9782                	jalr	a5
        intr_enable();
ffffffffc02023dc:	d92fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02023e0:	000a8717          	auipc	a4,0xa8
ffffffffc02023e4:	44870713          	addi	a4,a4,1096 # ffffffffc02aa828 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02023e8:	00043023          	sd	zero,0(s0)
ffffffffc02023ec:	bfb5                	j	ffffffffc0202368 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023ee:	00004697          	auipc	a3,0x4
ffffffffc02023f2:	12a68693          	addi	a3,a3,298 # ffffffffc0206518 <default_pmm_manager+0x160>
ffffffffc02023f6:	00004617          	auipc	a2,0x4
ffffffffc02023fa:	c1260613          	addi	a2,a2,-1006 # ffffffffc0206008 <commands+0x748>
ffffffffc02023fe:	14a00593          	li	a1,330
ffffffffc0202402:	00004517          	auipc	a0,0x4
ffffffffc0202406:	10650513          	addi	a0,a0,262 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020240a:	844fe0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc020240e:	00004617          	auipc	a2,0x4
ffffffffc0202412:	fe260613          	addi	a2,a2,-30 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0202416:	07100593          	li	a1,113
ffffffffc020241a:	00004517          	auipc	a0,0x4
ffffffffc020241e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0202422:	82cfe0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202426:	8e1ff0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc020242a:	00004697          	auipc	a3,0x4
ffffffffc020242e:	11e68693          	addi	a3,a3,286 # ffffffffc0206548 <default_pmm_manager+0x190>
ffffffffc0202432:	00004617          	auipc	a2,0x4
ffffffffc0202436:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206008 <commands+0x748>
ffffffffc020243a:	14b00593          	li	a1,331
ffffffffc020243e:	00004517          	auipc	a0,0x4
ffffffffc0202442:	0ca50513          	addi	a0,a0,202 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0202446:	808fe0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020244a <page_insert>:
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020244a:	01e65793          	srli	a5,a2,0x1e
{
ffffffffc020244e:	7179                	addi	sp,sp,-48
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202450:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202454:	e44e                	sd	s3,8(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202456:	078e                	slli	a5,a5,0x3
{
ffffffffc0202458:	89b2                	mv	s3,a2
ffffffffc020245a:	f022                	sd	s0,32(sp)
ffffffffc020245c:	e84a                	sd	s2,16(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020245e:	00f50433          	add	s0,a0,a5
{
ffffffffc0202462:	892e                	mv	s2,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202464:	4605                	li	a2,1
ffffffffc0202466:	85ce                	mv	a1,s3
{
ffffffffc0202468:	ec26                	sd	s1,24(sp)
ffffffffc020246a:	e052                	sd	s4,0(sp)
ffffffffc020246c:	f406                	sd	ra,40(sp)
    bool had_pdep1 = (*pdep1 & PTE_V) != 0;
ffffffffc020246e:	00043a03          	ld	s4,0(s0)
{
ffffffffc0202472:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202474:	983ff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
    if (ptep == NULL)
ffffffffc0202478:	cd4d                	beqz	a0,ffffffffc0202532 <page_insert+0xe8>
    if (*ptep & PTE_V)
ffffffffc020247a:	611c                	ld	a5,0(a0)
ffffffffc020247c:	0017f713          	andi	a4,a5,1
ffffffffc0202480:	ef29                	bnez	a4,ffffffffc02024da <page_insert+0x90>
    return &pages[PPN(pa) - nbase];
ffffffffc0202482:	000a8797          	auipc	a5,0xa8
ffffffffc0202486:	3a67b783          	ld	a5,934(a5) # ffffffffc02aa828 <pages>
    struct Page *old_page = NULL;
ffffffffc020248a:	4401                	li	s0,0
    if (old_page != page)
ffffffffc020248c:	01240763          	beq	s0,s2,ffffffffc020249a <page_insert+0x50>
    page->ref += 1;
ffffffffc0202490:	00092703          	lw	a4,0(s2) # ffffffffffe00000 <end+0x3fb5579c>
ffffffffc0202494:	2705                	addiw	a4,a4,1
ffffffffc0202496:	00e92023          	sw	a4,0(s2)
    return page - pages + nbase;
ffffffffc020249a:	40f907b3          	sub	a5,s2,a5
ffffffffc020249e:	000806b7          	lui	a3,0x80
ffffffffc02024a2:	8799                	srai	a5,a5,0x6
ffffffffc02024a4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024a6:	07aa                	slli	a5,a5,0xa
ffffffffc02024a8:	0097e6b3          	or	a3,a5,s1
ffffffffc02024ac:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), perm);
ffffffffc02024b0:	e114                	sd	a3,0(a0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024b2:	12098073          	sfence.vma	s3
    if (old_page != NULL && old_page != page && page_ref_dec(old_page) == 0)
ffffffffc02024b6:	c801                	beqz	s0,ffffffffc02024c6 <page_insert+0x7c>
ffffffffc02024b8:	01240763          	beq	s0,s2,ffffffffc02024c6 <page_insert+0x7c>
    page->ref -= 1;
ffffffffc02024bc:	401c                	lw	a5,0(s0)
ffffffffc02024be:	fff7849b          	addiw	s1,a5,-1
ffffffffc02024c2:	c004                	sw	s1,0(s0)
ffffffffc02024c4:	cc8d                	beqz	s1,ffffffffc02024fe <page_insert+0xb4>
    return 0;
ffffffffc02024c6:	4481                	li	s1,0
}
ffffffffc02024c8:	70a2                	ld	ra,40(sp)
ffffffffc02024ca:	7402                	ld	s0,32(sp)
ffffffffc02024cc:	6942                	ld	s2,16(sp)
ffffffffc02024ce:	69a2                	ld	s3,8(sp)
ffffffffc02024d0:	6a02                	ld	s4,0(sp)
ffffffffc02024d2:	8526                	mv	a0,s1
ffffffffc02024d4:	64e2                	ld	s1,24(sp)
ffffffffc02024d6:	6145                	addi	sp,sp,48
ffffffffc02024d8:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024da:	078a                	slli	a5,a5,0x2
ffffffffc02024dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024de:	000a8717          	auipc	a4,0xa8
ffffffffc02024e2:	34273703          	ld	a4,834(a4) # ffffffffc02aa820 <npage>
ffffffffc02024e6:	08e7fc63          	bgeu	a5,a4,ffffffffc020257e <page_insert+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc02024ea:	fff80437          	lui	s0,0xfff80
ffffffffc02024ee:	943e                	add	s0,s0,a5
ffffffffc02024f0:	041a                	slli	s0,s0,0x6
ffffffffc02024f2:	000a8797          	auipc	a5,0xa8
ffffffffc02024f6:	3367b783          	ld	a5,822(a5) # ffffffffc02aa828 <pages>
ffffffffc02024fa:	943e                	add	s0,s0,a5
ffffffffc02024fc:	bf41                	j	ffffffffc020248c <page_insert+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02024fe:	100027f3          	csrr	a5,sstatus
ffffffffc0202502:	8b89                	andi	a5,a5,2
ffffffffc0202504:	eb91                	bnez	a5,ffffffffc0202518 <page_insert+0xce>
        pmm_manager->free_pages(base, n);
ffffffffc0202506:	000a8797          	auipc	a5,0xa8
ffffffffc020250a:	32a7b783          	ld	a5,810(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc020250e:	739c                	ld	a5,32(a5)
ffffffffc0202510:	4585                	li	a1,1
ffffffffc0202512:	8522                	mv	a0,s0
ffffffffc0202514:	9782                	jalr	a5
    if (flag)
ffffffffc0202516:	bf4d                	j	ffffffffc02024c8 <page_insert+0x7e>
        intr_disable();
ffffffffc0202518:	c5cfe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc020251c:	000a8797          	auipc	a5,0xa8
ffffffffc0202520:	3147b783          	ld	a5,788(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0202524:	739c                	ld	a5,32(a5)
ffffffffc0202526:	4585                	li	a1,1
ffffffffc0202528:	8522                	mv	a0,s0
ffffffffc020252a:	9782                	jalr	a5
        intr_enable();
ffffffffc020252c:	c42fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202530:	bf61                	j	ffffffffc02024c8 <page_insert+0x7e>
    bool had_pdep1 = (*pdep1 & PTE_V) != 0;
ffffffffc0202532:	001a7a13          	andi	s4,s4,1
        if (!had_pdep1 && (*pdep1 & PTE_V))
ffffffffc0202536:	040a1263          	bnez	s4,ffffffffc020257a <page_insert+0x130>
ffffffffc020253a:	601c                	ld	a5,0(s0)
        return -E_NO_MEM;
ffffffffc020253c:	54f1                	li	s1,-4
        if (!had_pdep1 && (*pdep1 & PTE_V))
ffffffffc020253e:	0017f713          	andi	a4,a5,1
ffffffffc0202542:	d359                	beqz	a4,ffffffffc02024c8 <page_insert+0x7e>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202544:	078a                	slli	a5,a5,0x2
ffffffffc0202546:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202548:	000a8717          	auipc	a4,0xa8
ffffffffc020254c:	2d873703          	ld	a4,728(a4) # ffffffffc02aa820 <npage>
ffffffffc0202550:	02e7f763          	bgeu	a5,a4,ffffffffc020257e <page_insert+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202554:	fff80737          	lui	a4,0xfff80
ffffffffc0202558:	97ba                	add	a5,a5,a4
ffffffffc020255a:	000a8517          	auipc	a0,0xa8
ffffffffc020255e:	2ce53503          	ld	a0,718(a0) # ffffffffc02aa828 <pages>
ffffffffc0202562:	079a                	slli	a5,a5,0x6
ffffffffc0202564:	953e                	add	a0,a0,a5
            *pdep1 = 0;
ffffffffc0202566:	00043023          	sd	zero,0(s0) # fffffffffff80000 <end+0x3fcd579c>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256a:	12098073          	sfence.vma	s3
            free_page(table);
ffffffffc020256e:	4585                	li	a1,1
    page->ref = val;
ffffffffc0202570:	00052023          	sw	zero,0(a0)
ffffffffc0202574:	809ff0ef          	jal	ra,ffffffffc0201d7c <free_pages>
ffffffffc0202578:	bf81                	j	ffffffffc02024c8 <page_insert+0x7e>
        return -E_NO_MEM;
ffffffffc020257a:	54f1                	li	s1,-4
ffffffffc020257c:	b7b1                	j	ffffffffc02024c8 <page_insert+0x7e>
ffffffffc020257e:	f88ff0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>

ffffffffc0202582 <copy_range>:
{
ffffffffc0202582:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202584:	00d667b3          	or	a5,a2,a3
{
ffffffffc0202588:	fc86                	sd	ra,120(sp)
ffffffffc020258a:	f8a2                	sd	s0,112(sp)
ffffffffc020258c:	f4a6                	sd	s1,104(sp)
ffffffffc020258e:	f0ca                	sd	s2,96(sp)
ffffffffc0202590:	ecce                	sd	s3,88(sp)
ffffffffc0202592:	e8d2                	sd	s4,80(sp)
ffffffffc0202594:	e4d6                	sd	s5,72(sp)
ffffffffc0202596:	e0da                	sd	s6,64(sp)
ffffffffc0202598:	fc5e                	sd	s7,56(sp)
ffffffffc020259a:	f862                	sd	s8,48(sp)
ffffffffc020259c:	f466                	sd	s9,40(sp)
ffffffffc020259e:	f06a                	sd	s10,32(sp)
ffffffffc02025a0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02025a2:	17d2                	slli	a5,a5,0x34
ffffffffc02025a4:	20079f63          	bnez	a5,ffffffffc02027c2 <copy_range+0x240>
    assert(USER_ACCESS(start, end));
ffffffffc02025a8:	002007b7          	lui	a5,0x200
ffffffffc02025ac:	8432                	mv	s0,a2
ffffffffc02025ae:	18f66863          	bltu	a2,a5,ffffffffc020273e <copy_range+0x1bc>
ffffffffc02025b2:	84b6                	mv	s1,a3
ffffffffc02025b4:	18d67563          	bgeu	a2,a3,ffffffffc020273e <copy_range+0x1bc>
ffffffffc02025b8:	4785                	li	a5,1
ffffffffc02025ba:	07fe                	slli	a5,a5,0x1f
ffffffffc02025bc:	18d7e163          	bltu	a5,a3,ffffffffc020273e <copy_range+0x1bc>
    return KADDR(page2pa(page));
ffffffffc02025c0:	5c7d                	li	s8,-1
ffffffffc02025c2:	00cc5793          	srli	a5,s8,0xc
ffffffffc02025c6:	8a2a                	mv	s4,a0
ffffffffc02025c8:	892e                	mv	s2,a1
ffffffffc02025ca:	8bba                	mv	s7,a4
        start += PGSIZE;
ffffffffc02025cc:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc02025ce:	000a8b17          	auipc	s6,0xa8
ffffffffc02025d2:	252b0b13          	addi	s6,s6,594 # ffffffffc02aa820 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02025d6:	000a8a97          	auipc	s5,0xa8
ffffffffc02025da:	252a8a93          	addi	s5,s5,594 # ffffffffc02aa828 <pages>
ffffffffc02025de:	fff80cb7          	lui	s9,0xfff80
    return KADDR(page2pa(page));
ffffffffc02025e2:	e03e                	sd	a5,0(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc02025e4:	000a8d17          	auipc	s10,0xa8
ffffffffc02025e8:	24cd0d13          	addi	s10,s10,588 # ffffffffc02aa830 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02025ec:	4601                	li	a2,0
ffffffffc02025ee:	85a2                	mv	a1,s0
ffffffffc02025f0:	854a                	mv	a0,s2
ffffffffc02025f2:	805ff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc02025f6:	8c2a                	mv	s8,a0
        if (ptep == NULL)
ffffffffc02025f8:	c935                	beqz	a0,ffffffffc020266c <copy_range+0xea>
        if (*ptep & PTE_V)
ffffffffc02025fa:	6118                	ld	a4,0(a0)
ffffffffc02025fc:	8b05                	andi	a4,a4,1
ffffffffc02025fe:	e705                	bnez	a4,ffffffffc0202626 <copy_range+0xa4>
        start += PGSIZE;
ffffffffc0202600:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202602:	fe9465e3          	bltu	s0,s1,ffffffffc02025ec <copy_range+0x6a>
    return 0;
ffffffffc0202606:	4501                	li	a0,0
}
ffffffffc0202608:	70e6                	ld	ra,120(sp)
ffffffffc020260a:	7446                	ld	s0,112(sp)
ffffffffc020260c:	74a6                	ld	s1,104(sp)
ffffffffc020260e:	7906                	ld	s2,96(sp)
ffffffffc0202610:	69e6                	ld	s3,88(sp)
ffffffffc0202612:	6a46                	ld	s4,80(sp)
ffffffffc0202614:	6aa6                	ld	s5,72(sp)
ffffffffc0202616:	6b06                	ld	s6,64(sp)
ffffffffc0202618:	7be2                	ld	s7,56(sp)
ffffffffc020261a:	7c42                	ld	s8,48(sp)
ffffffffc020261c:	7ca2                	ld	s9,40(sp)
ffffffffc020261e:	7d02                	ld	s10,32(sp)
ffffffffc0202620:	6de2                	ld	s11,24(sp)
ffffffffc0202622:	6109                	addi	sp,sp,128
ffffffffc0202624:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0202626:	4605                	li	a2,1
ffffffffc0202628:	85a2                	mv	a1,s0
ffffffffc020262a:	8552                	mv	a0,s4
ffffffffc020262c:	fcaff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc0202630:	cd05                	beqz	a0,ffffffffc0202668 <copy_range+0xe6>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202632:	000c3783          	ld	a5,0(s8)
    if (!(pte & PTE_V))
ffffffffc0202636:	0017f713          	andi	a4,a5,1
ffffffffc020263a:	01f7fc13          	andi	s8,a5,31
ffffffffc020263e:	16070663          	beqz	a4,ffffffffc02027aa <copy_range+0x228>
    if (PPN(pa) >= npage)
ffffffffc0202642:	000b3703          	ld	a4,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202646:	078a                	slli	a5,a5,0x2
ffffffffc0202648:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020264a:	14e7f463          	bgeu	a5,a4,ffffffffc0202792 <copy_range+0x210>
    return &pages[PPN(pa) - nbase];
ffffffffc020264e:	000ab583          	ld	a1,0(s5)
ffffffffc0202652:	97e6                	add	a5,a5,s9
ffffffffc0202654:	079a                	slli	a5,a5,0x6
ffffffffc0202656:	95be                	add	a1,a1,a5
            if (share)
ffffffffc0202658:	020b8463          	beqz	s7,ffffffffc0202680 <copy_range+0xfe>
                if (page_insert(to, page, start, perm) != 0)
ffffffffc020265c:	86e2                	mv	a3,s8
ffffffffc020265e:	8622                	mv	a2,s0
ffffffffc0202660:	8552                	mv	a0,s4
ffffffffc0202662:	de9ff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202666:	dd49                	beqz	a0,ffffffffc0202600 <copy_range+0x7e>
                    return -E_NO_MEM;
ffffffffc0202668:	5571                	li	a0,-4
ffffffffc020266a:	bf79                	j	ffffffffc0202608 <copy_range+0x86>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020266c:	00200637          	lui	a2,0x200
ffffffffc0202670:	9432                	add	s0,s0,a2
ffffffffc0202672:	ffe00637          	lui	a2,0xffe00
ffffffffc0202676:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0202678:	d459                	beqz	s0,ffffffffc0202606 <copy_range+0x84>
ffffffffc020267a:	f69469e3          	bltu	s0,s1,ffffffffc02025ec <copy_range+0x6a>
ffffffffc020267e:	b761                	j	ffffffffc0202606 <copy_range+0x84>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202680:	10002773          	csrr	a4,sstatus
ffffffffc0202684:	8b09                	andi	a4,a4,2
ffffffffc0202686:	e42e                	sd	a1,8(sp)
ffffffffc0202688:	e359                	bnez	a4,ffffffffc020270e <copy_range+0x18c>
        page = pmm_manager->alloc_pages(n);
ffffffffc020268a:	000d3783          	ld	a5,0(s10)
ffffffffc020268e:	4505                	li	a0,1
ffffffffc0202690:	6f9c                	ld	a5,24(a5)
ffffffffc0202692:	9782                	jalr	a5
ffffffffc0202694:	65a2                	ld	a1,8(sp)
ffffffffc0202696:	8daa                	mv	s11,a0
                if ((npage = alloc_page()) == NULL)
ffffffffc0202698:	fc0d88e3          	beqz	s11,ffffffffc0202668 <copy_range+0xe6>
    return page - pages + nbase;
ffffffffc020269c:	000ab783          	ld	a5,0(s5)
    return KADDR(page2pa(page));
ffffffffc02026a0:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02026a2:	00080537          	lui	a0,0x80
ffffffffc02026a6:	40fd8733          	sub	a4,s11,a5
ffffffffc02026aa:	8719                	srai	a4,a4,0x6
    return KADDR(page2pa(page));
ffffffffc02026ac:	000b3603          	ld	a2,0(s6)
    return page - pages + nbase;
ffffffffc02026b0:	972a                	add	a4,a4,a0
    return KADDR(page2pa(page));
ffffffffc02026b2:	00d778b3          	and	a7,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02026b6:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02026b8:	0cc8f063          	bgeu	a7,a2,ffffffffc0202778 <copy_range+0x1f6>
ffffffffc02026bc:	000a8697          	auipc	a3,0xa8
ffffffffc02026c0:	18468693          	addi	a3,a3,388 # ffffffffc02aa840 <va_pa_offset>
    return page - pages + nbase;
ffffffffc02026c4:	40f587b3          	sub	a5,a1,a5
    return KADDR(page2pa(page));
ffffffffc02026c8:	628c                	ld	a1,0(a3)
ffffffffc02026ca:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02026cc:	8799                	srai	a5,a5,0x6
ffffffffc02026ce:	97aa                	add	a5,a5,a0
    return KADDR(page2pa(page));
ffffffffc02026d0:	00d7f8b3          	and	a7,a5,a3
ffffffffc02026d4:	00b70533          	add	a0,a4,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02026d8:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02026da:	08c8f263          	bgeu	a7,a2,ffffffffc020275e <copy_range+0x1dc>
                memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc02026de:	6605                	lui	a2,0x1
ffffffffc02026e0:	95be                	add	a1,a1,a5
ffffffffc02026e2:	75f020ef          	jal	ra,ffffffffc0205640 <memcpy>
                if (page_insert(to, npage, start, perm) != 0)
ffffffffc02026e6:	86e2                	mv	a3,s8
ffffffffc02026e8:	8622                	mv	a2,s0
ffffffffc02026ea:	85ee                	mv	a1,s11
ffffffffc02026ec:	8552                	mv	a0,s4
ffffffffc02026ee:	d5dff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc02026f2:	f00507e3          	beqz	a0,ffffffffc0202600 <copy_range+0x7e>
ffffffffc02026f6:	100027f3          	csrr	a5,sstatus
ffffffffc02026fa:	8b89                	andi	a5,a5,2
ffffffffc02026fc:	e78d                	bnez	a5,ffffffffc0202726 <copy_range+0x1a4>
        pmm_manager->free_pages(base, n);
ffffffffc02026fe:	000d3783          	ld	a5,0(s10)
ffffffffc0202702:	856e                	mv	a0,s11
ffffffffc0202704:	4585                	li	a1,1
ffffffffc0202706:	739c                	ld	a5,32(a5)
ffffffffc0202708:	9782                	jalr	a5
                    return -E_NO_MEM;
ffffffffc020270a:	5571                	li	a0,-4
ffffffffc020270c:	bdf5                	j	ffffffffc0202608 <copy_range+0x86>
        intr_disable();
ffffffffc020270e:	a66fe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202712:	000d3783          	ld	a5,0(s10)
ffffffffc0202716:	4505                	li	a0,1
ffffffffc0202718:	6f9c                	ld	a5,24(a5)
ffffffffc020271a:	9782                	jalr	a5
ffffffffc020271c:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc020271e:	a50fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202722:	65a2                	ld	a1,8(sp)
ffffffffc0202724:	bf95                	j	ffffffffc0202698 <copy_range+0x116>
        intr_disable();
ffffffffc0202726:	a4efe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020272a:	000d3783          	ld	a5,0(s10)
ffffffffc020272e:	856e                	mv	a0,s11
ffffffffc0202730:	4585                	li	a1,1
ffffffffc0202732:	739c                	ld	a5,32(a5)
ffffffffc0202734:	9782                	jalr	a5
        intr_enable();
ffffffffc0202736:	a38fe0ef          	jal	ra,ffffffffc020096e <intr_enable>
                    return -E_NO_MEM;
ffffffffc020273a:	5571                	li	a0,-4
ffffffffc020273c:	b5f1                	j	ffffffffc0202608 <copy_range+0x86>
    assert(USER_ACCESS(start, end));
ffffffffc020273e:	00004697          	auipc	a3,0x4
ffffffffc0202742:	e0a68693          	addi	a3,a3,-502 # ffffffffc0206548 <default_pmm_manager+0x190>
ffffffffc0202746:	00004617          	auipc	a2,0x4
ffffffffc020274a:	8c260613          	addi	a2,a2,-1854 # ffffffffc0206008 <commands+0x748>
ffffffffc020274e:	18c00593          	li	a1,396
ffffffffc0202752:	00004517          	auipc	a0,0x4
ffffffffc0202756:	db650513          	addi	a0,a0,-586 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020275a:	cf5fd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc020275e:	86be                	mv	a3,a5
ffffffffc0202760:	00004617          	auipc	a2,0x4
ffffffffc0202764:	c9060613          	addi	a2,a2,-880 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0202768:	07100593          	li	a1,113
ffffffffc020276c:	00004517          	auipc	a0,0x4
ffffffffc0202770:	cac50513          	addi	a0,a0,-852 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0202774:	cdbfd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202778:	86ba                	mv	a3,a4
ffffffffc020277a:	00004617          	auipc	a2,0x4
ffffffffc020277e:	c7660613          	addi	a2,a2,-906 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0202782:	07100593          	li	a1,113
ffffffffc0202786:	00004517          	auipc	a0,0x4
ffffffffc020278a:	c9250513          	addi	a0,a0,-878 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc020278e:	cc1fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202792:	00004617          	auipc	a2,0x4
ffffffffc0202796:	d2e60613          	addi	a2,a2,-722 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc020279a:	06900593          	li	a1,105
ffffffffc020279e:	00004517          	auipc	a0,0x4
ffffffffc02027a2:	c7a50513          	addi	a0,a0,-902 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc02027a6:	ca9fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02027aa:	00004617          	auipc	a2,0x4
ffffffffc02027ae:	d3660613          	addi	a2,a2,-714 # ffffffffc02064e0 <default_pmm_manager+0x128>
ffffffffc02027b2:	07f00593          	li	a1,127
ffffffffc02027b6:	00004517          	auipc	a0,0x4
ffffffffc02027ba:	c6250513          	addi	a0,a0,-926 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc02027be:	c91fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02027c2:	00004697          	auipc	a3,0x4
ffffffffc02027c6:	d5668693          	addi	a3,a3,-682 # ffffffffc0206518 <default_pmm_manager+0x160>
ffffffffc02027ca:	00004617          	auipc	a2,0x4
ffffffffc02027ce:	83e60613          	addi	a2,a2,-1986 # ffffffffc0206008 <commands+0x748>
ffffffffc02027d2:	18b00593          	li	a1,395
ffffffffc02027d6:	00004517          	auipc	a0,0x4
ffffffffc02027da:	d3250513          	addi	a0,a0,-718 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02027de:	c71fd0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02027e2 <page_remove>:
{
ffffffffc02027e2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02027e4:	4601                	li	a2,0
{
ffffffffc02027e6:	e426                	sd	s1,8(sp)
ffffffffc02027e8:	ec06                	sd	ra,24(sp)
ffffffffc02027ea:	e822                	sd	s0,16(sp)
ffffffffc02027ec:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02027ee:	e08ff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
    if (ptep == NULL || !(*ptep & PTE_V))
ffffffffc02027f2:	c509                	beqz	a0,ffffffffc02027fc <page_remove+0x1a>
ffffffffc02027f4:	611c                	ld	a5,0(a0)
ffffffffc02027f6:	0017f713          	andi	a4,a5,1
ffffffffc02027fa:	e711                	bnez	a4,ffffffffc0202806 <page_remove+0x24>
}
ffffffffc02027fc:	60e2                	ld	ra,24(sp)
ffffffffc02027fe:	6442                	ld	s0,16(sp)
ffffffffc0202800:	64a2                	ld	s1,8(sp)
ffffffffc0202802:	6105                	addi	sp,sp,32
ffffffffc0202804:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202806:	078a                	slli	a5,a5,0x2
ffffffffc0202808:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020280a:	000a8717          	auipc	a4,0xa8
ffffffffc020280e:	01673703          	ld	a4,22(a4) # ffffffffc02aa820 <npage>
ffffffffc0202812:	06e7f463          	bgeu	a5,a4,ffffffffc020287a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202816:	fff80737          	lui	a4,0xfff80
ffffffffc020281a:	97ba                	add	a5,a5,a4
ffffffffc020281c:	000a8417          	auipc	s0,0xa8
ffffffffc0202820:	00c43403          	ld	s0,12(s0) # ffffffffc02aa828 <pages>
ffffffffc0202824:	079a                	slli	a5,a5,0x6
ffffffffc0202826:	943e                	add	s0,s0,a5
    *ptep = 0;
ffffffffc0202828:	00053023          	sd	zero,0(a0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020282c:	12048073          	sfence.vma	s1
    page->ref -= 1;
ffffffffc0202830:	401c                	lw	a5,0(s0)
ffffffffc0202832:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202836:	c018                	sw	a4,0(s0)
    if (page_ref_dec(page) == 0)
ffffffffc0202838:	f371                	bnez	a4,ffffffffc02027fc <page_remove+0x1a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020283a:	100027f3          	csrr	a5,sstatus
ffffffffc020283e:	8b89                	andi	a5,a5,2
ffffffffc0202840:	ef89                	bnez	a5,ffffffffc020285a <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc0202842:	000a8797          	auipc	a5,0xa8
ffffffffc0202846:	fee7b783          	ld	a5,-18(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc020284a:	8522                	mv	a0,s0
}
ffffffffc020284c:	6442                	ld	s0,16(sp)
ffffffffc020284e:	60e2                	ld	ra,24(sp)
ffffffffc0202850:	64a2                	ld	s1,8(sp)
        pmm_manager->free_pages(base, n);
ffffffffc0202852:	739c                	ld	a5,32(a5)
ffffffffc0202854:	4585                	li	a1,1
}
ffffffffc0202856:	6105                	addi	sp,sp,32
        pmm_manager->free_pages(base, n);
ffffffffc0202858:	8782                	jr	a5
        intr_disable();
ffffffffc020285a:	91afe0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc020285e:	000a8797          	auipc	a5,0xa8
ffffffffc0202862:	fd27b783          	ld	a5,-46(a5) # ffffffffc02aa830 <pmm_manager>
ffffffffc0202866:	739c                	ld	a5,32(a5)
ffffffffc0202868:	8522                	mv	a0,s0
ffffffffc020286a:	4585                	li	a1,1
ffffffffc020286c:	9782                	jalr	a5
}
ffffffffc020286e:	6442                	ld	s0,16(sp)
ffffffffc0202870:	60e2                	ld	ra,24(sp)
ffffffffc0202872:	64a2                	ld	s1,8(sp)
ffffffffc0202874:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202876:	8f8fe06f          	j	ffffffffc020096e <intr_enable>
ffffffffc020287a:	c8cff0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>

ffffffffc020287e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020287e:	00004797          	auipc	a5,0x4
ffffffffc0202882:	b3a78793          	addi	a5,a5,-1222 # ffffffffc02063b8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202886:	638c                	ld	a1,0(a5)
{
ffffffffc0202888:	7159                	addi	sp,sp,-112
ffffffffc020288a:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020288c:	00004517          	auipc	a0,0x4
ffffffffc0202890:	cd450513          	addi	a0,a0,-812 # ffffffffc0206560 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202894:	000a8b17          	auipc	s6,0xa8
ffffffffc0202898:	f9cb0b13          	addi	s6,s6,-100 # ffffffffc02aa830 <pmm_manager>
{
ffffffffc020289c:	f486                	sd	ra,104(sp)
ffffffffc020289e:	fc56                	sd	s5,56(sp)
ffffffffc02028a0:	f0a2                	sd	s0,96(sp)
ffffffffc02028a2:	eca6                	sd	s1,88(sp)
ffffffffc02028a4:	e8ca                	sd	s2,80(sp)
ffffffffc02028a6:	e4ce                	sd	s3,72(sp)
ffffffffc02028a8:	e0d2                	sd	s4,64(sp)
ffffffffc02028aa:	f45e                	sd	s7,40(sp)
ffffffffc02028ac:	f062                	sd	s8,32(sp)
ffffffffc02028ae:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02028b0:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028b4:	8e1fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc02028b8:	000b3783          	ld	a5,0(s6)
ffffffffc02028bc:	679c                	ld	a5,8(a5)
ffffffffc02028be:	9782                	jalr	a5
    uint64_t mem_base = get_memory_base();
ffffffffc02028c0:	89afe0ef          	jal	ra,ffffffffc020095a <get_memory_base>
ffffffffc02028c4:	8aaa                	mv	s5,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02028c6:	89efe0ef          	jal	ra,ffffffffc0200964 <get_memory_size>
    if (mem_base == 0 || mem_size == 0)
ffffffffc02028ca:	0c0a84e3          	beqz	s5,ffffffffc0203192 <pmm_init+0x914>
ffffffffc02028ce:	8a2a                	mv	s4,a0
ffffffffc02028d0:	0c0501e3          	beqz	a0,ffffffffc0203192 <pmm_init+0x914>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02028d4:	57f5                	li	a5,-3
ffffffffc02028d6:	000a8997          	auipc	s3,0xa8
ffffffffc02028da:	f6a98993          	addi	s3,s3,-150 # ffffffffc02aa840 <va_pa_offset>
ffffffffc02028de:	07fa                	slli	a5,a5,0x1e
    if (mem_end > (KERNTOP - PHYSICAL_MEMORY_OFFSET))
ffffffffc02028e0:	4745                	li	a4,17
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02028e2:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_end = mem_base + mem_size;
ffffffffc02028e6:	00aa8c33          	add	s8,s5,a0
    if (mem_end > (KERNTOP - PHYSICAL_MEMORY_OFFSET))
ffffffffc02028ea:	076e                	slli	a4,a4,0x1b
ffffffffc02028ec:	57876663          	bltu	a4,s8,ffffffffc0202e58 <pmm_init+0x5da>
    if (mem_end <= DRAM_BASE)
ffffffffc02028f0:	4785                	li	a5,1
ffffffffc02028f2:	07fe                	slli	a5,a5,0x1f
ffffffffc02028f4:	0b87fbe3          	bgeu	a5,s8,ffffffffc02031aa <pmm_init+0x92c>
    npage = PPN(mem_end);
ffffffffc02028f8:	777d                	lui	a4,0xfffff
ffffffffc02028fa:	000a9797          	auipc	a5,0xa9
ffffffffc02028fe:	f6978793          	addi	a5,a5,-151 # ffffffffc02ab863 <end+0xfff>
ffffffffc0202902:	8ff9                	and	a5,a5,a4
ffffffffc0202904:	00cc5893          	srli	a7,s8,0xc
ffffffffc0202908:	000a8917          	auipc	s2,0xa8
ffffffffc020290c:	f1890913          	addi	s2,s2,-232 # ffffffffc02aa820 <npage>
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202910:	000a8b97          	auipc	s7,0xa8
ffffffffc0202914:	f18b8b93          	addi	s7,s7,-232 # ffffffffc02aa828 <pages>
    size_t nr_pages = npage - nbase;
ffffffffc0202918:	fff80737          	lui	a4,0xfff80
    npage = PPN(mem_end);
ffffffffc020291c:	01193023          	sd	a7,0(s2)
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202920:	00fbb023          	sd	a5,0(s7)
    size_t nr_pages = npage - nbase;
ffffffffc0202924:	98ba                	add	a7,a7,a4
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202926:	843e                	mv	s0,a5
    for (size_t i = 0; i < nr_pages; i++)
ffffffffc0202928:	84e2                	mv	s1,s8
ffffffffc020292a:	02088863          	beqz	a7,ffffffffc020295a <pmm_init+0xdc>
ffffffffc020292e:	4701                	li	a4,0
ffffffffc0202930:	4685                	li	a3,1
ffffffffc0202932:	a019                	j	ffffffffc0202938 <pmm_init+0xba>
        pages[i].ref = 0;
ffffffffc0202934:	000bb783          	ld	a5,0(s7)
ffffffffc0202938:	00671813          	slli	a6,a4,0x6
ffffffffc020293c:	97c2                	add	a5,a5,a6
ffffffffc020293e:	0007a023          	sw	zero,0(a5)
        pages[i].property = 0;
ffffffffc0202942:	0007a823          	sw	zero,16(a5)
        pages[i].flags = 0;
ffffffffc0202946:	0007b423          	sd	zero,8(a5)
ffffffffc020294a:	07a1                	addi	a5,a5,8
ffffffffc020294c:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < nr_pages; i++)
ffffffffc0202950:	0705                	addi	a4,a4,1
ffffffffc0202952:	ff1761e3          	bltu	a4,a7,ffffffffc0202934 <pmm_init+0xb6>
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0202956:	000bb403          	ld	s0,0(s7)
ffffffffc020295a:	c02007b7          	lui	a5,0xc0200
ffffffffc020295e:	06f462e3          	bltu	s0,a5,ffffffffc02031c2 <pmm_init+0x944>
        ROUNDUP(pages_pa + nr_pages * sizeof(struct Page), PGSIZE);
ffffffffc0202962:	0009b703          	ld	a4,0(s3)
ffffffffc0202966:	6785                	lui	a5,0x1
ffffffffc0202968:	17fd                	addi	a5,a5,-1
ffffffffc020296a:	8f99                	sub	a5,a5,a4
ffffffffc020296c:	943e                	add	s0,s0,a5
ffffffffc020296e:	089a                	slli	a7,a7,0x6
ffffffffc0202970:	9446                	add	s0,s0,a7
ffffffffc0202972:	77fd                	lui	a5,0xfffff
ffffffffc0202974:	8c7d                	and	s0,s0,a5
ffffffffc0202976:	01547363          	bgeu	s0,s5,ffffffffc020297c <pmm_init+0xfe>
ffffffffc020297a:	8456                	mv	s0,s5
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020297c:	777d                	lui	a4,0xfffff
    cprintf("physical memory map:\n");
ffffffffc020297e:	00004517          	auipc	a0,0x4
ffffffffc0202982:	c6250513          	addi	a0,a0,-926 # ffffffffc02065e0 <default_pmm_manager+0x228>
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202986:	8cf9                	and	s1,s1,a4
    cprintf("physical memory map:\n");
ffffffffc0202988:	80dfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size,
ffffffffc020298c:	fffc0693          	addi	a3,s8,-1
ffffffffc0202990:	8656                	mv	a2,s5
ffffffffc0202992:	85d2                	mv	a1,s4
ffffffffc0202994:	00004517          	auipc	a0,0x4
ffffffffc0202998:	c6450513          	addi	a0,a0,-924 # ffffffffc02065f8 <default_pmm_manager+0x240>
ffffffffc020299c:	ff8fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    if (free_end > free_start)
ffffffffc02029a0:	4e946d63          	bltu	s0,s1,ffffffffc0202e9a <pmm_init+0x61c>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02029a4:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02029a8:	000a8497          	auipc	s1,0xa8
ffffffffc02029ac:	e7048493          	addi	s1,s1,-400 # ffffffffc02aa818 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02029b0:	7b9c                	ld	a5,48(a5)
ffffffffc02029b2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02029b4:	00004517          	auipc	a0,0x4
ffffffffc02029b8:	c7450513          	addi	a0,a0,-908 # ffffffffc0206628 <default_pmm_manager+0x270>
ffffffffc02029bc:	fd8fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02029c0:	00007697          	auipc	a3,0x7
ffffffffc02029c4:	64068693          	addi	a3,a3,1600 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02029c8:	e094                	sd	a3,0(s1)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02029ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02029ce:	6af6e663          	bltu	a3,a5,ffffffffc020307a <pmm_init+0x7fc>
ffffffffc02029d2:	0009b783          	ld	a5,0(s3)
ffffffffc02029d6:	8e9d                	sub	a3,a3,a5
ffffffffc02029d8:	000a8797          	auipc	a5,0xa8
ffffffffc02029dc:	e2d7bc23          	sd	a3,-456(a5) # ffffffffc02aa810 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02029e0:	100027f3          	csrr	a5,sstatus
ffffffffc02029e4:	8b89                	andi	a5,a5,2
ffffffffc02029e6:	4a079063          	bnez	a5,ffffffffc0202e86 <pmm_init+0x608>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029ea:	000b3783          	ld	a5,0(s6)
ffffffffc02029ee:	779c                	ld	a5,40(a5)
ffffffffc02029f0:	9782                	jalr	a5
ffffffffc02029f2:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029f4:	00093703          	ld	a4,0(s2)
ffffffffc02029f8:	c80007b7          	lui	a5,0xc8000
ffffffffc02029fc:	83b1                	srli	a5,a5,0xc
ffffffffc02029fe:	68e7ea63          	bltu	a5,a4,ffffffffc0203092 <pmm_init+0x814>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202a02:	6088                	ld	a0,0(s1)
ffffffffc0202a04:	6a050763          	beqz	a0,ffffffffc02030b2 <pmm_init+0x834>
ffffffffc0202a08:	03451793          	slli	a5,a0,0x34
ffffffffc0202a0c:	6a079363          	bnez	a5,ffffffffc02030b2 <pmm_init+0x834>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202a10:	4601                	li	a2,0
ffffffffc0202a12:	4581                	li	a1,0
ffffffffc0202a14:	e0aff0ef          	jal	ra,ffffffffc020201e <get_page>
ffffffffc0202a18:	280517e3          	bnez	a0,ffffffffc02034a6 <pmm_init+0xc28>
ffffffffc0202a1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a20:	8b89                	andi	a5,a5,2
ffffffffc0202a22:	4a079c63          	bnez	a5,ffffffffc0202eda <pmm_init+0x65c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a26:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2a:	4505                	li	a0,1
ffffffffc0202a2c:	6f9c                	ld	a5,24(a5)
ffffffffc0202a2e:	9782                	jalr	a5
ffffffffc0202a30:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202a32:	6088                	ld	a0,0(s1)
ffffffffc0202a34:	4681                	li	a3,0
ffffffffc0202a36:	4601                	li	a2,0
ffffffffc0202a38:	85d2                	mv	a1,s4
ffffffffc0202a3a:	a11ff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202a3e:	280514e3          	bnez	a0,ffffffffc02034c6 <pmm_init+0xc48>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202a42:	6088                	ld	a0,0(s1)
ffffffffc0202a44:	4601                	li	a2,0
ffffffffc0202a46:	4581                	li	a1,0
ffffffffc0202a48:	baeff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc0202a4c:	28050de3          	beqz	a0,ffffffffc02034e6 <pmm_init+0xc68>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a50:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a52:	0017f713          	andi	a4,a5,1
ffffffffc0202a56:	2a0708e3          	beqz	a4,ffffffffc0203506 <pmm_init+0xc88>
    if (PPN(pa) >= npage)
ffffffffc0202a5a:	00093703          	ld	a4,0(s2)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a5e:	078a                	slli	a5,a5,0x2
ffffffffc0202a60:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a62:	5ce7fa63          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a66:	000bb683          	ld	a3,0(s7)
ffffffffc0202a6a:	fff80637          	lui	a2,0xfff80
ffffffffc0202a6e:	97b2                	add	a5,a5,a2
ffffffffc0202a70:	079a                	slli	a5,a5,0x6
ffffffffc0202a72:	97b6                	add	a5,a5,a3
ffffffffc0202a74:	00fa10e3          	bne	s4,a5,ffffffffc0203274 <pmm_init+0x9f6>
    assert(page_ref(p1) == 1);
ffffffffc0202a78:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202a7c:	4785                	li	a5,1
ffffffffc0202a7e:	28f696e3          	bne	a3,a5,ffffffffc020350a <pmm_init+0xc8c>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202a82:	6088                	ld	a0,0(s1)
ffffffffc0202a84:	77fd                	lui	a5,0xfffff
ffffffffc0202a86:	6114                	ld	a3,0(a0)
ffffffffc0202a88:	068a                	slli	a3,a3,0x2
ffffffffc0202a8a:	8efd                	and	a3,a3,a5
ffffffffc0202a8c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a90:	7ce67663          	bgeu	a2,a4,ffffffffc020325c <pmm_init+0x9de>
ffffffffc0202a94:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a98:	96e2                	add	a3,a3,s8
ffffffffc0202a9a:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a9e:	0a8a                	slli	s5,s5,0x2
ffffffffc0202aa0:	00fafab3          	and	s5,s5,a5
ffffffffc0202aa4:	00cad793          	srli	a5,s5,0xc
ffffffffc0202aa8:	10e7f2e3          	bgeu	a5,a4,ffffffffc02033ac <pmm_init+0xb2e>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202aac:	4601                	li	a2,0
ffffffffc0202aae:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202ab0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202ab2:	b44ff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202ab6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202ab8:	115517e3          	bne	a0,s5,ffffffffc02033c6 <pmm_init+0xb48>
ffffffffc0202abc:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac0:	8b89                	andi	a5,a5,2
ffffffffc0202ac2:	40079163          	bnez	a5,ffffffffc0202ec4 <pmm_init+0x646>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ac6:	000b3783          	ld	a5,0(s6)
ffffffffc0202aca:	4505                	li	a0,1
ffffffffc0202acc:	6f9c                	ld	a5,24(a5)
ffffffffc0202ace:	9782                	jalr	a5
ffffffffc0202ad0:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202ad2:	6088                	ld	a0,0(s1)
ffffffffc0202ad4:	46d1                	li	a3,20
ffffffffc0202ad6:	6605                	lui	a2,0x1
ffffffffc0202ad8:	85e2                	mv	a1,s8
ffffffffc0202ada:	971ff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202ade:	100514e3          	bnez	a0,ffffffffc02033e6 <pmm_init+0xb68>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202ae2:	6088                	ld	a0,0(s1)
ffffffffc0202ae4:	4601                	li	a2,0
ffffffffc0202ae6:	6585                	lui	a1,0x1
ffffffffc0202ae8:	b0eff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc0202aec:	10050de3          	beqz	a0,ffffffffc0203406 <pmm_init+0xb88>
    assert(*ptep & PTE_U);
ffffffffc0202af0:	611c                	ld	a5,0(a0)
ffffffffc0202af2:	0107f713          	andi	a4,a5,16
ffffffffc0202af6:	120708e3          	beqz	a4,ffffffffc0203426 <pmm_init+0xba8>
    assert(*ptep & PTE_W);
ffffffffc0202afa:	8b91                	andi	a5,a5,4
ffffffffc0202afc:	140785e3          	beqz	a5,ffffffffc0203446 <pmm_init+0xbc8>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202b00:	6088                	ld	a0,0(s1)
ffffffffc0202b02:	611c                	ld	a5,0(a0)
ffffffffc0202b04:	8bc1                	andi	a5,a5,16
ffffffffc0202b06:	160780e3          	beqz	a5,ffffffffc0203466 <pmm_init+0xbe8>
    assert(page_ref(p2) == 1);
ffffffffc0202b0a:	000c2703          	lw	a4,0(s8)
ffffffffc0202b0e:	4785                	li	a5,1
ffffffffc0202b10:	16f71be3          	bne	a4,a5,ffffffffc0203486 <pmm_init+0xc08>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202b14:	4681                	li	a3,0
ffffffffc0202b16:	6605                	lui	a2,0x1
ffffffffc0202b18:	85d2                	mv	a1,s4
ffffffffc0202b1a:	931ff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202b1e:	78051b63          	bnez	a0,ffffffffc02032b4 <pmm_init+0xa36>
    assert(page_ref(p1) == 2);
ffffffffc0202b22:	000a2703          	lw	a4,0(s4)
ffffffffc0202b26:	4789                	li	a5,2
ffffffffc0202b28:	7af71663          	bne	a4,a5,ffffffffc02032d4 <pmm_init+0xa56>
    assert(page_ref(p2) == 0);
ffffffffc0202b2c:	000c2783          	lw	a5,0(s8)
ffffffffc0202b30:	7c079263          	bnez	a5,ffffffffc02032f4 <pmm_init+0xa76>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202b34:	6088                	ld	a0,0(s1)
ffffffffc0202b36:	4601                	li	a2,0
ffffffffc0202b38:	6585                	lui	a1,0x1
ffffffffc0202b3a:	abcff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc0202b3e:	7c050b63          	beqz	a0,ffffffffc0203314 <pmm_init+0xa96>
    assert(pte2page(*ptep) == p1);
ffffffffc0202b42:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202b44:	00177793          	andi	a5,a4,1
ffffffffc0202b48:	1a078fe3          	beqz	a5,ffffffffc0203506 <pmm_init+0xc88>
    if (PPN(pa) >= npage)
ffffffffc0202b4c:	00093683          	ld	a3,0(s2)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b50:	00271793          	slli	a5,a4,0x2
ffffffffc0202b54:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b56:	4ed7f063          	bgeu	a5,a3,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b5a:	000bb683          	ld	a3,0(s7)
ffffffffc0202b5e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202b62:	97d6                	add	a5,a5,s5
ffffffffc0202b64:	079a                	slli	a5,a5,0x6
ffffffffc0202b66:	97b6                	add	a5,a5,a3
ffffffffc0202b68:	7cfa1663          	bne	s4,a5,ffffffffc0203334 <pmm_init+0xab6>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202b6c:	8b41                	andi	a4,a4,16
ffffffffc0202b6e:	66071763          	bnez	a4,ffffffffc02031dc <pmm_init+0x95e>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202b72:	6088                	ld	a0,0(s1)
ffffffffc0202b74:	4581                	li	a1,0
ffffffffc0202b76:	c6dff0ef          	jal	ra,ffffffffc02027e2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202b7a:	000a2c83          	lw	s9,0(s4)
ffffffffc0202b7e:	4785                	li	a5,1
ffffffffc0202b80:	66fc9e63          	bne	s9,a5,ffffffffc02031fc <pmm_init+0x97e>
    assert(page_ref(p2) == 0);
ffffffffc0202b84:	000c2783          	lw	a5,0(s8)
ffffffffc0202b88:	68079a63          	bnez	a5,ffffffffc020321c <pmm_init+0x99e>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202b8c:	6088                	ld	a0,0(s1)
ffffffffc0202b8e:	6585                	lui	a1,0x1
ffffffffc0202b90:	c53ff0ef          	jal	ra,ffffffffc02027e2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b94:	000a2783          	lw	a5,0(s4)
ffffffffc0202b98:	5a079d63          	bnez	a5,ffffffffc0203152 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc0202b9c:	000c2783          	lw	a5,0(s8)
ffffffffc0202ba0:	7a079a63          	bnez	a5,ffffffffc0203354 <pmm_init+0xad6>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202ba4:	0004ba03          	ld	s4,0(s1)
    if (PPN(pa) >= npage)
ffffffffc0202ba8:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bac:	000a3683          	ld	a3,0(s4)
ffffffffc0202bb0:	068a                	slli	a3,a3,0x2
ffffffffc0202bb2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bb4:	48e6f163          	bgeu	a3,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb8:	000bb503          	ld	a0,0(s7)
ffffffffc0202bbc:	96d6                	add	a3,a3,s5
ffffffffc0202bbe:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202bc0:	00d507b3          	add	a5,a0,a3
ffffffffc0202bc4:	439c                	lw	a5,0(a5)
ffffffffc0202bc6:	7b979763          	bne	a5,s9,ffffffffc0203374 <pmm_init+0xaf6>
    return page - pages + nbase;
ffffffffc0202bca:	8699                	srai	a3,a3,0x6
ffffffffc0202bcc:	000805b7          	lui	a1,0x80
ffffffffc0202bd0:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202bd2:	00c69613          	slli	a2,a3,0xc
ffffffffc0202bd6:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bd8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202bda:	7ae67d63          	bgeu	a2,a4,ffffffffc0203394 <pmm_init+0xb16>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202bde:	0009b603          	ld	a2,0(s3)
ffffffffc0202be2:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202be4:	629c                	ld	a5,0(a3)
ffffffffc0202be6:	078a                	slli	a5,a5,0x2
ffffffffc0202be8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bea:	44e7f663          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bee:	8f8d                	sub	a5,a5,a1
ffffffffc0202bf0:	079a                	slli	a5,a5,0x6
ffffffffc0202bf2:	953e                	add	a0,a0,a5
ffffffffc0202bf4:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf8:	8b89                	andi	a5,a5,2
ffffffffc0202bfa:	32079a63          	bnez	a5,ffffffffc0202f2e <pmm_init+0x6b0>
        pmm_manager->free_pages(base, n);
ffffffffc0202bfe:	000b3783          	ld	a5,0(s6)
ffffffffc0202c02:	4585                	li	a1,1
ffffffffc0202c04:	739c                	ld	a5,32(a5)
ffffffffc0202c06:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c08:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202c0c:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c10:	078a                	slli	a5,a5,0x2
ffffffffc0202c12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c14:	42e7f163          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c18:	000bb503          	ld	a0,0(s7)
ffffffffc0202c1c:	fff80737          	lui	a4,0xfff80
ffffffffc0202c20:	97ba                	add	a5,a5,a4
ffffffffc0202c22:	079a                	slli	a5,a5,0x6
ffffffffc0202c24:	953e                	add	a0,a0,a5
ffffffffc0202c26:	100027f3          	csrr	a5,sstatus
ffffffffc0202c2a:	8b89                	andi	a5,a5,2
ffffffffc0202c2c:	2c079263          	bnez	a5,ffffffffc0202ef0 <pmm_init+0x672>
ffffffffc0202c30:	000b3783          	ld	a5,0(s6)
ffffffffc0202c34:	4585                	li	a1,1
ffffffffc0202c36:	739c                	ld	a5,32(a5)
ffffffffc0202c38:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202c3a:	609c                	ld	a5,0(s1)
ffffffffc0202c3c:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd5479c>
    asm volatile("sfence.vma");
ffffffffc0202c40:	12000073          	sfence.vma
ffffffffc0202c44:	100027f3          	csrr	a5,sstatus
ffffffffc0202c48:	8b89                	andi	a5,a5,2
ffffffffc0202c4a:	2c079863          	bnez	a5,ffffffffc0202f1a <pmm_init+0x69c>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c52:	779c                	ld	a5,40(a5)
ffffffffc0202c54:	9782                	jalr	a5
ffffffffc0202c56:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c58:	63441e63          	bne	s0,s4,ffffffffc0203294 <pmm_init+0xa16>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202c5c:	00004517          	auipc	a0,0x4
ffffffffc0202c60:	cf450513          	addi	a0,a0,-780 # ffffffffc0206950 <default_pmm_manager+0x598>
ffffffffc0202c64:	d30fd0ef          	jal	ra,ffffffffc0200194 <cprintf>
ffffffffc0202c68:	100027f3          	csrr	a5,sstatus
ffffffffc0202c6c:	8b89                	andi	a5,a5,2
ffffffffc0202c6e:	2c079c63          	bnez	a5,ffffffffc0202f46 <pmm_init+0x6c8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c72:	000b3783          	ld	a5,0(s6)
ffffffffc0202c76:	779c                	ld	a5,40(a5)
ffffffffc0202c78:	9782                	jalr	a5
ffffffffc0202c7a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c7c:	00093703          	ld	a4,0(s2)
ffffffffc0202c80:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c84:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c86:	00c71793          	slli	a5,a4,0xc
ffffffffc0202c8a:	6a05                	lui	s4,0x1
ffffffffc0202c8c:	02f47c63          	bgeu	s0,a5,ffffffffc0202cc4 <pmm_init+0x446>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c90:	00c45793          	srli	a5,s0,0xc
ffffffffc0202c94:	6088                	ld	a0,0(s1)
ffffffffc0202c96:	34e7f363          	bgeu	a5,a4,ffffffffc0202fdc <pmm_init+0x75e>
ffffffffc0202c9a:	0009b583          	ld	a1,0(s3)
ffffffffc0202c9e:	4601                	li	a2,0
ffffffffc0202ca0:	95a2                	add	a1,a1,s0
ffffffffc0202ca2:	954ff0ef          	jal	ra,ffffffffc0201df6 <get_pte>
ffffffffc0202ca6:	34050863          	beqz	a0,ffffffffc0202ff6 <pmm_init+0x778>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202caa:	611c                	ld	a5,0(a0)
ffffffffc0202cac:	078a                	slli	a5,a5,0x2
ffffffffc0202cae:	0157f7b3          	and	a5,a5,s5
ffffffffc0202cb2:	36879263          	bne	a5,s0,ffffffffc0203016 <pmm_init+0x798>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202cb6:	00093703          	ld	a4,0(s2)
ffffffffc0202cba:	9452                	add	s0,s0,s4
ffffffffc0202cbc:	00c71793          	slli	a5,a4,0xc
ffffffffc0202cc0:	fcf468e3          	bltu	s0,a5,ffffffffc0202c90 <pmm_init+0x412>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202cc4:	609c                	ld	a5,0(s1)
ffffffffc0202cc6:	639c                	ld	a5,0(a5)
ffffffffc0202cc8:	56079a63          	bnez	a5,ffffffffc020323c <pmm_init+0x9be>
ffffffffc0202ccc:	100027f3          	csrr	a5,sstatus
ffffffffc0202cd0:	8b89                	andi	a5,a5,2
ffffffffc0202cd2:	28079463          	bnez	a5,ffffffffc0202f5a <pmm_init+0x6dc>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202cd6:	000b3783          	ld	a5,0(s6)
ffffffffc0202cda:	4505                	li	a0,1
ffffffffc0202cdc:	6f9c                	ld	a5,24(a5)
ffffffffc0202cde:	9782                	jalr	a5
ffffffffc0202ce0:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202ce2:	6088                	ld	a0,0(s1)
ffffffffc0202ce4:	4699                	li	a3,6
ffffffffc0202ce6:	10000613          	li	a2,256
ffffffffc0202cea:	85d2                	mv	a1,s4
ffffffffc0202cec:	f5eff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202cf0:	36051563          	bnez	a0,ffffffffc020305a <pmm_init+0x7dc>
    assert(page_ref(p) == 1);
ffffffffc0202cf4:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0202cf8:	4785                	li	a5,1
ffffffffc0202cfa:	3cf71c63          	bne	a4,a5,ffffffffc02030d2 <pmm_init+0x854>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202cfe:	6088                	ld	a0,0(s1)
ffffffffc0202d00:	6405                	lui	s0,0x1
ffffffffc0202d02:	4699                	li	a3,6
ffffffffc0202d04:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac0>
ffffffffc0202d08:	85d2                	mv	a1,s4
ffffffffc0202d0a:	f40ff0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0202d0e:	3e051263          	bnez	a0,ffffffffc02030f2 <pmm_init+0x874>
    assert(page_ref(p) == 2);
ffffffffc0202d12:	000a2703          	lw	a4,0(s4)
ffffffffc0202d16:	4789                	li	a5,2
ffffffffc0202d18:	3ef71d63          	bne	a4,a5,ffffffffc0203112 <pmm_init+0x894>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202d1c:	00004597          	auipc	a1,0x4
ffffffffc0202d20:	d7c58593          	addi	a1,a1,-644 # ffffffffc0206a98 <default_pmm_manager+0x6e0>
ffffffffc0202d24:	10000513          	li	a0,256
ffffffffc0202d28:	09b020ef          	jal	ra,ffffffffc02055c2 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202d2c:	10040593          	addi	a1,s0,256
ffffffffc0202d30:	10000513          	li	a0,256
ffffffffc0202d34:	0a1020ef          	jal	ra,ffffffffc02055d4 <strcmp>
ffffffffc0202d38:	3e051d63          	bnez	a0,ffffffffc0203132 <pmm_init+0x8b4>
    return page - pages + nbase;
ffffffffc0202d3c:	000bb683          	ld	a3,0(s7)
ffffffffc0202d40:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202d44:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202d46:	40da06b3          	sub	a3,s4,a3
ffffffffc0202d4a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202d4c:	00093783          	ld	a5,0(s2)
    return page - pages + nbase;
ffffffffc0202d50:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202d52:	8031                	srli	s0,s0,0xc
ffffffffc0202d54:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d58:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d5a:	62f77d63          	bgeu	a4,a5,ffffffffc0203394 <pmm_init+0xb16>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d5e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d62:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d66:	96be                	add	a3,a3,a5
ffffffffc0202d68:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d6c:	021020ef          	jal	ra,ffffffffc020558c <strlen>
ffffffffc0202d70:	2c051563          	bnez	a0,ffffffffc020303a <pmm_init+0x7bc>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202d74:	0004ba83          	ld	s5,0(s1)
    if (PPN(pa) >= npage)
ffffffffc0202d78:	00093783          	ld	a5,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d7c:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd5479c>
ffffffffc0202d80:	068a                	slli	a3,a3,0x2
ffffffffc0202d82:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d84:	2af6f963          	bgeu	a3,a5,ffffffffc0203036 <pmm_init+0x7b8>
    return KADDR(page2pa(page));
ffffffffc0202d88:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d8a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d8c:	60f47463          	bgeu	s0,a5,ffffffffc0203394 <pmm_init+0xb16>
ffffffffc0202d90:	0009b403          	ld	s0,0(s3)
ffffffffc0202d94:	9436                	add	s0,s0,a3
ffffffffc0202d96:	100027f3          	csrr	a5,sstatus
ffffffffc0202d9a:	8b89                	andi	a5,a5,2
ffffffffc0202d9c:	1c079a63          	bnez	a5,ffffffffc0202f70 <pmm_init+0x6f2>
        pmm_manager->free_pages(base, n);
ffffffffc0202da0:	000b3783          	ld	a5,0(s6)
ffffffffc0202da4:	4585                	li	a1,1
ffffffffc0202da6:	8552                	mv	a0,s4
ffffffffc0202da8:	739c                	ld	a5,32(a5)
ffffffffc0202daa:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dac:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202dae:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202db2:	078a                	slli	a5,a5,0x2
ffffffffc0202db4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202db6:	28e7f063          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dba:	000bb503          	ld	a0,0(s7)
ffffffffc0202dbe:	fff80737          	lui	a4,0xfff80
ffffffffc0202dc2:	97ba                	add	a5,a5,a4
ffffffffc0202dc4:	079a                	slli	a5,a5,0x6
ffffffffc0202dc6:	953e                	add	a0,a0,a5
ffffffffc0202dc8:	100027f3          	csrr	a5,sstatus
ffffffffc0202dcc:	8b89                	andi	a5,a5,2
ffffffffc0202dce:	1e079b63          	bnez	a5,ffffffffc0202fc4 <pmm_init+0x746>
ffffffffc0202dd2:	000b3783          	ld	a5,0(s6)
ffffffffc0202dd6:	4585                	li	a1,1
ffffffffc0202dd8:	739c                	ld	a5,32(a5)
ffffffffc0202dda:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ddc:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202de0:	00093703          	ld	a4,0(s2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202de4:	078a                	slli	a5,a5,0x2
ffffffffc0202de6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202de8:	24e7f763          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dec:	000bb503          	ld	a0,0(s7)
ffffffffc0202df0:	fff80737          	lui	a4,0xfff80
ffffffffc0202df4:	97ba                	add	a5,a5,a4
ffffffffc0202df6:	079a                	slli	a5,a5,0x6
ffffffffc0202df8:	953e                	add	a0,a0,a5
ffffffffc0202dfa:	100027f3          	csrr	a5,sstatus
ffffffffc0202dfe:	8b89                	andi	a5,a5,2
ffffffffc0202e00:	18079363          	bnez	a5,ffffffffc0202f86 <pmm_init+0x708>
ffffffffc0202e04:	000b3783          	ld	a5,0(s6)
ffffffffc0202e08:	4585                	li	a1,1
ffffffffc0202e0a:	739c                	ld	a5,32(a5)
ffffffffc0202e0c:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202e0e:	609c                	ld	a5,0(s1)
ffffffffc0202e10:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202e14:	12000073          	sfence.vma
ffffffffc0202e18:	100027f3          	csrr	a5,sstatus
ffffffffc0202e1c:	8b89                	andi	a5,a5,2
ffffffffc0202e1e:	18079963          	bnez	a5,ffffffffc0202fb0 <pmm_init+0x732>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e22:	000b3783          	ld	a5,0(s6)
ffffffffc0202e26:	779c                	ld	a5,40(a5)
ffffffffc0202e28:	9782                	jalr	a5
ffffffffc0202e2a:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202e2c:	348c1363          	bne	s8,s0,ffffffffc0203172 <pmm_init+0x8f4>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202e30:	00004517          	auipc	a0,0x4
ffffffffc0202e34:	ce050513          	addi	a0,a0,-800 # ffffffffc0206b10 <default_pmm_manager+0x758>
ffffffffc0202e38:	b5cfd0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0202e3c:	7406                	ld	s0,96(sp)
ffffffffc0202e3e:	70a6                	ld	ra,104(sp)
ffffffffc0202e40:	64e6                	ld	s1,88(sp)
ffffffffc0202e42:	6946                	ld	s2,80(sp)
ffffffffc0202e44:	69a6                	ld	s3,72(sp)
ffffffffc0202e46:	6a06                	ld	s4,64(sp)
ffffffffc0202e48:	7ae2                	ld	s5,56(sp)
ffffffffc0202e4a:	7b42                	ld	s6,48(sp)
ffffffffc0202e4c:	7ba2                	ld	s7,40(sp)
ffffffffc0202e4e:	7c02                	ld	s8,32(sp)
ffffffffc0202e50:	6ce2                	ld	s9,24(sp)
ffffffffc0202e52:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202e54:	cedfe06f          	j	ffffffffc0201b40 <kmalloc_init>
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202e58:	76fd                	lui	a3,0xfffff
ffffffffc0202e5a:	000a9797          	auipc	a5,0xa9
ffffffffc0202e5e:	a0978793          	addi	a5,a5,-1527 # ffffffffc02ab863 <end+0xfff>
ffffffffc0202e62:	8ff5                	and	a5,a5,a3
    npage = PPN(mem_end);
ffffffffc0202e64:	000a8917          	auipc	s2,0xa8
ffffffffc0202e68:	9bc90913          	addi	s2,s2,-1604 # ffffffffc02aa820 <npage>
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202e6c:	000a8b97          	auipc	s7,0xa8
ffffffffc0202e70:	9bcb8b93          	addi	s7,s7,-1604 # ffffffffc02aa828 <pages>
    npage = PPN(mem_end);
ffffffffc0202e74:	000886b7          	lui	a3,0x88
ffffffffc0202e78:	00d93023          	sd	a3,0(s2)
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0202e7c:	00fbb023          	sd	a5,0(s7)
    size_t nr_pages = npage - nbase;
ffffffffc0202e80:	68a1                	lui	a7,0x8
        mem_end = (KERNTOP - PHYSICAL_MEMORY_OFFSET);
ffffffffc0202e82:	84ba                	mv	s1,a4
ffffffffc0202e84:	b46d                	j	ffffffffc020292e <pmm_init+0xb0>
        intr_disable();
ffffffffc0202e86:	aeffd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e8e:	779c                	ld	a5,40(a5)
ffffffffc0202e90:	9782                	jalr	a5
ffffffffc0202e92:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e94:	adbfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202e98:	beb1                	j	ffffffffc02029f4 <pmm_init+0x176>
    if (PPN(pa) >= npage)
ffffffffc0202e9a:	00093703          	ld	a4,0(s2)
ffffffffc0202e9e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202ea2:	18e7fa63          	bgeu	a5,a4,ffffffffc0203036 <pmm_init+0x7b8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202ea6:	000b3703          	ld	a4,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202eaa:	000bb503          	ld	a0,0(s7)
ffffffffc0202eae:	fff806b7          	lui	a3,0xfff80
ffffffffc0202eb2:	97b6                	add	a5,a5,a3
ffffffffc0202eb4:	6b18                	ld	a4,16(a4)
        init_memmap(pa2page(free_start), (free_end - free_start) / PGSIZE);
ffffffffc0202eb6:	408485b3          	sub	a1,s1,s0
ffffffffc0202eba:	079a                	slli	a5,a5,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202ebc:	81b1                	srli	a1,a1,0xc
ffffffffc0202ebe:	953e                	add	a0,a0,a5
ffffffffc0202ec0:	9702                	jalr	a4
}
ffffffffc0202ec2:	b4cd                	j	ffffffffc02029a4 <pmm_init+0x126>
        intr_disable();
ffffffffc0202ec4:	ab1fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ec8:	000b3783          	ld	a5,0(s6)
ffffffffc0202ecc:	4505                	li	a0,1
ffffffffc0202ece:	6f9c                	ld	a5,24(a5)
ffffffffc0202ed0:	9782                	jalr	a5
ffffffffc0202ed2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202ed4:	a9bfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202ed8:	beed                	j	ffffffffc0202ad2 <pmm_init+0x254>
        intr_disable();
ffffffffc0202eda:	a9bfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202ede:	000b3783          	ld	a5,0(s6)
ffffffffc0202ee2:	4505                	li	a0,1
ffffffffc0202ee4:	6f9c                	ld	a5,24(a5)
ffffffffc0202ee6:	9782                	jalr	a5
ffffffffc0202ee8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202eea:	a85fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202eee:	b691                	j	ffffffffc0202a32 <pmm_init+0x1b4>
ffffffffc0202ef0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ef2:	a83fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ef6:	000b3783          	ld	a5,0(s6)
ffffffffc0202efa:	6522                	ld	a0,8(sp)
ffffffffc0202efc:	4585                	li	a1,1
ffffffffc0202efe:	739c                	ld	a5,32(a5)
ffffffffc0202f00:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f02:	a6dfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
    boot_pgdir_va[0] = 0;
ffffffffc0202f06:	609c                	ld	a5,0(s1)
ffffffffc0202f08:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202f0c:	12000073          	sfence.vma
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202f10:	100027f3          	csrr	a5,sstatus
ffffffffc0202f14:	8b89                	andi	a5,a5,2
ffffffffc0202f16:	d2078ce3          	beqz	a5,ffffffffc0202c4e <pmm_init+0x3d0>
        intr_disable();
ffffffffc0202f1a:	a5bfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f1e:	000b3783          	ld	a5,0(s6)
ffffffffc0202f22:	779c                	ld	a5,40(a5)
ffffffffc0202f24:	9782                	jalr	a5
ffffffffc0202f26:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202f28:	a47fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202f2c:	b335                	j	ffffffffc0202c58 <pmm_init+0x3da>
ffffffffc0202f2e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f30:	a45fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f34:	000b3783          	ld	a5,0(s6)
ffffffffc0202f38:	6522                	ld	a0,8(sp)
ffffffffc0202f3a:	4585                	li	a1,1
ffffffffc0202f3c:	739c                	ld	a5,32(a5)
ffffffffc0202f3e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f40:	a2ffd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202f44:	b1d1                	j	ffffffffc0202c08 <pmm_init+0x38a>
        intr_disable();
ffffffffc0202f46:	a2ffd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f4a:	000b3783          	ld	a5,0(s6)
ffffffffc0202f4e:	779c                	ld	a5,40(a5)
ffffffffc0202f50:	9782                	jalr	a5
ffffffffc0202f52:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202f54:	a1bfd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202f58:	b315                	j	ffffffffc0202c7c <pmm_init+0x3fe>
        intr_disable();
ffffffffc0202f5a:	a1bfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202f5e:	000b3783          	ld	a5,0(s6)
ffffffffc0202f62:	4505                	li	a0,1
ffffffffc0202f64:	6f9c                	ld	a5,24(a5)
ffffffffc0202f66:	9782                	jalr	a5
ffffffffc0202f68:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202f6a:	a05fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202f6e:	bb95                	j	ffffffffc0202ce2 <pmm_init+0x464>
        intr_disable();
ffffffffc0202f70:	a05fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f74:	000b3783          	ld	a5,0(s6)
ffffffffc0202f78:	4585                	li	a1,1
ffffffffc0202f7a:	8552                	mv	a0,s4
ffffffffc0202f7c:	739c                	ld	a5,32(a5)
ffffffffc0202f7e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f80:	9effd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202f84:	b525                	j	ffffffffc0202dac <pmm_init+0x52e>
ffffffffc0202f86:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f88:	9edfd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc0202f8c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f90:	6522                	ld	a0,8(sp)
ffffffffc0202f92:	4585                	li	a1,1
ffffffffc0202f94:	739c                	ld	a5,32(a5)
ffffffffc0202f96:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f98:	9d7fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
    boot_pgdir_va[0] = 0;
ffffffffc0202f9c:	609c                	ld	a5,0(s1)
ffffffffc0202f9e:	0007b023          	sd	zero,0(a5)
ffffffffc0202fa2:	12000073          	sfence.vma
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202fa6:	100027f3          	csrr	a5,sstatus
ffffffffc0202faa:	8b89                	andi	a5,a5,2
ffffffffc0202fac:	e6078be3          	beqz	a5,ffffffffc0202e22 <pmm_init+0x5a4>
        intr_disable();
ffffffffc0202fb0:	9c5fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202fb8:	779c                	ld	a5,40(a5)
ffffffffc0202fba:	9782                	jalr	a5
ffffffffc0202fbc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202fbe:	9b1fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202fc2:	b5ad                	j	ffffffffc0202e2c <pmm_init+0x5ae>
ffffffffc0202fc4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202fc6:	9affd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202fca:	000b3783          	ld	a5,0(s6)
ffffffffc0202fce:	6522                	ld	a0,8(sp)
ffffffffc0202fd0:	4585                	li	a1,1
ffffffffc0202fd2:	739c                	ld	a5,32(a5)
ffffffffc0202fd4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202fd6:	999fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0202fda:	b509                	j	ffffffffc0202ddc <pmm_init+0x55e>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202fdc:	86a2                	mv	a3,s0
ffffffffc0202fde:	00003617          	auipc	a2,0x3
ffffffffc0202fe2:	41260613          	addi	a2,a2,1042 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0202fe6:	26500593          	li	a1,613
ffffffffc0202fea:	00003517          	auipc	a0,0x3
ffffffffc0202fee:	51e50513          	addi	a0,a0,1310 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0202ff2:	c5cfd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0202ff6:	00004697          	auipc	a3,0x4
ffffffffc0202ffa:	97a68693          	addi	a3,a3,-1670 # ffffffffc0206970 <default_pmm_manager+0x5b8>
ffffffffc0202ffe:	00003617          	auipc	a2,0x3
ffffffffc0203002:	00a60613          	addi	a2,a2,10 # ffffffffc0206008 <commands+0x748>
ffffffffc0203006:	26500593          	li	a1,613
ffffffffc020300a:	00003517          	auipc	a0,0x3
ffffffffc020300e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203012:	c3cfd0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203016:	00004697          	auipc	a3,0x4
ffffffffc020301a:	99a68693          	addi	a3,a3,-1638 # ffffffffc02069b0 <default_pmm_manager+0x5f8>
ffffffffc020301e:	00003617          	auipc	a2,0x3
ffffffffc0203022:	fea60613          	addi	a2,a2,-22 # ffffffffc0206008 <commands+0x748>
ffffffffc0203026:	26600593          	li	a1,614
ffffffffc020302a:	00003517          	auipc	a0,0x3
ffffffffc020302e:	4de50513          	addi	a0,a0,1246 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203032:	c1cfd0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0203036:	cd1fe0ef          	jal	ra,ffffffffc0201d06 <pa2page.part.0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020303a:	00004697          	auipc	a3,0x4
ffffffffc020303e:	aae68693          	addi	a3,a3,-1362 # ffffffffc0206ae8 <default_pmm_manager+0x730>
ffffffffc0203042:	00003617          	auipc	a2,0x3
ffffffffc0203046:	fc660613          	addi	a2,a2,-58 # ffffffffc0206008 <commands+0x748>
ffffffffc020304a:	27700593          	li	a1,631
ffffffffc020304e:	00003517          	auipc	a0,0x3
ffffffffc0203052:	4ba50513          	addi	a0,a0,1210 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203056:	bf8fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020305a:	00004697          	auipc	a3,0x4
ffffffffc020305e:	98668693          	addi	a3,a3,-1658 # ffffffffc02069e0 <default_pmm_manager+0x628>
ffffffffc0203062:	00003617          	auipc	a2,0x3
ffffffffc0203066:	fa660613          	addi	a2,a2,-90 # ffffffffc0206008 <commands+0x748>
ffffffffc020306a:	26d00593          	li	a1,621
ffffffffc020306e:	00003517          	auipc	a0,0x3
ffffffffc0203072:	49a50513          	addi	a0,a0,1178 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203076:	bd8fd0ef          	jal	ra,ffffffffc020044e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020307a:	00003617          	auipc	a2,0x3
ffffffffc020307e:	41e60613          	addi	a2,a2,1054 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc0203082:	0de00593          	li	a1,222
ffffffffc0203086:	00003517          	auipc	a0,0x3
ffffffffc020308a:	48250513          	addi	a0,a0,1154 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020308e:	bc0fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203092:	00003697          	auipc	a3,0x3
ffffffffc0203096:	5b668693          	addi	a3,a3,1462 # ffffffffc0206648 <default_pmm_manager+0x290>
ffffffffc020309a:	00003617          	auipc	a2,0x3
ffffffffc020309e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0206008 <commands+0x748>
ffffffffc02030a2:	22600593          	li	a1,550
ffffffffc02030a6:	00003517          	auipc	a0,0x3
ffffffffc02030aa:	46250513          	addi	a0,a0,1122 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02030ae:	ba0fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02030b2:	00003697          	auipc	a3,0x3
ffffffffc02030b6:	5b668693          	addi	a3,a3,1462 # ffffffffc0206668 <default_pmm_manager+0x2b0>
ffffffffc02030ba:	00003617          	auipc	a2,0x3
ffffffffc02030be:	f4e60613          	addi	a2,a2,-178 # ffffffffc0206008 <commands+0x748>
ffffffffc02030c2:	22700593          	li	a1,551
ffffffffc02030c6:	00003517          	auipc	a0,0x3
ffffffffc02030ca:	44250513          	addi	a0,a0,1090 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02030ce:	b80fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02030d2:	00004697          	auipc	a3,0x4
ffffffffc02030d6:	94e68693          	addi	a3,a3,-1714 # ffffffffc0206a20 <default_pmm_manager+0x668>
ffffffffc02030da:	00003617          	auipc	a2,0x3
ffffffffc02030de:	f2e60613          	addi	a2,a2,-210 # ffffffffc0206008 <commands+0x748>
ffffffffc02030e2:	26e00593          	li	a1,622
ffffffffc02030e6:	00003517          	auipc	a0,0x3
ffffffffc02030ea:	42250513          	addi	a0,a0,1058 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02030ee:	b60fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02030f2:	00004697          	auipc	a3,0x4
ffffffffc02030f6:	94668693          	addi	a3,a3,-1722 # ffffffffc0206a38 <default_pmm_manager+0x680>
ffffffffc02030fa:	00003617          	auipc	a2,0x3
ffffffffc02030fe:	f0e60613          	addi	a2,a2,-242 # ffffffffc0206008 <commands+0x748>
ffffffffc0203102:	26f00593          	li	a1,623
ffffffffc0203106:	00003517          	auipc	a0,0x3
ffffffffc020310a:	40250513          	addi	a0,a0,1026 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020310e:	b40fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203112:	00004697          	auipc	a3,0x4
ffffffffc0203116:	96e68693          	addi	a3,a3,-1682 # ffffffffc0206a80 <default_pmm_manager+0x6c8>
ffffffffc020311a:	00003617          	auipc	a2,0x3
ffffffffc020311e:	eee60613          	addi	a2,a2,-274 # ffffffffc0206008 <commands+0x748>
ffffffffc0203122:	27000593          	li	a1,624
ffffffffc0203126:	00003517          	auipc	a0,0x3
ffffffffc020312a:	3e250513          	addi	a0,a0,994 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020312e:	b20fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203132:	00004697          	auipc	a3,0x4
ffffffffc0203136:	97e68693          	addi	a3,a3,-1666 # ffffffffc0206ab0 <default_pmm_manager+0x6f8>
ffffffffc020313a:	00003617          	auipc	a2,0x3
ffffffffc020313e:	ece60613          	addi	a2,a2,-306 # ffffffffc0206008 <commands+0x748>
ffffffffc0203142:	27400593          	li	a1,628
ffffffffc0203146:	00003517          	auipc	a0,0x3
ffffffffc020314a:	3c250513          	addi	a0,a0,962 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020314e:	b00fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203152:	00003697          	auipc	a3,0x3
ffffffffc0203156:	78e68693          	addi	a3,a3,1934 # ffffffffc02068e0 <default_pmm_manager+0x528>
ffffffffc020315a:	00003617          	auipc	a2,0x3
ffffffffc020315e:	eae60613          	addi	a2,a2,-338 # ffffffffc0206008 <commands+0x748>
ffffffffc0203162:	24b00593          	li	a1,587
ffffffffc0203166:	00003517          	auipc	a0,0x3
ffffffffc020316a:	3a250513          	addi	a0,a0,930 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020316e:	ae0fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203172:	00003697          	auipc	a3,0x3
ffffffffc0203176:	7b668693          	addi	a3,a3,1974 # ffffffffc0206928 <default_pmm_manager+0x570>
ffffffffc020317a:	00003617          	auipc	a2,0x3
ffffffffc020317e:	e8e60613          	addi	a2,a2,-370 # ffffffffc0206008 <commands+0x748>
ffffffffc0203182:	28000593          	li	a1,640
ffffffffc0203186:	00003517          	auipc	a0,0x3
ffffffffc020318a:	38250513          	addi	a0,a0,898 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc020318e:	ac0fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("page_init: invalid physical memory info from DTB");
ffffffffc0203192:	00003617          	auipc	a2,0x3
ffffffffc0203196:	3e660613          	addi	a2,a2,998 # ffffffffc0206578 <default_pmm_manager+0x1c0>
ffffffffc020319a:	06400593          	li	a1,100
ffffffffc020319e:	00003517          	auipc	a0,0x3
ffffffffc02031a2:	36a50513          	addi	a0,a0,874 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02031a6:	aa8fd0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("page_init: physical memory range is invalid");
ffffffffc02031aa:	00003617          	auipc	a2,0x3
ffffffffc02031ae:	40660613          	addi	a2,a2,1030 # ffffffffc02065b0 <default_pmm_manager+0x1f8>
ffffffffc02031b2:	07200593          	li	a1,114
ffffffffc02031b6:	00003517          	auipc	a0,0x3
ffffffffc02031ba:	35250513          	addi	a0,a0,850 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02031be:	a90fd0ef          	jal	ra,ffffffffc020044e <__panic>
    uintptr_t pages_pa = PADDR(pages);
ffffffffc02031c2:	86a2                	mv	a3,s0
ffffffffc02031c4:	00003617          	auipc	a2,0x3
ffffffffc02031c8:	2d460613          	addi	a2,a2,724 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc02031cc:	08700593          	li	a1,135
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	33850513          	addi	a0,a0,824 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02031d8:	a76fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031dc:	00003697          	auipc	a3,0x3
ffffffffc02031e0:	6ec68693          	addi	a3,a3,1772 # ffffffffc02068c8 <default_pmm_manager+0x510>
ffffffffc02031e4:	00003617          	auipc	a2,0x3
ffffffffc02031e8:	e2460613          	addi	a2,a2,-476 # ffffffffc0206008 <commands+0x748>
ffffffffc02031ec:	24400593          	li	a1,580
ffffffffc02031f0:	00003517          	auipc	a0,0x3
ffffffffc02031f4:	31850513          	addi	a0,a0,792 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02031f8:	a56fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02031fc:	00003697          	auipc	a3,0x3
ffffffffc0203200:	55468693          	addi	a3,a3,1364 # ffffffffc0206750 <default_pmm_manager+0x398>
ffffffffc0203204:	00003617          	auipc	a2,0x3
ffffffffc0203208:	e0460613          	addi	a2,a2,-508 # ffffffffc0206008 <commands+0x748>
ffffffffc020320c:	24700593          	li	a1,583
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	2f850513          	addi	a0,a0,760 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203218:	a36fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020321c:	00003697          	auipc	a3,0x3
ffffffffc0203220:	69468693          	addi	a3,a3,1684 # ffffffffc02068b0 <default_pmm_manager+0x4f8>
ffffffffc0203224:	00003617          	auipc	a2,0x3
ffffffffc0203228:	de460613          	addi	a2,a2,-540 # ffffffffc0206008 <commands+0x748>
ffffffffc020322c:	24800593          	li	a1,584
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	2d850513          	addi	a0,a0,728 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203238:	a16fd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020323c:	00003697          	auipc	a3,0x3
ffffffffc0203240:	78c68693          	addi	a3,a3,1932 # ffffffffc02069c8 <default_pmm_manager+0x610>
ffffffffc0203244:	00003617          	auipc	a2,0x3
ffffffffc0203248:	dc460613          	addi	a2,a2,-572 # ffffffffc0206008 <commands+0x748>
ffffffffc020324c:	26900593          	li	a1,617
ffffffffc0203250:	00003517          	auipc	a0,0x3
ffffffffc0203254:	2b850513          	addi	a0,a0,696 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203258:	9f6fd0ef          	jal	ra,ffffffffc020044e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020325c:	00003617          	auipc	a2,0x3
ffffffffc0203260:	19460613          	addi	a2,a2,404 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0203264:	23300593          	li	a1,563
ffffffffc0203268:	00003517          	auipc	a0,0x3
ffffffffc020326c:	2a050513          	addi	a0,a0,672 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203270:	9defd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203274:	00003697          	auipc	a3,0x3
ffffffffc0203278:	4c468693          	addi	a3,a3,1220 # ffffffffc0206738 <default_pmm_manager+0x380>
ffffffffc020327c:	00003617          	auipc	a2,0x3
ffffffffc0203280:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206008 <commands+0x748>
ffffffffc0203284:	23000593          	li	a1,560
ffffffffc0203288:	00003517          	auipc	a0,0x3
ffffffffc020328c:	28050513          	addi	a0,a0,640 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203290:	9befd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203294:	00003697          	auipc	a3,0x3
ffffffffc0203298:	69468693          	addi	a3,a3,1684 # ffffffffc0206928 <default_pmm_manager+0x570>
ffffffffc020329c:	00003617          	auipc	a2,0x3
ffffffffc02032a0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0206008 <commands+0x748>
ffffffffc02032a4:	25600593          	li	a1,598
ffffffffc02032a8:	00003517          	auipc	a0,0x3
ffffffffc02032ac:	26050513          	addi	a0,a0,608 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02032b0:	99efd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02032b4:	00003697          	auipc	a3,0x3
ffffffffc02032b8:	5b468693          	addi	a3,a3,1460 # ffffffffc0206868 <default_pmm_manager+0x4b0>
ffffffffc02032bc:	00003617          	auipc	a2,0x3
ffffffffc02032c0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0206008 <commands+0x748>
ffffffffc02032c4:	23f00593          	li	a1,575
ffffffffc02032c8:	00003517          	auipc	a0,0x3
ffffffffc02032cc:	24050513          	addi	a0,a0,576 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02032d0:	97efd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02032d4:	00003697          	auipc	a3,0x3
ffffffffc02032d8:	5c468693          	addi	a3,a3,1476 # ffffffffc0206898 <default_pmm_manager+0x4e0>
ffffffffc02032dc:	00003617          	auipc	a2,0x3
ffffffffc02032e0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206008 <commands+0x748>
ffffffffc02032e4:	24000593          	li	a1,576
ffffffffc02032e8:	00003517          	auipc	a0,0x3
ffffffffc02032ec:	22050513          	addi	a0,a0,544 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02032f0:	95efd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02032f4:	00003697          	auipc	a3,0x3
ffffffffc02032f8:	5bc68693          	addi	a3,a3,1468 # ffffffffc02068b0 <default_pmm_manager+0x4f8>
ffffffffc02032fc:	00003617          	auipc	a2,0x3
ffffffffc0203300:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206008 <commands+0x748>
ffffffffc0203304:	24100593          	li	a1,577
ffffffffc0203308:	00003517          	auipc	a0,0x3
ffffffffc020330c:	20050513          	addi	a0,a0,512 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203310:	93efd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203314:	00003697          	auipc	a3,0x3
ffffffffc0203318:	4c468693          	addi	a3,a3,1220 # ffffffffc02067d8 <default_pmm_manager+0x420>
ffffffffc020331c:	00003617          	auipc	a2,0x3
ffffffffc0203320:	cec60613          	addi	a2,a2,-788 # ffffffffc0206008 <commands+0x748>
ffffffffc0203324:	24200593          	li	a1,578
ffffffffc0203328:	00003517          	auipc	a0,0x3
ffffffffc020332c:	1e050513          	addi	a0,a0,480 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203330:	91efd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203334:	00003697          	auipc	a3,0x3
ffffffffc0203338:	40468693          	addi	a3,a3,1028 # ffffffffc0206738 <default_pmm_manager+0x380>
ffffffffc020333c:	00003617          	auipc	a2,0x3
ffffffffc0203340:	ccc60613          	addi	a2,a2,-820 # ffffffffc0206008 <commands+0x748>
ffffffffc0203344:	24300593          	li	a1,579
ffffffffc0203348:	00003517          	auipc	a0,0x3
ffffffffc020334c:	1c050513          	addi	a0,a0,448 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203350:	8fefd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203354:	00003697          	auipc	a3,0x3
ffffffffc0203358:	55c68693          	addi	a3,a3,1372 # ffffffffc02068b0 <default_pmm_manager+0x4f8>
ffffffffc020335c:	00003617          	auipc	a2,0x3
ffffffffc0203360:	cac60613          	addi	a2,a2,-852 # ffffffffc0206008 <commands+0x748>
ffffffffc0203364:	24c00593          	li	a1,588
ffffffffc0203368:	00003517          	auipc	a0,0x3
ffffffffc020336c:	1a050513          	addi	a0,a0,416 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203370:	8defd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203374:	00003697          	auipc	a3,0x3
ffffffffc0203378:	58468693          	addi	a3,a3,1412 # ffffffffc02068f8 <default_pmm_manager+0x540>
ffffffffc020337c:	00003617          	auipc	a2,0x3
ffffffffc0203380:	c8c60613          	addi	a2,a2,-884 # ffffffffc0206008 <commands+0x748>
ffffffffc0203384:	24e00593          	li	a1,590
ffffffffc0203388:	00003517          	auipc	a0,0x3
ffffffffc020338c:	18050513          	addi	a0,a0,384 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203390:	8befd0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203394:	00003617          	auipc	a2,0x3
ffffffffc0203398:	05c60613          	addi	a2,a2,92 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc020339c:	07100593          	li	a1,113
ffffffffc02033a0:	00003517          	auipc	a0,0x3
ffffffffc02033a4:	07850513          	addi	a0,a0,120 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc02033a8:	8a6fd0ef          	jal	ra,ffffffffc020044e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02033ac:	86d6                	mv	a3,s5
ffffffffc02033ae:	00003617          	auipc	a2,0x3
ffffffffc02033b2:	04260613          	addi	a2,a2,66 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc02033b6:	23400593          	li	a1,564
ffffffffc02033ba:	00003517          	auipc	a0,0x3
ffffffffc02033be:	14e50513          	addi	a0,a0,334 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02033c2:	88cfd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02033c6:	00003697          	auipc	a3,0x3
ffffffffc02033ca:	3a268693          	addi	a3,a3,930 # ffffffffc0206768 <default_pmm_manager+0x3b0>
ffffffffc02033ce:	00003617          	auipc	a2,0x3
ffffffffc02033d2:	c3a60613          	addi	a2,a2,-966 # ffffffffc0206008 <commands+0x748>
ffffffffc02033d6:	23500593          	li	a1,565
ffffffffc02033da:	00003517          	auipc	a0,0x3
ffffffffc02033de:	12e50513          	addi	a0,a0,302 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02033e2:	86cfd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02033e6:	00003697          	auipc	a3,0x3
ffffffffc02033ea:	3b268693          	addi	a3,a3,946 # ffffffffc0206798 <default_pmm_manager+0x3e0>
ffffffffc02033ee:	00003617          	auipc	a2,0x3
ffffffffc02033f2:	c1a60613          	addi	a2,a2,-998 # ffffffffc0206008 <commands+0x748>
ffffffffc02033f6:	23800593          	li	a1,568
ffffffffc02033fa:	00003517          	auipc	a0,0x3
ffffffffc02033fe:	10e50513          	addi	a0,a0,270 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203402:	84cfd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203406:	00003697          	auipc	a3,0x3
ffffffffc020340a:	3d268693          	addi	a3,a3,978 # ffffffffc02067d8 <default_pmm_manager+0x420>
ffffffffc020340e:	00003617          	auipc	a2,0x3
ffffffffc0203412:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206008 <commands+0x748>
ffffffffc0203416:	23900593          	li	a1,569
ffffffffc020341a:	00003517          	auipc	a0,0x3
ffffffffc020341e:	0ee50513          	addi	a0,a0,238 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203422:	82cfd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203426:	00003697          	auipc	a3,0x3
ffffffffc020342a:	3ea68693          	addi	a3,a3,1002 # ffffffffc0206810 <default_pmm_manager+0x458>
ffffffffc020342e:	00003617          	auipc	a2,0x3
ffffffffc0203432:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206008 <commands+0x748>
ffffffffc0203436:	23a00593          	li	a1,570
ffffffffc020343a:	00003517          	auipc	a0,0x3
ffffffffc020343e:	0ce50513          	addi	a0,a0,206 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203442:	80cfd0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203446:	00003697          	auipc	a3,0x3
ffffffffc020344a:	3da68693          	addi	a3,a3,986 # ffffffffc0206820 <default_pmm_manager+0x468>
ffffffffc020344e:	00003617          	auipc	a2,0x3
ffffffffc0203452:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206008 <commands+0x748>
ffffffffc0203456:	23b00593          	li	a1,571
ffffffffc020345a:	00003517          	auipc	a0,0x3
ffffffffc020345e:	0ae50513          	addi	a0,a0,174 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203462:	fedfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203466:	00003697          	auipc	a3,0x3
ffffffffc020346a:	3ca68693          	addi	a3,a3,970 # ffffffffc0206830 <default_pmm_manager+0x478>
ffffffffc020346e:	00003617          	auipc	a2,0x3
ffffffffc0203472:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206008 <commands+0x748>
ffffffffc0203476:	23c00593          	li	a1,572
ffffffffc020347a:	00003517          	auipc	a0,0x3
ffffffffc020347e:	08e50513          	addi	a0,a0,142 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203482:	fcdfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203486:	00003697          	auipc	a3,0x3
ffffffffc020348a:	3ca68693          	addi	a3,a3,970 # ffffffffc0206850 <default_pmm_manager+0x498>
ffffffffc020348e:	00003617          	auipc	a2,0x3
ffffffffc0203492:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0206008 <commands+0x748>
ffffffffc0203496:	23d00593          	li	a1,573
ffffffffc020349a:	00003517          	auipc	a0,0x3
ffffffffc020349e:	06e50513          	addi	a0,a0,110 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02034a2:	fadfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02034a6:	00003697          	auipc	a3,0x3
ffffffffc02034aa:	20268693          	addi	a3,a3,514 # ffffffffc02066a8 <default_pmm_manager+0x2f0>
ffffffffc02034ae:	00003617          	auipc	a2,0x3
ffffffffc02034b2:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206008 <commands+0x748>
ffffffffc02034b6:	22800593          	li	a1,552
ffffffffc02034ba:	00003517          	auipc	a0,0x3
ffffffffc02034be:	04e50513          	addi	a0,a0,78 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02034c2:	f8dfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02034c6:	00003697          	auipc	a3,0x3
ffffffffc02034ca:	21268693          	addi	a3,a3,530 # ffffffffc02066d8 <default_pmm_manager+0x320>
ffffffffc02034ce:	00003617          	auipc	a2,0x3
ffffffffc02034d2:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206008 <commands+0x748>
ffffffffc02034d6:	22c00593          	li	a1,556
ffffffffc02034da:	00003517          	auipc	a0,0x3
ffffffffc02034de:	02e50513          	addi	a0,a0,46 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02034e2:	f6dfc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02034e6:	00003697          	auipc	a3,0x3
ffffffffc02034ea:	22268693          	addi	a3,a3,546 # ffffffffc0206708 <default_pmm_manager+0x350>
ffffffffc02034ee:	00003617          	auipc	a2,0x3
ffffffffc02034f2:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206008 <commands+0x748>
ffffffffc02034f6:	22f00593          	li	a1,559
ffffffffc02034fa:	00003517          	auipc	a0,0x3
ffffffffc02034fe:	00e50513          	addi	a0,a0,14 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203502:	f4dfc0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0203506:	81dfe0ef          	jal	ra,ffffffffc0201d22 <pte2page.part.0>
    assert(page_ref(p1) == 1);
ffffffffc020350a:	00003697          	auipc	a3,0x3
ffffffffc020350e:	24668693          	addi	a3,a3,582 # ffffffffc0206750 <default_pmm_manager+0x398>
ffffffffc0203512:	00003617          	auipc	a2,0x3
ffffffffc0203516:	af660613          	addi	a2,a2,-1290 # ffffffffc0206008 <commands+0x748>
ffffffffc020351a:	23100593          	li	a1,561
ffffffffc020351e:	00003517          	auipc	a0,0x3
ffffffffc0203522:	fea50513          	addi	a0,a0,-22 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc0203526:	f29fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020352a <pgdir_alloc_page>:
{
ffffffffc020352a:	7179                	addi	sp,sp,-48
ffffffffc020352c:	ec26                	sd	s1,24(sp)
ffffffffc020352e:	e84a                	sd	s2,16(sp)
ffffffffc0203530:	e052                	sd	s4,0(sp)
ffffffffc0203532:	f406                	sd	ra,40(sp)
ffffffffc0203534:	f022                	sd	s0,32(sp)
ffffffffc0203536:	e44e                	sd	s3,8(sp)
ffffffffc0203538:	8a2a                	mv	s4,a0
ffffffffc020353a:	84ae                	mv	s1,a1
ffffffffc020353c:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020353e:	100027f3          	csrr	a5,sstatus
ffffffffc0203542:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203544:	000a7997          	auipc	s3,0xa7
ffffffffc0203548:	2ec98993          	addi	s3,s3,748 # ffffffffc02aa830 <pmm_manager>
ffffffffc020354c:	ef8d                	bnez	a5,ffffffffc0203586 <pgdir_alloc_page+0x5c>
ffffffffc020354e:	0009b783          	ld	a5,0(s3)
ffffffffc0203552:	4505                	li	a0,1
ffffffffc0203554:	6f9c                	ld	a5,24(a5)
ffffffffc0203556:	9782                	jalr	a5
ffffffffc0203558:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc020355a:	cc09                	beqz	s0,ffffffffc0203574 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc020355c:	86ca                	mv	a3,s2
ffffffffc020355e:	8626                	mv	a2,s1
ffffffffc0203560:	85a2                	mv	a1,s0
ffffffffc0203562:	8552                	mv	a0,s4
ffffffffc0203564:	ee7fe0ef          	jal	ra,ffffffffc020244a <page_insert>
ffffffffc0203568:	e915                	bnez	a0,ffffffffc020359c <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc020356a:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc020356c:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc020356e:	4785                	li	a5,1
ffffffffc0203570:	04f71e63          	bne	a4,a5,ffffffffc02035cc <pgdir_alloc_page+0xa2>
}
ffffffffc0203574:	70a2                	ld	ra,40(sp)
ffffffffc0203576:	8522                	mv	a0,s0
ffffffffc0203578:	7402                	ld	s0,32(sp)
ffffffffc020357a:	64e2                	ld	s1,24(sp)
ffffffffc020357c:	6942                	ld	s2,16(sp)
ffffffffc020357e:	69a2                	ld	s3,8(sp)
ffffffffc0203580:	6a02                	ld	s4,0(sp)
ffffffffc0203582:	6145                	addi	sp,sp,48
ffffffffc0203584:	8082                	ret
        intr_disable();
ffffffffc0203586:	beefd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020358a:	0009b783          	ld	a5,0(s3)
ffffffffc020358e:	4505                	li	a0,1
ffffffffc0203590:	6f9c                	ld	a5,24(a5)
ffffffffc0203592:	9782                	jalr	a5
ffffffffc0203594:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203596:	bd8fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc020359a:	b7c1                	j	ffffffffc020355a <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020359c:	100027f3          	csrr	a5,sstatus
ffffffffc02035a0:	8b89                	andi	a5,a5,2
ffffffffc02035a2:	eb89                	bnez	a5,ffffffffc02035b4 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02035a4:	0009b783          	ld	a5,0(s3)
ffffffffc02035a8:	8522                	mv	a0,s0
ffffffffc02035aa:	4585                	li	a1,1
ffffffffc02035ac:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035ae:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035b0:	9782                	jalr	a5
    if (flag)
ffffffffc02035b2:	b7c9                	j	ffffffffc0203574 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02035b4:	bc0fd0ef          	jal	ra,ffffffffc0200974 <intr_disable>
ffffffffc02035b8:	0009b783          	ld	a5,0(s3)
ffffffffc02035bc:	8522                	mv	a0,s0
ffffffffc02035be:	4585                	li	a1,1
ffffffffc02035c0:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02035c2:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02035c4:	9782                	jalr	a5
        intr_enable();
ffffffffc02035c6:	ba8fd0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02035ca:	b76d                	j	ffffffffc0203574 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02035cc:	00003697          	auipc	a3,0x3
ffffffffc02035d0:	56468693          	addi	a3,a3,1380 # ffffffffc0206b30 <default_pmm_manager+0x778>
ffffffffc02035d4:	00003617          	auipc	a2,0x3
ffffffffc02035d8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0206008 <commands+0x748>
ffffffffc02035dc:	20d00593          	li	a1,525
ffffffffc02035e0:	00003517          	auipc	a0,0x3
ffffffffc02035e4:	f2850513          	addi	a0,a0,-216 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02035e8:	e67fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02035ec <print_pgdir>:
    return 0;
}

// print_pgdir - 打印当前地址空间的有效映射区间与权限。
void print_pgdir(void)
{
ffffffffc02035ec:	711d                	addi	sp,sp,-96
    cprintf("-------------------- BEGIN --------------------\n");
ffffffffc02035ee:	00003517          	auipc	a0,0x3
ffffffffc02035f2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206b48 <default_pmm_manager+0x790>
{
ffffffffc02035f6:	f852                	sd	s4,48(sp)
ffffffffc02035f8:	ec86                	sd	ra,88(sp)
ffffffffc02035fa:	e8a2                	sd	s0,80(sp)
ffffffffc02035fc:	e4a6                	sd	s1,72(sp)
ffffffffc02035fe:	e0ca                	sd	s2,64(sp)
ffffffffc0203600:	fc4e                	sd	s3,56(sp)
ffffffffc0203602:	f456                	sd	s5,40(sp)
ffffffffc0203604:	f05a                	sd	s6,32(sp)
ffffffffc0203606:	ec5e                	sd	s7,24(sp)
ffffffffc0203608:	e862                	sd	s8,16(sp)
ffffffffc020360a:	e466                	sd	s9,8(sp)
ffffffffc020360c:	e06a                	sd	s10,0(sp)
    cprintf("-------------------- BEGIN --------------------\n");
ffffffffc020360e:	b87fc0ef          	jal	ra,ffffffffc0200194 <cprintf>

    pde_t *pgdir = boot_pgdir_va;
    if (current != NULL && current->mm != NULL)
ffffffffc0203612:	000a7797          	auipc	a5,0xa7
ffffffffc0203616:	2367b783          	ld	a5,566(a5) # ffffffffc02aa848 <current>
    pde_t *pgdir = boot_pgdir_va;
ffffffffc020361a:	000a7a17          	auipc	s4,0xa7
ffffffffc020361e:	1fea3a03          	ld	s4,510(s4) # ffffffffc02aa818 <boot_pgdir_va>
    if (current != NULL && current->mm != NULL)
ffffffffc0203622:	c789                	beqz	a5,ffffffffc020362c <print_pgdir+0x40>
ffffffffc0203624:	779c                	ld	a5,40(a5)
ffffffffc0203626:	c399                	beqz	a5,ffffffffc020362c <print_pgdir+0x40>
    {
        pgdir = current->mm->pgdir;
ffffffffc0203628:	0187ba03          	ld	s4,24(a5)
    }

    size_t left, right;
    for (size_t i = 0; i < NPDEENTRY; i++)
ffffffffc020362c:	20100b13          	li	s6,513
{
ffffffffc0203630:	400009b7          	lui	s3,0x40000
    {
        if (!(pgdir[i] & PTE_V))
        {
            continue;
        }
        uintptr_t base = (uintptr_t)i << PDX1SHIFT;
ffffffffc0203634:	c0000bb7          	lui	s7,0xc0000
    for (size_t i = 0; i < NPDEENTRY; i++)
ffffffffc0203638:	0b7a                	slli	s6,s6,0x1e
{
ffffffffc020363a:	19fd                	addi	s3,s3,-1
        uintptr_t base = (uintptr_t)i << PDX1SHIFT;
ffffffffc020363c:	0b85                	addi	s7,s7,1
        while (start < right && (table[start] & PTE_USER) == perm)
ffffffffc020363e:	20000913          	li	s2,512
    for (size_t i = 0; i < NPDEENTRY; i++)
ffffffffc0203642:	1b7d                	addi	s6,s6,-1
ffffffffc0203644:	a08d                	j	ffffffffc02036a6 <print_pgdir+0xba>
    str[0] = (perm & PTE_U) ? 'u' : '-';
ffffffffc0203646:	0107f713          	andi	a4,a5,16
ffffffffc020364a:	07500693          	li	a3,117
        if (!PTE_TABLE(pgdir[i]))
        {
            // 一级页表项直接作为 1GB 大页使用。
            cprintf("  PDE %p-%p %s\n", base, base + PDSIZE - 1,
                    perm2str(pgdir[i] & PTE_USER));
ffffffffc020364e:	2781                	sext.w	a5,a5
    str[0] = (perm & PTE_U) ? 'u' : '-';
ffffffffc0203650:	e319                	bnez	a4,ffffffffc0203656 <print_pgdir+0x6a>
ffffffffc0203652:	02d00693          	li	a3,45
ffffffffc0203656:	000a7717          	auipc	a4,0xa7
ffffffffc020365a:	1e270713          	addi	a4,a4,482 # ffffffffc02aa838 <str.0>
ffffffffc020365e:	00d70023          	sb	a3,0(a4)
    str[1] = 'r';
ffffffffc0203662:	07200693          	li	a3,114
ffffffffc0203666:	00d700a3          	sb	a3,1(a4)
    str[2] = (perm & PTE_W) ? 'w' : '-';
ffffffffc020366a:	8b91                	andi	a5,a5,4
ffffffffc020366c:	07700813          	li	a6,119
ffffffffc0203670:	e399                	bnez	a5,ffffffffc0203676 <print_pgdir+0x8a>
ffffffffc0203672:	02d00813          	li	a6,45
            cprintf("  PDE %p-%p %s\n", base, base + PDSIZE - 1,
ffffffffc0203676:	000a7697          	auipc	a3,0xa7
ffffffffc020367a:	1c268693          	addi	a3,a3,450 # ffffffffc02aa838 <str.0>
ffffffffc020367e:	864e                	mv	a2,s3
ffffffffc0203680:	85e6                	mv	a1,s9
ffffffffc0203682:	00003517          	auipc	a0,0x3
ffffffffc0203686:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206b80 <default_pmm_manager+0x7c8>
    str[2] = (perm & PTE_W) ? 'w' : '-';
ffffffffc020368a:	01070123          	sb	a6,2(a4)
    str[3] = '\0';
ffffffffc020368e:	000a7797          	auipc	a5,0xa7
ffffffffc0203692:	1a0786a3          	sb	zero,429(a5) # ffffffffc02aa83b <str.0+0x3>
            cprintf("  PDE %p-%p %s\n", base, base + PDSIZE - 1,
ffffffffc0203696:	afffc0ef          	jal	ra,ffffffffc0200194 <cprintf>
    for (size_t i = 0; i < NPDEENTRY; i++)
ffffffffc020369a:	400007b7          	lui	a5,0x40000
ffffffffc020369e:	99be                	add	s3,s3,a5
ffffffffc02036a0:	0a21                	addi	s4,s4,8
ffffffffc02036a2:	0f698463          	beq	s3,s6,ffffffffc020378a <print_pgdir+0x19e>
        if (!(pgdir[i] & PTE_V))
ffffffffc02036a6:	000a3783          	ld	a5,0(s4)
ffffffffc02036aa:	0017f713          	andi	a4,a5,1
ffffffffc02036ae:	d775                	beqz	a4,ffffffffc020369a <print_pgdir+0xae>
        if (!PTE_TABLE(pgdir[i]))
ffffffffc02036b0:	00f7f713          	andi	a4,a5,15
ffffffffc02036b4:	4685                	li	a3,1
        uintptr_t base = (uintptr_t)i << PDX1SHIFT;
ffffffffc02036b6:	01798cb3          	add	s9,s3,s7
        if (!PTE_TABLE(pgdir[i]))
ffffffffc02036ba:	f8d716e3          	bne	a4,a3,ffffffffc0203646 <print_pgdir+0x5a>
            continue;
        }
        pte_t *pt = (pte_t *)KADDR(PDE_ADDR(pgdir[i]));
ffffffffc02036be:	078a                	slli	a5,a5,0x2
ffffffffc02036c0:	76fd                	lui	a3,0xfffff
ffffffffc02036c2:	8efd                	and	a3,a3,a5
ffffffffc02036c4:	00c6d793          	srli	a5,a3,0xc
ffffffffc02036c8:	000a7717          	auipc	a4,0xa7
ffffffffc02036cc:	15873703          	ld	a4,344(a4) # ffffffffc02aa820 <npage>
ffffffffc02036d0:	0ee7f063          	bgeu	a5,a4,ffffffffc02037b0 <print_pgdir+0x1c4>
ffffffffc02036d4:	000a7497          	auipc	s1,0xa7
ffffffffc02036d8:	16c4b483          	ld	s1,364(s1) # ffffffffc02aa840 <va_pa_offset>
ffffffffc02036dc:	94b6                	add	s1,s1,a3
        size_t j = 0;
ffffffffc02036de:	4401                	li	s0,0
    while (start < right && !(table[start] & PTE_V))
ffffffffc02036e0:	1ff00c13          	li	s8,511
    str[0] = (perm & PTE_U) ? 'u' : '-';
ffffffffc02036e4:	000a7d17          	auipc	s10,0xa7
ffffffffc02036e8:	154d0d13          	addi	s10,s10,340 # ffffffffc02aa838 <str.0>
    str[1] = 'r';
ffffffffc02036ec:	07200a93          	li	s5,114
    while (start < right && !(table[start] & PTE_V))
ffffffffc02036f0:	00341793          	slli	a5,s0,0x3
ffffffffc02036f4:	97a6                	add	a5,a5,s1
ffffffffc02036f6:	a021                	j	ffffffffc02036fe <print_pgdir+0x112>
ffffffffc02036f8:	07a1                	addi	a5,a5,8
ffffffffc02036fa:	fa8c60e3          	bltu	s8,s0,ffffffffc020369a <print_pgdir+0xae>
ffffffffc02036fe:	6398                	ld	a4,0(a5)
ffffffffc0203700:	85a2                	mv	a1,s0
        start++;
ffffffffc0203702:	0405                	addi	s0,s0,1
    while (start < right && !(table[start] & PTE_V))
ffffffffc0203704:	00177613          	andi	a2,a4,1
ffffffffc0203708:	da65                	beqz	a2,ffffffffc02036f8 <print_pgdir+0x10c>
        int perm = (table[start++] & PTE_USER);
ffffffffc020370a:	0007051b          	sext.w	a0,a4
ffffffffc020370e:	8b7d                	andi	a4,a4,31
        while (start < right && (table[start] & PTE_USER) == perm)
ffffffffc0203710:	008c6e63          	bltu	s8,s0,ffffffffc020372c <print_pgdir+0x140>
ffffffffc0203714:	00341693          	slli	a3,s0,0x3
ffffffffc0203718:	96a6                	add	a3,a3,s1
ffffffffc020371a:	a029                	j	ffffffffc0203724 <print_pgdir+0x138>
            start++;
ffffffffc020371c:	0405                	addi	s0,s0,1
        while (start < right && (table[start] & PTE_USER) == perm)
ffffffffc020371e:	06a1                	addi	a3,a3,8
ffffffffc0203720:	01240663          	beq	s0,s2,ffffffffc020372c <print_pgdir+0x140>
ffffffffc0203724:	629c                	ld	a5,0(a3)
ffffffffc0203726:	8bfd                	andi	a5,a5,31
ffffffffc0203728:	fee78ae3          	beq	a5,a4,ffffffffc020371c <print_pgdir+0x130>
        while (j < NPTEENTRY)
        {
            int perm = get_pgtable_items(0, NPTEENTRY, j, pt, &left, &right);
            if (perm == 0)
ffffffffc020372c:	d73d                	beqz	a4,ffffffffc020369a <print_pgdir+0xae>
            {
                break;
            }
            uintptr_t start = base | (left << PTXSHIFT);
            uintptr_t end = base | (right << PTXSHIFT);
ffffffffc020372e:	00c41613          	slli	a2,s0,0xc
            uintptr_t start = base | (left << PTXSHIFT);
ffffffffc0203732:	05b2                	slli	a1,a1,0xc
            uintptr_t end = base | (right << PTXSHIFT);
ffffffffc0203734:	01966633          	or	a2,a2,s9
    str[0] = (perm & PTE_U) ? 'u' : '-';
ffffffffc0203738:	01057793          	andi	a5,a0,16
            uintptr_t start = base | (left << PTXSHIFT);
ffffffffc020373c:	0195e5b3          	or	a1,a1,s9
            cprintf("  PTE %p-%p %s\n", start, end - 1, perm2str(perm));
ffffffffc0203740:	167d                	addi	a2,a2,-1
    str[0] = (perm & PTE_U) ? 'u' : '-';
ffffffffc0203742:	07500713          	li	a4,117
ffffffffc0203746:	e399                	bnez	a5,ffffffffc020374c <print_pgdir+0x160>
ffffffffc0203748:	02d00713          	li	a4,45
ffffffffc020374c:	00ed0023          	sb	a4,0(s10)
    str[1] = 'r';
ffffffffc0203750:	015d00a3          	sb	s5,1(s10)
    str[2] = (perm & PTE_W) ? 'w' : '-';
ffffffffc0203754:	8911                	andi	a0,a0,4
ffffffffc0203756:	07700793          	li	a5,119
ffffffffc020375a:	e119                	bnez	a0,ffffffffc0203760 <print_pgdir+0x174>
ffffffffc020375c:	02d00793          	li	a5,45
            cprintf("  PTE %p-%p %s\n", start, end - 1, perm2str(perm));
ffffffffc0203760:	86ea                	mv	a3,s10
ffffffffc0203762:	00003517          	auipc	a0,0x3
ffffffffc0203766:	42e50513          	addi	a0,a0,1070 # ffffffffc0206b90 <default_pmm_manager+0x7d8>
    str[2] = (perm & PTE_W) ? 'w' : '-';
ffffffffc020376a:	00fd0123          	sb	a5,2(s10)
    str[3] = '\0';
ffffffffc020376e:	000a7797          	auipc	a5,0xa7
ffffffffc0203772:	0c0786a3          	sb	zero,205(a5) # ffffffffc02aa83b <str.0+0x3>
            cprintf("  PTE %p-%p %s\n", start, end - 1, perm2str(perm));
ffffffffc0203776:	a1ffc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        while (j < NPTEENTRY)
ffffffffc020377a:	f68c7be3          	bgeu	s8,s0,ffffffffc02036f0 <print_pgdir+0x104>
    for (size_t i = 0; i < NPDEENTRY; i++)
ffffffffc020377e:	400007b7          	lui	a5,0x40000
ffffffffc0203782:	99be                	add	s3,s3,a5
ffffffffc0203784:	0a21                	addi	s4,s4,8
ffffffffc0203786:	f36990e3          	bne	s3,s6,ffffffffc02036a6 <print_pgdir+0xba>
            j = right;
        }
    }
    cprintf("-------------------- END --------------------\n");
}
ffffffffc020378a:	6446                	ld	s0,80(sp)
ffffffffc020378c:	60e6                	ld	ra,88(sp)
ffffffffc020378e:	64a6                	ld	s1,72(sp)
ffffffffc0203790:	6906                	ld	s2,64(sp)
ffffffffc0203792:	79e2                	ld	s3,56(sp)
ffffffffc0203794:	7a42                	ld	s4,48(sp)
ffffffffc0203796:	7aa2                	ld	s5,40(sp)
ffffffffc0203798:	7b02                	ld	s6,32(sp)
ffffffffc020379a:	6be2                	ld	s7,24(sp)
ffffffffc020379c:	6c42                	ld	s8,16(sp)
ffffffffc020379e:	6ca2                	ld	s9,8(sp)
ffffffffc02037a0:	6d02                	ld	s10,0(sp)
    cprintf("-------------------- END --------------------\n");
ffffffffc02037a2:	00003517          	auipc	a0,0x3
ffffffffc02037a6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206ba0 <default_pmm_manager+0x7e8>
}
ffffffffc02037aa:	6125                	addi	sp,sp,96
    cprintf("-------------------- END --------------------\n");
ffffffffc02037ac:	9e9fc06f          	j	ffffffffc0200194 <cprintf>
        pte_t *pt = (pte_t *)KADDR(PDE_ADDR(pgdir[i]));
ffffffffc02037b0:	00003617          	auipc	a2,0x3
ffffffffc02037b4:	c4060613          	addi	a2,a2,-960 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc02037b8:	2d700593          	li	a1,727
ffffffffc02037bc:	00003517          	auipc	a0,0x3
ffffffffc02037c0:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206508 <default_pmm_manager+0x150>
ffffffffc02037c4:	c8bfc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02037c8 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037c8:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02037ca:	00003697          	auipc	a3,0x3
ffffffffc02037ce:	40668693          	addi	a3,a3,1030 # ffffffffc0206bd0 <default_pmm_manager+0x818>
ffffffffc02037d2:	00003617          	auipc	a2,0x3
ffffffffc02037d6:	83660613          	addi	a2,a2,-1994 # ffffffffc0206008 <commands+0x748>
ffffffffc02037da:	07400593          	li	a1,116
ffffffffc02037de:	00003517          	auipc	a0,0x3
ffffffffc02037e2:	41250513          	addi	a0,a0,1042 # ffffffffc0206bf0 <default_pmm_manager+0x838>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037e6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037e8:	c67fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02037ec <mm_create>:
{
ffffffffc02037ec:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037ee:	04000513          	li	a0,64
{
ffffffffc02037f2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037f4:	b6cfe0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
    if (mm != NULL)
ffffffffc02037f8:	cd19                	beqz	a0,ffffffffc0203816 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02037fa:	e508                	sd	a0,8(a0)
ffffffffc02037fc:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037fe:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203802:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203806:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020380a:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020380e:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0203812:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203816:	60a2                	ld	ra,8(sp)
ffffffffc0203818:	0141                	addi	sp,sp,16
ffffffffc020381a:	8082                	ret

ffffffffc020381c <find_vma>:
{
ffffffffc020381c:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020381e:	c505                	beqz	a0,ffffffffc0203846 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203820:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203822:	c501                	beqz	a0,ffffffffc020382a <find_vma+0xe>
ffffffffc0203824:	651c                	ld	a5,8(a0)
ffffffffc0203826:	02f5f263          	bgeu	a1,a5,ffffffffc020384a <find_vma+0x2e>
    return listelm->next;
ffffffffc020382a:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020382c:	00f68d63          	beq	a3,a5,ffffffffc0203846 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203830:	fe87b703          	ld	a4,-24(a5) # 3fffffe8 <_binary_obj___user_exit_out_size+0x3fff4eb8>
ffffffffc0203834:	00e5e663          	bltu	a1,a4,ffffffffc0203840 <find_vma+0x24>
ffffffffc0203838:	ff07b703          	ld	a4,-16(a5)
ffffffffc020383c:	00e5ec63          	bltu	a1,a4,ffffffffc0203854 <find_vma+0x38>
ffffffffc0203840:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203842:	fef697e3          	bne	a3,a5,ffffffffc0203830 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0203846:	4501                	li	a0,0
}
ffffffffc0203848:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020384a:	691c                	ld	a5,16(a0)
ffffffffc020384c:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020382a <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203850:	ea88                	sd	a0,16(a3)
ffffffffc0203852:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203854:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203858:	ea88                	sd	a0,16(a3)
ffffffffc020385a:	8082                	ret

ffffffffc020385c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020385c:	6590                	ld	a2,8(a1)
ffffffffc020385e:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203862:	1141                	addi	sp,sp,-16
ffffffffc0203864:	e406                	sd	ra,8(sp)
ffffffffc0203866:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203868:	01066763          	bltu	a2,a6,ffffffffc0203876 <insert_vma_struct+0x1a>
ffffffffc020386c:	a085                	j	ffffffffc02038cc <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020386e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203872:	04e66863          	bltu	a2,a4,ffffffffc02038c2 <insert_vma_struct+0x66>
ffffffffc0203876:	86be                	mv	a3,a5
ffffffffc0203878:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020387a:	fef51ae3          	bne	a0,a5,ffffffffc020386e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020387e:	02a68463          	beq	a3,a0,ffffffffc02038a6 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203882:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203886:	fe86b883          	ld	a7,-24(a3)
ffffffffc020388a:	08e8f163          	bgeu	a7,a4,ffffffffc020390c <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020388e:	04e66f63          	bltu	a2,a4,ffffffffc02038ec <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203892:	00f50a63          	beq	a0,a5,ffffffffc02038a6 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203896:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020389a:	05076963          	bltu	a4,a6,ffffffffc02038ec <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020389e:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038a2:	02c77363          	bgeu	a4,a2,ffffffffc02038c8 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02038a6:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02038a8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02038aa:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02038ae:	e390                	sd	a2,0(a5)
ffffffffc02038b0:	e690                	sd	a2,8(a3)
}
ffffffffc02038b2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02038b4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038b6:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02038b8:	0017079b          	addiw	a5,a4,1
ffffffffc02038bc:	d11c                	sw	a5,32(a0)
}
ffffffffc02038be:	0141                	addi	sp,sp,16
ffffffffc02038c0:	8082                	ret
    if (le_prev != list)
ffffffffc02038c2:	fca690e3          	bne	a3,a0,ffffffffc0203882 <insert_vma_struct+0x26>
ffffffffc02038c6:	bfd1                	j	ffffffffc020389a <insert_vma_struct+0x3e>
ffffffffc02038c8:	f01ff0ef          	jal	ra,ffffffffc02037c8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038cc:	00003697          	auipc	a3,0x3
ffffffffc02038d0:	33468693          	addi	a3,a3,820 # ffffffffc0206c00 <default_pmm_manager+0x848>
ffffffffc02038d4:	00002617          	auipc	a2,0x2
ffffffffc02038d8:	73460613          	addi	a2,a2,1844 # ffffffffc0206008 <commands+0x748>
ffffffffc02038dc:	07a00593          	li	a1,122
ffffffffc02038e0:	00003517          	auipc	a0,0x3
ffffffffc02038e4:	31050513          	addi	a0,a0,784 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc02038e8:	b67fc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038ec:	00003697          	auipc	a3,0x3
ffffffffc02038f0:	35468693          	addi	a3,a3,852 # ffffffffc0206c40 <default_pmm_manager+0x888>
ffffffffc02038f4:	00002617          	auipc	a2,0x2
ffffffffc02038f8:	71460613          	addi	a2,a2,1812 # ffffffffc0206008 <commands+0x748>
ffffffffc02038fc:	07300593          	li	a1,115
ffffffffc0203900:	00003517          	auipc	a0,0x3
ffffffffc0203904:	2f050513          	addi	a0,a0,752 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203908:	b47fc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020390c:	00003697          	auipc	a3,0x3
ffffffffc0203910:	31468693          	addi	a3,a3,788 # ffffffffc0206c20 <default_pmm_manager+0x868>
ffffffffc0203914:	00002617          	auipc	a2,0x2
ffffffffc0203918:	6f460613          	addi	a2,a2,1780 # ffffffffc0206008 <commands+0x748>
ffffffffc020391c:	07200593          	li	a1,114
ffffffffc0203920:	00003517          	auipc	a0,0x3
ffffffffc0203924:	2d050513          	addi	a0,a0,720 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203928:	b27fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020392c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020392c:	591c                	lw	a5,48(a0)
{
ffffffffc020392e:	1141                	addi	sp,sp,-16
ffffffffc0203930:	e406                	sd	ra,8(sp)
ffffffffc0203932:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203934:	e78d                	bnez	a5,ffffffffc020395e <mm_destroy+0x32>
ffffffffc0203936:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203938:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020393a:	00a40c63          	beq	s0,a0,ffffffffc0203952 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020393e:	6118                	ld	a4,0(a0)
ffffffffc0203940:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0203942:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203944:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203946:	e398                	sd	a4,0(a5)
ffffffffc0203948:	ac8fe0ef          	jal	ra,ffffffffc0201c10 <kfree>
    return listelm->next;
ffffffffc020394c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020394e:	fea418e3          	bne	s0,a0,ffffffffc020393e <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203952:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203954:	6402                	ld	s0,0(sp)
ffffffffc0203956:	60a2                	ld	ra,8(sp)
ffffffffc0203958:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020395a:	ab6fe06f          	j	ffffffffc0201c10 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020395e:	00003697          	auipc	a3,0x3
ffffffffc0203962:	30268693          	addi	a3,a3,770 # ffffffffc0206c60 <default_pmm_manager+0x8a8>
ffffffffc0203966:	00002617          	auipc	a2,0x2
ffffffffc020396a:	6a260613          	addi	a2,a2,1698 # ffffffffc0206008 <commands+0x748>
ffffffffc020396e:	09e00593          	li	a1,158
ffffffffc0203972:	00003517          	auipc	a0,0x3
ffffffffc0203976:	27e50513          	addi	a0,a0,638 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc020397a:	ad5fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020397e <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020397e:	7139                	addi	sp,sp,-64
ffffffffc0203980:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203982:	6405                	lui	s0,0x1
ffffffffc0203984:	147d                	addi	s0,s0,-1
ffffffffc0203986:	77fd                	lui	a5,0xfffff
ffffffffc0203988:	9622                	add	a2,a2,s0
ffffffffc020398a:	962e                	add	a2,a2,a1
{
ffffffffc020398c:	f426                	sd	s1,40(sp)
ffffffffc020398e:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203990:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0203994:	f04a                	sd	s2,32(sp)
ffffffffc0203996:	ec4e                	sd	s3,24(sp)
ffffffffc0203998:	e852                	sd	s4,16(sp)
ffffffffc020399a:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020399c:	002005b7          	lui	a1,0x200
ffffffffc02039a0:	00f67433          	and	s0,a2,a5
ffffffffc02039a4:	06b4e363          	bltu	s1,a1,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039a8:	0684f163          	bgeu	s1,s0,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039ac:	4785                	li	a5,1
ffffffffc02039ae:	07fe                	slli	a5,a5,0x1f
ffffffffc02039b0:	0487ed63          	bltu	a5,s0,ffffffffc0203a0a <mm_map+0x8c>
ffffffffc02039b4:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02039b6:	cd21                	beqz	a0,ffffffffc0203a0e <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02039b8:	85a6                	mv	a1,s1
ffffffffc02039ba:	8ab6                	mv	s5,a3
ffffffffc02039bc:	8a3a                	mv	s4,a4
ffffffffc02039be:	e5fff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc02039c2:	c501                	beqz	a0,ffffffffc02039ca <mm_map+0x4c>
ffffffffc02039c4:	651c                	ld	a5,8(a0)
ffffffffc02039c6:	0487e263          	bltu	a5,s0,ffffffffc0203a0a <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ca:	03000513          	li	a0,48
ffffffffc02039ce:	992fe0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
ffffffffc02039d2:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02039d4:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02039d6:	02090163          	beqz	s2,ffffffffc02039f8 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02039da:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02039dc:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02039e0:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02039e4:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02039e8:	85ca                	mv	a1,s2
ffffffffc02039ea:	e73ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02039ee:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02039f0:	000a0463          	beqz	s4,ffffffffc02039f8 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02039f4:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02039f8:	70e2                	ld	ra,56(sp)
ffffffffc02039fa:	7442                	ld	s0,48(sp)
ffffffffc02039fc:	74a2                	ld	s1,40(sp)
ffffffffc02039fe:	7902                	ld	s2,32(sp)
ffffffffc0203a00:	69e2                	ld	s3,24(sp)
ffffffffc0203a02:	6a42                	ld	s4,16(sp)
ffffffffc0203a04:	6aa2                	ld	s5,8(sp)
ffffffffc0203a06:	6121                	addi	sp,sp,64
ffffffffc0203a08:	8082                	ret
        return -E_INVAL;
ffffffffc0203a0a:	5575                	li	a0,-3
ffffffffc0203a0c:	b7f5                	j	ffffffffc02039f8 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0203a0e:	00003697          	auipc	a3,0x3
ffffffffc0203a12:	26a68693          	addi	a3,a3,618 # ffffffffc0206c78 <default_pmm_manager+0x8c0>
ffffffffc0203a16:	00002617          	auipc	a2,0x2
ffffffffc0203a1a:	5f260613          	addi	a2,a2,1522 # ffffffffc0206008 <commands+0x748>
ffffffffc0203a1e:	0b300593          	li	a1,179
ffffffffc0203a22:	00003517          	auipc	a0,0x3
ffffffffc0203a26:	1ce50513          	addi	a0,a0,462 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203a2a:	a25fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203a2e <dup_mmap>:

//lab5 function3 YOUR CODE
// dup_mmap - 按 vma 粒度把 from 的地址空间复制到 to，并逐页复制页表映射。
int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203a2e:	7139                	addi	sp,sp,-64
ffffffffc0203a30:	fc06                	sd	ra,56(sp)
ffffffffc0203a32:	f822                	sd	s0,48(sp)
ffffffffc0203a34:	f426                	sd	s1,40(sp)
ffffffffc0203a36:	f04a                	sd	s2,32(sp)
ffffffffc0203a38:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3a:	e852                	sd	s4,16(sp)
ffffffffc0203a3c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203a3e:	c52d                	beqz	a0,ffffffffc0203aa8 <dup_mmap+0x7a>
ffffffffc0203a40:	892a                	mv	s2,a0
ffffffffc0203a42:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203a44:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203a46:	e595                	bnez	a1,ffffffffc0203a72 <dup_mmap+0x44>
ffffffffc0203a48:	a085                	j	ffffffffc0203aa8 <dup_mmap+0x7a>
        struct vma_struct *nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }
        insert_vma_struct(to, nvma);
ffffffffc0203a4a:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0203a4c:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed8>
        vma->vm_end = vm_end;
ffffffffc0203a50:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203a54:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0203a58:	e05ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203a5c:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd0>
ffffffffc0203a60:	fe843603          	ld	a2,-24(s0)
ffffffffc0203a64:	6c8c                	ld	a1,24(s1)
ffffffffc0203a66:	01893503          	ld	a0,24(s2)
ffffffffc0203a6a:	4701                	li	a4,0
ffffffffc0203a6c:	b17fe0ef          	jal	ra,ffffffffc0202582 <copy_range>
ffffffffc0203a70:	e105                	bnez	a0,ffffffffc0203a90 <dup_mmap+0x62>
ffffffffc0203a72:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203a74:	02848863          	beq	s1,s0,ffffffffc0203aa4 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a78:	03000513          	li	a0,48
        struct vma_struct *nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203a7c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203a80:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203a84:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a88:	8d8fe0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
ffffffffc0203a8c:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0203a8e:	fd55                	bnez	a0,ffffffffc0203a4a <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0203a90:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203a92:	70e2                	ld	ra,56(sp)
ffffffffc0203a94:	7442                	ld	s0,48(sp)
ffffffffc0203a96:	74a2                	ld	s1,40(sp)
ffffffffc0203a98:	7902                	ld	s2,32(sp)
ffffffffc0203a9a:	69e2                	ld	s3,24(sp)
ffffffffc0203a9c:	6a42                	ld	s4,16(sp)
ffffffffc0203a9e:	6aa2                	ld	s5,8(sp)
ffffffffc0203aa0:	6121                	addi	sp,sp,64
ffffffffc0203aa2:	8082                	ret
    return 0;
ffffffffc0203aa4:	4501                	li	a0,0
ffffffffc0203aa6:	b7f5                	j	ffffffffc0203a92 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0203aa8:	00003697          	auipc	a3,0x3
ffffffffc0203aac:	1e068693          	addi	a3,a3,480 # ffffffffc0206c88 <default_pmm_manager+0x8d0>
ffffffffc0203ab0:	00002617          	auipc	a2,0x2
ffffffffc0203ab4:	55860613          	addi	a2,a2,1368 # ffffffffc0206008 <commands+0x748>
ffffffffc0203ab8:	0d100593          	li	a1,209
ffffffffc0203abc:	00003517          	auipc	a0,0x3
ffffffffc0203ac0:	13450513          	addi	a0,a0,308 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203ac4:	98bfc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203ac8 <exit_mmap>:


void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203ac8:	1101                	addi	sp,sp,-32
ffffffffc0203aca:	ec06                	sd	ra,24(sp)
ffffffffc0203acc:	e822                	sd	s0,16(sp)
ffffffffc0203ace:	e426                	sd	s1,8(sp)
ffffffffc0203ad0:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203ad2:	c531                	beqz	a0,ffffffffc0203b1e <exit_mmap+0x56>
ffffffffc0203ad4:	591c                	lw	a5,48(a0)
ffffffffc0203ad6:	84aa                	mv	s1,a0
ffffffffc0203ad8:	e3b9                	bnez	a5,ffffffffc0203b1e <exit_mmap+0x56>
ffffffffc0203ada:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203adc:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203ae0:	02850663          	beq	a0,s0,ffffffffc0203b0c <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203ae4:	ff043603          	ld	a2,-16(s0)
ffffffffc0203ae8:	fe843583          	ld	a1,-24(s0)
ffffffffc0203aec:	854a                	mv	a0,s2
ffffffffc0203aee:	d84fe0ef          	jal	ra,ffffffffc0202072 <unmap_range>
ffffffffc0203af2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203af4:	fe8498e3          	bne	s1,s0,ffffffffc0203ae4 <exit_mmap+0x1c>
ffffffffc0203af8:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203afa:	00848c63          	beq	s1,s0,ffffffffc0203b12 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203afe:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b02:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b06:	854a                	mv	a0,s2
ffffffffc0203b08:	eb0fe0ef          	jal	ra,ffffffffc02021b8 <exit_range>
ffffffffc0203b0c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b0e:	fe8498e3          	bne	s1,s0,ffffffffc0203afe <exit_mmap+0x36>
    }
}
ffffffffc0203b12:	60e2                	ld	ra,24(sp)
ffffffffc0203b14:	6442                	ld	s0,16(sp)
ffffffffc0203b16:	64a2                	ld	s1,8(sp)
ffffffffc0203b18:	6902                	ld	s2,0(sp)
ffffffffc0203b1a:	6105                	addi	sp,sp,32
ffffffffc0203b1c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b1e:	00003697          	auipc	a3,0x3
ffffffffc0203b22:	18a68693          	addi	a3,a3,394 # ffffffffc0206ca8 <default_pmm_manager+0x8f0>
ffffffffc0203b26:	00002617          	auipc	a2,0x2
ffffffffc0203b2a:	4e260613          	addi	a2,a2,1250 # ffffffffc0206008 <commands+0x748>
ffffffffc0203b2e:	0e900593          	li	a1,233
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	0be50513          	addi	a0,a0,190 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203b3a:	915fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203b3e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203b3e:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b40:	04000513          	li	a0,64
{
ffffffffc0203b44:	fc06                	sd	ra,56(sp)
ffffffffc0203b46:	f822                	sd	s0,48(sp)
ffffffffc0203b48:	f426                	sd	s1,40(sp)
ffffffffc0203b4a:	f04a                	sd	s2,32(sp)
ffffffffc0203b4c:	ec4e                	sd	s3,24(sp)
ffffffffc0203b4e:	e852                	sd	s4,16(sp)
ffffffffc0203b50:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b52:	80efe0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
    if (mm != NULL)
ffffffffc0203b56:	2e050663          	beqz	a0,ffffffffc0203e42 <vmm_init+0x304>
ffffffffc0203b5a:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0203b5c:	e508                	sd	a0,8(a0)
ffffffffc0203b5e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203b60:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203b64:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203b68:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203b6c:	02053423          	sd	zero,40(a0)
ffffffffc0203b70:	02052823          	sw	zero,48(a0)
ffffffffc0203b74:	02053c23          	sd	zero,56(a0)
ffffffffc0203b78:	03200413          	li	s0,50
ffffffffc0203b7c:	a811                	j	ffffffffc0203b90 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0203b7e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203b80:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b82:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203b86:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b88:	8526                	mv	a0,s1
ffffffffc0203b8a:	cd3ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203b8e:	c80d                	beqz	s0,ffffffffc0203bc0 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b90:	03000513          	li	a0,48
ffffffffc0203b94:	fcdfd0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
ffffffffc0203b98:	85aa                	mv	a1,a0
ffffffffc0203b9a:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203b9e:	f165                	bnez	a0,ffffffffc0203b7e <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0203ba0:	00003697          	auipc	a3,0x3
ffffffffc0203ba4:	2a068693          	addi	a3,a3,672 # ffffffffc0206e40 <default_pmm_manager+0xa88>
ffffffffc0203ba8:	00002617          	auipc	a2,0x2
ffffffffc0203bac:	46060613          	addi	a2,a2,1120 # ffffffffc0206008 <commands+0x748>
ffffffffc0203bb0:	12d00593          	li	a1,301
ffffffffc0203bb4:	00003517          	auipc	a0,0x3
ffffffffc0203bb8:	03c50513          	addi	a0,a0,60 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203bbc:	893fc0ef          	jal	ra,ffffffffc020044e <__panic>
ffffffffc0203bc0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bc4:	1f900913          	li	s2,505
ffffffffc0203bc8:	a819                	j	ffffffffc0203bde <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0203bca:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203bcc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bce:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bd2:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bd4:	8526                	mv	a0,s1
ffffffffc0203bd6:	c87ff0ef          	jal	ra,ffffffffc020385c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bda:	03240a63          	beq	s0,s2,ffffffffc0203c0e <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203bde:	03000513          	li	a0,48
ffffffffc0203be2:	f7ffd0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
ffffffffc0203be6:	85aa                	mv	a1,a0
ffffffffc0203be8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0203bec:	fd79                	bnez	a0,ffffffffc0203bca <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0203bee:	00003697          	auipc	a3,0x3
ffffffffc0203bf2:	25268693          	addi	a3,a3,594 # ffffffffc0206e40 <default_pmm_manager+0xa88>
ffffffffc0203bf6:	00002617          	auipc	a2,0x2
ffffffffc0203bfa:	41260613          	addi	a2,a2,1042 # ffffffffc0206008 <commands+0x748>
ffffffffc0203bfe:	13400593          	li	a1,308
ffffffffc0203c02:	00003517          	auipc	a0,0x3
ffffffffc0203c06:	fee50513          	addi	a0,a0,-18 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203c0a:	845fc0ef          	jal	ra,ffffffffc020044e <__panic>
    return listelm->next;
ffffffffc0203c0e:	649c                	ld	a5,8(s1)
ffffffffc0203c10:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203c12:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203c16:	16f48663          	beq	s1,a5,ffffffffc0203d82 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c1a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd54784>
ffffffffc0203c1e:	ffe70693          	addi	a3,a4,-2
ffffffffc0203c22:	10d61063          	bne	a2,a3,ffffffffc0203d22 <vmm_init+0x1e4>
ffffffffc0203c26:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203c2a:	0ed71c63          	bne	a4,a3,ffffffffc0203d22 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0203c2e:	0715                	addi	a4,a4,5
ffffffffc0203c30:	679c                	ld	a5,8(a5)
ffffffffc0203c32:	feb712e3          	bne	a4,a1,ffffffffc0203c16 <vmm_init+0xd8>
ffffffffc0203c36:	4a1d                	li	s4,7
ffffffffc0203c38:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203c3a:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203c3e:	85a2                	mv	a1,s0
ffffffffc0203c40:	8526                	mv	a0,s1
ffffffffc0203c42:	bdbff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203c46:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0203c48:	16050d63          	beqz	a0,ffffffffc0203dc2 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203c4c:	00140593          	addi	a1,s0,1
ffffffffc0203c50:	8526                	mv	a0,s1
ffffffffc0203c52:	bcbff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203c56:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203c58:	14050563          	beqz	a0,ffffffffc0203da2 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203c5c:	85d2                	mv	a1,s4
ffffffffc0203c5e:	8526                	mv	a0,s1
ffffffffc0203c60:	bbdff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma3 == NULL);
ffffffffc0203c64:	16051f63          	bnez	a0,ffffffffc0203de2 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203c68:	00340593          	addi	a1,s0,3
ffffffffc0203c6c:	8526                	mv	a0,s1
ffffffffc0203c6e:	bafff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma4 == NULL);
ffffffffc0203c72:	1a051863          	bnez	a0,ffffffffc0203e22 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203c76:	00440593          	addi	a1,s0,4
ffffffffc0203c7a:	8526                	mv	a0,s1
ffffffffc0203c7c:	ba1ff0ef          	jal	ra,ffffffffc020381c <find_vma>
        assert(vma5 == NULL);
ffffffffc0203c80:	18051163          	bnez	a0,ffffffffc0203e02 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c84:	00893783          	ld	a5,8(s2)
ffffffffc0203c88:	0a879d63          	bne	a5,s0,ffffffffc0203d42 <vmm_init+0x204>
ffffffffc0203c8c:	01093783          	ld	a5,16(s2)
ffffffffc0203c90:	0b479963          	bne	a5,s4,ffffffffc0203d42 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203c94:	0089b783          	ld	a5,8(s3) # 40000008 <_binary_obj___user_exit_out_size+0x3fff4ed8>
ffffffffc0203c98:	0c879563          	bne	a5,s0,ffffffffc0203d62 <vmm_init+0x224>
ffffffffc0203c9c:	0109b783          	ld	a5,16(s3)
ffffffffc0203ca0:	0d479163          	bne	a5,s4,ffffffffc0203d62 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203ca4:	0415                	addi	s0,s0,5
ffffffffc0203ca6:	0a15                	addi	s4,s4,5
ffffffffc0203ca8:	f9541be3          	bne	s0,s5,ffffffffc0203c3e <vmm_init+0x100>
ffffffffc0203cac:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203cae:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203cb0:	85a2                	mv	a1,s0
ffffffffc0203cb2:	8526                	mv	a0,s1
ffffffffc0203cb4:	b69ff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203cb8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203cbc:	c90d                	beqz	a0,ffffffffc0203cee <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203cbe:	6914                	ld	a3,16(a0)
ffffffffc0203cc0:	6510                	ld	a2,8(a0)
ffffffffc0203cc2:	00003517          	auipc	a0,0x3
ffffffffc0203cc6:	10650513          	addi	a0,a0,262 # ffffffffc0206dc8 <default_pmm_manager+0xa10>
ffffffffc0203cca:	ccafc0ef          	jal	ra,ffffffffc0200194 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203cce:	00003697          	auipc	a3,0x3
ffffffffc0203cd2:	12268693          	addi	a3,a3,290 # ffffffffc0206df0 <default_pmm_manager+0xa38>
ffffffffc0203cd6:	00002617          	auipc	a2,0x2
ffffffffc0203cda:	33260613          	addi	a2,a2,818 # ffffffffc0206008 <commands+0x748>
ffffffffc0203cde:	15a00593          	li	a1,346
ffffffffc0203ce2:	00003517          	auipc	a0,0x3
ffffffffc0203ce6:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203cea:	f64fc0ef          	jal	ra,ffffffffc020044e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203cee:	147d                	addi	s0,s0,-1
ffffffffc0203cf0:	fd2410e3          	bne	s0,s2,ffffffffc0203cb0 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203cf4:	8526                	mv	a0,s1
ffffffffc0203cf6:	c37ff0ef          	jal	ra,ffffffffc020392c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203cfa:	00003517          	auipc	a0,0x3
ffffffffc0203cfe:	10e50513          	addi	a0,a0,270 # ffffffffc0206e08 <default_pmm_manager+0xa50>
ffffffffc0203d02:	c92fc0ef          	jal	ra,ffffffffc0200194 <cprintf>
}
ffffffffc0203d06:	7442                	ld	s0,48(sp)
ffffffffc0203d08:	70e2                	ld	ra,56(sp)
ffffffffc0203d0a:	74a2                	ld	s1,40(sp)
ffffffffc0203d0c:	7902                	ld	s2,32(sp)
ffffffffc0203d0e:	69e2                	ld	s3,24(sp)
ffffffffc0203d10:	6a42                	ld	s4,16(sp)
ffffffffc0203d12:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d14:	00003517          	auipc	a0,0x3
ffffffffc0203d18:	11450513          	addi	a0,a0,276 # ffffffffc0206e28 <default_pmm_manager+0xa70>
}
ffffffffc0203d1c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d1e:	c76fc06f          	j	ffffffffc0200194 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d22:	00003697          	auipc	a3,0x3
ffffffffc0203d26:	fbe68693          	addi	a3,a3,-66 # ffffffffc0206ce0 <default_pmm_manager+0x928>
ffffffffc0203d2a:	00002617          	auipc	a2,0x2
ffffffffc0203d2e:	2de60613          	addi	a2,a2,734 # ffffffffc0206008 <commands+0x748>
ffffffffc0203d32:	13e00593          	li	a1,318
ffffffffc0203d36:	00003517          	auipc	a0,0x3
ffffffffc0203d3a:	eba50513          	addi	a0,a0,-326 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203d3e:	f10fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203d42:	00003697          	auipc	a3,0x3
ffffffffc0203d46:	02668693          	addi	a3,a3,38 # ffffffffc0206d68 <default_pmm_manager+0x9b0>
ffffffffc0203d4a:	00002617          	auipc	a2,0x2
ffffffffc0203d4e:	2be60613          	addi	a2,a2,702 # ffffffffc0206008 <commands+0x748>
ffffffffc0203d52:	14f00593          	li	a1,335
ffffffffc0203d56:	00003517          	auipc	a0,0x3
ffffffffc0203d5a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203d5e:	ef0fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203d62:	00003697          	auipc	a3,0x3
ffffffffc0203d66:	03668693          	addi	a3,a3,54 # ffffffffc0206d98 <default_pmm_manager+0x9e0>
ffffffffc0203d6a:	00002617          	auipc	a2,0x2
ffffffffc0203d6e:	29e60613          	addi	a2,a2,670 # ffffffffc0206008 <commands+0x748>
ffffffffc0203d72:	15000593          	li	a1,336
ffffffffc0203d76:	00003517          	auipc	a0,0x3
ffffffffc0203d7a:	e7a50513          	addi	a0,a0,-390 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203d7e:	ed0fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d82:	00003697          	auipc	a3,0x3
ffffffffc0203d86:	f4668693          	addi	a3,a3,-186 # ffffffffc0206cc8 <default_pmm_manager+0x910>
ffffffffc0203d8a:	00002617          	auipc	a2,0x2
ffffffffc0203d8e:	27e60613          	addi	a2,a2,638 # ffffffffc0206008 <commands+0x748>
ffffffffc0203d92:	13c00593          	li	a1,316
ffffffffc0203d96:	00003517          	auipc	a0,0x3
ffffffffc0203d9a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203d9e:	eb0fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma2 != NULL);
ffffffffc0203da2:	00003697          	auipc	a3,0x3
ffffffffc0203da6:	f8668693          	addi	a3,a3,-122 # ffffffffc0206d28 <default_pmm_manager+0x970>
ffffffffc0203daa:	00002617          	auipc	a2,0x2
ffffffffc0203dae:	25e60613          	addi	a2,a2,606 # ffffffffc0206008 <commands+0x748>
ffffffffc0203db2:	14700593          	li	a1,327
ffffffffc0203db6:	00003517          	auipc	a0,0x3
ffffffffc0203dba:	e3a50513          	addi	a0,a0,-454 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203dbe:	e90fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma1 != NULL);
ffffffffc0203dc2:	00003697          	auipc	a3,0x3
ffffffffc0203dc6:	f5668693          	addi	a3,a3,-170 # ffffffffc0206d18 <default_pmm_manager+0x960>
ffffffffc0203dca:	00002617          	auipc	a2,0x2
ffffffffc0203dce:	23e60613          	addi	a2,a2,574 # ffffffffc0206008 <commands+0x748>
ffffffffc0203dd2:	14500593          	li	a1,325
ffffffffc0203dd6:	00003517          	auipc	a0,0x3
ffffffffc0203dda:	e1a50513          	addi	a0,a0,-486 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203dde:	e70fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma3 == NULL);
ffffffffc0203de2:	00003697          	auipc	a3,0x3
ffffffffc0203de6:	f5668693          	addi	a3,a3,-170 # ffffffffc0206d38 <default_pmm_manager+0x980>
ffffffffc0203dea:	00002617          	auipc	a2,0x2
ffffffffc0203dee:	21e60613          	addi	a2,a2,542 # ffffffffc0206008 <commands+0x748>
ffffffffc0203df2:	14900593          	li	a1,329
ffffffffc0203df6:	00003517          	auipc	a0,0x3
ffffffffc0203dfa:	dfa50513          	addi	a0,a0,-518 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203dfe:	e50fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma5 == NULL);
ffffffffc0203e02:	00003697          	auipc	a3,0x3
ffffffffc0203e06:	f5668693          	addi	a3,a3,-170 # ffffffffc0206d58 <default_pmm_manager+0x9a0>
ffffffffc0203e0a:	00002617          	auipc	a2,0x2
ffffffffc0203e0e:	1fe60613          	addi	a2,a2,510 # ffffffffc0206008 <commands+0x748>
ffffffffc0203e12:	14d00593          	li	a1,333
ffffffffc0203e16:	00003517          	auipc	a0,0x3
ffffffffc0203e1a:	dda50513          	addi	a0,a0,-550 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203e1e:	e30fc0ef          	jal	ra,ffffffffc020044e <__panic>
        assert(vma4 == NULL);
ffffffffc0203e22:	00003697          	auipc	a3,0x3
ffffffffc0203e26:	f2668693          	addi	a3,a3,-218 # ffffffffc0206d48 <default_pmm_manager+0x990>
ffffffffc0203e2a:	00002617          	auipc	a2,0x2
ffffffffc0203e2e:	1de60613          	addi	a2,a2,478 # ffffffffc0206008 <commands+0x748>
ffffffffc0203e32:	14b00593          	li	a1,331
ffffffffc0203e36:	00003517          	auipc	a0,0x3
ffffffffc0203e3a:	dba50513          	addi	a0,a0,-582 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203e3e:	e10fc0ef          	jal	ra,ffffffffc020044e <__panic>
    assert(mm != NULL);
ffffffffc0203e42:	00003697          	auipc	a3,0x3
ffffffffc0203e46:	e3668693          	addi	a3,a3,-458 # ffffffffc0206c78 <default_pmm_manager+0x8c0>
ffffffffc0203e4a:	00002617          	auipc	a2,0x2
ffffffffc0203e4e:	1be60613          	addi	a2,a2,446 # ffffffffc0206008 <commands+0x748>
ffffffffc0203e52:	12500593          	li	a1,293
ffffffffc0203e56:	00003517          	auipc	a0,0x3
ffffffffc0203e5a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0206bf0 <default_pmm_manager+0x838>
ffffffffc0203e5e:	df0fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203e62 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203e62:	7179                	addi	sp,sp,-48
ffffffffc0203e64:	f022                	sd	s0,32(sp)
ffffffffc0203e66:	f406                	sd	ra,40(sp)
ffffffffc0203e68:	ec26                	sd	s1,24(sp)
ffffffffc0203e6a:	e84a                	sd	s2,16(sp)
ffffffffc0203e6c:	e44e                	sd	s3,8(sp)
ffffffffc0203e6e:	e052                	sd	s4,0(sp)
ffffffffc0203e70:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203e72:	c135                	beqz	a0,ffffffffc0203ed6 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203e74:	002007b7          	lui	a5,0x200
ffffffffc0203e78:	04f5e663          	bltu	a1,a5,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e7c:	00c584b3          	add	s1,a1,a2
ffffffffc0203e80:	0495f263          	bgeu	a1,s1,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e84:	4785                	li	a5,1
ffffffffc0203e86:	07fe                	slli	a5,a5,0x1f
ffffffffc0203e88:	0297ee63          	bltu	a5,s1,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203e8c:	892a                	mv	s2,a0
ffffffffc0203e8e:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203e90:	6a05                	lui	s4,0x1
ffffffffc0203e92:	a821                	j	ffffffffc0203eaa <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e94:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203e98:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e9c:	c685                	beqz	a3,ffffffffc0203ec4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9e:	c399                	beqz	a5,ffffffffc0203ea4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ea0:	02e46263          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203ea4:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203ea6:	04947663          	bgeu	s0,s1,ffffffffc0203ef2 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203eaa:	85a2                	mv	a1,s0
ffffffffc0203eac:	854a                	mv	a0,s2
ffffffffc0203eae:	96fff0ef          	jal	ra,ffffffffc020381c <find_vma>
ffffffffc0203eb2:	c909                	beqz	a0,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203eb4:	6518                	ld	a4,8(a0)
ffffffffc0203eb6:	00e46763          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203eba:	4d1c                	lw	a5,24(a0)
ffffffffc0203ebc:	fc099ce3          	bnez	s3,ffffffffc0203e94 <user_mem_check+0x32>
ffffffffc0203ec0:	8b85                	andi	a5,a5,1
ffffffffc0203ec2:	f3ed                	bnez	a5,ffffffffc0203ea4 <user_mem_check+0x42>
            return 0;
ffffffffc0203ec4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203ec6:	70a2                	ld	ra,40(sp)
ffffffffc0203ec8:	7402                	ld	s0,32(sp)
ffffffffc0203eca:	64e2                	ld	s1,24(sp)
ffffffffc0203ecc:	6942                	ld	s2,16(sp)
ffffffffc0203ece:	69a2                	ld	s3,8(sp)
ffffffffc0203ed0:	6a02                	ld	s4,0(sp)
ffffffffc0203ed2:	6145                	addi	sp,sp,48
ffffffffc0203ed4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203ed6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203eda:	4501                	li	a0,0
ffffffffc0203edc:	fef5e5e3          	bltu	a1,a5,ffffffffc0203ec6 <user_mem_check+0x64>
ffffffffc0203ee0:	962e                	add	a2,a2,a1
ffffffffc0203ee2:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203ec6 <user_mem_check+0x64>
ffffffffc0203ee6:	c8000537          	lui	a0,0xc8000
ffffffffc0203eea:	0505                	addi	a0,a0,1
ffffffffc0203eec:	00a63533          	sltu	a0,a2,a0
ffffffffc0203ef0:	bfd9                	j	ffffffffc0203ec6 <user_mem_check+0x64>
        return 1;
ffffffffc0203ef2:	4505                	li	a0,1
ffffffffc0203ef4:	bfc9                	j	ffffffffc0203ec6 <user_mem_check+0x64>

ffffffffc0203ef6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203ef6:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203ef8:	9402                	jalr	s0

	jal do_exit
ffffffffc0203efa:	6ec000ef          	jal	ra,ffffffffc02045e6 <do_exit>

ffffffffc0203efe <alloc_proc>:

//lab5 function2 YOUR CODE update alloc_proc
// alloc_proc - 分配并初始化一个 PCB，所有字段先置于安全初值。
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203efe:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f00:	10800513          	li	a0,264
{
ffffffffc0203f04:	e022                	sd	s0,0(sp)
ffffffffc0203f06:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f08:	c59fd0ef          	jal	ra,ffffffffc0201b60 <kmalloc>
ffffffffc0203f0c:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203f0e:	c921                	beqz	a0,ffffffffc0203f5e <alloc_proc+0x60>
    {
        memset(proc, 0, sizeof(struct proc_struct));
ffffffffc0203f10:	10800613          	li	a2,264
ffffffffc0203f14:	4581                	li	a1,0
ffffffffc0203f16:	718010ef          	jal	ra,ffffffffc020562e <memset>
        proc->state = PROC_UNINIT;
ffffffffc0203f1a:	57fd                	li	a5,-1
ffffffffc0203f1c:	1782                	slli	a5,a5,0x20
ffffffffc0203f1e:	e01c                	sd	a5,0(s0)
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        // 内核线程共享内核地址空间，因此初始页表指向内核页表。
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203f20:	000a7797          	auipc	a5,0xa7
ffffffffc0203f24:	8f07b783          	ld	a5,-1808(a5) # ffffffffc02aa810 <boot_pgdir_pa>
        proc->runs = 0;
ffffffffc0203f28:	00042423          	sw	zero,8(s0)
        proc->kstack = 0;
ffffffffc0203f2c:	00043823          	sd	zero,16(s0)
        proc->need_resched = 0;
ffffffffc0203f30:	00043c23          	sd	zero,24(s0)
        proc->parent = NULL;
ffffffffc0203f34:	02043023          	sd	zero,32(s0)
        proc->mm = NULL;
ffffffffc0203f38:	02043423          	sd	zero,40(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203f3c:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;
ffffffffc0203f3e:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203f42:	0a042823          	sw	zero,176(s0)
        proc->exit_code = 0;
ffffffffc0203f46:	0e043423          	sd	zero,232(s0)
        proc->wait_state = 0;
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0203f4a:	0e043823          	sd	zero,240(s0)
ffffffffc0203f4e:	0e043c23          	sd	zero,248(s0)
ffffffffc0203f52:	10043023          	sd	zero,256(s0)
        proc->context.ra = 0;
ffffffffc0203f56:	02043823          	sd	zero,48(s0)
        proc->context.sp = 0;
ffffffffc0203f5a:	02043c23          	sd	zero,56(s0)
    }
    return proc;
}
ffffffffc0203f5e:	60a2                	ld	ra,8(sp)
ffffffffc0203f60:	8522                	mv	a0,s0
ffffffffc0203f62:	6402                	ld	s0,0(sp)
ffffffffc0203f64:	0141                	addi	sp,sp,16
ffffffffc0203f66:	8082                	ret

ffffffffc0203f68 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203f68:	000a7797          	auipc	a5,0xa7
ffffffffc0203f6c:	8e07b783          	ld	a5,-1824(a5) # ffffffffc02aa848 <current>
ffffffffc0203f70:	73c8                	ld	a0,160(a5)
ffffffffc0203f72:	f95fc06f          	j	ffffffffc0200f06 <forkrets>

ffffffffc0203f76 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203f76:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203f78:	1141                	addi	sp,sp,-16
ffffffffc0203f7a:	e406                	sd	ra,8(sp)
ffffffffc0203f7c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203f80:	02f6ee63          	bltu	a3,a5,ffffffffc0203fbc <put_pgdir+0x46>
ffffffffc0203f84:	000a7517          	auipc	a0,0xa7
ffffffffc0203f88:	8bc53503          	ld	a0,-1860(a0) # ffffffffc02aa840 <va_pa_offset>
ffffffffc0203f8c:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0203f8e:	82b1                	srli	a3,a3,0xc
ffffffffc0203f90:	000a7797          	auipc	a5,0xa7
ffffffffc0203f94:	8907b783          	ld	a5,-1904(a5) # ffffffffc02aa820 <npage>
ffffffffc0203f98:	02f6fe63          	bgeu	a3,a5,ffffffffc0203fd4 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203f9c:	00003517          	auipc	a0,0x3
ffffffffc0203fa0:	55453503          	ld	a0,1364(a0) # ffffffffc02074f0 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203fa4:	60a2                	ld	ra,8(sp)
ffffffffc0203fa6:	8e89                	sub	a3,a3,a0
ffffffffc0203fa8:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203faa:	000a7517          	auipc	a0,0xa7
ffffffffc0203fae:	87e53503          	ld	a0,-1922(a0) # ffffffffc02aa828 <pages>
ffffffffc0203fb2:	4585                	li	a1,1
ffffffffc0203fb4:	9536                	add	a0,a0,a3
}
ffffffffc0203fb6:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203fb8:	dc5fd06f          	j	ffffffffc0201d7c <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203fbc:	00002617          	auipc	a2,0x2
ffffffffc0203fc0:	4dc60613          	addi	a2,a2,1244 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc0203fc4:	07700593          	li	a1,119
ffffffffc0203fc8:	00002517          	auipc	a0,0x2
ffffffffc0203fcc:	45050513          	addi	a0,a0,1104 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0203fd0:	c7efc0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203fd4:	00002617          	auipc	a2,0x2
ffffffffc0203fd8:	4ec60613          	addi	a2,a2,1260 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc0203fdc:	06900593          	li	a1,105
ffffffffc0203fe0:	00002517          	auipc	a0,0x2
ffffffffc0203fe4:	43850513          	addi	a0,a0,1080 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0203fe8:	c66fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0203fec <do_fork>:


//lab5 function3 YOUR CODE
// do_fork - 基于当前进程创建新进程/线程。
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc0203fec:	7119                	addi	sp,sp,-128
ffffffffc0203fee:	f0ca                	sd	s2,96(sp)
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;

    if (nr_process >= MAX_PROCESS)
ffffffffc0203ff0:	000a7917          	auipc	s2,0xa7
ffffffffc0203ff4:	87090913          	addi	s2,s2,-1936 # ffffffffc02aa860 <nr_process>
ffffffffc0203ff8:	00092703          	lw	a4,0(s2)
{
ffffffffc0203ffc:	fc86                	sd	ra,120(sp)
ffffffffc0203ffe:	f8a2                	sd	s0,112(sp)
ffffffffc0204000:	f4a6                	sd	s1,104(sp)
ffffffffc0204002:	ecce                	sd	s3,88(sp)
ffffffffc0204004:	e8d2                	sd	s4,80(sp)
ffffffffc0204006:	e4d6                	sd	s5,72(sp)
ffffffffc0204008:	e0da                	sd	s6,64(sp)
ffffffffc020400a:	fc5e                	sd	s7,56(sp)
ffffffffc020400c:	f862                	sd	s8,48(sp)
ffffffffc020400e:	f466                	sd	s9,40(sp)
ffffffffc0204010:	f06a                	sd	s10,32(sp)
ffffffffc0204012:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204014:	6785                	lui	a5,0x1
ffffffffc0204016:	34f75d63          	bge	a4,a5,ffffffffc0204370 <do_fork+0x384>
ffffffffc020401a:	8a2a                	mv	s4,a0
ffffffffc020401c:	89ae                	mv	s3,a1
ffffffffc020401e:	8432                	mv	s0,a2
    {
        goto fork_out;
    }

    ret = -E_NO_MEM;
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204020:	edfff0ef          	jal	ra,ffffffffc0203efe <alloc_proc>
ffffffffc0204024:	84aa                	mv	s1,a0
ffffffffc0204026:	34050363          	beqz	a0,ffffffffc020436c <do_fork+0x380>
    {
        goto fork_out;
    }
    proc->parent = current;
ffffffffc020402a:	000a7c17          	auipc	s8,0xa7
ffffffffc020402e:	81ec0c13          	addi	s8,s8,-2018 # ffffffffc02aa848 <current>
ffffffffc0204032:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0204036:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8ad4>
    proc->parent = current;
ffffffffc020403a:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc020403c:	32071f63          	bnez	a4,ffffffffc020437a <do_fork+0x38e>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204040:	4509                	li	a0,2
ffffffffc0204042:	cfdfd0ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
    if (page != NULL)
ffffffffc0204046:	32050063          	beqz	a0,ffffffffc0204366 <do_fork+0x37a>
    return page - pages + nbase;
ffffffffc020404a:	000a6a97          	auipc	s5,0xa6
ffffffffc020404e:	7dea8a93          	addi	s5,s5,2014 # ffffffffc02aa828 <pages>
ffffffffc0204052:	000ab683          	ld	a3,0(s5)
ffffffffc0204056:	00003b17          	auipc	s6,0x3
ffffffffc020405a:	49ab0b13          	addi	s6,s6,1178 # ffffffffc02074f0 <nbase>
ffffffffc020405e:	000b3783          	ld	a5,0(s6)
ffffffffc0204062:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204066:	000a6b97          	auipc	s7,0xa6
ffffffffc020406a:	7bab8b93          	addi	s7,s7,1978 # ffffffffc02aa820 <npage>
    return page - pages + nbase;
ffffffffc020406e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204070:	5d7d                	li	s10,-1
ffffffffc0204072:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204076:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204078:	00cd5d13          	srli	s10,s10,0xc
ffffffffc020407c:	01a6f633          	and	a2,a3,s10
    return page2ppn(page) << PGSHIFT;
ffffffffc0204080:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204082:	34e67563          	bgeu	a2,a4,ffffffffc02043cc <do_fork+0x3e0>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204086:	000c3603          	ld	a2,0(s8)
ffffffffc020408a:	000a6c17          	auipc	s8,0xa6
ffffffffc020408e:	7b6c0c13          	addi	s8,s8,1974 # ffffffffc02aa840 <va_pa_offset>
ffffffffc0204092:	000c3703          	ld	a4,0(s8)
ffffffffc0204096:	02863d83          	ld	s11,40(a2)
ffffffffc020409a:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020409c:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc020409e:	020d8563          	beqz	s11,ffffffffc02040c8 <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc02040a2:	100a7a13          	andi	s4,s4,256
ffffffffc02040a6:	1c0a0163          	beqz	s4,ffffffffc0204268 <do_fork+0x27c>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc02040aa:	030da603          	lw	a2,48(s11)
        proc->pgdir = PADDR(mm->pgdir);
ffffffffc02040ae:	018db783          	ld	a5,24(s11)
ffffffffc02040b2:	c02005b7          	lui	a1,0xc0200
ffffffffc02040b6:	2605                	addiw	a2,a2,1
ffffffffc02040b8:	02cda823          	sw	a2,48(s11)
        proc->mm = mm;
ffffffffc02040bc:	03b4b423          	sd	s11,40(s1)
        proc->pgdir = PADDR(mm->pgdir);
ffffffffc02040c0:	32b7e263          	bltu	a5,a1,ffffffffc02043e4 <do_fork+0x3f8>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02040c4:	8f99                	sub	a5,a5,a4
ffffffffc02040c6:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02040c8:	6789                	lui	a5,0x2
ffffffffc02040ca:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce0>
ffffffffc02040ce:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02040d0:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02040d2:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc02040d4:	87b6                	mv	a5,a3
ffffffffc02040d6:	12040893          	addi	a7,s0,288
ffffffffc02040da:	00063803          	ld	a6,0(a2)
ffffffffc02040de:	6608                	ld	a0,8(a2)
ffffffffc02040e0:	6a0c                	ld	a1,16(a2)
ffffffffc02040e2:	6e18                	ld	a4,24(a2)
ffffffffc02040e4:	0107b023          	sd	a6,0(a5)
ffffffffc02040e8:	e788                	sd	a0,8(a5)
ffffffffc02040ea:	eb8c                	sd	a1,16(a5)
ffffffffc02040ec:	ef98                	sd	a4,24(a5)
ffffffffc02040ee:	02060613          	addi	a2,a2,32
ffffffffc02040f2:	02078793          	addi	a5,a5,32
ffffffffc02040f6:	ff1612e3          	bne	a2,a7,ffffffffc02040da <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02040fa:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02040fe:	12098f63          	beqz	s3,ffffffffc020423c <do_fork+0x250>
ffffffffc0204102:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204106:	00000797          	auipc	a5,0x0
ffffffffc020410a:	e6278793          	addi	a5,a5,-414 # ffffffffc0203f68 <forkret>
ffffffffc020410e:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)proc->tf;
ffffffffc0204110:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204112:	100027f3          	csrr	a5,sstatus
ffffffffc0204116:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204118:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020411a:	14079063          	bnez	a5,ffffffffc020425a <do_fork+0x26e>
    if (++last_pid >= MAX_PID)
ffffffffc020411e:	000a2817          	auipc	a6,0xa2
ffffffffc0204122:	29280813          	addi	a6,a6,658 # ffffffffc02a63b0 <last_pid.1>
ffffffffc0204126:	00082783          	lw	a5,0(a6)
ffffffffc020412a:	6709                	lui	a4,0x2
ffffffffc020412c:	0017851b          	addiw	a0,a5,1
ffffffffc0204130:	00a82023          	sw	a0,0(a6)
ffffffffc0204134:	08e55d63          	bge	a0,a4,ffffffffc02041ce <do_fork+0x1e2>
    if (last_pid >= next_safe)
ffffffffc0204138:	000a2317          	auipc	t1,0xa2
ffffffffc020413c:	27c30313          	addi	t1,t1,636 # ffffffffc02a63b4 <next_safe.0>
ffffffffc0204140:	00032783          	lw	a5,0(t1)
ffffffffc0204144:	000a6417          	auipc	s0,0xa6
ffffffffc0204148:	68c40413          	addi	s0,s0,1676 # ffffffffc02aa7d0 <proc_list>
ffffffffc020414c:	08f55963          	bge	a0,a5,ffffffffc02041de <do_fork+0x1f2>

    // 在关中断临界区内完成 PID 分配与进程树挂接，避免暴露中间状态。
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc0204150:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204152:	45a9                	li	a1,10
ffffffffc0204154:	2501                	sext.w	a0,a0
ffffffffc0204156:	032010ef          	jal	ra,ffffffffc0205188 <hash32>
ffffffffc020415a:	02051793          	slli	a5,a0,0x20
ffffffffc020415e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204162:	000a2797          	auipc	a5,0xa2
ffffffffc0204166:	66e78793          	addi	a5,a5,1646 # ffffffffc02a67d0 <hash_list>
ffffffffc020416a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020416c:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020416e:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204170:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204174:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204176:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204178:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020417a:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020417c:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204180:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204182:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204184:	e21c                	sd	a5,0(a2)
ffffffffc0204186:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204188:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020418a:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc020418c:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204190:	10e4b023          	sd	a4,256(s1)
ffffffffc0204194:	c311                	beqz	a4,ffffffffc0204198 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc0204196:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc0204198:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020419c:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc020419e:	2785                	addiw	a5,a5,1
ffffffffc02041a0:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc02041a4:	0a099f63          	bnez	s3,ffffffffc0204262 <do_fork+0x276>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc02041a8:	8526                	mv	a0,s1
ffffffffc02041aa:	625000ef          	jal	ra,ffffffffc0204fce <wakeup_proc>

    ret = proc->pid;
ffffffffc02041ae:	40c8                	lw	a0,4(s1)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc02041b0:	70e6                	ld	ra,120(sp)
ffffffffc02041b2:	7446                	ld	s0,112(sp)
ffffffffc02041b4:	74a6                	ld	s1,104(sp)
ffffffffc02041b6:	7906                	ld	s2,96(sp)
ffffffffc02041b8:	69e6                	ld	s3,88(sp)
ffffffffc02041ba:	6a46                	ld	s4,80(sp)
ffffffffc02041bc:	6aa6                	ld	s5,72(sp)
ffffffffc02041be:	6b06                	ld	s6,64(sp)
ffffffffc02041c0:	7be2                	ld	s7,56(sp)
ffffffffc02041c2:	7c42                	ld	s8,48(sp)
ffffffffc02041c4:	7ca2                	ld	s9,40(sp)
ffffffffc02041c6:	7d02                	ld	s10,32(sp)
ffffffffc02041c8:	6de2                	ld	s11,24(sp)
ffffffffc02041ca:	6109                	addi	sp,sp,128
ffffffffc02041cc:	8082                	ret
        last_pid = 1;
ffffffffc02041ce:	4785                	li	a5,1
ffffffffc02041d0:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02041d4:	4505                	li	a0,1
ffffffffc02041d6:	000a2317          	auipc	t1,0xa2
ffffffffc02041da:	1de30313          	addi	t1,t1,478 # ffffffffc02a63b4 <next_safe.0>
    return listelm->next;
ffffffffc02041de:	000a6417          	auipc	s0,0xa6
ffffffffc02041e2:	5f240413          	addi	s0,s0,1522 # ffffffffc02aa7d0 <proc_list>
ffffffffc02041e6:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02041ea:	6789                	lui	a5,0x2
ffffffffc02041ec:	00f32023          	sw	a5,0(t1)
ffffffffc02041f0:	86aa                	mv	a3,a0
ffffffffc02041f2:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02041f4:	6e89                	lui	t4,0x2
ffffffffc02041f6:	108e0b63          	beq	t3,s0,ffffffffc020430c <do_fork+0x320>
ffffffffc02041fa:	88ae                	mv	a7,a1
ffffffffc02041fc:	87f2                	mv	a5,t3
ffffffffc02041fe:	6609                	lui	a2,0x2
ffffffffc0204200:	a811                	j	ffffffffc0204214 <do_fork+0x228>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204202:	00e6d663          	bge	a3,a4,ffffffffc020420e <do_fork+0x222>
ffffffffc0204206:	00c75463          	bge	a4,a2,ffffffffc020420e <do_fork+0x222>
ffffffffc020420a:	863a                	mv	a2,a4
ffffffffc020420c:	4885                	li	a7,1
ffffffffc020420e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204210:	00878d63          	beq	a5,s0,ffffffffc020422a <do_fork+0x23e>
            if (proc->pid == last_pid)
ffffffffc0204214:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c84>
ffffffffc0204218:	fed715e3          	bne	a4,a3,ffffffffc0204202 <do_fork+0x216>
                if (++last_pid >= next_safe)
ffffffffc020421c:	2685                	addiw	a3,a3,1
ffffffffc020421e:	0ec6d263          	bge	a3,a2,ffffffffc0204302 <do_fork+0x316>
ffffffffc0204222:	679c                	ld	a5,8(a5)
ffffffffc0204224:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204226:	fe8797e3          	bne	a5,s0,ffffffffc0204214 <do_fork+0x228>
ffffffffc020422a:	c581                	beqz	a1,ffffffffc0204232 <do_fork+0x246>
ffffffffc020422c:	00d82023          	sw	a3,0(a6)
ffffffffc0204230:	8536                	mv	a0,a3
ffffffffc0204232:	f0088fe3          	beqz	a7,ffffffffc0204150 <do_fork+0x164>
ffffffffc0204236:	00c32023          	sw	a2,0(t1)
ffffffffc020423a:	bf19                	j	ffffffffc0204150 <do_fork+0x164>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020423c:	89b6                	mv	s3,a3
ffffffffc020423e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204242:	00000797          	auipc	a5,0x0
ffffffffc0204246:	d2678793          	addi	a5,a5,-730 # ffffffffc0203f68 <forkret>
ffffffffc020424a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)proc->tf;
ffffffffc020424c:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020424e:	100027f3          	csrr	a5,sstatus
ffffffffc0204252:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204254:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204256:	ec0784e3          	beqz	a5,ffffffffc020411e <do_fork+0x132>
        intr_disable();
ffffffffc020425a:	f1afc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc020425e:	4985                	li	s3,1
ffffffffc0204260:	bd7d                	j	ffffffffc020411e <do_fork+0x132>
        intr_enable();
ffffffffc0204262:	f0cfc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc0204266:	b789                	j	ffffffffc02041a8 <do_fork+0x1bc>
ffffffffc0204268:	e43e                	sd	a5,8(sp)
    if ((mm = mm_create()) == NULL)
ffffffffc020426a:	d82ff0ef          	jal	ra,ffffffffc02037ec <mm_create>
ffffffffc020426e:	8caa                	mv	s9,a0
ffffffffc0204270:	c179                	beqz	a0,ffffffffc0204336 <do_fork+0x34a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204272:	4505                	li	a0,1
ffffffffc0204274:	acbfd0ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0204278:	cd45                	beqz	a0,ffffffffc0204330 <do_fork+0x344>
    return page - pages + nbase;
ffffffffc020427a:	000ab683          	ld	a3,0(s5)
ffffffffc020427e:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204280:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204284:	40d506b3          	sub	a3,a0,a3
ffffffffc0204288:	8699                	srai	a3,a3,0x6
ffffffffc020428a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020428c:	01a6fd33          	and	s10,a3,s10
    return page2ppn(page) << PGSHIFT;
ffffffffc0204290:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204292:	12ed7d63          	bgeu	s10,a4,ffffffffc02043cc <do_fork+0x3e0>
ffffffffc0204296:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc020429a:	6605                	lui	a2,0x1
ffffffffc020429c:	000a6597          	auipc	a1,0xa6
ffffffffc02042a0:	57c5b583          	ld	a1,1404(a1) # ffffffffc02aa818 <boot_pgdir_va>
ffffffffc02042a4:	9a36                	add	s4,s4,a3
ffffffffc02042a6:	8552                	mv	a0,s4
ffffffffc02042a8:	398010ef          	jal	ra,ffffffffc0205640 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02042ac:	038d8d13          	addi	s10,s11,56
    mm->pgdir = pgdir;
ffffffffc02042b0:	014cbc23          	sd	s4,24(s9) # fffffffffff80018 <end+0x3fcd57b4>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02042b4:	4785                	li	a5,1
ffffffffc02042b6:	40fd37af          	amoor.d	a5,a5,(s10)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02042ba:	8b85                	andi	a5,a5,1
ffffffffc02042bc:	4a05                	li	s4,1
ffffffffc02042be:	c799                	beqz	a5,ffffffffc02042cc <do_fork+0x2e0>
    {
        schedule();
ffffffffc02042c0:	58f000ef          	jal	ra,ffffffffc020504e <schedule>
ffffffffc02042c4:	414d37af          	amoor.d	a5,s4,(s10)
    while (!try_lock(lock))
ffffffffc02042c8:	8b85                	andi	a5,a5,1
ffffffffc02042ca:	fbfd                	bnez	a5,ffffffffc02042c0 <do_fork+0x2d4>
        int ret = dup_mmap(mm, oldmm);
ffffffffc02042cc:	85ee                	mv	a1,s11
ffffffffc02042ce:	8566                	mv	a0,s9
ffffffffc02042d0:	f5eff0ef          	jal	ra,ffffffffc0203a2e <dup_mmap>
        if (ret != 0)
ffffffffc02042d4:	e129                	bnez	a0,ffffffffc0204316 <do_fork+0x32a>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02042d6:	57f9                	li	a5,-2
ffffffffc02042d8:	038d8713          	addi	a4,s11,56
ffffffffc02042dc:	60f737af          	amoand.d	a5,a5,(a4)
ffffffffc02042e0:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc02042e2:	cbe9                	beqz	a5,ffffffffc02043b4 <do_fork+0x3c8>
    mm->mm_count = val;
ffffffffc02042e4:	4705                	li	a4,1
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02042e6:	018cb783          	ld	a5,24(s9)
ffffffffc02042ea:	02eca823          	sw	a4,48(s9)
    proc->mm = mm;
ffffffffc02042ee:	0394b423          	sd	s9,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02042f2:	c0200737          	lui	a4,0xc0200
ffffffffc02042f6:	0ae7e263          	bltu	a5,a4,ffffffffc020439a <do_fork+0x3ae>
ffffffffc02042fa:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02042fe:	6894                	ld	a3,16(s1)
ffffffffc0204300:	b3d1                	j	ffffffffc02040c4 <do_fork+0xd8>
                    if (last_pid >= MAX_PID)
ffffffffc0204302:	01d6c363          	blt	a3,t4,ffffffffc0204308 <do_fork+0x31c>
                        last_pid = 1;
ffffffffc0204306:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204308:	4585                	li	a1,1
ffffffffc020430a:	b5f5                	j	ffffffffc02041f6 <do_fork+0x20a>
ffffffffc020430c:	c5a5                	beqz	a1,ffffffffc0204374 <do_fork+0x388>
ffffffffc020430e:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0204312:	8536                	mv	a0,a3
ffffffffc0204314:	bd35                	j	ffffffffc0204150 <do_fork+0x164>
ffffffffc0204316:	57f9                	li	a5,-2
ffffffffc0204318:	038d8713          	addi	a4,s11,56
ffffffffc020431c:	60f737af          	amoand.d	a5,a5,(a4)
ffffffffc0204320:	8b85                	andi	a5,a5,1
ffffffffc0204322:	cbc9                	beqz	a5,ffffffffc02043b4 <do_fork+0x3c8>
    exit_mmap(mm);
ffffffffc0204324:	8566                	mv	a0,s9
ffffffffc0204326:	fa2ff0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
    put_pgdir(mm);
ffffffffc020432a:	8566                	mv	a0,s9
ffffffffc020432c:	c4bff0ef          	jal	ra,ffffffffc0203f76 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204330:	8566                	mv	a0,s9
ffffffffc0204332:	dfaff0ef          	jal	ra,ffffffffc020392c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204336:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0204338:	c02007b7          	lui	a5,0xc0200
ffffffffc020433c:	0cf6ed63          	bltu	a3,a5,ffffffffc0204416 <do_fork+0x42a>
ffffffffc0204340:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc0204344:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0204348:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020434c:	83b1                	srli	a5,a5,0xc
ffffffffc020434e:	0ae7f863          	bgeu	a5,a4,ffffffffc02043fe <do_fork+0x412>
    return &pages[PPN(pa) - nbase];
ffffffffc0204352:	000b3703          	ld	a4,0(s6)
ffffffffc0204356:	000ab503          	ld	a0,0(s5)
ffffffffc020435a:	4589                	li	a1,2
ffffffffc020435c:	8f99                	sub	a5,a5,a4
ffffffffc020435e:	079a                	slli	a5,a5,0x6
ffffffffc0204360:	953e                	add	a0,a0,a5
ffffffffc0204362:	a1bfd0ef          	jal	ra,ffffffffc0201d7c <free_pages>
    kfree(proc);
ffffffffc0204366:	8526                	mv	a0,s1
ffffffffc0204368:	8a9fd0ef          	jal	ra,ffffffffc0201c10 <kfree>
    ret = -E_NO_MEM;
ffffffffc020436c:	5571                	li	a0,-4
    return ret;
ffffffffc020436e:	b589                	j	ffffffffc02041b0 <do_fork+0x1c4>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204370:	556d                	li	a0,-5
ffffffffc0204372:	bd3d                	j	ffffffffc02041b0 <do_fork+0x1c4>
    return last_pid;
ffffffffc0204374:	00082503          	lw	a0,0(a6)
ffffffffc0204378:	bbe1                	j	ffffffffc0204150 <do_fork+0x164>
    assert(current->wait_state == 0);
ffffffffc020437a:	00003697          	auipc	a3,0x3
ffffffffc020437e:	ad668693          	addi	a3,a3,-1322 # ffffffffc0206e50 <default_pmm_manager+0xa98>
ffffffffc0204382:	00002617          	auipc	a2,0x2
ffffffffc0204386:	c8660613          	addi	a2,a2,-890 # ffffffffc0206008 <commands+0x748>
ffffffffc020438a:	1cd00593          	li	a1,461
ffffffffc020438e:	00003517          	auipc	a0,0x3
ffffffffc0204392:	ae250513          	addi	a0,a0,-1310 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204396:	8b8fc0ef          	jal	ra,ffffffffc020044e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020439a:	86be                	mv	a3,a5
ffffffffc020439c:	00002617          	auipc	a2,0x2
ffffffffc02043a0:	0fc60613          	addi	a2,a2,252 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc02043a4:	19c00593          	li	a1,412
ffffffffc02043a8:	00003517          	auipc	a0,0x3
ffffffffc02043ac:	ac850513          	addi	a0,a0,-1336 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02043b0:	89efc0ef          	jal	ra,ffffffffc020044e <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc02043b4:	00003617          	auipc	a2,0x3
ffffffffc02043b8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0206e88 <default_pmm_manager+0xad0>
ffffffffc02043bc:	03f00593          	li	a1,63
ffffffffc02043c0:	00003517          	auipc	a0,0x3
ffffffffc02043c4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0206e98 <default_pmm_manager+0xae0>
ffffffffc02043c8:	886fc0ef          	jal	ra,ffffffffc020044e <__panic>
    return KADDR(page2pa(page));
ffffffffc02043cc:	00002617          	auipc	a2,0x2
ffffffffc02043d0:	02460613          	addi	a2,a2,36 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc02043d4:	07100593          	li	a1,113
ffffffffc02043d8:	00002517          	auipc	a0,0x2
ffffffffc02043dc:	04050513          	addi	a0,a0,64 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc02043e0:	86efc0ef          	jal	ra,ffffffffc020044e <__panic>
        proc->pgdir = PADDR(mm->pgdir);
ffffffffc02043e4:	86be                	mv	a3,a5
ffffffffc02043e6:	00002617          	auipc	a2,0x2
ffffffffc02043ea:	0b260613          	addi	a2,a2,178 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc02043ee:	18000593          	li	a1,384
ffffffffc02043f2:	00003517          	auipc	a0,0x3
ffffffffc02043f6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02043fa:	854fc0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02043fe:	00002617          	auipc	a2,0x2
ffffffffc0204402:	0c260613          	addi	a2,a2,194 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc0204406:	06900593          	li	a1,105
ffffffffc020440a:	00002517          	auipc	a0,0x2
ffffffffc020440e:	00e50513          	addi	a0,a0,14 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0204412:	83cfc0ef          	jal	ra,ffffffffc020044e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204416:	00002617          	auipc	a2,0x2
ffffffffc020441a:	08260613          	addi	a2,a2,130 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc020441e:	07700593          	li	a1,119
ffffffffc0204422:	00002517          	auipc	a0,0x2
ffffffffc0204426:	ff650513          	addi	a0,a0,-10 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc020442a:	824fc0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020442e <kernel_thread>:
{
ffffffffc020442e:	7129                	addi	sp,sp,-320
ffffffffc0204430:	fa22                	sd	s0,304(sp)
ffffffffc0204432:	f626                	sd	s1,296(sp)
ffffffffc0204434:	f24a                	sd	s2,288(sp)
ffffffffc0204436:	84ae                	mv	s1,a1
ffffffffc0204438:	892a                	mv	s2,a0
ffffffffc020443a:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020443c:	4581                	li	a1,0
ffffffffc020443e:	12000613          	li	a2,288
ffffffffc0204442:	850a                	mv	a0,sp
{
ffffffffc0204444:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204446:	1e8010ef          	jal	ra,ffffffffc020562e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020444a:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020444c:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020444e:	100027f3          	csrr	a5,sstatus
ffffffffc0204452:	edd7f793          	andi	a5,a5,-291
ffffffffc0204456:	1207e793          	ori	a5,a5,288
ffffffffc020445a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020445c:	860a                	mv	a2,sp
ffffffffc020445e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204462:	00000797          	auipc	a5,0x0
ffffffffc0204466:	a9478793          	addi	a5,a5,-1388 # ffffffffc0203ef6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020446a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020446c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020446e:	b7fff0ef          	jal	ra,ffffffffc0203fec <do_fork>
}
ffffffffc0204472:	70f2                	ld	ra,312(sp)
ffffffffc0204474:	7452                	ld	s0,304(sp)
ffffffffc0204476:	74b2                	ld	s1,296(sp)
ffffffffc0204478:	7912                	ld	s2,288(sp)
ffffffffc020447a:	6131                	addi	sp,sp,320
ffffffffc020447c:	8082                	ret

ffffffffc020447e <proc_init>:
{
ffffffffc020447e:	1101                	addi	sp,sp,-32
ffffffffc0204480:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204482:	000a6797          	auipc	a5,0xa6
ffffffffc0204486:	34e78793          	addi	a5,a5,846 # ffffffffc02aa7d0 <proc_list>
ffffffffc020448a:	ec06                	sd	ra,24(sp)
ffffffffc020448c:	e822                	sd	s0,16(sp)
ffffffffc020448e:	e04a                	sd	s2,0(sp)
ffffffffc0204490:	000a2497          	auipc	s1,0xa2
ffffffffc0204494:	34048493          	addi	s1,s1,832 # ffffffffc02a67d0 <hash_list>
ffffffffc0204498:	e79c                	sd	a5,8(a5)
ffffffffc020449a:	e39c                	sd	a5,0(a5)
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc020449c:	000a6717          	auipc	a4,0xa6
ffffffffc02044a0:	33470713          	addi	a4,a4,820 # ffffffffc02aa7d0 <proc_list>
ffffffffc02044a4:	87a6                	mv	a5,s1
ffffffffc02044a6:	e79c                	sd	a5,8(a5)
ffffffffc02044a8:	e39c                	sd	a5,0(a5)
ffffffffc02044aa:	07c1                	addi	a5,a5,16
ffffffffc02044ac:	fef71de3          	bne	a4,a5,ffffffffc02044a6 <proc_init+0x28>
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02044b0:	a4fff0ef          	jal	ra,ffffffffc0203efe <alloc_proc>
ffffffffc02044b4:	000a6417          	auipc	s0,0xa6
ffffffffc02044b8:	39c40413          	addi	s0,s0,924 # ffffffffc02aa850 <idleproc>
ffffffffc02044bc:	e008                	sd	a0,0(s0)
ffffffffc02044be:	10050863          	beqz	a0,ffffffffc02045ce <proc_init+0x150>
    idleproc->state = PROC_RUNNABLE;
ffffffffc02044c2:	4789                	li	a5,2
ffffffffc02044c4:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02044c6:	00004797          	auipc	a5,0x4
ffffffffc02044ca:	b3a78793          	addi	a5,a5,-1222 # ffffffffc0208000 <bootstack>
ffffffffc02044ce:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02044d0:	0b450913          	addi	s2,a0,180
    idleproc->need_resched = 1;
ffffffffc02044d4:	4785                	li	a5,1
ffffffffc02044d6:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02044d8:	4641                	li	a2,16
ffffffffc02044da:	4581                	li	a1,0
ffffffffc02044dc:	854a                	mv	a0,s2
ffffffffc02044de:	150010ef          	jal	ra,ffffffffc020562e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02044e2:	463d                	li	a2,15
ffffffffc02044e4:	00003597          	auipc	a1,0x3
ffffffffc02044e8:	9e458593          	addi	a1,a1,-1564 # ffffffffc0206ec8 <default_pmm_manager+0xb10>
ffffffffc02044ec:	854a                	mv	a0,s2
ffffffffc02044ee:	152010ef          	jal	ra,ffffffffc0205640 <memcpy>
    nr_process++;
ffffffffc02044f2:	000a6717          	auipc	a4,0xa6
ffffffffc02044f6:	36e70713          	addi	a4,a4,878 # ffffffffc02aa860 <nr_process>
ffffffffc02044fa:	431c                	lw	a5,0(a4)
    current = idleproc;
ffffffffc02044fc:	6014                	ld	a3,0(s0)
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02044fe:	4601                	li	a2,0
    nr_process++;
ffffffffc0204500:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204502:	00003597          	auipc	a1,0x3
ffffffffc0204506:	9ce58593          	addi	a1,a1,-1586 # ffffffffc0206ed0 <default_pmm_manager+0xb18>
ffffffffc020450a:	00000517          	auipc	a0,0x0
ffffffffc020450e:	40650513          	addi	a0,a0,1030 # ffffffffc0204910 <init_main>
    current = idleproc;
ffffffffc0204512:	000a6417          	auipc	s0,0xa6
ffffffffc0204516:	32d43b23          	sd	a3,822(s0) # ffffffffc02aa848 <current>
    nr_process++;
ffffffffc020451a:	c31c                	sw	a5,0(a4)
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020451c:	f13ff0ef          	jal	ra,ffffffffc020442e <kernel_thread>
ffffffffc0204520:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204522:	08a05a63          	blez	a0,ffffffffc02045b6 <proc_init+0x138>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204526:	6789                	lui	a5,0x2
ffffffffc0204528:	fff5071b          	addiw	a4,a0,-1
ffffffffc020452c:	17f9                	addi	a5,a5,-2
ffffffffc020452e:	2501                	sext.w	a0,a0
ffffffffc0204530:	02e7e363          	bltu	a5,a4,ffffffffc0204556 <proc_init+0xd8>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204534:	45a9                	li	a1,10
ffffffffc0204536:	453000ef          	jal	ra,ffffffffc0205188 <hash32>
ffffffffc020453a:	02051793          	slli	a5,a0,0x20
ffffffffc020453e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204542:	96a6                	add	a3,a3,s1
ffffffffc0204544:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204546:	a029                	j	ffffffffc0204550 <proc_init+0xd2>
            if (proc->pid == pid)
ffffffffc0204548:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c94>
ffffffffc020454c:	02870563          	beq	a4,s0,ffffffffc0204576 <proc_init+0xf8>
    return listelm->next;
ffffffffc0204550:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204552:	fef69be3          	bne	a3,a5,ffffffffc0204548 <proc_init+0xca>
        panic("cannot find initproc.\n");
ffffffffc0204556:	00003617          	auipc	a2,0x3
ffffffffc020455a:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206f00 <default_pmm_manager+0xb48>
ffffffffc020455e:	09b00593          	li	a1,155
ffffffffc0204562:	00003517          	auipc	a0,0x3
ffffffffc0204566:	90e50513          	addi	a0,a0,-1778 # ffffffffc0206e70 <default_pmm_manager+0xab8>
    initproc = find_proc(pid);
ffffffffc020456a:	000a6797          	auipc	a5,0xa6
ffffffffc020456e:	2e07b723          	sd	zero,750(a5) # ffffffffc02aa858 <initproc>
        panic("cannot find initproc.\n");
ffffffffc0204572:	eddfb0ef          	jal	ra,ffffffffc020044e <__panic>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204576:	fdc78413          	addi	s0,a5,-36
ffffffffc020457a:	4641                	li	a2,16
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020457c:	f2878793          	addi	a5,a5,-216
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204580:	4581                	li	a1,0
ffffffffc0204582:	8522                	mv	a0,s0
    initproc = find_proc(pid);
ffffffffc0204584:	000a6717          	auipc	a4,0xa6
ffffffffc0204588:	2cf73a23          	sd	a5,724(a4) # ffffffffc02aa858 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020458c:	0a2010ef          	jal	ra,ffffffffc020562e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204590:	8522                	mv	a0,s0
ffffffffc0204592:	463d                	li	a2,15
ffffffffc0204594:	00003597          	auipc	a1,0x3
ffffffffc0204598:	98458593          	addi	a1,a1,-1660 # ffffffffc0206f18 <default_pmm_manager+0xb60>
ffffffffc020459c:	0a4010ef          	jal	ra,ffffffffc0205640 <memcpy>
}
ffffffffc02045a0:	6442                	ld	s0,16(sp)
ffffffffc02045a2:	60e2                	ld	ra,24(sp)
ffffffffc02045a4:	64a2                	ld	s1,8(sp)
ffffffffc02045a6:	6902                	ld	s2,0(sp)
    cprintf("proc_init() succeeded!\n");
ffffffffc02045a8:	00003517          	auipc	a0,0x3
ffffffffc02045ac:	97850513          	addi	a0,a0,-1672 # ffffffffc0206f20 <default_pmm_manager+0xb68>
}
ffffffffc02045b0:	6105                	addi	sp,sp,32
    cprintf("proc_init() succeeded!\n");
ffffffffc02045b2:	be3fb06f          	j	ffffffffc0200194 <cprintf>
        panic("create init_main failed.\n");
ffffffffc02045b6:	00003617          	auipc	a2,0x3
ffffffffc02045ba:	92a60613          	addi	a2,a2,-1750 # ffffffffc0206ee0 <default_pmm_manager+0xb28>
ffffffffc02045be:	09500593          	li	a1,149
ffffffffc02045c2:	00003517          	auipc	a0,0x3
ffffffffc02045c6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02045ca:	e85fb0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02045ce:	00003617          	auipc	a2,0x3
ffffffffc02045d2:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206eb0 <default_pmm_manager+0xaf8>
ffffffffc02045d6:	08600593          	li	a1,134
ffffffffc02045da:	00003517          	auipc	a0,0x3
ffffffffc02045de:	89650513          	addi	a0,a0,-1898 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02045e2:	e6dfb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc02045e6 <do_exit>:


//lab5 function4 YOUR CODE
// do_exit - 结束当前进程：释放用户地址空间，转为僵尸态并通知父进程。
int do_exit(int error_code)
{
ffffffffc02045e6:	7179                	addi	sp,sp,-48
ffffffffc02045e8:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02045ea:	000a6417          	auipc	s0,0xa6
ffffffffc02045ee:	25e40413          	addi	s0,s0,606 # ffffffffc02aa848 <current>
ffffffffc02045f2:	601c                	ld	a5,0(s0)
{
ffffffffc02045f4:	f406                	sd	ra,40(sp)
ffffffffc02045f6:	ec26                	sd	s1,24(sp)
ffffffffc02045f8:	e84a                	sd	s2,16(sp)
ffffffffc02045fa:	e44e                	sd	s3,8(sp)
ffffffffc02045fc:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc02045fe:	000a6717          	auipc	a4,0xa6
ffffffffc0204602:	25273703          	ld	a4,594(a4) # ffffffffc02aa850 <idleproc>
ffffffffc0204606:	0ee78363          	beq	a5,a4,ffffffffc02046ec <do_exit+0x106>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc020460a:	000a6497          	auipc	s1,0xa6
ffffffffc020460e:	24e48493          	addi	s1,s1,590 # ffffffffc02aa858 <initproc>
ffffffffc0204612:	6098                	ld	a4,0(s1)
ffffffffc0204614:	10e78263          	beq	a5,a4,ffffffffc0204718 <do_exit+0x132>
    {
        panic("initproc exit.\n");
    }

    struct mm_struct *mm = current->mm;
ffffffffc0204618:	0287b983          	ld	s3,40(a5)
ffffffffc020461c:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc020461e:	000a6a17          	auipc	s4,0xa6
ffffffffc0204622:	1f2a0a13          	addi	s4,s4,498 # ffffffffc02aa810 <boot_pgdir_pa>
ffffffffc0204626:	02098663          	beqz	s3,ffffffffc0204652 <do_exit+0x6c>
    {
        // 先切回内核页表，再销毁用户地址空间。
        write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc020462a:	000a3783          	ld	a5,0(s4)
ffffffffc020462e:	577d                	li	a4,-1
ffffffffc0204630:	177e                	slli	a4,a4,0x3f
ffffffffc0204632:	83b1                	srli	a5,a5,0xc
ffffffffc0204634:	8fd9                	or	a5,a5,a4
ffffffffc0204636:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma");
ffffffffc020463a:	12000073          	sfence.vma
    mm->mm_count -= 1;
ffffffffc020463e:	0309a783          	lw	a5,48(s3)
ffffffffc0204642:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204646:	02e9a823          	sw	a4,48(s3)
                            (boot_pgdir_pa >> RISCV_PGSHIFT));
        flush_tlb();
        if (mm_count_dec(mm) == 0)
ffffffffc020464a:	cf4d                	beqz	a4,ffffffffc0204704 <do_exit+0x11e>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc020464c:	601c                	ld	a5,0(s0)
ffffffffc020464e:	0207b423          	sd	zero,40(a5)
    }
    current->pgdir = boot_pgdir_pa;
ffffffffc0204652:	601c                	ld	a5,0(s0)
ffffffffc0204654:	000a3703          	ld	a4,0(s4)
    current->state = PROC_ZOMBIE;
ffffffffc0204658:	468d                	li	a3,3
ffffffffc020465a:	c394                	sw	a3,0(a5)
    current->pgdir = boot_pgdir_pa;
ffffffffc020465c:	f7d8                	sd	a4,168(a5)
    current->exit_code = error_code;
ffffffffc020465e:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204662:	100027f3          	csrr	a5,sstatus
ffffffffc0204666:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204668:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020466a:	e3f9                	bnez	a5,ffffffffc0204730 <do_exit+0x14a>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        // 唤醒正在等待子进程的父进程。
        proc = current->parent;
ffffffffc020466c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc020466e:	800007b7          	lui	a5,0x80000
ffffffffc0204672:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204674:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204676:	0ec52703          	lw	a4,236(a0)
ffffffffc020467a:	0af70f63          	beq	a4,a5,ffffffffc0204738 <do_exit+0x152>
        {
            wakeup_proc(proc);
        }
        // 把当前进程的子进程过继给 initproc，避免进程树出现无人管理的分支。
        while (current->cptr != NULL)
ffffffffc020467e:	601c                	ld	a5,0(s0)
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204680:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204684:	490d                	li	s2,3
        while (current->cptr != NULL)
ffffffffc0204686:	7bfc                	ld	a5,240(a5)
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204688:	0985                	addi	s3,s3,1
        while (current->cptr != NULL)
ffffffffc020468a:	e789                	bnez	a5,ffffffffc0204694 <do_exit+0xae>
ffffffffc020468c:	a81d                	j	ffffffffc02046c2 <do_exit+0xdc>
ffffffffc020468e:	601c                	ld	a5,0(s0)
ffffffffc0204690:	7bfc                	ld	a5,240(a5)
ffffffffc0204692:	cb85                	beqz	a5,ffffffffc02046c2 <do_exit+0xdc>
            proc->cptr = proc->optr;
ffffffffc0204694:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd0>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204698:	6088                	ld	a0,0(s1)
            proc->yptr = NULL;
ffffffffc020469a:	0e07bc23          	sd	zero,248(a5)
            proc->cptr = proc->optr;
ffffffffc020469e:	fbf8                	sd	a4,240(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02046a0:	7978                	ld	a4,240(a0)
ffffffffc02046a2:	10e7b023          	sd	a4,256(a5)
ffffffffc02046a6:	c311                	beqz	a4,ffffffffc02046aa <do_exit+0xc4>
                initproc->cptr->yptr = proc;
ffffffffc02046a8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046aa:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02046ac:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02046ae:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046b0:	fd271fe3          	bne	a4,s2,ffffffffc020468e <do_exit+0xa8>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02046b4:	0ec52783          	lw	a5,236(a0)
ffffffffc02046b8:	fd379be3          	bne	a5,s3,ffffffffc020468e <do_exit+0xa8>
                {
                    wakeup_proc(initproc);
ffffffffc02046bc:	113000ef          	jal	ra,ffffffffc0204fce <wakeup_proc>
ffffffffc02046c0:	b7f9                	j	ffffffffc020468e <do_exit+0xa8>
    if (flag)
ffffffffc02046c2:	020a1263          	bnez	s4,ffffffffc02046e6 <do_exit+0x100>
            }
        }
    }
    local_intr_restore(intr_flag);

    schedule();
ffffffffc02046c6:	189000ef          	jal	ra,ffffffffc020504e <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02046ca:	601c                	ld	a5,0(s0)
ffffffffc02046cc:	00003617          	auipc	a2,0x3
ffffffffc02046d0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0206f58 <default_pmm_manager+0xba0>
ffffffffc02046d4:	23500593          	li	a1,565
ffffffffc02046d8:	43d4                	lw	a3,4(a5)
ffffffffc02046da:	00002517          	auipc	a0,0x2
ffffffffc02046de:	79650513          	addi	a0,a0,1942 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02046e2:	d6dfb0ef          	jal	ra,ffffffffc020044e <__panic>
        intr_enable();
ffffffffc02046e6:	a88fc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02046ea:	bff1                	j	ffffffffc02046c6 <do_exit+0xe0>
        panic("idleproc exit.\n");
ffffffffc02046ec:	00003617          	auipc	a2,0x3
ffffffffc02046f0:	84c60613          	addi	a2,a2,-1972 # ffffffffc0206f38 <default_pmm_manager+0xb80>
ffffffffc02046f4:	1f800593          	li	a1,504
ffffffffc02046f8:	00002517          	auipc	a0,0x2
ffffffffc02046fc:	77850513          	addi	a0,a0,1912 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204700:	d4ffb0ef          	jal	ra,ffffffffc020044e <__panic>
            exit_mmap(mm);
ffffffffc0204704:	854e                	mv	a0,s3
ffffffffc0204706:	bc2ff0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
            put_pgdir(mm);
ffffffffc020470a:	854e                	mv	a0,s3
ffffffffc020470c:	86bff0ef          	jal	ra,ffffffffc0203f76 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204710:	854e                	mv	a0,s3
ffffffffc0204712:	a1aff0ef          	jal	ra,ffffffffc020392c <mm_destroy>
ffffffffc0204716:	bf1d                	j	ffffffffc020464c <do_exit+0x66>
        panic("initproc exit.\n");
ffffffffc0204718:	00003617          	auipc	a2,0x3
ffffffffc020471c:	83060613          	addi	a2,a2,-2000 # ffffffffc0206f48 <default_pmm_manager+0xb90>
ffffffffc0204720:	1fc00593          	li	a1,508
ffffffffc0204724:	00002517          	auipc	a0,0x2
ffffffffc0204728:	74c50513          	addi	a0,a0,1868 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc020472c:	d23fb0ef          	jal	ra,ffffffffc020044e <__panic>
        intr_disable();
ffffffffc0204730:	a44fc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc0204734:	4a05                	li	s4,1
ffffffffc0204736:	bf1d                	j	ffffffffc020466c <do_exit+0x86>
            wakeup_proc(proc);
ffffffffc0204738:	097000ef          	jal	ra,ffffffffc0204fce <wakeup_proc>
ffffffffc020473c:	b789                	j	ffffffffc020467e <do_exit+0x98>

ffffffffc020473e <do_wait.part.0>:
#endif
    panic("user_main execve failed.\n");
}

// do_wait - 等待指定子进程（pid 为 0 时等待任一子进程）并回收其资源。
int do_wait(int pid, int *code_store)
ffffffffc020473e:	715d                	addi	sp,sp,-80
ffffffffc0204740:	f84a                	sd	s2,48(sp)
ffffffffc0204742:	f44e                	sd	s3,40(sp)

    if (haskid)
    {
        // 有子进程但尚未退出：睡眠等待，被唤醒后重新检查。
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc0204744:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc0204748:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc020474a:	fc26                	sd	s1,56(sp)
ffffffffc020474c:	f052                	sd	s4,32(sp)
ffffffffc020474e:	ec56                	sd	s5,24(sp)
ffffffffc0204750:	e85a                	sd	s6,16(sp)
ffffffffc0204752:	e45e                	sd	s7,8(sp)
ffffffffc0204754:	e486                	sd	ra,72(sp)
ffffffffc0204756:	e0a2                	sd	s0,64(sp)
ffffffffc0204758:	84aa                	mv	s1,a0
ffffffffc020475a:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc020475c:	000a6b97          	auipc	s7,0xa6
ffffffffc0204760:	0ecb8b93          	addi	s7,s7,236 # ffffffffc02aa848 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204764:	00050b1b          	sext.w	s6,a0
ffffffffc0204768:	fff50a9b          	addiw	s5,a0,-1
ffffffffc020476c:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc020476e:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204770:	ccbd                	beqz	s1,ffffffffc02047ee <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204772:	0359e863          	bltu	s3,s5,ffffffffc02047a2 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204776:	45a9                	li	a1,10
ffffffffc0204778:	855a                	mv	a0,s6
ffffffffc020477a:	20f000ef          	jal	ra,ffffffffc0205188 <hash32>
ffffffffc020477e:	02051793          	slli	a5,a0,0x20
ffffffffc0204782:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204786:	000a2797          	auipc	a5,0xa2
ffffffffc020478a:	04a78793          	addi	a5,a5,74 # ffffffffc02a67d0 <hash_list>
ffffffffc020478e:	953e                	add	a0,a0,a5
ffffffffc0204790:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204792:	a029                	j	ffffffffc020479c <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204794:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204798:	02978163          	beq	a5,s1,ffffffffc02047ba <do_wait.part.0+0x7c>
ffffffffc020479c:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc020479e:	fe851be3          	bne	a0,s0,ffffffffc0204794 <do_wait.part.0+0x56>
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;
ffffffffc02047a2:	5579                	li	a0,-2
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc02047a4:	60a6                	ld	ra,72(sp)
ffffffffc02047a6:	6406                	ld	s0,64(sp)
ffffffffc02047a8:	74e2                	ld	s1,56(sp)
ffffffffc02047aa:	7942                	ld	s2,48(sp)
ffffffffc02047ac:	79a2                	ld	s3,40(sp)
ffffffffc02047ae:	7a02                	ld	s4,32(sp)
ffffffffc02047b0:	6ae2                	ld	s5,24(sp)
ffffffffc02047b2:	6b42                	ld	s6,16(sp)
ffffffffc02047b4:	6ba2                	ld	s7,8(sp)
ffffffffc02047b6:	6161                	addi	sp,sp,80
ffffffffc02047b8:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02047ba:	000bb683          	ld	a3,0(s7)
ffffffffc02047be:	f4843783          	ld	a5,-184(s0)
ffffffffc02047c2:	fed790e3          	bne	a5,a3,ffffffffc02047a2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047c6:	f2842703          	lw	a4,-216(s0)
ffffffffc02047ca:	478d                	li	a5,3
ffffffffc02047cc:	0ef70b63          	beq	a4,a5,ffffffffc02048c2 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02047d0:	4785                	li	a5,1
ffffffffc02047d2:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02047d4:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02047d8:	077000ef          	jal	ra,ffffffffc020504e <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02047dc:	000bb783          	ld	a5,0(s7)
ffffffffc02047e0:	0b07a783          	lw	a5,176(a5)
ffffffffc02047e4:	8b85                	andi	a5,a5,1
ffffffffc02047e6:	d7c9                	beqz	a5,ffffffffc0204770 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02047e8:	555d                	li	a0,-9
ffffffffc02047ea:	dfdff0ef          	jal	ra,ffffffffc02045e6 <do_exit>
        proc = current->cptr;
ffffffffc02047ee:	000bb683          	ld	a3,0(s7)
ffffffffc02047f2:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02047f4:	d45d                	beqz	s0,ffffffffc02047a2 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047f6:	470d                	li	a4,3
ffffffffc02047f8:	a021                	j	ffffffffc0204800 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02047fa:	10043403          	ld	s0,256(s0)
ffffffffc02047fe:	d869                	beqz	s0,ffffffffc02047d0 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204800:	401c                	lw	a5,0(s0)
ffffffffc0204802:	fee79ce3          	bne	a5,a4,ffffffffc02047fa <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204806:	000a6797          	auipc	a5,0xa6
ffffffffc020480a:	04a7b783          	ld	a5,74(a5) # ffffffffc02aa850 <idleproc>
ffffffffc020480e:	0c878963          	beq	a5,s0,ffffffffc02048e0 <do_wait.part.0+0x1a2>
ffffffffc0204812:	000a6797          	auipc	a5,0xa6
ffffffffc0204816:	0467b783          	ld	a5,70(a5) # ffffffffc02aa858 <initproc>
ffffffffc020481a:	0cf40363          	beq	s0,a5,ffffffffc02048e0 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc020481e:	000a0663          	beqz	s4,ffffffffc020482a <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204822:	0e842783          	lw	a5,232(s0)
ffffffffc0204826:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020482a:	100027f3          	csrr	a5,sstatus
ffffffffc020482e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204830:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204832:	e7c1                	bnez	a5,ffffffffc02048ba <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204834:	6c70                	ld	a2,216(s0)
ffffffffc0204836:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc0204838:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020483c:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020483e:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204840:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204842:	6470                	ld	a2,200(s0)
ffffffffc0204844:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204846:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204848:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc020484a:	c319                	beqz	a4,ffffffffc0204850 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc020484c:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc020484e:	7c7c                	ld	a5,248(s0)
ffffffffc0204850:	c3b5                	beqz	a5,ffffffffc02048b4 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204852:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc0204856:	000a6717          	auipc	a4,0xa6
ffffffffc020485a:	00a70713          	addi	a4,a4,10 # ffffffffc02aa860 <nr_process>
ffffffffc020485e:	431c                	lw	a5,0(a4)
ffffffffc0204860:	37fd                	addiw	a5,a5,-1
ffffffffc0204862:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc0204864:	e5a9                	bnez	a1,ffffffffc02048ae <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204866:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204868:	c02007b7          	lui	a5,0xc0200
ffffffffc020486c:	04f6ee63          	bltu	a3,a5,ffffffffc02048c8 <do_wait.part.0+0x18a>
ffffffffc0204870:	000a6797          	auipc	a5,0xa6
ffffffffc0204874:	fd07b783          	ld	a5,-48(a5) # ffffffffc02aa840 <va_pa_offset>
ffffffffc0204878:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020487a:	82b1                	srli	a3,a3,0xc
ffffffffc020487c:	000a6797          	auipc	a5,0xa6
ffffffffc0204880:	fa47b783          	ld	a5,-92(a5) # ffffffffc02aa820 <npage>
ffffffffc0204884:	06f6fa63          	bgeu	a3,a5,ffffffffc02048f8 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204888:	00003517          	auipc	a0,0x3
ffffffffc020488c:	c6853503          	ld	a0,-920(a0) # ffffffffc02074f0 <nbase>
ffffffffc0204890:	8e89                	sub	a3,a3,a0
ffffffffc0204892:	069a                	slli	a3,a3,0x6
ffffffffc0204894:	000a6517          	auipc	a0,0xa6
ffffffffc0204898:	f9453503          	ld	a0,-108(a0) # ffffffffc02aa828 <pages>
ffffffffc020489c:	9536                	add	a0,a0,a3
ffffffffc020489e:	4589                	li	a1,2
ffffffffc02048a0:	cdcfd0ef          	jal	ra,ffffffffc0201d7c <free_pages>
    kfree(proc);
ffffffffc02048a4:	8522                	mv	a0,s0
ffffffffc02048a6:	b6afd0ef          	jal	ra,ffffffffc0201c10 <kfree>
    return 0;
ffffffffc02048aa:	4501                	li	a0,0
ffffffffc02048ac:	bde5                	j	ffffffffc02047a4 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02048ae:	8c0fc0ef          	jal	ra,ffffffffc020096e <intr_enable>
ffffffffc02048b2:	bf55                	j	ffffffffc0204866 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc02048b4:	701c                	ld	a5,32(s0)
ffffffffc02048b6:	fbf8                	sd	a4,240(a5)
ffffffffc02048b8:	bf79                	j	ffffffffc0204856 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02048ba:	8bafc0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc02048be:	4585                	li	a1,1
ffffffffc02048c0:	bf95                	j	ffffffffc0204834 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02048c2:	f2840413          	addi	s0,s0,-216
ffffffffc02048c6:	b781                	j	ffffffffc0204806 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02048c8:	00002617          	auipc	a2,0x2
ffffffffc02048cc:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc02048d0:	07700593          	li	a1,119
ffffffffc02048d4:	00002517          	auipc	a0,0x2
ffffffffc02048d8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc02048dc:	b73fb0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02048e0:	00002617          	auipc	a2,0x2
ffffffffc02048e4:	69860613          	addi	a2,a2,1688 # ffffffffc0206f78 <default_pmm_manager+0xbc0>
ffffffffc02048e8:	37b00593          	li	a1,891
ffffffffc02048ec:	00002517          	auipc	a0,0x2
ffffffffc02048f0:	58450513          	addi	a0,a0,1412 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc02048f4:	b5bfb0ef          	jal	ra,ffffffffc020044e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048f8:	00002617          	auipc	a2,0x2
ffffffffc02048fc:	bc860613          	addi	a2,a2,-1080 # ffffffffc02064c0 <default_pmm_manager+0x108>
ffffffffc0204900:	06900593          	li	a1,105
ffffffffc0204904:	00002517          	auipc	a0,0x2
ffffffffc0204908:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc020490c:	b43fb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204910 <init_main>:

// init_main - 启动用户进程，并在其退出后完成启动阶段收尾。
static int
init_main(void *arg)
{
ffffffffc0204910:	1141                	addi	sp,sp,-16
    int pid;
    if ((pid = kernel_thread(user_main, NULL, 0)) <= 0)
ffffffffc0204912:	4601                	li	a2,0
ffffffffc0204914:	4581                	li	a1,0
ffffffffc0204916:	00000517          	auipc	a0,0x0
ffffffffc020491a:	51850513          	addi	a0,a0,1304 # ffffffffc0204e2e <user_main>
{
ffffffffc020491e:	e406                	sd	ra,8(sp)
    if ((pid = kernel_thread(user_main, NULL, 0)) <= 0)
ffffffffc0204920:	b0fff0ef          	jal	ra,ffffffffc020442e <kernel_thread>
ffffffffc0204924:	00a04563          	bgtz	a0,ffffffffc020492e <init_main+0x1e>
ffffffffc0204928:	a805                	j	ffffffffc0204958 <init_main+0x48>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc020492a:	724000ef          	jal	ra,ffffffffc020504e <schedule>
    if (code_store != NULL)
ffffffffc020492e:	4581                	li	a1,0
ffffffffc0204930:	4501                	li	a0,0
ffffffffc0204932:	e0dff0ef          	jal	ra,ffffffffc020473e <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204936:	d975                	beqz	a0,ffffffffc020492a <init_main+0x1a>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204938:	00002517          	auipc	a0,0x2
ffffffffc020493c:	68050513          	addi	a0,a0,1664 # ffffffffc0206fb8 <default_pmm_manager+0xc00>
ffffffffc0204940:	855fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    // init check memory pass
    cprintf("init check memory pass.\n");
ffffffffc0204944:	00002517          	auipc	a0,0x2
ffffffffc0204948:	69c50513          	addi	a0,a0,1692 # ffffffffc0206fe0 <default_pmm_manager+0xc28>
ffffffffc020494c:	849fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0204950:	60a2                	ld	ra,8(sp)
ffffffffc0204952:	4501                	li	a0,0
ffffffffc0204954:	0141                	addi	sp,sp,16
ffffffffc0204956:	8082                	ret
        panic("create user_main failed.\n");
ffffffffc0204958:	00002617          	auipc	a2,0x2
ffffffffc020495c:	64060613          	addi	a2,a2,1600 # ffffffffc0206f98 <default_pmm_manager+0xbe0>
ffffffffc0204960:	39300593          	li	a1,915
ffffffffc0204964:	00002517          	auipc	a0,0x2
ffffffffc0204968:	50c50513          	addi	a0,a0,1292 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc020496c:	ae3fb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204970 <do_yield>:
    current->need_resched = 1;
ffffffffc0204970:	000a6797          	auipc	a5,0xa6
ffffffffc0204974:	ed87b783          	ld	a5,-296(a5) # ffffffffc02aa848 <current>
ffffffffc0204978:	4705                	li	a4,1
ffffffffc020497a:	ef98                	sd	a4,24(a5)
}
ffffffffc020497c:	4501                	li	a0,0
ffffffffc020497e:	8082                	ret

ffffffffc0204980 <do_kill>:
{
ffffffffc0204980:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204982:	6789                	lui	a5,0x2
{
ffffffffc0204984:	e406                	sd	ra,8(sp)
ffffffffc0204986:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204988:	fff5071b          	addiw	a4,a0,-1
ffffffffc020498c:	17f9                	addi	a5,a5,-2
ffffffffc020498e:	02e7e963          	bltu	a5,a4,ffffffffc02049c0 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204992:	842a                	mv	s0,a0
ffffffffc0204994:	45a9                	li	a1,10
ffffffffc0204996:	2501                	sext.w	a0,a0
ffffffffc0204998:	7f0000ef          	jal	ra,ffffffffc0205188 <hash32>
ffffffffc020499c:	02051793          	slli	a5,a0,0x20
ffffffffc02049a0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02049a4:	000a2797          	auipc	a5,0xa2
ffffffffc02049a8:	e2c78793          	addi	a5,a5,-468 # ffffffffc02a67d0 <hash_list>
ffffffffc02049ac:	953e                	add	a0,a0,a5
ffffffffc02049ae:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc02049b0:	a029                	j	ffffffffc02049ba <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc02049b2:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02049b6:	00870b63          	beq	a4,s0,ffffffffc02049cc <do_kill+0x4c>
    return listelm->next;
ffffffffc02049ba:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02049bc:	fef51be3          	bne	a0,a5,ffffffffc02049b2 <do_kill+0x32>
    return -E_INVAL;
ffffffffc02049c0:	5475                	li	s0,-3
}
ffffffffc02049c2:	60a2                	ld	ra,8(sp)
ffffffffc02049c4:	8522                	mv	a0,s0
ffffffffc02049c6:	6402                	ld	s0,0(sp)
ffffffffc02049c8:	0141                	addi	sp,sp,16
ffffffffc02049ca:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc02049cc:	fd87a703          	lw	a4,-40(a5)
ffffffffc02049d0:	00177693          	andi	a3,a4,1
ffffffffc02049d4:	e295                	bnez	a3,ffffffffc02049f8 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02049d6:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc02049d8:	00176713          	ori	a4,a4,1
ffffffffc02049dc:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc02049e0:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc02049e2:	fe06d0e3          	bgez	a3,ffffffffc02049c2 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc02049e6:	f2878513          	addi	a0,a5,-216
ffffffffc02049ea:	5e4000ef          	jal	ra,ffffffffc0204fce <wakeup_proc>
}
ffffffffc02049ee:	60a2                	ld	ra,8(sp)
ffffffffc02049f0:	8522                	mv	a0,s0
ffffffffc02049f2:	6402                	ld	s0,0(sp)
ffffffffc02049f4:	0141                	addi	sp,sp,16
ffffffffc02049f6:	8082                	ret
        return -E_KILLED;
ffffffffc02049f8:	545d                	li	s0,-9
ffffffffc02049fa:	b7e1                	j	ffffffffc02049c2 <do_kill+0x42>

ffffffffc02049fc <do_execve>:
    struct mm_struct *mm = current->mm;
ffffffffc02049fc:	000a6797          	auipc	a5,0xa6
ffffffffc0204a00:	e4c78793          	addi	a5,a5,-436 # ffffffffc02aa848 <current>
ffffffffc0204a04:	639c                	ld	a5,0(a5)
{
ffffffffc0204a06:	7175                	addi	sp,sp,-144
ffffffffc0204a08:	fca6                	sd	s1,120(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a0a:	7784                	ld	s1,40(a5)
{
ffffffffc0204a0c:	e122                	sd	s0,128(sp)
ffffffffc0204a0e:	f8ca                	sd	s2,112(sp)
ffffffffc0204a10:	f46e                	sd	s11,40(sp)
ffffffffc0204a12:	892a                	mv	s2,a0
ffffffffc0204a14:	8db2                	mv	s11,a2
ffffffffc0204a16:	842e                	mv	s0,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a18:	862e                	mv	a2,a1
ffffffffc0204a1a:	4681                	li	a3,0
ffffffffc0204a1c:	85aa                	mv	a1,a0
ffffffffc0204a1e:	8526                	mv	a0,s1
{
ffffffffc0204a20:	e506                	sd	ra,136(sp)
ffffffffc0204a22:	f4ce                	sd	s3,104(sp)
ffffffffc0204a24:	f0d2                	sd	s4,96(sp)
ffffffffc0204a26:	ecd6                	sd	s5,88(sp)
ffffffffc0204a28:	e8da                	sd	s6,80(sp)
ffffffffc0204a2a:	e4de                	sd	s7,72(sp)
ffffffffc0204a2c:	e0e2                	sd	s8,64(sp)
ffffffffc0204a2e:	fc66                	sd	s9,56(sp)
ffffffffc0204a30:	f86a                	sd	s10,48(sp)
ffffffffc0204a32:	e46e                	sd	s11,8(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a34:	c2eff0ef          	jal	ra,ffffffffc0203e62 <user_mem_check>
ffffffffc0204a38:	30050363          	beqz	a0,ffffffffc0204d3e <do_execve+0x342>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204a3c:	4641                	li	a2,16
ffffffffc0204a3e:	4581                	li	a1,0
ffffffffc0204a40:	0808                	addi	a0,sp,16
ffffffffc0204a42:	3ed000ef          	jal	ra,ffffffffc020562e <memset>
    memcpy(local_name, name, len);
ffffffffc0204a46:	47bd                	li	a5,15
ffffffffc0204a48:	8622                	mv	a2,s0
ffffffffc0204a4a:	2087e463          	bltu	a5,s0,ffffffffc0204c52 <do_execve+0x256>
ffffffffc0204a4e:	85ca                	mv	a1,s2
ffffffffc0204a50:	0808                	addi	a0,sp,16
ffffffffc0204a52:	3ef000ef          	jal	ra,ffffffffc0205640 <memcpy>
    if (mm != NULL)
ffffffffc0204a56:	20048563          	beqz	s1,ffffffffc0204c60 <do_execve+0x264>
        write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc0204a5a:	000a6797          	auipc	a5,0xa6
ffffffffc0204a5e:	db67b783          	ld	a5,-586(a5) # ffffffffc02aa810 <boot_pgdir_pa>
ffffffffc0204a62:	577d                	li	a4,-1
ffffffffc0204a64:	177e                	slli	a4,a4,0x3f
ffffffffc0204a66:	83b1                	srli	a5,a5,0xc
ffffffffc0204a68:	8fd9                	or	a5,a5,a4
ffffffffc0204a6a:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma");
ffffffffc0204a6e:	12000073          	sfence.vma
ffffffffc0204a72:	589c                	lw	a5,48(s1)
ffffffffc0204a74:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204a78:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a7a:	22070963          	beqz	a4,ffffffffc0204cac <do_execve+0x2b0>
        current->mm = NULL;
ffffffffc0204a7e:	000a6797          	auipc	a5,0xa6
ffffffffc0204a82:	dca78793          	addi	a5,a5,-566 # ffffffffc02aa848 <current>
ffffffffc0204a86:	639c                	ld	a5,0(a5)
ffffffffc0204a88:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a8c:	d61fe0ef          	jal	ra,ffffffffc02037ec <mm_create>
ffffffffc0204a90:	84aa                	mv	s1,a0
ffffffffc0204a92:	34050363          	beqz	a0,ffffffffc0204dd8 <do_execve+0x3dc>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a96:	4505                	li	a0,1
ffffffffc0204a98:	aa6fd0ef          	jal	ra,ffffffffc0201d3e <alloc_pages>
ffffffffc0204a9c:	32050c63          	beqz	a0,ffffffffc0204dd4 <do_execve+0x3d8>
    return page - pages + nbase;
ffffffffc0204aa0:	000a6b97          	auipc	s7,0xa6
ffffffffc0204aa4:	d88b8b93          	addi	s7,s7,-632 # ffffffffc02aa828 <pages>
ffffffffc0204aa8:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204aac:	000a6c17          	auipc	s8,0xa6
ffffffffc0204ab0:	d74c0c13          	addi	s8,s8,-652 # ffffffffc02aa820 <npage>
    return page - pages + nbase;
ffffffffc0204ab4:	00003b17          	auipc	s6,0x3
ffffffffc0204ab8:	a3cb3b03          	ld	s6,-1476(s6) # ffffffffc02074f0 <nbase>
ffffffffc0204abc:	40d506b3          	sub	a3,a0,a3
ffffffffc0204ac0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ac2:	5a7d                	li	s4,-1
ffffffffc0204ac4:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204ac8:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204aca:	00ca5a13          	srli	s4,s4,0xc
ffffffffc0204ace:	0146f733          	and	a4,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ad4:	30f77563          	bgeu	a4,a5,ffffffffc0204dde <do_execve+0x3e2>
ffffffffc0204ad8:	000a6a97          	auipc	s5,0xa6
ffffffffc0204adc:	d68a8a93          	addi	s5,s5,-664 # ffffffffc02aa840 <va_pa_offset>
ffffffffc0204ae0:	000ab403          	ld	s0,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204ae4:	6605                	lui	a2,0x1
ffffffffc0204ae6:	000a6597          	auipc	a1,0xa6
ffffffffc0204aea:	d325b583          	ld	a1,-718(a1) # ffffffffc02aa818 <boot_pgdir_va>
ffffffffc0204aee:	9436                	add	s0,s0,a3
ffffffffc0204af0:	8522                	mv	a0,s0
ffffffffc0204af2:	34f000ef          	jal	ra,ffffffffc0205640 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204af6:	66a2                	ld	a3,8(sp)
ffffffffc0204af8:	464c47b7          	lui	a5,0x464c4
ffffffffc0204afc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b944f>
ffffffffc0204b00:	4298                	lw	a4,0(a3)
    mm->pgdir = pgdir;
ffffffffc0204b02:	ec80                	sd	s0,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204b04:	18f71263          	bne	a4,a5,ffffffffc0204c88 <do_execve+0x28c>
    for (int i = 0; i < elf->e_phnum; i++, ph++)
ffffffffc0204b08:	0386d783          	lhu	a5,56(a3)
ffffffffc0204b0c:	873e                	mv	a4,a5
ffffffffc0204b0e:	1a078963          	beqz	a5,ffffffffc0204cc0 <do_execve+0x2c4>
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b12:	67a2                	ld	a5,8(sp)
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
ffffffffc0204b14:	6905                	lui	s2,0x1
    for (int i = 0; i < elf->e_phnum; i++, ph++)
ffffffffc0204b16:	e002                	sd	zero,0(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b18:	0207b983          	ld	s3,32(a5)
ffffffffc0204b1c:	99be                	add	s3,s3,a5
ffffffffc0204b1e:	a819                	j	ffffffffc0204b34 <do_execve+0x138>
    for (int i = 0; i < elf->e_phnum; i++, ph++)
ffffffffc0204b20:	6782                	ld	a5,0(sp)
ffffffffc0204b22:	03898993          	addi	s3,s3,56 # 2038 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0204b26:	0017869b          	addiw	a3,a5,1
ffffffffc0204b2a:	e036                	sd	a3,0(sp)
ffffffffc0204b2c:	0007079b          	sext.w	a5,a4
ffffffffc0204b30:	18f6d863          	bge	a3,a5,ffffffffc0204cc0 <do_execve+0x2c4>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204b34:	0009a783          	lw	a5,0(s3)
ffffffffc0204b38:	4685                	li	a3,1
ffffffffc0204b3a:	fed793e3          	bne	a5,a3,ffffffffc0204b20 <do_execve+0x124>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204b3e:	0289b603          	ld	a2,40(s3)
ffffffffc0204b42:	0209b783          	ld	a5,32(s3)
ffffffffc0204b46:	1ef66a63          	bltu	a2,a5,ffffffffc0204d3a <do_execve+0x33e>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204b4a:	0049a783          	lw	a5,4(s3)
ffffffffc0204b4e:	0017f693          	andi	a3,a5,1
ffffffffc0204b52:	c291                	beqz	a3,ffffffffc0204b56 <do_execve+0x15a>
            vm_flags |= VM_EXEC;
ffffffffc0204b54:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b56:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b5a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204b5c:	14070063          	beqz	a4,ffffffffc0204c9c <do_execve+0x2a0>
            vm_flags |= VM_WRITE;
ffffffffc0204b60:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204b64:	12079d63          	bnez	a5,ffffffffc0204c9e <do_execve+0x2a2>
            vm_flags |= VM_READ;
ffffffffc0204b68:	0016e693          	ori	a3,a3,1
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204b6c:	0109b583          	ld	a1,16(s3)
ffffffffc0204b70:	4701                	li	a4,0
ffffffffc0204b72:	8526                	mv	a0,s1
ffffffffc0204b74:	e0bfe0ef          	jal	ra,ffffffffc020397e <mm_map>
ffffffffc0204b78:	842a                	mv	s0,a0
ffffffffc0204b7a:	1a051663          	bnez	a0,ffffffffc0204d26 <do_execve+0x32a>
        uintptr_t seg_end = ph->p_va + ph->p_memsz;
ffffffffc0204b7e:	0109bd03          	ld	s10,16(s3)
ffffffffc0204b82:	0289b403          	ld	s0,40(s3)
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
ffffffffc0204b86:	77fd                	lui	a5,0xfffff
ffffffffc0204b88:	00fd7db3          	and	s11,s10,a5
        uintptr_t seg_end = ph->p_va + ph->p_memsz;
ffffffffc0204b8c:	946a                	add	s0,s0,s10
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
ffffffffc0204b8e:	008de663          	bltu	s11,s0,ffffffffc0204b9a <do_execve+0x19e>
ffffffffc0204b92:	a889                	j	ffffffffc0204be4 <do_execve+0x1e8>
ffffffffc0204b94:	9dca                	add	s11,s11,s2
ffffffffc0204b96:	048df563          	bgeu	s11,s0,ffffffffc0204be0 <do_execve+0x1e4>
            if (get_page(mm->pgdir, va, NULL) == NULL)
ffffffffc0204b9a:	6c88                	ld	a0,24(s1)
ffffffffc0204b9c:	4601                	li	a2,0
ffffffffc0204b9e:	85ee                	mv	a1,s11
ffffffffc0204ba0:	c7efd0ef          	jal	ra,ffffffffc020201e <get_page>
ffffffffc0204ba4:	f965                	bnez	a0,ffffffffc0204b94 <do_execve+0x198>
                struct Page *page = pgdir_alloc_page(mm->pgdir, va,
ffffffffc0204ba6:	6c88                	ld	a0,24(s1)
ffffffffc0204ba8:	4679                	li	a2,30
ffffffffc0204baa:	85ee                	mv	a1,s11
ffffffffc0204bac:	97ffe0ef          	jal	ra,ffffffffc020352a <pgdir_alloc_page>
                if (page == NULL)
ffffffffc0204bb0:	16050a63          	beqz	a0,ffffffffc0204d24 <do_execve+0x328>
    return page - pages + nbase;
ffffffffc0204bb4:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204bb8:	000c3703          	ld	a4,0(s8)
    return page - pages + nbase;
ffffffffc0204bbc:	8d15                	sub	a0,a0,a3
ffffffffc0204bbe:	8519                	srai	a0,a0,0x6
ffffffffc0204bc0:	955a                	add	a0,a0,s6
    return KADDR(page2pa(page));
ffffffffc0204bc2:	014576b3          	and	a3,a0,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bc6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0204bc8:	20e6fa63          	bgeu	a3,a4,ffffffffc0204ddc <do_execve+0x3e0>
ffffffffc0204bcc:	000ab703          	ld	a4,0(s5)
                memset(page2kva(page), 0, PGSIZE);
ffffffffc0204bd0:	6605                	lui	a2,0x1
ffffffffc0204bd2:	4581                	li	a1,0
ffffffffc0204bd4:	953a                	add	a0,a0,a4
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
ffffffffc0204bd6:	9dca                	add	s11,s11,s2
                memset(page2kva(page), 0, PGSIZE);
ffffffffc0204bd8:	257000ef          	jal	ra,ffffffffc020562e <memset>
        for (uintptr_t va = ROUNDDOWN(ph->p_va, PGSIZE); va < seg_end; va += PGSIZE)
ffffffffc0204bdc:	fa8defe3          	bltu	s11,s0,ffffffffc0204b9a <do_execve+0x19e>
        uintptr_t dst = ph->p_va;
ffffffffc0204be0:	0109bd03          	ld	s10,16(s3)
        uintptr_t src = (uintptr_t)binary + ph->p_offset;
ffffffffc0204be4:	0089b403          	ld	s0,8(s3)
ffffffffc0204be8:	67a2                	ld	a5,8(sp)
        size_t left = ph->p_filesz;
ffffffffc0204bea:	0209bd83          	ld	s11,32(s3)
        uintptr_t src = (uintptr_t)binary + ph->p_offset;
ffffffffc0204bee:	943e                	add	s0,s0,a5
        while (left > 0)
ffffffffc0204bf0:	040d8e63          	beqz	s11,ffffffffc0204c4c <do_execve+0x250>
            struct Page *page = get_page(mm->pgdir, dst, NULL);
ffffffffc0204bf4:	6c88                	ld	a0,24(s1)
ffffffffc0204bf6:	4601                	li	a2,0
ffffffffc0204bf8:	85ea                	mv	a1,s10
ffffffffc0204bfa:	c24fd0ef          	jal	ra,ffffffffc020201e <get_page>
            assert(page != NULL);
ffffffffc0204bfe:	1e050c63          	beqz	a0,ffffffffc0204df6 <do_execve+0x3fa>
            size_t off = dst % PGSIZE;
ffffffffc0204c02:	6785                	lui	a5,0x1
ffffffffc0204c04:	17fd                	addi	a5,a5,-1
ffffffffc0204c06:	00fd77b3          	and	a5,s10,a5
            size_t n = (PGSIZE - off) < left ? (PGSIZE - off) : left;
ffffffffc0204c0a:	40f90cb3          	sub	s9,s2,a5
ffffffffc0204c0e:	019df363          	bgeu	s11,s9,ffffffffc0204c14 <do_execve+0x218>
ffffffffc0204c12:	8cee                	mv	s9,s11
    return page - pages + nbase;
ffffffffc0204c14:	000bb803          	ld	a6,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204c18:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204c1c:	41050533          	sub	a0,a0,a6
ffffffffc0204c20:	8519                	srai	a0,a0,0x6
ffffffffc0204c22:	955a                	add	a0,a0,s6
    return KADDR(page2pa(page));
ffffffffc0204c24:	01457833          	and	a6,a0,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c28:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0204c2a:	1ab87963          	bgeu	a6,a1,ffffffffc0204ddc <do_execve+0x3e0>
            memcpy((void *)((uintptr_t)page2kva(page) + off), (void *)src, n);
ffffffffc0204c2e:	000ab803          	ld	a6,0(s5)
ffffffffc0204c32:	85a2                	mv	a1,s0
ffffffffc0204c34:	8666                	mv	a2,s9
ffffffffc0204c36:	97c2                	add	a5,a5,a6
ffffffffc0204c38:	953e                	add	a0,a0,a5
            left -= n;
ffffffffc0204c3a:	419d8db3          	sub	s11,s11,s9
            memcpy((void *)((uintptr_t)page2kva(page) + off), (void *)src, n);
ffffffffc0204c3e:	203000ef          	jal	ra,ffffffffc0205640 <memcpy>
            src += n;
ffffffffc0204c42:	9466                	add	s0,s0,s9
            dst += n;
ffffffffc0204c44:	9d66                	add	s10,s10,s9
        while (left > 0)
ffffffffc0204c46:	fa0d97e3          	bnez	s11,ffffffffc0204bf4 <do_execve+0x1f8>
ffffffffc0204c4a:	67a2                	ld	a5,8(sp)
ffffffffc0204c4c:	0387d703          	lhu	a4,56(a5) # 1038 <_binary_obj___user_faultread_out_size-0x8b88>
ffffffffc0204c50:	bdc1                	j	ffffffffc0204b20 <do_execve+0x124>
    memcpy(local_name, name, len);
ffffffffc0204c52:	463d                	li	a2,15
ffffffffc0204c54:	85ca                	mv	a1,s2
ffffffffc0204c56:	0808                	addi	a0,sp,16
ffffffffc0204c58:	1e9000ef          	jal	ra,ffffffffc0205640 <memcpy>
    if (mm != NULL)
ffffffffc0204c5c:	de049fe3          	bnez	s1,ffffffffc0204a5a <do_execve+0x5e>
    if (current->mm != NULL)
ffffffffc0204c60:	000a6797          	auipc	a5,0xa6
ffffffffc0204c64:	be878793          	addi	a5,a5,-1048 # ffffffffc02aa848 <current>
ffffffffc0204c68:	639c                	ld	a5,0(a5)
ffffffffc0204c6a:	779c                	ld	a5,40(a5)
ffffffffc0204c6c:	e20780e3          	beqz	a5,ffffffffc0204a8c <do_execve+0x90>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204c70:	00002617          	auipc	a2,0x2
ffffffffc0204c74:	39060613          	addi	a2,a2,912 # ffffffffc0207000 <default_pmm_manager+0xc48>
ffffffffc0204c78:	27000593          	li	a1,624
ffffffffc0204c7c:	00002517          	auipc	a0,0x2
ffffffffc0204c80:	1f450513          	addi	a0,a0,500 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204c84:	fcafb0ef          	jal	ra,ffffffffc020044e <__panic>
    put_pgdir(mm);
ffffffffc0204c88:	8526                	mv	a0,s1
ffffffffc0204c8a:	aecff0ef          	jal	ra,ffffffffc0203f76 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c8e:	8526                	mv	a0,s1
ffffffffc0204c90:	c9dfe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204c94:	5461                	li	s0,-8
    do_exit(ret);
ffffffffc0204c96:	8522                	mv	a0,s0
ffffffffc0204c98:	94fff0ef          	jal	ra,ffffffffc02045e6 <do_exit>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c9c:	c399                	beqz	a5,ffffffffc0204ca2 <do_execve+0x2a6>
            vm_flags |= VM_READ;
ffffffffc0204c9e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_WRITE)
ffffffffc0204ca2:	0026f793          	andi	a5,a3,2
ffffffffc0204ca6:	ec0783e3          	beqz	a5,ffffffffc0204b6c <do_execve+0x170>
ffffffffc0204caa:	bd7d                	j	ffffffffc0204b68 <do_execve+0x16c>
            exit_mmap(mm);
ffffffffc0204cac:	8526                	mv	a0,s1
ffffffffc0204cae:	e1bfe0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204cb2:	8526                	mv	a0,s1
ffffffffc0204cb4:	ac2ff0ef          	jal	ra,ffffffffc0203f76 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204cb8:	8526                	mv	a0,s1
ffffffffc0204cba:	c73fe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
ffffffffc0204cbe:	b3c1                	j	ffffffffc0204a7e <do_execve+0x82>
    if ((ret = mm_map(mm, ustack_top - USTACKSIZE, USTACKSIZE,
ffffffffc0204cc0:	4701                	li	a4,0
ffffffffc0204cc2:	46ad                	li	a3,11
ffffffffc0204cc4:	00100637          	lui	a2,0x100
ffffffffc0204cc8:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204ccc:	8526                	mv	a0,s1
ffffffffc0204cce:	cb1fe0ef          	jal	ra,ffffffffc020397e <mm_map>
ffffffffc0204cd2:	842a                	mv	s0,a0
ffffffffc0204cd4:	e929                	bnez	a0,ffffffffc0204d26 <do_execve+0x32a>
ffffffffc0204cd6:	597d                	li	s2,-1
    for (uintptr_t va = ustack_top - USTACKSIZE; va < ustack_top; va += PGSIZE)
ffffffffc0204cd8:	4985                	li	s3,1
ffffffffc0204cda:	7ff00d37          	lui	s10,0x7ff00
ffffffffc0204cde:	00c95c93          	srli	s9,s2,0xc
ffffffffc0204ce2:	01f99a13          	slli	s4,s3,0x1f
ffffffffc0204ce6:	a80d                	j	ffffffffc0204d18 <do_execve+0x31c>
    return page - pages + nbase;
ffffffffc0204ce8:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204cec:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204cf0:	40d506b3          	sub	a3,a0,a3
ffffffffc0204cf4:	8699                	srai	a3,a3,0x6
ffffffffc0204cf6:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204cf8:	0196f733          	and	a4,a3,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cfc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cfe:	0ef77063          	bgeu	a4,a5,ffffffffc0204dde <do_execve+0x3e2>
ffffffffc0204d02:	000ab503          	ld	a0,0(s5)
        memset(page2kva(page), 0, PGSIZE);
ffffffffc0204d06:	6605                	lui	a2,0x1
ffffffffc0204d08:	4581                	li	a1,0
ffffffffc0204d0a:	9536                	add	a0,a0,a3
ffffffffc0204d0c:	123000ef          	jal	ra,ffffffffc020562e <memset>
    for (uintptr_t va = ustack_top - USTACKSIZE; va < ustack_top; va += PGSIZE)
ffffffffc0204d10:	6785                	lui	a5,0x1
ffffffffc0204d12:	9d3e                	add	s10,s10,a5
ffffffffc0204d14:	054d0663          	beq	s10,s4,ffffffffc0204d60 <do_execve+0x364>
        struct Page *page = pgdir_alloc_page(mm->pgdir, va, PTE_U | PTE_R | PTE_W);
ffffffffc0204d18:	6c88                	ld	a0,24(s1)
ffffffffc0204d1a:	4659                	li	a2,22
ffffffffc0204d1c:	85ea                	mv	a1,s10
ffffffffc0204d1e:	80dfe0ef          	jal	ra,ffffffffc020352a <pgdir_alloc_page>
        if (page == NULL)
ffffffffc0204d22:	f179                	bnez	a0,ffffffffc0204ce8 <do_execve+0x2ec>
                    ret = -E_NO_MEM;
ffffffffc0204d24:	5471                	li	s0,-4
    exit_mmap(mm);
ffffffffc0204d26:	8526                	mv	a0,s1
ffffffffc0204d28:	da1fe0ef          	jal	ra,ffffffffc0203ac8 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204d2c:	8526                	mv	a0,s1
ffffffffc0204d2e:	a48ff0ef          	jal	ra,ffffffffc0203f76 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204d32:	8526                	mv	a0,s1
ffffffffc0204d34:	bf9fe0ef          	jal	ra,ffffffffc020392c <mm_destroy>
ffffffffc0204d38:	bfb9                	j	ffffffffc0204c96 <do_execve+0x29a>
            ret = -E_INVAL_ELF;
ffffffffc0204d3a:	5461                	li	s0,-8
ffffffffc0204d3c:	b7ed                	j	ffffffffc0204d26 <do_execve+0x32a>
        return -E_INVAL;
ffffffffc0204d3e:	5475                	li	s0,-3
}
ffffffffc0204d40:	60aa                	ld	ra,136(sp)
ffffffffc0204d42:	8522                	mv	a0,s0
ffffffffc0204d44:	640a                	ld	s0,128(sp)
ffffffffc0204d46:	74e6                	ld	s1,120(sp)
ffffffffc0204d48:	7946                	ld	s2,112(sp)
ffffffffc0204d4a:	79a6                	ld	s3,104(sp)
ffffffffc0204d4c:	7a06                	ld	s4,96(sp)
ffffffffc0204d4e:	6ae6                	ld	s5,88(sp)
ffffffffc0204d50:	6b46                	ld	s6,80(sp)
ffffffffc0204d52:	6ba6                	ld	s7,72(sp)
ffffffffc0204d54:	6c06                	ld	s8,64(sp)
ffffffffc0204d56:	7ce2                	ld	s9,56(sp)
ffffffffc0204d58:	7d42                	ld	s10,48(sp)
ffffffffc0204d5a:	7da2                	ld	s11,40(sp)
ffffffffc0204d5c:	6149                	addi	sp,sp,144
ffffffffc0204d5e:	8082                	ret
    current->mm = mm;
ffffffffc0204d60:	000a6797          	auipc	a5,0xa6
ffffffffc0204d64:	ae878793          	addi	a5,a5,-1304 # ffffffffc02aa848 <current>
ffffffffc0204d68:	6398                	ld	a4,0(a5)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d6a:	6c94                	ld	a3,24(s1)
ffffffffc0204d6c:	c02007b7          	lui	a5,0xc0200
    current->mm = mm;
ffffffffc0204d70:	f704                	sd	s1,40(a4)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d72:	0af6e263          	bltu	a3,a5,ffffffffc0204e16 <do_execve+0x41a>
ffffffffc0204d76:	000ab783          	ld	a5,0(s5)
    write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc0204d7a:	197e                	slli	s2,s2,0x3f
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d7c:	8e9d                	sub	a3,a3,a5
ffffffffc0204d7e:	f754                	sd	a3,168(a4)
    write_csr(satp, ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc0204d80:	82b1                	srli	a3,a3,0xc
ffffffffc0204d82:	0126e6b3          	or	a3,a3,s2
    mm->mm_count = val;
ffffffffc0204d86:	0334a823          	sw	s3,48(s1)
ffffffffc0204d8a:	18069073          	csrw	satp,a3
    asm volatile("sfence.vma");
ffffffffc0204d8e:	12000073          	sfence.vma
    current->tf->gpr.sp = ustack_top;
ffffffffc0204d92:	000a6797          	auipc	a5,0xa6
ffffffffc0204d96:	ab678793          	addi	a5,a5,-1354 # ffffffffc02aa848 <current>
ffffffffc0204d9a:	6384                	ld	s1,0(a5)
    current->tf->epc = elf->e_entry;
ffffffffc0204d9c:	67a2                	ld	a5,8(sp)
    current->tf->gpr.sp = ustack_top;
ffffffffc0204d9e:	70d8                	ld	a4,160(s1)
    current->tf->epc = elf->e_entry;
ffffffffc0204da0:	6f9c                	ld	a5,24(a5)
    current->tf->gpr.sp = ustack_top;
ffffffffc0204da2:	01a73823          	sd	s10,16(a4)
    current->tf->epc = elf->e_entry;
ffffffffc0204da6:	10f73423          	sd	a5,264(a4)
    current->tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204daa:	100027f3          	csrr	a5,sstatus
ffffffffc0204dae:	edf7f793          	andi	a5,a5,-289
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204db2:	0b448493          	addi	s1,s1,180
    current->tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204db6:	0207e793          	ori	a5,a5,32
ffffffffc0204dba:	10f73023          	sd	a5,256(a4)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dbe:	4641                	li	a2,16
ffffffffc0204dc0:	4581                	li	a1,0
ffffffffc0204dc2:	8526                	mv	a0,s1
ffffffffc0204dc4:	06b000ef          	jal	ra,ffffffffc020562e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204dc8:	463d                	li	a2,15
ffffffffc0204dca:	080c                	addi	a1,sp,16
ffffffffc0204dcc:	8526                	mv	a0,s1
ffffffffc0204dce:	073000ef          	jal	ra,ffffffffc0205640 <memcpy>
ffffffffc0204dd2:	b7bd                	j	ffffffffc0204d40 <do_execve+0x344>
    int ret = -E_NO_MEM;
ffffffffc0204dd4:	5471                	li	s0,-4
ffffffffc0204dd6:	bfb1                	j	ffffffffc0204d32 <do_execve+0x336>
ffffffffc0204dd8:	5471                	li	s0,-4
ffffffffc0204dda:	bd75                	j	ffffffffc0204c96 <do_execve+0x29a>
    return KADDR(page2pa(page));
ffffffffc0204ddc:	86aa                	mv	a3,a0
ffffffffc0204dde:	00001617          	auipc	a2,0x1
ffffffffc0204de2:	61260613          	addi	a2,a2,1554 # ffffffffc02063f0 <default_pmm_manager+0x38>
ffffffffc0204de6:	07100593          	li	a1,113
ffffffffc0204dea:	00001517          	auipc	a0,0x1
ffffffffc0204dee:	62e50513          	addi	a0,a0,1582 # ffffffffc0206418 <default_pmm_manager+0x60>
ffffffffc0204df2:	e5cfb0ef          	jal	ra,ffffffffc020044e <__panic>
            assert(page != NULL);
ffffffffc0204df6:	00002697          	auipc	a3,0x2
ffffffffc0204dfa:	23268693          	addi	a3,a3,562 # ffffffffc0207028 <default_pmm_manager+0xc70>
ffffffffc0204dfe:	00001617          	auipc	a2,0x1
ffffffffc0204e02:	20a60613          	addi	a2,a2,522 # ffffffffc0206008 <commands+0x748>
ffffffffc0204e06:	2ba00593          	li	a1,698
ffffffffc0204e0a:	00002517          	auipc	a0,0x2
ffffffffc0204e0e:	06650513          	addi	a0,a0,102 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204e12:	e3cfb0ef          	jal	ra,ffffffffc020044e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204e16:	00001617          	auipc	a2,0x1
ffffffffc0204e1a:	68260613          	addi	a2,a2,1666 # ffffffffc0206498 <default_pmm_manager+0xe0>
ffffffffc0204e1e:	2d800593          	li	a1,728
ffffffffc0204e22:	00002517          	auipc	a0,0x2
ffffffffc0204e26:	04e50513          	addi	a0,a0,78 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204e2a:	e24fb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204e2e <user_main>:
{
ffffffffc0204e2e:	1141                	addi	sp,sp,-16
ffffffffc0204e30:	e022                	sd	s0,0(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204e32:	000a6417          	auipc	s0,0xa6
ffffffffc0204e36:	a1640413          	addi	s0,s0,-1514 # ffffffffc02aa848 <current>
ffffffffc0204e3a:	601c                	ld	a5,0(s0)
ffffffffc0204e3c:	00002617          	auipc	a2,0x2
ffffffffc0204e40:	1fc60613          	addi	a2,a2,508 # ffffffffc0207038 <default_pmm_manager+0xc80>
ffffffffc0204e44:	00002517          	auipc	a0,0x2
ffffffffc0204e48:	1fc50513          	addi	a0,a0,508 # ffffffffc0207040 <default_pmm_manager+0xc88>
ffffffffc0204e4c:	43cc                	lw	a1,4(a5)
{
ffffffffc0204e4e:	e406                	sd	ra,8(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204e50:	b44fb0ef          	jal	ra,ffffffffc0200194 <cprintf>
    int64_t ret = 0, len = strlen(name);
ffffffffc0204e54:	00002517          	auipc	a0,0x2
ffffffffc0204e58:	1e450513          	addi	a0,a0,484 # ffffffffc0207038 <default_pmm_manager+0xc80>
ffffffffc0204e5c:	730000ef          	jal	ra,ffffffffc020558c <strlen>
ffffffffc0204e60:	85aa                	mv	a1,a0
    ret = do_execve(name, len, binary, size);
ffffffffc0204e62:	3fe06697          	auipc	a3,0x3fe06
ffffffffc0204e66:	2ce68693          	addi	a3,a3,718 # b130 <_binary_obj___user_exit_out_size>
ffffffffc0204e6a:	00025617          	auipc	a2,0x25
ffffffffc0204e6e:	6ee60613          	addi	a2,a2,1774 # ffffffffc022a558 <_binary_obj___user_exit_out_start>
ffffffffc0204e72:	00002517          	auipc	a0,0x2
ffffffffc0204e76:	1c650513          	addi	a0,a0,454 # ffffffffc0207038 <default_pmm_manager+0xc80>
ffffffffc0204e7a:	b83ff0ef          	jal	ra,ffffffffc02049fc <do_execve>
    if (ret < 0)
ffffffffc0204e7e:	00054763          	bltz	a0,ffffffffc0204e8c <user_main+0x5e>
        : "r"(current->tf)
ffffffffc0204e82:	601c                	ld	a5,0(s0)
    asm volatile(
ffffffffc0204e84:	73dc                	ld	a5,160(a5)
ffffffffc0204e86:	813e                	mv	sp,a5
ffffffffc0204e88:	824fc06f          	j	ffffffffc0200eac <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204e8c:	00002617          	auipc	a2,0x2
ffffffffc0204e90:	1dc60613          	addi	a2,a2,476 # ffffffffc0207068 <default_pmm_manager+0xcb0>
ffffffffc0204e94:	33e00593          	li	a1,830
ffffffffc0204e98:	00002517          	auipc	a0,0x2
ffffffffc0204e9c:	fd850513          	addi	a0,a0,-40 # ffffffffc0206e70 <default_pmm_manager+0xab8>
ffffffffc0204ea0:	daefb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc0204ea4 <do_wait>:
{
ffffffffc0204ea4:	1101                	addi	sp,sp,-32
ffffffffc0204ea6:	e822                	sd	s0,16(sp)
ffffffffc0204ea8:	e426                	sd	s1,8(sp)
ffffffffc0204eaa:	ec06                	sd	ra,24(sp)
ffffffffc0204eac:	842e                	mv	s0,a1
ffffffffc0204eae:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204eb0:	c999                	beqz	a1,ffffffffc0204ec6 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204eb2:	000a6797          	auipc	a5,0xa6
ffffffffc0204eb6:	9967b783          	ld	a5,-1642(a5) # ffffffffc02aa848 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204eba:	7788                	ld	a0,40(a5)
ffffffffc0204ebc:	4685                	li	a3,1
ffffffffc0204ebe:	4611                	li	a2,4
ffffffffc0204ec0:	fa3fe0ef          	jal	ra,ffffffffc0203e62 <user_mem_check>
ffffffffc0204ec4:	c909                	beqz	a0,ffffffffc0204ed6 <do_wait+0x32>
ffffffffc0204ec6:	85a2                	mv	a1,s0
}
ffffffffc0204ec8:	6442                	ld	s0,16(sp)
ffffffffc0204eca:	60e2                	ld	ra,24(sp)
ffffffffc0204ecc:	8526                	mv	a0,s1
ffffffffc0204ece:	64a2                	ld	s1,8(sp)
ffffffffc0204ed0:	6105                	addi	sp,sp,32
ffffffffc0204ed2:	86dff06f          	j	ffffffffc020473e <do_wait.part.0>
ffffffffc0204ed6:	60e2                	ld	ra,24(sp)
ffffffffc0204ed8:	6442                	ld	s0,16(sp)
ffffffffc0204eda:	64a2                	ld	s1,8(sp)
ffffffffc0204edc:	5575                	li	a0,-3
ffffffffc0204ede:	6105                	addi	sp,sp,32
ffffffffc0204ee0:	8082                	ret

ffffffffc0204ee2 <proc_run>:

// 进程调度与切换（Lab4 遗留代码，在 Lab5 中继续使用）。
void proc_run(struct proc_struct *proc)
{
ffffffffc0204ee2:	7179                	addi	sp,sp,-48
ffffffffc0204ee4:	f026                	sd	s1,32(sp)
    if (proc == current)
ffffffffc0204ee6:	000a6497          	auipc	s1,0xa6
ffffffffc0204eea:	96248493          	addi	s1,s1,-1694 # ffffffffc02aa848 <current>
ffffffffc0204eee:	6094                	ld	a3,0(s1)
{
ffffffffc0204ef0:	f406                	sd	ra,40(sp)
ffffffffc0204ef2:	ec4a                	sd	s2,24(sp)
    if (proc == current)
ffffffffc0204ef4:	02a68963          	beq	a3,a0,ffffffffc0204f26 <proc_run+0x44>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204ef8:	100027f3          	csrr	a5,sstatus
ffffffffc0204efc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204efe:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204f00:	ef95                	bnez	a5,ffffffffc0204f3c <proc_run+0x5a>

    struct proc_struct *prev = current;
    current = proc;

    uint64_t satp = ((uint64_t)SATP_MODE_SV39 << 60) |
                    (proc->pgdir >> RISCV_PGSHIFT);
ffffffffc0204f02:	755c                	ld	a5,168(a0)
    uint64_t satp = ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc0204f04:	577d                	li	a4,-1
ffffffffc0204f06:	177e                	slli	a4,a4,0x3f
                    (proc->pgdir >> RISCV_PGSHIFT);
ffffffffc0204f08:	83b1                	srli	a5,a5,0xc
    current = proc;
ffffffffc0204f0a:	e088                	sd	a0,0(s1)
    uint64_t satp = ((uint64_t)SATP_MODE_SV39 << 60) |
ffffffffc0204f0c:	8fd9                	or	a5,a5,a4
    write_csr(satp, satp);
ffffffffc0204f0e:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma");
ffffffffc0204f12:	12000073          	sfence.vma
    flush_tlb();
    switch_to(&prev->context, &proc->context);
ffffffffc0204f16:	03050593          	addi	a1,a0,48
ffffffffc0204f1a:	03068513          	addi	a0,a3,48
ffffffffc0204f1e:	046000ef          	jal	ra,ffffffffc0204f64 <switch_to>
    if (flag)
ffffffffc0204f22:	00091763          	bnez	s2,ffffffffc0204f30 <proc_run+0x4e>

    local_intr_restore(intr_flag);
}
ffffffffc0204f26:	70a2                	ld	ra,40(sp)
ffffffffc0204f28:	7482                	ld	s1,32(sp)
ffffffffc0204f2a:	6962                	ld	s2,24(sp)
ffffffffc0204f2c:	6145                	addi	sp,sp,48
ffffffffc0204f2e:	8082                	ret
ffffffffc0204f30:	70a2                	ld	ra,40(sp)
ffffffffc0204f32:	7482                	ld	s1,32(sp)
ffffffffc0204f34:	6962                	ld	s2,24(sp)
ffffffffc0204f36:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204f38:	a37fb06f          	j	ffffffffc020096e <intr_enable>
ffffffffc0204f3c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204f3e:	a37fb0ef          	jal	ra,ffffffffc0200974 <intr_disable>
    struct proc_struct *prev = current;
ffffffffc0204f42:	6094                	ld	a3,0(s1)
        return 1;
ffffffffc0204f44:	6522                	ld	a0,8(sp)
ffffffffc0204f46:	4905                	li	s2,1
ffffffffc0204f48:	bf6d                	j	ffffffffc0204f02 <proc_run+0x20>

ffffffffc0204f4a <cpu_idle>:

void cpu_idle(void)
{
ffffffffc0204f4a:	1141                	addi	sp,sp,-16
ffffffffc0204f4c:	e022                	sd	s0,0(sp)
ffffffffc0204f4e:	e406                	sd	ra,8(sp)
ffffffffc0204f50:	000a6417          	auipc	s0,0xa6
ffffffffc0204f54:	8f840413          	addi	s0,s0,-1800 # ffffffffc02aa848 <current>
    for (;;)
    {
        if (current->need_resched)
ffffffffc0204f58:	6018                	ld	a4,0(s0)
ffffffffc0204f5a:	6f1c                	ld	a5,24(a4)
ffffffffc0204f5c:	dffd                	beqz	a5,ffffffffc0204f5a <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204f5e:	0f0000ef          	jal	ra,ffffffffc020504e <schedule>
ffffffffc0204f62:	bfdd                	j	ffffffffc0204f58 <cpu_idle+0xe>

ffffffffc0204f64 <switch_to>:
    .text
    .align 2
    .globl switch_to
    .type switch_to, @function
switch_to:
    sd ra, 0(a0)
ffffffffc0204f64:	00153023          	sd	ra,0(a0)
    sd sp, 8(a0)
ffffffffc0204f68:	00253423          	sd	sp,8(a0)
    sd s0, 16(a0)
ffffffffc0204f6c:	e900                	sd	s0,16(a0)
    sd s1, 24(a0)
ffffffffc0204f6e:	ed04                	sd	s1,24(a0)
    sd s2, 32(a0)
ffffffffc0204f70:	03253023          	sd	s2,32(a0)
    sd s3, 40(a0)
ffffffffc0204f74:	03353423          	sd	s3,40(a0)
    sd s4, 48(a0)
ffffffffc0204f78:	03453823          	sd	s4,48(a0)
    sd s5, 56(a0)
ffffffffc0204f7c:	03553c23          	sd	s5,56(a0)
    sd s6, 64(a0)
ffffffffc0204f80:	05653023          	sd	s6,64(a0)
    sd s7, 72(a0)
ffffffffc0204f84:	05753423          	sd	s7,72(a0)
    sd s8, 80(a0)
ffffffffc0204f88:	05853823          	sd	s8,80(a0)
    sd s9, 88(a0)
ffffffffc0204f8c:	05953c23          	sd	s9,88(a0)
    sd s10, 96(a0)
ffffffffc0204f90:	07a53023          	sd	s10,96(a0)
    sd s11, 104(a0)
ffffffffc0204f94:	07b53423          	sd	s11,104(a0)

    ld ra, 0(a1)
ffffffffc0204f98:	0005b083          	ld	ra,0(a1) # 7ff00000 <_binary_obj___user_exit_out_size+0x7fef4ed0>
    ld sp, 8(a1)
ffffffffc0204f9c:	0085b103          	ld	sp,8(a1)
    ld s0, 16(a1)
ffffffffc0204fa0:	6980                	ld	s0,16(a1)
    ld s1, 24(a1)
ffffffffc0204fa2:	6d84                	ld	s1,24(a1)
    ld s2, 32(a1)
ffffffffc0204fa4:	0205b903          	ld	s2,32(a1)
    ld s3, 40(a1)
ffffffffc0204fa8:	0285b983          	ld	s3,40(a1)
    ld s4, 48(a1)
ffffffffc0204fac:	0305ba03          	ld	s4,48(a1)
    ld s5, 56(a1)
ffffffffc0204fb0:	0385ba83          	ld	s5,56(a1)
    ld s6, 64(a1)
ffffffffc0204fb4:	0405bb03          	ld	s6,64(a1)
    ld s7, 72(a1)
ffffffffc0204fb8:	0485bb83          	ld	s7,72(a1)
    ld s8, 80(a1)
ffffffffc0204fbc:	0505bc03          	ld	s8,80(a1)
    ld s9, 88(a1)
ffffffffc0204fc0:	0585bc83          	ld	s9,88(a1)
    ld s10, 96(a1)
ffffffffc0204fc4:	0605bd03          	ld	s10,96(a1)
    ld s11, 104(a1)
ffffffffc0204fc8:	0685bd83          	ld	s11,104(a1)
    ret
ffffffffc0204fcc:	8082                	ret

ffffffffc0204fce <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204fce:	4118                	lw	a4,0(a0)
{
ffffffffc0204fd0:	1101                	addi	sp,sp,-32
ffffffffc0204fd2:	ec06                	sd	ra,24(sp)
ffffffffc0204fd4:	e822                	sd	s0,16(sp)
ffffffffc0204fd6:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0204fd8:	478d                	li	a5,3
ffffffffc0204fda:	04f70b63          	beq	a4,a5,ffffffffc0205030 <wakeup_proc+0x62>
ffffffffc0204fde:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204fe0:	100027f3          	csrr	a5,sstatus
ffffffffc0204fe4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204fe6:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204fe8:	ef9d                	bnez	a5,ffffffffc0205026 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0204fea:	4789                	li	a5,2
ffffffffc0204fec:	02f70163          	beq	a4,a5,ffffffffc020500e <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0204ff0:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0204ff2:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0204ff6:	e491                	bnez	s1,ffffffffc0205002 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204ff8:	60e2                	ld	ra,24(sp)
ffffffffc0204ffa:	6442                	ld	s0,16(sp)
ffffffffc0204ffc:	64a2                	ld	s1,8(sp)
ffffffffc0204ffe:	6105                	addi	sp,sp,32
ffffffffc0205000:	8082                	ret
ffffffffc0205002:	6442                	ld	s0,16(sp)
ffffffffc0205004:	60e2                	ld	ra,24(sp)
ffffffffc0205006:	64a2                	ld	s1,8(sp)
ffffffffc0205008:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020500a:	965fb06f          	j	ffffffffc020096e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020500e:	00002617          	auipc	a2,0x2
ffffffffc0205012:	0b260613          	addi	a2,a2,178 # ffffffffc02070c0 <default_pmm_manager+0xd08>
ffffffffc0205016:	45d1                	li	a1,20
ffffffffc0205018:	00002517          	auipc	a0,0x2
ffffffffc020501c:	09050513          	addi	a0,a0,144 # ffffffffc02070a8 <default_pmm_manager+0xcf0>
ffffffffc0205020:	c96fb0ef          	jal	ra,ffffffffc02004b6 <__warn>
ffffffffc0205024:	bfc9                	j	ffffffffc0204ff6 <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205026:	94ffb0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020502a:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc020502c:	4485                	li	s1,1
ffffffffc020502e:	bf75                	j	ffffffffc0204fea <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205030:	00002697          	auipc	a3,0x2
ffffffffc0205034:	05868693          	addi	a3,a3,88 # ffffffffc0207088 <default_pmm_manager+0xcd0>
ffffffffc0205038:	00001617          	auipc	a2,0x1
ffffffffc020503c:	fd060613          	addi	a2,a2,-48 # ffffffffc0206008 <commands+0x748>
ffffffffc0205040:	45a5                	li	a1,9
ffffffffc0205042:	00002517          	auipc	a0,0x2
ffffffffc0205046:	06650513          	addi	a0,a0,102 # ffffffffc02070a8 <default_pmm_manager+0xcf0>
ffffffffc020504a:	c04fb0ef          	jal	ra,ffffffffc020044e <__panic>

ffffffffc020504e <schedule>:

//lab4 请补充你在lab4中的代码
void schedule(void)
{
ffffffffc020504e:	1141                	addi	sp,sp,-16
ffffffffc0205050:	e406                	sd	ra,8(sp)
ffffffffc0205052:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205054:	100027f3          	csrr	a5,sstatus
ffffffffc0205058:	8b89                	andi	a5,a5,2
ffffffffc020505a:	4401                	li	s0,0
ffffffffc020505c:	e7ad                	bnez	a5,ffffffffc02050c6 <schedule+0x78>
    bool intr_flag;
    local_intr_save(intr_flag);

    struct proc_struct *prev = current;
ffffffffc020505e:	000a5817          	auipc	a6,0xa5
ffffffffc0205062:	7ea83803          	ld	a6,2026(a6) # ffffffffc02aa848 <current>
    prev->need_resched = 0;
ffffffffc0205066:	00083c23          	sd	zero,24(a6)

    list_entry_t *head = &proc_list;
    // 从当前进程的下一个开始扫描；idleproc 不在 proc_list 中，从表头开始。
    list_entry_t *start = (prev == idleproc) ? head : &prev->list_link;
ffffffffc020506a:	000a5517          	auipc	a0,0xa5
ffffffffc020506e:	7e653503          	ld	a0,2022(a0) # ffffffffc02aa850 <idleproc>
ffffffffc0205072:	000a5697          	auipc	a3,0xa5
ffffffffc0205076:	75e68693          	addi	a3,a3,1886 # ffffffffc02aa7d0 <proc_list>
ffffffffc020507a:	01050463          	beq	a0,a6,ffffffffc0205082 <schedule+0x34>
ffffffffc020507e:	0c880693          	addi	a3,a6,200
    list_entry_t *le = start;
ffffffffc0205082:	87b6                	mv	a5,a3
    struct proc_struct *next = idleproc;

    while ((le = list_next(le)) != start)
    {
        if (le == head)
ffffffffc0205084:	000a5617          	auipc	a2,0xa5
ffffffffc0205088:	74c60613          	addi	a2,a2,1868 # ffffffffc02aa7d0 <proc_list>
        {
            continue;
        }
        struct proc_struct *proc = le2proc(le, list_link);
        if (proc->state == PROC_RUNNABLE)
ffffffffc020508c:	4589                	li	a1,2
ffffffffc020508e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != start)
ffffffffc0205090:	00f68a63          	beq	a3,a5,ffffffffc02050a4 <schedule+0x56>
        if (le == head)
ffffffffc0205094:	fec78de3          	beq	a5,a2,ffffffffc020508e <schedule+0x40>
        if (proc->state == PROC_RUNNABLE)
ffffffffc0205098:	f387a703          	lw	a4,-200(a5)
ffffffffc020509c:	feb719e3          	bne	a4,a1,ffffffffc020508e <schedule+0x40>
        struct proc_struct *proc = le2proc(le, list_link);
ffffffffc02050a0:	f3878513          	addi	a0,a5,-200
            next = proc;
            break;
        }
    }

    next->runs++;
ffffffffc02050a4:	451c                	lw	a5,8(a0)
ffffffffc02050a6:	2785                	addiw	a5,a5,1
ffffffffc02050a8:	c51c                	sw	a5,8(a0)
    if (next != prev)
ffffffffc02050aa:	01050463          	beq	a0,a6,ffffffffc02050b2 <schedule+0x64>
    {
        proc_run(next);
ffffffffc02050ae:	e35ff0ef          	jal	ra,ffffffffc0204ee2 <proc_run>
    if (flag)
ffffffffc02050b2:	e409                	bnez	s0,ffffffffc02050bc <schedule+0x6e>
    }

    local_intr_restore(intr_flag);
}
ffffffffc02050b4:	60a2                	ld	ra,8(sp)
ffffffffc02050b6:	6402                	ld	s0,0(sp)
ffffffffc02050b8:	0141                	addi	sp,sp,16
ffffffffc02050ba:	8082                	ret
ffffffffc02050bc:	6402                	ld	s0,0(sp)
ffffffffc02050be:	60a2                	ld	ra,8(sp)
ffffffffc02050c0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02050c2:	8adfb06f          	j	ffffffffc020096e <intr_enable>
        intr_disable();
ffffffffc02050c6:	8affb0ef          	jal	ra,ffffffffc0200974 <intr_disable>
        return 1;
ffffffffc02050ca:	4405                	li	s0,1
ffffffffc02050cc:	bf49                	j	ffffffffc020505e <schedule+0x10>

ffffffffc02050ce <sys_getpid>:
    return do_kill(pid);
}

static int sys_getpid(uint64_t arg[])
{
    return current->pid;
ffffffffc02050ce:	000a5797          	auipc	a5,0xa5
ffffffffc02050d2:	77a7b783          	ld	a5,1914(a5) # ffffffffc02aa848 <current>
}
ffffffffc02050d6:	43c8                	lw	a0,4(a5)
ffffffffc02050d8:	8082                	ret

ffffffffc02050da <sys_pgdir>:
    cputchar(c);
    return 0;
}

static int sys_pgdir(uint64_t arg[])
{
ffffffffc02050da:	1141                	addi	sp,sp,-16
ffffffffc02050dc:	e406                	sd	ra,8(sp)
    print_pgdir();
ffffffffc02050de:	d0efe0ef          	jal	ra,ffffffffc02035ec <print_pgdir>
    return 0;
}
ffffffffc02050e2:	60a2                	ld	ra,8(sp)
ffffffffc02050e4:	4501                	li	a0,0
ffffffffc02050e6:	0141                	addi	sp,sp,16
ffffffffc02050e8:	8082                	ret

ffffffffc02050ea <sys_putc>:
    cputchar(c);
ffffffffc02050ea:	4108                	lw	a0,0(a0)
{
ffffffffc02050ec:	1141                	addi	sp,sp,-16
ffffffffc02050ee:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02050f0:	8dafb0ef          	jal	ra,ffffffffc02001ca <cputchar>
}
ffffffffc02050f4:	60a2                	ld	ra,8(sp)
ffffffffc02050f6:	4501                	li	a0,0
ffffffffc02050f8:	0141                	addi	sp,sp,16
ffffffffc02050fa:	8082                	ret

ffffffffc02050fc <sys_kill>:
    return do_kill(pid);
ffffffffc02050fc:	4108                	lw	a0,0(a0)
ffffffffc02050fe:	883ff06f          	j	ffffffffc0204980 <do_kill>

ffffffffc0205102 <sys_yield>:
    return do_yield();
ffffffffc0205102:	86fff06f          	j	ffffffffc0204970 <do_yield>

ffffffffc0205106 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205106:	6d14                	ld	a3,24(a0)
ffffffffc0205108:	6910                	ld	a2,16(a0)
ffffffffc020510a:	650c                	ld	a1,8(a0)
ffffffffc020510c:	6108                	ld	a0,0(a0)
ffffffffc020510e:	8efff06f          	j	ffffffffc02049fc <do_execve>

ffffffffc0205112 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205112:	650c                	ld	a1,8(a0)
ffffffffc0205114:	4108                	lw	a0,0(a0)
ffffffffc0205116:	d8fff06f          	j	ffffffffc0204ea4 <do_wait>

ffffffffc020511a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020511a:	000a5797          	auipc	a5,0xa5
ffffffffc020511e:	72e7b783          	ld	a5,1838(a5) # ffffffffc02aa848 <current>
ffffffffc0205122:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205124:	4501                	li	a0,0
ffffffffc0205126:	6a0c                	ld	a1,16(a2)
ffffffffc0205128:	ec5fe06f          	j	ffffffffc0203fec <do_fork>

ffffffffc020512c <sys_exit>:
    return do_exit(error_code);
ffffffffc020512c:	4108                	lw	a0,0(a0)
ffffffffc020512e:	cb8ff06f          	j	ffffffffc02045e6 <do_exit>

ffffffffc0205132 <syscall>:

// syscall - 从当前进程的 trapframe 取出系统调用号和参数并分发。
void syscall(void)
{
ffffffffc0205132:	7139                	addi	sp,sp,-64
    struct trapframe *tf = current->tf;
ffffffffc0205134:	000a5797          	auipc	a5,0xa5
ffffffffc0205138:	7147b783          	ld	a5,1812(a5) # ffffffffc02aa848 <current>
{
ffffffffc020513c:	f822                	sd	s0,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020513e:	73c0                	ld	s0,160(a5)
{
ffffffffc0205140:	fc06                	sd	ra,56(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;

    if (num >= 0 && num < NUM_SYSCALLS && syscalls[num] != NULL)
ffffffffc0205142:	477d                	li	a4,31
ffffffffc0205144:	483c                	lw	a5,80(s0)
ffffffffc0205146:	02f76b63          	bltu	a4,a5,ffffffffc020517c <syscall+0x4a>
ffffffffc020514a:	078e                	slli	a5,a5,0x3
ffffffffc020514c:	00002717          	auipc	a4,0x2
ffffffffc0205150:	f9470713          	addi	a4,a4,-108 # ffffffffc02070e0 <syscalls>
ffffffffc0205154:	97ba                	add	a5,a5,a4
ffffffffc0205156:	639c                	ld	a5,0(a5)
ffffffffc0205158:	c395                	beqz	a5,ffffffffc020517c <syscall+0x4a>
    {
        arg[0] = tf->gpr.a1;
ffffffffc020515a:	6c28                	ld	a0,88(s0)
        arg[1] = tf->gpr.a2;
ffffffffc020515c:	702c                	ld	a1,96(s0)
        arg[2] = tf->gpr.a3;
ffffffffc020515e:	7430                	ld	a2,104(s0)
        arg[3] = tf->gpr.a4;
ffffffffc0205160:	7834                	ld	a3,112(s0)
        arg[4] = tf->gpr.a5;
ffffffffc0205162:	7c38                	ld	a4,120(s0)
        arg[0] = tf->gpr.a1;
ffffffffc0205164:	e42a                	sd	a0,8(sp)
        arg[1] = tf->gpr.a2;
ffffffffc0205166:	e82e                	sd	a1,16(sp)
        arg[2] = tf->gpr.a3;
ffffffffc0205168:	ec32                	sd	a2,24(sp)
        arg[3] = tf->gpr.a4;
ffffffffc020516a:	f036                	sd	a3,32(sp)
        arg[4] = tf->gpr.a5;
ffffffffc020516c:	f43a                	sd	a4,40(sp)
        // 返回值写回 a0，异常返回后用户程序从 a0 读取结果。
        tf->gpr.a0 = syscalls[num](arg);
ffffffffc020516e:	0028                	addi	a0,sp,8
ffffffffc0205170:	9782                	jalr	a5
        return;
    }
    // 非法或未实现的系统调用号统一返回 -E_INVAL。
    tf->gpr.a0 = -E_INVAL;
}
ffffffffc0205172:	70e2                	ld	ra,56(sp)
        tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205174:	e828                	sd	a0,80(s0)
}
ffffffffc0205176:	7442                	ld	s0,48(sp)
ffffffffc0205178:	6121                	addi	sp,sp,64
ffffffffc020517a:	8082                	ret
    tf->gpr.a0 = -E_INVAL;
ffffffffc020517c:	57f5                	li	a5,-3
}
ffffffffc020517e:	70e2                	ld	ra,56(sp)
    tf->gpr.a0 = -E_INVAL;
ffffffffc0205180:	e83c                	sd	a5,80(s0)
}
ffffffffc0205182:	7442                	ld	s0,48(sp)
ffffffffc0205184:	6121                	addi	sp,sp,64
ffffffffc0205186:	8082                	ret

ffffffffc0205188 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205188:	9e3707b7          	lui	a5,0x9e370
ffffffffc020518c:	2785                	addiw	a5,a5,1
ffffffffc020518e:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205192:	02000793          	li	a5,32
ffffffffc0205196:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205198:	00f5553b          	srlw	a0,a0,a5
ffffffffc020519c:	8082                	ret

ffffffffc020519e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020519e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02051a2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02051a4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02051a8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02051aa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02051ae:	f022                	sd	s0,32(sp)
ffffffffc02051b0:	ec26                	sd	s1,24(sp)
ffffffffc02051b2:	e84a                	sd	s2,16(sp)
ffffffffc02051b4:	f406                	sd	ra,40(sp)
ffffffffc02051b6:	e44e                	sd	s3,8(sp)
ffffffffc02051b8:	84aa                	mv	s1,a0
ffffffffc02051ba:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02051bc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02051c0:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02051c2:	03067e63          	bgeu	a2,a6,ffffffffc02051fe <printnum+0x60>
ffffffffc02051c6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02051c8:	00805763          	blez	s0,ffffffffc02051d6 <printnum+0x38>
ffffffffc02051cc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02051ce:	85ca                	mv	a1,s2
ffffffffc02051d0:	854e                	mv	a0,s3
ffffffffc02051d2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02051d4:	fc65                	bnez	s0,ffffffffc02051cc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051d6:	1a02                	slli	s4,s4,0x20
ffffffffc02051d8:	00002797          	auipc	a5,0x2
ffffffffc02051dc:	00878793          	addi	a5,a5,8 # ffffffffc02071e0 <syscalls+0x100>
ffffffffc02051e0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02051e4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02051e6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051e8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02051ec:	70a2                	ld	ra,40(sp)
ffffffffc02051ee:	69a2                	ld	s3,8(sp)
ffffffffc02051f0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051f2:	85ca                	mv	a1,s2
ffffffffc02051f4:	87a6                	mv	a5,s1
}
ffffffffc02051f6:	6942                	ld	s2,16(sp)
ffffffffc02051f8:	64e2                	ld	s1,24(sp)
ffffffffc02051fa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02051fc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02051fe:	03065633          	divu	a2,a2,a6
ffffffffc0205202:	8722                	mv	a4,s0
ffffffffc0205204:	f9bff0ef          	jal	ra,ffffffffc020519e <printnum>
ffffffffc0205208:	b7f9                	j	ffffffffc02051d6 <printnum+0x38>

ffffffffc020520a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020520a:	7119                	addi	sp,sp,-128
ffffffffc020520c:	f4a6                	sd	s1,104(sp)
ffffffffc020520e:	f0ca                	sd	s2,96(sp)
ffffffffc0205210:	ecce                	sd	s3,88(sp)
ffffffffc0205212:	e8d2                	sd	s4,80(sp)
ffffffffc0205214:	e4d6                	sd	s5,72(sp)
ffffffffc0205216:	e0da                	sd	s6,64(sp)
ffffffffc0205218:	fc5e                	sd	s7,56(sp)
ffffffffc020521a:	f06a                	sd	s10,32(sp)
ffffffffc020521c:	fc86                	sd	ra,120(sp)
ffffffffc020521e:	f8a2                	sd	s0,112(sp)
ffffffffc0205220:	f862                	sd	s8,48(sp)
ffffffffc0205222:	f466                	sd	s9,40(sp)
ffffffffc0205224:	ec6e                	sd	s11,24(sp)
ffffffffc0205226:	892a                	mv	s2,a0
ffffffffc0205228:	84ae                	mv	s1,a1
ffffffffc020522a:	8d32                	mv	s10,a2
ffffffffc020522c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020522e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205232:	5b7d                	li	s6,-1
ffffffffc0205234:	00002a97          	auipc	s5,0x2
ffffffffc0205238:	fd8a8a93          	addi	s5,s5,-40 # ffffffffc020720c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020523c:	00002b97          	auipc	s7,0x2
ffffffffc0205240:	1ecb8b93          	addi	s7,s7,492 # ffffffffc0207428 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205244:	000d4503          	lbu	a0,0(s10) # 7ff00000 <_binary_obj___user_exit_out_size+0x7fef4ed0>
ffffffffc0205248:	001d0413          	addi	s0,s10,1
ffffffffc020524c:	01350a63          	beq	a0,s3,ffffffffc0205260 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205250:	c121                	beqz	a0,ffffffffc0205290 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205252:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205254:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205256:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205258:	fff44503          	lbu	a0,-1(s0)
ffffffffc020525c:	ff351ae3          	bne	a0,s3,ffffffffc0205250 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205260:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205264:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205268:	4c81                	li	s9,0
ffffffffc020526a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020526c:	5c7d                	li	s8,-1
ffffffffc020526e:	5dfd                	li	s11,-1
ffffffffc0205270:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0205274:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205276:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020527a:	0ff5f593          	zext.b	a1,a1
ffffffffc020527e:	00140d13          	addi	s10,s0,1
ffffffffc0205282:	04b56263          	bltu	a0,a1,ffffffffc02052c6 <vprintfmt+0xbc>
ffffffffc0205286:	058a                	slli	a1,a1,0x2
ffffffffc0205288:	95d6                	add	a1,a1,s5
ffffffffc020528a:	4194                	lw	a3,0(a1)
ffffffffc020528c:	96d6                	add	a3,a3,s5
ffffffffc020528e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205290:	70e6                	ld	ra,120(sp)
ffffffffc0205292:	7446                	ld	s0,112(sp)
ffffffffc0205294:	74a6                	ld	s1,104(sp)
ffffffffc0205296:	7906                	ld	s2,96(sp)
ffffffffc0205298:	69e6                	ld	s3,88(sp)
ffffffffc020529a:	6a46                	ld	s4,80(sp)
ffffffffc020529c:	6aa6                	ld	s5,72(sp)
ffffffffc020529e:	6b06                	ld	s6,64(sp)
ffffffffc02052a0:	7be2                	ld	s7,56(sp)
ffffffffc02052a2:	7c42                	ld	s8,48(sp)
ffffffffc02052a4:	7ca2                	ld	s9,40(sp)
ffffffffc02052a6:	7d02                	ld	s10,32(sp)
ffffffffc02052a8:	6de2                	ld	s11,24(sp)
ffffffffc02052aa:	6109                	addi	sp,sp,128
ffffffffc02052ac:	8082                	ret
            padc = '0';
ffffffffc02052ae:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02052b0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02052b4:	846a                	mv	s0,s10
ffffffffc02052b6:	00140d13          	addi	s10,s0,1
ffffffffc02052ba:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02052be:	0ff5f593          	zext.b	a1,a1
ffffffffc02052c2:	fcb572e3          	bgeu	a0,a1,ffffffffc0205286 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02052c6:	85a6                	mv	a1,s1
ffffffffc02052c8:	02500513          	li	a0,37
ffffffffc02052cc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02052ce:	fff44783          	lbu	a5,-1(s0)
ffffffffc02052d2:	8d22                	mv	s10,s0
ffffffffc02052d4:	f73788e3          	beq	a5,s3,ffffffffc0205244 <vprintfmt+0x3a>
ffffffffc02052d8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02052dc:	1d7d                	addi	s10,s10,-1
ffffffffc02052de:	ff379de3          	bne	a5,s3,ffffffffc02052d8 <vprintfmt+0xce>
ffffffffc02052e2:	b78d                	j	ffffffffc0205244 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02052e4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02052e8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02052ec:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02052ee:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02052f2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02052f6:	02d86463          	bltu	a6,a3,ffffffffc020531e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02052fa:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02052fe:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205302:	0186873b          	addw	a4,a3,s8
ffffffffc0205306:	0017171b          	slliw	a4,a4,0x1
ffffffffc020530a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020530c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205310:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205312:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205316:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020531a:	fed870e3          	bgeu	a6,a3,ffffffffc02052fa <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020531e:	f40ddce3          	bgez	s11,ffffffffc0205276 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205322:	8de2                	mv	s11,s8
ffffffffc0205324:	5c7d                	li	s8,-1
ffffffffc0205326:	bf81                	j	ffffffffc0205276 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205328:	fffdc693          	not	a3,s11
ffffffffc020532c:	96fd                	srai	a3,a3,0x3f
ffffffffc020532e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205332:	00144603          	lbu	a2,1(s0)
ffffffffc0205336:	2d81                	sext.w	s11,s11
ffffffffc0205338:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020533a:	bf35                	j	ffffffffc0205276 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020533c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205340:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205344:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205346:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205348:	bfd9                	j	ffffffffc020531e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020534a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020534c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205350:	01174463          	blt	a4,a7,ffffffffc0205358 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205354:	1a088e63          	beqz	a7,ffffffffc0205510 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205358:	000a3603          	ld	a2,0(s4)
ffffffffc020535c:	46c1                	li	a3,16
ffffffffc020535e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205360:	2781                	sext.w	a5,a5
ffffffffc0205362:	876e                	mv	a4,s11
ffffffffc0205364:	85a6                	mv	a1,s1
ffffffffc0205366:	854a                	mv	a0,s2
ffffffffc0205368:	e37ff0ef          	jal	ra,ffffffffc020519e <printnum>
            break;
ffffffffc020536c:	bde1                	j	ffffffffc0205244 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020536e:	000a2503          	lw	a0,0(s4)
ffffffffc0205372:	85a6                	mv	a1,s1
ffffffffc0205374:	0a21                	addi	s4,s4,8
ffffffffc0205376:	9902                	jalr	s2
            break;
ffffffffc0205378:	b5f1                	j	ffffffffc0205244 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020537a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020537c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205380:	01174463          	blt	a4,a7,ffffffffc0205388 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0205384:	18088163          	beqz	a7,ffffffffc0205506 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0205388:	000a3603          	ld	a2,0(s4)
ffffffffc020538c:	46a9                	li	a3,10
ffffffffc020538e:	8a2e                	mv	s4,a1
ffffffffc0205390:	bfc1                	j	ffffffffc0205360 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205392:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205396:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205398:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020539a:	bdf1                	j	ffffffffc0205276 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020539c:	85a6                	mv	a1,s1
ffffffffc020539e:	02500513          	li	a0,37
ffffffffc02053a2:	9902                	jalr	s2
            break;
ffffffffc02053a4:	b545                	j	ffffffffc0205244 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053a6:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02053aa:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02053ac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02053ae:	b5e1                	j	ffffffffc0205276 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02053b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02053b2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02053b6:	01174463          	blt	a4,a7,ffffffffc02053be <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02053ba:	14088163          	beqz	a7,ffffffffc02054fc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02053be:	000a3603          	ld	a2,0(s4)
ffffffffc02053c2:	46a1                	li	a3,8
ffffffffc02053c4:	8a2e                	mv	s4,a1
ffffffffc02053c6:	bf69                	j	ffffffffc0205360 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02053c8:	03000513          	li	a0,48
ffffffffc02053cc:	85a6                	mv	a1,s1
ffffffffc02053ce:	e03e                	sd	a5,0(sp)
ffffffffc02053d0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02053d2:	85a6                	mv	a1,s1
ffffffffc02053d4:	07800513          	li	a0,120
ffffffffc02053d8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02053da:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02053dc:	6782                	ld	a5,0(sp)
ffffffffc02053de:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02053e0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02053e4:	bfb5                	j	ffffffffc0205360 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02053e6:	000a3403          	ld	s0,0(s4)
ffffffffc02053ea:	008a0713          	addi	a4,s4,8
ffffffffc02053ee:	e03a                	sd	a4,0(sp)
ffffffffc02053f0:	14040263          	beqz	s0,ffffffffc0205534 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02053f4:	0fb05763          	blez	s11,ffffffffc02054e2 <vprintfmt+0x2d8>
ffffffffc02053f8:	02d00693          	li	a3,45
ffffffffc02053fc:	0cd79163          	bne	a5,a3,ffffffffc02054be <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205400:	00044783          	lbu	a5,0(s0)
ffffffffc0205404:	0007851b          	sext.w	a0,a5
ffffffffc0205408:	cf85                	beqz	a5,ffffffffc0205440 <vprintfmt+0x236>
ffffffffc020540a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020540e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205412:	000c4563          	bltz	s8,ffffffffc020541c <vprintfmt+0x212>
ffffffffc0205416:	3c7d                	addiw	s8,s8,-1
ffffffffc0205418:	036c0263          	beq	s8,s6,ffffffffc020543c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020541c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020541e:	0e0c8e63          	beqz	s9,ffffffffc020551a <vprintfmt+0x310>
ffffffffc0205422:	3781                	addiw	a5,a5,-32
ffffffffc0205424:	0ef47b63          	bgeu	s0,a5,ffffffffc020551a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205428:	03f00513          	li	a0,63
ffffffffc020542c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020542e:	000a4783          	lbu	a5,0(s4)
ffffffffc0205432:	3dfd                	addiw	s11,s11,-1
ffffffffc0205434:	0a05                	addi	s4,s4,1
ffffffffc0205436:	0007851b          	sext.w	a0,a5
ffffffffc020543a:	ffe1                	bnez	a5,ffffffffc0205412 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020543c:	01b05963          	blez	s11,ffffffffc020544e <vprintfmt+0x244>
ffffffffc0205440:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205442:	85a6                	mv	a1,s1
ffffffffc0205444:	02000513          	li	a0,32
ffffffffc0205448:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020544a:	fe0d9be3          	bnez	s11,ffffffffc0205440 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020544e:	6a02                	ld	s4,0(sp)
ffffffffc0205450:	bbd5                	j	ffffffffc0205244 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205452:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205454:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205458:	01174463          	blt	a4,a7,ffffffffc0205460 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020545c:	08088d63          	beqz	a7,ffffffffc02054f6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0205460:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205464:	0a044d63          	bltz	s0,ffffffffc020551e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0205468:	8622                	mv	a2,s0
ffffffffc020546a:	8a66                	mv	s4,s9
ffffffffc020546c:	46a9                	li	a3,10
ffffffffc020546e:	bdcd                	j	ffffffffc0205360 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0205470:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205474:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205476:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205478:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020547c:	8fb5                	xor	a5,a5,a3
ffffffffc020547e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205482:	02d74163          	blt	a4,a3,ffffffffc02054a4 <vprintfmt+0x29a>
ffffffffc0205486:	00369793          	slli	a5,a3,0x3
ffffffffc020548a:	97de                	add	a5,a5,s7
ffffffffc020548c:	639c                	ld	a5,0(a5)
ffffffffc020548e:	cb99                	beqz	a5,ffffffffc02054a4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205490:	86be                	mv	a3,a5
ffffffffc0205492:	00000617          	auipc	a2,0x0
ffffffffc0205496:	1ee60613          	addi	a2,a2,494 # ffffffffc0205680 <etext+0x28>
ffffffffc020549a:	85a6                	mv	a1,s1
ffffffffc020549c:	854a                	mv	a0,s2
ffffffffc020549e:	0ce000ef          	jal	ra,ffffffffc020556c <printfmt>
ffffffffc02054a2:	b34d                	j	ffffffffc0205244 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02054a4:	00002617          	auipc	a2,0x2
ffffffffc02054a8:	d5c60613          	addi	a2,a2,-676 # ffffffffc0207200 <syscalls+0x120>
ffffffffc02054ac:	85a6                	mv	a1,s1
ffffffffc02054ae:	854a                	mv	a0,s2
ffffffffc02054b0:	0bc000ef          	jal	ra,ffffffffc020556c <printfmt>
ffffffffc02054b4:	bb41                	j	ffffffffc0205244 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02054b6:	00002417          	auipc	s0,0x2
ffffffffc02054ba:	d4240413          	addi	s0,s0,-702 # ffffffffc02071f8 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02054be:	85e2                	mv	a1,s8
ffffffffc02054c0:	8522                	mv	a0,s0
ffffffffc02054c2:	e43e                	sd	a5,8(sp)
ffffffffc02054c4:	0e2000ef          	jal	ra,ffffffffc02055a6 <strnlen>
ffffffffc02054c8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02054cc:	01b05b63          	blez	s11,ffffffffc02054e2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02054d0:	67a2                	ld	a5,8(sp)
ffffffffc02054d2:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02054d6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02054d8:	85a6                	mv	a1,s1
ffffffffc02054da:	8552                	mv	a0,s4
ffffffffc02054dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02054de:	fe0d9ce3          	bnez	s11,ffffffffc02054d6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02054e2:	00044783          	lbu	a5,0(s0)
ffffffffc02054e6:	00140a13          	addi	s4,s0,1
ffffffffc02054ea:	0007851b          	sext.w	a0,a5
ffffffffc02054ee:	d3a5                	beqz	a5,ffffffffc020544e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02054f0:	05e00413          	li	s0,94
ffffffffc02054f4:	bf39                	j	ffffffffc0205412 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02054f6:	000a2403          	lw	s0,0(s4)
ffffffffc02054fa:	b7ad                	j	ffffffffc0205464 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02054fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0205500:	46a1                	li	a3,8
ffffffffc0205502:	8a2e                	mv	s4,a1
ffffffffc0205504:	bdb1                	j	ffffffffc0205360 <vprintfmt+0x156>
ffffffffc0205506:	000a6603          	lwu	a2,0(s4)
ffffffffc020550a:	46a9                	li	a3,10
ffffffffc020550c:	8a2e                	mv	s4,a1
ffffffffc020550e:	bd89                	j	ffffffffc0205360 <vprintfmt+0x156>
ffffffffc0205510:	000a6603          	lwu	a2,0(s4)
ffffffffc0205514:	46c1                	li	a3,16
ffffffffc0205516:	8a2e                	mv	s4,a1
ffffffffc0205518:	b5a1                	j	ffffffffc0205360 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020551a:	9902                	jalr	s2
ffffffffc020551c:	bf09                	j	ffffffffc020542e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020551e:	85a6                	mv	a1,s1
ffffffffc0205520:	02d00513          	li	a0,45
ffffffffc0205524:	e03e                	sd	a5,0(sp)
ffffffffc0205526:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205528:	6782                	ld	a5,0(sp)
ffffffffc020552a:	8a66                	mv	s4,s9
ffffffffc020552c:	40800633          	neg	a2,s0
ffffffffc0205530:	46a9                	li	a3,10
ffffffffc0205532:	b53d                	j	ffffffffc0205360 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205534:	03b05163          	blez	s11,ffffffffc0205556 <vprintfmt+0x34c>
ffffffffc0205538:	02d00693          	li	a3,45
ffffffffc020553c:	f6d79de3          	bne	a5,a3,ffffffffc02054b6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205540:	00002417          	auipc	s0,0x2
ffffffffc0205544:	cb840413          	addi	s0,s0,-840 # ffffffffc02071f8 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205548:	02800793          	li	a5,40
ffffffffc020554c:	02800513          	li	a0,40
ffffffffc0205550:	00140a13          	addi	s4,s0,1
ffffffffc0205554:	bd6d                	j	ffffffffc020540e <vprintfmt+0x204>
ffffffffc0205556:	00002a17          	auipc	s4,0x2
ffffffffc020555a:	ca3a0a13          	addi	s4,s4,-861 # ffffffffc02071f9 <syscalls+0x119>
ffffffffc020555e:	02800513          	li	a0,40
ffffffffc0205562:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205566:	05e00413          	li	s0,94
ffffffffc020556a:	b565                	j	ffffffffc0205412 <vprintfmt+0x208>

ffffffffc020556c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020556c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020556e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205572:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205574:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205576:	ec06                	sd	ra,24(sp)
ffffffffc0205578:	f83a                	sd	a4,48(sp)
ffffffffc020557a:	fc3e                	sd	a5,56(sp)
ffffffffc020557c:	e0c2                	sd	a6,64(sp)
ffffffffc020557e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205580:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205582:	c89ff0ef          	jal	ra,ffffffffc020520a <vprintfmt>
}
ffffffffc0205586:	60e2                	ld	ra,24(sp)
ffffffffc0205588:	6161                	addi	sp,sp,80
ffffffffc020558a:	8082                	ret

ffffffffc020558c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020558c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205590:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205592:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205594:	cb81                	beqz	a5,ffffffffc02055a4 <strlen+0x18>
        cnt ++;
ffffffffc0205596:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205598:	00a707b3          	add	a5,a4,a0
ffffffffc020559c:	0007c783          	lbu	a5,0(a5)
ffffffffc02055a0:	fbfd                	bnez	a5,ffffffffc0205596 <strlen+0xa>
ffffffffc02055a2:	8082                	ret
    }
    return cnt;
}
ffffffffc02055a4:	8082                	ret

ffffffffc02055a6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02055a6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02055a8:	e589                	bnez	a1,ffffffffc02055b2 <strnlen+0xc>
ffffffffc02055aa:	a811                	j	ffffffffc02055be <strnlen+0x18>
        cnt ++;
ffffffffc02055ac:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02055ae:	00f58863          	beq	a1,a5,ffffffffc02055be <strnlen+0x18>
ffffffffc02055b2:	00f50733          	add	a4,a0,a5
ffffffffc02055b6:	00074703          	lbu	a4,0(a4)
ffffffffc02055ba:	fb6d                	bnez	a4,ffffffffc02055ac <strnlen+0x6>
ffffffffc02055bc:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02055be:	852e                	mv	a0,a1
ffffffffc02055c0:	8082                	ret

ffffffffc02055c2 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02055c2:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02055c4:	0005c703          	lbu	a4,0(a1)
ffffffffc02055c8:	0785                	addi	a5,a5,1
ffffffffc02055ca:	0585                	addi	a1,a1,1
ffffffffc02055cc:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02055d0:	fb75                	bnez	a4,ffffffffc02055c4 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02055d2:	8082                	ret

ffffffffc02055d4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02055d4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055d8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02055dc:	cb89                	beqz	a5,ffffffffc02055ee <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02055de:	0505                	addi	a0,a0,1
ffffffffc02055e0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02055e2:	fee789e3          	beq	a5,a4,ffffffffc02055d4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055e6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02055ea:	9d19                	subw	a0,a0,a4
ffffffffc02055ec:	8082                	ret
ffffffffc02055ee:	4501                	li	a0,0
ffffffffc02055f0:	bfed                	j	ffffffffc02055ea <strcmp+0x16>

ffffffffc02055f2 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055f2:	c20d                	beqz	a2,ffffffffc0205614 <strncmp+0x22>
ffffffffc02055f4:	962e                	add	a2,a2,a1
ffffffffc02055f6:	a031                	j	ffffffffc0205602 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02055f8:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055fa:	00e79a63          	bne	a5,a4,ffffffffc020560e <strncmp+0x1c>
ffffffffc02055fe:	00b60b63          	beq	a2,a1,ffffffffc0205614 <strncmp+0x22>
ffffffffc0205602:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205606:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205608:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020560c:	f7f5                	bnez	a5,ffffffffc02055f8 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020560e:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205612:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205614:	4501                	li	a0,0
ffffffffc0205616:	8082                	ret

ffffffffc0205618 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205618:	00054783          	lbu	a5,0(a0)
ffffffffc020561c:	c799                	beqz	a5,ffffffffc020562a <strchr+0x12>
        if (*s == c) {
ffffffffc020561e:	00f58763          	beq	a1,a5,ffffffffc020562c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0205622:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0205626:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205628:	fbfd                	bnez	a5,ffffffffc020561e <strchr+0x6>
    }
    return NULL;
ffffffffc020562a:	4501                	li	a0,0
}
ffffffffc020562c:	8082                	ret

ffffffffc020562e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020562e:	ca01                	beqz	a2,ffffffffc020563e <memset+0x10>
ffffffffc0205630:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205632:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205634:	0785                	addi	a5,a5,1
ffffffffc0205636:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020563a:	fec79de3          	bne	a5,a2,ffffffffc0205634 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020563e:	8082                	ret

ffffffffc0205640 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205640:	ca19                	beqz	a2,ffffffffc0205656 <memcpy+0x16>
ffffffffc0205642:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205644:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205646:	0005c703          	lbu	a4,0(a1)
ffffffffc020564a:	0585                	addi	a1,a1,1
ffffffffc020564c:	0785                	addi	a5,a5,1
ffffffffc020564e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205652:	fec59ae3          	bne	a1,a2,ffffffffc0205646 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205656:	8082                	ret
