
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
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
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	23c50513          	addi	a0,a0,572 # ffffffffc0202288 <etext+0x6>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	24650513          	addi	a0,a0,582 # ffffffffc02022a8 <etext+0x26>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	21458593          	addi	a1,a1,532 # ffffffffc0202282 <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	25250513          	addi	a0,a0,594 # ffffffffc02022c8 <etext+0x46>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00007597          	auipc	a1,0x7
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0207018 <allowed>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	25e50513          	addi	a0,a0,606 # ffffffffc02022e8 <etext+0x66>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00008597          	auipc	a1,0x8
ffffffffc020009a:	e4a58593          	addi	a1,a1,-438 # ffffffffc0207ee0 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	26a50513          	addi	a0,a0,618 # ffffffffc0202308 <etext+0x86>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00008597          	auipc	a1,0x8
ffffffffc02000ae:	23558593          	addi	a1,a1,565 # ffffffffc02082df <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	25c50513          	addi	a0,a0,604 # ffffffffc0202328 <etext+0xa6>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00007517          	auipc	a0,0x7
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0207018 <allowed>
ffffffffc02000e0:	00008617          	auipc	a2,0x8
ffffffffc02000e4:	e0060613          	addi	a2,a2,-512 # ffffffffc0207ee0 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	144020ef          	jal	ra,ffffffffc0202234 <memset>
    dtb_init();
ffffffffc02000f4:	12c000ef          	jal	ra,ffffffffc0200220 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	11e000ef          	jal	ra,ffffffffc0200216 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	25c50513          	addi	a0,a0,604 # ffffffffc0202358 <etext+0xd6>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	275010ef          	jal	ra,ffffffffc0201b80 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	0fe000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	4df010ef          	jal	ra,ffffffffc0201e1e <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	4a9010ef          	jal	ra,ffffffffc0201e1e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	080000ef          	jal	ra,ffffffffc0200218 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ra,ffffffffc0200218 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00008317          	auipc	t1,0x8
ffffffffc02001c6:	cce30313          	addi	t1,t1,-818 # ffffffffc0207e90 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	18650513          	addi	a0,a0,390 # ffffffffc0202378 <etext+0xf6>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00003517          	auipc	a0,0x3
ffffffffc020020c:	9f050513          	addi	a0,a0,-1552 # ffffffffc0202bf8 <etext+0x976>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	7850106f          	j	ffffffffc02021a0 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200220:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	17650513          	addi	a0,a0,374 # ffffffffc0202398 <etext+0x116>
void dtb_init(void) {
ffffffffc020022a:	fc86                	sd	ra,120(sp)
ffffffffc020022c:	f8a2                	sd	s0,112(sp)
ffffffffc020022e:	e8d2                	sd	s4,80(sp)
ffffffffc0200230:	f4a6                	sd	s1,104(sp)
ffffffffc0200232:	f0ca                	sd	s2,96(sp)
ffffffffc0200234:	ecce                	sd	s3,88(sp)
ffffffffc0200236:	e4d6                	sd	s5,72(sp)
ffffffffc0200238:	e0da                	sd	s6,64(sp)
ffffffffc020023a:	fc5e                	sd	s7,56(sp)
ffffffffc020023c:	f862                	sd	s8,48(sp)
ffffffffc020023e:	f466                	sd	s9,40(sp)
ffffffffc0200240:	f06a                	sd	s10,32(sp)
ffffffffc0200242:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200244:	f09ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200248:	00007597          	auipc	a1,0x7
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200250:	00002517          	auipc	a0,0x2
ffffffffc0200254:	15850513          	addi	a0,a0,344 # ffffffffc02023a8 <etext+0x126>
ffffffffc0200258:	ef5ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	00007417          	auipc	s0,0x7
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0207008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00002517          	auipc	a0,0x2
ffffffffc020026a:	15250513          	addi	a0,a0,338 # ffffffffc02023b8 <etext+0x136>
ffffffffc020026e:	edfff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	15a50513          	addi	a0,a0,346 # ffffffffc02023d0 <etext+0x14e>
    if (boot_dtb == 0) {
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020028a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002bc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed800d>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002ca:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f4:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200302:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200320:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200326:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200328:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020032e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200330:	00002917          	auipc	s2,0x2
ffffffffc0200334:	0f090913          	addi	s2,s2,240 # ffffffffc0202420 <etext+0x19e>
ffffffffc0200338:	49bd                	li	s3,15
        switch (token) {
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020033e:	00002497          	auipc	s1,0x2
ffffffffc0200342:	0da48493          	addi	s1,s1,218 # ffffffffc0202418 <etext+0x196>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200392:	00002517          	auipc	a0,0x2
ffffffffc0200396:	10650513          	addi	a0,a0,262 # ffffffffc0202498 <etext+0x216>
ffffffffc020039a:	db3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	13250513          	addi	a0,a0,306 # ffffffffc02024d0 <etext+0x24e>
}
ffffffffc02003a6:	7446                	ld	s0,112(sp)
ffffffffc02003a8:	70e6                	ld	ra,120(sp)
ffffffffc02003aa:	74a6                	ld	s1,104(sp)
ffffffffc02003ac:	7906                	ld	s2,96(sp)
ffffffffc02003ae:	69e6                	ld	s3,88(sp)
ffffffffc02003b0:	6a46                	ld	s4,80(sp)
ffffffffc02003b2:	6aa6                	ld	s5,72(sp)
ffffffffc02003b4:	6b06                	ld	s6,64(sp)
ffffffffc02003b6:	7be2                	ld	s7,56(sp)
ffffffffc02003b8:	7c42                	ld	s8,48(sp)
ffffffffc02003ba:	7ca2                	ld	s9,40(sp)
ffffffffc02003bc:	7d02                	ld	s10,32(sp)
ffffffffc02003be:	6de2                	ld	s11,24(sp)
ffffffffc02003c0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003c4:	7446                	ld	s0,112(sp)
ffffffffc02003c6:	70e6                	ld	ra,120(sp)
ffffffffc02003c8:	74a6                	ld	s1,104(sp)
ffffffffc02003ca:	7906                	ld	s2,96(sp)
ffffffffc02003cc:	69e6                	ld	s3,88(sp)
ffffffffc02003ce:	6a46                	ld	s4,80(sp)
ffffffffc02003d0:	6aa6                	ld	s5,72(sp)
ffffffffc02003d2:	6b06                	ld	s6,64(sp)
ffffffffc02003d4:	7be2                	ld	s7,56(sp)
ffffffffc02003d6:	7c42                	ld	s8,48(sp)
ffffffffc02003d8:	7ca2                	ld	s9,40(sp)
ffffffffc02003da:	7d02                	ld	s10,32(sp)
ffffffffc02003dc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	01250513          	addi	a0,a0,18 # ffffffffc02023f0 <etext+0x16e>
}
ffffffffc02003e6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	5cf010ef          	jal	ra,ffffffffc02021ba <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003f8:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003fa:	615010ef          	jal	ra,ffffffffc020220e <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200400:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020042e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	561010ef          	jal	ra,ffffffffc02021f0 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02004a4:	00002517          	auipc	a0,0x2
ffffffffc02004a8:	f8450513          	addi	a0,a0,-124 # ffffffffc0202428 <etext+0x1a6>
           fdt32_to_cpu(x >> 32);
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200532:	011b78b3          	and	a7,s6,a7
ffffffffc0200536:	005eeeb3          	or	t4,t4,t0
ffffffffc020053a:	00c6e733          	or	a4,a3,a2
ffffffffc020053e:	006c6c33          	or	s8,s8,t1
ffffffffc0200542:	010b76b3          	and	a3,s6,a6
ffffffffc0200546:	00bb7b33          	and	s6,s6,a1
ffffffffc020054a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020054e:	016c6b33          	or	s6,s8,s6
ffffffffc0200552:	01146433          	or	s0,s0,a7
ffffffffc0200556:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020055e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200560:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020056c:	be1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	ed650513          	addi	a0,a0,-298 # ffffffffc0202448 <etext+0x1c6>
ffffffffc020057a:	bd3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00002517          	auipc	a0,0x2
ffffffffc0200588:	edc50513          	addi	a0,a0,-292 # ffffffffc0202460 <etext+0x1de>
ffffffffc020058c:	bc1ff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00002517          	auipc	a0,0x2
ffffffffc020059a:	eea50513          	addi	a0,a0,-278 # ffffffffc0202480 <etext+0x1fe>
ffffffffc020059e:	bafff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	f2e50513          	addi	a0,a0,-210 # ffffffffc02024d0 <etext+0x24e>
        memory_base = mem_base;
ffffffffc02005aa:	00008797          	auipc	a5,0x8
ffffffffc02005ae:	8e87b723          	sd	s0,-1810(a5) # ffffffffc0207e98 <memory_base>
        memory_size = mem_size;
ffffffffc02005b2:	00008797          	auipc	a5,0x8
ffffffffc02005b6:	8f67b723          	sd	s6,-1810(a5) # ffffffffc0207ea0 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005bc:	00008517          	auipc	a0,0x8
ffffffffc02005c0:	8dc53503          	ld	a0,-1828(a0) # ffffffffc0207e98 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005c6:	00008517          	auipc	a0,0x8
ffffffffc02005ca:	8da53503          	ld	a0,-1830(a0) # ffffffffc0207ea0 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
    return order;
}

static void
buddy_init(void) {
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) list_init(&buddy.lists[k]);
ffffffffc02005d0:	00007697          	auipc	a3,0x7
ffffffffc02005d4:	a6868693          	addi	a3,a3,-1432 # ffffffffc0207038 <buddy>
ffffffffc02005d8:	87b6                	mv	a5,a3
ffffffffc02005da:	00007717          	auipc	a4,0x7
ffffffffc02005de:	bae70713          	addi	a4,a4,-1106 # ffffffffc0207188 <buddy+0x150>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005e2:	e79c                	sd	a5,8(a5)
ffffffffc02005e4:	e39c                	sd	a5,0(a5)
ffffffffc02005e6:	07c1                	addi	a5,a5,16
ffffffffc02005e8:	fee79de3          	bne	a5,a4,ffffffffc02005e2 <buddy_init+0x12>
    buddy.nr_free = 0;
ffffffffc02005ec:	00007797          	auipc	a5,0x7
ffffffffc02005f0:	b807be23          	sd	zero,-1124(a5) # ffffffffc0207188 <buddy+0x150>
    buddy.first = npage;
ffffffffc02005f4:	00008797          	auipc	a5,0x8
ffffffffc02005f8:	8bc7b783          	ld	a5,-1860(a5) # ffffffffc0207eb0 <npage>
ffffffffc02005fc:	14f6bc23          	sd	a5,344(a3)
    buddy.end = nbase;
ffffffffc0200600:	00003797          	auipc	a5,0x3
ffffffffc0200604:	a687b783          	ld	a5,-1432(a5) # ffffffffc0203068 <nbase>
ffffffffc0200608:	16f6b023          	sd	a5,352(a3)
}
ffffffffc020060c:	8082                	ret

ffffffffc020060e <free_partner>:
// Validate the entire candidate before forming/dereferencing its descriptor.
// Reserved holes have no free-head flag and can never be merged across.
static struct Page *
free_partner(ppn_t ppn, int k) {
    size_t size = 1UL << k;
    if (ppn < nbase || ppn < buddy.first || ppn >= npage ||
ffffffffc020060e:	00003697          	auipc	a3,0x3
ffffffffc0200612:	a5a6b683          	ld	a3,-1446(a3) # ffffffffc0203068 <nbase>
ffffffffc0200616:	06d56263          	bltu	a0,a3,ffffffffc020067a <free_partner+0x6c>
ffffffffc020061a:	00007717          	auipc	a4,0x7
ffffffffc020061e:	a1e70713          	addi	a4,a4,-1506 # ffffffffc0207038 <buddy>
ffffffffc0200622:	15873783          	ld	a5,344(a4)
ffffffffc0200626:	04f56a63          	bltu	a0,a5,ffffffffc020067a <free_partner+0x6c>
ffffffffc020062a:	00008797          	auipc	a5,0x8
ffffffffc020062e:	8867b783          	ld	a5,-1914(a5) # ffffffffc0207eb0 <npage>
ffffffffc0200632:	04f57463          	bgeu	a0,a5,ffffffffc020067a <free_partner+0x6c>
        ppn >= buddy.end || size > npage - ppn || size > buddy.end - ppn)
ffffffffc0200636:	16073603          	ld	a2,352(a4)
    if (ppn < nbase || ppn < buddy.first || ppn >= npage ||
ffffffffc020063a:	04c57063          	bgeu	a0,a2,ffffffffc020067a <free_partner+0x6c>
    size_t size = 1UL << k;
ffffffffc020063e:	4705                	li	a4,1
ffffffffc0200640:	00b715b3          	sll	a1,a4,a1
        ppn >= buddy.end || size > npage - ppn || size > buddy.end - ppn)
ffffffffc0200644:	8f89                	sub	a5,a5,a0
ffffffffc0200646:	02b7ea63          	bltu	a5,a1,ffffffffc020067a <free_partner+0x6c>
ffffffffc020064a:	8e09                	sub	a2,a2,a0
ffffffffc020064c:	02b66763          	bltu	a2,a1,ffffffffc020067a <free_partner+0x6c>
        return NULL;
    struct Page *p = pages + (ppn - nbase);
ffffffffc0200650:	8d15                	sub	a0,a0,a3
ffffffffc0200652:	00251793          	slli	a5,a0,0x2
ffffffffc0200656:	953e                	add	a0,a0,a5
ffffffffc0200658:	00351793          	slli	a5,a0,0x3
ffffffffc020065c:	00008517          	auipc	a0,0x8
ffffffffc0200660:	85c53503          	ld	a0,-1956(a0) # ffffffffc0207eb8 <pages>
ffffffffc0200664:	953e                	add	a0,a0,a5
    return !PageReserved(p) && PageProperty(p) && p->property == size ? p : NULL;
ffffffffc0200666:	651c                	ld	a5,8(a0)
ffffffffc0200668:	4709                	li	a4,2
ffffffffc020066a:	8b8d                	andi	a5,a5,3
ffffffffc020066c:	00e79763          	bne	a5,a4,ffffffffc020067a <free_partner+0x6c>
ffffffffc0200670:	01056783          	lwu	a5,16(a0)
ffffffffc0200674:	00b79363          	bne	a5,a1,ffffffffc020067a <free_partner+0x6c>
}
ffffffffc0200678:	8082                	ret
    return !PageReserved(p) && PageProperty(p) && p->property == size ? p : NULL;
ffffffffc020067a:	4501                	li	a0,0
}
ffffffffc020067c:	8082                	ret

ffffffffc020067e <insert_merge>:

static void
insert_merge(struct Page *base, int k) {
ffffffffc020067e:	715d                	addi	sp,sp,-80
ffffffffc0200680:	e0a2                	sd	s0,64(sp)
ffffffffc0200682:	e85a                	sd	s6,16(sp)
ffffffffc0200684:	e486                	sd	ra,72(sp)
ffffffffc0200686:	fc26                	sd	s1,56(sp)
ffffffffc0200688:	f84a                	sd	s2,48(sp)
ffffffffc020068a:	f44e                	sd	s3,40(sp)
ffffffffc020068c:	f052                	sd	s4,32(sp)
ffffffffc020068e:	ec56                	sd	s5,24(sp)
ffffffffc0200690:	e45e                	sd	s7,8(sp)
    while (k < BUDDY_MAX_ORDER) {
ffffffffc0200692:	47cd                	li	a5,19
insert_merge(struct Page *base, int k) {
ffffffffc0200694:	842e                	mv	s0,a1
ffffffffc0200696:	8b2a                	mv	s6,a0
    while (k < BUDDY_MAX_ORDER) {
ffffffffc0200698:	0ab7c563          	blt	a5,a1,ffffffffc0200742 <insert_merge+0xc4>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020069c:	00008a17          	auipc	s4,0x8
ffffffffc02006a0:	81ca3a03          	ld	s4,-2020(s4) # ffffffffc0207eb8 <pages>
ffffffffc02006a4:	00003997          	auipc	s3,0x3
ffffffffc02006a8:	9c49b983          	ld	s3,-1596(s3) # ffffffffc0203068 <nbase>
ffffffffc02006ac:	00003917          	auipc	s2,0x3
ffffffffc02006b0:	9ac93903          	ld	s2,-1620(s2) # ffffffffc0203058 <error_string+0x38>
        struct Page *other = free_partner(page2ppn(base) ^ (1UL << k), k);
ffffffffc02006b4:	4485                	li	s1,1
    while (k < BUDDY_MAX_ORDER) {
ffffffffc02006b6:	4ad1                	li	s5,20
ffffffffc02006b8:	414b0533          	sub	a0,s6,s4
ffffffffc02006bc:	850d                	srai	a0,a0,0x3
ffffffffc02006be:	03250533          	mul	a0,a0,s2
        struct Page *other = free_partner(page2ppn(base) ^ (1UL << k), k);
ffffffffc02006c2:	00849bb3          	sll	s7,s1,s0
ffffffffc02006c6:	85a2                	mv	a1,s0
ffffffffc02006c8:	954e                	add	a0,a0,s3
ffffffffc02006ca:	01754533          	xor	a0,a0,s7
ffffffffc02006ce:	f41ff0ef          	jal	ra,ffffffffc020060e <free_partner>
        if (other == NULL) break;
        list_del_init(&other->page_link);
ffffffffc02006d2:	01850713          	addi	a4,a0,24
        if (other == NULL) break;
ffffffffc02006d6:	c505                	beqz	a0,ffffffffc02006fe <insert_merge+0x80>
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
ffffffffc02006d8:	6d10                	ld	a2,24(a0)
ffffffffc02006da:	7114                	ld	a3,32(a0)
        ClearPageProperty(other);
ffffffffc02006dc:	651c                	ld	a5,8(a0)
        other->property = 0;
        if (other < base) base = other;
        k++;
ffffffffc02006de:	2405                	addiw	s0,s0,1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02006e0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02006e2:	e290                	sd	a2,0(a3)
        ClearPageProperty(other);
ffffffffc02006e4:	9bf5                	andi	a5,a5,-3
    elm->prev = elm->next = elm;
ffffffffc02006e6:	f118                	sd	a4,32(a0)
ffffffffc02006e8:	ed18                	sd	a4,24(a0)
ffffffffc02006ea:	e51c                	sd	a5,8(a0)
        other->property = 0;
ffffffffc02006ec:	00052823          	sw	zero,16(a0)
        if (other < base) base = other;
ffffffffc02006f0:	01657363          	bgeu	a0,s6,ffffffffc02006f6 <insert_merge+0x78>
ffffffffc02006f4:	8b2a                	mv	s6,a0
    while (k < BUDDY_MAX_ORDER) {
ffffffffc02006f6:	fd5411e3          	bne	s0,s5,ffffffffc02006b8 <insert_merge+0x3a>
ffffffffc02006fa:	00100bb7          	lui	s7,0x100
    }
    base->property = 1UL << k;
    SetPageProperty(base);
ffffffffc02006fe:	008b3783          	ld	a5,8(s6) # 10008 <kern_entry-0xffffffffc01efff8>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200702:	0412                	slli	s0,s0,0x4
ffffffffc0200704:	00007597          	auipc	a1,0x7
ffffffffc0200708:	93458593          	addi	a1,a1,-1740 # ffffffffc0207038 <buddy>
ffffffffc020070c:	942e                	add	s0,s0,a1
ffffffffc020070e:	6418                	ld	a4,8(s0)
ffffffffc0200710:	0027e793          	ori	a5,a5,2
    base->property = 1UL << k;
ffffffffc0200714:	017b2823          	sw	s7,16(s6)
    SetPageProperty(base);
ffffffffc0200718:	00fb3423          	sd	a5,8(s6)
    list_add(&buddy.lists[k], &base->page_link);
ffffffffc020071c:	018b0793          	addi	a5,s6,24
    prev->next = next->prev = elm;
ffffffffc0200720:	e31c                	sd	a5,0(a4)
ffffffffc0200722:	e41c                	sd	a5,8(s0)
    elm->prev = prev;
ffffffffc0200724:	008b3c23          	sd	s0,24(s6)
}
ffffffffc0200728:	60a6                	ld	ra,72(sp)
ffffffffc020072a:	6406                	ld	s0,64(sp)
    elm->next = next;
ffffffffc020072c:	02eb3023          	sd	a4,32(s6)
ffffffffc0200730:	74e2                	ld	s1,56(sp)
ffffffffc0200732:	7942                	ld	s2,48(sp)
ffffffffc0200734:	79a2                	ld	s3,40(sp)
ffffffffc0200736:	7a02                	ld	s4,32(sp)
ffffffffc0200738:	6ae2                	ld	s5,24(sp)
ffffffffc020073a:	6b42                	ld	s6,16(sp)
ffffffffc020073c:	6ba2                	ld	s7,8(sp)
ffffffffc020073e:	6161                	addi	sp,sp,80
ffffffffc0200740:	8082                	ret
        struct Page *other = free_partner(page2ppn(base) ^ (1UL << k), k);
ffffffffc0200742:	4b85                	li	s7,1
ffffffffc0200744:	00bb9bb3          	sll	s7,s7,a1
ffffffffc0200748:	bf5d                	j	ffffffffc02006fe <insert_merge+0x80>

ffffffffc020074a <buddy_nr_free_pages>:
    buddy.nr_free += size;
    insert_merge(base, k);
}

static size_t
buddy_nr_free_pages(void) { return buddy.nr_free; }
ffffffffc020074a:	00007517          	auipc	a0,0x7
ffffffffc020074e:	a3e53503          	ld	a0,-1474(a0) # ffffffffc0207188 <buddy+0x150>
ffffffffc0200752:	8082                	ret

ffffffffc0200754 <check_consistency>:
static unsigned char allowed[TEST_PAGES], occupied[TEST_PAGES];
static struct buddy_state saved_state, failure_state;
static struct Page saved_pages[TEST_PAGES], failure_pages[TEST_PAGES];

static void
check_consistency(void) {
ffffffffc0200754:	7131                	addi	sp,sp,-192
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
            assert(list_prev(list_next(le)) == le && list_next(list_prev(le)) == le);
            struct Page *p = le2page(le, page_link);
            size_t size = 1UL << k;
            ppn_t ppn = page2ppn(p);
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
ffffffffc0200756:	00007317          	auipc	t1,0x7
ffffffffc020075a:	8e230313          	addi	t1,t1,-1822 # ffffffffc0207038 <buddy>
check_consistency(void) {
ffffffffc020075e:	f0ea                	sd	s10,96(sp)
ffffffffc0200760:	ecee                	sd	s11,88(sp)
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
ffffffffc0200762:	00003e17          	auipc	t3,0x3
ffffffffc0200766:	906e3e03          	ld	t3,-1786(t3) # ffffffffc0203068 <nbase>
ffffffffc020076a:	00007d97          	auipc	s11,0x7
ffffffffc020076e:	746dbd83          	ld	s11,1862(s11) # ffffffffc0207eb0 <npage>
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
ffffffffc0200772:	15833f83          	ld	t6,344(t1)
ffffffffc0200776:	16033d03          	ld	s10,352(t1)
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
ffffffffc020077a:	41cd8db3          	sub	s11,s11,t3
check_consistency(void) {
ffffffffc020077e:	ed4e                	sd	s3,152(sp)
ffffffffc0200780:	e952                	sd	s4,144(sp)
ffffffffc0200782:	fcde                	sd	s7,120(sp)
ffffffffc0200784:	f8e2                	sd	s8,112(sp)
ffffffffc0200786:	f4e6                	sd	s9,104(sp)
ffffffffc0200788:	fd06                	sd	ra,184(sp)
ffffffffc020078a:	f922                	sd	s0,176(sp)
ffffffffc020078c:	f526                	sd	s1,168(sp)
ffffffffc020078e:	f14a                	sd	s2,160(sp)
ffffffffc0200790:	e556                	sd	s5,136(sp)
ffffffffc0200792:	e15a                	sd	s6,128(sp)
ffffffffc0200794:	00007f17          	auipc	t5,0x7
ffffffffc0200798:	724f3f03          	ld	t5,1828(t5) # ffffffffc0207eb8 <pages>
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
ffffffffc020079c:	889a                	mv	a7,t1
ffffffffc020079e:	4c01                	li	s8,0
    size_t total = 0, blocks = 0;
ffffffffc02007a0:	4b81                	li	s7,0
ffffffffc02007a2:	4c81                	li	s9,0
            // Every other block is disjoint, including blocks of another order.
            for (int j = k; j <= BUDDY_MAX_ORDER; j++) {
                list_entry_t *h = &buddy.lists[j];
                for (list_entry_t *q = list_next(h); q != h; q = list_next(q)) {
                    struct Page *other = le2page(q, page_link);
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc02007a4:	02800a13          	li	s4,40
ffffffffc02007a8:	00003e97          	auipc	t4,0x3
ffffffffc02007ac:	8b0ebe83          	ld	t4,-1872(t4) # ffffffffc0203058 <error_string+0x38>
            for (int j = k; j <= BUDDY_MAX_ORDER; j++) {
ffffffffc02007b0:	49d5                	li	s3,21
ffffffffc02007b2:	83ee                	mv	t2,s11
    return listelm->next;
ffffffffc02007b4:	0088bd83          	ld	s11,8(a7)
ffffffffc02007b8:	000c059b          	sext.w	a1,s8
        for (list_entry_t *le = list_next(head); le != head; le = list_next(le)) {
ffffffffc02007bc:	131d8363          	beq	s11,a7,ffffffffc02008e2 <check_consistency+0x18e>
ffffffffc02007c0:	004c1b13          	slli	s6,s8,0x4
            size_t size = 1UL << k;
ffffffffc02007c4:	4785                	li	a5,1
ffffffffc02007c6:	9b1a                	add	s6,s6,t1
ffffffffc02007c8:	00b79933          	sll	s2,a5,a1
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc02007cc:	846e                	mv	s0,s11
ffffffffc02007ce:	e4c6                	sd	a7,72(sp)
            assert((ppn & (size - 1)) == 0 && PageProperty(p) && p->property == size);
ffffffffc02007d0:	fff90293          	addi	t0,s2,-1
ffffffffc02007d4:	88ee                	mv	a7,s11
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc02007d6:	00ba1833          	sll	a6,s4,a1
ffffffffc02007da:	8df2                	mv	s11,t3
ffffffffc02007dc:	8e62                	mv	t3,s8
ffffffffc02007de:	8c5a                	mv	s8,s6
ffffffffc02007e0:	8b1e                	mv	s6,t2
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
ffffffffc02007e2:	0b85                	addi	s7,s7,1
ffffffffc02007e4:	237b6663          	bltu	s6,s7,ffffffffc0200a10 <check_consistency+0x2bc>
ffffffffc02007e8:	00843a83          	ld	s5,8(s0)
            assert(list_prev(list_next(le)) == le && list_next(list_prev(le)) == le);
ffffffffc02007ec:	000ab783          	ld	a5,0(s5)
ffffffffc02007f0:	20879063          	bne	a5,s0,ffffffffc02009f0 <check_consistency+0x29c>
ffffffffc02007f4:	601c                	ld	a5,0(s0)
ffffffffc02007f6:	679c                	ld	a5,8(a5)
ffffffffc02007f8:	1e879c63          	bne	a5,s0,ffffffffc02009f0 <check_consistency+0x29c>
            struct Page *p = le2page(le, page_link);
ffffffffc02007fc:	fe840493          	addi	s1,s0,-24
ffffffffc0200800:	41e48533          	sub	a0,s1,t5
ffffffffc0200804:	850d                	srai	a0,a0,0x3
ffffffffc0200806:	03d50533          	mul	a0,a0,t4
ffffffffc020080a:	956e                	add	a0,a0,s11
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
ffffffffc020080c:	1df56263          	bltu	a0,t6,ffffffffc02009d0 <check_consistency+0x27c>
ffffffffc0200810:	1da57063          	bgeu	a0,s10,ffffffffc02009d0 <check_consistency+0x27c>
ffffffffc0200814:	40ad07b3          	sub	a5,s10,a0
ffffffffc0200818:	1b27ec63          	bltu	a5,s2,ffffffffc02009d0 <check_consistency+0x27c>
            assert((ppn & (size - 1)) == 0 && PageProperty(p) && p->property == size);
ffffffffc020081c:	00a2f7b3          	and	a5,t0,a0
ffffffffc0200820:	18079863          	bnez	a5,ffffffffc02009b0 <check_consistency+0x25c>
ffffffffc0200824:	ff043703          	ld	a4,-16(s0)
ffffffffc0200828:	8b09                	andi	a4,a4,2
ffffffffc020082a:	18070363          	beqz	a4,ffffffffc02009b0 <check_consistency+0x25c>
ffffffffc020082e:	ff846703          	lwu	a4,-8(s0)
ffffffffc0200832:	17271f63          	bne	a4,s2,ffffffffc02009b0 <check_consistency+0x25c>
            if (k < BUDDY_MAX_ORDER) assert(free_partner(ppn ^ size, k) == NULL);
ffffffffc0200836:	4751                	li	a4,20
ffffffffc0200838:	04ee0263          	beq	t3,a4,ffffffffc020087c <check_consistency+0x128>
ffffffffc020083c:	00a94533          	xor	a0,s2,a0
ffffffffc0200840:	e0f2                	sd	t3,64(sp)
ffffffffc0200842:	fc46                	sd	a7,56(sp)
ffffffffc0200844:	f87a                	sd	t5,48(sp)
ffffffffc0200846:	f442                	sd	a6,40(sp)
ffffffffc0200848:	f016                	sd	t0,32(sp)
ffffffffc020084a:	ec7e                	sd	t6,24(sp)
ffffffffc020084c:	e83e                	sd	a5,16(sp)
ffffffffc020084e:	e42e                	sd	a1,8(sp)
ffffffffc0200850:	dbfff0ef          	jal	ra,ffffffffc020060e <free_partner>
ffffffffc0200854:	00003717          	auipc	a4,0x3
ffffffffc0200858:	80470713          	addi	a4,a4,-2044 # ffffffffc0203058 <error_string+0x38>
ffffffffc020085c:	65a2                	ld	a1,8(sp)
ffffffffc020085e:	67c2                	ld	a5,16(sp)
ffffffffc0200860:	00073e83          	ld	t4,0(a4)
ffffffffc0200864:	6fe2                	ld	t6,24(sp)
ffffffffc0200866:	7282                	ld	t0,32(sp)
ffffffffc0200868:	7822                	ld	a6,40(sp)
ffffffffc020086a:	7f42                	ld	t5,48(sp)
ffffffffc020086c:	78e2                	ld	a7,56(sp)
ffffffffc020086e:	6e06                	ld	t3,64(sp)
ffffffffc0200870:	00006317          	auipc	t1,0x6
ffffffffc0200874:	7c830313          	addi	t1,t1,1992 # ffffffffc0207038 <buddy>
ffffffffc0200878:	10051c63          	bnez	a0,ffffffffc0200990 <check_consistency+0x23c>
ffffffffc020087c:	8726                	mv	a4,s1
                assert(!PageReserved(p + i) && page_ref(p + i) == 0);
ffffffffc020087e:	6714                	ld	a3,8(a4)
ffffffffc0200880:	0016f613          	andi	a2,a3,1
ffffffffc0200884:	e655                	bnez	a2,ffffffffc0200930 <check_consistency+0x1dc>
ffffffffc0200886:	4310                	lw	a2,0(a4)
ffffffffc0200888:	e645                	bnez	a2,ffffffffc0200930 <check_consistency+0x1dc>
                if (i != 0) assert(!PageProperty(p + i));
ffffffffc020088a:	c399                	beqz	a5,ffffffffc0200890 <check_consistency+0x13c>
ffffffffc020088c:	8a89                	andi	a3,a3,2
ffffffffc020088e:	e2e9                	bnez	a3,ffffffffc0200950 <check_consistency+0x1fc>
            for (size_t i = 0; i < size; i++) {
ffffffffc0200890:	0785                	addi	a5,a5,1
ffffffffc0200892:	02870713          	addi	a4,a4,40
ffffffffc0200896:	ff27e4e3          	bltu	a5,s2,ffffffffc020087e <check_consistency+0x12a>
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc020089a:	01048633          	add	a2,s1,a6
ffffffffc020089e:	86e2                	mv	a3,s8
ffffffffc02008a0:	87c6                	mv	a5,a7
ffffffffc02008a2:	80ae                	mv	ra,a1
                for (list_entry_t *q = list_next(h); q != h; q = list_next(q)) {
ffffffffc02008a4:	02d78063          	beq	a5,a3,ffffffffc02008c4 <check_consistency+0x170>
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc02008a8:	001a1533          	sll	a0,s4,ra
ffffffffc02008ac:	00878963          	beq	a5,s0,ffffffffc02008be <check_consistency+0x16a>
                    struct Page *other = le2page(q, page_link);
ffffffffc02008b0:	fe878713          	addi	a4,a5,-24
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc02008b4:	00c77563          	bgeu	a4,a2,ffffffffc02008be <check_consistency+0x16a>
ffffffffc02008b8:	972a                	add	a4,a4,a0
ffffffffc02008ba:	04e4eb63          	bltu	s1,a4,ffffffffc0200910 <check_consistency+0x1bc>
ffffffffc02008be:	679c                	ld	a5,8(a5)
                for (list_entry_t *q = list_next(h); q != h; q = list_next(q)) {
ffffffffc02008c0:	fed796e3          	bne	a5,a3,ffffffffc02008ac <check_consistency+0x158>
            for (int j = k; j <= BUDDY_MAX_ORDER; j++) {
ffffffffc02008c4:	2085                	addiw	ra,ra,1
ffffffffc02008c6:	06c1                	addi	a3,a3,16
ffffffffc02008c8:	01308463          	beq	ra,s3,ffffffffc02008d0 <check_consistency+0x17c>
ffffffffc02008cc:	669c                	ld	a5,8(a3)
ffffffffc02008ce:	bfd9                	j	ffffffffc02008a4 <check_consistency+0x150>
                }
            }
            total += size;
ffffffffc02008d0:	9cca                	add	s9,s9,s2
        for (list_entry_t *le = list_next(head); le != head; le = list_next(le)) {
ffffffffc02008d2:	018a8463          	beq	s5,s8,ffffffffc02008da <check_consistency+0x186>
ffffffffc02008d6:	8456                	mv	s0,s5
ffffffffc02008d8:	b729                	j	ffffffffc02007e2 <check_consistency+0x8e>
ffffffffc02008da:	68a6                	ld	a7,72(sp)
ffffffffc02008dc:	8c72                	mv	s8,t3
ffffffffc02008de:	83da                	mv	t2,s6
ffffffffc02008e0:	8e6e                	mv	t3,s11
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
ffffffffc02008e2:	0c05                	addi	s8,s8,1
ffffffffc02008e4:	08c1                	addi	a7,a7,16
ffffffffc02008e6:	ed3c17e3          	bne	s8,s3,ffffffffc02007b4 <check_consistency+0x60>
        }
    }
    assert(total == nr_free_pages());
ffffffffc02008ea:	28a010ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02008ee:	09951163          	bne	a0,s9,ffffffffc0200970 <check_consistency+0x21c>
}
ffffffffc02008f2:	70ea                	ld	ra,184(sp)
ffffffffc02008f4:	744a                	ld	s0,176(sp)
ffffffffc02008f6:	74aa                	ld	s1,168(sp)
ffffffffc02008f8:	790a                	ld	s2,160(sp)
ffffffffc02008fa:	69ea                	ld	s3,152(sp)
ffffffffc02008fc:	6a4a                	ld	s4,144(sp)
ffffffffc02008fe:	6aaa                	ld	s5,136(sp)
ffffffffc0200900:	6b0a                	ld	s6,128(sp)
ffffffffc0200902:	7be6                	ld	s7,120(sp)
ffffffffc0200904:	7c46                	ld	s8,112(sp)
ffffffffc0200906:	7ca6                	ld	s9,104(sp)
ffffffffc0200908:	7d06                	ld	s10,96(sp)
ffffffffc020090a:	6de6                	ld	s11,88(sp)
ffffffffc020090c:	6129                	addi	sp,sp,192
ffffffffc020090e:	8082                	ret
                    if (q != le) assert(p + size <= other || other + (1UL << j) <= p);
ffffffffc0200910:	00002697          	auipc	a3,0x2
ffffffffc0200914:	d7068693          	addi	a3,a3,-656 # ffffffffc0202680 <etext+0x3fe>
ffffffffc0200918:	00002617          	auipc	a2,0x2
ffffffffc020091c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0202508 <etext+0x286>
ffffffffc0200920:	0a900593          	li	a1,169
ffffffffc0200924:	00002517          	auipc	a0,0x2
ffffffffc0200928:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0202520 <etext+0x29e>
ffffffffc020092c:	897ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
                assert(!PageReserved(p + i) && page_ref(p + i) == 0);
ffffffffc0200930:	00002697          	auipc	a3,0x2
ffffffffc0200934:	d0868693          	addi	a3,a3,-760 # ffffffffc0202638 <etext+0x3b6>
ffffffffc0200938:	00002617          	auipc	a2,0x2
ffffffffc020093c:	bd060613          	addi	a2,a2,-1072 # ffffffffc0202508 <etext+0x286>
ffffffffc0200940:	0a100593          	li	a1,161
ffffffffc0200944:	00002517          	auipc	a0,0x2
ffffffffc0200948:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0202520 <etext+0x29e>
ffffffffc020094c:	877ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
                if (i != 0) assert(!PageProperty(p + i));
ffffffffc0200950:	00002697          	auipc	a3,0x2
ffffffffc0200954:	d1868693          	addi	a3,a3,-744 # ffffffffc0202668 <etext+0x3e6>
ffffffffc0200958:	00002617          	auipc	a2,0x2
ffffffffc020095c:	bb060613          	addi	a2,a2,-1104 # ffffffffc0202508 <etext+0x286>
ffffffffc0200960:	0a200593          	li	a1,162
ffffffffc0200964:	00002517          	auipc	a0,0x2
ffffffffc0200968:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0202520 <etext+0x29e>
ffffffffc020096c:	857ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200970:	00002697          	auipc	a3,0x2
ffffffffc0200974:	d4068693          	addi	a3,a3,-704 # ffffffffc02026b0 <etext+0x42e>
ffffffffc0200978:	00002617          	auipc	a2,0x2
ffffffffc020097c:	b9060613          	addi	a2,a2,-1136 # ffffffffc0202508 <etext+0x286>
ffffffffc0200980:	0af00593          	li	a1,175
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0202520 <etext+0x29e>
ffffffffc020098c:	837ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            if (k < BUDDY_MAX_ORDER) assert(free_partner(ppn ^ size, k) == NULL);
ffffffffc0200990:	00002697          	auipc	a3,0x2
ffffffffc0200994:	c8068693          	addi	a3,a3,-896 # ffffffffc0202610 <etext+0x38e>
ffffffffc0200998:	00002617          	auipc	a2,0x2
ffffffffc020099c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0202508 <etext+0x286>
ffffffffc02009a0:	09f00593          	li	a1,159
ffffffffc02009a4:	00002517          	auipc	a0,0x2
ffffffffc02009a8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0202520 <etext+0x29e>
ffffffffc02009ac:	817ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert((ppn & (size - 1)) == 0 && PageProperty(p) && p->property == size);
ffffffffc02009b0:	00002697          	auipc	a3,0x2
ffffffffc02009b4:	c1868693          	addi	a3,a3,-1000 # ffffffffc02025c8 <etext+0x346>
ffffffffc02009b8:	00002617          	auipc	a2,0x2
ffffffffc02009bc:	b5060613          	addi	a2,a2,-1200 # ffffffffc0202508 <etext+0x286>
ffffffffc02009c0:	09e00593          	li	a1,158
ffffffffc02009c4:	00002517          	auipc	a0,0x2
ffffffffc02009c8:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0202520 <etext+0x29e>
ffffffffc02009cc:	ff6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(ppn >= buddy.first && ppn < buddy.end && size <= buddy.end - ppn);
ffffffffc02009d0:	00002697          	auipc	a3,0x2
ffffffffc02009d4:	bb068693          	addi	a3,a3,-1104 # ffffffffc0202580 <etext+0x2fe>
ffffffffc02009d8:	00002617          	auipc	a2,0x2
ffffffffc02009dc:	b3060613          	addi	a2,a2,-1232 # ffffffffc0202508 <etext+0x286>
ffffffffc02009e0:	09d00593          	li	a1,157
ffffffffc02009e4:	00002517          	auipc	a0,0x2
ffffffffc02009e8:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0202520 <etext+0x29e>
ffffffffc02009ec:	fd6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(list_prev(list_next(le)) == le && list_next(list_prev(le)) == le);
ffffffffc02009f0:	00002697          	auipc	a3,0x2
ffffffffc02009f4:	b4868693          	addi	a3,a3,-1208 # ffffffffc0202538 <etext+0x2b6>
ffffffffc02009f8:	00002617          	auipc	a2,0x2
ffffffffc02009fc:	b1060613          	addi	a2,a2,-1264 # ffffffffc0202508 <etext+0x286>
ffffffffc0200a00:	09900593          	li	a1,153
ffffffffc0200a04:	00002517          	auipc	a0,0x2
ffffffffc0200a08:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200a0c:	fb6ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(++blocks <= npage - nbase); // also bounds accidental cycles
ffffffffc0200a10:	00002697          	auipc	a3,0x2
ffffffffc0200a14:	ad868693          	addi	a3,a3,-1320 # ffffffffc02024e8 <etext+0x266>
ffffffffc0200a18:	00002617          	auipc	a2,0x2
ffffffffc0200a1c:	af060613          	addi	a2,a2,-1296 # ffffffffc0202508 <etext+0x286>
ffffffffc0200a20:	09800593          	li	a1,152
ffffffffc0200a24:	00002517          	auipc	a0,0x2
ffffffffc0200a28:	afc50513          	addi	a0,a0,-1284 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200a2c:	f96ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200a30 <check_pool>:

static void
check_pool(void) {
ffffffffc0200a30:	7139                	addi	sp,sp,-64
ffffffffc0200a32:	fc06                	sd	ra,56(sp)
ffffffffc0200a34:	f822                	sd	s0,48(sp)
ffffffffc0200a36:	f426                	sd	s1,40(sp)
    unsigned char seen[TEST_PAGES] = {0};
ffffffffc0200a38:	e002                	sd	zero,0(sp)
ffffffffc0200a3a:	e402                	sd	zero,8(sp)
ffffffffc0200a3c:	e802                	sd	zero,16(sp)
ffffffffc0200a3e:	ec02                	sd	zero,24(sp)
    check_consistency();
ffffffffc0200a40:	d15ff0ef          	jal	ra,ffffffffc0200754 <check_consistency>
    size_t expected = 0;
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
        list_entry_t *h = &buddy.lists[k];
        for (list_entry_t *le = list_next(h); le != h; le = list_next(le)) {
            struct Page *p = le2page(le, page_link);
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
ffffffffc0200a44:	00007e97          	auipc	t4,0x7
ffffffffc0200a48:	464ebe83          	ld	t4,1124(t4) # ffffffffc0207ea8 <test_base>
ffffffffc0200a4c:	500e8293          	addi	t0,t4,1280
ffffffffc0200a50:	00006f17          	auipc	t5,0x6
ffffffffc0200a54:	5e8f0f13          	addi	t5,t5,1512 # ffffffffc0207038 <buddy>
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
ffffffffc0200a58:	4401                	li	s0,0
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
ffffffffc0200a5a:	02800493          	li	s1,40
            size_t offset = p - test_base;
            for (size_t i = 0; i < (1UL << k); i++) {
ffffffffc0200a5e:	4885                	li	a7,1
            size_t offset = p - test_base;
ffffffffc0200a60:	00002f97          	auipc	t6,0x2
ffffffffc0200a64:	5f8fbf83          	ld	t6,1528(t6) # ffffffffc0203058 <error_string+0x38>
ffffffffc0200a68:	00006817          	auipc	a6,0x6
ffffffffc0200a6c:	5b080813          	addi	a6,a6,1456 # ffffffffc0207018 <allowed>
                assert(allowed[offset+i] && !occupied[offset+i] && !seen[offset+i]);
ffffffffc0200a70:	00007517          	auipc	a0,0x7
ffffffffc0200a74:	d9850513          	addi	a0,a0,-616 # ffffffffc0207808 <occupied>
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
ffffffffc0200a78:	40d5                	li	ra,21
ffffffffc0200a7a:	008f3e03          	ld	t3,8(t5)
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
ffffffffc0200a7e:	008493b3          	sll	t2,s1,s0
            for (size_t i = 0; i < (1UL << k); i++) {
ffffffffc0200a82:	00889333          	sll	t1,a7,s0
        for (list_entry_t *le = list_next(h); le != h; le = list_next(le)) {
ffffffffc0200a86:	05ee0a63          	beq	t3,t5,ffffffffc0200ada <check_pool+0xaa>
            struct Page *p = le2page(le, page_link);
ffffffffc0200a8a:	fe8e0793          	addi	a5,t3,-24
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
ffffffffc0200a8e:	11d7e063          	bltu	a5,t4,ffffffffc0200b8e <check_pool+0x15e>
ffffffffc0200a92:	00778733          	add	a4,a5,t2
ffffffffc0200a96:	0ee2ec63          	bltu	t0,a4,ffffffffc0200b8e <check_pool+0x15e>
            size_t offset = p - test_base;
ffffffffc0200a9a:	41d785b3          	sub	a1,a5,t4
ffffffffc0200a9e:	858d                	srai	a1,a1,0x3
ffffffffc0200aa0:	03f585b3          	mul	a1,a1,t6
            for (size_t i = 0; i < (1UL << k); i++) {
ffffffffc0200aa4:	4701                	li	a4,0
ffffffffc0200aa6:	00b106b3          	add	a3,sp,a1
                assert(allowed[offset+i] && !occupied[offset+i] && !seen[offset+i]);
ffffffffc0200aaa:	00b707b3          	add	a5,a4,a1
ffffffffc0200aae:	00f80633          	add	a2,a6,a5
ffffffffc0200ab2:	00064603          	lbu	a2,0(a2)
ffffffffc0200ab6:	ce41                	beqz	a2,ffffffffc0200b4e <check_pool+0x11e>
ffffffffc0200ab8:	97aa                	add	a5,a5,a0
ffffffffc0200aba:	0007c783          	lbu	a5,0(a5)
ffffffffc0200abe:	ebc1                	bnez	a5,ffffffffc0200b4e <check_pool+0x11e>
ffffffffc0200ac0:	0006c783          	lbu	a5,0(a3)
ffffffffc0200ac4:	e7c9                	bnez	a5,ffffffffc0200b4e <check_pool+0x11e>
                seen[offset+i] = 1;
ffffffffc0200ac6:	01168023          	sb	a7,0(a3)
            for (size_t i = 0; i < (1UL << k); i++) {
ffffffffc0200aca:	0705                	addi	a4,a4,1
ffffffffc0200acc:	0685                	addi	a3,a3,1
ffffffffc0200ace:	fc676ee3          	bltu	a4,t1,ffffffffc0200aaa <check_pool+0x7a>
ffffffffc0200ad2:	008e3e03          	ld	t3,8(t3)
        for (list_entry_t *le = list_next(h); le != h; le = list_next(le)) {
ffffffffc0200ad6:	fbee1ae3          	bne	t3,t5,ffffffffc0200a8a <check_pool+0x5a>
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) {
ffffffffc0200ada:	2405                	addiw	s0,s0,1
ffffffffc0200adc:	0f41                	addi	t5,t5,16
ffffffffc0200ade:	f8141ee3          	bne	s0,ra,ffffffffc0200a7a <check_pool+0x4a>
ffffffffc0200ae2:	860a                	mv	a2,sp
ffffffffc0200ae4:	00006597          	auipc	a1,0x6
ffffffffc0200ae8:	53458593          	addi	a1,a1,1332 # ffffffffc0207018 <allowed>
ffffffffc0200aec:	0ea1                	addi	t4,t4,8
ffffffffc0200aee:	00007517          	auipc	a0,0x7
ffffffffc0200af2:	d1a50513          	addi	a0,a0,-742 # ffffffffc0207808 <occupied>
    size_t expected = 0;
ffffffffc0200af6:	4401                	li	s0,0
            }
        }
    }
    for (int i = 0; i < TEST_PAGES; i++) {
        assert(seen[i] == (allowed[i] && !occupied[i]));
ffffffffc0200af8:	00064683          	lbu	a3,0(a2)
ffffffffc0200afc:	0005c703          	lbu	a4,0(a1)
ffffffffc0200b00:	4781                	li	a5,0
ffffffffc0200b02:	0006881b          	sext.w	a6,a3
ffffffffc0200b06:	c709                	beqz	a4,ffffffffc0200b10 <check_pool+0xe0>
ffffffffc0200b08:	00054783          	lbu	a5,0(a0)
ffffffffc0200b0c:	0017b793          	seqz	a5,a5
ffffffffc0200b10:	04f81f63          	bne	a6,a5,ffffffffc0200b6e <check_pool+0x13e>
        if (seen[i]) expected++;
        assert(!PageReserved(test_base+i) == !!allowed[i]);
ffffffffc0200b14:	000eb783          	ld	a5,0(t4)
        if (seen[i]) expected++;
ffffffffc0200b18:	00d036b3          	snez	a3,a3
        assert(!PageReserved(test_base+i) == !!allowed[i]);
ffffffffc0200b1c:	00e03733          	snez	a4,a4
ffffffffc0200b20:	fff7c793          	not	a5,a5
ffffffffc0200b24:	8b85                	andi	a5,a5,1
        if (seen[i]) expected++;
ffffffffc0200b26:	9436                	add	s0,s0,a3
        assert(!PageReserved(test_base+i) == !!allowed[i]);
ffffffffc0200b28:	0af71363          	bne	a4,a5,ffffffffc0200bce <check_pool+0x19e>
    for (int i = 0; i < TEST_PAGES; i++) {
ffffffffc0200b2c:	0605                	addi	a2,a2,1
ffffffffc0200b2e:	101c                	addi	a5,sp,32
ffffffffc0200b30:	0585                	addi	a1,a1,1
ffffffffc0200b32:	028e8e93          	addi	t4,t4,40
ffffffffc0200b36:	0505                	addi	a0,a0,1
ffffffffc0200b38:	fcf610e3          	bne	a2,a5,ffffffffc0200af8 <check_pool+0xc8>
    }
    assert(expected == nr_free_pages());
ffffffffc0200b3c:	038010ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc0200b40:	06851763          	bne	a0,s0,ffffffffc0200bae <check_pool+0x17e>
}
ffffffffc0200b44:	70e2                	ld	ra,56(sp)
ffffffffc0200b46:	7442                	ld	s0,48(sp)
ffffffffc0200b48:	74a2                	ld	s1,40(sp)
ffffffffc0200b4a:	6121                	addi	sp,sp,64
ffffffffc0200b4c:	8082                	ret
                assert(allowed[offset+i] && !occupied[offset+i] && !seen[offset+i]);
ffffffffc0200b4e:	00002697          	auipc	a3,0x2
ffffffffc0200b52:	bc268693          	addi	a3,a3,-1086 # ffffffffc0202710 <etext+0x48e>
ffffffffc0200b56:	00002617          	auipc	a2,0x2
ffffffffc0200b5a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0202508 <etext+0x286>
ffffffffc0200b5e:	0be00593          	li	a1,190
ffffffffc0200b62:	00002517          	auipc	a0,0x2
ffffffffc0200b66:	9be50513          	addi	a0,a0,-1602 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200b6a:	e58ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(seen[i] == (allowed[i] && !occupied[i]));
ffffffffc0200b6e:	00002697          	auipc	a3,0x2
ffffffffc0200b72:	be268693          	addi	a3,a3,-1054 # ffffffffc0202750 <etext+0x4ce>
ffffffffc0200b76:	00002617          	auipc	a2,0x2
ffffffffc0200b7a:	99260613          	addi	a2,a2,-1646 # ffffffffc0202508 <etext+0x286>
ffffffffc0200b7e:	0c400593          	li	a1,196
ffffffffc0200b82:	00002517          	auipc	a0,0x2
ffffffffc0200b86:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200b8a:	e38ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(p >= test_base && p + (1UL << k) <= test_base + TEST_PAGES);
ffffffffc0200b8e:	00002697          	auipc	a3,0x2
ffffffffc0200b92:	b4268693          	addi	a3,a3,-1214 # ffffffffc02026d0 <etext+0x44e>
ffffffffc0200b96:	00002617          	auipc	a2,0x2
ffffffffc0200b9a:	97260613          	addi	a2,a2,-1678 # ffffffffc0202508 <etext+0x286>
ffffffffc0200b9e:	0bb00593          	li	a1,187
ffffffffc0200ba2:	00002517          	auipc	a0,0x2
ffffffffc0200ba6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200baa:	e18ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(expected == nr_free_pages());
ffffffffc0200bae:	00002697          	auipc	a3,0x2
ffffffffc0200bb2:	bfa68693          	addi	a3,a3,-1030 # ffffffffc02027a8 <etext+0x526>
ffffffffc0200bb6:	00002617          	auipc	a2,0x2
ffffffffc0200bba:	95260613          	addi	a2,a2,-1710 # ffffffffc0202508 <etext+0x286>
ffffffffc0200bbe:	0c800593          	li	a1,200
ffffffffc0200bc2:	00002517          	auipc	a0,0x2
ffffffffc0200bc6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200bca:	df8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(!PageReserved(test_base+i) == !!allowed[i]);
ffffffffc0200bce:	00002697          	auipc	a3,0x2
ffffffffc0200bd2:	baa68693          	addi	a3,a3,-1110 # ffffffffc0202778 <etext+0x4f6>
ffffffffc0200bd6:	00002617          	auipc	a2,0x2
ffffffffc0200bda:	93260613          	addi	a2,a2,-1742 # ffffffffc0202508 <etext+0x286>
ffffffffc0200bde:	0c600593          	li	a1,198
ffffffffc0200be2:	00002517          	auipc	a0,0x2
ffffffffc0200be6:	93e50513          	addi	a0,a0,-1730 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200bea:	dd8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200bee <pool_alloc>:
    assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
    check_pool();
}

static struct Page *
pool_alloc(size_t n) {
ffffffffc0200bee:	1101                	addi	sp,sp,-32
ffffffffc0200bf0:	e822                	sd	s0,16(sp)
ffffffffc0200bf2:	e426                	sd	s1,8(sp)
ffffffffc0200bf4:	ec06                	sd	ra,24(sp)
ffffffffc0200bf6:	84aa                	mv	s1,a0
    struct Page *p = alloc_pages(n);
ffffffffc0200bf8:	765000ef          	jal	ra,ffffffffc0201b5c <alloc_pages>
ffffffffc0200bfc:	842a                	mv	s0,a0
    if (p != NULL) {
ffffffffc0200bfe:	cd4d                	beqz	a0,ffffffffc0200cb8 <pool_alloc+0xca>
        // Deliberately compute rounding independently of request_order().
        size_t size = 1;
        while (size < n) size *= 2;
ffffffffc0200c00:	4785                	li	a5,1
        size_t size = 1;
ffffffffc0200c02:	4805                	li	a6,1
        while (size < n) size *= 2;
ffffffffc0200c04:	0097f563          	bgeu	a5,s1,ffffffffc0200c0e <pool_alloc+0x20>
ffffffffc0200c08:	0806                	slli	a6,a6,0x1
ffffffffc0200c0a:	fe986fe3          	bltu	a6,s1,ffffffffc0200c08 <pool_alloc+0x1a>
        assert(p >= test_base && p + size <= test_base + TEST_PAGES);
ffffffffc0200c0e:	00007797          	auipc	a5,0x7
ffffffffc0200c12:	29a7b783          	ld	a5,666(a5) # ffffffffc0207ea8 <test_base>
ffffffffc0200c16:	12f46963          	bltu	s0,a5,ffffffffc0200d48 <pool_alloc+0x15a>
ffffffffc0200c1a:	00281713          	slli	a4,a6,0x2
ffffffffc0200c1e:	9742                	add	a4,a4,a6
ffffffffc0200c20:	070e                	slli	a4,a4,0x3
ffffffffc0200c22:	9722                	add	a4,a4,s0
ffffffffc0200c24:	50078693          	addi	a3,a5,1280
ffffffffc0200c28:	12e6e063          	bltu	a3,a4,ffffffffc0200d48 <pool_alloc+0x15a>
ffffffffc0200c2c:	00007317          	auipc	t1,0x7
ffffffffc0200c30:	28c33303          	ld	t1,652(t1) # ffffffffc0207eb8 <pages>
ffffffffc0200c34:	406405b3          	sub	a1,s0,t1
ffffffffc0200c38:	858d                	srai	a1,a1,0x3
ffffffffc0200c3a:	00002897          	auipc	a7,0x2
ffffffffc0200c3e:	41e8b883          	ld	a7,1054(a7) # ffffffffc0203058 <error_string+0x38>
ffffffffc0200c42:	031585b3          	mul	a1,a1,a7
ffffffffc0200c46:	00002e17          	auipc	t3,0x2
ffffffffc0200c4a:	422e3e03          	ld	t3,1058(t3) # ffffffffc0203068 <nbase>
ffffffffc0200c4e:	95f2                	add	a1,a1,t3
        assert((page2ppn(p) % size) == 0);
ffffffffc0200c50:	0305f733          	remu	a4,a1,a6
ffffffffc0200c54:	eb71                	bnez	a4,ffffffffc0200d28 <pool_alloc+0x13a>
        for (size_t i = 0; i < size; i++) {
            size_t at = p - test_base + i;
ffffffffc0200c56:	40f407b3          	sub	a5,s0,a5
ffffffffc0200c5a:	878d                	srai	a5,a5,0x3
ffffffffc0200c5c:	031787b3          	mul	a5,a5,a7
ffffffffc0200c60:	00006697          	auipc	a3,0x6
ffffffffc0200c64:	3b868693          	addi	a3,a3,952 # ffffffffc0207018 <allowed>
ffffffffc0200c68:	00007617          	auipc	a2,0x7
ffffffffc0200c6c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0207808 <occupied>

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c70:	05b2                	slli	a1,a1,0xc
ffffffffc0200c72:	8722                	mv	a4,s0
            assert(allowed[at] && !occupied[at] && !PageProperty(p+i));
            assert(page_ref(p+i) == 0);
            assert(page2pa(p+i) == page2pa(p) + i*PGSIZE);
            occupied[at] = 1;
ffffffffc0200c74:	4505                	li	a0,1
        for (size_t i = 0; i < size; i++) {
ffffffffc0200c76:	6e85                	lui	t4,0x1
ffffffffc0200c78:	96be                	add	a3,a3,a5
ffffffffc0200c7a:	963e                	add	a2,a2,a5
ffffffffc0200c7c:	9836                	add	a6,a6,a3
            assert(allowed[at] && !occupied[at] && !PageProperty(p+i));
ffffffffc0200c7e:	0006c783          	lbu	a5,0(a3)
ffffffffc0200c82:	c3b9                	beqz	a5,ffffffffc0200cc8 <pool_alloc+0xda>
ffffffffc0200c84:	00064783          	lbu	a5,0(a2)
ffffffffc0200c88:	e3a1                	bnez	a5,ffffffffc0200cc8 <pool_alloc+0xda>
ffffffffc0200c8a:	671c                	ld	a5,8(a4)
ffffffffc0200c8c:	8b89                	andi	a5,a5,2
ffffffffc0200c8e:	ef8d                	bnez	a5,ffffffffc0200cc8 <pool_alloc+0xda>
            assert(page_ref(p+i) == 0);
ffffffffc0200c90:	431c                	lw	a5,0(a4)
ffffffffc0200c92:	ebbd                	bnez	a5,ffffffffc0200d08 <pool_alloc+0x11a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c94:	406707b3          	sub	a5,a4,t1
ffffffffc0200c98:	878d                	srai	a5,a5,0x3
ffffffffc0200c9a:	031787b3          	mul	a5,a5,a7
ffffffffc0200c9e:	97f2                	add	a5,a5,t3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ca0:	07b2                	slli	a5,a5,0xc
            assert(page2pa(p+i) == page2pa(p) + i*PGSIZE);
ffffffffc0200ca2:	04b79363          	bne	a5,a1,ffffffffc0200ce8 <pool_alloc+0xfa>
            occupied[at] = 1;
ffffffffc0200ca6:	00a60023          	sb	a0,0(a2)
        for (size_t i = 0; i < size; i++) {
ffffffffc0200caa:	0685                	addi	a3,a3,1
ffffffffc0200cac:	0605                	addi	a2,a2,1
ffffffffc0200cae:	02870713          	addi	a4,a4,40
ffffffffc0200cb2:	95f6                	add	a1,a1,t4
ffffffffc0200cb4:	fd0695e3          	bne	a3,a6,ffffffffc0200c7e <pool_alloc+0x90>
        }
    }
    check_pool();
ffffffffc0200cb8:	d79ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    return p;
}
ffffffffc0200cbc:	60e2                	ld	ra,24(sp)
ffffffffc0200cbe:	8522                	mv	a0,s0
ffffffffc0200cc0:	6442                	ld	s0,16(sp)
ffffffffc0200cc2:	64a2                	ld	s1,8(sp)
ffffffffc0200cc4:	6105                	addi	sp,sp,32
ffffffffc0200cc6:	8082                	ret
            assert(allowed[at] && !occupied[at] && !PageProperty(p+i));
ffffffffc0200cc8:	00002697          	auipc	a3,0x2
ffffffffc0200ccc:	b5868693          	addi	a3,a3,-1192 # ffffffffc0202820 <etext+0x59e>
ffffffffc0200cd0:	00002617          	auipc	a2,0x2
ffffffffc0200cd4:	83860613          	addi	a2,a2,-1992 # ffffffffc0202508 <etext+0x286>
ffffffffc0200cd8:	0f400593          	li	a1,244
ffffffffc0200cdc:	00002517          	auipc	a0,0x2
ffffffffc0200ce0:	84450513          	addi	a0,a0,-1980 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200ce4:	cdeff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(page2pa(p+i) == page2pa(p) + i*PGSIZE);
ffffffffc0200ce8:	00002697          	auipc	a3,0x2
ffffffffc0200cec:	b8868693          	addi	a3,a3,-1144 # ffffffffc0202870 <etext+0x5ee>
ffffffffc0200cf0:	00002617          	auipc	a2,0x2
ffffffffc0200cf4:	81860613          	addi	a2,a2,-2024 # ffffffffc0202508 <etext+0x286>
ffffffffc0200cf8:	0f600593          	li	a1,246
ffffffffc0200cfc:	00002517          	auipc	a0,0x2
ffffffffc0200d00:	82450513          	addi	a0,a0,-2012 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200d04:	cbeff0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(page_ref(p+i) == 0);
ffffffffc0200d08:	00002697          	auipc	a3,0x2
ffffffffc0200d0c:	b5068693          	addi	a3,a3,-1200 # ffffffffc0202858 <etext+0x5d6>
ffffffffc0200d10:	00001617          	auipc	a2,0x1
ffffffffc0200d14:	7f860613          	addi	a2,a2,2040 # ffffffffc0202508 <etext+0x286>
ffffffffc0200d18:	0f500593          	li	a1,245
ffffffffc0200d1c:	00002517          	auipc	a0,0x2
ffffffffc0200d20:	80450513          	addi	a0,a0,-2044 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200d24:	c9eff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert((page2ppn(p) % size) == 0);
ffffffffc0200d28:	00002697          	auipc	a3,0x2
ffffffffc0200d2c:	ad868693          	addi	a3,a3,-1320 # ffffffffc0202800 <etext+0x57e>
ffffffffc0200d30:	00001617          	auipc	a2,0x1
ffffffffc0200d34:	7d860613          	addi	a2,a2,2008 # ffffffffc0202508 <etext+0x286>
ffffffffc0200d38:	0f100593          	li	a1,241
ffffffffc0200d3c:	00001517          	auipc	a0,0x1
ffffffffc0200d40:	7e450513          	addi	a0,a0,2020 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200d44:	c7eff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(p >= test_base && p + size <= test_base + TEST_PAGES);
ffffffffc0200d48:	00002697          	auipc	a3,0x2
ffffffffc0200d4c:	a8068693          	addi	a3,a3,-1408 # ffffffffc02027c8 <etext+0x546>
ffffffffc0200d50:	00001617          	auipc	a2,0x1
ffffffffc0200d54:	7b860613          	addi	a2,a2,1976 # ffffffffc0202508 <etext+0x286>
ffffffffc0200d58:	0f000593          	li	a1,240
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	7c450513          	addi	a0,a0,1988 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200d64:	c5eff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200d68 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d68:	711d                	addi	sp,sp,-96
ffffffffc0200d6a:	ec86                	sd	ra,88(sp)
ffffffffc0200d6c:	e8a2                	sd	s0,80(sp)
ffffffffc0200d6e:	e4a6                	sd	s1,72(sp)
ffffffffc0200d70:	e0ca                	sd	s2,64(sp)
ffffffffc0200d72:	fc4e                	sd	s3,56(sp)
ffffffffc0200d74:	f852                	sd	s4,48(sp)
ffffffffc0200d76:	f456                	sd	s5,40(sp)
ffffffffc0200d78:	f05a                	sd	s6,32(sp)
ffffffffc0200d7a:	ec5e                	sd	s7,24(sp)
ffffffffc0200d7c:	e862                	sd	s8,16(sp)
ffffffffc0200d7e:	e466                	sd	s9,8(sp)
    assert(n > 0);
ffffffffc0200d80:	16058363          	beqz	a1,ffffffffc0200ee6 <buddy_init_memmap+0x17e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d84:	00007917          	auipc	s2,0x7
ffffffffc0200d88:	13490913          	addi	s2,s2,308 # ffffffffc0207eb8 <pages>
ffffffffc0200d8c:	00093703          	ld	a4,0(s2)
ffffffffc0200d90:	8a2e                	mv	s4,a1
ffffffffc0200d92:	00002497          	auipc	s1,0x2
ffffffffc0200d96:	2c64b483          	ld	s1,710(s1) # ffffffffc0203058 <error_string+0x38>
ffffffffc0200d9a:	40e50733          	sub	a4,a0,a4
ffffffffc0200d9e:	40375593          	srai	a1,a4,0x3
ffffffffc0200da2:	029585b3          	mul	a1,a1,s1
ffffffffc0200da6:	00002417          	auipc	s0,0x2
ffffffffc0200daa:	2c243403          	ld	s0,706(s0) # ffffffffc0203068 <nbase>
ffffffffc0200dae:	8c2a                	mv	s8,a0
ffffffffc0200db0:	95a2                	add	a1,a1,s0
    assert(start >= nbase && start < npage && n <= npage - start);
ffffffffc0200db2:	1085ea63          	bltu	a1,s0,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
ffffffffc0200db6:	00007797          	auipc	a5,0x7
ffffffffc0200dba:	0fa7b783          	ld	a5,250(a5) # ffffffffc0207eb0 <npage>
ffffffffc0200dbe:	10f5f463          	bgeu	a1,a5,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
ffffffffc0200dc2:	8f8d                	sub	a5,a5,a1
ffffffffc0200dc4:	1147e163          	bltu	a5,s4,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200dc8:	002a1613          	slli	a2,s4,0x2
ffffffffc0200dcc:	9652                	add	a2,a2,s4
ffffffffc0200dce:	060e                	slli	a2,a2,0x3
ffffffffc0200dd0:	962a                	add	a2,a2,a0
ffffffffc0200dd2:	87aa                	mv	a5,a0
ffffffffc0200dd4:	00c57f63          	bgeu	a0,a2,ffffffffc0200df2 <buddy_init_memmap+0x8a>
        assert(PageReserved(p));
ffffffffc0200dd8:	6794                	ld	a3,8(a5)
ffffffffc0200dda:	8a85                	andi	a3,a3,1
ffffffffc0200ddc:	c6e9                	beqz	a3,ffffffffc0200ea6 <buddy_init_memmap+0x13e>
        p->flags = p->property = 0;
ffffffffc0200dde:	0007a823          	sw	zero,16(a5)
ffffffffc0200de2:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200de6:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200dea:	02878793          	addi	a5,a5,40
ffffffffc0200dee:	fec7e5e3          	bltu	a5,a2,ffffffffc0200dd8 <buddy_init_memmap+0x70>
    if (start < buddy.first) buddy.first = start;
ffffffffc0200df2:	00006797          	auipc	a5,0x6
ffffffffc0200df6:	24678793          	addi	a5,a5,582 # ffffffffc0207038 <buddy>
ffffffffc0200dfa:	1587b683          	ld	a3,344(a5)
ffffffffc0200dfe:	00d5f463          	bgeu	a1,a3,ffffffffc0200e06 <buddy_init_memmap+0x9e>
ffffffffc0200e02:	14b7bc23          	sd	a1,344(a5)
    if (start + n > buddy.end) buddy.end = start + n;
ffffffffc0200e06:	1607b683          	ld	a3,352(a5)
ffffffffc0200e0a:	95d2                	add	a1,a1,s4
ffffffffc0200e0c:	08b6ea63          	bltu	a3,a1,ffffffffc0200ea0 <buddy_init_memmap+0x138>
    buddy.nr_free += n;
ffffffffc0200e10:	1507b683          	ld	a3,336(a5)
        while (k < BUDDY_MAX_ORDER && (1UL << (k + 1)) <= n &&
ffffffffc0200e14:	4a85                	li	s5,1
               (page2ppn(base) & ((1UL << (k + 1)) - 1)) == 0) k++;
ffffffffc0200e16:	5b7d                	li	s6,-1
    buddy.nr_free += n;
ffffffffc0200e18:	96d2                	add	a3,a3,s4
ffffffffc0200e1a:	14d7b823          	sd	a3,336(a5)
        while (k < BUDDY_MAX_ORDER && (1UL << (k + 1)) <= n &&
ffffffffc0200e1e:	4bd1                	li	s7,20
        base += size;
ffffffffc0200e20:	02800993          	li	s3,40
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e24:	870d                	srai	a4,a4,0x3
ffffffffc0200e26:	02970733          	mul	a4,a4,s1
        int k = 0;
ffffffffc0200e2a:	4581                	li	a1,0
ffffffffc0200e2c:	9722                	add	a4,a4,s0
ffffffffc0200e2e:	86ae                	mv	a3,a1
        while (k < BUDDY_MAX_ORDER && (1UL << (k + 1)) <= n &&
ffffffffc0200e30:	2585                	addiw	a1,a1,1
ffffffffc0200e32:	00ba97b3          	sll	a5,s5,a1
ffffffffc0200e36:	02fa6b63          	bltu	s4,a5,ffffffffc0200e6c <buddy_init_memmap+0x104>
               (page2ppn(base) & ((1UL << (k + 1)) - 1)) == 0) k++;
ffffffffc0200e3a:	00bb17b3          	sll	a5,s6,a1
ffffffffc0200e3e:	fff7c793          	not	a5,a5
ffffffffc0200e42:	8ff9                	and	a5,a5,a4
        while (k < BUDDY_MAX_ORDER && (1UL << (k + 1)) <= n &&
ffffffffc0200e44:	e785                	bnez	a5,ffffffffc0200e6c <buddy_init_memmap+0x104>
ffffffffc0200e46:	ff7594e3          	bne	a1,s7,ffffffffc0200e2e <buddy_init_memmap+0xc6>
ffffffffc0200e4a:	001007b7          	lui	a5,0x100
        insert_merge(base, k);
ffffffffc0200e4e:	8562                	mv	a0,s8
ffffffffc0200e50:	02800cb7          	lui	s9,0x2800
        n -= size;
ffffffffc0200e54:	40fa0a33          	sub	s4,s4,a5
        base += size;
ffffffffc0200e58:	9c66                	add	s8,s8,s9
        insert_merge(base, k);
ffffffffc0200e5a:	825ff0ef          	jal	ra,ffffffffc020067e <insert_merge>
    while (n != 0) {
ffffffffc0200e5e:	020a0463          	beqz	s4,ffffffffc0200e86 <buddy_init_memmap+0x11e>
ffffffffc0200e62:	00093703          	ld	a4,0(s2)
ffffffffc0200e66:	40ec0733          	sub	a4,s8,a4
ffffffffc0200e6a:	bf6d                	j	ffffffffc0200e24 <buddy_init_memmap+0xbc>
        size_t size = 1UL << k;
ffffffffc0200e6c:	00da97b3          	sll	a5,s5,a3
        base += size;
ffffffffc0200e70:	00d99cb3          	sll	s9,s3,a3
        insert_merge(base, k);
ffffffffc0200e74:	8562                	mv	a0,s8
        size_t size = 1UL << k;
ffffffffc0200e76:	85b6                	mv	a1,a3
        n -= size;
ffffffffc0200e78:	40fa0a33          	sub	s4,s4,a5
        base += size;
ffffffffc0200e7c:	9c66                	add	s8,s8,s9
        insert_merge(base, k);
ffffffffc0200e7e:	801ff0ef          	jal	ra,ffffffffc020067e <insert_merge>
    while (n != 0) {
ffffffffc0200e82:	fe0a10e3          	bnez	s4,ffffffffc0200e62 <buddy_init_memmap+0xfa>
}
ffffffffc0200e86:	60e6                	ld	ra,88(sp)
ffffffffc0200e88:	6446                	ld	s0,80(sp)
ffffffffc0200e8a:	64a6                	ld	s1,72(sp)
ffffffffc0200e8c:	6906                	ld	s2,64(sp)
ffffffffc0200e8e:	79e2                	ld	s3,56(sp)
ffffffffc0200e90:	7a42                	ld	s4,48(sp)
ffffffffc0200e92:	7aa2                	ld	s5,40(sp)
ffffffffc0200e94:	7b02                	ld	s6,32(sp)
ffffffffc0200e96:	6be2                	ld	s7,24(sp)
ffffffffc0200e98:	6c42                	ld	s8,16(sp)
ffffffffc0200e9a:	6ca2                	ld	s9,8(sp)
ffffffffc0200e9c:	6125                	addi	sp,sp,96
ffffffffc0200e9e:	8082                	ret
    if (start + n > buddy.end) buddy.end = start + n;
ffffffffc0200ea0:	16b7b023          	sd	a1,352(a5) # 100160 <kern_entry-0xffffffffc00ffea0>
ffffffffc0200ea4:	b7b5                	j	ffffffffc0200e10 <buddy_init_memmap+0xa8>
        assert(PageReserved(p));
ffffffffc0200ea6:	00002697          	auipc	a3,0x2
ffffffffc0200eaa:	a3268693          	addi	a3,a3,-1486 # ffffffffc02028d8 <etext+0x656>
ffffffffc0200eae:	00001617          	auipc	a2,0x1
ffffffffc0200eb2:	65a60613          	addi	a2,a2,1626 # ffffffffc0202508 <etext+0x286>
ffffffffc0200eb6:	04300593          	li	a1,67
ffffffffc0200eba:	00001517          	auipc	a0,0x1
ffffffffc0200ebe:	66650513          	addi	a0,a0,1638 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200ec2:	b00ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(start >= nbase && start < npage && n <= npage - start);
ffffffffc0200ec6:	00002697          	auipc	a3,0x2
ffffffffc0200eca:	9da68693          	addi	a3,a3,-1574 # ffffffffc02028a0 <etext+0x61e>
ffffffffc0200ece:	00001617          	auipc	a2,0x1
ffffffffc0200ed2:	63a60613          	addi	a2,a2,1594 # ffffffffc0202508 <etext+0x286>
ffffffffc0200ed6:	04100593          	li	a1,65
ffffffffc0200eda:	00001517          	auipc	a0,0x1
ffffffffc0200ede:	64650513          	addi	a0,a0,1606 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200ee2:	ae0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200ee6:	00002697          	auipc	a3,0x2
ffffffffc0200eea:	9b268693          	addi	a3,a3,-1614 # ffffffffc0202898 <etext+0x616>
ffffffffc0200eee:	00001617          	auipc	a2,0x1
ffffffffc0200ef2:	61a60613          	addi	a2,a2,1562 # ffffffffc0202508 <etext+0x286>
ffffffffc0200ef6:	03f00593          	li	a1,63
ffffffffc0200efa:	00001517          	auipc	a0,0x1
ffffffffc0200efe:	62650513          	addi	a0,a0,1574 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200f02:	ac0ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f06 <expect_failure>:
expect_failure(size_t n) {
ffffffffc0200f06:	1101                	addi	sp,sp,-32
ffffffffc0200f08:	e822                	sd	s0,16(sp)
    memcpy(&failure_state, &buddy, sizeof(buddy));
ffffffffc0200f0a:	16800613          	li	a2,360
expect_failure(size_t n) {
ffffffffc0200f0e:	842a                	mv	s0,a0
    memcpy(&failure_state, &buddy, sizeof(buddy));
ffffffffc0200f10:	00006597          	auipc	a1,0x6
ffffffffc0200f14:	12858593          	addi	a1,a1,296 # ffffffffc0207038 <buddy>
ffffffffc0200f18:	00006517          	auipc	a0,0x6
ffffffffc0200f1c:	78850513          	addi	a0,a0,1928 # ffffffffc02076a0 <failure_state>
expect_failure(size_t n) {
ffffffffc0200f20:	ec06                	sd	ra,24(sp)
ffffffffc0200f22:	e426                	sd	s1,8(sp)
    memcpy(&failure_state, &buddy, sizeof(buddy));
ffffffffc0200f24:	322010ef          	jal	ra,ffffffffc0202246 <memcpy>
    memcpy(failure_pages, test_base, sizeof(failure_pages));
ffffffffc0200f28:	00007497          	auipc	s1,0x7
ffffffffc0200f2c:	f8048493          	addi	s1,s1,-128 # ffffffffc0207ea8 <test_base>
ffffffffc0200f30:	608c                	ld	a1,0(s1)
ffffffffc0200f32:	50000613          	li	a2,1280
ffffffffc0200f36:	00006517          	auipc	a0,0x6
ffffffffc0200f3a:	26a50513          	addi	a0,a0,618 # ffffffffc02071a0 <failure_pages>
ffffffffc0200f3e:	308010ef          	jal	ra,ffffffffc0202246 <memcpy>
    assert(alloc_pages(n) == NULL);
ffffffffc0200f42:	8522                	mv	a0,s0
ffffffffc0200f44:	419000ef          	jal	ra,ffffffffc0201b5c <alloc_pages>
ffffffffc0200f48:	ed0d                	bnez	a0,ffffffffc0200f82 <expect_failure+0x7c>
    assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
ffffffffc0200f4a:	16800613          	li	a2,360
ffffffffc0200f4e:	00006597          	auipc	a1,0x6
ffffffffc0200f52:	0ea58593          	addi	a1,a1,234 # ffffffffc0207038 <buddy>
ffffffffc0200f56:	00006517          	auipc	a0,0x6
ffffffffc0200f5a:	74a50513          	addi	a0,a0,1866 # ffffffffc02076a0 <failure_state>
ffffffffc0200f5e:	300010ef          	jal	ra,ffffffffc020225e <memcmp>
ffffffffc0200f62:	e125                	bnez	a0,ffffffffc0200fc2 <expect_failure+0xbc>
    assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
ffffffffc0200f64:	608c                	ld	a1,0(s1)
ffffffffc0200f66:	50000613          	li	a2,1280
ffffffffc0200f6a:	00006517          	auipc	a0,0x6
ffffffffc0200f6e:	23650513          	addi	a0,a0,566 # ffffffffc02071a0 <failure_pages>
ffffffffc0200f72:	2ec010ef          	jal	ra,ffffffffc020225e <memcmp>
ffffffffc0200f76:	e515                	bnez	a0,ffffffffc0200fa2 <expect_failure+0x9c>
}
ffffffffc0200f78:	6442                	ld	s0,16(sp)
ffffffffc0200f7a:	60e2                	ld	ra,24(sp)
ffffffffc0200f7c:	64a2                	ld	s1,8(sp)
ffffffffc0200f7e:	6105                	addi	sp,sp,32
    check_pool();
ffffffffc0200f80:	bc45                	j	ffffffffc0200a30 <check_pool>
    assert(alloc_pages(n) == NULL);
ffffffffc0200f82:	00002697          	auipc	a3,0x2
ffffffffc0200f86:	96668693          	addi	a3,a3,-1690 # ffffffffc02028e8 <etext+0x666>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	57e60613          	addi	a2,a2,1406 # ffffffffc0202508 <etext+0x286>
ffffffffc0200f92:	0e300593          	li	a1,227
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	58a50513          	addi	a0,a0,1418 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200f9e:	a24ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
ffffffffc0200fa2:	00002697          	auipc	a3,0x2
ffffffffc0200fa6:	99668693          	addi	a3,a3,-1642 # ffffffffc0202938 <etext+0x6b6>
ffffffffc0200faa:	00001617          	auipc	a2,0x1
ffffffffc0200fae:	55e60613          	addi	a2,a2,1374 # ffffffffc0202508 <etext+0x286>
ffffffffc0200fb2:	0e500593          	li	a1,229
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	56a50513          	addi	a0,a0,1386 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200fbe:	a04ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
ffffffffc0200fc2:	00002697          	auipc	a3,0x2
ffffffffc0200fc6:	93e68693          	addi	a3,a3,-1730 # ffffffffc0202900 <etext+0x67e>
ffffffffc0200fca:	00001617          	auipc	a2,0x1
ffffffffc0200fce:	53e60613          	addi	a2,a2,1342 # ffffffffc0202508 <etext+0x286>
ffffffffc0200fd2:	0e400593          	li	a1,228
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	54a50513          	addi	a0,a0,1354 # ffffffffc0202520 <etext+0x29e>
ffffffffc0200fde:	9e4ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200fe2 <pool_free>:

static void
pool_free(struct Page *p, size_t n) {
ffffffffc0200fe2:	1141                	addi	sp,sp,-16
ffffffffc0200fe4:	e406                	sd	ra,8(sp)
    size_t size = 1;
    while (size < n) size *= 2;
ffffffffc0200fe6:	4785                	li	a5,1
    size_t size = 1;
ffffffffc0200fe8:	4805                	li	a6,1
    while (size < n) size *= 2;
ffffffffc0200fea:	00b7f563          	bgeu	a5,a1,ffffffffc0200ff4 <pool_free+0x12>
ffffffffc0200fee:	0806                	slli	a6,a6,0x1
ffffffffc0200ff0:	feb86fe3          	bltu	a6,a1,ffffffffc0200fee <pool_free+0xc>
    for (size_t i = 0; i < size; i++) {
        size_t at = p - test_base + i;
ffffffffc0200ff4:	00007797          	auipc	a5,0x7
ffffffffc0200ff8:	eb47b783          	ld	a5,-332(a5) # ffffffffc0207ea8 <test_base>
ffffffffc0200ffc:	40f507b3          	sub	a5,a0,a5
ffffffffc0201000:	4037d893          	srai	a7,a5,0x3
ffffffffc0201004:	00002697          	auipc	a3,0x2
ffffffffc0201008:	0546b683          	ld	a3,84(a3) # ffffffffc0203058 <error_string+0x38>
        assert(at < TEST_PAGES && occupied[at]);
ffffffffc020100c:	4d800713          	li	a4,1240
        size_t at = p - test_base + i;
ffffffffc0201010:	02d888b3          	mul	a7,a7,a3
        assert(at < TEST_PAGES && occupied[at]);
ffffffffc0201014:	04f76263          	bltu	a4,a5,ffffffffc0201058 <pool_free+0x76>
ffffffffc0201018:	00006797          	auipc	a5,0x6
ffffffffc020101c:	7f078793          	addi	a5,a5,2032 # ffffffffc0207808 <occupied>
ffffffffc0201020:	97c6                	add	a5,a5,a7
ffffffffc0201022:	862a                	mv	a2,a0
    for (size_t i = 0; i < size; i++) {
ffffffffc0201024:	4701                	li	a4,0
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201026:	430d                	li	t1,3
        assert(at < TEST_PAGES && occupied[at]);
ffffffffc0201028:	4e7d                	li	t3,31
ffffffffc020102a:	a801                	j	ffffffffc020103a <pool_free+0x58>
ffffffffc020102c:	011706b3          	add	a3,a4,a7
ffffffffc0201030:	0785                	addi	a5,a5,1
ffffffffc0201032:	02860613          	addi	a2,a2,40
ffffffffc0201036:	02de6163          	bltu	t3,a3,ffffffffc0201058 <pool_free+0x76>
ffffffffc020103a:	0007c683          	lbu	a3,0(a5)
ffffffffc020103e:	ce89                	beqz	a3,ffffffffc0201058 <pool_free+0x76>
        occupied[at] = 0;
ffffffffc0201040:	00078023          	sb	zero,0(a5)
ffffffffc0201044:	00662023          	sw	t1,0(a2)
    for (size_t i = 0; i < size; i++) {
ffffffffc0201048:	0705                	addi	a4,a4,1
ffffffffc020104a:	ff0761e3          	bltu	a4,a6,ffffffffc020102c <pool_free+0x4a>
        set_page_ref(p+i, 3); // free must reset references
    }
    free_pages(p, n); // original request, not the rounded size
ffffffffc020104e:	31b000ef          	jal	ra,ffffffffc0201b68 <free_pages>
    check_pool();
}
ffffffffc0201052:	60a2                	ld	ra,8(sp)
ffffffffc0201054:	0141                	addi	sp,sp,16
    check_pool();
ffffffffc0201056:	bae9                	j	ffffffffc0200a30 <check_pool>
        assert(at < TEST_PAGES && occupied[at]);
ffffffffc0201058:	00002697          	auipc	a3,0x2
ffffffffc020105c:	92068693          	addi	a3,a3,-1760 # ffffffffc0202978 <etext+0x6f6>
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	4a860613          	addi	a2,a2,1192 # ffffffffc0202508 <etext+0x286>
ffffffffc0201068:	10400593          	li	a1,260
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	4b450513          	addi	a0,a0,1204 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201074:	94eff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201078 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0201078:	1141                	addi	sp,sp,-16
ffffffffc020107a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020107c:	10058763          	beqz	a1,ffffffffc020118a <buddy_free_pages+0x112>
    if (n == 0 || n > BUDDY_MAX_PAGES) return -1;
ffffffffc0201080:	fff58793          	addi	a5,a1,-1
ffffffffc0201084:	00100737          	lui	a4,0x100
ffffffffc0201088:	862e                	mv	a2,a1
ffffffffc020108a:	0ae7f063          	bgeu	a5,a4,ffffffffc020112a <buddy_free_pages+0xb2>
    for (size_t size = 1; size < n; size <<= 1) order++;
ffffffffc020108e:	4785                	li	a5,1
    int order = 0;
ffffffffc0201090:	4581                	li	a1,0
    for (size_t size = 1; size < n; size <<= 1) order++;
ffffffffc0201092:	00f60963          	beq	a2,a5,ffffffffc02010a4 <buddy_free_pages+0x2c>
ffffffffc0201096:	0786                	slli	a5,a5,0x1
ffffffffc0201098:	2585                	addiw	a1,a1,1
ffffffffc020109a:	fec7eee3          	bltu	a5,a2,ffffffffc0201096 <buddy_free_pages+0x1e>
    size_t size = 1UL << k;
ffffffffc020109e:	4605                	li	a2,1
ffffffffc02010a0:	00b61633          	sll	a2,a2,a1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010a4:	00007797          	auipc	a5,0x7
ffffffffc02010a8:	e147b783          	ld	a5,-492(a5) # ffffffffc0207eb8 <pages>
ffffffffc02010ac:	40f507b3          	sub	a5,a0,a5
ffffffffc02010b0:	00002717          	auipc	a4,0x2
ffffffffc02010b4:	fa873703          	ld	a4,-88(a4) # ffffffffc0203058 <error_string+0x38>
ffffffffc02010b8:	878d                	srai	a5,a5,0x3
ffffffffc02010ba:	02e787b3          	mul	a5,a5,a4
    assert(start >= buddy.first && start < buddy.end &&
ffffffffc02010be:	00006817          	auipc	a6,0x6
ffffffffc02010c2:	f7a80813          	addi	a6,a6,-134 # ffffffffc0207038 <buddy>
ffffffffc02010c6:	15883703          	ld	a4,344(a6)
ffffffffc02010ca:	00002697          	auipc	a3,0x2
ffffffffc02010ce:	f9e6b683          	ld	a3,-98(a3) # ffffffffc0203068 <nbase>
ffffffffc02010d2:	97b6                	add	a5,a5,a3
ffffffffc02010d4:	08e7eb63          	bltu	a5,a4,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010d8:	16083703          	ld	a4,352(a6)
ffffffffc02010dc:	08e7f763          	bgeu	a5,a4,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010e0:	8f1d                	sub	a4,a4,a5
ffffffffc02010e2:	08c76463          	bltu	a4,a2,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010e6:	fff60713          	addi	a4,a2,-1
ffffffffc02010ea:	8ff9                	and	a5,a5,a4
ffffffffc02010ec:	efbd                	bnez	a5,ffffffffc020116a <buddy_free_pages+0xf2>
    for (struct Page *p = base; p < base + size; p++) {
ffffffffc02010ee:	02800693          	li	a3,40
ffffffffc02010f2:	00b696b3          	sll	a3,a3,a1
ffffffffc02010f6:	96aa                	add	a3,a3,a0
ffffffffc02010f8:	87aa                	mv	a5,a0
ffffffffc02010fa:	00d57f63          	bgeu	a0,a3,ffffffffc0201118 <buddy_free_pages+0xa0>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010fe:	6798                	ld	a4,8(a5)
ffffffffc0201100:	8b0d                	andi	a4,a4,3
ffffffffc0201102:	e721                	bnez	a4,ffffffffc020114a <buddy_free_pages+0xd2>
        p->flags = p->property = 0;
ffffffffc0201104:	0007a823          	sw	zero,16(a5)
ffffffffc0201108:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020110c:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + size; p++) {
ffffffffc0201110:	02878793          	addi	a5,a5,40
ffffffffc0201114:	fed7e5e3          	bltu	a5,a3,ffffffffc02010fe <buddy_free_pages+0x86>
    buddy.nr_free += size;
ffffffffc0201118:	15083783          	ld	a5,336(a6)
}
ffffffffc020111c:	60a2                	ld	ra,8(sp)
    buddy.nr_free += size;
ffffffffc020111e:	97b2                	add	a5,a5,a2
ffffffffc0201120:	14f83823          	sd	a5,336(a6)
}
ffffffffc0201124:	0141                	addi	sp,sp,16
    insert_merge(base, k);
ffffffffc0201126:	d58ff06f          	j	ffffffffc020067e <insert_merge>
    assert(k >= 0);
ffffffffc020112a:	00002697          	auipc	a3,0x2
ffffffffc020112e:	86e68693          	addi	a3,a3,-1938 # ffffffffc0202998 <etext+0x716>
ffffffffc0201132:	00001617          	auipc	a2,0x1
ffffffffc0201136:	3d660613          	addi	a2,a2,982 # ffffffffc0202508 <etext+0x286>
ffffffffc020113a:	07000593          	li	a1,112
ffffffffc020113e:	00001517          	auipc	a0,0x1
ffffffffc0201142:	3e250513          	addi	a0,a0,994 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201146:	87cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020114a:	00002697          	auipc	a3,0x2
ffffffffc020114e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0202a08 <etext+0x786>
ffffffffc0201152:	00001617          	auipc	a2,0x1
ffffffffc0201156:	3b660613          	addi	a2,a2,950 # ffffffffc0202508 <etext+0x286>
ffffffffc020115a:	07600593          	li	a1,118
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	3c250513          	addi	a0,a0,962 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201166:	85cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(start >= buddy.first && start < buddy.end &&
ffffffffc020116a:	00002697          	auipc	a3,0x2
ffffffffc020116e:	83668693          	addi	a3,a3,-1994 # ffffffffc02029a0 <etext+0x71e>
ffffffffc0201172:	00001617          	auipc	a2,0x1
ffffffffc0201176:	39660613          	addi	a2,a2,918 # ffffffffc0202508 <etext+0x286>
ffffffffc020117a:	07300593          	li	a1,115
ffffffffc020117e:	00001517          	auipc	a0,0x1
ffffffffc0201182:	3a250513          	addi	a0,a0,930 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201186:	83cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc020118a:	00001697          	auipc	a3,0x1
ffffffffc020118e:	70e68693          	addi	a3,a3,1806 # ffffffffc0202898 <etext+0x616>
ffffffffc0201192:	00001617          	auipc	a2,0x1
ffffffffc0201196:	37660613          	addi	a2,a2,886 # ffffffffc0202508 <etext+0x286>
ffffffffc020119a:	06e00593          	li	a1,110
ffffffffc020119e:	00001517          	auipc	a0,0x1
ffffffffc02011a2:	38250513          	addi	a0,a0,898 # ffffffffc0202520 <etext+0x29e>
ffffffffc02011a6:	81cff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02011aa <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc02011aa:	c971                	beqz	a0,ffffffffc020127e <buddy_alloc_pages+0xd4>
    if (n == 0 || n > BUDDY_MAX_PAGES) return -1;
ffffffffc02011ac:	fff50793          	addi	a5,a0,-1
ffffffffc02011b0:	00100737          	lui	a4,0x100
ffffffffc02011b4:	882a                	mv	a6,a0
ffffffffc02011b6:	0ae7fe63          	bgeu	a5,a4,ffffffffc0201272 <buddy_alloc_pages+0xc8>
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
ffffffffc02011ba:	00006f17          	auipc	t5,0x6
ffffffffc02011be:	e7ef0f13          	addi	t5,t5,-386 # ffffffffc0207038 <buddy>
    for (size_t size = 1; size < n; size <<= 1) order++;
ffffffffc02011c2:	4785                	li	a5,1
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
ffffffffc02011c4:	150f3f83          	ld	t6,336(t5)
    for (size_t size = 1; size < n; size <<= 1) order++;
ffffffffc02011c8:	0af50763          	beq	a0,a5,ffffffffc0201276 <buddy_alloc_pages+0xcc>
    int order = 0;
ffffffffc02011cc:	4601                	li	a2,0
    for (size_t size = 1; size < n; size <<= 1) order++;
ffffffffc02011ce:	0786                	slli	a5,a5,0x1
ffffffffc02011d0:	2605                	addiw	a2,a2,1
ffffffffc02011d2:	ff07eee3          	bltu	a5,a6,ffffffffc02011ce <buddy_alloc_pages+0x24>
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
ffffffffc02011d6:	4805                	li	a6,1
ffffffffc02011d8:	00c81833          	sll	a6,a6,a2
ffffffffc02011dc:	090feb63          	bltu	t6,a6,ffffffffc0201272 <buddy_alloc_pages+0xc8>
    while (found <= BUDDY_MAX_ORDER && list_empty(&buddy.lists[found])) found++;
ffffffffc02011e0:	47d1                	li	a5,20
ffffffffc02011e2:	08c7c863          	blt	a5,a2,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc02011e6:	00461713          	slli	a4,a2,0x4
ffffffffc02011ea:	977a                	add	a4,a4,t5
    int order = 0;
ffffffffc02011ec:	87b2                	mv	a5,a2
    while (found <= BUDDY_MAX_ORDER && list_empty(&buddy.lists[found])) found++;
ffffffffc02011ee:	46d5                	li	a3,21
ffffffffc02011f0:	a029                	j	ffffffffc02011fa <buddy_alloc_pages+0x50>
ffffffffc02011f2:	2785                	addiw	a5,a5,1
ffffffffc02011f4:	0741                	addi	a4,a4,16
ffffffffc02011f6:	06d78e63          	beq	a5,a3,ffffffffc0201272 <buddy_alloc_pages+0xc8>
    return list->next == list;
ffffffffc02011fa:	670c                	ld	a1,8(a4)
ffffffffc02011fc:	fee58be3          	beq	a1,a4,ffffffffc02011f2 <buddy_alloc_pages+0x48>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201200:	6588                	ld	a0,8(a1)
ffffffffc0201202:	0005b883          	ld	a7,0(a1)
    ClearPageProperty(base);
ffffffffc0201206:	ff05b703          	ld	a4,-16(a1)
ffffffffc020120a:	fff78693          	addi	a3,a5,-1
    prev->next = next;
ffffffffc020120e:	00a8b423          	sd	a0,8(a7)
    next->prev = prev;
ffffffffc0201212:	01153023          	sd	a7,0(a0)
ffffffffc0201216:	9b75                	andi	a4,a4,-3
ffffffffc0201218:	0692                	slli	a3,a3,0x4
    elm->prev = elm->next = elm;
ffffffffc020121a:	e58c                	sd	a1,8(a1)
ffffffffc020121c:	e18c                	sd	a1,0(a1)
ffffffffc020121e:	fee5b823          	sd	a4,-16(a1)
    base->property = 0;
ffffffffc0201222:	fe05ac23          	sw	zero,-8(a1)
    struct Page *base = le2page(list_next(&buddy.lists[found]), page_link);
ffffffffc0201226:	fe858513          	addi	a0,a1,-24
    while (found > k) {
ffffffffc020122a:	96fa                	add	a3,a3,t5
        struct Page *other = base + (1UL << found);
ffffffffc020122c:	02800e93          	li	t4,40
        other->property = 1UL << found;
ffffffffc0201230:	4e05                	li	t3,1
    while (found > k) {
ffffffffc0201232:	02f65b63          	bge	a2,a5,ffffffffc0201268 <buddy_alloc_pages+0xbe>
        found--;
ffffffffc0201236:	37fd                	addiw	a5,a5,-1
        struct Page *other = base + (1UL << found);
ffffffffc0201238:	00fe9733          	sll	a4,t4,a5
ffffffffc020123c:	972a                	add	a4,a4,a0
        SetPageProperty(other);
ffffffffc020123e:	670c                	ld	a1,8(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201240:	0086b883          	ld	a7,8(a3)
        other->property = 1UL << found;
ffffffffc0201244:	00fe1333          	sll	t1,t3,a5
        SetPageProperty(other);
ffffffffc0201248:	0025e593          	ori	a1,a1,2
ffffffffc020124c:	e70c                	sd	a1,8(a4)
        other->property = 1UL << found;
ffffffffc020124e:	00672823          	sw	t1,16(a4) # 100010 <kern_entry-0xffffffffc00ffff0>
        list_add(&buddy.lists[found], &other->page_link);
ffffffffc0201252:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0201256:	00b8b023          	sd	a1,0(a7)
ffffffffc020125a:	e68c                	sd	a1,8(a3)
    elm->prev = prev;
ffffffffc020125c:	ef14                	sd	a3,24(a4)
    elm->next = next;
ffffffffc020125e:	03173023          	sd	a7,32(a4)
    while (found > k) {
ffffffffc0201262:	16c1                	addi	a3,a3,-16
ffffffffc0201264:	fcc799e3          	bne	a5,a2,ffffffffc0201236 <buddy_alloc_pages+0x8c>
    buddy.nr_free -= 1UL << k;
ffffffffc0201268:	410f8833          	sub	a6,t6,a6
ffffffffc020126c:	150f3823          	sd	a6,336(t5)
    return base;
ffffffffc0201270:	8082                	ret
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
ffffffffc0201272:	4501                	li	a0,0
}
ffffffffc0201274:	8082                	ret
    if (k < 0 || (1UL << k) > buddy.nr_free) return NULL;
ffffffffc0201276:	fe0f8ee3          	beqz	t6,ffffffffc0201272 <buddy_alloc_pages+0xc8>
    int order = 0;
ffffffffc020127a:	4601                	li	a2,0
ffffffffc020127c:	b7ad                	j	ffffffffc02011e6 <buddy_alloc_pages+0x3c>
buddy_alloc_pages(size_t n) {
ffffffffc020127e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201280:	00001697          	auipc	a3,0x1
ffffffffc0201284:	61868693          	addi	a3,a3,1560 # ffffffffc0202898 <etext+0x616>
ffffffffc0201288:	00001617          	auipc	a2,0x1
ffffffffc020128c:	28060613          	addi	a2,a2,640 # ffffffffc0202508 <etext+0x286>
ffffffffc0201290:	05700593          	li	a1,87
ffffffffc0201294:	00001517          	auipc	a0,0x1
ffffffffc0201298:	28c50513          	addi	a0,a0,652 # ffffffffc0202520 <etext+0x29e>
buddy_alloc_pages(size_t n) {
ffffffffc020129c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020129e:	f25fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02012a2 <pool_reset>:
pool_reset(void) {
ffffffffc02012a2:	1141                	addi	sp,sp,-16
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	d9468693          	addi	a3,a3,-620 # ffffffffc0207038 <buddy>
ffffffffc02012ac:	e406                	sd	ra,8(sp)
ffffffffc02012ae:	87b6                	mv	a5,a3
ffffffffc02012b0:	00006717          	auipc	a4,0x6
ffffffffc02012b4:	ed870713          	addi	a4,a4,-296 # ffffffffc0207188 <buddy+0x150>
    elm->prev = elm->next = elm;
ffffffffc02012b8:	e79c                	sd	a5,8(a5)
ffffffffc02012ba:	e39c                	sd	a5,0(a5)
    for (int k = 0; k <= BUDDY_MAX_ORDER; k++) list_init(&buddy.lists[k]);
ffffffffc02012bc:	07c1                	addi	a5,a5,16
ffffffffc02012be:	fee79de3          	bne	a5,a4,ffffffffc02012b8 <pool_reset+0x16>
    buddy.nr_free = 0;
ffffffffc02012c2:	00006797          	auipc	a5,0x6
ffffffffc02012c6:	ec07b323          	sd	zero,-314(a5) # ffffffffc0207188 <buddy+0x150>
    buddy.first = npage;
ffffffffc02012ca:	00007797          	auipc	a5,0x7
ffffffffc02012ce:	be67b783          	ld	a5,-1050(a5) # ffffffffc0207eb0 <npage>
ffffffffc02012d2:	14f6bc23          	sd	a5,344(a3)
    memset(allowed, 0, sizeof(allowed));
ffffffffc02012d6:	02000613          	li	a2,32
    buddy.end = nbase;
ffffffffc02012da:	00002797          	auipc	a5,0x2
ffffffffc02012de:	d8e7b783          	ld	a5,-626(a5) # ffffffffc0203068 <nbase>
    memset(allowed, 0, sizeof(allowed));
ffffffffc02012e2:	4581                	li	a1,0
ffffffffc02012e4:	00006517          	auipc	a0,0x6
ffffffffc02012e8:	d3450513          	addi	a0,a0,-716 # ffffffffc0207018 <allowed>
    buddy.end = nbase;
ffffffffc02012ec:	16f6b023          	sd	a5,352(a3)
    memset(allowed, 0, sizeof(allowed));
ffffffffc02012f0:	745000ef          	jal	ra,ffffffffc0202234 <memset>
    memset(occupied, 0, sizeof(occupied));
ffffffffc02012f4:	02000613          	li	a2,32
ffffffffc02012f8:	4581                	li	a1,0
ffffffffc02012fa:	00006517          	auipc	a0,0x6
ffffffffc02012fe:	50e50513          	addi	a0,a0,1294 # ffffffffc0207808 <occupied>
ffffffffc0201302:	733000ef          	jal	ra,ffffffffc0202234 <memset>
    for (int i = 0; i < TEST_PAGES; i++) {
ffffffffc0201306:	00007797          	auipc	a5,0x7
ffffffffc020130a:	ba27b783          	ld	a5,-1118(a5) # ffffffffc0207ea8 <test_base>
ffffffffc020130e:	50078613          	addi	a2,a5,1280
ffffffffc0201312:	469d                	li	a3,7
        SetPageReserved(test_base+i);
ffffffffc0201314:	4705                	li	a4,1
        test_base[i].flags = test_base[i].property = 0;
ffffffffc0201316:	0007a823          	sw	zero,16(a5)
ffffffffc020131a:	c394                	sw	a3,0(a5)
        SetPageReserved(test_base+i);
ffffffffc020131c:	e798                	sd	a4,8(a5)
    for (int i = 0; i < TEST_PAGES; i++) {
ffffffffc020131e:	02878793          	addi	a5,a5,40
ffffffffc0201322:	fef61ae3          	bne	a2,a5,ffffffffc0201316 <pool_reset+0x74>
}
ffffffffc0201326:	60a2                	ld	ra,8(sp)
ffffffffc0201328:	0141                	addi	sp,sp,16
ffffffffc020132a:	8082                	ret

ffffffffc020132c <buddy_check>:

static void
buddy_check(void) {
ffffffffc020132c:	7101                	addi	sp,sp,-512
ffffffffc020132e:	ff86                	sd	ra,504(sp)
ffffffffc0201330:	e7d6                	sd	s5,456(sp)
ffffffffc0201332:	fba2                	sd	s0,496(sp)
ffffffffc0201334:	f7a6                	sd	s1,488(sp)
ffffffffc0201336:	f3ca                	sd	s2,480(sp)
ffffffffc0201338:	efce                	sd	s3,472(sp)
ffffffffc020133a:	ebd2                	sd	s4,464(sp)
ffffffffc020133c:	e3da                	sd	s6,448(sp)
ffffffffc020133e:	ff5e                	sd	s7,440(sp)
ffffffffc0201340:	fb62                	sd	s8,432(sp)
ffffffffc0201342:	f766                	sd	s9,424(sp)
ffffffffc0201344:	f36a                	sd	s10,416(sp)
ffffffffc0201346:	ef6e                	sd	s11,408(sp)
    check_consistency();
ffffffffc0201348:	c0cff0ef          	jal	ra,ffffffffc0200754 <check_consistency>
    size_t original = nr_free_pages();
ffffffffc020134c:	029000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc0201350:	87aa                	mv	a5,a0
    test_base = alloc_pages(TEST_PAGES);
ffffffffc0201352:	02000513          	li	a0,32
    size_t original = nr_free_pages();
ffffffffc0201356:	ec3e                	sd	a5,24(sp)
    test_base = alloc_pages(TEST_PAGES);
ffffffffc0201358:	00007a97          	auipc	s5,0x7
ffffffffc020135c:	b50a8a93          	addi	s5,s5,-1200 # ffffffffc0207ea8 <test_base>
ffffffffc0201360:	7fc000ef          	jal	ra,ffffffffc0201b5c <alloc_pages>
ffffffffc0201364:	00aab023          	sd	a0,0(s5)
    assert(test_base != NULL && nr_free_pages() == original - TEST_PAGES);
ffffffffc0201368:	60050a63          	beqz	a0,ffffffffc020197c <buddy_check+0x650>
ffffffffc020136c:	009000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc0201370:	67e2                	ld	a5,24(sp)
ffffffffc0201372:	1781                	addi	a5,a5,-32
ffffffffc0201374:	60f51463          	bne	a0,a5,ffffffffc020197c <buddy_check+0x650>
    memcpy(&saved_state, &buddy, sizeof(buddy));
ffffffffc0201378:	16800613          	li	a2,360
ffffffffc020137c:	00006597          	auipc	a1,0x6
ffffffffc0201380:	cbc58593          	addi	a1,a1,-836 # ffffffffc0207038 <buddy>
ffffffffc0201384:	00007517          	auipc	a0,0x7
ffffffffc0201388:	9a450513          	addi	a0,a0,-1628 # ffffffffc0207d28 <saved_state>
ffffffffc020138c:	6bb000ef          	jal	ra,ffffffffc0202246 <memcpy>
    memcpy(saved_pages, test_base, sizeof(saved_pages));
ffffffffc0201390:	000ab583          	ld	a1,0(s5)
ffffffffc0201394:	50000613          	li	a2,1280
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	49050513          	addi	a0,a0,1168 # ffffffffc0207828 <saved_pages>
ffffffffc02013a0:	6a7000ef          	jal	ra,ffffffffc0202246 <memcpy>

    pool_reset();
ffffffffc02013a4:	effff0ef          	jal	ra,ffffffffc02012a2 <pool_reset>
    expect_failure(1); // empty pool
ffffffffc02013a8:	4505                	li	a0,1
ffffffffc02013aa:	b5dff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    buddy_init_memmap(test_base+offset, n);
ffffffffc02013ae:	000ab503          	ld	a0,0(s5)
ffffffffc02013b2:	02000593          	li	a1,32
ffffffffc02013b6:	00006417          	auipc	s0,0x6
ffffffffc02013ba:	c6240413          	addi	s0,s0,-926 # ffffffffc0207018 <allowed>
ffffffffc02013be:	9abff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc02013c2:	00006917          	auipc	s2,0x6
ffffffffc02013c6:	c7690913          	addi	s2,s2,-906 # ffffffffc0207038 <buddy>
    buddy_init_memmap(test_base+offset, n);
ffffffffc02013ca:	8c22                	mv	s8,s0
ffffffffc02013cc:	87a2                	mv	a5,s0
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc02013ce:	4705                	li	a4,1
ffffffffc02013d0:	00e78023          	sb	a4,0(a5)
ffffffffc02013d4:	0785                	addi	a5,a5,1
ffffffffc02013d6:	ff279de3          	bne	a5,s2,ffffffffc02013d0 <buddy_check+0xa4>
    check_pool();
ffffffffc02013da:	e56ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    pool_register(0, TEST_PAGES);
    size_t requests[] = {1, 2, 4, 3, 5};
ffffffffc02013de:	00002797          	auipc	a5,0x2
ffffffffc02013e2:	83a78793          	addi	a5,a5,-1990 # ffffffffc0202c18 <etext+0x996>
ffffffffc02013e6:	638c                	ld	a1,0(a5)
ffffffffc02013e8:	6790                	ld	a2,8(a5)
ffffffffc02013ea:	6b94                	ld	a3,16(a5)
ffffffffc02013ec:	6f98                	ld	a4,24(a5)
ffffffffc02013ee:	739c                	ld	a5,32(a5)
ffffffffc02013f0:	f42e                	sd	a1,40(sp)
ffffffffc02013f2:	f832                	sd	a2,48(sp)
ffffffffc02013f4:	fc36                	sd	a3,56(sp)
ffffffffc02013f6:	e0ba                	sd	a4,64(sp)
ffffffffc02013f8:	e4be                	sd	a5,72(sp)
    struct Page *blocks[5];
    size_t used = 0;
    for (int i = 0; i < 5; i++) {
        blocks[i] = pool_alloc(requests[i]);
ffffffffc02013fa:	7da2                	ld	s11,40(sp)
ffffffffc02013fc:	05010c93          	addi	s9,sp,80
    size_t requests[] = {1, 2, 4, 3, 5};
ffffffffc0201400:	8a66                	mv	s4,s9
        blocks[i] = pool_alloc(requests[i]);
ffffffffc0201402:	856e                	mv	a0,s11
ffffffffc0201404:	feaff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
ffffffffc0201408:	00aa3023          	sd	a0,0(s4)
ffffffffc020140c:	02810b13          	addi	s6,sp,40
    size_t requests[] = {1, 2, 4, 3, 5};
ffffffffc0201410:	4b85                	li	s7,1
ffffffffc0201412:	4481                	li	s1,0
    size_t used = 0;
ffffffffc0201414:	4981                	li	s3,0
        assert(blocks[i] != NULL);
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
ffffffffc0201416:	4d0d                	li	s10,3
        assert(blocks[i] != NULL);
ffffffffc0201418:	c121                	beqz	a0,ffffffffc0201458 <buddy_check+0x12c>
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
ffffffffc020141a:	0004871b          	sext.w	a4,s1
ffffffffc020141e:	05a48d63          	beq	s1,s10,ffffffffc0201478 <buddy_check+0x14c>
ffffffffc0201422:	4791                	li	a5,4
ffffffffc0201424:	50f70a63          	beq	a4,a5,ffffffffc0201938 <buddy_check+0x60c>
        assert(nr_free_pages() == TEST_PAGES - used);
ffffffffc0201428:	74c000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
ffffffffc020142c:	99ee                	add	s3,s3,s11
        assert(nr_free_pages() == TEST_PAGES - used);
ffffffffc020142e:	02000793          	li	a5,32
ffffffffc0201432:	413787b3          	sub	a5,a5,s3
ffffffffc0201436:	04f51a63          	bne	a0,a5,ffffffffc020148a <buddy_check+0x15e>
    for (int i = 0; i < 5; i++) {
ffffffffc020143a:	4795                	li	a5,5
ffffffffc020143c:	06fb8763          	beq	s7,a5,ffffffffc02014aa <buddy_check+0x17e>
        blocks[i] = pool_alloc(requests[i]);
ffffffffc0201440:	008b3d83          	ld	s11,8(s6)
ffffffffc0201444:	0a21                	addi	s4,s4,8
ffffffffc0201446:	0b21                	addi	s6,s6,8
ffffffffc0201448:	856e                	mv	a0,s11
ffffffffc020144a:	fa4ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
ffffffffc020144e:	00aa3023          	sd	a0,0(s4)
ffffffffc0201452:	0485                	addi	s1,s1,1
ffffffffc0201454:	2b85                	addiw	s7,s7,1
        assert(blocks[i] != NULL);
ffffffffc0201456:	f171                	bnez	a0,ffffffffc020141a <buddy_check+0xee>
ffffffffc0201458:	00001697          	auipc	a3,0x1
ffffffffc020145c:	61868693          	addi	a3,a3,1560 # ffffffffc0202a70 <etext+0x7ee>
ffffffffc0201460:	00001617          	auipc	a2,0x1
ffffffffc0201464:	0a860613          	addi	a2,a2,168 # ffffffffc0202508 <etext+0x286>
ffffffffc0201468:	11d00593          	li	a1,285
ffffffffc020146c:	00001517          	auipc	a0,0x1
ffffffffc0201470:	0b450513          	addi	a0,a0,180 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201474:	d4ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(nr_free_pages() == TEST_PAGES - used);
ffffffffc0201478:	6fc000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
ffffffffc020147c:	0991                	addi	s3,s3,4
        assert(nr_free_pages() == TEST_PAGES - used);
ffffffffc020147e:	02000793          	li	a5,32
ffffffffc0201482:	413787b3          	sub	a5,a5,s3
ffffffffc0201486:	faa78de3          	beq	a5,a0,ffffffffc0201440 <buddy_check+0x114>
ffffffffc020148a:	00001697          	auipc	a3,0x1
ffffffffc020148e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0202a88 <etext+0x806>
ffffffffc0201492:	00001617          	auipc	a2,0x1
ffffffffc0201496:	07660613          	addi	a2,a2,118 # ffffffffc0202508 <etext+0x286>
ffffffffc020149a:	11f00593          	li	a1,287
ffffffffc020149e:	00001517          	auipc	a0,0x1
ffffffffc02014a2:	08250513          	addi	a0,a0,130 # ffffffffc0202520 <etext+0x29e>
ffffffffc02014a6:	d1dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
ffffffffc02014aa:	1884                	addi	s1,sp,112
ffffffffc02014ac:	04810993          	addi	s3,sp,72
    }
    for (int i = 4; i >= 0; i--) pool_free(blocks[i], requests[i]);
ffffffffc02014b0:	0009b583          	ld	a1,0(s3)
ffffffffc02014b4:	6088                	ld	a0,0(s1)
ffffffffc02014b6:	19e1                	addi	s3,s3,-8
ffffffffc02014b8:	b2bff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
ffffffffc02014bc:	87a6                	mv	a5,s1
ffffffffc02014be:	14e1                	addi	s1,s1,-8
ffffffffc02014c0:	ff9798e3          	bne	a5,s9,ffffffffc02014b0 <buddy_check+0x184>
    assert(nr_free_pages() == TEST_PAGES);
ffffffffc02014c4:	6b0000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02014c8:	02000793          	li	a5,32
ffffffffc02014cc:	48f51863          	bne	a0,a5,ffffffffc020195c <buddy_check+0x630>
    expect_failure(TEST_PAGES+1);
ffffffffc02014d0:	02100513          	li	a0,33
ffffffffc02014d4:	a33ff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    expect_failure(BUDDY_MAX_PAGES+1);
ffffffffc02014d8:	00100537          	lui	a0,0x100
ffffffffc02014dc:	0505                	addi	a0,a0,1
ffffffffc02014de:	a29ff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    expect_failure((size_t)-1); // rounding overflow input
ffffffffc02014e2:	557d                	li	a0,-1
ffffffffc02014e4:	a23ff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    expect_failure(((size_t)-1 >> 1)+1);
ffffffffc02014e8:	557d                	li	a0,-1
ffffffffc02014ea:	157e                	slli	a0,a0,0x3f
ffffffffc02014ec:	a1bff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>

    // One aligned block: exhaust by splitting, then merge in both directions.
    for (int reverse = 0; reverse < 2; reverse++) {
ffffffffc02014f0:	4481                	li	s1,0
ffffffffc02014f2:	00002c97          	auipc	s9,0x2
ffffffffc02014f6:	b6ec8c93          	addi	s9,s9,-1170 # ffffffffc0203060 <error_string+0x40>
ffffffffc02014fa:	13810b13          	addi	s6,sp,312
ffffffffc02014fe:	17810a13          	addi	s4,sp,376
ffffffffc0201502:	4b9d                	li	s7,7
        pool_reset();
ffffffffc0201504:	d9fff0ef          	jal	ra,ffffffffc02012a2 <pool_reset>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201508:	000ab503          	ld	a0,0(s5)
ffffffffc020150c:	45a1                	li	a1,8
ffffffffc020150e:	89da                	mv	s3,s6
ffffffffc0201510:	859ff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201514:	000cb783          	ld	a5,0(s9)
ffffffffc0201518:	00fc3023          	sd	a5,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
    check_pool();
ffffffffc020151c:	d14ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
        pool_register(0, 8);
        struct Page *singles[8];
        for (int i = 0; i < 8; i++) { singles[i] = pool_alloc(1); assert(singles[i]); }
ffffffffc0201520:	4505                	li	a0,1
ffffffffc0201522:	eccff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
ffffffffc0201526:	00a9b023          	sd	a0,0(s3)
ffffffffc020152a:	40050963          	beqz	a0,ffffffffc020193c <buddy_check+0x610>
ffffffffc020152e:	09a1                	addi	s3,s3,8
ffffffffc0201530:	ff4998e3          	bne	s3,s4,ffffffffc0201520 <buddy_check+0x1f4>
        expect_failure(1);
ffffffffc0201534:	4505                	li	a0,1
ffffffffc0201536:	9d1ff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
        for (int i = 0; i < 8; i++) pool_free(singles[reverse ? 7-i : i], 1);
ffffffffc020153a:	4d01                	li	s10,0
ffffffffc020153c:	49a1                	li	s3,8
ffffffffc020153e:	87ea                	mv	a5,s10
ffffffffc0201540:	c099                	beqz	s1,ffffffffc0201546 <buddy_check+0x21a>
ffffffffc0201542:	41ab87bb          	subw	a5,s7,s10
ffffffffc0201546:	078e                	slli	a5,a5,0x3
ffffffffc0201548:	0b18                	addi	a4,sp,400
ffffffffc020154a:	97ba                	add	a5,a5,a4
ffffffffc020154c:	fa87b503          	ld	a0,-88(a5)
ffffffffc0201550:	2d05                	addiw	s10,s10,1
ffffffffc0201552:	4585                	li	a1,1
ffffffffc0201554:	a8fff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
ffffffffc0201558:	ff3d13e3          	bne	s10,s3,ffffffffc020153e <buddy_check+0x212>
        struct Page *whole = pool_alloc(8);
ffffffffc020155c:	4521                	li	a0,8
ffffffffc020155e:	e90ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
        assert(whole == test_base);
ffffffffc0201562:	000ab783          	ld	a5,0(s5)
ffffffffc0201566:	5ca79b63          	bne	a5,a0,ffffffffc0201b3c <buddy_check+0x810>
        pool_free(whole, 8);
ffffffffc020156a:	45a1                	li	a1,8
ffffffffc020156c:	a77ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
    for (int reverse = 0; reverse < 2; reverse++) {
ffffffffc0201570:	3c048263          	beqz	s1,ffffffffc0201934 <buddy_check+0x608>
    }

    pool_reset();
ffffffffc0201574:	d2fff0ef          	jal	ra,ffffffffc02012a2 <pool_reset>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201578:	000ab503          	ld	a0,0(s5)
ffffffffc020157c:	45a1                	li	a1,8
    pool_register(0, 8);
    struct Page *single[8] = {0};
ffffffffc020157e:	49a1                	li	s3,8
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201580:	fe8ff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201584:	000cb783          	ld	a5,0(s9)
ffffffffc0201588:	00fc3023          	sd	a5,0(s8)
    check_pool();
ffffffffc020158c:	ca4ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    struct Page *single[8] = {0};
ffffffffc0201590:	fc82                	sd	zero,120(sp)
ffffffffc0201592:	e102                	sd	zero,128(sp)
ffffffffc0201594:	e502                	sd	zero,136(sp)
ffffffffc0201596:	e902                	sd	zero,144(sp)
ffffffffc0201598:	ed02                	sd	zero,152(sp)
ffffffffc020159a:	f102                	sd	zero,160(sp)
ffffffffc020159c:	f502                	sd	zero,168(sp)
ffffffffc020159e:	f902                	sd	zero,176(sp)
    for (int i = 0; i < 8; i++) {
        struct Page *p = pool_alloc(1);
        assert(p != NULL);
        single[p-test_base] = p;
ffffffffc02015a0:	00002497          	auipc	s1,0x2
ffffffffc02015a4:	ab84b483          	ld	s1,-1352(s1) # ffffffffc0203058 <error_string+0x38>
        struct Page *p = pool_alloc(1);
ffffffffc02015a8:	4505                	li	a0,1
ffffffffc02015aa:	e44ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
        assert(p != NULL);
ffffffffc02015ae:	56050763          	beqz	a0,ffffffffc0201b1c <buddy_check+0x7f0>
        single[p-test_base] = p;
ffffffffc02015b2:	000ab783          	ld	a5,0(s5)
ffffffffc02015b6:	0b18                	addi	a4,sp,400
    for (int i = 0; i < 8; i++) {
ffffffffc02015b8:	39fd                	addiw	s3,s3,-1
        single[p-test_base] = p;
ffffffffc02015ba:	40f507b3          	sub	a5,a0,a5
ffffffffc02015be:	878d                	srai	a5,a5,0x3
ffffffffc02015c0:	029787b3          	mul	a5,a5,s1
ffffffffc02015c4:	078e                	slli	a5,a5,0x3
ffffffffc02015c6:	97ba                	add	a5,a5,a4
ffffffffc02015c8:	eea7b423          	sd	a0,-280(a5)
    for (int i = 0; i < 8; i++) {
ffffffffc02015cc:	fc099ee3          	bnez	s3,ffffffffc02015a8 <buddy_check+0x27c>
    }
    pool_free(single[1], 1);
ffffffffc02015d0:	650a                	ld	a0,128(sp)
ffffffffc02015d2:	4585                	li	a1,1
ffffffffc02015d4:	a0fff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
    pool_free(single[2], 1); // adjacent, but XOR partners are 0 and 3
ffffffffc02015d8:	652a                	ld	a0,136(sp)
ffffffffc02015da:	4585                	li	a1,1
ffffffffc02015dc:	a07ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
    assert(nr_free_pages() == 2);
ffffffffc02015e0:	594000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02015e4:	4789                	li	a5,2
ffffffffc02015e6:	50f51b63          	bne	a0,a5,ffffffffc0201afc <buddy_check+0x7d0>
    expect_failure(2);
ffffffffc02015ea:	91dff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    pool_free(single[0], 1);
ffffffffc02015ee:	7566                	ld	a0,120(sp)
ffffffffc02015f0:	4585                	li	a1,1
ffffffffc02015f2:	9f1ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
    struct Page *pair = pool_alloc(2);
ffffffffc02015f6:	4509                	li	a0,2
ffffffffc02015f8:	df6ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
    assert(pair == test_base); // 2 cannot merge while 3 remains occupied
ffffffffc02015fc:	000ab783          	ld	a5,0(s5)
ffffffffc0201600:	4ca79e63          	bne	a5,a0,ffffffffc0201adc <buddy_check+0x7b0>
    pool_free(pair, 2);
ffffffffc0201604:	4589                	li	a1,2
ffffffffc0201606:	9ddff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
    for (int i = 3; i < 8; i++) pool_free(single[i], 1);
ffffffffc020160a:	0904                	addi	s1,sp,144
ffffffffc020160c:	6088                	ld	a0,0(s1)
ffffffffc020160e:	4585                	li	a1,1
ffffffffc0201610:	04a1                	addi	s1,s1,8
ffffffffc0201612:	9d1ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
ffffffffc0201616:	193c                	addi	a5,sp,184
ffffffffc0201618:	fe979ae3          	bne	a5,s1,ffffffffc020160c <buddy_check+0x2e0>
    struct Page *whole = pool_alloc(8);
ffffffffc020161c:	4521                	li	a0,8
ffffffffc020161e:	dd0ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
    assert(whole == test_base);
ffffffffc0201622:	000ab783          	ld	a5,0(s5)
ffffffffc0201626:	48a79b63          	bne	a5,a0,ffffffffc0201abc <buddy_check+0x790>
    pool_free(whole, 8);
ffffffffc020162a:	45a1                	li	a1,8
ffffffffc020162c:	9b7ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>

    // Unaligned length 5, isolated single page, reserved holes, reverse-order
    // adjacent registrations, and partners below/above the managed envelope.
    pool_reset();
ffffffffc0201630:	c73ff0ef          	jal	ra,ffffffffc02012a2 <pool_reset>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201634:	000ab503          	ld	a0,0(s5)
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201638:	10100993          	li	s3,257
    buddy_init_memmap(test_base+offset, n);
ffffffffc020163c:	4595                	li	a1,5
ffffffffc020163e:	02850513          	addi	a0,a0,40 # 100028 <kern_entry-0xffffffffc00fffd8>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201642:	4a05                	li	s4,1
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201644:	f24ff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201648:	013c1123          	sh	s3,2(s8)
ffffffffc020164c:	013c1223          	sh	s3,4(s8)
ffffffffc0201650:	014c00a3          	sb	s4,1(s8)
    check_pool();
ffffffffc0201654:	bdcff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201658:	000ab503          	ld	a0,0(s5)
ffffffffc020165c:	4585                	li	a1,1
    check_pool();
ffffffffc020165e:	84da                	mv	s1,s6
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201660:	16850513          	addi	a0,a0,360
ffffffffc0201664:	f04ff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201668:	014c04a3          	sb	s4,9(s8)
    check_pool();
ffffffffc020166c:	bc4ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201670:	000ab503          	ld	a0,0(s5)
ffffffffc0201674:	4589                	li	a1,2
ffffffffc0201676:	2d050513          	addi	a0,a0,720
ffffffffc020167a:	eeeff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc020167e:	013c1923          	sh	s3,18(s8)
    check_pool();
ffffffffc0201682:	baeff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    buddy_init_memmap(test_base+offset, n);
ffffffffc0201686:	000ab503          	ld	a0,0(s5)
ffffffffc020168a:	4589                	li	a1,2
ffffffffc020168c:	28050513          	addi	a0,a0,640
ffffffffc0201690:	ed8ff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201694:	013c1823          	sh	s3,16(s8)
    check_pool();
ffffffffc0201698:	b98ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    buddy_init_memmap(test_base+offset, n);
ffffffffc020169c:	000ab503          	ld	a0,0(s5)
ffffffffc02016a0:	4585                	li	a1,1
ffffffffc02016a2:	19010993          	addi	s3,sp,400
ffffffffc02016a6:	4d850513          	addi	a0,a0,1240
ffffffffc02016aa:	ebeff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc02016ae:	014c0fa3          	sb	s4,31(s8)
    check_pool();
ffffffffc02016b2:	b7eff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    pool_register(9, 1);
    pool_register(18, 2);
    pool_register(16, 2); // must coalesce across registration boundaries
    pool_register(31, 1);
    struct Page *registered[11];
    for (int i = 0; i < 11; i++) { registered[i] = pool_alloc(1); assert(registered[i]); }
ffffffffc02016b6:	4505                	li	a0,1
ffffffffc02016b8:	d36ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
ffffffffc02016bc:	e088                	sd	a0,0(s1)
ffffffffc02016be:	3c050f63          	beqz	a0,ffffffffc0201a9c <buddy_check+0x770>
ffffffffc02016c2:	04a1                	addi	s1,s1,8
ffffffffc02016c4:	fe9999e3          	bne	s3,s1,ffffffffc02016b6 <buddy_check+0x38a>
    expect_failure(1);
ffffffffc02016c8:	4505                	li	a0,1
ffffffffc02016ca:	83dff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>
    for (int i = 10; i >= 0; i--) pool_free(registered[i], 1);
ffffffffc02016ce:	0324                	addi	s1,sp,392
ffffffffc02016d0:	6088                	ld	a0,0(s1)
ffffffffc02016d2:	4585                	li	a1,1
ffffffffc02016d4:	90fff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
ffffffffc02016d8:	87a6                	mv	a5,s1
ffffffffc02016da:	14e1                	addi	s1,s1,-8
ffffffffc02016dc:	fefb1ae3          	bne	s6,a5,ffffffffc02016d0 <buddy_check+0x3a4>
    assert(nr_free_pages() == 11);
ffffffffc02016e0:	494000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02016e4:	47ad                	li	a5,11
ffffffffc02016e6:	38f51b63          	bne	a0,a5,ffffffffc0201a7c <buddy_check+0x750>
    expect_failure(8); // enough pages, no order-3 block
ffffffffc02016ea:	4521                	li	a0,8
ffffffffc02016ec:	81bff0ef          	jal	ra,ffffffffc0200f06 <expect_failure>

    // Bounded deterministic mixed requests, with a separate occupancy oracle.
    pool_reset();
ffffffffc02016f0:	bb3ff0ef          	jal	ra,ffffffffc02012a2 <pool_reset>
    buddy_init_memmap(test_base+offset, n);
ffffffffc02016f4:	000ab503          	ld	a0,0(s5)
ffffffffc02016f8:	02000593          	li	a1,32
ffffffffc02016fc:	e6cff0ef          	jal	ra,ffffffffc0200d68 <buddy_init_memmap>
    for (int i = offset; i < offset+n; i++) allowed[i] = 1;
ffffffffc0201700:	4785                	li	a5,1
ffffffffc0201702:	00f40023          	sb	a5,0(s0)
ffffffffc0201706:	0405                	addi	s0,s0,1
ffffffffc0201708:	ff241de3          	bne	s0,s2,ffffffffc0201702 <buddy_check+0x3d6>
    check_pool();
ffffffffc020170c:	b24ff0ef          	jal	ra,ffffffffc0200a30 <check_pool>
    pool_register(0, TEST_PAGES);
    struct Page *slots[8] = {0};
    size_t sizes[8] = {0};
    unsigned int random = 0x13579bdu;
ffffffffc0201710:	013584b7          	lui	s1,0x1358
    int successes = 0, failures = 0, releases = 0;
    for (int step = 0; step < 256; step++) {
        random = random * 1664525u + 1013904223u;
ffffffffc0201714:	001969b7          	lui	s3,0x196
ffffffffc0201718:	3c6ef937          	lui	s2,0x3c6ef
    struct Page *slots[8] = {0};
ffffffffc020171c:	fd02                	sd	zero,184(sp)
ffffffffc020171e:	e182                	sd	zero,192(sp)
ffffffffc0201720:	e582                	sd	zero,200(sp)
ffffffffc0201722:	e982                	sd	zero,208(sp)
ffffffffc0201724:	ed82                	sd	zero,216(sp)
ffffffffc0201726:	f182                	sd	zero,224(sp)
ffffffffc0201728:	f582                	sd	zero,232(sp)
ffffffffc020172a:	f982                	sd	zero,240(sp)
    size_t sizes[8] = {0};
ffffffffc020172c:	fd82                	sd	zero,248(sp)
ffffffffc020172e:	e202                	sd	zero,256(sp)
ffffffffc0201730:	e602                	sd	zero,264(sp)
ffffffffc0201732:	ea02                	sd	zero,272(sp)
ffffffffc0201734:	ee02                	sd	zero,280(sp)
ffffffffc0201736:	f202                	sd	zero,288(sp)
ffffffffc0201738:	f602                	sd	zero,296(sp)
ffffffffc020173a:	fa02                	sd	zero,304(sp)
ffffffffc020173c:	10000d93          	li	s11,256
ffffffffc0201740:	4501                	li	a0,0
    int successes = 0, failures = 0, releases = 0;
ffffffffc0201742:	4a01                	li	s4,0
ffffffffc0201744:	e802                	sd	zero,16(sp)
ffffffffc0201746:	e402                	sd	zero,8(sp)
    unsigned int random = 0x13579bdu;
ffffffffc0201748:	9bd48493          	addi	s1,s1,-1603 # 13579bd <kern_entry-0xffffffffbeea8643>
        random = random * 1664525u + 1013904223u;
ffffffffc020174c:	60d9899b          	addiw	s3,s3,1549
ffffffffc0201750:	35f9091b          	addiw	s2,s2,863
            pool_free(slots[slot], sizes[slot]);
            slots[slot] = NULL;
            releases++;
        } else {
            size_t n = ((random >> 8) % 9) + 1;
            memcpy(&failure_state, &buddy, sizeof(buddy));
ffffffffc0201754:	00006c97          	auipc	s9,0x6
ffffffffc0201758:	8e4c8c93          	addi	s9,s9,-1820 # ffffffffc0207038 <buddy>
ffffffffc020175c:	00006c17          	auipc	s8,0x6
ffffffffc0201760:	f44c0c13          	addi	s8,s8,-188 # ffffffffc02076a0 <failure_state>
            memcpy(failure_pages, test_base, sizeof(failure_pages));
ffffffffc0201764:	00006b97          	auipc	s7,0x6
ffffffffc0201768:	a3cb8b93          	addi	s7,s7,-1476 # ffffffffc02071a0 <failure_pages>
ffffffffc020176c:	a81d                	j	ffffffffc02017a2 <buddy_check+0x476>
            pool_free(slots[slot], sizes[slot]);
ffffffffc020176e:	0b1c                	addi	a5,sp,400
ffffffffc0201770:	003b1413          	slli	s0,s6,0x3
ffffffffc0201774:	943e                	add	s0,s0,a5
ffffffffc0201776:	f6843583          	ld	a1,-152(s0)
            releases++;
ffffffffc020177a:	2a05                	addiw	s4,s4,1
            pool_free(slots[slot], sizes[slot]);
ffffffffc020177c:	867ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
            slots[slot] = NULL;
ffffffffc0201780:	f2043423          	sd	zero,-216(s0)
    for (int step = 0; step < 256; step++) {
ffffffffc0201784:	3dfd                	addiw	s11,s11,-1
ffffffffc0201786:	080d8063          	beqz	s11,ffffffffc0201806 <buddy_check+0x4da>
        random = random * 1664525u + 1013904223u;
ffffffffc020178a:	033d07bb          	mulw	a5,s10,s3
        if (slots[slot]) {
ffffffffc020178e:	0b18                	addi	a4,sp,400
        random = random * 1664525u + 1013904223u;
ffffffffc0201790:	012787bb          	addw	a5,a5,s2
        unsigned int slot = (random >> 16) % 8;
ffffffffc0201794:	0107d79b          	srliw	a5,a5,0x10
        if (slots[slot]) {
ffffffffc0201798:	8b9d                	andi	a5,a5,7
ffffffffc020179a:	078e                	slli	a5,a5,0x3
ffffffffc020179c:	97ba                	add	a5,a5,a4
ffffffffc020179e:	f287b503          	ld	a0,-216(a5)
        random = random * 1664525u + 1013904223u;
ffffffffc02017a2:	033487bb          	mulw	a5,s1,s3
ffffffffc02017a6:	012784bb          	addw	s1,a5,s2
        unsigned int slot = (random >> 16) % 8;
ffffffffc02017aa:	0104d71b          	srliw	a4,s1,0x10
        random = random * 1664525u + 1013904223u;
ffffffffc02017ae:	8d26                	mv	s10,s1
        unsigned int slot = (random >> 16) % 8;
ffffffffc02017b0:	00777b13          	andi	s6,a4,7
        if (slots[slot]) {
ffffffffc02017b4:	fd4d                	bnez	a0,ffffffffc020176e <buddy_check+0x442>
            size_t n = ((random >> 8) % 9) + 1;
ffffffffc02017b6:	47a5                	li	a5,9
ffffffffc02017b8:	0084d41b          	srliw	s0,s1,0x8
ffffffffc02017bc:	02f4743b          	remuw	s0,s0,a5
            memcpy(&failure_state, &buddy, sizeof(buddy));
ffffffffc02017c0:	16800613          	li	a2,360
ffffffffc02017c4:	85e6                	mv	a1,s9
ffffffffc02017c6:	8562                	mv	a0,s8
ffffffffc02017c8:	27f000ef          	jal	ra,ffffffffc0202246 <memcpy>
            memcpy(failure_pages, test_base, sizeof(failure_pages));
ffffffffc02017cc:	000ab583          	ld	a1,0(s5)
ffffffffc02017d0:	50000613          	li	a2,1280
ffffffffc02017d4:	855e                	mv	a0,s7
ffffffffc02017d6:	271000ef          	jal	ra,ffffffffc0202246 <memcpy>
            size_t n = ((random >> 8) % 9) + 1;
ffffffffc02017da:	2405                	addiw	s0,s0,1
ffffffffc02017dc:	1402                	slli	s0,s0,0x20
ffffffffc02017de:	9001                	srli	s0,s0,0x20
            slots[slot] = pool_alloc(n);
ffffffffc02017e0:	8522                	mv	a0,s0
ffffffffc02017e2:	c0cff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
ffffffffc02017e6:	003b1713          	slli	a4,s6,0x3
ffffffffc02017ea:	0b1c                	addi	a5,sp,400
ffffffffc02017ec:	973e                	add	a4,a4,a5
ffffffffc02017ee:	f2a73423          	sd	a0,-216(a4)
            sizes[slot] = n;
ffffffffc02017f2:	f6873423          	sd	s0,-152(a4)
            if (slots[slot]) successes++;
ffffffffc02017f6:	0e050b63          	beqz	a0,ffffffffc02018ec <buddy_check+0x5c0>
ffffffffc02017fa:	67a2                	ld	a5,8(sp)
    for (int step = 0; step < 256; step++) {
ffffffffc02017fc:	3dfd                	addiw	s11,s11,-1
            if (slots[slot]) successes++;
ffffffffc02017fe:	2785                	addiw	a5,a5,1
ffffffffc0201800:	e43e                	sd	a5,8(sp)
    for (int step = 0; step < 256; step++) {
ffffffffc0201802:	f80d94e3          	bnez	s11,ffffffffc020178a <buddy_check+0x45e>
                assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
                assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
            }
        }
    }
    assert(successes && failures && releases);
ffffffffc0201806:	67a2                	ld	a5,8(sp)
ffffffffc0201808:	22078a63          	beqz	a5,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc020180c:	67c2                	ld	a5,16(sp)
ffffffffc020180e:	22078763          	beqz	a5,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc0201812:	220a0563          	beqz	s4,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc0201816:	19a4                	addi	s1,sp,248
ffffffffc0201818:	1920                	addi	s0,sp,184
ffffffffc020181a:	8926                	mv	s2,s1
    for (int i = 0; i < 8; i++) if (slots[i]) pool_free(slots[i], sizes[i]);
ffffffffc020181c:	6008                	ld	a0,0(s0)
ffffffffc020181e:	c501                	beqz	a0,ffffffffc0201826 <buddy_check+0x4fa>
ffffffffc0201820:	608c                	ld	a1,0(s1)
ffffffffc0201822:	fc0ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>
ffffffffc0201826:	0421                	addi	s0,s0,8
ffffffffc0201828:	04a1                	addi	s1,s1,8
ffffffffc020182a:	fe8919e3          	bne	s2,s0,ffffffffc020181c <buddy_check+0x4f0>
    assert(nr_free_pages() == TEST_PAGES);
ffffffffc020182e:	346000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc0201832:	02000793          	li	a5,32
ffffffffc0201836:	1ef51363          	bne	a0,a5,ffffffffc0201a1c <buddy_check+0x6f0>
    whole = pool_alloc(TEST_PAGES);
ffffffffc020183a:	bb4ff0ef          	jal	ra,ffffffffc0200bee <pool_alloc>
    assert(whole == test_base);
ffffffffc020183e:	000ab783          	ld	a5,0(s5)
ffffffffc0201842:	1aa79d63          	bne	a5,a0,ffffffffc02019fc <buddy_check+0x6d0>
    pool_free(whole, TEST_PAGES);
ffffffffc0201846:	02000593          	li	a1,32
ffffffffc020184a:	f98ff0ef          	jal	ra,ffffffffc0200fe2 <pool_free>

    // Restore original list heads at their original addresses, plus all arena
    // metadata, before returning the allocation to the real global allocator.
    memcpy(test_base, saved_pages, sizeof(saved_pages));
ffffffffc020184e:	000ab503          	ld	a0,0(s5)
ffffffffc0201852:	50000613          	li	a2,1280
ffffffffc0201856:	00006597          	auipc	a1,0x6
ffffffffc020185a:	fd258593          	addi	a1,a1,-46 # ffffffffc0207828 <saved_pages>
ffffffffc020185e:	1e9000ef          	jal	ra,ffffffffc0202246 <memcpy>
    memcpy(&buddy, &saved_state, sizeof(buddy));
ffffffffc0201862:	16800613          	li	a2,360
ffffffffc0201866:	00006597          	auipc	a1,0x6
ffffffffc020186a:	4c258593          	addi	a1,a1,1218 # ffffffffc0207d28 <saved_state>
ffffffffc020186e:	00005517          	auipc	a0,0x5
ffffffffc0201872:	7ca50513          	addi	a0,a0,1994 # ffffffffc0207038 <buddy>
ffffffffc0201876:	1d1000ef          	jal	ra,ffffffffc0202246 <memcpy>
    free_pages(test_base, TEST_PAGES);
ffffffffc020187a:	000ab503          	ld	a0,0(s5)
ffffffffc020187e:	02000593          	li	a1,32
ffffffffc0201882:	2e6000ef          	jal	ra,ffffffffc0201b68 <free_pages>
    assert(nr_free_pages() == original);
ffffffffc0201886:	2ee000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc020188a:	67e2                	ld	a5,24(sp)
ffffffffc020188c:	14f51863          	bne	a0,a5,ffffffffc02019dc <buddy_check+0x6b0>
    check_consistency();
ffffffffc0201890:	ec5fe0ef          	jal	ra,ffffffffc0200754 <check_consistency>
    struct Page *probe = alloc_pages(3);
ffffffffc0201894:	450d                	li	a0,3
ffffffffc0201896:	2c6000ef          	jal	ra,ffffffffc0201b5c <alloc_pages>
ffffffffc020189a:	842a                	mv	s0,a0
    assert(probe != NULL && nr_free_pages() == original - 4);
ffffffffc020189c:	12050063          	beqz	a0,ffffffffc02019bc <buddy_check+0x690>
ffffffffc02018a0:	2d4000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02018a4:	64e2                	ld	s1,24(sp)
ffffffffc02018a6:	ffc48793          	addi	a5,s1,-4
ffffffffc02018aa:	10f51963          	bne	a0,a5,ffffffffc02019bc <buddy_check+0x690>
    free_pages(probe, 3);
ffffffffc02018ae:	458d                	li	a1,3
ffffffffc02018b0:	8522                	mv	a0,s0
ffffffffc02018b2:	2b6000ef          	jal	ra,ffffffffc0201b68 <free_pages>
    assert(nr_free_pages() == original);
ffffffffc02018b6:	2be000ef          	jal	ra,ffffffffc0201b74 <nr_free_pages>
ffffffffc02018ba:	0e951163          	bne	a0,s1,ffffffffc020199c <buddy_check+0x670>
    check_consistency();
ffffffffc02018be:	e97fe0ef          	jal	ra,ffffffffc0200754 <check_consistency>
    cprintf("buddy_check() succeeded!\n");
}
ffffffffc02018c2:	745e                	ld	s0,496(sp)
ffffffffc02018c4:	70fe                	ld	ra,504(sp)
ffffffffc02018c6:	74be                	ld	s1,488(sp)
ffffffffc02018c8:	791e                	ld	s2,480(sp)
ffffffffc02018ca:	69fe                	ld	s3,472(sp)
ffffffffc02018cc:	6a5e                	ld	s4,464(sp)
ffffffffc02018ce:	6abe                	ld	s5,456(sp)
ffffffffc02018d0:	6b1e                	ld	s6,448(sp)
ffffffffc02018d2:	7bfa                	ld	s7,440(sp)
ffffffffc02018d4:	7c5a                	ld	s8,432(sp)
ffffffffc02018d6:	7cba                	ld	s9,424(sp)
ffffffffc02018d8:	7d1a                	ld	s10,416(sp)
ffffffffc02018da:	6dfa                	ld	s11,408(sp)
    cprintf("buddy_check() succeeded!\n");
ffffffffc02018dc:	00001517          	auipc	a0,0x1
ffffffffc02018e0:	30450513          	addi	a0,a0,772 # ffffffffc0202be0 <etext+0x95e>
}
ffffffffc02018e4:	20010113          	addi	sp,sp,512
    cprintf("buddy_check() succeeded!\n");
ffffffffc02018e8:	865fe06f          	j	ffffffffc020014c <cprintf>
                assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
ffffffffc02018ec:	16800613          	li	a2,360
ffffffffc02018f0:	85e6                	mv	a1,s9
ffffffffc02018f2:	8562                	mv	a0,s8
ffffffffc02018f4:	16b000ef          	jal	ra,ffffffffc020225e <memcmp>
                failures++;
ffffffffc02018f8:	67c2                	ld	a5,16(sp)
ffffffffc02018fa:	2785                	addiw	a5,a5,1
ffffffffc02018fc:	e83e                	sd	a5,16(sp)
                assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
ffffffffc02018fe:	14051f63          	bnez	a0,ffffffffc0201a5c <buddy_check+0x730>
                assert(memcmp(failure_pages, test_base, sizeof(failure_pages)) == 0);
ffffffffc0201902:	000ab583          	ld	a1,0(s5)
ffffffffc0201906:	50000613          	li	a2,1280
ffffffffc020190a:	855e                	mv	a0,s7
ffffffffc020190c:	153000ef          	jal	ra,ffffffffc020225e <memcmp>
ffffffffc0201910:	e6050ae3          	beqz	a0,ffffffffc0201784 <buddy_check+0x458>
ffffffffc0201914:	00001697          	auipc	a3,0x1
ffffffffc0201918:	02468693          	addi	a3,a3,36 # ffffffffc0202938 <etext+0x6b6>
ffffffffc020191c:	00001617          	auipc	a2,0x1
ffffffffc0201920:	bec60613          	addi	a2,a2,-1044 # ffffffffc0202508 <etext+0x286>
ffffffffc0201924:	17100593          	li	a1,369
ffffffffc0201928:	00001517          	auipc	a0,0x1
ffffffffc020192c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201930:	893fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
ffffffffc0201934:	4485                	li	s1,1
ffffffffc0201936:	b6f9                	j	ffffffffc0201504 <buddy_check+0x1d8>
        used += i == 3 ? 4 : i == 4 ? 8 : requests[i];
ffffffffc0201938:	4da1                	li	s11,8
ffffffffc020193a:	b4fd                	j	ffffffffc0201428 <buddy_check+0xfc>
        for (int i = 0; i < 8; i++) { singles[i] = pool_alloc(1); assert(singles[i]); }
ffffffffc020193c:	00001697          	auipc	a3,0x1
ffffffffc0201940:	19468693          	addi	a3,a3,404 # ffffffffc0202ad0 <etext+0x84e>
ffffffffc0201944:	00001617          	auipc	a2,0x1
ffffffffc0201948:	bc460613          	addi	a2,a2,-1084 # ffffffffc0202508 <etext+0x286>
ffffffffc020194c:	12d00593          	li	a1,301
ffffffffc0201950:	00001517          	auipc	a0,0x1
ffffffffc0201954:	bd050513          	addi	a0,a0,-1072 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201958:	86bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == TEST_PAGES);
ffffffffc020195c:	00001697          	auipc	a3,0x1
ffffffffc0201960:	15468693          	addi	a3,a3,340 # ffffffffc0202ab0 <etext+0x82e>
ffffffffc0201964:	00001617          	auipc	a2,0x1
ffffffffc0201968:	ba460613          	addi	a2,a2,-1116 # ffffffffc0202508 <etext+0x286>
ffffffffc020196c:	12200593          	li	a1,290
ffffffffc0201970:	00001517          	auipc	a0,0x1
ffffffffc0201974:	bb050513          	addi	a0,a0,-1104 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201978:	84bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(test_base != NULL && nr_free_pages() == original - TEST_PAGES);
ffffffffc020197c:	00001697          	auipc	a3,0x1
ffffffffc0201980:	0b468693          	addi	a3,a3,180 # ffffffffc0202a30 <etext+0x7ae>
ffffffffc0201984:	00001617          	auipc	a2,0x1
ffffffffc0201988:	b8460613          	addi	a2,a2,-1148 # ffffffffc0202508 <etext+0x286>
ffffffffc020198c:	11100593          	li	a1,273
ffffffffc0201990:	00001517          	auipc	a0,0x1
ffffffffc0201994:	b9050513          	addi	a0,a0,-1136 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201998:	82bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == original);
ffffffffc020199c:	00001697          	auipc	a3,0x1
ffffffffc02019a0:	1ec68693          	addi	a3,a3,492 # ffffffffc0202b88 <etext+0x906>
ffffffffc02019a4:	00001617          	auipc	a2,0x1
ffffffffc02019a8:	b6460613          	addi	a2,a2,-1180 # ffffffffc0202508 <etext+0x286>
ffffffffc02019ac:	18600593          	li	a1,390
ffffffffc02019b0:	00001517          	auipc	a0,0x1
ffffffffc02019b4:	b7050513          	addi	a0,a0,-1168 # ffffffffc0202520 <etext+0x29e>
ffffffffc02019b8:	80bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(probe != NULL && nr_free_pages() == original - 4);
ffffffffc02019bc:	00001697          	auipc	a3,0x1
ffffffffc02019c0:	1ec68693          	addi	a3,a3,492 # ffffffffc0202ba8 <etext+0x926>
ffffffffc02019c4:	00001617          	auipc	a2,0x1
ffffffffc02019c8:	b4460613          	addi	a2,a2,-1212 # ffffffffc0202508 <etext+0x286>
ffffffffc02019cc:	18400593          	li	a1,388
ffffffffc02019d0:	00001517          	auipc	a0,0x1
ffffffffc02019d4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0202520 <etext+0x29e>
ffffffffc02019d8:	feafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == original);
ffffffffc02019dc:	00001697          	auipc	a3,0x1
ffffffffc02019e0:	1ac68693          	addi	a3,a3,428 # ffffffffc0202b88 <etext+0x906>
ffffffffc02019e4:	00001617          	auipc	a2,0x1
ffffffffc02019e8:	b2460613          	addi	a2,a2,-1244 # ffffffffc0202508 <etext+0x286>
ffffffffc02019ec:	18100593          	li	a1,385
ffffffffc02019f0:	00001517          	auipc	a0,0x1
ffffffffc02019f4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0202520 <etext+0x29e>
ffffffffc02019f8:	fcafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(whole == test_base);
ffffffffc02019fc:	00001697          	auipc	a3,0x1
ffffffffc0201a00:	0e468693          	addi	a3,a3,228 # ffffffffc0202ae0 <etext+0x85e>
ffffffffc0201a04:	00001617          	auipc	a2,0x1
ffffffffc0201a08:	b0460613          	addi	a2,a2,-1276 # ffffffffc0202508 <etext+0x286>
ffffffffc0201a0c:	17900593          	li	a1,377
ffffffffc0201a10:	00001517          	auipc	a0,0x1
ffffffffc0201a14:	b1050513          	addi	a0,a0,-1264 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201a18:	faafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == TEST_PAGES);
ffffffffc0201a1c:	00001697          	auipc	a3,0x1
ffffffffc0201a20:	09468693          	addi	a3,a3,148 # ffffffffc0202ab0 <etext+0x82e>
ffffffffc0201a24:	00001617          	auipc	a2,0x1
ffffffffc0201a28:	ae460613          	addi	a2,a2,-1308 # ffffffffc0202508 <etext+0x286>
ffffffffc0201a2c:	17700593          	li	a1,375
ffffffffc0201a30:	00001517          	auipc	a0,0x1
ffffffffc0201a34:	af050513          	addi	a0,a0,-1296 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201a38:	f8afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(successes && failures && releases);
ffffffffc0201a3c:	00001697          	auipc	a3,0x1
ffffffffc0201a40:	12468693          	addi	a3,a3,292 # ffffffffc0202b60 <etext+0x8de>
ffffffffc0201a44:	00001617          	auipc	a2,0x1
ffffffffc0201a48:	ac460613          	addi	a2,a2,-1340 # ffffffffc0202508 <etext+0x286>
ffffffffc0201a4c:	17500593          	li	a1,373
ffffffffc0201a50:	00001517          	auipc	a0,0x1
ffffffffc0201a54:	ad050513          	addi	a0,a0,-1328 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201a58:	f6afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
                assert(memcmp(&failure_state, &buddy, sizeof(buddy)) == 0);
ffffffffc0201a5c:	00001697          	auipc	a3,0x1
ffffffffc0201a60:	ea468693          	addi	a3,a3,-348 # ffffffffc0202900 <etext+0x67e>
ffffffffc0201a64:	00001617          	auipc	a2,0x1
ffffffffc0201a68:	aa460613          	addi	a2,a2,-1372 # ffffffffc0202508 <etext+0x286>
ffffffffc0201a6c:	17000593          	li	a1,368
ffffffffc0201a70:	00001517          	auipc	a0,0x1
ffffffffc0201a74:	ab050513          	addi	a0,a0,-1360 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201a78:	f4afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == 11);
ffffffffc0201a7c:	00001697          	auipc	a3,0x1
ffffffffc0201a80:	0cc68693          	addi	a3,a3,204 # ffffffffc0202b48 <etext+0x8c6>
ffffffffc0201a84:	00001617          	auipc	a2,0x1
ffffffffc0201a88:	a8460613          	addi	a2,a2,-1404 # ffffffffc0202508 <etext+0x286>
ffffffffc0201a8c:	15600593          	li	a1,342
ffffffffc0201a90:	00001517          	auipc	a0,0x1
ffffffffc0201a94:	a9050513          	addi	a0,a0,-1392 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201a98:	f2afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    for (int i = 0; i < 11; i++) { registered[i] = pool_alloc(1); assert(registered[i]); }
ffffffffc0201a9c:	00001697          	auipc	a3,0x1
ffffffffc0201aa0:	09c68693          	addi	a3,a3,156 # ffffffffc0202b38 <etext+0x8b6>
ffffffffc0201aa4:	00001617          	auipc	a2,0x1
ffffffffc0201aa8:	a6460613          	addi	a2,a2,-1436 # ffffffffc0202508 <etext+0x286>
ffffffffc0201aac:	15300593          	li	a1,339
ffffffffc0201ab0:	00001517          	auipc	a0,0x1
ffffffffc0201ab4:	a7050513          	addi	a0,a0,-1424 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201ab8:	f0afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(whole == test_base);
ffffffffc0201abc:	00001697          	auipc	a3,0x1
ffffffffc0201ac0:	02468693          	addi	a3,a3,36 # ffffffffc0202ae0 <etext+0x85e>
ffffffffc0201ac4:	00001617          	auipc	a2,0x1
ffffffffc0201ac8:	a4460613          	addi	a2,a2,-1468 # ffffffffc0202508 <etext+0x286>
ffffffffc0201acc:	14700593          	li	a1,327
ffffffffc0201ad0:	00001517          	auipc	a0,0x1
ffffffffc0201ad4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201ad8:	eeafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(pair == test_base); // 2 cannot merge while 3 remains occupied
ffffffffc0201adc:	00001697          	auipc	a3,0x1
ffffffffc0201ae0:	04468693          	addi	a3,a3,68 # ffffffffc0202b20 <etext+0x89e>
ffffffffc0201ae4:	00001617          	auipc	a2,0x1
ffffffffc0201ae8:	a2460613          	addi	a2,a2,-1500 # ffffffffc0202508 <etext+0x286>
ffffffffc0201aec:	14300593          	li	a1,323
ffffffffc0201af0:	00001517          	auipc	a0,0x1
ffffffffc0201af4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201af8:	ecafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == 2);
ffffffffc0201afc:	00001697          	auipc	a3,0x1
ffffffffc0201b00:	00c68693          	addi	a3,a3,12 # ffffffffc0202b08 <etext+0x886>
ffffffffc0201b04:	00001617          	auipc	a2,0x1
ffffffffc0201b08:	a0460613          	addi	a2,a2,-1532 # ffffffffc0202508 <etext+0x286>
ffffffffc0201b0c:	13f00593          	li	a1,319
ffffffffc0201b10:	00001517          	auipc	a0,0x1
ffffffffc0201b14:	a1050513          	addi	a0,a0,-1520 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201b18:	eaafe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(p != NULL);
ffffffffc0201b1c:	00001697          	auipc	a3,0x1
ffffffffc0201b20:	fdc68693          	addi	a3,a3,-36 # ffffffffc0202af8 <etext+0x876>
ffffffffc0201b24:	00001617          	auipc	a2,0x1
ffffffffc0201b28:	9e460613          	addi	a2,a2,-1564 # ffffffffc0202508 <etext+0x286>
ffffffffc0201b2c:	13a00593          	li	a1,314
ffffffffc0201b30:	00001517          	auipc	a0,0x1
ffffffffc0201b34:	9f050513          	addi	a0,a0,-1552 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201b38:	e8afe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(whole == test_base);
ffffffffc0201b3c:	00001697          	auipc	a3,0x1
ffffffffc0201b40:	fa468693          	addi	a3,a3,-92 # ffffffffc0202ae0 <etext+0x85e>
ffffffffc0201b44:	00001617          	auipc	a2,0x1
ffffffffc0201b48:	9c460613          	addi	a2,a2,-1596 # ffffffffc0202508 <etext+0x286>
ffffffffc0201b4c:	13100593          	li	a1,305
ffffffffc0201b50:	00001517          	auipc	a0,0x1
ffffffffc0201b54:	9d050513          	addi	a0,a0,-1584 # ffffffffc0202520 <etext+0x29e>
ffffffffc0201b58:	e6afe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201b5c <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0201b5c:	00006797          	auipc	a5,0x6
ffffffffc0201b60:	3647b783          	ld	a5,868(a5) # ffffffffc0207ec0 <pmm_manager>
ffffffffc0201b64:	6f9c                	ld	a5,24(a5)
ffffffffc0201b66:	8782                	jr	a5

ffffffffc0201b68 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0201b68:	00006797          	auipc	a5,0x6
ffffffffc0201b6c:	3587b783          	ld	a5,856(a5) # ffffffffc0207ec0 <pmm_manager>
ffffffffc0201b70:	739c                	ld	a5,32(a5)
ffffffffc0201b72:	8782                	jr	a5

ffffffffc0201b74 <nr_free_pages>:
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc0201b74:	00006797          	auipc	a5,0x6
ffffffffc0201b78:	34c7b783          	ld	a5,844(a5) # ffffffffc0207ec0 <pmm_manager>
ffffffffc0201b7c:	779c                	ld	a5,40(a5)
ffffffffc0201b7e:	8782                	jr	a5

ffffffffc0201b80 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201b80:	00001797          	auipc	a5,0x1
ffffffffc0201b84:	0c078793          	addi	a5,a5,192 # ffffffffc0202c40 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b88:	638c                	ld	a1,0(a5)
            mem_base + mem_size - 1);
}


/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201b8a:	715d                	addi	sp,sp,-80
ffffffffc0201b8c:	e0a2                	sd	s0,64(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b8e:	00001517          	auipc	a0,0x1
ffffffffc0201b92:	0ea50513          	addi	a0,a0,234 # ffffffffc0202c78 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201b96:	00006417          	auipc	s0,0x6
ffffffffc0201b9a:	32a40413          	addi	s0,s0,810 # ffffffffc0207ec0 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b9e:	e486                	sd	ra,72(sp)
ffffffffc0201ba0:	f84a                	sd	s2,48(sp)
ffffffffc0201ba2:	f44e                	sd	s3,40(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201ba4:	e01c                	sd	a5,0(s0)
void pmm_init(void) {
ffffffffc0201ba6:	fc26                	sd	s1,56(sp)
ffffffffc0201ba8:	f052                	sd	s4,32(sp)
ffffffffc0201baa:	ec56                	sd	s5,24(sp)
ffffffffc0201bac:	e85a                	sd	s6,16(sp)
ffffffffc0201bae:	e45e                	sd	s7,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bb0:	d9cfe0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0201bb4:	601c                	ld	a5,0(s0)
ffffffffc0201bb6:	679c                	ld	a5,8(a5)
ffffffffc0201bb8:	9782                	jalr	a5
    uint64_t mem_base = get_memory_base();
ffffffffc0201bba:	a03fe0ef          	jal	ra,ffffffffc02005bc <get_memory_base>
ffffffffc0201bbe:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0201bc0:	a07fe0ef          	jal	ra,ffffffffc02005c6 <get_memory_size>
    if (mem_base == 0 || mem_size == 0 || mem_base != DRAM_BASE) {
ffffffffc0201bc4:	4785                	li	a5,1
ffffffffc0201bc6:	07fe                	slli	a5,a5,0x1f
    uint64_t mem_size = get_memory_size();
ffffffffc0201bc8:	89aa                	mv	s3,a0
    if (mem_base == 0 || mem_size == 0 || mem_base != DRAM_BASE) {
ffffffffc0201bca:	16f91563          	bne	s2,a5,ffffffffc0201d34 <pmm_init+0x1b4>
ffffffffc0201bce:	16050363          	beqz	a0,ffffffffc0201d34 <pmm_init+0x1b4>
    uint64_t mem_end = mem_base + mem_size;
ffffffffc0201bd2:	992a                	add	s2,s2,a0
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201bd4:	57f5                	li	a5,-3
ffffffffc0201bd6:	00006a17          	auipc	s4,0x6
ffffffffc0201bda:	302a0a13          	addi	s4,s4,770 # ffffffffc0207ed8 <va_pa_offset>
    npage = PPN(mem_end);
ffffffffc0201bde:	00c95b13          	srli	s6,s2,0xc
ffffffffc0201be2:	00006a97          	auipc	s5,0x6
ffffffffc0201be6:	2cea8a93          	addi	s5,s5,718 # ffffffffc0207eb0 <npage>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201bea:	07fa                	slli	a5,a5,0x1e
ffffffffc0201bec:	00fa3023          	sd	a5,0(s4)
    npage = PPN(mem_end);
ffffffffc0201bf0:	016ab023          	sd	s6,0(s5)
    if (npage <= nbase) {
ffffffffc0201bf4:	000804b7          	lui	s1,0x80
ffffffffc0201bf8:	1564fc63          	bgeu	s1,s6,ffffffffc0201d50 <pmm_init+0x1d0>
    size_t nr_pages = npage - nbase;
ffffffffc0201bfc:	409b04b3          	sub	s1,s6,s1
    memset(pages, 0, nr_pages * sizeof(struct Page));
ffffffffc0201c00:	00249693          	slli	a3,s1,0x2
ffffffffc0201c04:	96a6                	add	a3,a3,s1
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201c06:	77fd                	lui	a5,0xfffff
    memset(pages, 0, nr_pages * sizeof(struct Page));
ffffffffc0201c08:	00369493          	slli	s1,a3,0x3
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201c0c:	00007517          	auipc	a0,0x7
ffffffffc0201c10:	2d350513          	addi	a0,a0,723 # ffffffffc0208edf <end+0xfff>
ffffffffc0201c14:	8d7d                	and	a0,a0,a5
ffffffffc0201c16:	00006b97          	auipc	s7,0x6
ffffffffc0201c1a:	2a2b8b93          	addi	s7,s7,674 # ffffffffc0207eb8 <pages>
    memset(pages, 0, nr_pages * sizeof(struct Page));
ffffffffc0201c1e:	8626                	mv	a2,s1
ffffffffc0201c20:	4581                	li	a1,0
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201c22:	00abb023          	sd	a0,0(s7)
    memset(pages, 0, nr_pages * sizeof(struct Page));
ffffffffc0201c26:	60e000ef          	jal	ra,ffffffffc0202234 <memset>
        SetPageReserved(&pages[i]);
ffffffffc0201c2a:	000bb603          	ld	a2,0(s7)
ffffffffc0201c2e:	002b1713          	slli	a4,s6,0x2
ffffffffc0201c32:	fec00837          	lui	a6,0xfec00
ffffffffc0201c36:	975a                	add	a4,a4,s6
ffffffffc0201c38:	0821                	addi	a6,a6,8
ffffffffc0201c3a:	9832                	add	a6,a6,a2
ffffffffc0201c3c:	070e                	slli	a4,a4,0x3
ffffffffc0201c3e:	00860793          	addi	a5,a2,8
ffffffffc0201c42:	983a                	add	a6,a6,a4
ffffffffc0201c44:	6394                	ld	a3,0(a5)
    for (size_t i = 0; i < nr_pages; i ++) {
ffffffffc0201c46:	02878793          	addi	a5,a5,40 # fffffffffffff028 <end+0x3fdf7148>
        SetPageReserved(&pages[i]);
ffffffffc0201c4a:	0016e693          	ori	a3,a3,1
ffffffffc0201c4e:	fcd7bc23          	sd	a3,-40(a5)
    for (size_t i = 0; i < nr_pages; i ++) {
ffffffffc0201c52:	ff0799e3          	bne	a5,a6,ffffffffc0201c44 <pmm_init+0xc4>
        PADDR((uintptr_t)pages + nr_pages * sizeof(struct Page));
ffffffffc0201c56:	009606b3          	add	a3,a2,s1
ffffffffc0201c5a:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c5e:	10f6e563          	bltu	a3,a5,ffffffffc0201d68 <pmm_init+0x1e8>
    uintptr_t free_start_pa = ROUNDUP(pages_end_pa, PGSIZE);
ffffffffc0201c62:	000a3703          	ld	a4,0(s4)
ffffffffc0201c66:	6785                	lui	a5,0x1
ffffffffc0201c68:	17fd                	addi	a5,a5,-1
ffffffffc0201c6a:	8f99                	sub	a5,a5,a4
ffffffffc0201c6c:	75fd                	lui	a1,0xfffff
ffffffffc0201c6e:	4745                	li	a4,17
ffffffffc0201c70:	96be                	add	a3,a3,a5
ffffffffc0201c72:	076e                	slli	a4,a4,0x1b
    uintptr_t free_end_pa = ROUNDDOWN((uintptr_t)mem_end, PGSIZE);
ffffffffc0201c74:	00b977b3          	and	a5,s2,a1
ffffffffc0201c78:	8eed                	and	a3,a3,a1
    if (free_end_pa > PHYSICAL_MEMORY_END) {
ffffffffc0201c7a:	08f76563          	bltu	a4,a5,ffffffffc0201d04 <pmm_init+0x184>
    if (free_end_pa > free_start_pa) {
ffffffffc0201c7e:	08f6e663          	bltu	a3,a5,ffffffffc0201d0a <pmm_init+0x18a>
    cprintf("physical memory map:\n");
ffffffffc0201c82:	00001517          	auipc	a0,0x1
ffffffffc0201c86:	0e650513          	addi	a0,a0,230 # ffffffffc0202d68 <buddy_pmm_manager+0x128>
ffffffffc0201c8a:	cc2fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_base,
ffffffffc0201c8e:	800006b7          	lui	a3,0x80000
ffffffffc0201c92:	fff6c693          	not	a3,a3
ffffffffc0201c96:	4605                	li	a2,1
ffffffffc0201c98:	85ce                	mv	a1,s3
ffffffffc0201c9a:	96ce                	add	a3,a3,s3
ffffffffc0201c9c:	067e                	slli	a2,a2,0x1f
ffffffffc0201c9e:	00001517          	auipc	a0,0x1
ffffffffc0201ca2:	0e250513          	addi	a0,a0,226 # ffffffffc0202d80 <buddy_pmm_manager+0x140>
ffffffffc0201ca6:	ca6fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201caa:	601c                	ld	a5,0(s0)
ffffffffc0201cac:	7b9c                	ld	a5,48(a5)
ffffffffc0201cae:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201cb0:	00001517          	auipc	a0,0x1
ffffffffc0201cb4:	10050513          	addi	a0,a0,256 # ffffffffc0202db0 <buddy_pmm_manager+0x170>
ffffffffc0201cb8:	c94fe0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201cbc:	00004597          	auipc	a1,0x4
ffffffffc0201cc0:	34458593          	addi	a1,a1,836 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc0201cc4:	00006797          	auipc	a5,0x6
ffffffffc0201cc8:	20b7b623          	sd	a1,524(a5) # ffffffffc0207ed0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201ccc:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cd0:	0af5e863          	bltu	a1,a5,ffffffffc0201d80 <pmm_init+0x200>
ffffffffc0201cd4:	000a3603          	ld	a2,0(s4)
}
ffffffffc0201cd8:	6406                	ld	s0,64(sp)
ffffffffc0201cda:	60a6                	ld	ra,72(sp)
ffffffffc0201cdc:	74e2                	ld	s1,56(sp)
ffffffffc0201cde:	7942                	ld	s2,48(sp)
ffffffffc0201ce0:	79a2                	ld	s3,40(sp)
ffffffffc0201ce2:	7a02                	ld	s4,32(sp)
ffffffffc0201ce4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ce6:	6b42                	ld	s6,16(sp)
ffffffffc0201ce8:	6ba2                	ld	s7,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201cea:	40c58633          	sub	a2,a1,a2
ffffffffc0201cee:	00006797          	auipc	a5,0x6
ffffffffc0201cf2:	1cc7bd23          	sd	a2,474(a5) # ffffffffc0207ec8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201cf6:	00001517          	auipc	a0,0x1
ffffffffc0201cfa:	0da50513          	addi	a0,a0,218 # ffffffffc0202dd0 <buddy_pmm_manager+0x190>
}
ffffffffc0201cfe:	6161                	addi	sp,sp,80
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201d00:	c4cfe06f          	j	ffffffffc020014c <cprintf>
ffffffffc0201d04:	87ba                	mv	a5,a4
    if (free_end_pa > free_start_pa) {
ffffffffc0201d06:	f6f6fee3          	bgeu	a3,a5,ffffffffc0201c82 <pmm_init+0x102>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201d0a:	000ab703          	ld	a4,0(s5)
ffffffffc0201d0e:	00c6d513          	srli	a0,a3,0xc
ffffffffc0201d12:	08e57463          	bgeu	a0,a4,ffffffffc0201d9a <pmm_init+0x21a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201d16:	600c                	ld	a1,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201d18:	fff80737          	lui	a4,0xfff80
ffffffffc0201d1c:	972a                	add	a4,a4,a0
ffffffffc0201d1e:	00271513          	slli	a0,a4,0x2
ffffffffc0201d22:	953a                	add	a0,a0,a4
ffffffffc0201d24:	6998                	ld	a4,16(a1)
        size_t n = (free_end_pa - free_start_pa) >> PGSHIFT;
ffffffffc0201d26:	8f95                	sub	a5,a5,a3
ffffffffc0201d28:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201d2a:	00c7d593          	srli	a1,a5,0xc
ffffffffc0201d2e:	9532                	add	a0,a0,a2
ffffffffc0201d30:	9702                	jalr	a4
}
ffffffffc0201d32:	bf81                	j	ffffffffc0201c82 <pmm_init+0x102>
        panic("page_init: invalid physical memory info (base = 0x%lx, size = 0x%lx)",
ffffffffc0201d34:	874e                	mv	a4,s3
ffffffffc0201d36:	86ca                	mv	a3,s2
ffffffffc0201d38:	00001617          	auipc	a2,0x1
ffffffffc0201d3c:	f5860613          	addi	a2,a2,-168 # ffffffffc0202c90 <buddy_pmm_manager+0x50>
ffffffffc0201d40:	04b00593          	li	a1,75
ffffffffc0201d44:	00001517          	auipc	a0,0x1
ffffffffc0201d48:	f9450513          	addi	a0,a0,-108 # ffffffffc0202cd8 <buddy_pmm_manager+0x98>
ffffffffc0201d4c:	c76fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("page_init: no manageable physical page");
ffffffffc0201d50:	00001617          	auipc	a2,0x1
ffffffffc0201d54:	f9860613          	addi	a2,a2,-104 # ffffffffc0202ce8 <buddy_pmm_manager+0xa8>
ffffffffc0201d58:	05800593          	li	a1,88
ffffffffc0201d5c:	00001517          	auipc	a0,0x1
ffffffffc0201d60:	f7c50513          	addi	a0,a0,-132 # ffffffffc0202cd8 <buddy_pmm_manager+0x98>
ffffffffc0201d64:	c5efe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        PADDR((uintptr_t)pages + nr_pages * sizeof(struct Page));
ffffffffc0201d68:	00001617          	auipc	a2,0x1
ffffffffc0201d6c:	fa860613          	addi	a2,a2,-88 # ffffffffc0202d10 <buddy_pmm_manager+0xd0>
ffffffffc0201d70:	06a00593          	li	a1,106
ffffffffc0201d74:	00001517          	auipc	a0,0x1
ffffffffc0201d78:	f6450513          	addi	a0,a0,-156 # ffffffffc0202cd8 <buddy_pmm_manager+0x98>
ffffffffc0201d7c:	c46fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201d80:	86ae                	mv	a3,a1
ffffffffc0201d82:	00001617          	auipc	a2,0x1
ffffffffc0201d86:	f8e60613          	addi	a2,a2,-114 # ffffffffc0202d10 <buddy_pmm_manager+0xd0>
ffffffffc0201d8a:	09000593          	li	a1,144
ffffffffc0201d8e:	00001517          	auipc	a0,0x1
ffffffffc0201d92:	f4a50513          	addi	a0,a0,-182 # ffffffffc0202cd8 <buddy_pmm_manager+0x98>
ffffffffc0201d96:	c2cfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201d9a:	00001617          	auipc	a2,0x1
ffffffffc0201d9e:	f9e60613          	addi	a2,a2,-98 # ffffffffc0202d38 <buddy_pmm_manager+0xf8>
ffffffffc0201da2:	06a00593          	li	a1,106
ffffffffc0201da6:	00001517          	auipc	a0,0x1
ffffffffc0201daa:	fb250513          	addi	a0,a0,-78 # ffffffffc0202d58 <buddy_pmm_manager+0x118>
ffffffffc0201dae:	c14fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201db2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201db2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201db6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201db8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201dbc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201dbe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201dc2:	f022                	sd	s0,32(sp)
ffffffffc0201dc4:	ec26                	sd	s1,24(sp)
ffffffffc0201dc6:	e84a                	sd	s2,16(sp)
ffffffffc0201dc8:	f406                	sd	ra,40(sp)
ffffffffc0201dca:	e44e                	sd	s3,8(sp)
ffffffffc0201dcc:	84aa                	mv	s1,a0
ffffffffc0201dce:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201dd0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201dd4:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201dd6:	03067e63          	bgeu	a2,a6,ffffffffc0201e12 <printnum+0x60>
ffffffffc0201dda:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201ddc:	00805763          	blez	s0,ffffffffc0201dea <printnum+0x38>
ffffffffc0201de0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201de2:	85ca                	mv	a1,s2
ffffffffc0201de4:	854e                	mv	a0,s3
ffffffffc0201de6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201de8:	fc65                	bnez	s0,ffffffffc0201de0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201dea:	1a02                	slli	s4,s4,0x20
ffffffffc0201dec:	00001797          	auipc	a5,0x1
ffffffffc0201df0:	02478793          	addi	a5,a5,36 # ffffffffc0202e10 <buddy_pmm_manager+0x1d0>
ffffffffc0201df4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201df8:	9a3e                	add	s4,s4,a5
}
ffffffffc0201dfa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201dfc:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201e00:	70a2                	ld	ra,40(sp)
ffffffffc0201e02:	69a2                	ld	s3,8(sp)
ffffffffc0201e04:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201e06:	85ca                	mv	a1,s2
ffffffffc0201e08:	87a6                	mv	a5,s1
}
ffffffffc0201e0a:	6942                	ld	s2,16(sp)
ffffffffc0201e0c:	64e2                	ld	s1,24(sp)
ffffffffc0201e0e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201e10:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201e12:	03065633          	divu	a2,a2,a6
ffffffffc0201e16:	8722                	mv	a4,s0
ffffffffc0201e18:	f9bff0ef          	jal	ra,ffffffffc0201db2 <printnum>
ffffffffc0201e1c:	b7f9                	j	ffffffffc0201dea <printnum+0x38>

ffffffffc0201e1e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201e1e:	7119                	addi	sp,sp,-128
ffffffffc0201e20:	f4a6                	sd	s1,104(sp)
ffffffffc0201e22:	f0ca                	sd	s2,96(sp)
ffffffffc0201e24:	ecce                	sd	s3,88(sp)
ffffffffc0201e26:	e8d2                	sd	s4,80(sp)
ffffffffc0201e28:	e4d6                	sd	s5,72(sp)
ffffffffc0201e2a:	e0da                	sd	s6,64(sp)
ffffffffc0201e2c:	fc5e                	sd	s7,56(sp)
ffffffffc0201e2e:	f06a                	sd	s10,32(sp)
ffffffffc0201e30:	fc86                	sd	ra,120(sp)
ffffffffc0201e32:	f8a2                	sd	s0,112(sp)
ffffffffc0201e34:	f862                	sd	s8,48(sp)
ffffffffc0201e36:	f466                	sd	s9,40(sp)
ffffffffc0201e38:	ec6e                	sd	s11,24(sp)
ffffffffc0201e3a:	892a                	mv	s2,a0
ffffffffc0201e3c:	84ae                	mv	s1,a1
ffffffffc0201e3e:	8d32                	mv	s10,a2
ffffffffc0201e40:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201e42:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201e46:	5b7d                	li	s6,-1
ffffffffc0201e48:	00001a97          	auipc	s5,0x1
ffffffffc0201e4c:	ffca8a93          	addi	s5,s5,-4 # ffffffffc0202e44 <buddy_pmm_manager+0x204>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201e50:	00001b97          	auipc	s7,0x1
ffffffffc0201e54:	1d0b8b93          	addi	s7,s7,464 # ffffffffc0203020 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201e58:	000d4503          	lbu	a0,0(s10)
ffffffffc0201e5c:	001d0413          	addi	s0,s10,1
ffffffffc0201e60:	01350a63          	beq	a0,s3,ffffffffc0201e74 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201e64:	c121                	beqz	a0,ffffffffc0201ea4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201e66:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201e68:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201e6a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201e6c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201e70:	ff351ae3          	bne	a0,s3,ffffffffc0201e64 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201e74:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201e78:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201e7c:	4c81                	li	s9,0
ffffffffc0201e7e:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201e80:	5c7d                	li	s8,-1
ffffffffc0201e82:	5dfd                	li	s11,-1
ffffffffc0201e84:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201e88:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201e8a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201e8e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201e92:	00140d13          	addi	s10,s0,1
ffffffffc0201e96:	04b56263          	bltu	a0,a1,ffffffffc0201eda <vprintfmt+0xbc>
ffffffffc0201e9a:	058a                	slli	a1,a1,0x2
ffffffffc0201e9c:	95d6                	add	a1,a1,s5
ffffffffc0201e9e:	4194                	lw	a3,0(a1)
ffffffffc0201ea0:	96d6                	add	a3,a3,s5
ffffffffc0201ea2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201ea4:	70e6                	ld	ra,120(sp)
ffffffffc0201ea6:	7446                	ld	s0,112(sp)
ffffffffc0201ea8:	74a6                	ld	s1,104(sp)
ffffffffc0201eaa:	7906                	ld	s2,96(sp)
ffffffffc0201eac:	69e6                	ld	s3,88(sp)
ffffffffc0201eae:	6a46                	ld	s4,80(sp)
ffffffffc0201eb0:	6aa6                	ld	s5,72(sp)
ffffffffc0201eb2:	6b06                	ld	s6,64(sp)
ffffffffc0201eb4:	7be2                	ld	s7,56(sp)
ffffffffc0201eb6:	7c42                	ld	s8,48(sp)
ffffffffc0201eb8:	7ca2                	ld	s9,40(sp)
ffffffffc0201eba:	7d02                	ld	s10,32(sp)
ffffffffc0201ebc:	6de2                	ld	s11,24(sp)
ffffffffc0201ebe:	6109                	addi	sp,sp,128
ffffffffc0201ec0:	8082                	ret
            padc = '0';
ffffffffc0201ec2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201ec4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ec8:	846a                	mv	s0,s10
ffffffffc0201eca:	00140d13          	addi	s10,s0,1
ffffffffc0201ece:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201ed2:	0ff5f593          	zext.b	a1,a1
ffffffffc0201ed6:	fcb572e3          	bgeu	a0,a1,ffffffffc0201e9a <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201eda:	85a6                	mv	a1,s1
ffffffffc0201edc:	02500513          	li	a0,37
ffffffffc0201ee0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201ee2:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201ee6:	8d22                	mv	s10,s0
ffffffffc0201ee8:	f73788e3          	beq	a5,s3,ffffffffc0201e58 <vprintfmt+0x3a>
ffffffffc0201eec:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201ef0:	1d7d                	addi	s10,s10,-1
ffffffffc0201ef2:	ff379de3          	bne	a5,s3,ffffffffc0201eec <vprintfmt+0xce>
ffffffffc0201ef6:	b78d                	j	ffffffffc0201e58 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201ef8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201efc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201f00:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201f02:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201f06:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201f0a:	02d86463          	bltu	a6,a3,ffffffffc0201f32 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201f0e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201f12:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201f16:	0186873b          	addw	a4,a3,s8
ffffffffc0201f1a:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201f1e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201f20:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201f24:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201f26:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201f2a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201f2e:	fed870e3          	bgeu	a6,a3,ffffffffc0201f0e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201f32:	f40ddce3          	bgez	s11,ffffffffc0201e8a <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201f36:	8de2                	mv	s11,s8
ffffffffc0201f38:	5c7d                	li	s8,-1
ffffffffc0201f3a:	bf81                	j	ffffffffc0201e8a <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201f3c:	fffdc693          	not	a3,s11
ffffffffc0201f40:	96fd                	srai	a3,a3,0x3f
ffffffffc0201f42:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201f46:	00144603          	lbu	a2,1(s0)
ffffffffc0201f4a:	2d81                	sext.w	s11,s11
ffffffffc0201f4c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201f4e:	bf35                	j	ffffffffc0201e8a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201f50:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201f54:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201f58:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201f5a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201f5c:	bfd9                	j	ffffffffc0201f32 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201f5e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201f60:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201f64:	01174463          	blt	a4,a7,ffffffffc0201f6c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201f68:	1a088e63          	beqz	a7,ffffffffc0202124 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201f6c:	000a3603          	ld	a2,0(s4)
ffffffffc0201f70:	46c1                	li	a3,16
ffffffffc0201f72:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201f74:	2781                	sext.w	a5,a5
ffffffffc0201f76:	876e                	mv	a4,s11
ffffffffc0201f78:	85a6                	mv	a1,s1
ffffffffc0201f7a:	854a                	mv	a0,s2
ffffffffc0201f7c:	e37ff0ef          	jal	ra,ffffffffc0201db2 <printnum>
            break;
ffffffffc0201f80:	bde1                	j	ffffffffc0201e58 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201f82:	000a2503          	lw	a0,0(s4)
ffffffffc0201f86:	85a6                	mv	a1,s1
ffffffffc0201f88:	0a21                	addi	s4,s4,8
ffffffffc0201f8a:	9902                	jalr	s2
            break;
ffffffffc0201f8c:	b5f1                	j	ffffffffc0201e58 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201f8e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201f90:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201f94:	01174463          	blt	a4,a7,ffffffffc0201f9c <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201f98:	18088163          	beqz	a7,ffffffffc020211a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201f9c:	000a3603          	ld	a2,0(s4)
ffffffffc0201fa0:	46a9                	li	a3,10
ffffffffc0201fa2:	8a2e                	mv	s4,a1
ffffffffc0201fa4:	bfc1                	j	ffffffffc0201f74 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201fa6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201faa:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201fac:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201fae:	bdf1                	j	ffffffffc0201e8a <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201fb0:	85a6                	mv	a1,s1
ffffffffc0201fb2:	02500513          	li	a0,37
ffffffffc0201fb6:	9902                	jalr	s2
            break;
ffffffffc0201fb8:	b545                	j	ffffffffc0201e58 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201fba:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201fbe:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201fc0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201fc2:	b5e1                	j	ffffffffc0201e8a <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201fc4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201fc6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201fca:	01174463          	blt	a4,a7,ffffffffc0201fd2 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201fce:	14088163          	beqz	a7,ffffffffc0202110 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201fd2:	000a3603          	ld	a2,0(s4)
ffffffffc0201fd6:	46a1                	li	a3,8
ffffffffc0201fd8:	8a2e                	mv	s4,a1
ffffffffc0201fda:	bf69                	j	ffffffffc0201f74 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201fdc:	03000513          	li	a0,48
ffffffffc0201fe0:	85a6                	mv	a1,s1
ffffffffc0201fe2:	e03e                	sd	a5,0(sp)
ffffffffc0201fe4:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201fe6:	85a6                	mv	a1,s1
ffffffffc0201fe8:	07800513          	li	a0,120
ffffffffc0201fec:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201fee:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201ff0:	6782                	ld	a5,0(sp)
ffffffffc0201ff2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ff4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201ff8:	bfb5                	j	ffffffffc0201f74 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201ffa:	000a3403          	ld	s0,0(s4)
ffffffffc0201ffe:	008a0713          	addi	a4,s4,8
ffffffffc0202002:	e03a                	sd	a4,0(sp)
ffffffffc0202004:	14040263          	beqz	s0,ffffffffc0202148 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0202008:	0fb05763          	blez	s11,ffffffffc02020f6 <vprintfmt+0x2d8>
ffffffffc020200c:	02d00693          	li	a3,45
ffffffffc0202010:	0cd79163          	bne	a5,a3,ffffffffc02020d2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0202014:	00044783          	lbu	a5,0(s0)
ffffffffc0202018:	0007851b          	sext.w	a0,a5
ffffffffc020201c:	cf85                	beqz	a5,ffffffffc0202054 <vprintfmt+0x236>
ffffffffc020201e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0202022:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0202026:	000c4563          	bltz	s8,ffffffffc0202030 <vprintfmt+0x212>
ffffffffc020202a:	3c7d                	addiw	s8,s8,-1
ffffffffc020202c:	036c0263          	beq	s8,s6,ffffffffc0202050 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0202030:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0202032:	0e0c8e63          	beqz	s9,ffffffffc020212e <vprintfmt+0x310>
ffffffffc0202036:	3781                	addiw	a5,a5,-32
ffffffffc0202038:	0ef47b63          	bgeu	s0,a5,ffffffffc020212e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020203c:	03f00513          	li	a0,63
ffffffffc0202040:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0202042:	000a4783          	lbu	a5,0(s4)
ffffffffc0202046:	3dfd                	addiw	s11,s11,-1
ffffffffc0202048:	0a05                	addi	s4,s4,1
ffffffffc020204a:	0007851b          	sext.w	a0,a5
ffffffffc020204e:	ffe1                	bnez	a5,ffffffffc0202026 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0202050:	01b05963          	blez	s11,ffffffffc0202062 <vprintfmt+0x244>
ffffffffc0202054:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0202056:	85a6                	mv	a1,s1
ffffffffc0202058:	02000513          	li	a0,32
ffffffffc020205c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020205e:	fe0d9be3          	bnez	s11,ffffffffc0202054 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0202062:	6a02                	ld	s4,0(sp)
ffffffffc0202064:	bbd5                	j	ffffffffc0201e58 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0202066:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0202068:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020206c:	01174463          	blt	a4,a7,ffffffffc0202074 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0202070:	08088d63          	beqz	a7,ffffffffc020210a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0202074:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0202078:	0a044d63          	bltz	s0,ffffffffc0202132 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020207c:	8622                	mv	a2,s0
ffffffffc020207e:	8a66                	mv	s4,s9
ffffffffc0202080:	46a9                	li	a3,10
ffffffffc0202082:	bdcd                	j	ffffffffc0201f74 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0202084:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0202088:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020208a:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020208c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0202090:	8fb5                	xor	a5,a5,a3
ffffffffc0202092:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0202096:	02d74163          	blt	a4,a3,ffffffffc02020b8 <vprintfmt+0x29a>
ffffffffc020209a:	00369793          	slli	a5,a3,0x3
ffffffffc020209e:	97de                	add	a5,a5,s7
ffffffffc02020a0:	639c                	ld	a5,0(a5)
ffffffffc02020a2:	cb99                	beqz	a5,ffffffffc02020b8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02020a4:	86be                	mv	a3,a5
ffffffffc02020a6:	00001617          	auipc	a2,0x1
ffffffffc02020aa:	d9a60613          	addi	a2,a2,-614 # ffffffffc0202e40 <buddy_pmm_manager+0x200>
ffffffffc02020ae:	85a6                	mv	a1,s1
ffffffffc02020b0:	854a                	mv	a0,s2
ffffffffc02020b2:	0ce000ef          	jal	ra,ffffffffc0202180 <printfmt>
ffffffffc02020b6:	b34d                	j	ffffffffc0201e58 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02020b8:	00001617          	auipc	a2,0x1
ffffffffc02020bc:	d7860613          	addi	a2,a2,-648 # ffffffffc0202e30 <buddy_pmm_manager+0x1f0>
ffffffffc02020c0:	85a6                	mv	a1,s1
ffffffffc02020c2:	854a                	mv	a0,s2
ffffffffc02020c4:	0bc000ef          	jal	ra,ffffffffc0202180 <printfmt>
ffffffffc02020c8:	bb41                	j	ffffffffc0201e58 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02020ca:	00001417          	auipc	s0,0x1
ffffffffc02020ce:	d5e40413          	addi	s0,s0,-674 # ffffffffc0202e28 <buddy_pmm_manager+0x1e8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02020d2:	85e2                	mv	a1,s8
ffffffffc02020d4:	8522                	mv	a0,s0
ffffffffc02020d6:	e43e                	sd	a5,8(sp)
ffffffffc02020d8:	0fc000ef          	jal	ra,ffffffffc02021d4 <strnlen>
ffffffffc02020dc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02020e0:	01b05b63          	blez	s11,ffffffffc02020f6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02020e4:	67a2                	ld	a5,8(sp)
ffffffffc02020e6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02020ea:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02020ec:	85a6                	mv	a1,s1
ffffffffc02020ee:	8552                	mv	a0,s4
ffffffffc02020f0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02020f2:	fe0d9ce3          	bnez	s11,ffffffffc02020ea <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02020f6:	00044783          	lbu	a5,0(s0)
ffffffffc02020fa:	00140a13          	addi	s4,s0,1
ffffffffc02020fe:	0007851b          	sext.w	a0,a5
ffffffffc0202102:	d3a5                	beqz	a5,ffffffffc0202062 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0202104:	05e00413          	li	s0,94
ffffffffc0202108:	bf39                	j	ffffffffc0202026 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020210a:	000a2403          	lw	s0,0(s4)
ffffffffc020210e:	b7ad                	j	ffffffffc0202078 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0202110:	000a6603          	lwu	a2,0(s4)
ffffffffc0202114:	46a1                	li	a3,8
ffffffffc0202116:	8a2e                	mv	s4,a1
ffffffffc0202118:	bdb1                	j	ffffffffc0201f74 <vprintfmt+0x156>
ffffffffc020211a:	000a6603          	lwu	a2,0(s4)
ffffffffc020211e:	46a9                	li	a3,10
ffffffffc0202120:	8a2e                	mv	s4,a1
ffffffffc0202122:	bd89                	j	ffffffffc0201f74 <vprintfmt+0x156>
ffffffffc0202124:	000a6603          	lwu	a2,0(s4)
ffffffffc0202128:	46c1                	li	a3,16
ffffffffc020212a:	8a2e                	mv	s4,a1
ffffffffc020212c:	b5a1                	j	ffffffffc0201f74 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020212e:	9902                	jalr	s2
ffffffffc0202130:	bf09                	j	ffffffffc0202042 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0202132:	85a6                	mv	a1,s1
ffffffffc0202134:	02d00513          	li	a0,45
ffffffffc0202138:	e03e                	sd	a5,0(sp)
ffffffffc020213a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020213c:	6782                	ld	a5,0(sp)
ffffffffc020213e:	8a66                	mv	s4,s9
ffffffffc0202140:	40800633          	neg	a2,s0
ffffffffc0202144:	46a9                	li	a3,10
ffffffffc0202146:	b53d                	j	ffffffffc0201f74 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0202148:	03b05163          	blez	s11,ffffffffc020216a <vprintfmt+0x34c>
ffffffffc020214c:	02d00693          	li	a3,45
ffffffffc0202150:	f6d79de3          	bne	a5,a3,ffffffffc02020ca <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0202154:	00001417          	auipc	s0,0x1
ffffffffc0202158:	cd440413          	addi	s0,s0,-812 # ffffffffc0202e28 <buddy_pmm_manager+0x1e8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020215c:	02800793          	li	a5,40
ffffffffc0202160:	02800513          	li	a0,40
ffffffffc0202164:	00140a13          	addi	s4,s0,1
ffffffffc0202168:	bd6d                	j	ffffffffc0202022 <vprintfmt+0x204>
ffffffffc020216a:	00001a17          	auipc	s4,0x1
ffffffffc020216e:	cbfa0a13          	addi	s4,s4,-833 # ffffffffc0202e29 <buddy_pmm_manager+0x1e9>
ffffffffc0202172:	02800513          	li	a0,40
ffffffffc0202176:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020217a:	05e00413          	li	s0,94
ffffffffc020217e:	b565                	j	ffffffffc0202026 <vprintfmt+0x208>

ffffffffc0202180 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0202180:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0202182:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0202186:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0202188:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020218a:	ec06                	sd	ra,24(sp)
ffffffffc020218c:	f83a                	sd	a4,48(sp)
ffffffffc020218e:	fc3e                	sd	a5,56(sp)
ffffffffc0202190:	e0c2                	sd	a6,64(sp)
ffffffffc0202192:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0202194:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0202196:	c89ff0ef          	jal	ra,ffffffffc0201e1e <vprintfmt>
}
ffffffffc020219a:	60e2                	ld	ra,24(sp)
ffffffffc020219c:	6161                	addi	sp,sp,80
ffffffffc020219e:	8082                	ret

ffffffffc02021a0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02021a0:	4781                	li	a5,0
ffffffffc02021a2:	00005717          	auipc	a4,0x5
ffffffffc02021a6:	e6e73703          	ld	a4,-402(a4) # ffffffffc0207010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02021aa:	88ba                	mv	a7,a4
ffffffffc02021ac:	852a                	mv	a0,a0
ffffffffc02021ae:	85be                	mv	a1,a5
ffffffffc02021b0:	863e                	mv	a2,a5
ffffffffc02021b2:	00000073          	ecall
ffffffffc02021b6:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02021b8:	8082                	ret

ffffffffc02021ba <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02021ba:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02021be:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02021c0:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02021c2:	cb81                	beqz	a5,ffffffffc02021d2 <strlen+0x18>
        cnt ++;
ffffffffc02021c4:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02021c6:	00a707b3          	add	a5,a4,a0
ffffffffc02021ca:	0007c783          	lbu	a5,0(a5)
ffffffffc02021ce:	fbfd                	bnez	a5,ffffffffc02021c4 <strlen+0xa>
ffffffffc02021d0:	8082                	ret
    }
    return cnt;
}
ffffffffc02021d2:	8082                	ret

ffffffffc02021d4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02021d4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02021d6:	e589                	bnez	a1,ffffffffc02021e0 <strnlen+0xc>
ffffffffc02021d8:	a811                	j	ffffffffc02021ec <strnlen+0x18>
        cnt ++;
ffffffffc02021da:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02021dc:	00f58863          	beq	a1,a5,ffffffffc02021ec <strnlen+0x18>
ffffffffc02021e0:	00f50733          	add	a4,a0,a5
ffffffffc02021e4:	00074703          	lbu	a4,0(a4)
ffffffffc02021e8:	fb6d                	bnez	a4,ffffffffc02021da <strnlen+0x6>
ffffffffc02021ea:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02021ec:	852e                	mv	a0,a1
ffffffffc02021ee:	8082                	ret

ffffffffc02021f0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02021f0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02021f4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02021f8:	cb89                	beqz	a5,ffffffffc020220a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02021fa:	0505                	addi	a0,a0,1
ffffffffc02021fc:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02021fe:	fee789e3          	beq	a5,a4,ffffffffc02021f0 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0202202:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0202206:	9d19                	subw	a0,a0,a4
ffffffffc0202208:	8082                	ret
ffffffffc020220a:	4501                	li	a0,0
ffffffffc020220c:	bfed                	j	ffffffffc0202206 <strcmp+0x16>

ffffffffc020220e <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020220e:	c20d                	beqz	a2,ffffffffc0202230 <strncmp+0x22>
ffffffffc0202210:	962e                	add	a2,a2,a1
ffffffffc0202212:	a031                	j	ffffffffc020221e <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0202214:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0202216:	00e79a63          	bne	a5,a4,ffffffffc020222a <strncmp+0x1c>
ffffffffc020221a:	00b60b63          	beq	a2,a1,ffffffffc0202230 <strncmp+0x22>
ffffffffc020221e:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0202222:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0202224:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0202228:	f7f5                	bnez	a5,ffffffffc0202214 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020222a:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020222e:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0202230:	4501                	li	a0,0
ffffffffc0202232:	8082                	ret

ffffffffc0202234 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0202234:	ca01                	beqz	a2,ffffffffc0202244 <memset+0x10>
ffffffffc0202236:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0202238:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020223a:	0785                	addi	a5,a5,1
ffffffffc020223c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0202240:	fec79de3          	bne	a5,a2,ffffffffc020223a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0202244:	8082                	ret

ffffffffc0202246 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0202246:	ca19                	beqz	a2,ffffffffc020225c <memcpy+0x16>
ffffffffc0202248:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020224a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020224c:	0005c703          	lbu	a4,0(a1)
ffffffffc0202250:	0585                	addi	a1,a1,1
ffffffffc0202252:	0785                	addi	a5,a5,1
ffffffffc0202254:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0202258:	fec59ae3          	bne	a1,a2,ffffffffc020224c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020225c:	8082                	ret

ffffffffc020225e <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc020225e:	c205                	beqz	a2,ffffffffc020227e <memcmp+0x20>
ffffffffc0202260:	962e                	add	a2,a2,a1
ffffffffc0202262:	a019                	j	ffffffffc0202268 <memcmp+0xa>
ffffffffc0202264:	00c58d63          	beq	a1,a2,ffffffffc020227e <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0202268:	00054783          	lbu	a5,0(a0)
ffffffffc020226c:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0202270:	0505                	addi	a0,a0,1
ffffffffc0202272:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0202274:	fee788e3          	beq	a5,a4,ffffffffc0202264 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0202278:	40e7853b          	subw	a0,a5,a4
ffffffffc020227c:	8082                	ret
    }
    return 0;
ffffffffc020227e:	4501                	li	a0,0
}
ffffffffc0202280:	8082                	ret
