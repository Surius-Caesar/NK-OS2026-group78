
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00008297          	auipc	t0,0x8
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0208000 <boot_hartid>
ffffffffc020000c:	00008297          	auipc	t0,0x8
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0208008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02072b7          	lui	t0,0xc0207
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0207137          	lui	sp,0xc0207
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
ffffffffc020004a:	1141                	addi	sp,sp,-16 # ffffffffc0206ff0 <bootstack+0x1ff0>
ffffffffc020004c:	00003517          	auipc	a0,0x3
ffffffffc0200050:	e1c50513          	addi	a0,a0,-484 # ffffffffc0202e68 <etext>
ffffffffc0200054:	e406                	sd	ra,8(sp)
ffffffffc0200056:	0f6000ef          	jal	ffffffffc020014c <cprintf>
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00003517          	auipc	a0,0x3
ffffffffc0200066:	e2650513          	addi	a0,a0,-474 # ffffffffc0202e88 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ffffffffc020014c <cprintf>
ffffffffc020006e:	00003597          	auipc	a1,0x3
ffffffffc0200072:	dfa58593          	addi	a1,a1,-518 # ffffffffc0202e68 <etext>
ffffffffc0200076:	00003517          	auipc	a0,0x3
ffffffffc020007a:	e3250513          	addi	a0,a0,-462 # ffffffffc0202ea8 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200082:	00008597          	auipc	a1,0x8
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0208018 <allowed>
ffffffffc020008a:	00003517          	auipc	a0,0x3
ffffffffc020008e:	e3e50513          	addi	a0,a0,-450 # ffffffffc0202ec8 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200096:	00009597          	auipc	a1,0x9
ffffffffc020009a:	e9658593          	addi	a1,a1,-362 # ffffffffc0208f2c <end>
ffffffffc020009e:	00003517          	auipc	a0,0x3
ffffffffc02000a2:	e4a50513          	addi	a0,a0,-438 # ffffffffc0202ee8 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ffffffffc020014c <cprintf>
ffffffffc02000aa:	00009597          	auipc	a1,0x9
ffffffffc02000ae:	28158593          	addi	a1,a1,641 # ffffffffc020932b <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00003517          	auipc	a0,0x3
ffffffffc02000d0:	e3c50513          	addi	a0,a0,-452 # ffffffffc0202f08 <etext+0xa0>
ffffffffc02000d4:	0141                	addi	sp,sp,16
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:
ffffffffc02000d8:	00008517          	auipc	a0,0x8
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0208018 <allowed>
ffffffffc02000e0:	00009617          	auipc	a2,0x9
ffffffffc02000e4:	e4c60613          	addi	a2,a2,-436 # ffffffffc0208f2c <end>
ffffffffc02000e8:	1141                	addi	sp,sp,-16
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	52b020ef          	jal	ffffffffc0202e1a <memset>
ffffffffc02000f4:	12c000ef          	jal	ffffffffc0200220 <dtb_init>
ffffffffc02000f8:	11e000ef          	jal	ffffffffc0200216 <cons_init>
ffffffffc02000fc:	00004517          	auipc	a0,0x4
ffffffffc0200100:	ccc50513          	addi	a0,a0,-820 # ffffffffc0203dc8 <etext+0xf60>
ffffffffc0200104:	07e000ef          	jal	ffffffffc0200182 <cputs>
ffffffffc0200108:	f43ff0ef          	jal	ffffffffc020004a <print_kerninfo>
ffffffffc020010c:	275010ef          	jal	ffffffffc0201b80 <pmm_init>
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
ffffffffc020011a:	0fe000ef          	jal	ffffffffc0200218 <cons_putc>
ffffffffc020011e:	401c                	lw	a5,0(s0)
ffffffffc0200120:	60a2                	ld	ra,8(sp)
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
ffffffffc020013c:	ec06                	sd	ra,24(sp)
ffffffffc020013e:	c602                	sw	zero,12(sp)
ffffffffc0200140:	0c5020ef          	jal	ffffffffc0202a04 <vprintfmt>
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
ffffffffc020014c:	711d                	addi	sp,sp,-96
ffffffffc020014e:	02810313          	addi	t1,sp,40
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
ffffffffc0200172:	e41a                	sd	t1,8(sp)
ffffffffc0200174:	c202                	sw	zero,4(sp)
ffffffffc0200176:	08f020ef          	jal	ffffffffc0202a04 <vprintfmt>
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
ffffffffc0200198:	080000ef          	jal	ffffffffc0200218 <cons_putc>
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	06a000ef          	jal	ffffffffc0200218 <cons_putc>
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
ffffffffc02001c2:	00009317          	auipc	t1,0x9
ffffffffc02001c6:	d1630313          	addi	t1,t1,-746 # ffffffffc0208ed8 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00003517          	auipc	a0,0x3
ffffffffc02001f6:	d4650513          	addi	a0,a0,-698 # ffffffffc0202f38 <etext+0xd0>
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
ffffffffc02001fc:	f51ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ffffffffc020012c <vcprintf>
ffffffffc0200208:	00003517          	auipc	a0,0x3
ffffffffc020020c:	d5050513          	addi	a0,a0,-688 # ffffffffc0202f58 <etext+0xf0>
ffffffffc0200210:	f3dff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <cons_init>:
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <cons_putc>:
ffffffffc0200218:	0ff57513          	zext.b	a0,a0
ffffffffc020021c:	36b0206f          	j	ffffffffc0202d86 <sbi_console_putchar>

ffffffffc0200220 <dtb_init>:
ffffffffc0200220:	7119                	addi	sp,sp,-128
ffffffffc0200222:	00003517          	auipc	a0,0x3
ffffffffc0200226:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202f60 <etext+0xf8>
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
ffffffffc0200244:	f09ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200248:	00008597          	auipc	a1,0x8
ffffffffc020024c:	db85b583          	ld	a1,-584(a1) # ffffffffc0208000 <boot_hartid>
ffffffffc0200250:	00003517          	auipc	a0,0x3
ffffffffc0200254:	d2050513          	addi	a0,a0,-736 # ffffffffc0202f70 <etext+0x108>
ffffffffc0200258:	ef5ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc020025c:	00008417          	auipc	s0,0x8
ffffffffc0200260:	dac40413          	addi	s0,s0,-596 # ffffffffc0208008 <boot_dtb>
ffffffffc0200264:	600c                	ld	a1,0(s0)
ffffffffc0200266:	00003517          	auipc	a0,0x3
ffffffffc020026a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0202f80 <etext+0x118>
ffffffffc020026e:	edfff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200272:	00043a03          	ld	s4,0(s0)
ffffffffc0200276:	00003517          	auipc	a0,0x3
ffffffffc020027a:	d2250513          	addi	a0,a0,-734 # ffffffffc0202f98 <etext+0x130>
ffffffffc020027e:	120a0463          	beqz	s4,ffffffffc02003a6 <dtb_init+0x186>
ffffffffc0200282:	57f5                	li	a5,-3
ffffffffc0200284:	07fa                	slli	a5,a5,0x1e
ffffffffc0200286:	00fa0733          	add	a4,s4,a5
ffffffffc020028a:	431c                	lw	a5,0(a4)
ffffffffc020028c:	00ff0637          	lui	a2,0xff0
ffffffffc0200290:	6b41                	lui	s6,0x10
ffffffffc0200292:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200296:	0187969b          	slliw	a3,a5,0x18
ffffffffc020029a:	0187d51b          	srliw	a0,a5,0x18
ffffffffc020029e:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002a2:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002a6:	8df1                	and	a1,a1,a2
ffffffffc02002a8:	8ec9                	or	a3,a3,a0
ffffffffc02002aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002ae:	1b7d                	addi	s6,s6,-1 # ffff <kern_entry-0xffffffffc01f0001>
ffffffffc02002b0:	0167f7b3          	and	a5,a5,s6
ffffffffc02002b4:	8dd5                	or	a1,a1,a3
ffffffffc02002b6:	8ddd                	or	a1,a1,a5
ffffffffc02002b8:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02002bc:	2581                	sext.w	a1,a1
ffffffffc02002be:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed6fc1>
ffffffffc02002c2:	10f59163          	bne	a1,a5,ffffffffc02003c4 <dtb_init+0x1a4>
ffffffffc02002c6:	471c                	lw	a5,8(a4)
ffffffffc02002c8:	4754                	lw	a3,12(a4)
ffffffffc02002ca:	4c81                	li	s9,0
ffffffffc02002cc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002d0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002d4:	0186941b          	slliw	s0,a3,0x18
ffffffffc02002d8:	0186d89b          	srliw	a7,a3,0x18
ffffffffc02002dc:	01879a1b          	slliw	s4,a5,0x18
ffffffffc02002e0:	0187d81b          	srliw	a6,a5,0x18
ffffffffc02002e4:	0105151b          	slliw	a0,a0,0x10
ffffffffc02002e8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002ec:	0105959b          	slliw	a1,a1,0x10
ffffffffc02002f0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02002f4:	8d71                	and	a0,a0,a2
ffffffffc02002f6:	01146433          	or	s0,s0,a7
ffffffffc02002fa:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002fe:	010a6a33          	or	s4,s4,a6
ffffffffc0200302:	8e6d                	and	a2,a2,a1
ffffffffc0200304:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200308:	8c49                	or	s0,s0,a0
ffffffffc020030a:	0166f6b3          	and	a3,a3,s6
ffffffffc020030e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200312:	0167f7b3          	and	a5,a5,s6
ffffffffc0200316:	8c55                	or	s0,s0,a3
ffffffffc0200318:	00fa6a33          	or	s4,s4,a5
ffffffffc020031c:	1402                	slli	s0,s0,0x20
ffffffffc020031e:	1a02                	slli	s4,s4,0x20
ffffffffc0200320:	9001                	srli	s0,s0,0x20
ffffffffc0200322:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200326:	943a                	add	s0,s0,a4
ffffffffc0200328:	9a3a                	add	s4,s4,a4
ffffffffc020032a:	00ff0c37          	lui	s8,0xff0
ffffffffc020032e:	4b8d                	li	s7,3
ffffffffc0200330:	00003917          	auipc	s2,0x3
ffffffffc0200334:	cb890913          	addi	s2,s2,-840 # ffffffffc0202fe8 <etext+0x180>
ffffffffc0200338:	49bd                	li	s3,15
ffffffffc020033a:	4d91                	li	s11,4
ffffffffc020033c:	4d05                	li	s10,1
ffffffffc020033e:	00003497          	auipc	s1,0x3
ffffffffc0200342:	ca248493          	addi	s1,s1,-862 # ffffffffc0202fe0 <etext+0x178>
ffffffffc0200346:	000a2703          	lw	a4,0(s4)
ffffffffc020034a:	004a0a93          	addi	s5,s4,4
ffffffffc020034e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200352:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200356:	0187561b          	srliw	a2,a4,0x18
ffffffffc020035a:	0106969b          	slliw	a3,a3,0x10
ffffffffc020035e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200362:	8fd1                	or	a5,a5,a2
ffffffffc0200364:	0186f6b3          	and	a3,a3,s8
ffffffffc0200368:	0087171b          	slliw	a4,a4,0x8
ffffffffc020036c:	8fd5                	or	a5,a5,a3
ffffffffc020036e:	00eb7733          	and	a4,s6,a4
ffffffffc0200372:	8fd9                	or	a5,a5,a4
ffffffffc0200374:	2781                	sext.w	a5,a5
ffffffffc0200376:	09778c63          	beq	a5,s7,ffffffffc020040e <dtb_init+0x1ee>
ffffffffc020037a:	00fbea63          	bltu	s7,a5,ffffffffc020038e <dtb_init+0x16e>
ffffffffc020037e:	07a78663          	beq	a5,s10,ffffffffc02003ea <dtb_init+0x1ca>
ffffffffc0200382:	4709                	li	a4,2
ffffffffc0200384:	00e79763          	bne	a5,a4,ffffffffc0200392 <dtb_init+0x172>
ffffffffc0200388:	4c81                	li	s9,0
ffffffffc020038a:	8a56                	mv	s4,s5
ffffffffc020038c:	bf6d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020038e:	ffb78ee3          	beq	a5,s11,ffffffffc020038a <dtb_init+0x16a>
ffffffffc0200392:	00003517          	auipc	a0,0x3
ffffffffc0200396:	cce50513          	addi	a0,a0,-818 # ffffffffc0203060 <etext+0x1f8>
ffffffffc020039a:	db3ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc020039e:	00003517          	auipc	a0,0x3
ffffffffc02003a2:	cfa50513          	addi	a0,a0,-774 # ffffffffc0203098 <etext+0x230>
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
ffffffffc02003c2:	b369                	j	ffffffffc020014c <cprintf>
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
ffffffffc02003de:	00003517          	auipc	a0,0x3
ffffffffc02003e2:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202fb8 <etext+0x150>
ffffffffc02003e6:	6109                	addi	sp,sp,128
ffffffffc02003e8:	b395                	j	ffffffffc020014c <cprintf>
ffffffffc02003ea:	8556                	mv	a0,s5
ffffffffc02003ec:	1b5020ef          	jal	ffffffffc0202da0 <strlen>
ffffffffc02003f0:	8a2a                	mv	s4,a0
ffffffffc02003f2:	4619                	li	a2,6
ffffffffc02003f4:	85a6                	mv	a1,s1
ffffffffc02003f6:	8556                	mv	a0,s5
ffffffffc02003f8:	2a01                	sext.w	s4,s4
ffffffffc02003fa:	1fb020ef          	jal	ffffffffc0202df4 <strncmp>
ffffffffc02003fe:	e111                	bnez	a0,ffffffffc0200402 <dtb_init+0x1e2>
ffffffffc0200400:	4c85                	li	s9,1
ffffffffc0200402:	0a91                	addi	s5,s5,4
ffffffffc0200404:	9ad2                	add	s5,s5,s4
ffffffffc0200406:	ffcafa93          	andi	s5,s5,-4
ffffffffc020040a:	8a56                	mv	s4,s5
ffffffffc020040c:	bf2d                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020040e:	004a2783          	lw	a5,4(s4)
ffffffffc0200412:	00ca0693          	addi	a3,s4,12
ffffffffc0200416:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020041a:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020041e:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200422:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200426:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020042a:	00caeab3          	or	s5,s5,a2
ffffffffc020042e:	01877733          	and	a4,a4,s8
ffffffffc0200432:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200436:	00eaeab3          	or	s5,s5,a4
ffffffffc020043a:	00fb77b3          	and	a5,s6,a5
ffffffffc020043e:	00faeab3          	or	s5,s5,a5
ffffffffc0200442:	2a81                	sext.w	s5,s5
ffffffffc0200444:	000c9c63          	bnez	s9,ffffffffc020045c <dtb_init+0x23c>
ffffffffc0200448:	1a82                	slli	s5,s5,0x20
ffffffffc020044a:	00368793          	addi	a5,a3,3
ffffffffc020044e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200452:	9abe                	add	s5,s5,a5
ffffffffc0200454:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200458:	8a56                	mv	s4,s5
ffffffffc020045a:	b5f5                	j	ffffffffc0200346 <dtb_init+0x126>
ffffffffc020045c:	008a2783          	lw	a5,8(s4)
ffffffffc0200460:	85ca                	mv	a1,s2
ffffffffc0200462:	e436                	sd	a3,8(sp)
ffffffffc0200464:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200468:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020046c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200470:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200474:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200478:	8f51                	or	a4,a4,a2
ffffffffc020047a:	01857533          	and	a0,a0,s8
ffffffffc020047e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200482:	8d59                	or	a0,a0,a4
ffffffffc0200484:	00fb77b3          	and	a5,s6,a5
ffffffffc0200488:	8d5d                	or	a0,a0,a5
ffffffffc020048a:	1502                	slli	a0,a0,0x20
ffffffffc020048c:	9101                	srli	a0,a0,0x20
ffffffffc020048e:	9522                	add	a0,a0,s0
ffffffffc0200490:	147020ef          	jal	ffffffffc0202dd6 <strcmp>
ffffffffc0200494:	66a2                	ld	a3,8(sp)
ffffffffc0200496:	f94d                	bnez	a0,ffffffffc0200448 <dtb_init+0x228>
ffffffffc0200498:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200448 <dtb_init+0x228>
ffffffffc020049c:	00ca3783          	ld	a5,12(s4)
ffffffffc02004a0:	014a3703          	ld	a4,20(s4)
ffffffffc02004a4:	00003517          	auipc	a0,0x3
ffffffffc02004a8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0202ff0 <etext+0x188>
ffffffffc02004ac:	4207d613          	srai	a2,a5,0x20
ffffffffc02004b0:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02004b4:	42075593          	srai	a1,a4,0x20
ffffffffc02004b8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004bc:	0186581b          	srliw	a6,a2,0x18
ffffffffc02004c0:	0187941b          	slliw	s0,a5,0x18
ffffffffc02004c4:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02004c8:	0187d693          	srli	a3,a5,0x18
ffffffffc02004cc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004d0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004d4:	0103131b          	slliw	t1,t1,0x10
ffffffffc02004d8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004dc:	010f6f33          	or	t5,t5,a6
ffffffffc02004e0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004e4:	0185df9b          	srliw	t6,a1,0x18
ffffffffc02004e8:	01837333          	and	t1,t1,s8
ffffffffc02004ec:	01c46433          	or	s0,s0,t3
ffffffffc02004f0:	0186f6b3          	and	a3,a3,s8
ffffffffc02004f4:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004f8:	01871e9b          	slliw	t4,a4,0x18
ffffffffc02004fc:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200500:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200504:	8361                	srli	a4,a4,0x18
ffffffffc0200506:	0107979b          	slliw	a5,a5,0x10
ffffffffc020050a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020050e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200512:	00cb7633          	and	a2,s6,a2
ffffffffc0200516:	0088181b          	slliw	a6,a6,0x8
ffffffffc020051a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020051e:	00646433          	or	s0,s0,t1
ffffffffc0200522:	0187f7b3          	and	a5,a5,s8
ffffffffc0200526:	01fe6333          	or	t1,t3,t6
ffffffffc020052a:	01877c33          	and	s8,a4,s8
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
ffffffffc0200558:	1702                	slli	a4,a4,0x20
ffffffffc020055a:	1b02                	slli	s6,s6,0x20
ffffffffc020055c:	1782                	slli	a5,a5,0x20
ffffffffc020055e:	9301                	srli	a4,a4,0x20
ffffffffc0200560:	1402                	slli	s0,s0,0x20
ffffffffc0200562:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200566:	0167eb33          	or	s6,a5,s6
ffffffffc020056a:	8c59                	or	s0,s0,a4
ffffffffc020056c:	be1ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200570:	85a2                	mv	a1,s0
ffffffffc0200572:	00003517          	auipc	a0,0x3
ffffffffc0200576:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0203010 <etext+0x1a8>
ffffffffc020057a:	bd3ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc020057e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200582:	85da                	mv	a1,s6
ffffffffc0200584:	00003517          	auipc	a0,0x3
ffffffffc0200588:	aa450513          	addi	a0,a0,-1372 # ffffffffc0203028 <etext+0x1c0>
ffffffffc020058c:	bc1ff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc0200590:	008b05b3          	add	a1,s6,s0
ffffffffc0200594:	15fd                	addi	a1,a1,-1
ffffffffc0200596:	00003517          	auipc	a0,0x3
ffffffffc020059a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0203048 <etext+0x1e0>
ffffffffc020059e:	bafff0ef          	jal	ffffffffc020014c <cprintf>
ffffffffc02005a2:	00003517          	auipc	a0,0x3
ffffffffc02005a6:	af650513          	addi	a0,a0,-1290 # ffffffffc0203098 <etext+0x230>
ffffffffc02005aa:	00009797          	auipc	a5,0x9
ffffffffc02005ae:	9287bb23          	sd	s0,-1738(a5) # ffffffffc0208ee0 <memory_base>
ffffffffc02005b2:	00009797          	auipc	a5,0x9
ffffffffc02005b6:	9367bb23          	sd	s6,-1738(a5) # ffffffffc0208ee8 <memory_size>
ffffffffc02005ba:	b3f5                	j	ffffffffc02003a6 <dtb_init+0x186>

ffffffffc02005bc <get_memory_base>:
ffffffffc02005bc:	00009517          	auipc	a0,0x9
ffffffffc02005c0:	92453503          	ld	a0,-1756(a0) # ffffffffc0208ee0 <memory_base>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <get_memory_size>:
ffffffffc02005c6:	00009517          	auipc	a0,0x9
ffffffffc02005ca:	92253503          	ld	a0,-1758(a0) # ffffffffc0208ee8 <memory_size>
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <buddy_init>:
ffffffffc02005d0:	00008697          	auipc	a3,0x8
ffffffffc02005d4:	a6868693          	addi	a3,a3,-1432 # ffffffffc0208038 <buddy>
ffffffffc02005d8:	87b6                	mv	a5,a3
ffffffffc02005da:	00008717          	auipc	a4,0x8
ffffffffc02005de:	bae70713          	addi	a4,a4,-1106 # ffffffffc0208188 <buddy+0x150>
ffffffffc02005e2:	e79c                	sd	a5,8(a5)
ffffffffc02005e4:	e39c                	sd	a5,0(a5)
ffffffffc02005e6:	07c1                	addi	a5,a5,16
ffffffffc02005e8:	fee79de3          	bne	a5,a4,ffffffffc02005e2 <buddy_init+0x12>
ffffffffc02005ec:	00008797          	auipc	a5,0x8
ffffffffc02005f0:	b807be23          	sd	zero,-1124(a5) # ffffffffc0208188 <buddy+0x150>
ffffffffc02005f4:	00009797          	auipc	a5,0x9
ffffffffc02005f8:	9247b783          	ld	a5,-1756(a5) # ffffffffc0208f18 <npage>
ffffffffc02005fc:	14f6bc23          	sd	a5,344(a3)
ffffffffc0200600:	00004797          	auipc	a5,0x4
ffffffffc0200604:	b307b783          	ld	a5,-1232(a5) # ffffffffc0204130 <nbase>
ffffffffc0200608:	16f6b023          	sd	a5,352(a3)
ffffffffc020060c:	8082                	ret

ffffffffc020060e <free_partner>:
ffffffffc020060e:	00004697          	auipc	a3,0x4
ffffffffc0200612:	b226b683          	ld	a3,-1246(a3) # ffffffffc0204130 <nbase>
ffffffffc0200616:	06d56263          	bltu	a0,a3,ffffffffc020067a <free_partner+0x6c>
ffffffffc020061a:	00008717          	auipc	a4,0x8
ffffffffc020061e:	a1e70713          	addi	a4,a4,-1506 # ffffffffc0208038 <buddy>
ffffffffc0200622:	15873783          	ld	a5,344(a4)
ffffffffc0200626:	04f56a63          	bltu	a0,a5,ffffffffc020067a <free_partner+0x6c>
ffffffffc020062a:	00009797          	auipc	a5,0x9
ffffffffc020062e:	8ee7b783          	ld	a5,-1810(a5) # ffffffffc0208f18 <npage>
ffffffffc0200632:	04f57463          	bgeu	a0,a5,ffffffffc020067a <free_partner+0x6c>
ffffffffc0200636:	16073603          	ld	a2,352(a4)
ffffffffc020063a:	04c57063          	bgeu	a0,a2,ffffffffc020067a <free_partner+0x6c>
ffffffffc020063e:	4705                	li	a4,1
ffffffffc0200640:	00b715b3          	sll	a1,a4,a1
ffffffffc0200644:	8f89                	sub	a5,a5,a0
ffffffffc0200646:	02b7ea63          	bltu	a5,a1,ffffffffc020067a <free_partner+0x6c>
ffffffffc020064a:	8e09                	sub	a2,a2,a0
ffffffffc020064c:	02b66763          	bltu	a2,a1,ffffffffc020067a <free_partner+0x6c>
ffffffffc0200650:	8d15                	sub	a0,a0,a3
ffffffffc0200652:	00251793          	slli	a5,a0,0x2
ffffffffc0200656:	953e                	add	a0,a0,a5
ffffffffc0200658:	00351793          	slli	a5,a0,0x3
ffffffffc020065c:	00009517          	auipc	a0,0x9
ffffffffc0200660:	8c453503          	ld	a0,-1852(a0) # ffffffffc0208f20 <pages>
ffffffffc0200664:	953e                	add	a0,a0,a5
ffffffffc0200666:	651c                	ld	a5,8(a0)
ffffffffc0200668:	4709                	li	a4,2
ffffffffc020066a:	8b8d                	andi	a5,a5,3
ffffffffc020066c:	00e79763          	bne	a5,a4,ffffffffc020067a <free_partner+0x6c>
ffffffffc0200670:	01056783          	lwu	a5,16(a0)
ffffffffc0200674:	00b79363          	bne	a5,a1,ffffffffc020067a <free_partner+0x6c>
ffffffffc0200678:	8082                	ret
ffffffffc020067a:	4501                	li	a0,0
ffffffffc020067c:	8082                	ret

ffffffffc020067e <insert_merge>:
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
ffffffffc0200692:	47cd                	li	a5,19
ffffffffc0200694:	842e                	mv	s0,a1
ffffffffc0200696:	8b2a                	mv	s6,a0
ffffffffc0200698:	0ab7c563          	blt	a5,a1,ffffffffc0200742 <insert_merge+0xc4>
ffffffffc020069c:	00009a17          	auipc	s4,0x9
ffffffffc02006a0:	884a3a03          	ld	s4,-1916(s4) # ffffffffc0208f20 <pages>
ffffffffc02006a4:	00004997          	auipc	s3,0x4
ffffffffc02006a8:	a8c9b983          	ld	s3,-1396(s3) # ffffffffc0204130 <nbase>
ffffffffc02006ac:	00004917          	auipc	s2,0x4
ffffffffc02006b0:	a6c93903          	ld	s2,-1428(s2) # ffffffffc0204118 <error_string+0x38>
ffffffffc02006b4:	4485                	li	s1,1
ffffffffc02006b6:	4ad1                	li	s5,20
ffffffffc02006b8:	414b0533          	sub	a0,s6,s4
ffffffffc02006bc:	850d                	srai	a0,a0,0x3
ffffffffc02006be:	03250533          	mul	a0,a0,s2
ffffffffc02006c2:	00849bb3          	sll	s7,s1,s0
ffffffffc02006c6:	85a2                	mv	a1,s0
ffffffffc02006c8:	954e                	add	a0,a0,s3
ffffffffc02006ca:	01754533          	xor	a0,a0,s7
ffffffffc02006ce:	f41ff0ef          	jal	ffffffffc020060e <free_partner>
ffffffffc02006d2:	01850713          	addi	a4,a0,24
ffffffffc02006d6:	c505                	beqz	a0,ffffffffc02006fe <insert_merge+0x80>
ffffffffc02006d8:	6d10                	ld	a2,24(a0)
ffffffffc02006da:	7114                	ld	a3,32(a0)
ffffffffc02006dc:	651c                	ld	a5,8(a0)
ffffffffc02006de:	2405                	addiw	s0,s0,1
ffffffffc02006e0:	e614                	sd	a3,8(a2)
ffffffffc02006e2:	e290                	sd	a2,0(a3)
ffffffffc02006e4:	9bf5                	andi	a5,a5,-3
ffffffffc02006e6:	f118                	sd	a4,32(a0)
ffffffffc02006e8:	ed18                	sd	a4,24(a0)
ffffffffc02006ea:	e51c                	sd	a5,8(a0)
ffffffffc02006ec:	00052823          	sw	zero,16(a0)
ffffffffc02006f0:	01657363          	bgeu	a0,s6,ffffffffc02006f6 <insert_merge+0x78>
ffffffffc02006f4:	8b2a                	mv	s6,a0
ffffffffc02006f6:	fd5411e3          	bne	s0,s5,ffffffffc02006b8 <insert_merge+0x3a>
ffffffffc02006fa:	00100bb7          	lui	s7,0x100
ffffffffc02006fe:	008b3783          	ld	a5,8(s6)
ffffffffc0200702:	0412                	slli	s0,s0,0x4
ffffffffc0200704:	00008597          	auipc	a1,0x8
ffffffffc0200708:	93458593          	addi	a1,a1,-1740 # ffffffffc0208038 <buddy>
ffffffffc020070c:	942e                	add	s0,s0,a1
ffffffffc020070e:	6418                	ld	a4,8(s0)
ffffffffc0200710:	0027e793          	ori	a5,a5,2
ffffffffc0200714:	017b2823          	sw	s7,16(s6)
ffffffffc0200718:	00fb3423          	sd	a5,8(s6)
ffffffffc020071c:	018b0793          	addi	a5,s6,24
ffffffffc0200720:	e31c                	sd	a5,0(a4)
ffffffffc0200722:	e41c                	sd	a5,8(s0)
ffffffffc0200724:	008b3c23          	sd	s0,24(s6)
ffffffffc0200728:	60a6                	ld	ra,72(sp)
ffffffffc020072a:	6406                	ld	s0,64(sp)
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
ffffffffc0200742:	4b85                	li	s7,1
ffffffffc0200744:	00bb9bb3          	sll	s7,s7,a1
ffffffffc0200748:	bf5d                	j	ffffffffc02006fe <insert_merge+0x80>

ffffffffc020074a <buddy_nr_free_pages>:
ffffffffc020074a:	00008517          	auipc	a0,0x8
ffffffffc020074e:	a3e53503          	ld	a0,-1474(a0) # ffffffffc0208188 <buddy+0x150>
ffffffffc0200752:	8082                	ret

ffffffffc0200754 <check_consistency>:
ffffffffc0200754:	7131                	addi	sp,sp,-192
ffffffffc0200756:	00008317          	auipc	t1,0x8
ffffffffc020075a:	8e230313          	addi	t1,t1,-1822 # ffffffffc0208038 <buddy>
ffffffffc020075e:	f0ea                	sd	s10,96(sp)
ffffffffc0200760:	ecee                	sd	s11,88(sp)
ffffffffc0200762:	00004e17          	auipc	t3,0x4
ffffffffc0200766:	9cee3e03          	ld	t3,-1586(t3) # ffffffffc0204130 <nbase>
ffffffffc020076a:	00008d97          	auipc	s11,0x8
ffffffffc020076e:	7aedbd83          	ld	s11,1966(s11) # ffffffffc0208f18 <npage>
ffffffffc0200772:	15833f83          	ld	t6,344(t1)
ffffffffc0200776:	16033d03          	ld	s10,352(t1)
ffffffffc020077a:	41cd8db3          	sub	s11,s11,t3
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
ffffffffc0200794:	00008f17          	auipc	t5,0x8
ffffffffc0200798:	78cf3f03          	ld	t5,1932(t5) # ffffffffc0208f20 <pages>
ffffffffc020079c:	889a                	mv	a7,t1
ffffffffc020079e:	4c01                	li	s8,0
ffffffffc02007a0:	4b81                	li	s7,0
ffffffffc02007a2:	4c81                	li	s9,0
ffffffffc02007a4:	02800a13          	li	s4,40
ffffffffc02007a8:	00004e97          	auipc	t4,0x4
ffffffffc02007ac:	970ebe83          	ld	t4,-1680(t4) # ffffffffc0204118 <error_string+0x38>
ffffffffc02007b0:	49d5                	li	s3,21
ffffffffc02007b2:	83ee                	mv	t2,s11
ffffffffc02007b4:	0088bd83          	ld	s11,8(a7)
ffffffffc02007b8:	000c059b          	sext.w	a1,s8
ffffffffc02007bc:	131d8363          	beq	s11,a7,ffffffffc02008e2 <check_consistency+0x18e>
ffffffffc02007c0:	004c1b13          	slli	s6,s8,0x4
ffffffffc02007c4:	4785                	li	a5,1
ffffffffc02007c6:	9b1a                	add	s6,s6,t1
ffffffffc02007c8:	00b79933          	sll	s2,a5,a1
ffffffffc02007cc:	846e                	mv	s0,s11
ffffffffc02007ce:	e4c6                	sd	a7,72(sp)
ffffffffc02007d0:	fff90293          	addi	t0,s2,-1
ffffffffc02007d4:	88ee                	mv	a7,s11
ffffffffc02007d6:	00ba1833          	sll	a6,s4,a1
ffffffffc02007da:	8df2                	mv	s11,t3
ffffffffc02007dc:	8e62                	mv	t3,s8
ffffffffc02007de:	8c5a                	mv	s8,s6
ffffffffc02007e0:	8b1e                	mv	s6,t2
ffffffffc02007e2:	0b85                	addi	s7,s7,1 # 100001 <kern_entry-0xffffffffc00fffff>
ffffffffc02007e4:	237b6663          	bltu	s6,s7,ffffffffc0200a10 <check_consistency+0x2bc>
ffffffffc02007e8:	00843a83          	ld	s5,8(s0)
ffffffffc02007ec:	000ab783          	ld	a5,0(s5)
ffffffffc02007f0:	20879063          	bne	a5,s0,ffffffffc02009f0 <check_consistency+0x29c>
ffffffffc02007f4:	601c                	ld	a5,0(s0)
ffffffffc02007f6:	679c                	ld	a5,8(a5)
ffffffffc02007f8:	1e879c63          	bne	a5,s0,ffffffffc02009f0 <check_consistency+0x29c>
ffffffffc02007fc:	fe840493          	addi	s1,s0,-24
ffffffffc0200800:	41e48533          	sub	a0,s1,t5
ffffffffc0200804:	850d                	srai	a0,a0,0x3
ffffffffc0200806:	03d50533          	mul	a0,a0,t4
ffffffffc020080a:	956e                	add	a0,a0,s11
ffffffffc020080c:	1df56263          	bltu	a0,t6,ffffffffc02009d0 <check_consistency+0x27c>
ffffffffc0200810:	1da57063          	bgeu	a0,s10,ffffffffc02009d0 <check_consistency+0x27c>
ffffffffc0200814:	40ad07b3          	sub	a5,s10,a0
ffffffffc0200818:	1b27ec63          	bltu	a5,s2,ffffffffc02009d0 <check_consistency+0x27c>
ffffffffc020081c:	00a2f7b3          	and	a5,t0,a0
ffffffffc0200820:	18079863          	bnez	a5,ffffffffc02009b0 <check_consistency+0x25c>
ffffffffc0200824:	ff043703          	ld	a4,-16(s0)
ffffffffc0200828:	8b09                	andi	a4,a4,2
ffffffffc020082a:	18070363          	beqz	a4,ffffffffc02009b0 <check_consistency+0x25c>
ffffffffc020082e:	ff846703          	lwu	a4,-8(s0)
ffffffffc0200832:	17271f63          	bne	a4,s2,ffffffffc02009b0 <check_consistency+0x25c>
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
ffffffffc0200850:	dbfff0ef          	jal	ffffffffc020060e <free_partner>
ffffffffc0200854:	00004717          	auipc	a4,0x4
ffffffffc0200858:	8c470713          	addi	a4,a4,-1852 # ffffffffc0204118 <error_string+0x38>
ffffffffc020085c:	65a2                	ld	a1,8(sp)
ffffffffc020085e:	67c2                	ld	a5,16(sp)
ffffffffc0200860:	00073e83          	ld	t4,0(a4)
ffffffffc0200864:	6fe2                	ld	t6,24(sp)
ffffffffc0200866:	7282                	ld	t0,32(sp)
ffffffffc0200868:	7822                	ld	a6,40(sp)
ffffffffc020086a:	7f42                	ld	t5,48(sp)
ffffffffc020086c:	78e2                	ld	a7,56(sp)
ffffffffc020086e:	6e06                	ld	t3,64(sp)
ffffffffc0200870:	00007317          	auipc	t1,0x7
ffffffffc0200874:	7c830313          	addi	t1,t1,1992 # ffffffffc0208038 <buddy>
ffffffffc0200878:	10051c63          	bnez	a0,ffffffffc0200990 <check_consistency+0x23c>
ffffffffc020087c:	8726                	mv	a4,s1
ffffffffc020087e:	6714                	ld	a3,8(a4)
ffffffffc0200880:	0016f613          	andi	a2,a3,1
ffffffffc0200884:	e655                	bnez	a2,ffffffffc0200930 <check_consistency+0x1dc>
ffffffffc0200886:	4310                	lw	a2,0(a4)
ffffffffc0200888:	e645                	bnez	a2,ffffffffc0200930 <check_consistency+0x1dc>
ffffffffc020088a:	c399                	beqz	a5,ffffffffc0200890 <check_consistency+0x13c>
ffffffffc020088c:	8a89                	andi	a3,a3,2
ffffffffc020088e:	e2e9                	bnez	a3,ffffffffc0200950 <check_consistency+0x1fc>
ffffffffc0200890:	0785                	addi	a5,a5,1
ffffffffc0200892:	02870713          	addi	a4,a4,40
ffffffffc0200896:	ff27e4e3          	bltu	a5,s2,ffffffffc020087e <check_consistency+0x12a>
ffffffffc020089a:	01048633          	add	a2,s1,a6
ffffffffc020089e:	86e2                	mv	a3,s8
ffffffffc02008a0:	87c6                	mv	a5,a7
ffffffffc02008a2:	80ae                	mv	ra,a1
ffffffffc02008a4:	02d78063          	beq	a5,a3,ffffffffc02008c4 <check_consistency+0x170>
ffffffffc02008a8:	001a1533          	sll	a0,s4,ra
ffffffffc02008ac:	00878963          	beq	a5,s0,ffffffffc02008be <check_consistency+0x16a>
ffffffffc02008b0:	fe878713          	addi	a4,a5,-24
ffffffffc02008b4:	00c77563          	bgeu	a4,a2,ffffffffc02008be <check_consistency+0x16a>
ffffffffc02008b8:	972a                	add	a4,a4,a0
ffffffffc02008ba:	04e4eb63          	bltu	s1,a4,ffffffffc0200910 <check_consistency+0x1bc>
ffffffffc02008be:	679c                	ld	a5,8(a5)
ffffffffc02008c0:	fed796e3          	bne	a5,a3,ffffffffc02008ac <check_consistency+0x158>
ffffffffc02008c4:	2085                	addiw	ra,ra,1
ffffffffc02008c6:	06c1                	addi	a3,a3,16
ffffffffc02008c8:	01308463          	beq	ra,s3,ffffffffc02008d0 <check_consistency+0x17c>
ffffffffc02008cc:	669c                	ld	a5,8(a3)
ffffffffc02008ce:	bfd9                	j	ffffffffc02008a4 <check_consistency+0x150>
ffffffffc02008d0:	9cca                	add	s9,s9,s2
ffffffffc02008d2:	018a8463          	beq	s5,s8,ffffffffc02008da <check_consistency+0x186>
ffffffffc02008d6:	8456                	mv	s0,s5
ffffffffc02008d8:	b729                	j	ffffffffc02007e2 <check_consistency+0x8e>
ffffffffc02008da:	68a6                	ld	a7,72(sp)
ffffffffc02008dc:	8c72                	mv	s8,t3
ffffffffc02008de:	83da                	mv	t2,s6
ffffffffc02008e0:	8e6e                	mv	t3,s11
ffffffffc02008e2:	0c05                	addi	s8,s8,1 # ff0001 <kern_entry-0xffffffffbf20ffff>
ffffffffc02008e4:	08c1                	addi	a7,a7,16
ffffffffc02008e6:	ed3c17e3          	bne	s8,s3,ffffffffc02007b4 <check_consistency+0x60>
ffffffffc02008ea:	28a010ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02008ee:	09951163          	bne	a0,s9,ffffffffc0200970 <check_consistency+0x21c>
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
ffffffffc0200910:	00003697          	auipc	a3,0x3
ffffffffc0200914:	93868693          	addi	a3,a3,-1736 # ffffffffc0203248 <etext+0x3e0>
ffffffffc0200918:	00002617          	auipc	a2,0x2
ffffffffc020091c:	7b860613          	addi	a2,a2,1976 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200920:	0a900593          	li	a1,169
ffffffffc0200924:	00002517          	auipc	a0,0x2
ffffffffc0200928:	7c450513          	addi	a0,a0,1988 # ffffffffc02030e8 <etext+0x280>
ffffffffc020092c:	897ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200930:	00003697          	auipc	a3,0x3
ffffffffc0200934:	8d068693          	addi	a3,a3,-1840 # ffffffffc0203200 <etext+0x398>
ffffffffc0200938:	00002617          	auipc	a2,0x2
ffffffffc020093c:	79860613          	addi	a2,a2,1944 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200940:	0a100593          	li	a1,161
ffffffffc0200944:	00002517          	auipc	a0,0x2
ffffffffc0200948:	7a450513          	addi	a0,a0,1956 # ffffffffc02030e8 <etext+0x280>
ffffffffc020094c:	877ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200950:	00003697          	auipc	a3,0x3
ffffffffc0200954:	8e068693          	addi	a3,a3,-1824 # ffffffffc0203230 <etext+0x3c8>
ffffffffc0200958:	00002617          	auipc	a2,0x2
ffffffffc020095c:	77860613          	addi	a2,a2,1912 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200960:	0a200593          	li	a1,162
ffffffffc0200964:	00002517          	auipc	a0,0x2
ffffffffc0200968:	78450513          	addi	a0,a0,1924 # ffffffffc02030e8 <etext+0x280>
ffffffffc020096c:	857ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200970:	00003697          	auipc	a3,0x3
ffffffffc0200974:	90868693          	addi	a3,a3,-1784 # ffffffffc0203278 <etext+0x410>
ffffffffc0200978:	00002617          	auipc	a2,0x2
ffffffffc020097c:	75860613          	addi	a2,a2,1880 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200980:	0af00593          	li	a1,175
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	76450513          	addi	a0,a0,1892 # ffffffffc02030e8 <etext+0x280>
ffffffffc020098c:	837ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200990:	00003697          	auipc	a3,0x3
ffffffffc0200994:	84868693          	addi	a3,a3,-1976 # ffffffffc02031d8 <etext+0x370>
ffffffffc0200998:	00002617          	auipc	a2,0x2
ffffffffc020099c:	73860613          	addi	a2,a2,1848 # ffffffffc02030d0 <etext+0x268>
ffffffffc02009a0:	09f00593          	li	a1,159
ffffffffc02009a4:	00002517          	auipc	a0,0x2
ffffffffc02009a8:	74450513          	addi	a0,a0,1860 # ffffffffc02030e8 <etext+0x280>
ffffffffc02009ac:	817ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02009b0:	00002697          	auipc	a3,0x2
ffffffffc02009b4:	7e068693          	addi	a3,a3,2016 # ffffffffc0203190 <etext+0x328>
ffffffffc02009b8:	00002617          	auipc	a2,0x2
ffffffffc02009bc:	71860613          	addi	a2,a2,1816 # ffffffffc02030d0 <etext+0x268>
ffffffffc02009c0:	09e00593          	li	a1,158
ffffffffc02009c4:	00002517          	auipc	a0,0x2
ffffffffc02009c8:	72450513          	addi	a0,a0,1828 # ffffffffc02030e8 <etext+0x280>
ffffffffc02009cc:	ff6ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02009d0:	00002697          	auipc	a3,0x2
ffffffffc02009d4:	77868693          	addi	a3,a3,1912 # ffffffffc0203148 <etext+0x2e0>
ffffffffc02009d8:	00002617          	auipc	a2,0x2
ffffffffc02009dc:	6f860613          	addi	a2,a2,1784 # ffffffffc02030d0 <etext+0x268>
ffffffffc02009e0:	09d00593          	li	a1,157
ffffffffc02009e4:	00002517          	auipc	a0,0x2
ffffffffc02009e8:	70450513          	addi	a0,a0,1796 # ffffffffc02030e8 <etext+0x280>
ffffffffc02009ec:	fd6ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02009f0:	00002697          	auipc	a3,0x2
ffffffffc02009f4:	71068693          	addi	a3,a3,1808 # ffffffffc0203100 <etext+0x298>
ffffffffc02009f8:	00002617          	auipc	a2,0x2
ffffffffc02009fc:	6d860613          	addi	a2,a2,1752 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200a00:	09900593          	li	a1,153
ffffffffc0200a04:	00002517          	auipc	a0,0x2
ffffffffc0200a08:	6e450513          	addi	a0,a0,1764 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200a0c:	fb6ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200a10:	00002697          	auipc	a3,0x2
ffffffffc0200a14:	6a068693          	addi	a3,a3,1696 # ffffffffc02030b0 <etext+0x248>
ffffffffc0200a18:	00002617          	auipc	a2,0x2
ffffffffc0200a1c:	6b860613          	addi	a2,a2,1720 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200a20:	09800593          	li	a1,152
ffffffffc0200a24:	00002517          	auipc	a0,0x2
ffffffffc0200a28:	6c450513          	addi	a0,a0,1732 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200a2c:	f96ff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0200a30 <check_pool>:
ffffffffc0200a30:	7139                	addi	sp,sp,-64
ffffffffc0200a32:	fc06                	sd	ra,56(sp)
ffffffffc0200a34:	f822                	sd	s0,48(sp)
ffffffffc0200a36:	f426                	sd	s1,40(sp)
ffffffffc0200a38:	e002                	sd	zero,0(sp)
ffffffffc0200a3a:	e402                	sd	zero,8(sp)
ffffffffc0200a3c:	e802                	sd	zero,16(sp)
ffffffffc0200a3e:	ec02                	sd	zero,24(sp)
ffffffffc0200a40:	d15ff0ef          	jal	ffffffffc0200754 <check_consistency>
ffffffffc0200a44:	00008e97          	auipc	t4,0x8
ffffffffc0200a48:	4acebe83          	ld	t4,1196(t4) # ffffffffc0208ef0 <test_base>
ffffffffc0200a4c:	500e8293          	addi	t0,t4,1280
ffffffffc0200a50:	00007f17          	auipc	t5,0x7
ffffffffc0200a54:	5e8f0f13          	addi	t5,t5,1512 # ffffffffc0208038 <buddy>
ffffffffc0200a58:	4401                	li	s0,0
ffffffffc0200a5a:	02800493          	li	s1,40
ffffffffc0200a5e:	4885                	li	a7,1
ffffffffc0200a60:	00003f97          	auipc	t6,0x3
ffffffffc0200a64:	6b8fbf83          	ld	t6,1720(t6) # ffffffffc0204118 <error_string+0x38>
ffffffffc0200a68:	00007817          	auipc	a6,0x7
ffffffffc0200a6c:	5b080813          	addi	a6,a6,1456 # ffffffffc0208018 <allowed>
ffffffffc0200a70:	00008517          	auipc	a0,0x8
ffffffffc0200a74:	d9850513          	addi	a0,a0,-616 # ffffffffc0208808 <occupied>
ffffffffc0200a78:	40d5                	li	ra,21
ffffffffc0200a7a:	008f3e03          	ld	t3,8(t5)
ffffffffc0200a7e:	008493b3          	sll	t2,s1,s0
ffffffffc0200a82:	00889333          	sll	t1,a7,s0
ffffffffc0200a86:	05ee0a63          	beq	t3,t5,ffffffffc0200ada <check_pool+0xaa>
ffffffffc0200a8a:	fe8e0793          	addi	a5,t3,-24
ffffffffc0200a8e:	11d7e063          	bltu	a5,t4,ffffffffc0200b8e <check_pool+0x15e>
ffffffffc0200a92:	00778733          	add	a4,a5,t2
ffffffffc0200a96:	0ee2ec63          	bltu	t0,a4,ffffffffc0200b8e <check_pool+0x15e>
ffffffffc0200a9a:	41d785b3          	sub	a1,a5,t4
ffffffffc0200a9e:	858d                	srai	a1,a1,0x3
ffffffffc0200aa0:	03f585b3          	mul	a1,a1,t6
ffffffffc0200aa4:	4701                	li	a4,0
ffffffffc0200aa6:	00b106b3          	add	a3,sp,a1
ffffffffc0200aaa:	00b707b3          	add	a5,a4,a1
ffffffffc0200aae:	00f80633          	add	a2,a6,a5
ffffffffc0200ab2:	00064603          	lbu	a2,0(a2)
ffffffffc0200ab6:	ce41                	beqz	a2,ffffffffc0200b4e <check_pool+0x11e>
ffffffffc0200ab8:	97aa                	add	a5,a5,a0
ffffffffc0200aba:	0007c783          	lbu	a5,0(a5)
ffffffffc0200abe:	ebc1                	bnez	a5,ffffffffc0200b4e <check_pool+0x11e>
ffffffffc0200ac0:	0006c783          	lbu	a5,0(a3)
ffffffffc0200ac4:	e7c9                	bnez	a5,ffffffffc0200b4e <check_pool+0x11e>
ffffffffc0200ac6:	01168023          	sb	a7,0(a3)
ffffffffc0200aca:	0705                	addi	a4,a4,1
ffffffffc0200acc:	0685                	addi	a3,a3,1
ffffffffc0200ace:	fc676ee3          	bltu	a4,t1,ffffffffc0200aaa <check_pool+0x7a>
ffffffffc0200ad2:	008e3e03          	ld	t3,8(t3)
ffffffffc0200ad6:	fbee1ae3          	bne	t3,t5,ffffffffc0200a8a <check_pool+0x5a>
ffffffffc0200ada:	2405                	addiw	s0,s0,1
ffffffffc0200adc:	0f41                	addi	t5,t5,16
ffffffffc0200ade:	f8141ee3          	bne	s0,ra,ffffffffc0200a7a <check_pool+0x4a>
ffffffffc0200ae2:	860a                	mv	a2,sp
ffffffffc0200ae4:	00007597          	auipc	a1,0x7
ffffffffc0200ae8:	53458593          	addi	a1,a1,1332 # ffffffffc0208018 <allowed>
ffffffffc0200aec:	0ea1                	addi	t4,t4,8
ffffffffc0200aee:	00008517          	auipc	a0,0x8
ffffffffc0200af2:	d1a50513          	addi	a0,a0,-742 # ffffffffc0208808 <occupied>
ffffffffc0200af6:	4401                	li	s0,0
ffffffffc0200af8:	00064683          	lbu	a3,0(a2)
ffffffffc0200afc:	0005c703          	lbu	a4,0(a1)
ffffffffc0200b00:	4781                	li	a5,0
ffffffffc0200b02:	0006881b          	sext.w	a6,a3
ffffffffc0200b06:	c709                	beqz	a4,ffffffffc0200b10 <check_pool+0xe0>
ffffffffc0200b08:	00054783          	lbu	a5,0(a0)
ffffffffc0200b0c:	0017b793          	seqz	a5,a5
ffffffffc0200b10:	04f81f63          	bne	a6,a5,ffffffffc0200b6e <check_pool+0x13e>
ffffffffc0200b14:	000eb783          	ld	a5,0(t4)
ffffffffc0200b18:	00d036b3          	snez	a3,a3
ffffffffc0200b1c:	00e03733          	snez	a4,a4
ffffffffc0200b20:	fff7c793          	not	a5,a5
ffffffffc0200b24:	8b85                	andi	a5,a5,1
ffffffffc0200b26:	9436                	add	s0,s0,a3
ffffffffc0200b28:	0af71363          	bne	a4,a5,ffffffffc0200bce <check_pool+0x19e>
ffffffffc0200b2c:	0605                	addi	a2,a2,1
ffffffffc0200b2e:	101c                	addi	a5,sp,32
ffffffffc0200b30:	0585                	addi	a1,a1,1
ffffffffc0200b32:	028e8e93          	addi	t4,t4,40
ffffffffc0200b36:	0505                	addi	a0,a0,1
ffffffffc0200b38:	fcf610e3          	bne	a2,a5,ffffffffc0200af8 <check_pool+0xc8>
ffffffffc0200b3c:	038010ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0200b40:	06851763          	bne	a0,s0,ffffffffc0200bae <check_pool+0x17e>
ffffffffc0200b44:	70e2                	ld	ra,56(sp)
ffffffffc0200b46:	7442                	ld	s0,48(sp)
ffffffffc0200b48:	74a2                	ld	s1,40(sp)
ffffffffc0200b4a:	6121                	addi	sp,sp,64
ffffffffc0200b4c:	8082                	ret
ffffffffc0200b4e:	00002697          	auipc	a3,0x2
ffffffffc0200b52:	78a68693          	addi	a3,a3,1930 # ffffffffc02032d8 <etext+0x470>
ffffffffc0200b56:	00002617          	auipc	a2,0x2
ffffffffc0200b5a:	57a60613          	addi	a2,a2,1402 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200b5e:	0be00593          	li	a1,190
ffffffffc0200b62:	00002517          	auipc	a0,0x2
ffffffffc0200b66:	58650513          	addi	a0,a0,1414 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200b6a:	e58ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200b6e:	00002697          	auipc	a3,0x2
ffffffffc0200b72:	7aa68693          	addi	a3,a3,1962 # ffffffffc0203318 <etext+0x4b0>
ffffffffc0200b76:	00002617          	auipc	a2,0x2
ffffffffc0200b7a:	55a60613          	addi	a2,a2,1370 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200b7e:	0c400593          	li	a1,196
ffffffffc0200b82:	00002517          	auipc	a0,0x2
ffffffffc0200b86:	56650513          	addi	a0,a0,1382 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200b8a:	e38ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200b8e:	00002697          	auipc	a3,0x2
ffffffffc0200b92:	70a68693          	addi	a3,a3,1802 # ffffffffc0203298 <etext+0x430>
ffffffffc0200b96:	00002617          	auipc	a2,0x2
ffffffffc0200b9a:	53a60613          	addi	a2,a2,1338 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200b9e:	0bb00593          	li	a1,187
ffffffffc0200ba2:	00002517          	auipc	a0,0x2
ffffffffc0200ba6:	54650513          	addi	a0,a0,1350 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200baa:	e18ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200bae:	00002697          	auipc	a3,0x2
ffffffffc0200bb2:	7c268693          	addi	a3,a3,1986 # ffffffffc0203370 <etext+0x508>
ffffffffc0200bb6:	00002617          	auipc	a2,0x2
ffffffffc0200bba:	51a60613          	addi	a2,a2,1306 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200bbe:	0c800593          	li	a1,200
ffffffffc0200bc2:	00002517          	auipc	a0,0x2
ffffffffc0200bc6:	52650513          	addi	a0,a0,1318 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200bca:	df8ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200bce:	00002697          	auipc	a3,0x2
ffffffffc0200bd2:	77268693          	addi	a3,a3,1906 # ffffffffc0203340 <etext+0x4d8>
ffffffffc0200bd6:	00002617          	auipc	a2,0x2
ffffffffc0200bda:	4fa60613          	addi	a2,a2,1274 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200bde:	0c600593          	li	a1,198
ffffffffc0200be2:	00002517          	auipc	a0,0x2
ffffffffc0200be6:	50650513          	addi	a0,a0,1286 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200bea:	dd8ff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0200bee <pool_alloc>:
ffffffffc0200bee:	1101                	addi	sp,sp,-32
ffffffffc0200bf0:	e822                	sd	s0,16(sp)
ffffffffc0200bf2:	e426                	sd	s1,8(sp)
ffffffffc0200bf4:	ec06                	sd	ra,24(sp)
ffffffffc0200bf6:	84aa                	mv	s1,a0
ffffffffc0200bf8:	765000ef          	jal	ffffffffc0201b5c <alloc_pages>
ffffffffc0200bfc:	842a                	mv	s0,a0
ffffffffc0200bfe:	cd4d                	beqz	a0,ffffffffc0200cb8 <pool_alloc+0xca>
ffffffffc0200c00:	4785                	li	a5,1
ffffffffc0200c02:	4805                	li	a6,1
ffffffffc0200c04:	0097f563          	bgeu	a5,s1,ffffffffc0200c0e <pool_alloc+0x20>
ffffffffc0200c08:	0806                	slli	a6,a6,0x1
ffffffffc0200c0a:	fe986fe3          	bltu	a6,s1,ffffffffc0200c08 <pool_alloc+0x1a>
ffffffffc0200c0e:	00008797          	auipc	a5,0x8
ffffffffc0200c12:	2e27b783          	ld	a5,738(a5) # ffffffffc0208ef0 <test_base>
ffffffffc0200c16:	12f46963          	bltu	s0,a5,ffffffffc0200d48 <pool_alloc+0x15a>
ffffffffc0200c1a:	00281713          	slli	a4,a6,0x2
ffffffffc0200c1e:	9742                	add	a4,a4,a6
ffffffffc0200c20:	070e                	slli	a4,a4,0x3
ffffffffc0200c22:	9722                	add	a4,a4,s0
ffffffffc0200c24:	50078693          	addi	a3,a5,1280
ffffffffc0200c28:	12e6e063          	bltu	a3,a4,ffffffffc0200d48 <pool_alloc+0x15a>
ffffffffc0200c2c:	00008317          	auipc	t1,0x8
ffffffffc0200c30:	2f433303          	ld	t1,756(t1) # ffffffffc0208f20 <pages>
ffffffffc0200c34:	406405b3          	sub	a1,s0,t1
ffffffffc0200c38:	858d                	srai	a1,a1,0x3
ffffffffc0200c3a:	00003897          	auipc	a7,0x3
ffffffffc0200c3e:	4de8b883          	ld	a7,1246(a7) # ffffffffc0204118 <error_string+0x38>
ffffffffc0200c42:	031585b3          	mul	a1,a1,a7
ffffffffc0200c46:	00003e17          	auipc	t3,0x3
ffffffffc0200c4a:	4eae3e03          	ld	t3,1258(t3) # ffffffffc0204130 <nbase>
ffffffffc0200c4e:	95f2                	add	a1,a1,t3
ffffffffc0200c50:	0305f733          	remu	a4,a1,a6
ffffffffc0200c54:	eb71                	bnez	a4,ffffffffc0200d28 <pool_alloc+0x13a>
ffffffffc0200c56:	40f407b3          	sub	a5,s0,a5
ffffffffc0200c5a:	878d                	srai	a5,a5,0x3
ffffffffc0200c5c:	031787b3          	mul	a5,a5,a7
ffffffffc0200c60:	00007697          	auipc	a3,0x7
ffffffffc0200c64:	3b868693          	addi	a3,a3,952 # ffffffffc0208018 <allowed>
ffffffffc0200c68:	00008617          	auipc	a2,0x8
ffffffffc0200c6c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0208808 <occupied>
ffffffffc0200c70:	05b2                	slli	a1,a1,0xc
ffffffffc0200c72:	8722                	mv	a4,s0
ffffffffc0200c74:	4505                	li	a0,1
ffffffffc0200c76:	6e85                	lui	t4,0x1
ffffffffc0200c78:	96be                	add	a3,a3,a5
ffffffffc0200c7a:	963e                	add	a2,a2,a5
ffffffffc0200c7c:	9836                	add	a6,a6,a3
ffffffffc0200c7e:	0006c783          	lbu	a5,0(a3)
ffffffffc0200c82:	c3b9                	beqz	a5,ffffffffc0200cc8 <pool_alloc+0xda>
ffffffffc0200c84:	00064783          	lbu	a5,0(a2)
ffffffffc0200c88:	e3a1                	bnez	a5,ffffffffc0200cc8 <pool_alloc+0xda>
ffffffffc0200c8a:	671c                	ld	a5,8(a4)
ffffffffc0200c8c:	8b89                	andi	a5,a5,2
ffffffffc0200c8e:	ef8d                	bnez	a5,ffffffffc0200cc8 <pool_alloc+0xda>
ffffffffc0200c90:	431c                	lw	a5,0(a4)
ffffffffc0200c92:	ebbd                	bnez	a5,ffffffffc0200d08 <pool_alloc+0x11a>
ffffffffc0200c94:	406707b3          	sub	a5,a4,t1
ffffffffc0200c98:	878d                	srai	a5,a5,0x3
ffffffffc0200c9a:	031787b3          	mul	a5,a5,a7
ffffffffc0200c9e:	97f2                	add	a5,a5,t3
ffffffffc0200ca0:	07b2                	slli	a5,a5,0xc
ffffffffc0200ca2:	04b79363          	bne	a5,a1,ffffffffc0200ce8 <pool_alloc+0xfa>
ffffffffc0200ca6:	00a60023          	sb	a0,0(a2)
ffffffffc0200caa:	0685                	addi	a3,a3,1
ffffffffc0200cac:	0605                	addi	a2,a2,1
ffffffffc0200cae:	02870713          	addi	a4,a4,40
ffffffffc0200cb2:	95f6                	add	a1,a1,t4
ffffffffc0200cb4:	fd0695e3          	bne	a3,a6,ffffffffc0200c7e <pool_alloc+0x90>
ffffffffc0200cb8:	d79ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0200cbc:	60e2                	ld	ra,24(sp)
ffffffffc0200cbe:	8522                	mv	a0,s0
ffffffffc0200cc0:	6442                	ld	s0,16(sp)
ffffffffc0200cc2:	64a2                	ld	s1,8(sp)
ffffffffc0200cc4:	6105                	addi	sp,sp,32
ffffffffc0200cc6:	8082                	ret
ffffffffc0200cc8:	00002697          	auipc	a3,0x2
ffffffffc0200ccc:	72068693          	addi	a3,a3,1824 # ffffffffc02033e8 <etext+0x580>
ffffffffc0200cd0:	00002617          	auipc	a2,0x2
ffffffffc0200cd4:	40060613          	addi	a2,a2,1024 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200cd8:	0f400593          	li	a1,244
ffffffffc0200cdc:	00002517          	auipc	a0,0x2
ffffffffc0200ce0:	40c50513          	addi	a0,a0,1036 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200ce4:	cdeff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200ce8:	00002697          	auipc	a3,0x2
ffffffffc0200cec:	75068693          	addi	a3,a3,1872 # ffffffffc0203438 <etext+0x5d0>
ffffffffc0200cf0:	00002617          	auipc	a2,0x2
ffffffffc0200cf4:	3e060613          	addi	a2,a2,992 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200cf8:	0f600593          	li	a1,246
ffffffffc0200cfc:	00002517          	auipc	a0,0x2
ffffffffc0200d00:	3ec50513          	addi	a0,a0,1004 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200d04:	cbeff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200d08:	00002697          	auipc	a3,0x2
ffffffffc0200d0c:	71868693          	addi	a3,a3,1816 # ffffffffc0203420 <etext+0x5b8>
ffffffffc0200d10:	00002617          	auipc	a2,0x2
ffffffffc0200d14:	3c060613          	addi	a2,a2,960 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200d18:	0f500593          	li	a1,245
ffffffffc0200d1c:	00002517          	auipc	a0,0x2
ffffffffc0200d20:	3cc50513          	addi	a0,a0,972 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200d24:	c9eff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200d28:	00002697          	auipc	a3,0x2
ffffffffc0200d2c:	6a068693          	addi	a3,a3,1696 # ffffffffc02033c8 <etext+0x560>
ffffffffc0200d30:	00002617          	auipc	a2,0x2
ffffffffc0200d34:	3a060613          	addi	a2,a2,928 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200d38:	0f100593          	li	a1,241
ffffffffc0200d3c:	00002517          	auipc	a0,0x2
ffffffffc0200d40:	3ac50513          	addi	a0,a0,940 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200d44:	c7eff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200d48:	00002697          	auipc	a3,0x2
ffffffffc0200d4c:	64868693          	addi	a3,a3,1608 # ffffffffc0203390 <etext+0x528>
ffffffffc0200d50:	00002617          	auipc	a2,0x2
ffffffffc0200d54:	38060613          	addi	a2,a2,896 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200d58:	0f000593          	li	a1,240
ffffffffc0200d5c:	00002517          	auipc	a0,0x2
ffffffffc0200d60:	38c50513          	addi	a0,a0,908 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200d64:	c5eff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0200d68 <buddy_init_memmap>:
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
ffffffffc0200d80:	16058363          	beqz	a1,ffffffffc0200ee6 <buddy_init_memmap+0x17e>
ffffffffc0200d84:	00008917          	auipc	s2,0x8
ffffffffc0200d88:	19c90913          	addi	s2,s2,412 # ffffffffc0208f20 <pages>
ffffffffc0200d8c:	00093703          	ld	a4,0(s2)
ffffffffc0200d90:	8a2e                	mv	s4,a1
ffffffffc0200d92:	00003497          	auipc	s1,0x3
ffffffffc0200d96:	3864b483          	ld	s1,902(s1) # ffffffffc0204118 <error_string+0x38>
ffffffffc0200d9a:	40e50733          	sub	a4,a0,a4
ffffffffc0200d9e:	40375593          	srai	a1,a4,0x3
ffffffffc0200da2:	029585b3          	mul	a1,a1,s1
ffffffffc0200da6:	00003417          	auipc	s0,0x3
ffffffffc0200daa:	38a43403          	ld	s0,906(s0) # ffffffffc0204130 <nbase>
ffffffffc0200dae:	8c2a                	mv	s8,a0
ffffffffc0200db0:	95a2                	add	a1,a1,s0
ffffffffc0200db2:	1085ea63          	bltu	a1,s0,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
ffffffffc0200db6:	00008797          	auipc	a5,0x8
ffffffffc0200dba:	1627b783          	ld	a5,354(a5) # ffffffffc0208f18 <npage>
ffffffffc0200dbe:	10f5f463          	bgeu	a1,a5,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
ffffffffc0200dc2:	8f8d                	sub	a5,a5,a1
ffffffffc0200dc4:	1147e163          	bltu	a5,s4,ffffffffc0200ec6 <buddy_init_memmap+0x15e>
ffffffffc0200dc8:	002a1613          	slli	a2,s4,0x2
ffffffffc0200dcc:	9652                	add	a2,a2,s4
ffffffffc0200dce:	060e                	slli	a2,a2,0x3
ffffffffc0200dd0:	962a                	add	a2,a2,a0
ffffffffc0200dd2:	87aa                	mv	a5,a0
ffffffffc0200dd4:	00c57f63          	bgeu	a0,a2,ffffffffc0200df2 <buddy_init_memmap+0x8a>
ffffffffc0200dd8:	6794                	ld	a3,8(a5)
ffffffffc0200dda:	8a85                	andi	a3,a3,1
ffffffffc0200ddc:	c6e9                	beqz	a3,ffffffffc0200ea6 <buddy_init_memmap+0x13e>
ffffffffc0200dde:	0007a823          	sw	zero,16(a5)
ffffffffc0200de2:	0007b423          	sd	zero,8(a5)
ffffffffc0200de6:	0007a023          	sw	zero,0(a5)
ffffffffc0200dea:	02878793          	addi	a5,a5,40
ffffffffc0200dee:	fec7e5e3          	bltu	a5,a2,ffffffffc0200dd8 <buddy_init_memmap+0x70>
ffffffffc0200df2:	00007797          	auipc	a5,0x7
ffffffffc0200df6:	24678793          	addi	a5,a5,582 # ffffffffc0208038 <buddy>
ffffffffc0200dfa:	1587b683          	ld	a3,344(a5)
ffffffffc0200dfe:	00d5f463          	bgeu	a1,a3,ffffffffc0200e06 <buddy_init_memmap+0x9e>
ffffffffc0200e02:	14b7bc23          	sd	a1,344(a5)
ffffffffc0200e06:	1607b683          	ld	a3,352(a5)
ffffffffc0200e0a:	95d2                	add	a1,a1,s4
ffffffffc0200e0c:	08b6ea63          	bltu	a3,a1,ffffffffc0200ea0 <buddy_init_memmap+0x138>
ffffffffc0200e10:	1507b683          	ld	a3,336(a5)
ffffffffc0200e14:	4a85                	li	s5,1
ffffffffc0200e16:	5b7d                	li	s6,-1
ffffffffc0200e18:	96d2                	add	a3,a3,s4
ffffffffc0200e1a:	14d7b823          	sd	a3,336(a5)
ffffffffc0200e1e:	4bd1                	li	s7,20
ffffffffc0200e20:	02800993          	li	s3,40
ffffffffc0200e24:	870d                	srai	a4,a4,0x3
ffffffffc0200e26:	02970733          	mul	a4,a4,s1
ffffffffc0200e2a:	4581                	li	a1,0
ffffffffc0200e2c:	9722                	add	a4,a4,s0
ffffffffc0200e2e:	86ae                	mv	a3,a1
ffffffffc0200e30:	2585                	addiw	a1,a1,1
ffffffffc0200e32:	00ba97b3          	sll	a5,s5,a1
ffffffffc0200e36:	02fa6b63          	bltu	s4,a5,ffffffffc0200e6c <buddy_init_memmap+0x104>
ffffffffc0200e3a:	00bb17b3          	sll	a5,s6,a1
ffffffffc0200e3e:	fff7c793          	not	a5,a5
ffffffffc0200e42:	8ff9                	and	a5,a5,a4
ffffffffc0200e44:	e785                	bnez	a5,ffffffffc0200e6c <buddy_init_memmap+0x104>
ffffffffc0200e46:	ff7594e3          	bne	a1,s7,ffffffffc0200e2e <buddy_init_memmap+0xc6>
ffffffffc0200e4a:	001007b7          	lui	a5,0x100
ffffffffc0200e4e:	8562                	mv	a0,s8
ffffffffc0200e50:	02800cb7          	lui	s9,0x2800
ffffffffc0200e54:	40fa0a33          	sub	s4,s4,a5
ffffffffc0200e58:	9c66                	add	s8,s8,s9
ffffffffc0200e5a:	825ff0ef          	jal	ffffffffc020067e <insert_merge>
ffffffffc0200e5e:	020a0463          	beqz	s4,ffffffffc0200e86 <buddy_init_memmap+0x11e>
ffffffffc0200e62:	00093703          	ld	a4,0(s2)
ffffffffc0200e66:	40ec0733          	sub	a4,s8,a4
ffffffffc0200e6a:	bf6d                	j	ffffffffc0200e24 <buddy_init_memmap+0xbc>
ffffffffc0200e6c:	00da97b3          	sll	a5,s5,a3
ffffffffc0200e70:	00d99cb3          	sll	s9,s3,a3
ffffffffc0200e74:	8562                	mv	a0,s8
ffffffffc0200e76:	85b6                	mv	a1,a3
ffffffffc0200e78:	40fa0a33          	sub	s4,s4,a5
ffffffffc0200e7c:	9c66                	add	s8,s8,s9
ffffffffc0200e7e:	801ff0ef          	jal	ffffffffc020067e <insert_merge>
ffffffffc0200e82:	fe0a10e3          	bnez	s4,ffffffffc0200e62 <buddy_init_memmap+0xfa>
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
ffffffffc0200ea0:	16b7b023          	sd	a1,352(a5) # 100160 <kern_entry-0xffffffffc00ffea0>
ffffffffc0200ea4:	b7b5                	j	ffffffffc0200e10 <buddy_init_memmap+0xa8>
ffffffffc0200ea6:	00002697          	auipc	a3,0x2
ffffffffc0200eaa:	5fa68693          	addi	a3,a3,1530 # ffffffffc02034a0 <etext+0x638>
ffffffffc0200eae:	00002617          	auipc	a2,0x2
ffffffffc0200eb2:	22260613          	addi	a2,a2,546 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200eb6:	04300593          	li	a1,67
ffffffffc0200eba:	00002517          	auipc	a0,0x2
ffffffffc0200ebe:	22e50513          	addi	a0,a0,558 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200ec2:	b00ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200ec6:	00002697          	auipc	a3,0x2
ffffffffc0200eca:	5a268693          	addi	a3,a3,1442 # ffffffffc0203468 <etext+0x600>
ffffffffc0200ece:	00002617          	auipc	a2,0x2
ffffffffc0200ed2:	20260613          	addi	a2,a2,514 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200ed6:	04100593          	li	a1,65
ffffffffc0200eda:	00002517          	auipc	a0,0x2
ffffffffc0200ede:	20e50513          	addi	a0,a0,526 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200ee2:	ae0ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200ee6:	00002697          	auipc	a3,0x2
ffffffffc0200eea:	57a68693          	addi	a3,a3,1402 # ffffffffc0203460 <etext+0x5f8>
ffffffffc0200eee:	00002617          	auipc	a2,0x2
ffffffffc0200ef2:	1e260613          	addi	a2,a2,482 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200ef6:	03f00593          	li	a1,63
ffffffffc0200efa:	00002517          	auipc	a0,0x2
ffffffffc0200efe:	1ee50513          	addi	a0,a0,494 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200f02:	ac0ff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0200f06 <expect_failure>:
ffffffffc0200f06:	1101                	addi	sp,sp,-32
ffffffffc0200f08:	e822                	sd	s0,16(sp)
ffffffffc0200f0a:	16800613          	li	a2,360
ffffffffc0200f0e:	842a                	mv	s0,a0
ffffffffc0200f10:	00007597          	auipc	a1,0x7
ffffffffc0200f14:	12858593          	addi	a1,a1,296 # ffffffffc0208038 <buddy>
ffffffffc0200f18:	00007517          	auipc	a0,0x7
ffffffffc0200f1c:	78850513          	addi	a0,a0,1928 # ffffffffc02086a0 <failure_state>
ffffffffc0200f20:	ec06                	sd	ra,24(sp)
ffffffffc0200f22:	e426                	sd	s1,8(sp)
ffffffffc0200f24:	709010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc0200f28:	00008497          	auipc	s1,0x8
ffffffffc0200f2c:	fc848493          	addi	s1,s1,-56 # ffffffffc0208ef0 <test_base>
ffffffffc0200f30:	608c                	ld	a1,0(s1)
ffffffffc0200f32:	50000613          	li	a2,1280
ffffffffc0200f36:	00007517          	auipc	a0,0x7
ffffffffc0200f3a:	26a50513          	addi	a0,a0,618 # ffffffffc02081a0 <failure_pages>
ffffffffc0200f3e:	6ef010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc0200f42:	8522                	mv	a0,s0
ffffffffc0200f44:	419000ef          	jal	ffffffffc0201b5c <alloc_pages>
ffffffffc0200f48:	ed0d                	bnez	a0,ffffffffc0200f82 <expect_failure+0x7c>
ffffffffc0200f4a:	16800613          	li	a2,360
ffffffffc0200f4e:	00007597          	auipc	a1,0x7
ffffffffc0200f52:	0ea58593          	addi	a1,a1,234 # ffffffffc0208038 <buddy>
ffffffffc0200f56:	00007517          	auipc	a0,0x7
ffffffffc0200f5a:	74a50513          	addi	a0,a0,1866 # ffffffffc02086a0 <failure_state>
ffffffffc0200f5e:	6e7010ef          	jal	ffffffffc0202e44 <memcmp>
ffffffffc0200f62:	e125                	bnez	a0,ffffffffc0200fc2 <expect_failure+0xbc>
ffffffffc0200f64:	608c                	ld	a1,0(s1)
ffffffffc0200f66:	50000613          	li	a2,1280
ffffffffc0200f6a:	00007517          	auipc	a0,0x7
ffffffffc0200f6e:	23650513          	addi	a0,a0,566 # ffffffffc02081a0 <failure_pages>
ffffffffc0200f72:	6d3010ef          	jal	ffffffffc0202e44 <memcmp>
ffffffffc0200f76:	e515                	bnez	a0,ffffffffc0200fa2 <expect_failure+0x9c>
ffffffffc0200f78:	6442                	ld	s0,16(sp)
ffffffffc0200f7a:	60e2                	ld	ra,24(sp)
ffffffffc0200f7c:	64a2                	ld	s1,8(sp)
ffffffffc0200f7e:	6105                	addi	sp,sp,32
ffffffffc0200f80:	bc45                	j	ffffffffc0200a30 <check_pool>
ffffffffc0200f82:	00002697          	auipc	a3,0x2
ffffffffc0200f86:	52e68693          	addi	a3,a3,1326 # ffffffffc02034b0 <etext+0x648>
ffffffffc0200f8a:	00002617          	auipc	a2,0x2
ffffffffc0200f8e:	14660613          	addi	a2,a2,326 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200f92:	0e300593          	li	a1,227
ffffffffc0200f96:	00002517          	auipc	a0,0x2
ffffffffc0200f9a:	15250513          	addi	a0,a0,338 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200f9e:	a24ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200fa2:	00002697          	auipc	a3,0x2
ffffffffc0200fa6:	55e68693          	addi	a3,a3,1374 # ffffffffc0203500 <etext+0x698>
ffffffffc0200faa:	00002617          	auipc	a2,0x2
ffffffffc0200fae:	12660613          	addi	a2,a2,294 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200fb2:	0e500593          	li	a1,229
ffffffffc0200fb6:	00002517          	auipc	a0,0x2
ffffffffc0200fba:	13250513          	addi	a0,a0,306 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200fbe:	a04ff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0200fc2:	00002697          	auipc	a3,0x2
ffffffffc0200fc6:	50668693          	addi	a3,a3,1286 # ffffffffc02034c8 <etext+0x660>
ffffffffc0200fca:	00002617          	auipc	a2,0x2
ffffffffc0200fce:	10660613          	addi	a2,a2,262 # ffffffffc02030d0 <etext+0x268>
ffffffffc0200fd2:	0e400593          	li	a1,228
ffffffffc0200fd6:	00002517          	auipc	a0,0x2
ffffffffc0200fda:	11250513          	addi	a0,a0,274 # ffffffffc02030e8 <etext+0x280>
ffffffffc0200fde:	9e4ff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0200fe2 <pool_free>:
ffffffffc0200fe2:	1141                	addi	sp,sp,-16
ffffffffc0200fe4:	e406                	sd	ra,8(sp)
ffffffffc0200fe6:	4785                	li	a5,1
ffffffffc0200fe8:	4805                	li	a6,1
ffffffffc0200fea:	00b7f563          	bgeu	a5,a1,ffffffffc0200ff4 <pool_free+0x12>
ffffffffc0200fee:	0806                	slli	a6,a6,0x1
ffffffffc0200ff0:	feb86fe3          	bltu	a6,a1,ffffffffc0200fee <pool_free+0xc>
ffffffffc0200ff4:	00008797          	auipc	a5,0x8
ffffffffc0200ff8:	efc7b783          	ld	a5,-260(a5) # ffffffffc0208ef0 <test_base>
ffffffffc0200ffc:	40f507b3          	sub	a5,a0,a5
ffffffffc0201000:	4037d893          	srai	a7,a5,0x3
ffffffffc0201004:	00003697          	auipc	a3,0x3
ffffffffc0201008:	1146b683          	ld	a3,276(a3) # ffffffffc0204118 <error_string+0x38>
ffffffffc020100c:	4d800713          	li	a4,1240
ffffffffc0201010:	02d888b3          	mul	a7,a7,a3
ffffffffc0201014:	04f76263          	bltu	a4,a5,ffffffffc0201058 <pool_free+0x76>
ffffffffc0201018:	00007797          	auipc	a5,0x7
ffffffffc020101c:	7f078793          	addi	a5,a5,2032 # ffffffffc0208808 <occupied>
ffffffffc0201020:	97c6                	add	a5,a5,a7
ffffffffc0201022:	862a                	mv	a2,a0
ffffffffc0201024:	4701                	li	a4,0
ffffffffc0201026:	430d                	li	t1,3
ffffffffc0201028:	4e7d                	li	t3,31
ffffffffc020102a:	a801                	j	ffffffffc020103a <pool_free+0x58>
ffffffffc020102c:	011706b3          	add	a3,a4,a7
ffffffffc0201030:	0785                	addi	a5,a5,1
ffffffffc0201032:	02860613          	addi	a2,a2,40
ffffffffc0201036:	02de6163          	bltu	t3,a3,ffffffffc0201058 <pool_free+0x76>
ffffffffc020103a:	0007c683          	lbu	a3,0(a5)
ffffffffc020103e:	ce89                	beqz	a3,ffffffffc0201058 <pool_free+0x76>
ffffffffc0201040:	00078023          	sb	zero,0(a5)
ffffffffc0201044:	00662023          	sw	t1,0(a2)
ffffffffc0201048:	0705                	addi	a4,a4,1
ffffffffc020104a:	ff0761e3          	bltu	a4,a6,ffffffffc020102c <pool_free+0x4a>
ffffffffc020104e:	31b000ef          	jal	ffffffffc0201b68 <free_pages>
ffffffffc0201052:	60a2                	ld	ra,8(sp)
ffffffffc0201054:	0141                	addi	sp,sp,16
ffffffffc0201056:	bae9                	j	ffffffffc0200a30 <check_pool>
ffffffffc0201058:	00002697          	auipc	a3,0x2
ffffffffc020105c:	4e868693          	addi	a3,a3,1256 # ffffffffc0203540 <etext+0x6d8>
ffffffffc0201060:	00002617          	auipc	a2,0x2
ffffffffc0201064:	07060613          	addi	a2,a2,112 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201068:	10400593          	li	a1,260
ffffffffc020106c:	00002517          	auipc	a0,0x2
ffffffffc0201070:	07c50513          	addi	a0,a0,124 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201074:	94eff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201078 <buddy_free_pages>:
ffffffffc0201078:	1141                	addi	sp,sp,-16
ffffffffc020107a:	e406                	sd	ra,8(sp)
ffffffffc020107c:	10058763          	beqz	a1,ffffffffc020118a <buddy_free_pages+0x112>
ffffffffc0201080:	fff58793          	addi	a5,a1,-1
ffffffffc0201084:	00100737          	lui	a4,0x100
ffffffffc0201088:	862e                	mv	a2,a1
ffffffffc020108a:	0ae7f063          	bgeu	a5,a4,ffffffffc020112a <buddy_free_pages+0xb2>
ffffffffc020108e:	4785                	li	a5,1
ffffffffc0201090:	4581                	li	a1,0
ffffffffc0201092:	00f60963          	beq	a2,a5,ffffffffc02010a4 <buddy_free_pages+0x2c>
ffffffffc0201096:	0786                	slli	a5,a5,0x1
ffffffffc0201098:	2585                	addiw	a1,a1,1
ffffffffc020109a:	fec7eee3          	bltu	a5,a2,ffffffffc0201096 <buddy_free_pages+0x1e>
ffffffffc020109e:	4605                	li	a2,1
ffffffffc02010a0:	00b61633          	sll	a2,a2,a1
ffffffffc02010a4:	00008797          	auipc	a5,0x8
ffffffffc02010a8:	e7c7b783          	ld	a5,-388(a5) # ffffffffc0208f20 <pages>
ffffffffc02010ac:	40f507b3          	sub	a5,a0,a5
ffffffffc02010b0:	00003717          	auipc	a4,0x3
ffffffffc02010b4:	06873703          	ld	a4,104(a4) # ffffffffc0204118 <error_string+0x38>
ffffffffc02010b8:	878d                	srai	a5,a5,0x3
ffffffffc02010ba:	02e787b3          	mul	a5,a5,a4
ffffffffc02010be:	00007817          	auipc	a6,0x7
ffffffffc02010c2:	f7a80813          	addi	a6,a6,-134 # ffffffffc0208038 <buddy>
ffffffffc02010c6:	15883703          	ld	a4,344(a6)
ffffffffc02010ca:	00003697          	auipc	a3,0x3
ffffffffc02010ce:	0666b683          	ld	a3,102(a3) # ffffffffc0204130 <nbase>
ffffffffc02010d2:	97b6                	add	a5,a5,a3
ffffffffc02010d4:	08e7eb63          	bltu	a5,a4,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010d8:	16083703          	ld	a4,352(a6)
ffffffffc02010dc:	08e7f763          	bgeu	a5,a4,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010e0:	8f1d                	sub	a4,a4,a5
ffffffffc02010e2:	08c76463          	bltu	a4,a2,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010e6:	fff60713          	addi	a4,a2,-1
ffffffffc02010ea:	8ff9                	and	a5,a5,a4
ffffffffc02010ec:	efbd                	bnez	a5,ffffffffc020116a <buddy_free_pages+0xf2>
ffffffffc02010ee:	02800693          	li	a3,40
ffffffffc02010f2:	00b696b3          	sll	a3,a3,a1
ffffffffc02010f6:	96aa                	add	a3,a3,a0
ffffffffc02010f8:	87aa                	mv	a5,a0
ffffffffc02010fa:	00d57f63          	bgeu	a0,a3,ffffffffc0201118 <buddy_free_pages+0xa0>
ffffffffc02010fe:	6798                	ld	a4,8(a5)
ffffffffc0201100:	8b0d                	andi	a4,a4,3
ffffffffc0201102:	e721                	bnez	a4,ffffffffc020114a <buddy_free_pages+0xd2>
ffffffffc0201104:	0007a823          	sw	zero,16(a5)
ffffffffc0201108:	0007b423          	sd	zero,8(a5)
ffffffffc020110c:	0007a023          	sw	zero,0(a5)
ffffffffc0201110:	02878793          	addi	a5,a5,40
ffffffffc0201114:	fed7e5e3          	bltu	a5,a3,ffffffffc02010fe <buddy_free_pages+0x86>
ffffffffc0201118:	15083783          	ld	a5,336(a6)
ffffffffc020111c:	60a2                	ld	ra,8(sp)
ffffffffc020111e:	97b2                	add	a5,a5,a2
ffffffffc0201120:	14f83823          	sd	a5,336(a6)
ffffffffc0201124:	0141                	addi	sp,sp,16
ffffffffc0201126:	d58ff06f          	j	ffffffffc020067e <insert_merge>
ffffffffc020112a:	00002697          	auipc	a3,0x2
ffffffffc020112e:	43668693          	addi	a3,a3,1078 # ffffffffc0203560 <etext+0x6f8>
ffffffffc0201132:	00002617          	auipc	a2,0x2
ffffffffc0201136:	f9e60613          	addi	a2,a2,-98 # ffffffffc02030d0 <etext+0x268>
ffffffffc020113a:	07000593          	li	a1,112
ffffffffc020113e:	00002517          	auipc	a0,0x2
ffffffffc0201142:	faa50513          	addi	a0,a0,-86 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201146:	87cff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020114a:	00002697          	auipc	a3,0x2
ffffffffc020114e:	48668693          	addi	a3,a3,1158 # ffffffffc02035d0 <etext+0x768>
ffffffffc0201152:	00002617          	auipc	a2,0x2
ffffffffc0201156:	f7e60613          	addi	a2,a2,-130 # ffffffffc02030d0 <etext+0x268>
ffffffffc020115a:	07600593          	li	a1,118
ffffffffc020115e:	00002517          	auipc	a0,0x2
ffffffffc0201162:	f8a50513          	addi	a0,a0,-118 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201166:	85cff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020116a:	00002697          	auipc	a3,0x2
ffffffffc020116e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0203568 <etext+0x700>
ffffffffc0201172:	00002617          	auipc	a2,0x2
ffffffffc0201176:	f5e60613          	addi	a2,a2,-162 # ffffffffc02030d0 <etext+0x268>
ffffffffc020117a:	07300593          	li	a1,115
ffffffffc020117e:	00002517          	auipc	a0,0x2
ffffffffc0201182:	f6a50513          	addi	a0,a0,-150 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201186:	83cff0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020118a:	00002697          	auipc	a3,0x2
ffffffffc020118e:	2d668693          	addi	a3,a3,726 # ffffffffc0203460 <etext+0x5f8>
ffffffffc0201192:	00002617          	auipc	a2,0x2
ffffffffc0201196:	f3e60613          	addi	a2,a2,-194 # ffffffffc02030d0 <etext+0x268>
ffffffffc020119a:	06e00593          	li	a1,110
ffffffffc020119e:	00002517          	auipc	a0,0x2
ffffffffc02011a2:	f4a50513          	addi	a0,a0,-182 # ffffffffc02030e8 <etext+0x280>
ffffffffc02011a6:	81cff0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc02011aa <buddy_alloc_pages>:
ffffffffc02011aa:	c971                	beqz	a0,ffffffffc020127e <buddy_alloc_pages+0xd4>
ffffffffc02011ac:	fff50793          	addi	a5,a0,-1
ffffffffc02011b0:	00100737          	lui	a4,0x100
ffffffffc02011b4:	882a                	mv	a6,a0
ffffffffc02011b6:	0ae7fe63          	bgeu	a5,a4,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc02011ba:	00007f17          	auipc	t5,0x7
ffffffffc02011be:	e7ef0f13          	addi	t5,t5,-386 # ffffffffc0208038 <buddy>
ffffffffc02011c2:	4785                	li	a5,1
ffffffffc02011c4:	150f3f83          	ld	t6,336(t5)
ffffffffc02011c8:	0af50763          	beq	a0,a5,ffffffffc0201276 <buddy_alloc_pages+0xcc>
ffffffffc02011cc:	4601                	li	a2,0
ffffffffc02011ce:	0786                	slli	a5,a5,0x1
ffffffffc02011d0:	2605                	addiw	a2,a2,1
ffffffffc02011d2:	ff07eee3          	bltu	a5,a6,ffffffffc02011ce <buddy_alloc_pages+0x24>
ffffffffc02011d6:	4805                	li	a6,1
ffffffffc02011d8:	00c81833          	sll	a6,a6,a2
ffffffffc02011dc:	090feb63          	bltu	t6,a6,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc02011e0:	47d1                	li	a5,20
ffffffffc02011e2:	08c7c863          	blt	a5,a2,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc02011e6:	00461713          	slli	a4,a2,0x4
ffffffffc02011ea:	977a                	add	a4,a4,t5
ffffffffc02011ec:	87b2                	mv	a5,a2
ffffffffc02011ee:	46d5                	li	a3,21
ffffffffc02011f0:	a029                	j	ffffffffc02011fa <buddy_alloc_pages+0x50>
ffffffffc02011f2:	2785                	addiw	a5,a5,1
ffffffffc02011f4:	0741                	addi	a4,a4,16 # 100010 <kern_entry-0xffffffffc00ffff0>
ffffffffc02011f6:	06d78e63          	beq	a5,a3,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc02011fa:	670c                	ld	a1,8(a4)
ffffffffc02011fc:	fee58be3          	beq	a1,a4,ffffffffc02011f2 <buddy_alloc_pages+0x48>
ffffffffc0201200:	6588                	ld	a0,8(a1)
ffffffffc0201202:	0005b883          	ld	a7,0(a1)
ffffffffc0201206:	ff05b703          	ld	a4,-16(a1)
ffffffffc020120a:	fff78693          	addi	a3,a5,-1
ffffffffc020120e:	00a8b423          	sd	a0,8(a7)
ffffffffc0201212:	01153023          	sd	a7,0(a0)
ffffffffc0201216:	9b75                	andi	a4,a4,-3
ffffffffc0201218:	0692                	slli	a3,a3,0x4
ffffffffc020121a:	e58c                	sd	a1,8(a1)
ffffffffc020121c:	e18c                	sd	a1,0(a1)
ffffffffc020121e:	fee5b823          	sd	a4,-16(a1)
ffffffffc0201222:	fe05ac23          	sw	zero,-8(a1)
ffffffffc0201226:	fe858513          	addi	a0,a1,-24
ffffffffc020122a:	96fa                	add	a3,a3,t5
ffffffffc020122c:	02800e93          	li	t4,40
ffffffffc0201230:	4e05                	li	t3,1
ffffffffc0201232:	02f65b63          	bge	a2,a5,ffffffffc0201268 <buddy_alloc_pages+0xbe>
ffffffffc0201236:	37fd                	addiw	a5,a5,-1
ffffffffc0201238:	00fe9733          	sll	a4,t4,a5
ffffffffc020123c:	972a                	add	a4,a4,a0
ffffffffc020123e:	670c                	ld	a1,8(a4)
ffffffffc0201240:	0086b883          	ld	a7,8(a3)
ffffffffc0201244:	00fe1333          	sll	t1,t3,a5
ffffffffc0201248:	0025e593          	ori	a1,a1,2
ffffffffc020124c:	e70c                	sd	a1,8(a4)
ffffffffc020124e:	00672823          	sw	t1,16(a4)
ffffffffc0201252:	01870593          	addi	a1,a4,24
ffffffffc0201256:	00b8b023          	sd	a1,0(a7)
ffffffffc020125a:	e68c                	sd	a1,8(a3)
ffffffffc020125c:	ef14                	sd	a3,24(a4)
ffffffffc020125e:	03173023          	sd	a7,32(a4)
ffffffffc0201262:	16c1                	addi	a3,a3,-16
ffffffffc0201264:	fcc799e3          	bne	a5,a2,ffffffffc0201236 <buddy_alloc_pages+0x8c>
ffffffffc0201268:	410f8833          	sub	a6,t6,a6
ffffffffc020126c:	150f3823          	sd	a6,336(t5)
ffffffffc0201270:	8082                	ret
ffffffffc0201272:	4501                	li	a0,0
ffffffffc0201274:	8082                	ret
ffffffffc0201276:	fe0f8ee3          	beqz	t6,ffffffffc0201272 <buddy_alloc_pages+0xc8>
ffffffffc020127a:	4601                	li	a2,0
ffffffffc020127c:	b7ad                	j	ffffffffc02011e6 <buddy_alloc_pages+0x3c>
ffffffffc020127e:	1141                	addi	sp,sp,-16
ffffffffc0201280:	00002697          	auipc	a3,0x2
ffffffffc0201284:	1e068693          	addi	a3,a3,480 # ffffffffc0203460 <etext+0x5f8>
ffffffffc0201288:	00002617          	auipc	a2,0x2
ffffffffc020128c:	e4860613          	addi	a2,a2,-440 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201290:	05700593          	li	a1,87
ffffffffc0201294:	00002517          	auipc	a0,0x2
ffffffffc0201298:	e5450513          	addi	a0,a0,-428 # ffffffffc02030e8 <etext+0x280>
ffffffffc020129c:	e406                	sd	ra,8(sp)
ffffffffc020129e:	f25fe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc02012a2 <pool_reset>:
ffffffffc02012a2:	1141                	addi	sp,sp,-16
ffffffffc02012a4:	00007697          	auipc	a3,0x7
ffffffffc02012a8:	d9468693          	addi	a3,a3,-620 # ffffffffc0208038 <buddy>
ffffffffc02012ac:	e406                	sd	ra,8(sp)
ffffffffc02012ae:	87b6                	mv	a5,a3
ffffffffc02012b0:	00007717          	auipc	a4,0x7
ffffffffc02012b4:	ed870713          	addi	a4,a4,-296 # ffffffffc0208188 <buddy+0x150>
ffffffffc02012b8:	e79c                	sd	a5,8(a5)
ffffffffc02012ba:	e39c                	sd	a5,0(a5)
ffffffffc02012bc:	07c1                	addi	a5,a5,16
ffffffffc02012be:	fee79de3          	bne	a5,a4,ffffffffc02012b8 <pool_reset+0x16>
ffffffffc02012c2:	00007797          	auipc	a5,0x7
ffffffffc02012c6:	ec07b323          	sd	zero,-314(a5) # ffffffffc0208188 <buddy+0x150>
ffffffffc02012ca:	00008797          	auipc	a5,0x8
ffffffffc02012ce:	c4e7b783          	ld	a5,-946(a5) # ffffffffc0208f18 <npage>
ffffffffc02012d2:	14f6bc23          	sd	a5,344(a3)
ffffffffc02012d6:	02000613          	li	a2,32
ffffffffc02012da:	00003797          	auipc	a5,0x3
ffffffffc02012de:	e567b783          	ld	a5,-426(a5) # ffffffffc0204130 <nbase>
ffffffffc02012e2:	4581                	li	a1,0
ffffffffc02012e4:	00007517          	auipc	a0,0x7
ffffffffc02012e8:	d3450513          	addi	a0,a0,-716 # ffffffffc0208018 <allowed>
ffffffffc02012ec:	16f6b023          	sd	a5,352(a3)
ffffffffc02012f0:	32b010ef          	jal	ffffffffc0202e1a <memset>
ffffffffc02012f4:	02000613          	li	a2,32
ffffffffc02012f8:	4581                	li	a1,0
ffffffffc02012fa:	00007517          	auipc	a0,0x7
ffffffffc02012fe:	50e50513          	addi	a0,a0,1294 # ffffffffc0208808 <occupied>
ffffffffc0201302:	319010ef          	jal	ffffffffc0202e1a <memset>
ffffffffc0201306:	00008797          	auipc	a5,0x8
ffffffffc020130a:	bea7b783          	ld	a5,-1046(a5) # ffffffffc0208ef0 <test_base>
ffffffffc020130e:	50078613          	addi	a2,a5,1280
ffffffffc0201312:	469d                	li	a3,7
ffffffffc0201314:	4705                	li	a4,1
ffffffffc0201316:	0007a823          	sw	zero,16(a5)
ffffffffc020131a:	c394                	sw	a3,0(a5)
ffffffffc020131c:	e798                	sd	a4,8(a5)
ffffffffc020131e:	02878793          	addi	a5,a5,40
ffffffffc0201322:	fef61ae3          	bne	a2,a5,ffffffffc0201316 <pool_reset+0x74>
ffffffffc0201326:	60a2                	ld	ra,8(sp)
ffffffffc0201328:	0141                	addi	sp,sp,16
ffffffffc020132a:	8082                	ret

ffffffffc020132c <buddy_check>:
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
ffffffffc0201348:	c0cff0ef          	jal	ffffffffc0200754 <check_consistency>
ffffffffc020134c:	029000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0201350:	87aa                	mv	a5,a0
ffffffffc0201352:	02000513          	li	a0,32
ffffffffc0201356:	ec3e                	sd	a5,24(sp)
ffffffffc0201358:	00008a97          	auipc	s5,0x8
ffffffffc020135c:	b98a8a93          	addi	s5,s5,-1128 # ffffffffc0208ef0 <test_base>
ffffffffc0201360:	7fc000ef          	jal	ffffffffc0201b5c <alloc_pages>
ffffffffc0201364:	00aab023          	sd	a0,0(s5)
ffffffffc0201368:	60050a63          	beqz	a0,ffffffffc020197c <buddy_check+0x650>
ffffffffc020136c:	009000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0201370:	67e2                	ld	a5,24(sp)
ffffffffc0201372:	1781                	addi	a5,a5,-32
ffffffffc0201374:	60f51463          	bne	a0,a5,ffffffffc020197c <buddy_check+0x650>
ffffffffc0201378:	16800613          	li	a2,360
ffffffffc020137c:	00007597          	auipc	a1,0x7
ffffffffc0201380:	cbc58593          	addi	a1,a1,-836 # ffffffffc0208038 <buddy>
ffffffffc0201384:	00008517          	auipc	a0,0x8
ffffffffc0201388:	9a450513          	addi	a0,a0,-1628 # ffffffffc0208d28 <saved_state>
ffffffffc020138c:	2a1010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc0201390:	000ab583          	ld	a1,0(s5)
ffffffffc0201394:	50000613          	li	a2,1280
ffffffffc0201398:	00007517          	auipc	a0,0x7
ffffffffc020139c:	49050513          	addi	a0,a0,1168 # ffffffffc0208828 <saved_pages>
ffffffffc02013a0:	28d010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc02013a4:	effff0ef          	jal	ffffffffc02012a2 <pool_reset>
ffffffffc02013a8:	4505                	li	a0,1
ffffffffc02013aa:	b5dff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02013ae:	000ab503          	ld	a0,0(s5)
ffffffffc02013b2:	02000593          	li	a1,32
ffffffffc02013b6:	00007417          	auipc	s0,0x7
ffffffffc02013ba:	c6240413          	addi	s0,s0,-926 # ffffffffc0208018 <allowed>
ffffffffc02013be:	9abff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc02013c2:	00007917          	auipc	s2,0x7
ffffffffc02013c6:	c7690913          	addi	s2,s2,-906 # ffffffffc0208038 <buddy>
ffffffffc02013ca:	8c22                	mv	s8,s0
ffffffffc02013cc:	87a2                	mv	a5,s0
ffffffffc02013ce:	4705                	li	a4,1
ffffffffc02013d0:	00e78023          	sb	a4,0(a5)
ffffffffc02013d4:	0785                	addi	a5,a5,1
ffffffffc02013d6:	ff279de3          	bne	a5,s2,ffffffffc02013d0 <buddy_check+0xa4>
ffffffffc02013da:	e56ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc02013de:	00003797          	auipc	a5,0x3
ffffffffc02013e2:	a0a78793          	addi	a5,a5,-1526 # ffffffffc0203de8 <etext+0xf80>
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
ffffffffc02013fa:	7da2                	ld	s11,40(sp)
ffffffffc02013fc:	05010c93          	addi	s9,sp,80
ffffffffc0201400:	8a66                	mv	s4,s9
ffffffffc0201402:	856e                	mv	a0,s11
ffffffffc0201404:	feaff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc0201408:	00aa3023          	sd	a0,0(s4)
ffffffffc020140c:	02810b13          	addi	s6,sp,40
ffffffffc0201410:	4b85                	li	s7,1
ffffffffc0201412:	4481                	li	s1,0
ffffffffc0201414:	4981                	li	s3,0
ffffffffc0201416:	4d0d                	li	s10,3
ffffffffc0201418:	c121                	beqz	a0,ffffffffc0201458 <buddy_check+0x12c>
ffffffffc020141a:	0004871b          	sext.w	a4,s1
ffffffffc020141e:	05a48d63          	beq	s1,s10,ffffffffc0201478 <buddy_check+0x14c>
ffffffffc0201422:	4791                	li	a5,4
ffffffffc0201424:	50f70a63          	beq	a4,a5,ffffffffc0201938 <buddy_check+0x60c>
ffffffffc0201428:	74c000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc020142c:	99ee                	add	s3,s3,s11
ffffffffc020142e:	02000793          	li	a5,32
ffffffffc0201432:	413787b3          	sub	a5,a5,s3
ffffffffc0201436:	04f51a63          	bne	a0,a5,ffffffffc020148a <buddy_check+0x15e>
ffffffffc020143a:	4795                	li	a5,5
ffffffffc020143c:	06fb8763          	beq	s7,a5,ffffffffc02014aa <buddy_check+0x17e>
ffffffffc0201440:	008b3d83          	ld	s11,8(s6)
ffffffffc0201444:	0a21                	addi	s4,s4,8
ffffffffc0201446:	0b21                	addi	s6,s6,8
ffffffffc0201448:	856e                	mv	a0,s11
ffffffffc020144a:	fa4ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc020144e:	00aa3023          	sd	a0,0(s4)
ffffffffc0201452:	0485                	addi	s1,s1,1
ffffffffc0201454:	2b85                	addiw	s7,s7,1
ffffffffc0201456:	f171                	bnez	a0,ffffffffc020141a <buddy_check+0xee>
ffffffffc0201458:	00002697          	auipc	a3,0x2
ffffffffc020145c:	1e068693          	addi	a3,a3,480 # ffffffffc0203638 <etext+0x7d0>
ffffffffc0201460:	00002617          	auipc	a2,0x2
ffffffffc0201464:	c7060613          	addi	a2,a2,-912 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201468:	11d00593          	li	a1,285
ffffffffc020146c:	00002517          	auipc	a0,0x2
ffffffffc0201470:	c7c50513          	addi	a0,a0,-900 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201474:	d4ffe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201478:	6fc000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc020147c:	0991                	addi	s3,s3,4
ffffffffc020147e:	02000793          	li	a5,32
ffffffffc0201482:	413787b3          	sub	a5,a5,s3
ffffffffc0201486:	faa78de3          	beq	a5,a0,ffffffffc0201440 <buddy_check+0x114>
ffffffffc020148a:	00002697          	auipc	a3,0x2
ffffffffc020148e:	1c668693          	addi	a3,a3,454 # ffffffffc0203650 <etext+0x7e8>
ffffffffc0201492:	00002617          	auipc	a2,0x2
ffffffffc0201496:	c3e60613          	addi	a2,a2,-962 # ffffffffc02030d0 <etext+0x268>
ffffffffc020149a:	11f00593          	li	a1,287
ffffffffc020149e:	00002517          	auipc	a0,0x2
ffffffffc02014a2:	c4a50513          	addi	a0,a0,-950 # ffffffffc02030e8 <etext+0x280>
ffffffffc02014a6:	d1dfe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02014aa:	1884                	addi	s1,sp,112
ffffffffc02014ac:	04810993          	addi	s3,sp,72
ffffffffc02014b0:	0009b583          	ld	a1,0(s3)
ffffffffc02014b4:	6088                	ld	a0,0(s1)
ffffffffc02014b6:	19e1                	addi	s3,s3,-8
ffffffffc02014b8:	b2bff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc02014bc:	87a6                	mv	a5,s1
ffffffffc02014be:	14e1                	addi	s1,s1,-8
ffffffffc02014c0:	ff9798e3          	bne	a5,s9,ffffffffc02014b0 <buddy_check+0x184>
ffffffffc02014c4:	6b0000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02014c8:	02000793          	li	a5,32
ffffffffc02014cc:	48f51863          	bne	a0,a5,ffffffffc020195c <buddy_check+0x630>
ffffffffc02014d0:	02100513          	li	a0,33
ffffffffc02014d4:	a33ff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02014d8:	00100537          	lui	a0,0x100
ffffffffc02014dc:	0505                	addi	a0,a0,1 # 100001 <kern_entry-0xffffffffc00fffff>
ffffffffc02014de:	a29ff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02014e2:	557d                	li	a0,-1
ffffffffc02014e4:	a23ff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02014e8:	557d                	li	a0,-1
ffffffffc02014ea:	157e                	slli	a0,a0,0x3f
ffffffffc02014ec:	a1bff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02014f0:	4481                	li	s1,0
ffffffffc02014f2:	00003c97          	auipc	s9,0x3
ffffffffc02014f6:	c2ec8c93          	addi	s9,s9,-978 # ffffffffc0204120 <error_string+0x40>
ffffffffc02014fa:	13810b13          	addi	s6,sp,312
ffffffffc02014fe:	17810a13          	addi	s4,sp,376
ffffffffc0201502:	4b9d                	li	s7,7
ffffffffc0201504:	d9fff0ef          	jal	ffffffffc02012a2 <pool_reset>
ffffffffc0201508:	000ab503          	ld	a0,0(s5)
ffffffffc020150c:	45a1                	li	a1,8
ffffffffc020150e:	89da                	mv	s3,s6
ffffffffc0201510:	859ff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201514:	000cb783          	ld	a5,0(s9)
ffffffffc0201518:	00fc3023          	sd	a5,0(s8)
ffffffffc020151c:	d14ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201520:	4505                	li	a0,1
ffffffffc0201522:	eccff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc0201526:	00a9b023          	sd	a0,0(s3)
ffffffffc020152a:	40050963          	beqz	a0,ffffffffc020193c <buddy_check+0x610>
ffffffffc020152e:	09a1                	addi	s3,s3,8
ffffffffc0201530:	ff4998e3          	bne	s3,s4,ffffffffc0201520 <buddy_check+0x1f4>
ffffffffc0201534:	4505                	li	a0,1
ffffffffc0201536:	9d1ff0ef          	jal	ffffffffc0200f06 <expect_failure>
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
ffffffffc0201554:	a8fff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201558:	ff3d13e3          	bne	s10,s3,ffffffffc020153e <buddy_check+0x212>
ffffffffc020155c:	4521                	li	a0,8
ffffffffc020155e:	e90ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc0201562:	000ab783          	ld	a5,0(s5)
ffffffffc0201566:	5ca79b63          	bne	a5,a0,ffffffffc0201b3c <buddy_check+0x810>
ffffffffc020156a:	45a1                	li	a1,8
ffffffffc020156c:	a77ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201570:	3c048263          	beqz	s1,ffffffffc0201934 <buddy_check+0x608>
ffffffffc0201574:	d2fff0ef          	jal	ffffffffc02012a2 <pool_reset>
ffffffffc0201578:	000ab503          	ld	a0,0(s5)
ffffffffc020157c:	45a1                	li	a1,8
ffffffffc020157e:	49a1                	li	s3,8
ffffffffc0201580:	fe8ff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201584:	000cb783          	ld	a5,0(s9)
ffffffffc0201588:	00fc3023          	sd	a5,0(s8)
ffffffffc020158c:	ca4ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201590:	fc82                	sd	zero,120(sp)
ffffffffc0201592:	e102                	sd	zero,128(sp)
ffffffffc0201594:	e502                	sd	zero,136(sp)
ffffffffc0201596:	e902                	sd	zero,144(sp)
ffffffffc0201598:	ed02                	sd	zero,152(sp)
ffffffffc020159a:	f102                	sd	zero,160(sp)
ffffffffc020159c:	f502                	sd	zero,168(sp)
ffffffffc020159e:	f902                	sd	zero,176(sp)
ffffffffc02015a0:	00003497          	auipc	s1,0x3
ffffffffc02015a4:	b784b483          	ld	s1,-1160(s1) # ffffffffc0204118 <error_string+0x38>
ffffffffc02015a8:	4505                	li	a0,1
ffffffffc02015aa:	e44ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc02015ae:	56050763          	beqz	a0,ffffffffc0201b1c <buddy_check+0x7f0>
ffffffffc02015b2:	000ab783          	ld	a5,0(s5)
ffffffffc02015b6:	0b18                	addi	a4,sp,400
ffffffffc02015b8:	39fd                	addiw	s3,s3,-1
ffffffffc02015ba:	40f507b3          	sub	a5,a0,a5
ffffffffc02015be:	878d                	srai	a5,a5,0x3
ffffffffc02015c0:	029787b3          	mul	a5,a5,s1
ffffffffc02015c4:	078e                	slli	a5,a5,0x3
ffffffffc02015c6:	97ba                	add	a5,a5,a4
ffffffffc02015c8:	eea7b423          	sd	a0,-280(a5)
ffffffffc02015cc:	fc099ee3          	bnez	s3,ffffffffc02015a8 <buddy_check+0x27c>
ffffffffc02015d0:	650a                	ld	a0,128(sp)
ffffffffc02015d2:	4585                	li	a1,1
ffffffffc02015d4:	a0fff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc02015d8:	652a                	ld	a0,136(sp)
ffffffffc02015da:	4585                	li	a1,1
ffffffffc02015dc:	a07ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc02015e0:	594000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02015e4:	4789                	li	a5,2
ffffffffc02015e6:	50f51b63          	bne	a0,a5,ffffffffc0201afc <buddy_check+0x7d0>
ffffffffc02015ea:	91dff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02015ee:	7566                	ld	a0,120(sp)
ffffffffc02015f0:	4585                	li	a1,1
ffffffffc02015f2:	9f1ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc02015f6:	4509                	li	a0,2
ffffffffc02015f8:	df6ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc02015fc:	000ab783          	ld	a5,0(s5)
ffffffffc0201600:	4ca79e63          	bne	a5,a0,ffffffffc0201adc <buddy_check+0x7b0>
ffffffffc0201604:	4589                	li	a1,2
ffffffffc0201606:	9ddff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc020160a:	0904                	addi	s1,sp,144
ffffffffc020160c:	6088                	ld	a0,0(s1)
ffffffffc020160e:	4585                	li	a1,1
ffffffffc0201610:	04a1                	addi	s1,s1,8
ffffffffc0201612:	9d1ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201616:	193c                	addi	a5,sp,184
ffffffffc0201618:	fe979ae3          	bne	a5,s1,ffffffffc020160c <buddy_check+0x2e0>
ffffffffc020161c:	4521                	li	a0,8
ffffffffc020161e:	dd0ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc0201622:	000ab783          	ld	a5,0(s5)
ffffffffc0201626:	48a79b63          	bne	a5,a0,ffffffffc0201abc <buddy_check+0x790>
ffffffffc020162a:	45a1                	li	a1,8
ffffffffc020162c:	9b7ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201630:	c73ff0ef          	jal	ffffffffc02012a2 <pool_reset>
ffffffffc0201634:	000ab503          	ld	a0,0(s5)
ffffffffc0201638:	10100993          	li	s3,257
ffffffffc020163c:	4595                	li	a1,5
ffffffffc020163e:	02850513          	addi	a0,a0,40
ffffffffc0201642:	4a05                	li	s4,1
ffffffffc0201644:	f24ff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201648:	013c1123          	sh	s3,2(s8)
ffffffffc020164c:	013c1223          	sh	s3,4(s8)
ffffffffc0201650:	014c00a3          	sb	s4,1(s8)
ffffffffc0201654:	bdcff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201658:	000ab503          	ld	a0,0(s5)
ffffffffc020165c:	4585                	li	a1,1
ffffffffc020165e:	84da                	mv	s1,s6
ffffffffc0201660:	16850513          	addi	a0,a0,360
ffffffffc0201664:	f04ff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201668:	014c04a3          	sb	s4,9(s8)
ffffffffc020166c:	bc4ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201670:	000ab503          	ld	a0,0(s5)
ffffffffc0201674:	4589                	li	a1,2
ffffffffc0201676:	2d050513          	addi	a0,a0,720
ffffffffc020167a:	eeeff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc020167e:	013c1923          	sh	s3,18(s8)
ffffffffc0201682:	baeff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201686:	000ab503          	ld	a0,0(s5)
ffffffffc020168a:	4589                	li	a1,2
ffffffffc020168c:	28050513          	addi	a0,a0,640
ffffffffc0201690:	ed8ff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201694:	013c1823          	sh	s3,16(s8)
ffffffffc0201698:	b98ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc020169c:	000ab503          	ld	a0,0(s5)
ffffffffc02016a0:	4585                	li	a1,1
ffffffffc02016a2:	19010993          	addi	s3,sp,400
ffffffffc02016a6:	4d850513          	addi	a0,a0,1240
ffffffffc02016aa:	ebeff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc02016ae:	014c0fa3          	sb	s4,31(s8)
ffffffffc02016b2:	b7eff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc02016b6:	4505                	li	a0,1
ffffffffc02016b8:	d36ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc02016bc:	e088                	sd	a0,0(s1)
ffffffffc02016be:	3c050f63          	beqz	a0,ffffffffc0201a9c <buddy_check+0x770>
ffffffffc02016c2:	04a1                	addi	s1,s1,8
ffffffffc02016c4:	fe9999e3          	bne	s3,s1,ffffffffc02016b6 <buddy_check+0x38a>
ffffffffc02016c8:	4505                	li	a0,1
ffffffffc02016ca:	83dff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02016ce:	0324                	addi	s1,sp,392
ffffffffc02016d0:	6088                	ld	a0,0(s1)
ffffffffc02016d2:	4585                	li	a1,1
ffffffffc02016d4:	90fff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc02016d8:	87a6                	mv	a5,s1
ffffffffc02016da:	14e1                	addi	s1,s1,-8
ffffffffc02016dc:	fefb1ae3          	bne	s6,a5,ffffffffc02016d0 <buddy_check+0x3a4>
ffffffffc02016e0:	494000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02016e4:	47ad                	li	a5,11
ffffffffc02016e6:	38f51b63          	bne	a0,a5,ffffffffc0201a7c <buddy_check+0x750>
ffffffffc02016ea:	4521                	li	a0,8
ffffffffc02016ec:	81bff0ef          	jal	ffffffffc0200f06 <expect_failure>
ffffffffc02016f0:	bb3ff0ef          	jal	ffffffffc02012a2 <pool_reset>
ffffffffc02016f4:	000ab503          	ld	a0,0(s5)
ffffffffc02016f8:	02000593          	li	a1,32
ffffffffc02016fc:	e6cff0ef          	jal	ffffffffc0200d68 <buddy_init_memmap>
ffffffffc0201700:	4785                	li	a5,1
ffffffffc0201702:	00f40023          	sb	a5,0(s0)
ffffffffc0201706:	0405                	addi	s0,s0,1
ffffffffc0201708:	ff241de3          	bne	s0,s2,ffffffffc0201702 <buddy_check+0x3d6>
ffffffffc020170c:	b24ff0ef          	jal	ffffffffc0200a30 <check_pool>
ffffffffc0201710:	013584b7          	lui	s1,0x1358
ffffffffc0201714:	001969b7          	lui	s3,0x196
ffffffffc0201718:	3c6ef937          	lui	s2,0x3c6ef
ffffffffc020171c:	fd02                	sd	zero,184(sp)
ffffffffc020171e:	e182                	sd	zero,192(sp)
ffffffffc0201720:	e582                	sd	zero,200(sp)
ffffffffc0201722:	e982                	sd	zero,208(sp)
ffffffffc0201724:	ed82                	sd	zero,216(sp)
ffffffffc0201726:	f182                	sd	zero,224(sp)
ffffffffc0201728:	f582                	sd	zero,232(sp)
ffffffffc020172a:	f982                	sd	zero,240(sp)
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
ffffffffc0201742:	4a01                	li	s4,0
ffffffffc0201744:	e802                	sd	zero,16(sp)
ffffffffc0201746:	e402                	sd	zero,8(sp)
ffffffffc0201748:	9bd48493          	addi	s1,s1,-1603 # 13579bd <kern_entry-0xffffffffbeea8643>
ffffffffc020174c:	60d9899b          	addiw	s3,s3,1549 # 19660d <kern_entry-0xffffffffc00699f3>
ffffffffc0201750:	35f9091b          	addiw	s2,s2,863 # 3c6ef35f <kern_entry-0xffffffff83b10ca1>
ffffffffc0201754:	00007c97          	auipc	s9,0x7
ffffffffc0201758:	8e4c8c93          	addi	s9,s9,-1820 # ffffffffc0208038 <buddy>
ffffffffc020175c:	00007c17          	auipc	s8,0x7
ffffffffc0201760:	f44c0c13          	addi	s8,s8,-188 # ffffffffc02086a0 <failure_state>
ffffffffc0201764:	00007b97          	auipc	s7,0x7
ffffffffc0201768:	a3cb8b93          	addi	s7,s7,-1476 # ffffffffc02081a0 <failure_pages>
ffffffffc020176c:	a81d                	j	ffffffffc02017a2 <buddy_check+0x476>
ffffffffc020176e:	0b1c                	addi	a5,sp,400
ffffffffc0201770:	003b1413          	slli	s0,s6,0x3
ffffffffc0201774:	943e                	add	s0,s0,a5
ffffffffc0201776:	f6843583          	ld	a1,-152(s0)
ffffffffc020177a:	2a05                	addiw	s4,s4,1
ffffffffc020177c:	867ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201780:	f2043423          	sd	zero,-216(s0)
ffffffffc0201784:	3dfd                	addiw	s11,s11,-1
ffffffffc0201786:	080d8063          	beqz	s11,ffffffffc0201806 <buddy_check+0x4da>
ffffffffc020178a:	033d07bb          	mulw	a5,s10,s3
ffffffffc020178e:	0b18                	addi	a4,sp,400
ffffffffc0201790:	012787bb          	addw	a5,a5,s2
ffffffffc0201794:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0201798:	8b9d                	andi	a5,a5,7
ffffffffc020179a:	078e                	slli	a5,a5,0x3
ffffffffc020179c:	97ba                	add	a5,a5,a4
ffffffffc020179e:	f287b503          	ld	a0,-216(a5)
ffffffffc02017a2:	033487bb          	mulw	a5,s1,s3
ffffffffc02017a6:	012784bb          	addw	s1,a5,s2
ffffffffc02017aa:	0104d71b          	srliw	a4,s1,0x10
ffffffffc02017ae:	8d26                	mv	s10,s1
ffffffffc02017b0:	00777b13          	andi	s6,a4,7
ffffffffc02017b4:	fd4d                	bnez	a0,ffffffffc020176e <buddy_check+0x442>
ffffffffc02017b6:	47a5                	li	a5,9
ffffffffc02017b8:	0084d41b          	srliw	s0,s1,0x8
ffffffffc02017bc:	02f4743b          	remuw	s0,s0,a5
ffffffffc02017c0:	16800613          	li	a2,360
ffffffffc02017c4:	85e6                	mv	a1,s9
ffffffffc02017c6:	8562                	mv	a0,s8
ffffffffc02017c8:	664010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc02017cc:	000ab583          	ld	a1,0(s5)
ffffffffc02017d0:	50000613          	li	a2,1280
ffffffffc02017d4:	855e                	mv	a0,s7
ffffffffc02017d6:	656010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc02017da:	2405                	addiw	s0,s0,1
ffffffffc02017dc:	1402                	slli	s0,s0,0x20
ffffffffc02017de:	9001                	srli	s0,s0,0x20
ffffffffc02017e0:	8522                	mv	a0,s0
ffffffffc02017e2:	c0cff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc02017e6:	003b1713          	slli	a4,s6,0x3
ffffffffc02017ea:	0b1c                	addi	a5,sp,400
ffffffffc02017ec:	973e                	add	a4,a4,a5
ffffffffc02017ee:	f2a73423          	sd	a0,-216(a4)
ffffffffc02017f2:	f6873423          	sd	s0,-152(a4)
ffffffffc02017f6:	0e050b63          	beqz	a0,ffffffffc02018ec <buddy_check+0x5c0>
ffffffffc02017fa:	67a2                	ld	a5,8(sp)
ffffffffc02017fc:	3dfd                	addiw	s11,s11,-1
ffffffffc02017fe:	2785                	addiw	a5,a5,1
ffffffffc0201800:	e43e                	sd	a5,8(sp)
ffffffffc0201802:	f80d94e3          	bnez	s11,ffffffffc020178a <buddy_check+0x45e>
ffffffffc0201806:	67a2                	ld	a5,8(sp)
ffffffffc0201808:	22078a63          	beqz	a5,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc020180c:	67c2                	ld	a5,16(sp)
ffffffffc020180e:	22078763          	beqz	a5,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc0201812:	220a0563          	beqz	s4,ffffffffc0201a3c <buddy_check+0x710>
ffffffffc0201816:	19a4                	addi	s1,sp,248
ffffffffc0201818:	1920                	addi	s0,sp,184
ffffffffc020181a:	8926                	mv	s2,s1
ffffffffc020181c:	6008                	ld	a0,0(s0)
ffffffffc020181e:	c501                	beqz	a0,ffffffffc0201826 <buddy_check+0x4fa>
ffffffffc0201820:	608c                	ld	a1,0(s1)
ffffffffc0201822:	fc0ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc0201826:	0421                	addi	s0,s0,8
ffffffffc0201828:	04a1                	addi	s1,s1,8
ffffffffc020182a:	fe8919e3          	bne	s2,s0,ffffffffc020181c <buddy_check+0x4f0>
ffffffffc020182e:	346000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0201832:	02000793          	li	a5,32
ffffffffc0201836:	1ef51363          	bne	a0,a5,ffffffffc0201a1c <buddy_check+0x6f0>
ffffffffc020183a:	bb4ff0ef          	jal	ffffffffc0200bee <pool_alloc>
ffffffffc020183e:	000ab783          	ld	a5,0(s5)
ffffffffc0201842:	1aa79d63          	bne	a5,a0,ffffffffc02019fc <buddy_check+0x6d0>
ffffffffc0201846:	02000593          	li	a1,32
ffffffffc020184a:	f98ff0ef          	jal	ffffffffc0200fe2 <pool_free>
ffffffffc020184e:	000ab503          	ld	a0,0(s5)
ffffffffc0201852:	50000613          	li	a2,1280
ffffffffc0201856:	00007597          	auipc	a1,0x7
ffffffffc020185a:	fd258593          	addi	a1,a1,-46 # ffffffffc0208828 <saved_pages>
ffffffffc020185e:	5ce010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc0201862:	16800613          	li	a2,360
ffffffffc0201866:	00007597          	auipc	a1,0x7
ffffffffc020186a:	4c258593          	addi	a1,a1,1218 # ffffffffc0208d28 <saved_state>
ffffffffc020186e:	00006517          	auipc	a0,0x6
ffffffffc0201872:	7ca50513          	addi	a0,a0,1994 # ffffffffc0208038 <buddy>
ffffffffc0201876:	5b6010ef          	jal	ffffffffc0202e2c <memcpy>
ffffffffc020187a:	000ab503          	ld	a0,0(s5)
ffffffffc020187e:	02000593          	li	a1,32
ffffffffc0201882:	2e6000ef          	jal	ffffffffc0201b68 <free_pages>
ffffffffc0201886:	2ee000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc020188a:	67e2                	ld	a5,24(sp)
ffffffffc020188c:	14f51863          	bne	a0,a5,ffffffffc02019dc <buddy_check+0x6b0>
ffffffffc0201890:	ec5fe0ef          	jal	ffffffffc0200754 <check_consistency>
ffffffffc0201894:	450d                	li	a0,3
ffffffffc0201896:	2c6000ef          	jal	ffffffffc0201b5c <alloc_pages>
ffffffffc020189a:	842a                	mv	s0,a0
ffffffffc020189c:	12050063          	beqz	a0,ffffffffc02019bc <buddy_check+0x690>
ffffffffc02018a0:	2d4000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02018a4:	64e2                	ld	s1,24(sp)
ffffffffc02018a6:	ffc48793          	addi	a5,s1,-4
ffffffffc02018aa:	10f51963          	bne	a0,a5,ffffffffc02019bc <buddy_check+0x690>
ffffffffc02018ae:	458d                	li	a1,3
ffffffffc02018b0:	8522                	mv	a0,s0
ffffffffc02018b2:	2b6000ef          	jal	ffffffffc0201b68 <free_pages>
ffffffffc02018b6:	2be000ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02018ba:	0e951163          	bne	a0,s1,ffffffffc020199c <buddy_check+0x670>
ffffffffc02018be:	e97fe0ef          	jal	ffffffffc0200754 <check_consistency>
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
ffffffffc02018dc:	00002517          	auipc	a0,0x2
ffffffffc02018e0:	ecc50513          	addi	a0,a0,-308 # ffffffffc02037a8 <etext+0x940>
ffffffffc02018e4:	20010113          	addi	sp,sp,512
ffffffffc02018e8:	865fe06f          	j	ffffffffc020014c <cprintf>
ffffffffc02018ec:	16800613          	li	a2,360
ffffffffc02018f0:	85e6                	mv	a1,s9
ffffffffc02018f2:	8562                	mv	a0,s8
ffffffffc02018f4:	550010ef          	jal	ffffffffc0202e44 <memcmp>
ffffffffc02018f8:	67c2                	ld	a5,16(sp)
ffffffffc02018fa:	2785                	addiw	a5,a5,1
ffffffffc02018fc:	e83e                	sd	a5,16(sp)
ffffffffc02018fe:	14051f63          	bnez	a0,ffffffffc0201a5c <buddy_check+0x730>
ffffffffc0201902:	000ab583          	ld	a1,0(s5)
ffffffffc0201906:	50000613          	li	a2,1280
ffffffffc020190a:	855e                	mv	a0,s7
ffffffffc020190c:	538010ef          	jal	ffffffffc0202e44 <memcmp>
ffffffffc0201910:	e6050ae3          	beqz	a0,ffffffffc0201784 <buddy_check+0x458>
ffffffffc0201914:	00002697          	auipc	a3,0x2
ffffffffc0201918:	bec68693          	addi	a3,a3,-1044 # ffffffffc0203500 <etext+0x698>
ffffffffc020191c:	00001617          	auipc	a2,0x1
ffffffffc0201920:	7b460613          	addi	a2,a2,1972 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201924:	17100593          	li	a1,369
ffffffffc0201928:	00001517          	auipc	a0,0x1
ffffffffc020192c:	7c050513          	addi	a0,a0,1984 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201930:	893fe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201934:	4485                	li	s1,1
ffffffffc0201936:	b6f9                	j	ffffffffc0201504 <buddy_check+0x1d8>
ffffffffc0201938:	4da1                	li	s11,8
ffffffffc020193a:	b4fd                	j	ffffffffc0201428 <buddy_check+0xfc>
ffffffffc020193c:	00002697          	auipc	a3,0x2
ffffffffc0201940:	d5c68693          	addi	a3,a3,-676 # ffffffffc0203698 <etext+0x830>
ffffffffc0201944:	00001617          	auipc	a2,0x1
ffffffffc0201948:	78c60613          	addi	a2,a2,1932 # ffffffffc02030d0 <etext+0x268>
ffffffffc020194c:	12d00593          	li	a1,301
ffffffffc0201950:	00001517          	auipc	a0,0x1
ffffffffc0201954:	79850513          	addi	a0,a0,1944 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201958:	86bfe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020195c:	00002697          	auipc	a3,0x2
ffffffffc0201960:	d1c68693          	addi	a3,a3,-740 # ffffffffc0203678 <etext+0x810>
ffffffffc0201964:	00001617          	auipc	a2,0x1
ffffffffc0201968:	76c60613          	addi	a2,a2,1900 # ffffffffc02030d0 <etext+0x268>
ffffffffc020196c:	12200593          	li	a1,290
ffffffffc0201970:	00001517          	auipc	a0,0x1
ffffffffc0201974:	77850513          	addi	a0,a0,1912 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201978:	84bfe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020197c:	00002697          	auipc	a3,0x2
ffffffffc0201980:	c7c68693          	addi	a3,a3,-900 # ffffffffc02035f8 <etext+0x790>
ffffffffc0201984:	00001617          	auipc	a2,0x1
ffffffffc0201988:	74c60613          	addi	a2,a2,1868 # ffffffffc02030d0 <etext+0x268>
ffffffffc020198c:	11100593          	li	a1,273
ffffffffc0201990:	00001517          	auipc	a0,0x1
ffffffffc0201994:	75850513          	addi	a0,a0,1880 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201998:	82bfe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc020199c:	00002697          	auipc	a3,0x2
ffffffffc02019a0:	db468693          	addi	a3,a3,-588 # ffffffffc0203750 <etext+0x8e8>
ffffffffc02019a4:	00001617          	auipc	a2,0x1
ffffffffc02019a8:	72c60613          	addi	a2,a2,1836 # ffffffffc02030d0 <etext+0x268>
ffffffffc02019ac:	18600593          	li	a1,390
ffffffffc02019b0:	00001517          	auipc	a0,0x1
ffffffffc02019b4:	73850513          	addi	a0,a0,1848 # ffffffffc02030e8 <etext+0x280>
ffffffffc02019b8:	80bfe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02019bc:	00002697          	auipc	a3,0x2
ffffffffc02019c0:	db468693          	addi	a3,a3,-588 # ffffffffc0203770 <etext+0x908>
ffffffffc02019c4:	00001617          	auipc	a2,0x1
ffffffffc02019c8:	70c60613          	addi	a2,a2,1804 # ffffffffc02030d0 <etext+0x268>
ffffffffc02019cc:	18400593          	li	a1,388
ffffffffc02019d0:	00001517          	auipc	a0,0x1
ffffffffc02019d4:	71850513          	addi	a0,a0,1816 # ffffffffc02030e8 <etext+0x280>
ffffffffc02019d8:	feafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02019dc:	00002697          	auipc	a3,0x2
ffffffffc02019e0:	d7468693          	addi	a3,a3,-652 # ffffffffc0203750 <etext+0x8e8>
ffffffffc02019e4:	00001617          	auipc	a2,0x1
ffffffffc02019e8:	6ec60613          	addi	a2,a2,1772 # ffffffffc02030d0 <etext+0x268>
ffffffffc02019ec:	18100593          	li	a1,385
ffffffffc02019f0:	00001517          	auipc	a0,0x1
ffffffffc02019f4:	6f850513          	addi	a0,a0,1784 # ffffffffc02030e8 <etext+0x280>
ffffffffc02019f8:	fcafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc02019fc:	00002697          	auipc	a3,0x2
ffffffffc0201a00:	cac68693          	addi	a3,a3,-852 # ffffffffc02036a8 <etext+0x840>
ffffffffc0201a04:	00001617          	auipc	a2,0x1
ffffffffc0201a08:	6cc60613          	addi	a2,a2,1740 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201a0c:	17900593          	li	a1,377
ffffffffc0201a10:	00001517          	auipc	a0,0x1
ffffffffc0201a14:	6d850513          	addi	a0,a0,1752 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201a18:	faafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201a1c:	00002697          	auipc	a3,0x2
ffffffffc0201a20:	c5c68693          	addi	a3,a3,-932 # ffffffffc0203678 <etext+0x810>
ffffffffc0201a24:	00001617          	auipc	a2,0x1
ffffffffc0201a28:	6ac60613          	addi	a2,a2,1708 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201a2c:	17700593          	li	a1,375
ffffffffc0201a30:	00001517          	auipc	a0,0x1
ffffffffc0201a34:	6b850513          	addi	a0,a0,1720 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201a38:	f8afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201a3c:	00002697          	auipc	a3,0x2
ffffffffc0201a40:	cec68693          	addi	a3,a3,-788 # ffffffffc0203728 <etext+0x8c0>
ffffffffc0201a44:	00001617          	auipc	a2,0x1
ffffffffc0201a48:	68c60613          	addi	a2,a2,1676 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201a4c:	17500593          	li	a1,373
ffffffffc0201a50:	00001517          	auipc	a0,0x1
ffffffffc0201a54:	69850513          	addi	a0,a0,1688 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201a58:	f6afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201a5c:	00002697          	auipc	a3,0x2
ffffffffc0201a60:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02034c8 <etext+0x660>
ffffffffc0201a64:	00001617          	auipc	a2,0x1
ffffffffc0201a68:	66c60613          	addi	a2,a2,1644 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201a6c:	17000593          	li	a1,368
ffffffffc0201a70:	00001517          	auipc	a0,0x1
ffffffffc0201a74:	67850513          	addi	a0,a0,1656 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201a78:	f4afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201a7c:	00002697          	auipc	a3,0x2
ffffffffc0201a80:	c9468693          	addi	a3,a3,-876 # ffffffffc0203710 <etext+0x8a8>
ffffffffc0201a84:	00001617          	auipc	a2,0x1
ffffffffc0201a88:	64c60613          	addi	a2,a2,1612 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201a8c:	15600593          	li	a1,342
ffffffffc0201a90:	00001517          	auipc	a0,0x1
ffffffffc0201a94:	65850513          	addi	a0,a0,1624 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201a98:	f2afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201a9c:	00002697          	auipc	a3,0x2
ffffffffc0201aa0:	c6468693          	addi	a3,a3,-924 # ffffffffc0203700 <etext+0x898>
ffffffffc0201aa4:	00001617          	auipc	a2,0x1
ffffffffc0201aa8:	62c60613          	addi	a2,a2,1580 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201aac:	15300593          	li	a1,339
ffffffffc0201ab0:	00001517          	auipc	a0,0x1
ffffffffc0201ab4:	63850513          	addi	a0,a0,1592 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201ab8:	f0afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201abc:	00002697          	auipc	a3,0x2
ffffffffc0201ac0:	bec68693          	addi	a3,a3,-1044 # ffffffffc02036a8 <etext+0x840>
ffffffffc0201ac4:	00001617          	auipc	a2,0x1
ffffffffc0201ac8:	60c60613          	addi	a2,a2,1548 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201acc:	14700593          	li	a1,327
ffffffffc0201ad0:	00001517          	auipc	a0,0x1
ffffffffc0201ad4:	61850513          	addi	a0,a0,1560 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201ad8:	eeafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201adc:	00002697          	auipc	a3,0x2
ffffffffc0201ae0:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02036e8 <etext+0x880>
ffffffffc0201ae4:	00001617          	auipc	a2,0x1
ffffffffc0201ae8:	5ec60613          	addi	a2,a2,1516 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201aec:	14300593          	li	a1,323
ffffffffc0201af0:	00001517          	auipc	a0,0x1
ffffffffc0201af4:	5f850513          	addi	a0,a0,1528 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201af8:	ecafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201afc:	00002697          	auipc	a3,0x2
ffffffffc0201b00:	bd468693          	addi	a3,a3,-1068 # ffffffffc02036d0 <etext+0x868>
ffffffffc0201b04:	00001617          	auipc	a2,0x1
ffffffffc0201b08:	5cc60613          	addi	a2,a2,1484 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201b0c:	13f00593          	li	a1,319
ffffffffc0201b10:	00001517          	auipc	a0,0x1
ffffffffc0201b14:	5d850513          	addi	a0,a0,1496 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201b18:	eaafe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201b1c:	00002697          	auipc	a3,0x2
ffffffffc0201b20:	ba468693          	addi	a3,a3,-1116 # ffffffffc02036c0 <etext+0x858>
ffffffffc0201b24:	00001617          	auipc	a2,0x1
ffffffffc0201b28:	5ac60613          	addi	a2,a2,1452 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201b2c:	13a00593          	li	a1,314
ffffffffc0201b30:	00001517          	auipc	a0,0x1
ffffffffc0201b34:	5b850513          	addi	a0,a0,1464 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201b38:	e8afe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201b3c:	00002697          	auipc	a3,0x2
ffffffffc0201b40:	b6c68693          	addi	a3,a3,-1172 # ffffffffc02036a8 <etext+0x840>
ffffffffc0201b44:	00001617          	auipc	a2,0x1
ffffffffc0201b48:	58c60613          	addi	a2,a2,1420 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201b4c:	13100593          	li	a1,305
ffffffffc0201b50:	00001517          	auipc	a0,0x1
ffffffffc0201b54:	59850513          	addi	a0,a0,1432 # ffffffffc02030e8 <etext+0x280>
ffffffffc0201b58:	e6afe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201b5c <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0201b5c:	00007797          	auipc	a5,0x7
ffffffffc0201b60:	39c7b783          	ld	a5,924(a5) # ffffffffc0208ef8 <pmm_manager>
ffffffffc0201b64:	6f9c                	ld	a5,24(a5)
ffffffffc0201b66:	8782                	jr	a5

ffffffffc0201b68 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0201b68:	00007797          	auipc	a5,0x7
ffffffffc0201b6c:	3907b783          	ld	a5,912(a5) # ffffffffc0208ef8 <pmm_manager>
ffffffffc0201b70:	739c                	ld	a5,32(a5)
ffffffffc0201b72:	8782                	jr	a5

ffffffffc0201b74 <nr_free_pages>:
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc0201b74:	00007797          	auipc	a5,0x7
ffffffffc0201b78:	3847b783          	ld	a5,900(a5) # ffffffffc0208ef8 <pmm_manager>
ffffffffc0201b7c:	779c                	ld	a5,40(a5)
ffffffffc0201b7e:	8782                	jr	a5

ffffffffc0201b80 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201b80:	00002797          	auipc	a5,0x2
ffffffffc0201b84:	29078793          	addi	a5,a5,656 # ffffffffc0203e10 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b88:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(free_start), (free_end - free_start) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201b8a:	715d                	addi	sp,sp,-80
ffffffffc0201b8c:	e486                	sd	ra,72(sp)
ffffffffc0201b8e:	fc26                	sd	s1,56(sp)
ffffffffc0201b90:	e45e                	sd	s7,8(sp)
ffffffffc0201b92:	e85a                	sd	s6,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201b94:	00007497          	auipc	s1,0x7
ffffffffc0201b98:	36448493          	addi	s1,s1,868 # ffffffffc0208ef8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b9c:	00002517          	auipc	a0,0x2
ffffffffc0201ba0:	c4450513          	addi	a0,a0,-956 # ffffffffc02037e0 <etext+0x978>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201ba4:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ba6:	da6fe0ef          	jal	ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0201baa:	609c                	ld	a5,0(s1)
ffffffffc0201bac:	679c                	ld	a5,8(a5)
ffffffffc0201bae:	9782                	jalr	a5
    uint64_t mem_base = get_memory_base();
ffffffffc0201bb0:	a0dfe0ef          	jal	ffffffffc02005bc <get_memory_base>
ffffffffc0201bb4:	8baa                	mv	s7,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0201bb6:	a11fe0ef          	jal	ffffffffc02005c6 <get_memory_size>
    if (mem_base == 0 || mem_size == 0) {
ffffffffc0201bba:	1c0b8a63          	beqz	s7,ffffffffc0201d8e <pmm_init+0x20e>
ffffffffc0201bbe:	8b2a                	mv	s6,a0
ffffffffc0201bc0:	1c050763          	beqz	a0,ffffffffc0201d8e <pmm_init+0x20e>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201bc4:	57f5                	li	a5,-3
ffffffffc0201bc6:	f84a                	sd	s2,48(sp)
ffffffffc0201bc8:	f44e                	sd	s3,40(sp)
ffffffffc0201bca:	e062                	sd	s8,0(sp)
ffffffffc0201bcc:	f052                	sd	s4,32(sp)
ffffffffc0201bce:	ec56                	sd	s5,24(sp)
ffffffffc0201bd0:	07fa                	slli	a5,a5,0x1e
ffffffffc0201bd2:	00007917          	auipc	s2,0x7
ffffffffc0201bd6:	33e90913          	addi	s2,s2,830 # ffffffffc0208f10 <va_pa_offset>
    if (mem_end > PHYSICAL_MEMORY_END) {
ffffffffc0201bda:	49c5                	li	s3,17
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201bdc:	00f93023          	sd	a5,0(s2)
    if (mem_end > PHYSICAL_MEMORY_END) {
ffffffffc0201be0:	09ee                	slli	s3,s3,0x1b
    uint64_t mem_end = mem_base + mem_size;
ffffffffc0201be2:	00ab8c33          	add	s8,s7,a0
    if (mem_end > PHYSICAL_MEMORY_END) {
ffffffffc0201be6:	1189ef63          	bltu	s3,s8,ffffffffc0201d04 <pmm_init+0x184>
    if (mem_end <= DRAM_BASE) {
ffffffffc0201bea:	4785                	li	a5,1
ffffffffc0201bec:	07fe                	slli	a5,a5,0x1f
ffffffffc0201bee:	2187fa63          	bgeu	a5,s8,ffffffffc0201e02 <pmm_init+0x282>
    npage = PPN(mem_end);
ffffffffc0201bf2:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201bf4:	00008317          	auipc	t1,0x8
ffffffffc0201bf8:	33730313          	addi	t1,t1,823 # ffffffffc0209f2b <end+0xfff>
ffffffffc0201bfc:	00f37333          	and	t1,t1,a5
    npage = PPN(mem_end);
ffffffffc0201c00:	00cc5e13          	srli	t3,s8,0xc
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201c04:	00007a17          	auipc	s4,0x7
ffffffffc0201c08:	31ca0a13          	addi	s4,s4,796 # ffffffffc0208f20 <pages>
    npage = PPN(mem_end);
ffffffffc0201c0c:	00007a97          	auipc	s5,0x7
ffffffffc0201c10:	30ca8a93          	addi	s5,s5,780 # ffffffffc0208f18 <npage>
    size_t nr_pages = npage - nbase;
ffffffffc0201c14:	fff807b7          	lui	a5,0xfff80
    npage = PPN(mem_end);
ffffffffc0201c18:	01cab023          	sd	t3,0(s5)
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201c1c:	006a3023          	sd	t1,0(s4)
    size_t nr_pages = npage - nbase;
ffffffffc0201c20:	9e3e                	add	t3,t3,a5
    for (size_t i = 0; i < nr_pages; i++) {
ffffffffc0201c22:	140e0163          	beqz	t3,ffffffffc0201d64 <pmm_init+0x1e4>
ffffffffc0201c26:	e0a2                	sd	s0,64(sp)
ffffffffc0201c28:	89e2                	mv	s3,s8
ffffffffc0201c2a:	002e1813          	slli	a6,t3,0x2
ffffffffc0201c2e:	01c80733          	add	a4,a6,t3
ffffffffc0201c32:	070e                	slli	a4,a4,0x3
ffffffffc0201c34:	971a                	add	a4,a4,t1
ffffffffc0201c36:	879a                	mv	a5,t1
        SetPageReserved(&pages[i]);
ffffffffc0201c38:	4885                	li	a7,1
        pages[i].ref = 0;
ffffffffc0201c3a:	0007a023          	sw	zero,0(a5) # fffffffffff80000 <end+0x3fd770d4>
        pages[i].property = 0;
ffffffffc0201c3e:	0007a823          	sw	zero,16(a5)
        SetPageReserved(&pages[i]);
ffffffffc0201c42:	0117b423          	sd	a7,8(a5)
    for (size_t i = 0; i < nr_pages; i++) {
ffffffffc0201c46:	02878793          	addi	a5,a5,40
ffffffffc0201c4a:	fee798e3          	bne	a5,a4,ffffffffc0201c3a <pmm_init+0xba>
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0201c4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c52:	16f36163          	bltu	t1,a5,ffffffffc0201db4 <pmm_init+0x234>
        ROUNDUP(pages_pa + nr_pages * sizeof(struct Page), PGSIZE);
ffffffffc0201c56:	000c07b7          	lui	a5,0xc0
ffffffffc0201c5a:	0785                	addi	a5,a5,1 # c0001 <kern_entry-0xffffffffc013ffff>
ffffffffc0201c5c:	07b2                	slli	a5,a5,0xc
ffffffffc0201c5e:	9872                	add	a6,a6,t3
ffffffffc0201c60:	17fd                	addi	a5,a5,-1
ffffffffc0201c62:	979a                	add	a5,a5,t1
ffffffffc0201c64:	080e                	slli	a6,a6,0x3
ffffffffc0201c66:	983e                	add	a6,a6,a5
    if (free_start < mem_base) {
ffffffffc0201c68:	77fd                	lui	a5,0xfffff
ffffffffc0201c6a:	00f87433          	and	s0,a6,a5
ffffffffc0201c6e:	01747363          	bgeu	s0,s7,ffffffffc0201c74 <pmm_init+0xf4>
ffffffffc0201c72:	845e                	mv	s0,s7
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201c74:	77fd                	lui	a5,0xfffff
    cprintf("physical memory map:\n");
ffffffffc0201c76:	00002517          	auipc	a0,0x2
ffffffffc0201c7a:	c2250513          	addi	a0,a0,-990 # ffffffffc0203898 <etext+0xa30>
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201c7e:	00f9f9b3          	and	s3,s3,a5
    cprintf("physical memory map:\n");
ffffffffc0201c82:	ccafe0ef          	jal	ffffffffc020014c <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size,
ffffffffc0201c86:	fffc0693          	addi	a3,s8,-1
ffffffffc0201c8a:	865e                	mv	a2,s7
ffffffffc0201c8c:	85da                	mv	a1,s6
ffffffffc0201c8e:	00002517          	auipc	a0,0x2
ffffffffc0201c92:	c2250513          	addi	a0,a0,-990 # ffffffffc02038b0 <etext+0xa48>
ffffffffc0201c96:	cb6fe0ef          	jal	ffffffffc020014c <cprintf>
    if (free_end > free_start) {
ffffffffc0201c9a:	09346d63          	bltu	s0,s3,ffffffffc0201d34 <pmm_init+0x1b4>
ffffffffc0201c9e:	6406                	ld	s0,64(sp)
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201ca0:	609c                	ld	a5,0(s1)
ffffffffc0201ca2:	7b9c                	ld	a5,48(a5)
ffffffffc0201ca4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201ca6:	00002517          	auipc	a0,0x2
ffffffffc0201caa:	c6a50513          	addi	a0,a0,-918 # ffffffffc0203910 <etext+0xaa8>
ffffffffc0201cae:	c9efe0ef          	jal	ffffffffc020014c <cprintf>
    slub_init();
ffffffffc0201cb2:	24c000ef          	jal	ffffffffc0201efe <slub_init>
    slub_check();
ffffffffc0201cb6:	620000ef          	jal	ffffffffc02022d6 <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201cba:	00005597          	auipc	a1,0x5
ffffffffc0201cbe:	34658593          	addi	a1,a1,838 # ffffffffc0207000 <boot_page_table_sv39>
ffffffffc0201cc2:	00007797          	auipc	a5,0x7
ffffffffc0201cc6:	24b7b323          	sd	a1,582(a5) # ffffffffc0208f08 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201cca:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cce:	10f5e063          	bltu	a1,a5,ffffffffc0201dce <pmm_init+0x24e>
ffffffffc0201cd2:	00093783          	ld	a5,0(s2)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201cd6:	79a2                	ld	s3,40(sp)
ffffffffc0201cd8:	7942                	ld	s2,48(sp)
ffffffffc0201cda:	7a02                	ld	s4,32(sp)
ffffffffc0201cdc:	6ae2                	ld	s5,24(sp)
ffffffffc0201cde:	6c02                	ld	s8,0(sp)
}
ffffffffc0201ce0:	60a6                	ld	ra,72(sp)
ffffffffc0201ce2:	74e2                	ld	s1,56(sp)
ffffffffc0201ce4:	6b42                	ld	s6,16(sp)
ffffffffc0201ce6:	6ba2                	ld	s7,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201ce8:	40f586b3          	sub	a3,a1,a5
ffffffffc0201cec:	00007797          	auipc	a5,0x7
ffffffffc0201cf0:	20d7ba23          	sd	a3,532(a5) # ffffffffc0208f00 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201cf4:	00002517          	auipc	a0,0x2
ffffffffc0201cf8:	c3c50513          	addi	a0,a0,-964 # ffffffffc0203930 <etext+0xac8>
ffffffffc0201cfc:	8636                	mv	a2,a3
}
ffffffffc0201cfe:	6161                	addi	sp,sp,80
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201d00:	c4cfe06f          	j	ffffffffc020014c <cprintf>
ffffffffc0201d04:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201d06:	00008317          	auipc	t1,0x8
ffffffffc0201d0a:	22530313          	addi	t1,t1,549 # ffffffffc0209f2b <end+0xfff>
ffffffffc0201d0e:	e0a2                	sd	s0,64(sp)
    npage = PPN(mem_end);
ffffffffc0201d10:	00f37333          	and	t1,t1,a5
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201d14:	00007a17          	auipc	s4,0x7
ffffffffc0201d18:	20ca0a13          	addi	s4,s4,524 # ffffffffc0208f20 <pages>
    npage = PPN(mem_end);
ffffffffc0201d1c:	00007a97          	auipc	s5,0x7
ffffffffc0201d20:	1fca8a93          	addi	s5,s5,508 # ffffffffc0208f18 <npage>
ffffffffc0201d24:	000887b7          	lui	a5,0x88
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201d28:	006a3023          	sd	t1,0(s4)
    npage = PPN(mem_end);
ffffffffc0201d2c:	00fab023          	sd	a5,0(s5)
    size_t nr_pages = npage - nbase;
ffffffffc0201d30:	6e21                	lui	t3,0x8
ffffffffc0201d32:	bde5                	j	ffffffffc0201c2a <pmm_init+0xaa>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201d34:	000ab783          	ld	a5,0(s5)
ffffffffc0201d38:	00c45713          	srli	a4,s0,0xc
ffffffffc0201d3c:	0af77763          	bgeu	a4,a5,ffffffffc0201dea <pmm_init+0x26a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201d40:	6094                	ld	a3,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201d42:	fff807b7          	lui	a5,0xfff80
ffffffffc0201d46:	973e                	add	a4,a4,a5
ffffffffc0201d48:	000a3503          	ld	a0,0(s4)
ffffffffc0201d4c:	00271793          	slli	a5,a4,0x2
ffffffffc0201d50:	97ba                	add	a5,a5,a4
ffffffffc0201d52:	6a98                	ld	a4,16(a3)
        init_memmap(pa2page(free_start), (free_end - free_start) / PGSIZE);
ffffffffc0201d54:	408985b3          	sub	a1,s3,s0
ffffffffc0201d58:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201d5a:	81b1                	srli	a1,a1,0xc
ffffffffc0201d5c:	953e                	add	a0,a0,a5
ffffffffc0201d5e:	9702                	jalr	a4
ffffffffc0201d60:	6406                	ld	s0,64(sp)
}
ffffffffc0201d62:	bf3d                	j	ffffffffc0201ca0 <pmm_init+0x120>
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0201d64:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d68:	04f36563          	bltu	t1,a5,ffffffffc0201db2 <pmm_init+0x232>
    cprintf("physical memory map:\n");
ffffffffc0201d6c:	00002517          	auipc	a0,0x2
ffffffffc0201d70:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0203898 <etext+0xa30>
ffffffffc0201d74:	bd8fe0ef          	jal	ffffffffc020014c <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size,
ffffffffc0201d78:	fffc0693          	addi	a3,s8,-1
ffffffffc0201d7c:	865e                	mv	a2,s7
ffffffffc0201d7e:	85da                	mv	a1,s6
ffffffffc0201d80:	00002517          	auipc	a0,0x2
ffffffffc0201d84:	b3050513          	addi	a0,a0,-1232 # ffffffffc02038b0 <etext+0xa48>
ffffffffc0201d88:	bc4fe0ef          	jal	ffffffffc020014c <cprintf>
    if (free_end > free_start) {
ffffffffc0201d8c:	bf11                	j	ffffffffc0201ca0 <pmm_init+0x120>
        panic("page_init: invalid physical memory info from DTB");
ffffffffc0201d8e:	00002617          	auipc	a2,0x2
ffffffffc0201d92:	a6a60613          	addi	a2,a2,-1430 # ffffffffc02037f8 <etext+0x990>
ffffffffc0201d96:	04a00593          	li	a1,74
ffffffffc0201d9a:	00002517          	auipc	a0,0x2
ffffffffc0201d9e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0203830 <etext+0x9c8>
ffffffffc0201da2:	e0a2                	sd	s0,64(sp)
ffffffffc0201da4:	f84a                	sd	s2,48(sp)
ffffffffc0201da6:	f44e                	sd	s3,40(sp)
ffffffffc0201da8:	f052                	sd	s4,32(sp)
ffffffffc0201daa:	ec56                	sd	s5,24(sp)
ffffffffc0201dac:	e062                	sd	s8,0(sp)
ffffffffc0201dae:	c14fe0ef          	jal	ffffffffc02001c2 <__panic>
ffffffffc0201db2:	e0a2                	sd	s0,64(sp)
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0201db4:	869a                	mv	a3,t1
ffffffffc0201db6:	00002617          	auipc	a2,0x2
ffffffffc0201dba:	aba60613          	addi	a2,a2,-1350 # ffffffffc0203870 <etext+0xa08>
ffffffffc0201dbe:	06c00593          	li	a1,108
ffffffffc0201dc2:	00002517          	auipc	a0,0x2
ffffffffc0201dc6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0203830 <etext+0x9c8>
ffffffffc0201dca:	bf8fe0ef          	jal	ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201dce:	86ae                	mv	a3,a1
ffffffffc0201dd0:	00002617          	auipc	a2,0x2
ffffffffc0201dd4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0203870 <etext+0xa08>
ffffffffc0201dd8:	09400593          	li	a1,148
ffffffffc0201ddc:	00002517          	auipc	a0,0x2
ffffffffc0201de0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0203830 <etext+0x9c8>
ffffffffc0201de4:	e0a2                	sd	s0,64(sp)
ffffffffc0201de6:	bdcfe0ef          	jal	ffffffffc02001c2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201dea:	00002617          	auipc	a2,0x2
ffffffffc0201dee:	af660613          	addi	a2,a2,-1290 # ffffffffc02038e0 <etext+0xa78>
ffffffffc0201df2:	06a00593          	li	a1,106
ffffffffc0201df6:	00002517          	auipc	a0,0x2
ffffffffc0201dfa:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0203900 <etext+0xa98>
ffffffffc0201dfe:	bc4fe0ef          	jal	ffffffffc02001c2 <__panic>
        panic("page_init: physical memory range is invalid");
ffffffffc0201e02:	00002617          	auipc	a2,0x2
ffffffffc0201e06:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0203840 <etext+0x9d8>
ffffffffc0201e0a:	05700593          	li	a1,87
ffffffffc0201e0e:	00002517          	auipc	a0,0x2
ffffffffc0201e12:	a2250513          	addi	a0,a0,-1502 # ffffffffc0203830 <etext+0x9c8>
ffffffffc0201e16:	e0a2                	sd	s0,64(sp)
ffffffffc0201e18:	baafe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201e1c <test_fill>:
    unsigned char pattern;
};

static void
test_fill(struct test_object *object) {
    assert(object->ptr != NULL);
ffffffffc0201e1c:	6118                	ld	a4,0(a0)
test_fill(struct test_object *object) {
ffffffffc0201e1e:	1141                	addi	sp,sp,-16
ffffffffc0201e20:	e406                	sd	ra,8(sp)
    assert(object->ptr != NULL);
ffffffffc0201e22:	cb1d                	beqz	a4,ffffffffc0201e58 <test_fill+0x3c>
    assert((uintptr_t)object->ptr % sizeof(uintptr_t) == 0);
ffffffffc0201e24:	00777793          	andi	a5,a4,7
ffffffffc0201e28:	eba1                	bnez	a5,ffffffffc0201e78 <test_fill+0x5c>
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201e2a:	651c                	ld	a5,8(a0)
ffffffffc0201e2c:	c39d                	beqz	a5,ffffffffc0201e52 <test_fill+0x36>
        ((unsigned char *)object->ptr)[i] = object->pattern;
ffffffffc0201e2e:	01054683          	lbu	a3,16(a0)
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201e32:	4785                	li	a5,1
        ((unsigned char *)object->ptr)[i] = object->pattern;
ffffffffc0201e34:	00d70023          	sb	a3,0(a4)
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201e38:	6518                	ld	a4,8(a0)
ffffffffc0201e3a:	00e7fc63          	bgeu	a5,a4,ffffffffc0201e52 <test_fill+0x36>
        ((unsigned char *)object->ptr)[i] = object->pattern;
ffffffffc0201e3e:	6118                	ld	a4,0(a0)
ffffffffc0201e40:	01054683          	lbu	a3,16(a0)
ffffffffc0201e44:	973e                	add	a4,a4,a5
ffffffffc0201e46:	00d70023          	sb	a3,0(a4)
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201e4a:	6518                	ld	a4,8(a0)
ffffffffc0201e4c:	0785                	addi	a5,a5,1 # ffffffffc0200001 <kern_entry+0x1>
ffffffffc0201e4e:	fee7e8e3          	bltu	a5,a4,ffffffffc0201e3e <test_fill+0x22>
    }
}
ffffffffc0201e52:	60a2                	ld	ra,8(sp)
ffffffffc0201e54:	0141                	addi	sp,sp,16
ffffffffc0201e56:	8082                	ret
    assert(object->ptr != NULL);
ffffffffc0201e58:	00002697          	auipc	a3,0x2
ffffffffc0201e5c:	b1868693          	addi	a3,a3,-1256 # ffffffffc0203970 <etext+0xb08>
ffffffffc0201e60:	00001617          	auipc	a2,0x1
ffffffffc0201e64:	27060613          	addi	a2,a2,624 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201e68:	09c00593          	li	a1,156
ffffffffc0201e6c:	00002517          	auipc	a0,0x2
ffffffffc0201e70:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0203988 <etext+0xb20>
ffffffffc0201e74:	b4efe0ef          	jal	ffffffffc02001c2 <__panic>
    assert((uintptr_t)object->ptr % sizeof(uintptr_t) == 0);
ffffffffc0201e78:	00002697          	auipc	a3,0x2
ffffffffc0201e7c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0203998 <etext+0xb30>
ffffffffc0201e80:	00001617          	auipc	a2,0x1
ffffffffc0201e84:	25060613          	addi	a2,a2,592 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201e88:	09d00593          	li	a1,157
ffffffffc0201e8c:	00002517          	auipc	a0,0x2
ffffffffc0201e90:	afc50513          	addi	a0,a0,-1284 # ffffffffc0203988 <etext+0xb20>
ffffffffc0201e94:	b2efe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201e98 <test_contents>:

static void
test_contents(const struct test_object *object) {
    assert(object->ptr != NULL);
ffffffffc0201e98:	611c                	ld	a5,0(a0)
test_contents(const struct test_object *object) {
ffffffffc0201e9a:	1141                	addi	sp,sp,-16
ffffffffc0201e9c:	e406                	sd	ra,8(sp)
    assert(object->ptr != NULL);
ffffffffc0201e9e:	c3a1                	beqz	a5,ffffffffc0201ede <test_contents+0x46>
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201ea0:	6514                	ld	a3,8(a0)
ffffffffc0201ea2:	ca99                	beqz	a3,ffffffffc0201eb8 <test_contents+0x20>
        assert(((const unsigned char *)object->ptr)[i] == object->pattern);
ffffffffc0201ea4:	01054603          	lbu	a2,16(a0)
ffffffffc0201ea8:	96be                	add	a3,a3,a5
ffffffffc0201eaa:	0007c703          	lbu	a4,0(a5)
ffffffffc0201eae:	00c71863          	bne	a4,a2,ffffffffc0201ebe <test_contents+0x26>
    for (size_t i = 0; i < object->size; i++) {
ffffffffc0201eb2:	0785                	addi	a5,a5,1
ffffffffc0201eb4:	fed79be3          	bne	a5,a3,ffffffffc0201eaa <test_contents+0x12>
    }
}
ffffffffc0201eb8:	60a2                	ld	ra,8(sp)
ffffffffc0201eba:	0141                	addi	sp,sp,16
ffffffffc0201ebc:	8082                	ret
        assert(((const unsigned char *)object->ptr)[i] == object->pattern);
ffffffffc0201ebe:	00002697          	auipc	a3,0x2
ffffffffc0201ec2:	b0a68693          	addi	a3,a3,-1270 # ffffffffc02039c8 <etext+0xb60>
ffffffffc0201ec6:	00001617          	auipc	a2,0x1
ffffffffc0201eca:	20a60613          	addi	a2,a2,522 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201ece:	0a700593          	li	a1,167
ffffffffc0201ed2:	00002517          	auipc	a0,0x2
ffffffffc0201ed6:	ab650513          	addi	a0,a0,-1354 # ffffffffc0203988 <etext+0xb20>
ffffffffc0201eda:	ae8fe0ef          	jal	ffffffffc02001c2 <__panic>
    assert(object->ptr != NULL);
ffffffffc0201ede:	00002697          	auipc	a3,0x2
ffffffffc0201ee2:	a9268693          	addi	a3,a3,-1390 # ffffffffc0203970 <etext+0xb08>
ffffffffc0201ee6:	00001617          	auipc	a2,0x1
ffffffffc0201eea:	1ea60613          	addi	a2,a2,490 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201eee:	0a500593          	li	a1,165
ffffffffc0201ef2:	00002517          	auipc	a0,0x2
ffffffffc0201ef6:	a9650513          	addi	a0,a0,-1386 # ffffffffc0203988 <etext+0xb20>
ffffffffc0201efa:	ac8fe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201efe <slub_init>:
    assert(!initialized);
ffffffffc0201efe:	00007697          	auipc	a3,0x7
ffffffffc0201f02:	02a6a683          	lw	a3,42(a3) # ffffffffc0208f28 <initialized>
ffffffffc0201f06:	00007797          	auipc	a5,0x7
ffffffffc0201f0a:	f8a78793          	addi	a5,a5,-118 # ffffffffc0208e90 <slabs>
ffffffffc0201f0e:	00007717          	auipc	a4,0x7
ffffffffc0201f12:	fca70713          	addi	a4,a4,-54 # ffffffffc0208ed8 <is_panic>
ffffffffc0201f16:	ee81                	bnez	a3,ffffffffc0201f2e <slub_init+0x30>
    for (size_t i = 0; i < NR_CLASSES; i++) slabs[i] = NULL;
ffffffffc0201f18:	0007b023          	sd	zero,0(a5)
ffffffffc0201f1c:	07a1                	addi	a5,a5,8
ffffffffc0201f1e:	fee79de3          	bne	a5,a4,ffffffffc0201f18 <slub_init+0x1a>
    initialized = 1;
ffffffffc0201f22:	4785                	li	a5,1
ffffffffc0201f24:	00007717          	auipc	a4,0x7
ffffffffc0201f28:	00f72223          	sw	a5,4(a4) # ffffffffc0208f28 <initialized>
ffffffffc0201f2c:	8082                	ret
slub_init(void) {
ffffffffc0201f2e:	1141                	addi	sp,sp,-16
    assert(!initialized);
ffffffffc0201f30:	00002697          	auipc	a3,0x2
ffffffffc0201f34:	ad868693          	addi	a3,a3,-1320 # ffffffffc0203a08 <etext+0xba0>
ffffffffc0201f38:	00001617          	auipc	a2,0x1
ffffffffc0201f3c:	19860613          	addi	a2,a2,408 # ffffffffc02030d0 <etext+0x268>
ffffffffc0201f40:	04100593          	li	a1,65
ffffffffc0201f44:	00002517          	auipc	a0,0x2
ffffffffc0201f48:	a4450513          	addi	a0,a0,-1468 # ffffffffc0203988 <etext+0xb20>
slub_init(void) {
ffffffffc0201f4c:	e406                	sd	ra,8(sp)
    assert(!initialized);
ffffffffc0201f4e:	a74fe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0201f52 <slub_alloc>:
    assert(initialized);
ffffffffc0201f52:	00007797          	auipc	a5,0x7
ffffffffc0201f56:	fd67a783          	lw	a5,-42(a5) # ffffffffc0208f28 <initialized>
slub_alloc(size_t size) {
ffffffffc0201f5a:	7179                	addi	sp,sp,-48
ffffffffc0201f5c:	f406                	sd	ra,40(sp)
ffffffffc0201f5e:	f022                	sd	s0,32(sp)
    assert(initialized);
ffffffffc0201f60:	18078863          	beqz	a5,ffffffffc02020f0 <slub_alloc+0x19e>
    if (size == 0) return NULL;
ffffffffc0201f64:	00002797          	auipc	a5,0x2
ffffffffc0201f68:	ee478793          	addi	a5,a5,-284 # ffffffffc0203e48 <class_sizes>
    for (size_t i = 0; i < NR_CLASSES; i++) {
ffffffffc0201f6c:	4401                	li	s0,0
ffffffffc0201f6e:	4725                	li	a4,9
    if (size == 0) return NULL;
ffffffffc0201f70:	c959                	beqz	a0,ffffffffc0202006 <slub_alloc+0xb4>
ffffffffc0201f72:	ec26                	sd	s1,24(sp)
        if (size <= class_sizes[i]) {
ffffffffc0201f74:	6384                	ld	s1,0(a5)
ffffffffc0201f76:	08a4fd63          	bgeu	s1,a0,ffffffffc0202010 <slub_alloc+0xbe>
    for (size_t i = 0; i < NR_CLASSES; i++) {
ffffffffc0201f7a:	0405                	addi	s0,s0,1
ffffffffc0201f7c:	07a1                	addi	a5,a5,8
ffffffffc0201f7e:	fee41be3          	bne	s0,a4,ffffffffc0201f74 <slub_alloc+0x22>
    if (size > (size_t)-1 - payload_offset() - (PGSIZE - 1)) return NULL;
ffffffffc0201f82:	77fd                	lui	a5,0xfffff
ffffffffc0201f84:	fc078793          	addi	a5,a5,-64 # ffffffffffffefc0 <end+0x3fdf6094>
ffffffffc0201f88:	06a7ee63          	bltu	a5,a0,ffffffffc0202004 <slub_alloc+0xb2>
    size_t pages_needed = (size + payload_offset() + PGSIZE - 1) / PGSIZE;
ffffffffc0201f8c:	6785                	lui	a5,0x1
ffffffffc0201f8e:	03f78793          	addi	a5,a5,63 # 103f <kern_entry-0xffffffffc01fefc1>
ffffffffc0201f92:	953e                	add	a0,a0,a5
ffffffffc0201f94:	00c55413          	srli	s0,a0,0xc
    struct Page *page = alloc_pages(pages_needed);
ffffffffc0201f98:	8522                	mv	a0,s0
ffffffffc0201f9a:	bc3ff0ef          	jal	ffffffffc0201b5c <alloc_pages>
    if (page == NULL) return NULL;
ffffffffc0201f9e:	c13d                	beqz	a0,ffffffffc0202004 <slub_alloc+0xb2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa0:	00007797          	auipc	a5,0x7
ffffffffc0201fa4:	f807b783          	ld	a5,-128(a5) # ffffffffc0208f20 <pages>
ffffffffc0201fa8:	ccccd737          	lui	a4,0xccccd
ffffffffc0201fac:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac3da1>
ffffffffc0201fb0:	02071693          	slli	a3,a4,0x20
ffffffffc0201fb4:	40f507b3          	sub	a5,a0,a5
ffffffffc0201fb8:	9736                	add	a4,a4,a3
ffffffffc0201fba:	878d                	srai	a5,a5,0x3
ffffffffc0201fbc:	02e787b3          	mul	a5,a5,a4
ffffffffc0201fc0:	00002817          	auipc	a6,0x2
ffffffffc0201fc4:	17083803          	ld	a6,368(a6) # ffffffffc0204130 <nbase>
    struct slub_page *large = (struct slub_page *)(page2pa(page) + va_pa_offset);
ffffffffc0201fc8:	00007597          	auipc	a1,0x7
ffffffffc0201fcc:	f485b583          	ld	a1,-184(a1) # ffffffffc0208f10 <va_pa_offset>
    large->magic = SLUB_MAGIC;
ffffffffc0201fd0:	00002617          	auipc	a2,0x2
ffffffffc0201fd4:	15863603          	ld	a2,344(a2) # ffffffffc0204128 <error_string+0x48>
}
ffffffffc0201fd8:	70a2                	ld	ra,40(sp)
    large->capacity = 1;
ffffffffc0201fda:	4705                	li	a4,1
    large->class_index = SLUB_LARGE;
ffffffffc0201fdc:	56fd                	li	a3,-1
    return (char *)large + payload_offset();
ffffffffc0201fde:	64e2                	ld	s1,24(sp)
ffffffffc0201fe0:	97c2                	add	a5,a5,a6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fe2:	07b2                	slli	a5,a5,0xc
    struct slub_page *large = (struct slub_page *)(page2pa(page) + va_pa_offset);
ffffffffc0201fe4:	97ae                	add	a5,a5,a1
    large->page_count = pages_needed;
ffffffffc0201fe6:	f380                	sd	s0,32(a5)
}
ffffffffc0201fe8:	7402                	ld	s0,32(sp)
    large->page = page;
ffffffffc0201fea:	e788                	sd	a0,8(a5)
    large->next = NULL;
ffffffffc0201fec:	0007b823          	sd	zero,16(a5)
    large->free_head = NULL;
ffffffffc0201ff0:	0007bc23          	sd	zero,24(a5)
    large->magic = SLUB_MAGIC;
ffffffffc0201ff4:	e390                	sd	a2,0(a5)
    large->class_index = SLUB_LARGE;
ffffffffc0201ff6:	f794                	sd	a3,40(a5)
    large->capacity = 1;
ffffffffc0201ff8:	fb98                	sd	a4,48(a5)
    large->inuse = 1;
ffffffffc0201ffa:	ff98                	sd	a4,56(a5)
    return (char *)large + payload_offset();
ffffffffc0201ffc:	04078513          	addi	a0,a5,64
}
ffffffffc0202000:	6145                	addi	sp,sp,48
ffffffffc0202002:	8082                	ret
ffffffffc0202004:	64e2                	ld	s1,24(sp)
    if (size == 0) return NULL;
ffffffffc0202006:	4501                	li	a0,0
}
ffffffffc0202008:	7402                	ld	s0,32(sp)
ffffffffc020200a:	70a2                	ld	ra,40(sp)
ffffffffc020200c:	6145                	addi	sp,sp,48
ffffffffc020200e:	8082                	ret
ffffffffc0202010:	e84a                	sd	s2,16(sp)
ffffffffc0202012:	e44e                	sd	s3,8(sp)
            struct slub_page *slab = slabs[i];
ffffffffc0202014:	00007917          	auipc	s2,0x7
ffffffffc0202018:	e7c90913          	addi	s2,s2,-388 # ffffffffc0208e90 <slabs>
ffffffffc020201c:	00341993          	slli	s3,s0,0x3
ffffffffc0202020:	013907b3          	add	a5,s2,s3
ffffffffc0202024:	639c                	ld	a5,0(a5)
            while (slab != NULL && slab->free_head == NULL) slab = slab->next;
ffffffffc0202026:	e781                	bnez	a5,ffffffffc020202e <slub_alloc+0xdc>
ffffffffc0202028:	a015                	j	ffffffffc020204c <slub_alloc+0xfa>
ffffffffc020202a:	6b9c                	ld	a5,16(a5)
ffffffffc020202c:	c385                	beqz	a5,ffffffffc020204c <slub_alloc+0xfa>
ffffffffc020202e:	6f98                	ld	a4,24(a5)
ffffffffc0202030:	df6d                	beqz	a4,ffffffffc020202a <slub_alloc+0xd8>
            slab->inuse++;
ffffffffc0202032:	7f98                	ld	a4,56(a5)
ffffffffc0202034:	0705                	addi	a4,a4,1
            void *slot = slab->free_head;
ffffffffc0202036:	6f88                	ld	a0,24(a5)
}
ffffffffc0202038:	7402                	ld	s0,32(sp)
ffffffffc020203a:	70a2                	ld	ra,40(sp)
            slab->free_head = *(void **)slot;
ffffffffc020203c:	6114                	ld	a3,0(a0)
            slab->inuse++;
ffffffffc020203e:	ff98                	sd	a4,56(a5)
            return slot;
ffffffffc0202040:	64e2                	ld	s1,24(sp)
            slab->free_head = *(void **)slot;
ffffffffc0202042:	ef94                	sd	a3,24(a5)
            return slot;
ffffffffc0202044:	6942                	ld	s2,16(sp)
ffffffffc0202046:	69a2                	ld	s3,8(sp)
}
ffffffffc0202048:	6145                	addi	sp,sp,48
ffffffffc020204a:	8082                	ret
    struct Page *page = alloc_page();
ffffffffc020204c:	4505                	li	a0,1
ffffffffc020204e:	b0fff0ef          	jal	ffffffffc0201b5c <alloc_pages>
    if (page == NULL) return NULL;
ffffffffc0202052:	c951                	beqz	a0,ffffffffc02020e6 <slub_alloc+0x194>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202054:	00007797          	auipc	a5,0x7
ffffffffc0202058:	ecc7b783          	ld	a5,-308(a5) # ffffffffc0208f20 <pages>
ffffffffc020205c:	ccccd737          	lui	a4,0xccccd
ffffffffc0202060:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac3da1>
ffffffffc0202064:	02071693          	slli	a3,a4,0x20
ffffffffc0202068:	40f507b3          	sub	a5,a0,a5
ffffffffc020206c:	9736                	add	a4,a4,a3
ffffffffc020206e:	878d                	srai	a5,a5,0x3
ffffffffc0202070:	02e787b3          	mul	a5,a5,a4
ffffffffc0202074:	00002617          	auipc	a2,0x2
ffffffffc0202078:	0bc63603          	ld	a2,188(a2) # ffffffffc0204130 <nbase>
    struct slub_page *slab = (struct slub_page *)(page2pa(page) + va_pa_offset);
ffffffffc020207c:	00007697          	auipc	a3,0x7
ffffffffc0202080:	e946b683          	ld	a3,-364(a3) # ffffffffc0208f10 <va_pa_offset>
    size_t capacity = (PGSIZE - payload_offset()) / size;
ffffffffc0202084:	6705                	lui	a4,0x1
ffffffffc0202086:	fc070713          	addi	a4,a4,-64 # fc0 <kern_entry-0xffffffffc01ff040>
ffffffffc020208a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020208c:	07b2                	slli	a5,a5,0xc
    struct slub_page *slab = (struct slub_page *)(page2pa(page) + va_pa_offset);
ffffffffc020208e:	97b6                	add	a5,a5,a3
    size_t capacity = (PGSIZE - payload_offset()) / size;
ffffffffc0202090:	029756b3          	divu	a3,a4,s1
    assert(capacity > 0);
ffffffffc0202094:	08976163          	bltu	a4,s1,ffffffffc0202116 <slub_alloc+0x1c4>
    slab->magic = SLUB_MAGIC;
ffffffffc0202098:	fff68613          	addi	a2,a3,-1
    slab->next = slabs[class_index];
ffffffffc020209c:	013905b3          	add	a1,s2,s3
ffffffffc02020a0:	0005b883          	ld	a7,0(a1)
    slab->magic = SLUB_MAGIC;
ffffffffc02020a4:	00002817          	auipc	a6,0x2
ffffffffc02020a8:	08483803          	ld	a6,132(a6) # ffffffffc0204128 <error_string+0x48>
    slab->page_count = 1;
ffffffffc02020ac:	4585                	li	a1,1
    slab->capacity = capacity;
ffffffffc02020ae:	fb94                	sd	a3,48(a5)
    slab->page = page;
ffffffffc02020b0:	e788                	sd	a0,8(a5)
    slab->next = slabs[class_index];
ffffffffc02020b2:	0117b823          	sd	a7,16(a5)
    slab->class_index = class_index;
ffffffffc02020b6:	f780                	sd	s0,40(a5)
    slab->inuse = 0;
ffffffffc02020b8:	0207bc23          	sd	zero,56(a5)
    slab->magic = SLUB_MAGIC;
ffffffffc02020bc:	0107b023          	sd	a6,0(a5)
    slab->page_count = 1;
ffffffffc02020c0:	f38c                	sd	a1,32(a5)
    slab->inuse = 0;
ffffffffc02020c2:	4681                	li	a3,0
ffffffffc02020c4:	02960733          	mul	a4,a2,s1
ffffffffc02020c8:	04070713          	addi	a4,a4,64
ffffffffc02020cc:	973e                	add	a4,a4,a5
ffffffffc02020ce:	a011                	j	ffffffffc02020d2 <slub_alloc+0x180>
ffffffffc02020d0:	167d                	addi	a2,a2,-1
        *(void **)slot = slab->free_head;
ffffffffc02020d2:	e314                	sd	a3,0(a4)
        void *slot = (char *)slab + payload_offset() + (i - 1) * size;
ffffffffc02020d4:	86ba                	mv	a3,a4
    for (size_t i = capacity; i > 0; i--) {
ffffffffc02020d6:	8f05                	sub	a4,a4,s1
ffffffffc02020d8:	fe65                	bnez	a2,ffffffffc02020d0 <slub_alloc+0x17e>
ffffffffc02020da:	ef94                	sd	a3,24(a5)
    slabs[class_index] = slab;
ffffffffc02020dc:	994e                	add	s2,s2,s3
ffffffffc02020de:	00f93023          	sd	a5,0(s2)
            if (slab == NULL) return NULL;
ffffffffc02020e2:	4705                	li	a4,1
ffffffffc02020e4:	bf89                	j	ffffffffc0202036 <slub_alloc+0xe4>
ffffffffc02020e6:	64e2                	ld	s1,24(sp)
ffffffffc02020e8:	6942                	ld	s2,16(sp)
ffffffffc02020ea:	69a2                	ld	s3,8(sp)
    if (size == 0) return NULL;
ffffffffc02020ec:	4501                	li	a0,0
ffffffffc02020ee:	bf29                	j	ffffffffc0202008 <slub_alloc+0xb6>
    assert(initialized);
ffffffffc02020f0:	00002697          	auipc	a3,0x2
ffffffffc02020f4:	92868693          	addi	a3,a3,-1752 # ffffffffc0203a18 <etext+0xbb0>
ffffffffc02020f8:	00001617          	auipc	a2,0x1
ffffffffc02020fc:	fd860613          	addi	a2,a2,-40 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202100:	04800593          	li	a1,72
ffffffffc0202104:	00002517          	auipc	a0,0x2
ffffffffc0202108:	88450513          	addi	a0,a0,-1916 # ffffffffc0203988 <etext+0xb20>
ffffffffc020210c:	ec26                	sd	s1,24(sp)
ffffffffc020210e:	e84a                	sd	s2,16(sp)
ffffffffc0202110:	e44e                	sd	s3,8(sp)
ffffffffc0202112:	8b0fe0ef          	jal	ffffffffc02001c2 <__panic>
    assert(capacity > 0);
ffffffffc0202116:	00002697          	auipc	a3,0x2
ffffffffc020211a:	91268693          	addi	a3,a3,-1774 # ffffffffc0203a28 <etext+0xbc0>
ffffffffc020211e:	00001617          	auipc	a2,0x1
ffffffffc0202122:	fb260613          	addi	a2,a2,-78 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202126:	02a00593          	li	a1,42
ffffffffc020212a:	00002517          	auipc	a0,0x2
ffffffffc020212e:	85e50513          	addi	a0,a0,-1954 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202132:	890fe0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0202136 <slub_free>:
    if (ptr == NULL) return;
ffffffffc0202136:	cd79                	beqz	a0,ffffffffc0202214 <slub_free+0xde>
    assert(initialized);
ffffffffc0202138:	00007797          	auipc	a5,0x7
ffffffffc020213c:	df07a783          	lw	a5,-528(a5) # ffffffffc0208f28 <initialized>
slub_free(void *ptr) {
ffffffffc0202140:	1141                	addi	sp,sp,-16
ffffffffc0202142:	e406                	sd	ra,8(sp)
    assert(initialized);
ffffffffc0202144:	10078963          	beqz	a5,ffffffffc0202256 <slub_free+0x120>
        ((uintptr_t)ptr & ~((uintptr_t)PGSIZE - 1));
ffffffffc0202148:	76fd                	lui	a3,0xfffff
    assert(slab->magic == SLUB_MAGIC);
ffffffffc020214a:	534c57b7          	lui	a5,0x534c5
        ((uintptr_t)ptr & ~((uintptr_t)PGSIZE - 1));
ffffffffc020214e:	8ee9                	and	a3,a3,a0
    assert(slab->magic == SLUB_MAGIC);
ffffffffc0202150:	54278793          	addi	a5,a5,1346 # 534c5542 <kern_entry-0xffffffff6cd3aabe>
ffffffffc0202154:	50414737          	lui	a4,0x50414
ffffffffc0202158:	6290                	ld	a2,0(a3)
ffffffffc020215a:	1782                	slli	a5,a5,0x20
ffffffffc020215c:	74570713          	addi	a4,a4,1861 # 50414745 <kern_entry-0xffffffff6fdeb8bb>
ffffffffc0202160:	97ba                	add	a5,a5,a4
ffffffffc0202162:	0cf61a63          	bne	a2,a5,ffffffffc0202236 <slub_free+0x100>
    if (slab->class_index == SLUB_LARGE) {
ffffffffc0202166:	7698                	ld	a4,40(a3)
ffffffffc0202168:	57fd                	li	a5,-1
ffffffffc020216a:	08f70563          	beq	a4,a5,ffffffffc02021f4 <slub_free+0xbe>
    assert(index < NR_CLASSES && slab->inuse > 0);
ffffffffc020216e:	47a1                	li	a5,8
ffffffffc0202170:	12e7e363          	bltu	a5,a4,ffffffffc0202296 <slub_free+0x160>
ffffffffc0202174:	7e8c                	ld	a1,56(a3)
ffffffffc0202176:	12058063          	beqz	a1,ffffffffc0202296 <slub_free+0x160>
    size_t offset = (uintptr_t)ptr - (uintptr_t)slab;
ffffffffc020217a:	40d507b3          	sub	a5,a0,a3
    assert(offset >= payload_offset() &&
ffffffffc020217e:	03f00613          	li	a2,63
ffffffffc0202182:	0ef67a63          	bgeu	a2,a5,ffffffffc0202276 <slub_free+0x140>
ffffffffc0202186:	070e                	slli	a4,a4,0x3
ffffffffc0202188:	00002617          	auipc	a2,0x2
ffffffffc020218c:	cc060613          	addi	a2,a2,-832 # ffffffffc0203e48 <class_sizes>
ffffffffc0202190:	963a                	add	a2,a2,a4
ffffffffc0202192:	00063803          	ld	a6,0(a2)
ffffffffc0202196:	7a90                	ld	a2,48(a3)
ffffffffc0202198:	02c80633          	mul	a2,a6,a2
ffffffffc020219c:	04060613          	addi	a2,a2,64
ffffffffc02021a0:	0cc7fb63          	bgeu	a5,a2,ffffffffc0202276 <slub_free+0x140>
ffffffffc02021a4:	fc078793          	addi	a5,a5,-64
ffffffffc02021a8:	0307f7b3          	remu	a5,a5,a6
ffffffffc02021ac:	e7e9                	bnez	a5,ffffffffc0202276 <slub_free+0x140>
    *(void **)ptr = slab->free_head;
ffffffffc02021ae:	6e9c                	ld	a5,24(a3)
    if (--slab->inuse != 0) return;
ffffffffc02021b0:	15fd                	addi	a1,a1,-1
    *(void **)ptr = slab->free_head;
ffffffffc02021b2:	e11c                	sd	a5,0(a0)
    if (--slab->inuse != 0) return;
ffffffffc02021b4:	fe8c                	sd	a1,56(a3)
    slab->free_head = ptr;
ffffffffc02021b6:	ee88                	sd	a0,24(a3)
    if (--slab->inuse != 0) return;
ffffffffc02021b8:	ed99                	bnez	a1,ffffffffc02021d6 <slub_free+0xa0>
    struct slub_page **link = &slabs[index];
ffffffffc02021ba:	00007797          	auipc	a5,0x7
ffffffffc02021be:	cd678793          	addi	a5,a5,-810 # ffffffffc0208e90 <slabs>
ffffffffc02021c2:	973e                	add	a4,a4,a5
    while (*link != slab) {
ffffffffc02021c4:	631c                	ld	a5,0(a4)
ffffffffc02021c6:	00d78d63          	beq	a5,a3,ffffffffc02021e0 <slub_free+0xaa>
        assert(*link != NULL);
ffffffffc02021ca:	c7b1                	beqz	a5,ffffffffc0202216 <slub_free+0xe0>
        link = &(*link)->next;
ffffffffc02021cc:	6b98                	ld	a4,16(a5)
    while (*link != slab) {
ffffffffc02021ce:	00e68763          	beq	a3,a4,ffffffffc02021dc <slub_free+0xa6>
ffffffffc02021d2:	87ba                	mv	a5,a4
ffffffffc02021d4:	bfdd                	j	ffffffffc02021ca <slub_free+0x94>
}
ffffffffc02021d6:	60a2                	ld	ra,8(sp)
ffffffffc02021d8:	0141                	addi	sp,sp,16
ffffffffc02021da:	8082                	ret
        link = &(*link)->next;
ffffffffc02021dc:	01078713          	addi	a4,a5,16
    *link = slab->next;
ffffffffc02021e0:	6a9c                	ld	a5,16(a3)
    free_page(page);
ffffffffc02021e2:	6688                	ld	a0,8(a3)
}
ffffffffc02021e4:	60a2                	ld	ra,8(sp)
    *link = slab->next;
ffffffffc02021e6:	e31c                	sd	a5,0(a4)
    slab->magic = 0;
ffffffffc02021e8:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0x3fdf60d4>
    free_page(page);
ffffffffc02021ec:	4585                	li	a1,1
}
ffffffffc02021ee:	0141                	addi	sp,sp,16
    free_page(page);
ffffffffc02021f0:	979ff06f          	j	ffffffffc0201b68 <free_pages>
        assert(ptr == (char *)slab + payload_offset() && slab->inuse == 1);
ffffffffc02021f4:	04068793          	addi	a5,a3,64
ffffffffc02021f8:	0af51f63          	bne	a0,a5,ffffffffc02022b6 <slub_free+0x180>
ffffffffc02021fc:	7e98                	ld	a4,56(a3)
ffffffffc02021fe:	4785                	li	a5,1
ffffffffc0202200:	0af71b63          	bne	a4,a5,ffffffffc02022b6 <slub_free+0x180>
}
ffffffffc0202204:	60a2                	ld	ra,8(sp)
        free_pages(page, count);
ffffffffc0202206:	728c                	ld	a1,32(a3)
ffffffffc0202208:	6688                	ld	a0,8(a3)
    slab->magic = 0;
ffffffffc020220a:	0006b023          	sd	zero,0(a3)
}
ffffffffc020220e:	0141                	addi	sp,sp,16
    free_page(page);
ffffffffc0202210:	959ff06f          	j	ffffffffc0201b68 <free_pages>
ffffffffc0202214:	8082                	ret
        assert(*link != NULL);
ffffffffc0202216:	00002697          	auipc	a3,0x2
ffffffffc020221a:	94268693          	addi	a3,a3,-1726 # ffffffffc0203b58 <etext+0xcf0>
ffffffffc020221e:	00001617          	auipc	a2,0x1
ffffffffc0202222:	eb260613          	addi	a2,a2,-334 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202226:	08b00593          	li	a1,139
ffffffffc020222a:	00001517          	auipc	a0,0x1
ffffffffc020222e:	75e50513          	addi	a0,a0,1886 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202232:	f91fd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(slab->magic == SLUB_MAGIC);
ffffffffc0202236:	00002697          	auipc	a3,0x2
ffffffffc020223a:	80268693          	addi	a3,a3,-2046 # ffffffffc0203a38 <etext+0xbd0>
ffffffffc020223e:	00001617          	auipc	a2,0x1
ffffffffc0202242:	e9260613          	addi	a2,a2,-366 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202246:	07200593          	li	a1,114
ffffffffc020224a:	00001517          	auipc	a0,0x1
ffffffffc020224e:	73e50513          	addi	a0,a0,1854 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202252:	f71fd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(initialized);
ffffffffc0202256:	00001697          	auipc	a3,0x1
ffffffffc020225a:	7c268693          	addi	a3,a3,1986 # ffffffffc0203a18 <etext+0xbb0>
ffffffffc020225e:	00001617          	auipc	a2,0x1
ffffffffc0202262:	e7260613          	addi	a2,a2,-398 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202266:	06e00593          	li	a1,110
ffffffffc020226a:	00001517          	auipc	a0,0x1
ffffffffc020226e:	71e50513          	addi	a0,a0,1822 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202272:	f51fd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(offset >= payload_offset() &&
ffffffffc0202276:	00002697          	auipc	a3,0x2
ffffffffc020227a:	84a68693          	addi	a3,a3,-1974 # ffffffffc0203ac0 <etext+0xc58>
ffffffffc020227e:	00001617          	auipc	a2,0x1
ffffffffc0202282:	e5260613          	addi	a2,a2,-430 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202286:	08000593          	li	a1,128
ffffffffc020228a:	00001517          	auipc	a0,0x1
ffffffffc020228e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202292:	f31fd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(index < NR_CLASSES && slab->inuse > 0);
ffffffffc0202296:	00002697          	auipc	a3,0x2
ffffffffc020229a:	80268693          	addi	a3,a3,-2046 # ffffffffc0203a98 <etext+0xc30>
ffffffffc020229e:	00001617          	auipc	a2,0x1
ffffffffc02022a2:	e3260613          	addi	a2,a2,-462 # ffffffffc02030d0 <etext+0x268>
ffffffffc02022a6:	07e00593          	li	a1,126
ffffffffc02022aa:	00001517          	auipc	a0,0x1
ffffffffc02022ae:	6de50513          	addi	a0,a0,1758 # ffffffffc0203988 <etext+0xb20>
ffffffffc02022b2:	f11fd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(ptr == (char *)slab + payload_offset() && slab->inuse == 1);
ffffffffc02022b6:	00001697          	auipc	a3,0x1
ffffffffc02022ba:	7a268693          	addi	a3,a3,1954 # ffffffffc0203a58 <etext+0xbf0>
ffffffffc02022be:	00001617          	auipc	a2,0x1
ffffffffc02022c2:	e1260613          	addi	a2,a2,-494 # ffffffffc02030d0 <etext+0x268>
ffffffffc02022c6:	07500593          	li	a1,117
ffffffffc02022ca:	00001517          	auipc	a0,0x1
ffffffffc02022ce:	6be50513          	addi	a0,a0,1726 # ffffffffc0203988 <etext+0xb20>
ffffffffc02022d2:	ef1fd0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc02022d6 <slub_check>:
    }
}

void
slub_check(void) {
    assert(initialized);
ffffffffc02022d6:	00007797          	auipc	a5,0x7
ffffffffc02022da:	c527a783          	lw	a5,-942(a5) # ffffffffc0208f28 <initialized>
slub_check(void) {
ffffffffc02022de:	b0010113          	addi	sp,sp,-1280
ffffffffc02022e2:	4e113c23          	sd	ra,1272(sp)
ffffffffc02022e6:	4e813823          	sd	s0,1264(sp)
ffffffffc02022ea:	4e913423          	sd	s1,1256(sp)
ffffffffc02022ee:	4f213023          	sd	s2,1248(sp)
ffffffffc02022f2:	4d313c23          	sd	s3,1240(sp)
ffffffffc02022f6:	4d413823          	sd	s4,1232(sp)
ffffffffc02022fa:	4d513423          	sd	s5,1224(sp)
ffffffffc02022fe:	4d613023          	sd	s6,1216(sp)
ffffffffc0202302:	4b713c23          	sd	s7,1208(sp)
ffffffffc0202306:	4b813823          	sd	s8,1200(sp)
ffffffffc020230a:	4b913423          	sd	s9,1192(sp)
ffffffffc020230e:	4ba13023          	sd	s10,1184(sp)
ffffffffc0202312:	49b13c23          	sd	s11,1176(sp)
    assert(initialized);
ffffffffc0202316:	66078163          	beqz	a5,ffffffffc0202978 <slub_check+0x6a2>
    size_t baseline = nr_free_pages();
ffffffffc020231a:	85bff0ef          	jal	ffffffffc0201b74 <nr_free_pages>

    /* Exercise class boundaries, the largest slab class, and direct pages. */
    const size_t sizes[] = {
ffffffffc020231e:	00002497          	auipc	s1,0x2
ffffffffc0202322:	b7248493          	addi	s1,s1,-1166 # ffffffffc0203e90 <class_sizes+0x48>
    size_t baseline = nr_free_pages();
ffffffffc0202326:	892a                	mv	s2,a0
    const size_t sizes[] = {
ffffffffc0202328:	1998                	addi	a4,sp,240
ffffffffc020232a:	87a6                	mv	a5,s1
ffffffffc020232c:	00002697          	auipc	a3,0x2
ffffffffc0202330:	c0468693          	addi	a3,a3,-1020 # ffffffffc0203f30 <class_sizes+0xe8>
ffffffffc0202334:	0007b803          	ld	a6,0(a5)
ffffffffc0202338:	6788                	ld	a0,8(a5)
ffffffffc020233a:	6b8c                	ld	a1,16(a5)
ffffffffc020233c:	6f90                	ld	a2,24(a5)
ffffffffc020233e:	01073023          	sd	a6,0(a4)
ffffffffc0202342:	e708                	sd	a0,8(a4)
ffffffffc0202344:	eb0c                	sd	a1,16(a4)
ffffffffc0202346:	ef10                	sd	a2,24(a4)
ffffffffc0202348:	02078793          	addi	a5,a5,32
ffffffffc020234c:	02070713          	addi	a4,a4,32
ffffffffc0202350:	fed792e3          	bne	a5,a3,ffffffffc0202334 <slub_check+0x5e>
ffffffffc0202354:	6390                	ld	a2,0(a5)
ffffffffc0202356:	6794                	ld	a3,8(a5)
ffffffffc0202358:	6b9c                	ld	a5,16(a5)
ffffffffc020235a:	0f010b13          	addi	s6,sp,240
ffffffffc020235e:	e310                	sd	a2,0(a4)
ffffffffc0202360:	e714                	sd	a3,8(a4)
ffffffffc0202362:	eb1c                	sd	a5,16(a4)
        PGSIZE - sizeof(struct slub_page),
        PGSIZE - sizeof(struct slub_page) + 1,
        PGSIZE - 1, PGSIZE, PGSIZE + 1, 2 * PGSIZE + 13,
    };
    struct test_object objects[sizeof(sizes) / sizeof(sizes[0])];
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
ffffffffc0202364:	0500                	addi	s0,sp,640
ffffffffc0202366:	26810993          	addi	s3,sp,616
ffffffffc020236a:	4a810a13          	addi	s4,sp,1192
    const size_t sizes[] = {
ffffffffc020236e:	4a85                	li	s5,1
        objects[i].size = sizes[i];
ffffffffc0202370:	000b3503          	ld	a0,0(s6)
        objects[i].pattern = (unsigned char)(i + 1);
ffffffffc0202374:	ff540c23          	sb	s5,-8(s0)
        objects[i].size = sizes[i];
ffffffffc0202378:	fea43823          	sd	a0,-16(s0)
        objects[i].ptr = slub_alloc(sizes[i]);
ffffffffc020237c:	bd7ff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc0202380:	fea43423          	sd	a0,-24(s0)
        assert(objects[i].ptr != NULL);
ffffffffc0202384:	3e050a63          	beqz	a0,ffffffffc0202778 <slub_check+0x4a2>
        test_fill(&objects[i]);
ffffffffc0202388:	fe840513          	addi	a0,s0,-24
ffffffffc020238c:	a91ff0ef          	jal	ffffffffc0201e1c <test_fill>
    for (size_t i = 0; i < count; i++) {
ffffffffc0202390:	050c                	addi	a1,sp,640
ffffffffc0202392:	4501                	li	a0,0
        if (objects[i].ptr == NULL) continue;
ffffffffc0202394:	fe85b603          	ld	a2,-24(a1)
        for (size_t j = i + 1; j < count; j++) {
ffffffffc0202398:	0505                	addi	a0,a0,1
        if (objects[i].ptr == NULL) continue;
ffffffffc020239a:	c615                	beqz	a2,ffffffffc02023c6 <slub_check+0xf0>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc020239c:	03557863          	bgeu	a0,s5,ffffffffc02023cc <slub_check+0xf6>
ffffffffc02023a0:	87ae                	mv	a5,a1
            if (objects[j].ptr == NULL) continue;
ffffffffc02023a2:	6398                	ld	a4,0(a5)
ffffffffc02023a4:	cb11                	beqz	a4,ffffffffc02023b8 <slub_check+0xe2>
            assert(first + objects[i].size <= second ||
ffffffffc02023a6:	ff05b683          	ld	a3,-16(a1)
ffffffffc02023aa:	96b2                	add	a3,a3,a2
ffffffffc02023ac:	00d77663          	bgeu	a4,a3,ffffffffc02023b8 <slub_check+0xe2>
ffffffffc02023b0:	6794                	ld	a3,8(a5)
ffffffffc02023b2:	9736                	add	a4,a4,a3
ffffffffc02023b4:	3ae66263          	bltu	a2,a4,ffffffffc0202758 <slub_check+0x482>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02023b8:	07e1                	addi	a5,a5,24
ffffffffc02023ba:	fe8794e3          	bne	a5,s0,ffffffffc02023a2 <slub_check+0xcc>
        if (objects[i].ptr == NULL) continue;
ffffffffc02023be:	6190                	ld	a2,0(a1)
    for (size_t i = 0; i < count; i++) {
ffffffffc02023c0:	05e1                	addi	a1,a1,24
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02023c2:	0505                	addi	a0,a0,1
        if (objects[i].ptr == NULL) continue;
ffffffffc02023c4:	fe61                	bnez	a2,ffffffffc020239c <slub_check+0xc6>
    for (size_t i = 0; i < count; i++) {
ffffffffc02023c6:	05e1                	addi	a1,a1,24
ffffffffc02023c8:	fd5516e3          	bne	a0,s5,ffffffffc0202394 <slub_check+0xbe>
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
ffffffffc02023cc:	0461                	addi	s0,s0,24
ffffffffc02023ce:	0a85                	addi	s5,s5,1
ffffffffc02023d0:	0b21                	addi	s6,s6,8
ffffffffc02023d2:	f9441fe3          	bne	s0,s4,ffffffffc0202370 <slub_check+0x9a>
ffffffffc02023d6:	844e                	mv	s0,s3
        test_disjoint(objects, i + 1);
    }
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
        test_contents(&objects[i]);
ffffffffc02023d8:	8522                	mv	a0,s0
ffffffffc02023da:	abfff0ef          	jal	ffffffffc0201e98 <test_contents>
    for (size_t i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
ffffffffc02023de:	0461                	addi	s0,s0,24
ffffffffc02023e0:	49010793          	addi	a5,sp,1168
ffffffffc02023e4:	fef41ae3          	bne	s0,a5,ffffffffc02023d8 <slub_check+0x102>
ffffffffc02023e8:	47810413          	addi	s0,sp,1144
    }
    for (size_t i = sizeof(sizes) / sizeof(sizes[0]); i > 0; i--) {
        slub_free(objects[i - 1].ptr);
ffffffffc02023ec:	6008                	ld	a0,0(s0)
ffffffffc02023ee:	d49ff0ef          	jal	ffffffffc0202136 <slub_free>
    for (size_t i = sizeof(sizes) / sizeof(sizes[0]); i > 0; i--) {
ffffffffc02023f2:	87a2                	mv	a5,s0
ffffffffc02023f4:	1421                	addi	s0,s0,-24
ffffffffc02023f6:	ff379be3          	bne	a5,s3,ffffffffc02023ec <slub_check+0x116>
    }
    assert(nr_free_pages() == baseline);
ffffffffc02023fa:	f7aff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02023fe:	39251d63          	bne	a0,s2,ffffffffc0202798 <slub_check+0x4c2>
ffffffffc0202402:	0900                	addi	s0,sp,144
ffffffffc0202404:	89a2                	mv	s3,s0
ffffffffc0202406:	8b22                	mv	s6,s0
ffffffffc0202408:	04100a93          	li	s5,65

    /* Several objects share one slab; a released slot is immediately reusable. */
    struct test_object shared[4];
    for (size_t i = 0; i < 4; i++) {
        shared[i].size = 32;
ffffffffc020240c:	02000c13          	li	s8,32
        shared[i].pattern = (unsigned char)(0x41 + i);
        shared[i].ptr = slub_alloc(shared[i].size);
        assert(shared[i].ptr != NULL);
        test_fill(&shared[i]);
        assert(nr_free_pages() == baseline - 1);
ffffffffc0202410:	fff90a13          	addi	s4,s2,-1
    for (size_t i = 0; i < 4; i++) {
ffffffffc0202414:	04500b93          	li	s7,69
        shared[i].ptr = slub_alloc(shared[i].size);
ffffffffc0202418:	02000513          	li	a0,32
        shared[i].size = 32;
ffffffffc020241c:	018b3423          	sd	s8,8(s6)
        shared[i].pattern = (unsigned char)(0x41 + i);
ffffffffc0202420:	015b0823          	sb	s5,16(s6)
        shared[i].ptr = slub_alloc(shared[i].size);
ffffffffc0202424:	b2fff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc0202428:	00ab3023          	sd	a0,0(s6)
        assert(shared[i].ptr != NULL);
ffffffffc020242c:	38050663          	beqz	a0,ffffffffc02027b8 <slub_check+0x4e2>
        test_fill(&shared[i]);
ffffffffc0202430:	855a                	mv	a0,s6
ffffffffc0202432:	9ebff0ef          	jal	ffffffffc0201e1c <test_fill>
        assert(nr_free_pages() == baseline - 1);
ffffffffc0202436:	f3eff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc020243a:	39451f63          	bne	a0,s4,ffffffffc02027d8 <slub_check+0x502>
    for (size_t i = 0; i < 4; i++) {
ffffffffc020243e:	2a85                	addiw	s5,s5,1
ffffffffc0202440:	0ffafa93          	zext.b	s5,s5
ffffffffc0202444:	0b61                	addi	s6,s6,24
ffffffffc0202446:	fd7a99e3          	bne	s5,s7,ffffffffc0202418 <slub_check+0x142>
ffffffffc020244a:	85a2                	mv	a1,s0
        if (objects[i].ptr == NULL) continue;
ffffffffc020244c:	6190                	ld	a2,0(a1)
    for (size_t i = 0; i < count; i++) {
ffffffffc020244e:	4781                	li	a5,0
ffffffffc0202450:	4311                	li	t1,4
        for (size_t j = i + 1; j < count; j++) {
ffffffffc0202452:	488d                	li	a7,3
ffffffffc0202454:	04840513          	addi	a0,s0,72
ffffffffc0202458:	00178813          	addi	a6,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc020245c:	c61d                	beqz	a2,ffffffffc020248a <slub_check+0x1b4>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc020245e:	03178963          	beq	a5,a7,ffffffffc0202490 <slub_check+0x1ba>
ffffffffc0202462:	87ae                	mv	a5,a1
            if (objects[j].ptr == NULL) continue;
ffffffffc0202464:	6f98                	ld	a4,24(a5)
ffffffffc0202466:	cb09                	beqz	a4,ffffffffc0202478 <slub_check+0x1a2>
            assert(first + objects[i].size <= second ||
ffffffffc0202468:	6594                	ld	a3,8(a1)
ffffffffc020246a:	96b2                	add	a3,a3,a2
ffffffffc020246c:	00d77663          	bgeu	a4,a3,ffffffffc0202478 <slub_check+0x1a2>
ffffffffc0202470:	7394                	ld	a3,32(a5)
ffffffffc0202472:	9736                	add	a4,a4,a3
ffffffffc0202474:	2ee66263          	bltu	a2,a4,ffffffffc0202758 <slub_check+0x482>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc0202478:	07e1                	addi	a5,a5,24
ffffffffc020247a:	fea795e3          	bne	a5,a0,ffffffffc0202464 <slub_check+0x18e>
    for (size_t i = 0; i < count; i++) {
ffffffffc020247e:	05e1                	addi	a1,a1,24
        if (objects[i].ptr == NULL) continue;
ffffffffc0202480:	6190                	ld	a2,0(a1)
    assert(nr_free_pages() == baseline);
ffffffffc0202482:	87c2                	mv	a5,a6
        for (size_t j = i + 1; j < count; j++) {
ffffffffc0202484:	00178813          	addi	a6,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc0202488:	fa79                	bnez	a2,ffffffffc020245e <slub_check+0x188>
    for (size_t i = 0; i < count; i++) {
ffffffffc020248a:	05e1                	addi	a1,a1,24
ffffffffc020248c:	fe681ae3          	bne	a6,t1,ffffffffc0202480 <slub_check+0x1aa>
    }
    test_disjoint(shared, 4);
    void *released = shared[1].ptr;
ffffffffc0202490:	7baa                	ld	s7,168(sp)
    slub_free(released);
ffffffffc0202492:	06040a93          	addi	s5,s0,96
    shared[1].ptr = NULL;
    assert(nr_free_pages() == baseline - 1);
ffffffffc0202496:	8b22                	mv	s6,s0
    slub_free(released);
ffffffffc0202498:	855e                	mv	a0,s7
ffffffffc020249a:	c9dff0ef          	jal	ffffffffc0202136 <slub_free>
    shared[1].ptr = NULL;
ffffffffc020249e:	f502                	sd	zero,168(sp)
    assert(nr_free_pages() == baseline - 1);
ffffffffc02024a0:	ed4ff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02024a4:	34aa1a63          	bne	s4,a0,ffffffffc02027f8 <slub_check+0x522>
    for (size_t i = 0; i < 4; i++) {
        if (shared[i].ptr != NULL) test_contents(&shared[i]);
ffffffffc02024a8:	000b3783          	ld	a5,0(s6)
ffffffffc02024ac:	c781                	beqz	a5,ffffffffc02024b4 <slub_check+0x1de>
ffffffffc02024ae:	855a                	mv	a0,s6
ffffffffc02024b0:	9e9ff0ef          	jal	ffffffffc0201e98 <test_contents>
    for (size_t i = 0; i < 4; i++) {
ffffffffc02024b4:	0b61                	addi	s6,s6,24
ffffffffc02024b6:	ff5b19e3          	bne	s6,s5,ffffffffc02024a8 <slub_check+0x1d2>
    }
    shared[1].ptr = slub_alloc(32);
ffffffffc02024ba:	02000513          	li	a0,32
ffffffffc02024be:	a95ff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc02024c2:	f52a                	sd	a0,168(sp)
    assert(shared[1].ptr == released);
ffffffffc02024c4:	35751a63          	bne	a0,s7,ffffffffc0202818 <slub_check+0x542>
    test_fill(&shared[1]);
ffffffffc02024c8:	1128                	addi	a0,sp,168
ffffffffc02024ca:	953ff0ef          	jal	ffffffffc0201e1c <test_fill>
ffffffffc02024ce:	85a2                	mv	a1,s0
        if (objects[i].ptr == NULL) continue;
ffffffffc02024d0:	6190                	ld	a2,0(a1)
    for (size_t i = 0; i < count; i++) {
ffffffffc02024d2:	4781                	li	a5,0
ffffffffc02024d4:	04840513          	addi	a0,s0,72
ffffffffc02024d8:	4311                	li	t1,4
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02024da:	488d                	li	a7,3
ffffffffc02024dc:	00178813          	addi	a6,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc02024e0:	c61d                	beqz	a2,ffffffffc020250e <slub_check+0x238>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02024e2:	03178963          	beq	a5,a7,ffffffffc0202514 <slub_check+0x23e>
ffffffffc02024e6:	87ae                	mv	a5,a1
            if (objects[j].ptr == NULL) continue;
ffffffffc02024e8:	6f98                	ld	a4,24(a5)
ffffffffc02024ea:	cb09                	beqz	a4,ffffffffc02024fc <slub_check+0x226>
            assert(first + objects[i].size <= second ||
ffffffffc02024ec:	6594                	ld	a3,8(a1)
ffffffffc02024ee:	96b2                	add	a3,a3,a2
ffffffffc02024f0:	00d77663          	bgeu	a4,a3,ffffffffc02024fc <slub_check+0x226>
ffffffffc02024f4:	7394                	ld	a3,32(a5)
ffffffffc02024f6:	9736                	add	a4,a4,a3
ffffffffc02024f8:	26e66063          	bltu	a2,a4,ffffffffc0202758 <slub_check+0x482>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02024fc:	07e1                	addi	a5,a5,24
ffffffffc02024fe:	fea795e3          	bne	a5,a0,ffffffffc02024e8 <slub_check+0x212>
    for (size_t i = 0; i < count; i++) {
ffffffffc0202502:	05e1                	addi	a1,a1,24
        if (objects[i].ptr == NULL) continue;
ffffffffc0202504:	6190                	ld	a2,0(a1)
    assert(nr_free_pages() == baseline - 1);
ffffffffc0202506:	87c2                	mv	a5,a6
        for (size_t j = i + 1; j < count; j++) {
ffffffffc0202508:	00178813          	addi	a6,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc020250c:	fa79                	bnez	a2,ffffffffc02024e2 <slub_check+0x20c>
    for (size_t i = 0; i < count; i++) {
ffffffffc020250e:	05e1                	addi	a1,a1,24
ffffffffc0202510:	fe681ae3          	bne	a6,t1,ffffffffc0202504 <slub_check+0x22e>
    test_disjoint(shared, 4);
    for (size_t i = 0; i < 4; i++) test_contents(&shared[i]);
ffffffffc0202514:	8522                	mv	a0,s0
ffffffffc0202516:	983ff0ef          	jal	ffffffffc0201e98 <test_contents>
ffffffffc020251a:	1128                	addi	a0,sp,168
ffffffffc020251c:	97dff0ef          	jal	ffffffffc0201e98 <test_contents>
ffffffffc0202520:	0188                	addi	a0,sp,192
ffffffffc0202522:	977ff0ef          	jal	ffffffffc0201e98 <test_contents>
ffffffffc0202526:	09a8                	addi	a0,sp,216
ffffffffc0202528:	971ff0ef          	jal	ffffffffc0201e98 <test_contents>
    for (size_t i = 0; i < 4; i++) slub_free(shared[i].ptr);
ffffffffc020252c:	0009b503          	ld	a0,0(s3)
ffffffffc0202530:	09e1                	addi	s3,s3,24
ffffffffc0202532:	c05ff0ef          	jal	ffffffffc0202136 <slub_free>
ffffffffc0202536:	ff599be3          	bne	s3,s5,ffffffffc020252c <slub_check+0x256>
    assert(nr_free_pages() == baseline);
ffffffffc020253a:	e3aff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc020253e:	2f251d63          	bne	a0,s2,ffffffffc0202838 <slub_check+0x562>

    /* Invalid sizes and NULL release leave live objects and page count intact. */
    struct test_object guard = {slub_alloc(64), 64, 0xa5};
ffffffffc0202542:	04000513          	li	a0,64
ffffffffc0202546:	a0dff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc020254a:	04000713          	li	a4,64
ffffffffc020254e:	fa500793          	li	a5,-91
ffffffffc0202552:	e42a                	sd	a0,8(sp)
ffffffffc0202554:	e83a                	sd	a4,16(sp)
ffffffffc0202556:	00f10c23          	sb	a5,24(sp)
ffffffffc020255a:	842a                	mv	s0,a0
    assert(guard.ptr != NULL);
ffffffffc020255c:	2e050e63          	beqz	a0,ffffffffc0202858 <slub_check+0x582>
    test_fill(&guard);
ffffffffc0202560:	0028                	addi	a0,sp,8
ffffffffc0202562:	8bbff0ef          	jal	ffffffffc0201e1c <test_fill>
    size_t while_guard = nr_free_pages();
ffffffffc0202566:	e0eff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
    assert(initialized);
ffffffffc020256a:	00007797          	auipc	a5,0x7
ffffffffc020256e:	9be7a783          	lw	a5,-1602(a5) # ffffffffc0208f28 <initialized>
    size_t while_guard = nr_free_pages();
ffffffffc0202572:	89aa                	mv	s3,a0
    assert(initialized);
ffffffffc0202574:	30078263          	beqz	a5,ffffffffc0202878 <slub_check+0x5a2>
    assert(slub_alloc(0) == NULL);
    assert(slub_alloc((size_t)-1) == NULL);
ffffffffc0202578:	557d                	li	a0,-1
ffffffffc020257a:	9d9ff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc020257e:	30051d63          	bnez	a0,ffffffffc0202898 <slub_check+0x5c2>
    assert(slub_alloc((size_t)-2) == NULL);
ffffffffc0202582:	5579                	li	a0,-2
ffffffffc0202584:	9cfff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc0202588:	32051863          	bnez	a0,ffffffffc02028b8 <slub_check+0x5e2>
    slub_free(NULL);
    assert(nr_free_pages() == while_guard);
ffffffffc020258c:	de8ff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0202590:	35351463          	bne	a0,s3,ffffffffc02028d8 <slub_check+0x602>
    test_contents(&guard);
ffffffffc0202594:	0028                	addi	a0,sp,8
ffffffffc0202596:	903ff0ef          	jal	ffffffffc0201e98 <test_contents>
    slub_free(guard.ptr);
ffffffffc020259a:	8522                	mv	a0,s0
ffffffffc020259c:	b9bff0ef          	jal	ffffffffc0202136 <slub_free>
    assert(nr_free_pages() == baseline);
ffffffffc02025a0:	dd4ff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc02025a4:	35251a63          	bne	a0,s2,ffffffffc02028f8 <slub_check+0x622>

    /* Fixed mixed sequence checks that frees do not disturb survivors. */
    const size_t mixed_sizes[] = {8, 31, 64, 5000, 2030, PGSIZE + 17, 7, 1024};
ffffffffc02025a8:	0b84b883          	ld	a7,184(s1)
ffffffffc02025ac:	0c04b803          	ld	a6,192(s1)
ffffffffc02025b0:	64e8                	ld	a0,200(s1)
ffffffffc02025b2:	68ec                	ld	a1,208(s1)
ffffffffc02025b4:	6cf0                	ld	a2,216(s1)
ffffffffc02025b6:	70f4                	ld	a3,224(s1)
ffffffffc02025b8:	74f8                	ld	a4,232(s1)
ffffffffc02025ba:	78fc                	ld	a5,240(s1)
ffffffffc02025bc:	1320                	addi	s0,sp,424
ffffffffc02025be:	e8c6                	sd	a7,80(sp)
ffffffffc02025c0:	ecc2                	sd	a6,88(sp)
ffffffffc02025c2:	f0aa                	sd	a0,96(sp)
ffffffffc02025c4:	f4ae                	sd	a1,104(sp)
ffffffffc02025c6:	f8b2                	sd	a2,112(sp)
ffffffffc02025c8:	fcb6                	sd	a3,120(sp)
ffffffffc02025ca:	e13a                	sd	a4,128(sp)
ffffffffc02025cc:	e53e                	sd	a5,136(sp)
    struct test_object mixed[sizeof(mixed_sizes) / sizeof(mixed_sizes[0])];
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
ffffffffc02025ce:	8a22                	mv	s4,s0
    const size_t mixed_sizes[] = {8, 31, 64, 5000, 2030, PGSIZE + 17, 7, 1024};
ffffffffc02025d0:	89a2                	mv	s3,s0
ffffffffc02025d2:	05010a93          	addi	s5,sp,80
ffffffffc02025d6:	08000493          	li	s1,128
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
ffffffffc02025da:	08800b13          	li	s6,136
        mixed[i].size = mixed_sizes[i];
ffffffffc02025de:	000ab503          	ld	a0,0(s5)
        mixed[i].pattern = (unsigned char)(0x80 + i);
ffffffffc02025e2:	00998823          	sb	s1,16(s3)
        mixed[i].size = mixed_sizes[i];
ffffffffc02025e6:	00a9b423          	sd	a0,8(s3)
        mixed[i].ptr = slub_alloc(mixed[i].size);
ffffffffc02025ea:	969ff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc02025ee:	00a9b023          	sd	a0,0(s3)
        assert(mixed[i].ptr != NULL);
ffffffffc02025f2:	32050363          	beqz	a0,ffffffffc0202918 <slub_check+0x642>
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
ffffffffc02025f6:	2485                	addiw	s1,s1,1
        test_fill(&mixed[i]);
ffffffffc02025f8:	854e                	mv	a0,s3
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
ffffffffc02025fa:	0ff4f493          	zext.b	s1,s1
        test_fill(&mixed[i]);
ffffffffc02025fe:	81fff0ef          	jal	ffffffffc0201e1c <test_fill>
    for (size_t i = 0; i < sizeof(mixed_sizes) / sizeof(mixed_sizes[0]); i++) {
ffffffffc0202602:	0aa1                	addi	s5,s5,8
ffffffffc0202604:	09e1                	addi	s3,s3,24
ffffffffc0202606:	fd649ce3          	bne	s1,s6,ffffffffc02025de <slub_check+0x308>
    }
    const size_t replace_at[] = {1, 3, 5};
    const size_t replace_size[] = {16, 5001, 2049};
ffffffffc020260a:	6705                	lui	a4,0x1
ffffffffc020260c:	87ba                	mv	a5,a4
ffffffffc020260e:	80178793          	addi	a5,a5,-2047
ffffffffc0202612:	38970713          	addi	a4,a4,905 # 1389 <kern_entry-0xffffffffc01fec77>
    const size_t replace_at[] = {1, 3, 5};
ffffffffc0202616:	4505                	li	a0,1
ffffffffc0202618:	458d                	li	a1,3
ffffffffc020261a:	4615                	li	a2,5
    const size_t replace_size[] = {16, 5001, 2049};
ffffffffc020261c:	46c1                	li	a3,16
ffffffffc020261e:	e0ba                	sd	a4,64(sp)
ffffffffc0202620:	e4be                	sd	a5,72(sp)
    const size_t replace_at[] = {1, 3, 5};
ffffffffc0202622:	f02a                	sd	a0,32(sp)
ffffffffc0202624:	f42e                	sd	a1,40(sp)
ffffffffc0202626:	f832                	sd	a2,48(sp)
    const size_t replace_size[] = {16, 5001, 2049};
ffffffffc0202628:	fc36                	sd	a3,56(sp)
ffffffffc020262a:	02010b93          	addi	s7,sp,32
ffffffffc020262e:	03810b13          	addi	s6,sp,56
ffffffffc0202632:	0d000993          	li	s3,208
ffffffffc0202636:	0c040c93          	addi	s9,s0,192
    for (size_t i = 0; i < count; i++) {
ffffffffc020263a:	4aa1                	li	s5,8
        for (size_t j = i + 1; j < count; j++) {
ffffffffc020263c:	449d                	li	s1,7
    for (size_t i = 0; i < 3; i++) {
        size_t index = replace_at[i];
ffffffffc020263e:	000bbd83          	ld	s11,0(s7)
        slub_free(mixed[index].ptr);
ffffffffc0202642:	001d9d13          	slli	s10,s11,0x1
ffffffffc0202646:	01bd07b3          	add	a5,s10,s11
ffffffffc020264a:	078e                	slli	a5,a5,0x3
ffffffffc020264c:	00278c33          	add	s8,a5,sp
ffffffffc0202650:	1a8c3503          	ld	a0,424(s8)
ffffffffc0202654:	ae3ff0ef          	jal	ffffffffc0202136 <slub_free>
        mixed[index].ptr = NULL;
ffffffffc0202658:	1a0c3423          	sd	zero,424(s8)
ffffffffc020265c:	8c22                	mv	s8,s0
        for (size_t j = 0; j < sizeof(mixed) / sizeof(mixed[0]); j++) {
            if (mixed[j].ptr != NULL) test_contents(&mixed[j]);
ffffffffc020265e:	000c3783          	ld	a5,0(s8)
ffffffffc0202662:	c781                	beqz	a5,ffffffffc020266a <slub_check+0x394>
ffffffffc0202664:	8562                	mv	a0,s8
ffffffffc0202666:	833ff0ef          	jal	ffffffffc0201e98 <test_contents>
        for (size_t j = 0; j < sizeof(mixed) / sizeof(mixed[0]); j++) {
ffffffffc020266a:	0c61                	addi	s8,s8,24
ffffffffc020266c:	ff9c19e3          	bne	s8,s9,ffffffffc020265e <slub_check+0x388>
        }
        mixed[index].size = replace_size[i];
ffffffffc0202670:	000b3503          	ld	a0,0(s6)
ffffffffc0202674:	9d6e                	add	s10,s10,s11
ffffffffc0202676:	0d0e                	slli	s10,s10,0x3
ffffffffc0202678:	002d0db3          	add	s11,s10,sp
        mixed[index].pattern = (unsigned char)(0xd0 + i);
ffffffffc020267c:	1b3d8c23          	sb	s3,440(s11)
        mixed[index].size = replace_size[i];
ffffffffc0202680:	1aadb823          	sd	a0,432(s11)
        mixed[index].ptr = slub_alloc(mixed[index].size);
ffffffffc0202684:	8cfff0ef          	jal	ffffffffc0201f52 <slub_alloc>
ffffffffc0202688:	1aadb423          	sd	a0,424(s11)
        assert(mixed[index].ptr != NULL);
ffffffffc020268c:	2a050663          	beqz	a0,ffffffffc0202938 <slub_check+0x662>
        test_fill(&mixed[index]);
ffffffffc0202690:	01a40533          	add	a0,s0,s10
ffffffffc0202694:	f88ff0ef          	jal	ffffffffc0201e1c <test_fill>
        if (objects[i].ptr == NULL) continue;
ffffffffc0202698:	763a                	ld	a2,424(sp)
    for (size_t i = 0; i < count; i++) {
ffffffffc020269a:	4781                	li	a5,0
ffffffffc020269c:	038c                	addi	a1,sp,448
        for (size_t j = i + 1; j < count; j++) {
ffffffffc020269e:	00178513          	addi	a0,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc02026a2:	ca0d                	beqz	a2,ffffffffc02026d4 <slub_check+0x3fe>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02026a4:	02978b63          	beq	a5,s1,ffffffffc02026da <slub_check+0x404>
ffffffffc02026a8:	87ae                	mv	a5,a1
            if (objects[j].ptr == NULL) continue;
ffffffffc02026aa:	6398                	ld	a4,0(a5)
ffffffffc02026ac:	cb11                	beqz	a4,ffffffffc02026c0 <slub_check+0x3ea>
            assert(first + objects[i].size <= second ||
ffffffffc02026ae:	ff05b683          	ld	a3,-16(a1)
ffffffffc02026b2:	96b2                	add	a3,a3,a2
ffffffffc02026b4:	00d77663          	bgeu	a4,a3,ffffffffc02026c0 <slub_check+0x3ea>
ffffffffc02026b8:	6794                	ld	a3,8(a5)
ffffffffc02026ba:	9736                	add	a4,a4,a3
ffffffffc02026bc:	08e66e63          	bltu	a2,a4,ffffffffc0202758 <slub_check+0x482>
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02026c0:	07e1                	addi	a5,a5,24
ffffffffc02026c2:	ff9794e3          	bne	a5,s9,ffffffffc02026aa <slub_check+0x3d4>
    for (size_t i = 0; i < count; i++) {
ffffffffc02026c6:	05e1                	addi	a1,a1,24
        if (objects[i].ptr == NULL) continue;
ffffffffc02026c8:	fe85b603          	ld	a2,-24(a1)
        mixed[index].ptr = NULL;
ffffffffc02026cc:	87aa                	mv	a5,a0
        for (size_t j = i + 1; j < count; j++) {
ffffffffc02026ce:	00178513          	addi	a0,a5,1
        if (objects[i].ptr == NULL) continue;
ffffffffc02026d2:	fa69                	bnez	a2,ffffffffc02026a4 <slub_check+0x3ce>
    for (size_t i = 0; i < count; i++) {
ffffffffc02026d4:	05e1                	addi	a1,a1,24
ffffffffc02026d6:	ff5519e3          	bne	a0,s5,ffffffffc02026c8 <slub_check+0x3f2>
    for (size_t i = 0; i < 3; i++) {
ffffffffc02026da:	2985                	addiw	s3,s3,1
ffffffffc02026dc:	0ff9f993          	zext.b	s3,s3
ffffffffc02026e0:	0d300793          	li	a5,211
ffffffffc02026e4:	0ba1                	addi	s7,s7,8
ffffffffc02026e6:	0b21                	addi	s6,s6,8
ffffffffc02026e8:	f4f99be3          	bne	s3,a5,ffffffffc020263e <slub_check+0x368>
ffffffffc02026ec:	84a2                	mv	s1,s0
        test_disjoint(mixed, sizeof(mixed) / sizeof(mixed[0]));
    }
    for (size_t i = 0; i < sizeof(mixed) / sizeof(mixed[0]); i++) {
        test_contents(&mixed[i]);
ffffffffc02026ee:	8526                	mv	a0,s1
    for (size_t i = 0; i < sizeof(mixed) / sizeof(mixed[0]); i++) {
ffffffffc02026f0:	04e1                	addi	s1,s1,24
        test_contents(&mixed[i]);
ffffffffc02026f2:	fa6ff0ef          	jal	ffffffffc0201e98 <test_contents>
    for (size_t i = 0; i < sizeof(mixed) / sizeof(mixed[0]); i++) {
ffffffffc02026f6:	ff949ce3          	bne	s1,s9,ffffffffc02026ee <slub_check+0x418>
ffffffffc02026fa:	f4040413          	addi	s0,s0,-192
    }
    for (size_t i = sizeof(mixed) / sizeof(mixed[0]); i > 0; i--) {
        slub_free(mixed[i - 1].ptr);
ffffffffc02026fe:	0a8a3503          	ld	a0,168(s4)
    for (size_t i = sizeof(mixed) / sizeof(mixed[0]); i > 0; i--) {
ffffffffc0202702:	1a21                	addi	s4,s4,-24
        slub_free(mixed[i - 1].ptr);
ffffffffc0202704:	a33ff0ef          	jal	ffffffffc0202136 <slub_free>
    for (size_t i = sizeof(mixed) / sizeof(mixed[0]); i > 0; i--) {
ffffffffc0202708:	ff441be3          	bne	s0,s4,ffffffffc02026fe <slub_check+0x428>
    }
    assert(nr_free_pages() == baseline);
ffffffffc020270c:	c68ff0ef          	jal	ffffffffc0201b74 <nr_free_pages>
ffffffffc0202710:	25251463          	bne	a0,s2,ffffffffc0202958 <slub_check+0x682>
    cprintf("slub_check() succeeded!\n");
}
ffffffffc0202714:	4f013403          	ld	s0,1264(sp)
ffffffffc0202718:	4f813083          	ld	ra,1272(sp)
ffffffffc020271c:	4e813483          	ld	s1,1256(sp)
ffffffffc0202720:	4e013903          	ld	s2,1248(sp)
ffffffffc0202724:	4d813983          	ld	s3,1240(sp)
ffffffffc0202728:	4d013a03          	ld	s4,1232(sp)
ffffffffc020272c:	4c813a83          	ld	s5,1224(sp)
ffffffffc0202730:	4c013b03          	ld	s6,1216(sp)
ffffffffc0202734:	4b813b83          	ld	s7,1208(sp)
ffffffffc0202738:	4b013c03          	ld	s8,1200(sp)
ffffffffc020273c:	4a813c83          	ld	s9,1192(sp)
ffffffffc0202740:	4a013d03          	ld	s10,1184(sp)
ffffffffc0202744:	49813d83          	ld	s11,1176(sp)
    cprintf("slub_check() succeeded!\n");
ffffffffc0202748:	00001517          	auipc	a0,0x1
ffffffffc020274c:	5a850513          	addi	a0,a0,1448 # ffffffffc0203cf0 <etext+0xe88>
}
ffffffffc0202750:	50010113          	addi	sp,sp,1280
    cprintf("slub_check() succeeded!\n");
ffffffffc0202754:	9f9fd06f          	j	ffffffffc020014c <cprintf>
            assert(first + objects[i].size <= second ||
ffffffffc0202758:	00001697          	auipc	a3,0x1
ffffffffc020275c:	42868693          	addi	a3,a3,1064 # ffffffffc0203b80 <etext+0xd18>
ffffffffc0202760:	00001617          	auipc	a2,0x1
ffffffffc0202764:	97060613          	addi	a2,a2,-1680 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202768:	0b300593          	li	a1,179
ffffffffc020276c:	00001517          	auipc	a0,0x1
ffffffffc0202770:	21c50513          	addi	a0,a0,540 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202774:	a4ffd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(objects[i].ptr != NULL);
ffffffffc0202778:	00001697          	auipc	a3,0x1
ffffffffc020277c:	3f068693          	addi	a3,a3,1008 # ffffffffc0203b68 <etext+0xd00>
ffffffffc0202780:	00001617          	auipc	a2,0x1
ffffffffc0202784:	95060613          	addi	a2,a2,-1712 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202788:	0cb00593          	li	a1,203
ffffffffc020278c:	00001517          	auipc	a0,0x1
ffffffffc0202790:	1fc50513          	addi	a0,a0,508 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202794:	a2ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == baseline);
ffffffffc0202798:	00001697          	auipc	a3,0x1
ffffffffc020279c:	43068693          	addi	a3,a3,1072 # ffffffffc0203bc8 <etext+0xd60>
ffffffffc02027a0:	00001617          	auipc	a2,0x1
ffffffffc02027a4:	93060613          	addi	a2,a2,-1744 # ffffffffc02030d0 <etext+0x268>
ffffffffc02027a8:	0d500593          	li	a1,213
ffffffffc02027ac:	00001517          	auipc	a0,0x1
ffffffffc02027b0:	1dc50513          	addi	a0,a0,476 # ffffffffc0203988 <etext+0xb20>
ffffffffc02027b4:	a0ffd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(shared[i].ptr != NULL);
ffffffffc02027b8:	00001697          	auipc	a3,0x1
ffffffffc02027bc:	43068693          	addi	a3,a3,1072 # ffffffffc0203be8 <etext+0xd80>
ffffffffc02027c0:	00001617          	auipc	a2,0x1
ffffffffc02027c4:	91060613          	addi	a2,a2,-1776 # ffffffffc02030d0 <etext+0x268>
ffffffffc02027c8:	0dd00593          	li	a1,221
ffffffffc02027cc:	00001517          	auipc	a0,0x1
ffffffffc02027d0:	1bc50513          	addi	a0,a0,444 # ffffffffc0203988 <etext+0xb20>
ffffffffc02027d4:	9effd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(nr_free_pages() == baseline - 1);
ffffffffc02027d8:	00001697          	auipc	a3,0x1
ffffffffc02027dc:	42868693          	addi	a3,a3,1064 # ffffffffc0203c00 <etext+0xd98>
ffffffffc02027e0:	00001617          	auipc	a2,0x1
ffffffffc02027e4:	8f060613          	addi	a2,a2,-1808 # ffffffffc02030d0 <etext+0x268>
ffffffffc02027e8:	0df00593          	li	a1,223
ffffffffc02027ec:	00001517          	auipc	a0,0x1
ffffffffc02027f0:	19c50513          	addi	a0,a0,412 # ffffffffc0203988 <etext+0xb20>
ffffffffc02027f4:	9cffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == baseline - 1);
ffffffffc02027f8:	00001697          	auipc	a3,0x1
ffffffffc02027fc:	40868693          	addi	a3,a3,1032 # ffffffffc0203c00 <etext+0xd98>
ffffffffc0202800:	00001617          	auipc	a2,0x1
ffffffffc0202804:	8d060613          	addi	a2,a2,-1840 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202808:	0e500593          	li	a1,229
ffffffffc020280c:	00001517          	auipc	a0,0x1
ffffffffc0202810:	17c50513          	addi	a0,a0,380 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202814:	9affd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(shared[1].ptr == released);
ffffffffc0202818:	00001697          	auipc	a3,0x1
ffffffffc020281c:	40868693          	addi	a3,a3,1032 # ffffffffc0203c20 <etext+0xdb8>
ffffffffc0202820:	00001617          	auipc	a2,0x1
ffffffffc0202824:	8b060613          	addi	a2,a2,-1872 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202828:	0ea00593          	li	a1,234
ffffffffc020282c:	00001517          	auipc	a0,0x1
ffffffffc0202830:	15c50513          	addi	a0,a0,348 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202834:	98ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == baseline);
ffffffffc0202838:	00001697          	auipc	a3,0x1
ffffffffc020283c:	39068693          	addi	a3,a3,912 # ffffffffc0203bc8 <etext+0xd60>
ffffffffc0202840:	00001617          	auipc	a2,0x1
ffffffffc0202844:	89060613          	addi	a2,a2,-1904 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202848:	0ef00593          	li	a1,239
ffffffffc020284c:	00001517          	auipc	a0,0x1
ffffffffc0202850:	13c50513          	addi	a0,a0,316 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202854:	96ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(guard.ptr != NULL);
ffffffffc0202858:	00001697          	auipc	a3,0x1
ffffffffc020285c:	3e868693          	addi	a3,a3,1000 # ffffffffc0203c40 <etext+0xdd8>
ffffffffc0202860:	00001617          	auipc	a2,0x1
ffffffffc0202864:	87060613          	addi	a2,a2,-1936 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202868:	0f300593          	li	a1,243
ffffffffc020286c:	00001517          	auipc	a0,0x1
ffffffffc0202870:	11c50513          	addi	a0,a0,284 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202874:	94ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(initialized);
ffffffffc0202878:	00001697          	auipc	a3,0x1
ffffffffc020287c:	1a068693          	addi	a3,a3,416 # ffffffffc0203a18 <etext+0xbb0>
ffffffffc0202880:	00001617          	auipc	a2,0x1
ffffffffc0202884:	85060613          	addi	a2,a2,-1968 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202888:	04800593          	li	a1,72
ffffffffc020288c:	00001517          	auipc	a0,0x1
ffffffffc0202890:	0fc50513          	addi	a0,a0,252 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202894:	92ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(slub_alloc((size_t)-1) == NULL);
ffffffffc0202898:	00001697          	auipc	a3,0x1
ffffffffc020289c:	3c068693          	addi	a3,a3,960 # ffffffffc0203c58 <etext+0xdf0>
ffffffffc02028a0:	00001617          	auipc	a2,0x1
ffffffffc02028a4:	83060613          	addi	a2,a2,-2000 # ffffffffc02030d0 <etext+0x268>
ffffffffc02028a8:	0f700593          	li	a1,247
ffffffffc02028ac:	00001517          	auipc	a0,0x1
ffffffffc02028b0:	0dc50513          	addi	a0,a0,220 # ffffffffc0203988 <etext+0xb20>
ffffffffc02028b4:	90ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(slub_alloc((size_t)-2) == NULL);
ffffffffc02028b8:	00001697          	auipc	a3,0x1
ffffffffc02028bc:	3c068693          	addi	a3,a3,960 # ffffffffc0203c78 <etext+0xe10>
ffffffffc02028c0:	00001617          	auipc	a2,0x1
ffffffffc02028c4:	81060613          	addi	a2,a2,-2032 # ffffffffc02030d0 <etext+0x268>
ffffffffc02028c8:	0f800593          	li	a1,248
ffffffffc02028cc:	00001517          	auipc	a0,0x1
ffffffffc02028d0:	0bc50513          	addi	a0,a0,188 # ffffffffc0203988 <etext+0xb20>
ffffffffc02028d4:	8effd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == while_guard);
ffffffffc02028d8:	00001697          	auipc	a3,0x1
ffffffffc02028dc:	3c068693          	addi	a3,a3,960 # ffffffffc0203c98 <etext+0xe30>
ffffffffc02028e0:	00000617          	auipc	a2,0x0
ffffffffc02028e4:	7f060613          	addi	a2,a2,2032 # ffffffffc02030d0 <etext+0x268>
ffffffffc02028e8:	0fa00593          	li	a1,250
ffffffffc02028ec:	00001517          	auipc	a0,0x1
ffffffffc02028f0:	09c50513          	addi	a0,a0,156 # ffffffffc0203988 <etext+0xb20>
ffffffffc02028f4:	8cffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == baseline);
ffffffffc02028f8:	00001697          	auipc	a3,0x1
ffffffffc02028fc:	2d068693          	addi	a3,a3,720 # ffffffffc0203bc8 <etext+0xd60>
ffffffffc0202900:	00000617          	auipc	a2,0x0
ffffffffc0202904:	7d060613          	addi	a2,a2,2000 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202908:	0fd00593          	li	a1,253
ffffffffc020290c:	00001517          	auipc	a0,0x1
ffffffffc0202910:	07c50513          	addi	a0,a0,124 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202914:	8affd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(mixed[i].ptr != NULL);
ffffffffc0202918:	00001697          	auipc	a3,0x1
ffffffffc020291c:	3a068693          	addi	a3,a3,928 # ffffffffc0203cb8 <etext+0xe50>
ffffffffc0202920:	00000617          	auipc	a2,0x0
ffffffffc0202924:	7b060613          	addi	a2,a2,1968 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202928:	10600593          	li	a1,262
ffffffffc020292c:	00001517          	auipc	a0,0x1
ffffffffc0202930:	05c50513          	addi	a0,a0,92 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202934:	88ffd0ef          	jal	ffffffffc02001c2 <__panic>
        assert(mixed[index].ptr != NULL);
ffffffffc0202938:	00001697          	auipc	a3,0x1
ffffffffc020293c:	39868693          	addi	a3,a3,920 # ffffffffc0203cd0 <etext+0xe68>
ffffffffc0202940:	00000617          	auipc	a2,0x0
ffffffffc0202944:	79060613          	addi	a2,a2,1936 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202948:	11500593          	li	a1,277
ffffffffc020294c:	00001517          	auipc	a0,0x1
ffffffffc0202950:	03c50513          	addi	a0,a0,60 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202954:	86ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(nr_free_pages() == baseline);
ffffffffc0202958:	00001697          	auipc	a3,0x1
ffffffffc020295c:	27068693          	addi	a3,a3,624 # ffffffffc0203bc8 <etext+0xd60>
ffffffffc0202960:	00000617          	auipc	a2,0x0
ffffffffc0202964:	77060613          	addi	a2,a2,1904 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202968:	11f00593          	li	a1,287
ffffffffc020296c:	00001517          	auipc	a0,0x1
ffffffffc0202970:	01c50513          	addi	a0,a0,28 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202974:	84ffd0ef          	jal	ffffffffc02001c2 <__panic>
    assert(initialized);
ffffffffc0202978:	00001697          	auipc	a3,0x1
ffffffffc020297c:	0a068693          	addi	a3,a3,160 # ffffffffc0203a18 <etext+0xbb0>
ffffffffc0202980:	00000617          	auipc	a2,0x0
ffffffffc0202984:	75060613          	addi	a2,a2,1872 # ffffffffc02030d0 <etext+0x268>
ffffffffc0202988:	0bb00593          	li	a1,187
ffffffffc020298c:	00001517          	auipc	a0,0x1
ffffffffc0202990:	ffc50513          	addi	a0,a0,-4 # ffffffffc0203988 <etext+0xb20>
ffffffffc0202994:	82ffd0ef          	jal	ffffffffc02001c2 <__panic>

ffffffffc0202998 <printnum>:
ffffffffc0202998:	02069813          	slli	a6,a3,0x20
ffffffffc020299c:	7179                	addi	sp,sp,-48
ffffffffc020299e:	02085813          	srli	a6,a6,0x20
ffffffffc02029a2:	e052                	sd	s4,0(sp)
ffffffffc02029a4:	03067a33          	remu	s4,a2,a6
ffffffffc02029a8:	f022                	sd	s0,32(sp)
ffffffffc02029aa:	ec26                	sd	s1,24(sp)
ffffffffc02029ac:	e84a                	sd	s2,16(sp)
ffffffffc02029ae:	f406                	sd	ra,40(sp)
ffffffffc02029b0:	e44e                	sd	s3,8(sp)
ffffffffc02029b2:	84aa                	mv	s1,a0
ffffffffc02029b4:	892e                	mv	s2,a1
ffffffffc02029b6:	fff7041b          	addiw	s0,a4,-1
ffffffffc02029ba:	2a01                	sext.w	s4,s4
ffffffffc02029bc:	03067e63          	bgeu	a2,a6,ffffffffc02029f8 <printnum+0x60>
ffffffffc02029c0:	89be                	mv	s3,a5
ffffffffc02029c2:	00805763          	blez	s0,ffffffffc02029d0 <printnum+0x38>
ffffffffc02029c6:	347d                	addiw	s0,s0,-1
ffffffffc02029c8:	85ca                	mv	a1,s2
ffffffffc02029ca:	854e                	mv	a0,s3
ffffffffc02029cc:	9482                	jalr	s1
ffffffffc02029ce:	fc65                	bnez	s0,ffffffffc02029c6 <printnum+0x2e>
ffffffffc02029d0:	1a02                	slli	s4,s4,0x20
ffffffffc02029d2:	00001797          	auipc	a5,0x1
ffffffffc02029d6:	33e78793          	addi	a5,a5,830 # ffffffffc0203d10 <etext+0xea8>
ffffffffc02029da:	020a5a13          	srli	s4,s4,0x20
ffffffffc02029de:	9a3e                	add	s4,s4,a5
ffffffffc02029e0:	7402                	ld	s0,32(sp)
ffffffffc02029e2:	000a4503          	lbu	a0,0(s4)
ffffffffc02029e6:	70a2                	ld	ra,40(sp)
ffffffffc02029e8:	69a2                	ld	s3,8(sp)
ffffffffc02029ea:	6a02                	ld	s4,0(sp)
ffffffffc02029ec:	85ca                	mv	a1,s2
ffffffffc02029ee:	87a6                	mv	a5,s1
ffffffffc02029f0:	6942                	ld	s2,16(sp)
ffffffffc02029f2:	64e2                	ld	s1,24(sp)
ffffffffc02029f4:	6145                	addi	sp,sp,48
ffffffffc02029f6:	8782                	jr	a5
ffffffffc02029f8:	03065633          	divu	a2,a2,a6
ffffffffc02029fc:	8722                	mv	a4,s0
ffffffffc02029fe:	f9bff0ef          	jal	ffffffffc0202998 <printnum>
ffffffffc0202a02:	b7f9                	j	ffffffffc02029d0 <printnum+0x38>

ffffffffc0202a04 <vprintfmt>:
ffffffffc0202a04:	7119                	addi	sp,sp,-128
ffffffffc0202a06:	f4a6                	sd	s1,104(sp)
ffffffffc0202a08:	f0ca                	sd	s2,96(sp)
ffffffffc0202a0a:	ecce                	sd	s3,88(sp)
ffffffffc0202a0c:	e8d2                	sd	s4,80(sp)
ffffffffc0202a0e:	e4d6                	sd	s5,72(sp)
ffffffffc0202a10:	e0da                	sd	s6,64(sp)
ffffffffc0202a12:	fc5e                	sd	s7,56(sp)
ffffffffc0202a14:	f06a                	sd	s10,32(sp)
ffffffffc0202a16:	fc86                	sd	ra,120(sp)
ffffffffc0202a18:	f8a2                	sd	s0,112(sp)
ffffffffc0202a1a:	f862                	sd	s8,48(sp)
ffffffffc0202a1c:	f466                	sd	s9,40(sp)
ffffffffc0202a1e:	ec6e                	sd	s11,24(sp)
ffffffffc0202a20:	892a                	mv	s2,a0
ffffffffc0202a22:	84ae                	mv	s1,a1
ffffffffc0202a24:	8d32                	mv	s10,a2
ffffffffc0202a26:	8a36                	mv	s4,a3
ffffffffc0202a28:	02500993          	li	s3,37
ffffffffc0202a2c:	5b7d                	li	s6,-1
ffffffffc0202a2e:	00001a97          	auipc	s5,0x1
ffffffffc0202a32:	55aa8a93          	addi	s5,s5,1370 # ffffffffc0203f88 <class_sizes+0x140>
ffffffffc0202a36:	00001b97          	auipc	s7,0x1
ffffffffc0202a3a:	6aab8b93          	addi	s7,s7,1706 # ffffffffc02040e0 <error_string>
ffffffffc0202a3e:	000d4503          	lbu	a0,0(s10)
ffffffffc0202a42:	001d0413          	addi	s0,s10,1
ffffffffc0202a46:	01350a63          	beq	a0,s3,ffffffffc0202a5a <vprintfmt+0x56>
ffffffffc0202a4a:	c121                	beqz	a0,ffffffffc0202a8a <vprintfmt+0x86>
ffffffffc0202a4c:	85a6                	mv	a1,s1
ffffffffc0202a4e:	0405                	addi	s0,s0,1
ffffffffc0202a50:	9902                	jalr	s2
ffffffffc0202a52:	fff44503          	lbu	a0,-1(s0)
ffffffffc0202a56:	ff351ae3          	bne	a0,s3,ffffffffc0202a4a <vprintfmt+0x46>
ffffffffc0202a5a:	00044603          	lbu	a2,0(s0)
ffffffffc0202a5e:	02000793          	li	a5,32
ffffffffc0202a62:	4c81                	li	s9,0
ffffffffc0202a64:	4881                	li	a7,0
ffffffffc0202a66:	5c7d                	li	s8,-1
ffffffffc0202a68:	5dfd                	li	s11,-1
ffffffffc0202a6a:	05500513          	li	a0,85
ffffffffc0202a6e:	4825                	li	a6,9
ffffffffc0202a70:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0202a74:	0ff5f593          	zext.b	a1,a1
ffffffffc0202a78:	00140d13          	addi	s10,s0,1
ffffffffc0202a7c:	04b56263          	bltu	a0,a1,ffffffffc0202ac0 <vprintfmt+0xbc>
ffffffffc0202a80:	058a                	slli	a1,a1,0x2
ffffffffc0202a82:	95d6                	add	a1,a1,s5
ffffffffc0202a84:	4194                	lw	a3,0(a1)
ffffffffc0202a86:	96d6                	add	a3,a3,s5
ffffffffc0202a88:	8682                	jr	a3
ffffffffc0202a8a:	70e6                	ld	ra,120(sp)
ffffffffc0202a8c:	7446                	ld	s0,112(sp)
ffffffffc0202a8e:	74a6                	ld	s1,104(sp)
ffffffffc0202a90:	7906                	ld	s2,96(sp)
ffffffffc0202a92:	69e6                	ld	s3,88(sp)
ffffffffc0202a94:	6a46                	ld	s4,80(sp)
ffffffffc0202a96:	6aa6                	ld	s5,72(sp)
ffffffffc0202a98:	6b06                	ld	s6,64(sp)
ffffffffc0202a9a:	7be2                	ld	s7,56(sp)
ffffffffc0202a9c:	7c42                	ld	s8,48(sp)
ffffffffc0202a9e:	7ca2                	ld	s9,40(sp)
ffffffffc0202aa0:	7d02                	ld	s10,32(sp)
ffffffffc0202aa2:	6de2                	ld	s11,24(sp)
ffffffffc0202aa4:	6109                	addi	sp,sp,128
ffffffffc0202aa6:	8082                	ret
ffffffffc0202aa8:	87b2                	mv	a5,a2
ffffffffc0202aaa:	00144603          	lbu	a2,1(s0)
ffffffffc0202aae:	846a                	mv	s0,s10
ffffffffc0202ab0:	00140d13          	addi	s10,s0,1
ffffffffc0202ab4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0202ab8:	0ff5f593          	zext.b	a1,a1
ffffffffc0202abc:	fcb572e3          	bgeu	a0,a1,ffffffffc0202a80 <vprintfmt+0x7c>
ffffffffc0202ac0:	85a6                	mv	a1,s1
ffffffffc0202ac2:	02500513          	li	a0,37
ffffffffc0202ac6:	9902                	jalr	s2
ffffffffc0202ac8:	fff44783          	lbu	a5,-1(s0)
ffffffffc0202acc:	8d22                	mv	s10,s0
ffffffffc0202ace:	f73788e3          	beq	a5,s3,ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202ad2:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0202ad6:	1d7d                	addi	s10,s10,-1
ffffffffc0202ad8:	ff379de3          	bne	a5,s3,ffffffffc0202ad2 <vprintfmt+0xce>
ffffffffc0202adc:	b78d                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202ade:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0202ae2:	00144603          	lbu	a2,1(s0)
ffffffffc0202ae6:	846a                	mv	s0,s10
ffffffffc0202ae8:	fd06069b          	addiw	a3,a2,-48
ffffffffc0202aec:	0006059b          	sext.w	a1,a2
ffffffffc0202af0:	02d86463          	bltu	a6,a3,ffffffffc0202b18 <vprintfmt+0x114>
ffffffffc0202af4:	00144603          	lbu	a2,1(s0)
ffffffffc0202af8:	002c169b          	slliw	a3,s8,0x2
ffffffffc0202afc:	0186873b          	addw	a4,a3,s8
ffffffffc0202b00:	0017171b          	slliw	a4,a4,0x1
ffffffffc0202b04:	9f2d                	addw	a4,a4,a1
ffffffffc0202b06:	fd06069b          	addiw	a3,a2,-48
ffffffffc0202b0a:	0405                	addi	s0,s0,1
ffffffffc0202b0c:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0202b10:	0006059b          	sext.w	a1,a2
ffffffffc0202b14:	fed870e3          	bgeu	a6,a3,ffffffffc0202af4 <vprintfmt+0xf0>
ffffffffc0202b18:	f40ddce3          	bgez	s11,ffffffffc0202a70 <vprintfmt+0x6c>
ffffffffc0202b1c:	8de2                	mv	s11,s8
ffffffffc0202b1e:	5c7d                	li	s8,-1
ffffffffc0202b20:	bf81                	j	ffffffffc0202a70 <vprintfmt+0x6c>
ffffffffc0202b22:	fffdc693          	not	a3,s11
ffffffffc0202b26:	96fd                	srai	a3,a3,0x3f
ffffffffc0202b28:	00ddfdb3          	and	s11,s11,a3
ffffffffc0202b2c:	00144603          	lbu	a2,1(s0)
ffffffffc0202b30:	2d81                	sext.w	s11,s11
ffffffffc0202b32:	846a                	mv	s0,s10
ffffffffc0202b34:	bf35                	j	ffffffffc0202a70 <vprintfmt+0x6c>
ffffffffc0202b36:	000a2c03          	lw	s8,0(s4)
ffffffffc0202b3a:	00144603          	lbu	a2,1(s0)
ffffffffc0202b3e:	0a21                	addi	s4,s4,8
ffffffffc0202b40:	846a                	mv	s0,s10
ffffffffc0202b42:	bfd9                	j	ffffffffc0202b18 <vprintfmt+0x114>
ffffffffc0202b44:	4705                	li	a4,1
ffffffffc0202b46:	008a0593          	addi	a1,s4,8
ffffffffc0202b4a:	01174463          	blt	a4,a7,ffffffffc0202b52 <vprintfmt+0x14e>
ffffffffc0202b4e:	1a088e63          	beqz	a7,ffffffffc0202d0a <vprintfmt+0x306>
ffffffffc0202b52:	000a3603          	ld	a2,0(s4)
ffffffffc0202b56:	46c1                	li	a3,16
ffffffffc0202b58:	8a2e                	mv	s4,a1
ffffffffc0202b5a:	2781                	sext.w	a5,a5
ffffffffc0202b5c:	876e                	mv	a4,s11
ffffffffc0202b5e:	85a6                	mv	a1,s1
ffffffffc0202b60:	854a                	mv	a0,s2
ffffffffc0202b62:	e37ff0ef          	jal	ffffffffc0202998 <printnum>
ffffffffc0202b66:	bde1                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202b68:	000a2503          	lw	a0,0(s4)
ffffffffc0202b6c:	85a6                	mv	a1,s1
ffffffffc0202b6e:	0a21                	addi	s4,s4,8
ffffffffc0202b70:	9902                	jalr	s2
ffffffffc0202b72:	b5f1                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202b74:	4705                	li	a4,1
ffffffffc0202b76:	008a0593          	addi	a1,s4,8
ffffffffc0202b7a:	01174463          	blt	a4,a7,ffffffffc0202b82 <vprintfmt+0x17e>
ffffffffc0202b7e:	18088163          	beqz	a7,ffffffffc0202d00 <vprintfmt+0x2fc>
ffffffffc0202b82:	000a3603          	ld	a2,0(s4)
ffffffffc0202b86:	46a9                	li	a3,10
ffffffffc0202b88:	8a2e                	mv	s4,a1
ffffffffc0202b8a:	bfc1                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202b8c:	00144603          	lbu	a2,1(s0)
ffffffffc0202b90:	4c85                	li	s9,1
ffffffffc0202b92:	846a                	mv	s0,s10
ffffffffc0202b94:	bdf1                	j	ffffffffc0202a70 <vprintfmt+0x6c>
ffffffffc0202b96:	85a6                	mv	a1,s1
ffffffffc0202b98:	02500513          	li	a0,37
ffffffffc0202b9c:	9902                	jalr	s2
ffffffffc0202b9e:	b545                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202ba0:	00144603          	lbu	a2,1(s0)
ffffffffc0202ba4:	2885                	addiw	a7,a7,1
ffffffffc0202ba6:	846a                	mv	s0,s10
ffffffffc0202ba8:	b5e1                	j	ffffffffc0202a70 <vprintfmt+0x6c>
ffffffffc0202baa:	4705                	li	a4,1
ffffffffc0202bac:	008a0593          	addi	a1,s4,8
ffffffffc0202bb0:	01174463          	blt	a4,a7,ffffffffc0202bb8 <vprintfmt+0x1b4>
ffffffffc0202bb4:	14088163          	beqz	a7,ffffffffc0202cf6 <vprintfmt+0x2f2>
ffffffffc0202bb8:	000a3603          	ld	a2,0(s4)
ffffffffc0202bbc:	46a1                	li	a3,8
ffffffffc0202bbe:	8a2e                	mv	s4,a1
ffffffffc0202bc0:	bf69                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202bc2:	03000513          	li	a0,48
ffffffffc0202bc6:	85a6                	mv	a1,s1
ffffffffc0202bc8:	e03e                	sd	a5,0(sp)
ffffffffc0202bca:	9902                	jalr	s2
ffffffffc0202bcc:	85a6                	mv	a1,s1
ffffffffc0202bce:	07800513          	li	a0,120
ffffffffc0202bd2:	9902                	jalr	s2
ffffffffc0202bd4:	0a21                	addi	s4,s4,8
ffffffffc0202bd6:	6782                	ld	a5,0(sp)
ffffffffc0202bd8:	46c1                	li	a3,16
ffffffffc0202bda:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0202bde:	bfb5                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202be0:	000a3403          	ld	s0,0(s4)
ffffffffc0202be4:	008a0713          	addi	a4,s4,8
ffffffffc0202be8:	e03a                	sd	a4,0(sp)
ffffffffc0202bea:	14040263          	beqz	s0,ffffffffc0202d2e <vprintfmt+0x32a>
ffffffffc0202bee:	0fb05763          	blez	s11,ffffffffc0202cdc <vprintfmt+0x2d8>
ffffffffc0202bf2:	02d00693          	li	a3,45
ffffffffc0202bf6:	0cd79163          	bne	a5,a3,ffffffffc0202cb8 <vprintfmt+0x2b4>
ffffffffc0202bfa:	00044783          	lbu	a5,0(s0)
ffffffffc0202bfe:	0007851b          	sext.w	a0,a5
ffffffffc0202c02:	cf85                	beqz	a5,ffffffffc0202c3a <vprintfmt+0x236>
ffffffffc0202c04:	00140a13          	addi	s4,s0,1
ffffffffc0202c08:	05e00413          	li	s0,94
ffffffffc0202c0c:	000c4563          	bltz	s8,ffffffffc0202c16 <vprintfmt+0x212>
ffffffffc0202c10:	3c7d                	addiw	s8,s8,-1
ffffffffc0202c12:	036c0263          	beq	s8,s6,ffffffffc0202c36 <vprintfmt+0x232>
ffffffffc0202c16:	85a6                	mv	a1,s1
ffffffffc0202c18:	0e0c8e63          	beqz	s9,ffffffffc0202d14 <vprintfmt+0x310>
ffffffffc0202c1c:	3781                	addiw	a5,a5,-32
ffffffffc0202c1e:	0ef47b63          	bgeu	s0,a5,ffffffffc0202d14 <vprintfmt+0x310>
ffffffffc0202c22:	03f00513          	li	a0,63
ffffffffc0202c26:	9902                	jalr	s2
ffffffffc0202c28:	000a4783          	lbu	a5,0(s4)
ffffffffc0202c2c:	3dfd                	addiw	s11,s11,-1
ffffffffc0202c2e:	0a05                	addi	s4,s4,1
ffffffffc0202c30:	0007851b          	sext.w	a0,a5
ffffffffc0202c34:	ffe1                	bnez	a5,ffffffffc0202c0c <vprintfmt+0x208>
ffffffffc0202c36:	01b05963          	blez	s11,ffffffffc0202c48 <vprintfmt+0x244>
ffffffffc0202c3a:	3dfd                	addiw	s11,s11,-1
ffffffffc0202c3c:	85a6                	mv	a1,s1
ffffffffc0202c3e:	02000513          	li	a0,32
ffffffffc0202c42:	9902                	jalr	s2
ffffffffc0202c44:	fe0d9be3          	bnez	s11,ffffffffc0202c3a <vprintfmt+0x236>
ffffffffc0202c48:	6a02                	ld	s4,0(sp)
ffffffffc0202c4a:	bbd5                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202c4c:	4705                	li	a4,1
ffffffffc0202c4e:	008a0c93          	addi	s9,s4,8
ffffffffc0202c52:	01174463          	blt	a4,a7,ffffffffc0202c5a <vprintfmt+0x256>
ffffffffc0202c56:	08088d63          	beqz	a7,ffffffffc0202cf0 <vprintfmt+0x2ec>
ffffffffc0202c5a:	000a3403          	ld	s0,0(s4)
ffffffffc0202c5e:	0a044d63          	bltz	s0,ffffffffc0202d18 <vprintfmt+0x314>
ffffffffc0202c62:	8622                	mv	a2,s0
ffffffffc0202c64:	8a66                	mv	s4,s9
ffffffffc0202c66:	46a9                	li	a3,10
ffffffffc0202c68:	bdcd                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202c6a:	000a2783          	lw	a5,0(s4)
ffffffffc0202c6e:	4719                	li	a4,6
ffffffffc0202c70:	0a21                	addi	s4,s4,8
ffffffffc0202c72:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0202c76:	8fb5                	xor	a5,a5,a3
ffffffffc0202c78:	40d786bb          	subw	a3,a5,a3
ffffffffc0202c7c:	02d74163          	blt	a4,a3,ffffffffc0202c9e <vprintfmt+0x29a>
ffffffffc0202c80:	00369793          	slli	a5,a3,0x3
ffffffffc0202c84:	97de                	add	a5,a5,s7
ffffffffc0202c86:	639c                	ld	a5,0(a5)
ffffffffc0202c88:	cb99                	beqz	a5,ffffffffc0202c9e <vprintfmt+0x29a>
ffffffffc0202c8a:	86be                	mv	a3,a5
ffffffffc0202c8c:	00001617          	auipc	a2,0x1
ffffffffc0202c90:	0b460613          	addi	a2,a2,180 # ffffffffc0203d40 <etext+0xed8>
ffffffffc0202c94:	85a6                	mv	a1,s1
ffffffffc0202c96:	854a                	mv	a0,s2
ffffffffc0202c98:	0ce000ef          	jal	ffffffffc0202d66 <printfmt>
ffffffffc0202c9c:	b34d                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202c9e:	00001617          	auipc	a2,0x1
ffffffffc0202ca2:	09260613          	addi	a2,a2,146 # ffffffffc0203d30 <etext+0xec8>
ffffffffc0202ca6:	85a6                	mv	a1,s1
ffffffffc0202ca8:	854a                	mv	a0,s2
ffffffffc0202caa:	0bc000ef          	jal	ffffffffc0202d66 <printfmt>
ffffffffc0202cae:	bb41                	j	ffffffffc0202a3e <vprintfmt+0x3a>
ffffffffc0202cb0:	00001417          	auipc	s0,0x1
ffffffffc0202cb4:	07840413          	addi	s0,s0,120 # ffffffffc0203d28 <etext+0xec0>
ffffffffc0202cb8:	85e2                	mv	a1,s8
ffffffffc0202cba:	8522                	mv	a0,s0
ffffffffc0202cbc:	e43e                	sd	a5,8(sp)
ffffffffc0202cbe:	0fc000ef          	jal	ffffffffc0202dba <strnlen>
ffffffffc0202cc2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0202cc6:	01b05b63          	blez	s11,ffffffffc0202cdc <vprintfmt+0x2d8>
ffffffffc0202cca:	67a2                	ld	a5,8(sp)
ffffffffc0202ccc:	00078a1b          	sext.w	s4,a5
ffffffffc0202cd0:	3dfd                	addiw	s11,s11,-1
ffffffffc0202cd2:	85a6                	mv	a1,s1
ffffffffc0202cd4:	8552                	mv	a0,s4
ffffffffc0202cd6:	9902                	jalr	s2
ffffffffc0202cd8:	fe0d9ce3          	bnez	s11,ffffffffc0202cd0 <vprintfmt+0x2cc>
ffffffffc0202cdc:	00044783          	lbu	a5,0(s0)
ffffffffc0202ce0:	00140a13          	addi	s4,s0,1
ffffffffc0202ce4:	0007851b          	sext.w	a0,a5
ffffffffc0202ce8:	d3a5                	beqz	a5,ffffffffc0202c48 <vprintfmt+0x244>
ffffffffc0202cea:	05e00413          	li	s0,94
ffffffffc0202cee:	bf39                	j	ffffffffc0202c0c <vprintfmt+0x208>
ffffffffc0202cf0:	000a2403          	lw	s0,0(s4)
ffffffffc0202cf4:	b7ad                	j	ffffffffc0202c5e <vprintfmt+0x25a>
ffffffffc0202cf6:	000a6603          	lwu	a2,0(s4)
ffffffffc0202cfa:	46a1                	li	a3,8
ffffffffc0202cfc:	8a2e                	mv	s4,a1
ffffffffc0202cfe:	bdb1                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202d00:	000a6603          	lwu	a2,0(s4)
ffffffffc0202d04:	46a9                	li	a3,10
ffffffffc0202d06:	8a2e                	mv	s4,a1
ffffffffc0202d08:	bd89                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202d0a:	000a6603          	lwu	a2,0(s4)
ffffffffc0202d0e:	46c1                	li	a3,16
ffffffffc0202d10:	8a2e                	mv	s4,a1
ffffffffc0202d12:	b5a1                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202d14:	9902                	jalr	s2
ffffffffc0202d16:	bf09                	j	ffffffffc0202c28 <vprintfmt+0x224>
ffffffffc0202d18:	85a6                	mv	a1,s1
ffffffffc0202d1a:	02d00513          	li	a0,45
ffffffffc0202d1e:	e03e                	sd	a5,0(sp)
ffffffffc0202d20:	9902                	jalr	s2
ffffffffc0202d22:	6782                	ld	a5,0(sp)
ffffffffc0202d24:	8a66                	mv	s4,s9
ffffffffc0202d26:	40800633          	neg	a2,s0
ffffffffc0202d2a:	46a9                	li	a3,10
ffffffffc0202d2c:	b53d                	j	ffffffffc0202b5a <vprintfmt+0x156>
ffffffffc0202d2e:	03b05163          	blez	s11,ffffffffc0202d50 <vprintfmt+0x34c>
ffffffffc0202d32:	02d00693          	li	a3,45
ffffffffc0202d36:	f6d79de3          	bne	a5,a3,ffffffffc0202cb0 <vprintfmt+0x2ac>
ffffffffc0202d3a:	00001417          	auipc	s0,0x1
ffffffffc0202d3e:	fee40413          	addi	s0,s0,-18 # ffffffffc0203d28 <etext+0xec0>
ffffffffc0202d42:	02800793          	li	a5,40
ffffffffc0202d46:	02800513          	li	a0,40
ffffffffc0202d4a:	00140a13          	addi	s4,s0,1
ffffffffc0202d4e:	bd6d                	j	ffffffffc0202c08 <vprintfmt+0x204>
ffffffffc0202d50:	00001a17          	auipc	s4,0x1
ffffffffc0202d54:	fd9a0a13          	addi	s4,s4,-39 # ffffffffc0203d29 <etext+0xec1>
ffffffffc0202d58:	02800513          	li	a0,40
ffffffffc0202d5c:	02800793          	li	a5,40
ffffffffc0202d60:	05e00413          	li	s0,94
ffffffffc0202d64:	b565                	j	ffffffffc0202c0c <vprintfmt+0x208>

ffffffffc0202d66 <printfmt>:
ffffffffc0202d66:	715d                	addi	sp,sp,-80
ffffffffc0202d68:	02810313          	addi	t1,sp,40
ffffffffc0202d6c:	f436                	sd	a3,40(sp)
ffffffffc0202d6e:	869a                	mv	a3,t1
ffffffffc0202d70:	ec06                	sd	ra,24(sp)
ffffffffc0202d72:	f83a                	sd	a4,48(sp)
ffffffffc0202d74:	fc3e                	sd	a5,56(sp)
ffffffffc0202d76:	e0c2                	sd	a6,64(sp)
ffffffffc0202d78:	e4c6                	sd	a7,72(sp)
ffffffffc0202d7a:	e41a                	sd	t1,8(sp)
ffffffffc0202d7c:	c89ff0ef          	jal	ffffffffc0202a04 <vprintfmt>
ffffffffc0202d80:	60e2                	ld	ra,24(sp)
ffffffffc0202d82:	6161                	addi	sp,sp,80
ffffffffc0202d84:	8082                	ret

ffffffffc0202d86 <sbi_console_putchar>:
ffffffffc0202d86:	4781                	li	a5,0
ffffffffc0202d88:	00005717          	auipc	a4,0x5
ffffffffc0202d8c:	28873703          	ld	a4,648(a4) # ffffffffc0208010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0202d90:	88ba                	mv	a7,a4
ffffffffc0202d92:	852a                	mv	a0,a0
ffffffffc0202d94:	85be                	mv	a1,a5
ffffffffc0202d96:	863e                	mv	a2,a5
ffffffffc0202d98:	00000073          	ecall
ffffffffc0202d9c:	87aa                	mv	a5,a0
ffffffffc0202d9e:	8082                	ret

ffffffffc0202da0 <strlen>:
ffffffffc0202da0:	00054783          	lbu	a5,0(a0)
ffffffffc0202da4:	872a                	mv	a4,a0
ffffffffc0202da6:	4501                	li	a0,0
ffffffffc0202da8:	cb81                	beqz	a5,ffffffffc0202db8 <strlen+0x18>
ffffffffc0202daa:	0505                	addi	a0,a0,1
ffffffffc0202dac:	00a707b3          	add	a5,a4,a0
ffffffffc0202db0:	0007c783          	lbu	a5,0(a5)
ffffffffc0202db4:	fbfd                	bnez	a5,ffffffffc0202daa <strlen+0xa>
ffffffffc0202db6:	8082                	ret
ffffffffc0202db8:	8082                	ret

ffffffffc0202dba <strnlen>:
ffffffffc0202dba:	4781                	li	a5,0
ffffffffc0202dbc:	e589                	bnez	a1,ffffffffc0202dc6 <strnlen+0xc>
ffffffffc0202dbe:	a811                	j	ffffffffc0202dd2 <strnlen+0x18>
ffffffffc0202dc0:	0785                	addi	a5,a5,1
ffffffffc0202dc2:	00f58863          	beq	a1,a5,ffffffffc0202dd2 <strnlen+0x18>
ffffffffc0202dc6:	00f50733          	add	a4,a0,a5
ffffffffc0202dca:	00074703          	lbu	a4,0(a4)
ffffffffc0202dce:	fb6d                	bnez	a4,ffffffffc0202dc0 <strnlen+0x6>
ffffffffc0202dd0:	85be                	mv	a1,a5
ffffffffc0202dd2:	852e                	mv	a0,a1
ffffffffc0202dd4:	8082                	ret

ffffffffc0202dd6 <strcmp>:
ffffffffc0202dd6:	00054783          	lbu	a5,0(a0)
ffffffffc0202dda:	0005c703          	lbu	a4,0(a1)
ffffffffc0202dde:	cb89                	beqz	a5,ffffffffc0202df0 <strcmp+0x1a>
ffffffffc0202de0:	0505                	addi	a0,a0,1
ffffffffc0202de2:	0585                	addi	a1,a1,1
ffffffffc0202de4:	fee789e3          	beq	a5,a4,ffffffffc0202dd6 <strcmp>
ffffffffc0202de8:	0007851b          	sext.w	a0,a5
ffffffffc0202dec:	9d19                	subw	a0,a0,a4
ffffffffc0202dee:	8082                	ret
ffffffffc0202df0:	4501                	li	a0,0
ffffffffc0202df2:	bfed                	j	ffffffffc0202dec <strcmp+0x16>

ffffffffc0202df4 <strncmp>:
ffffffffc0202df4:	c20d                	beqz	a2,ffffffffc0202e16 <strncmp+0x22>
ffffffffc0202df6:	962e                	add	a2,a2,a1
ffffffffc0202df8:	a031                	j	ffffffffc0202e04 <strncmp+0x10>
ffffffffc0202dfa:	0505                	addi	a0,a0,1
ffffffffc0202dfc:	00e79a63          	bne	a5,a4,ffffffffc0202e10 <strncmp+0x1c>
ffffffffc0202e00:	00b60b63          	beq	a2,a1,ffffffffc0202e16 <strncmp+0x22>
ffffffffc0202e04:	00054783          	lbu	a5,0(a0)
ffffffffc0202e08:	0585                	addi	a1,a1,1
ffffffffc0202e0a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0202e0e:	f7f5                	bnez	a5,ffffffffc0202dfa <strncmp+0x6>
ffffffffc0202e10:	40e7853b          	subw	a0,a5,a4
ffffffffc0202e14:	8082                	ret
ffffffffc0202e16:	4501                	li	a0,0
ffffffffc0202e18:	8082                	ret

ffffffffc0202e1a <memset>:
ffffffffc0202e1a:	ca01                	beqz	a2,ffffffffc0202e2a <memset+0x10>
ffffffffc0202e1c:	962a                	add	a2,a2,a0
ffffffffc0202e1e:	87aa                	mv	a5,a0
ffffffffc0202e20:	0785                	addi	a5,a5,1
ffffffffc0202e22:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0202e26:	fec79de3          	bne	a5,a2,ffffffffc0202e20 <memset+0x6>
ffffffffc0202e2a:	8082                	ret

ffffffffc0202e2c <memcpy>:
ffffffffc0202e2c:	ca19                	beqz	a2,ffffffffc0202e42 <memcpy+0x16>
ffffffffc0202e2e:	962e                	add	a2,a2,a1
ffffffffc0202e30:	87aa                	mv	a5,a0
ffffffffc0202e32:	0005c703          	lbu	a4,0(a1)
ffffffffc0202e36:	0585                	addi	a1,a1,1
ffffffffc0202e38:	0785                	addi	a5,a5,1
ffffffffc0202e3a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0202e3e:	fec59ae3          	bne	a1,a2,ffffffffc0202e32 <memcpy+0x6>
ffffffffc0202e42:	8082                	ret

ffffffffc0202e44 <memcmp>:
ffffffffc0202e44:	c205                	beqz	a2,ffffffffc0202e64 <memcmp+0x20>
ffffffffc0202e46:	962e                	add	a2,a2,a1
ffffffffc0202e48:	a019                	j	ffffffffc0202e4e <memcmp+0xa>
ffffffffc0202e4a:	00c58d63          	beq	a1,a2,ffffffffc0202e64 <memcmp+0x20>
ffffffffc0202e4e:	00054783          	lbu	a5,0(a0)
ffffffffc0202e52:	0005c703          	lbu	a4,0(a1)
ffffffffc0202e56:	0505                	addi	a0,a0,1
ffffffffc0202e58:	0585                	addi	a1,a1,1
ffffffffc0202e5a:	fee788e3          	beq	a5,a4,ffffffffc0202e4a <memcmp+0x6>
ffffffffc0202e5e:	40e7853b          	subw	a0,a5,a4
ffffffffc0202e62:	8082                	ret
ffffffffc0202e64:	4501                	li	a0,0
ffffffffc0202e66:	8082                	ret
