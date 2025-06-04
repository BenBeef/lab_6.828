
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 5e 21 f0 00 	cmpl   $0x0,0xf0215e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 ce 08 00 00       	call   f0100929 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 5e 21 f0    	mov    %esi,0xf0215e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 9b 60 00 00       	call   f010610b <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 40 67 10 f0       	push   $0xf0106740
f010007c:	e8 07 3d 00 00       	call   f0103d88 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 d7 3c 00 00       	call   f0103d62 <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 ec 78 10 f0 	movl   $0xf01078ec,(%esp)
f0100092:	e8 f1 3c 00 00       	call   f0103d88 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 ae 05 00 00       	call   f0100656 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a8:	83 ec 08             	sub    $0x8,%esp
f01000ab:	68 ac 1a 00 00       	push   $0x1aac
f01000b0:	68 ac 67 10 f0       	push   $0xf01067ac
f01000b5:	e8 ce 3c 00 00       	call   f0103d88 <cprintf>
	mem_init();
f01000ba:	e8 ac 15 00 00       	call   f010166b <mem_init>
	env_init();
f01000bf:	e8 cc 33 00 00       	call   f0103490 <env_init>
	trap_init();
f01000c4:	e8 da 3d 00 00       	call   f0103ea3 <trap_init>
	mp_init();
f01000c9:	e8 2b 5d 00 00       	call   f0105df9 <mp_init>
	lapic_init();
f01000ce:	e8 52 60 00 00       	call   f0106125 <lapic_init>
	pic_init();
f01000d3:	e8 d3 3b 00 00       	call   f0103cab <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d8:	c7 04 24 e0 27 12 f0 	movl   $0xf01227e0,(%esp)
f01000df:	e8 97 62 00 00       	call   f010637b <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e4:	83 c4 10             	add    $0x10,%esp
f01000e7:	83 3d 88 5e 21 f0 07 	cmpl   $0x7,0xf0215e88
f01000ee:	76 27                	jbe    f0100117 <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f0:	83 ec 04             	sub    $0x4,%esp
f01000f3:	b8 5e 5d 10 f0       	mov    $0xf0105d5e,%eax
f01000f8:	2d e4 5c 10 f0       	sub    $0xf0105ce4,%eax
f01000fd:	50                   	push   %eax
f01000fe:	68 e4 5c 10 f0       	push   $0xf0105ce4
f0100103:	68 00 70 00 f0       	push   $0xf0007000
f0100108:	e8 28 5a 00 00       	call   f0105b35 <memmove>
f010010d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	bb 20 60 21 f0       	mov    $0xf0216020,%ebx
f0100115:	eb 19                	jmp    f0100130 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100117:	68 00 70 00 00       	push   $0x7000
f010011c:	68 64 67 10 f0       	push   $0xf0106764
f0100121:	6a 53                	push   $0x53
f0100123:	68 c7 67 10 f0       	push   $0xf01067c7
f0100128:	e8 13 ff ff ff       	call   f0100040 <_panic>
f010012d:	83 c3 74             	add    $0x74,%ebx
f0100130:	6b 05 c4 63 21 f0 74 	imul   $0x74,0xf02163c4,%eax
f0100137:	05 20 60 21 f0       	add    $0xf0216020,%eax
f010013c:	39 c3                	cmp    %eax,%ebx
f010013e:	73 4c                	jae    f010018c <i386_init+0xf0>
		if (c == cpus + cpunum())  // We've started already.
f0100140:	e8 c6 5f 00 00       	call   f010610b <cpunum>
f0100145:	6b c0 74             	imul   $0x74,%eax,%eax
f0100148:	05 20 60 21 f0       	add    $0xf0216020,%eax
f010014d:	39 c3                	cmp    %eax,%ebx
f010014f:	74 dc                	je     f010012d <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100151:	89 d8                	mov    %ebx,%eax
f0100153:	2d 20 60 21 f0       	sub    $0xf0216020,%eax
f0100158:	c1 f8 02             	sar    $0x2,%eax
f010015b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100161:	c1 e0 0f             	shl    $0xf,%eax
f0100164:	05 00 f0 21 f0       	add    $0xf021f000,%eax
f0100169:	a3 84 5e 21 f0       	mov    %eax,0xf0215e84
		lapic_startap(c->cpu_id, PADDR(code));
f010016e:	83 ec 08             	sub    $0x8,%esp
f0100171:	68 00 70 00 00       	push   $0x7000
f0100176:	0f b6 03             	movzbl (%ebx),%eax
f0100179:	50                   	push   %eax
f010017a:	e8 f7 60 00 00       	call   f0106276 <lapic_startap>
f010017f:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100182:	8b 43 04             	mov    0x4(%ebx),%eax
f0100185:	83 f8 01             	cmp    $0x1,%eax
f0100188:	75 f8                	jne    f0100182 <i386_init+0xe6>
f010018a:	eb a1                	jmp    f010012d <i386_init+0x91>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010018c:	83 ec 08             	sub    $0x8,%esp
f010018f:	6a 01                	push   $0x1
f0100191:	68 10 2d 1d f0       	push   $0xf01d2d10
f0100196:	e8 9b 34 00 00       	call   f0103636 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019b:	83 c4 08             	add    $0x8,%esp
f010019e:	6a 00                	push   $0x0
f01001a0:	68 58 ea 20 f0       	push   $0xf020ea58
f01001a5:	e8 8c 34 00 00       	call   f0103636 <env_create>
	kbd_intr();
f01001aa:	e8 4c 04 00 00       	call   f01005fb <kbd_intr>
	sched_yield();
f01001af:	e8 6a 46 00 00       	call   f010481e <sched_yield>

f01001b4 <mp_main>:
{
f01001b4:	55                   	push   %ebp
f01001b5:	89 e5                	mov    %esp,%ebp
f01001b7:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001ba:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c4:	77 12                	ja     f01001d8 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c6:	50                   	push   %eax
f01001c7:	68 88 67 10 f0       	push   $0xf0106788
f01001cc:	6a 6a                	push   $0x6a
f01001ce:	68 c7 67 10 f0       	push   $0xf01067c7
f01001d3:	e8 68 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001d8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001dd:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001e0:	e8 26 5f 00 00       	call   f010610b <cpunum>
f01001e5:	83 ec 08             	sub    $0x8,%esp
f01001e8:	50                   	push   %eax
f01001e9:	68 d3 67 10 f0       	push   $0xf01067d3
f01001ee:	e8 95 3b 00 00       	call   f0103d88 <cprintf>
	lapic_init();
f01001f3:	e8 2d 5f 00 00       	call   f0106125 <lapic_init>
	env_init_percpu();
f01001f8:	e8 63 32 00 00       	call   f0103460 <env_init_percpu>
	trap_init_percpu();
f01001fd:	e8 9a 3b 00 00       	call   f0103d9c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100202:	e8 04 5f 00 00       	call   f010610b <cpunum>
f0100207:	6b d0 74             	imul   $0x74,%eax,%edx
f010020a:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100212:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
f0100219:	c7 04 24 e0 27 12 f0 	movl   $0xf01227e0,(%esp)
f0100220:	e8 56 61 00 00       	call   f010637b <spin_lock>
    sched_yield();
f0100225:	e8 f4 45 00 00       	call   f010481e <sched_yield>

f010022a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	53                   	push   %ebx
f010022e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100231:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100234:	ff 75 0c             	pushl  0xc(%ebp)
f0100237:	ff 75 08             	pushl  0x8(%ebp)
f010023a:	68 e9 67 10 f0       	push   $0xf01067e9
f010023f:	e8 44 3b 00 00       	call   f0103d88 <cprintf>
	vcprintf(fmt, ap);
f0100244:	83 c4 08             	add    $0x8,%esp
f0100247:	53                   	push   %ebx
f0100248:	ff 75 10             	pushl  0x10(%ebp)
f010024b:	e8 12 3b 00 00       	call   f0103d62 <vcprintf>
	cprintf("\n");
f0100250:	c7 04 24 ec 78 10 f0 	movl   $0xf01078ec,(%esp)
f0100257:	e8 2c 3b 00 00       	call   f0103d88 <cprintf>
	va_end(ap);
}
f010025c:	83 c4 10             	add    $0x10,%esp
f010025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100262:	c9                   	leave  
f0100263:	c3                   	ret    

f0100264 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100267:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026d:	a8 01                	test   $0x1,%al
f010026f:	74 0b                	je     f010027c <serial_proc_data+0x18>
f0100271:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100276:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100277:	0f b6 c0             	movzbl %al,%eax
}
f010027a:	5d                   	pop    %ebp
f010027b:	c3                   	ret    
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	eb f7                	jmp    f010027a <serial_proc_data+0x16>

f0100283 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100283:	55                   	push   %ebp
f0100284:	89 e5                	mov    %esp,%ebp
f0100286:	53                   	push   %ebx
f0100287:	83 ec 04             	sub    $0x4,%esp
f010028a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028c:	ff d3                	call   *%ebx
f010028e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100291:	74 2d                	je     f01002c0 <cons_intr+0x3d>
		if (c == 0)
f0100293:	85 c0                	test   %eax,%eax
f0100295:	74 f5                	je     f010028c <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100297:	8b 0d 24 52 21 f0    	mov    0xf0215224,%ecx
f010029d:	8d 51 01             	lea    0x1(%ecx),%edx
f01002a0:	89 15 24 52 21 f0    	mov    %edx,0xf0215224
f01002a6:	88 81 20 50 21 f0    	mov    %al,-0xfdeafe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ac:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002b2:	75 d8                	jne    f010028c <cons_intr+0x9>
			cons.wpos = 0;
f01002b4:	c7 05 24 52 21 f0 00 	movl   $0x0,0xf0215224
f01002bb:	00 00 00 
f01002be:	eb cc                	jmp    f010028c <cons_intr+0x9>
	}
}
f01002c0:	83 c4 04             	add    $0x4,%esp
f01002c3:	5b                   	pop    %ebx
f01002c4:	5d                   	pop    %ebp
f01002c5:	c3                   	ret    

f01002c6 <kbd_proc_data>:
{
f01002c6:	55                   	push   %ebp
f01002c7:	89 e5                	mov    %esp,%ebp
f01002c9:	53                   	push   %ebx
f01002ca:	83 ec 04             	sub    $0x4,%esp
f01002cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01002d2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002d3:	a8 01                	test   $0x1,%al
f01002d5:	0f 84 fa 00 00 00    	je     f01003d5 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002db:	a8 20                	test   $0x20,%al
f01002dd:	0f 85 f9 00 00 00    	jne    f01003dc <kbd_proc_data+0x116>
f01002e3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002eb:	3c e0                	cmp    $0xe0,%al
f01002ed:	0f 84 8e 00 00 00    	je     f0100381 <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	0f 88 99 00 00 00    	js     f0100394 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002fb:	8b 0d 00 50 21 f0    	mov    0xf0215000,%ecx
f0100301:	f6 c1 40             	test   $0x40,%cl
f0100304:	74 0e                	je     f0100314 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100306:	83 c8 80             	or     $0xffffff80,%eax
f0100309:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010030b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010030e:	89 0d 00 50 21 f0    	mov    %ecx,0xf0215000
	shift |= shiftcode[data];
f0100314:	0f b6 d2             	movzbl %dl,%edx
f0100317:	0f b6 82 60 69 10 f0 	movzbl -0xfef96a0(%edx),%eax
f010031e:	0b 05 00 50 21 f0    	or     0xf0215000,%eax
	shift ^= togglecode[data];
f0100324:	0f b6 8a 60 68 10 f0 	movzbl -0xfef97a0(%edx),%ecx
f010032b:	31 c8                	xor    %ecx,%eax
f010032d:	a3 00 50 21 f0       	mov    %eax,0xf0215000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100332:	89 c1                	mov    %eax,%ecx
f0100334:	83 e1 03             	and    $0x3,%ecx
f0100337:	8b 0c 8d 40 68 10 f0 	mov    -0xfef97c0(,%ecx,4),%ecx
f010033e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100342:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100345:	a8 08                	test   $0x8,%al
f0100347:	74 0d                	je     f0100356 <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f0100349:	89 da                	mov    %ebx,%edx
f010034b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010034e:	83 f9 19             	cmp    $0x19,%ecx
f0100351:	77 74                	ja     f01003c7 <kbd_proc_data+0x101>
			c += 'A' - 'a';
f0100353:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100356:	f7 d0                	not    %eax
f0100358:	a8 06                	test   $0x6,%al
f010035a:	75 31                	jne    f010038d <kbd_proc_data+0xc7>
f010035c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100362:	75 29                	jne    f010038d <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100364:	83 ec 0c             	sub    $0xc,%esp
f0100367:	68 03 68 10 f0       	push   $0xf0106803
f010036c:	e8 17 3a 00 00       	call   f0103d88 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100371:	b8 03 00 00 00       	mov    $0x3,%eax
f0100376:	ba 92 00 00 00       	mov    $0x92,%edx
f010037b:	ee                   	out    %al,(%dx)
f010037c:	83 c4 10             	add    $0x10,%esp
f010037f:	eb 0c                	jmp    f010038d <kbd_proc_data+0xc7>
		shift |= E0ESC;
f0100381:	83 0d 00 50 21 f0 40 	orl    $0x40,0xf0215000
		return 0;
f0100388:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010038d:	89 d8                	mov    %ebx,%eax
f010038f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100392:	c9                   	leave  
f0100393:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100394:	8b 0d 00 50 21 f0    	mov    0xf0215000,%ecx
f010039a:	89 cb                	mov    %ecx,%ebx
f010039c:	83 e3 40             	and    $0x40,%ebx
f010039f:	83 e0 7f             	and    $0x7f,%eax
f01003a2:	85 db                	test   %ebx,%ebx
f01003a4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003a7:	0f b6 d2             	movzbl %dl,%edx
f01003aa:	0f b6 82 60 69 10 f0 	movzbl -0xfef96a0(%edx),%eax
f01003b1:	83 c8 40             	or     $0x40,%eax
f01003b4:	0f b6 c0             	movzbl %al,%eax
f01003b7:	f7 d0                	not    %eax
f01003b9:	21 c8                	and    %ecx,%eax
f01003bb:	a3 00 50 21 f0       	mov    %eax,0xf0215000
		return 0;
f01003c0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c5:	eb c6                	jmp    f010038d <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003c7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ca:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003cd:	83 fa 1a             	cmp    $0x1a,%edx
f01003d0:	0f 42 d9             	cmovb  %ecx,%ebx
f01003d3:	eb 81                	jmp    f0100356 <kbd_proc_data+0x90>
		return -1;
f01003d5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003da:	eb b1                	jmp    f010038d <kbd_proc_data+0xc7>
		return -1;
f01003dc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003e1:	eb aa                	jmp    f010038d <kbd_proc_data+0xc7>

f01003e3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e3:	55                   	push   %ebp
f01003e4:	89 e5                	mov    %esp,%ebp
f01003e6:	57                   	push   %edi
f01003e7:	56                   	push   %esi
f01003e8:	53                   	push   %ebx
f01003e9:	83 ec 1c             	sub    $0x1c,%esp
f01003ec:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f3:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fd:	eb 09                	jmp    f0100408 <cons_putc+0x25>
f01003ff:	89 ca                	mov    %ecx,%edx
f0100401:	ec                   	in     (%dx),%al
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
	     i++)
f0100405:	83 c3 01             	add    $0x1,%ebx
f0100408:	89 f2                	mov    %esi,%edx
f010040a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040b:	a8 20                	test   $0x20,%al
f010040d:	75 08                	jne    f0100417 <cons_putc+0x34>
f010040f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100415:	7e e8                	jle    f01003ff <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100417:	89 f8                	mov    %edi,%eax
f0100419:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100421:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100422:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100427:	be 79 03 00 00       	mov    $0x379,%esi
f010042c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100431:	eb 09                	jmp    f010043c <cons_putc+0x59>
f0100433:	89 ca                	mov    %ecx,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	83 c3 01             	add    $0x1,%ebx
f010043c:	89 f2                	mov    %esi,%edx
f010043e:	ec                   	in     (%dx),%al
f010043f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100445:	7f 04                	jg     f010044b <cons_putc+0x68>
f0100447:	84 c0                	test   %al,%al
f0100449:	79 e8                	jns    f0100433 <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100450:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100454:	ee                   	out    %al,(%dx)
f0100455:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045f:	ee                   	out    %al,(%dx)
f0100460:	b8 08 00 00 00       	mov    $0x8,%eax
f0100465:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100466:	89 fa                	mov    %edi,%edx
f0100468:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010046e:	89 f8                	mov    %edi,%eax
f0100470:	80 cc 07             	or     $0x7,%ah
f0100473:	85 d2                	test   %edx,%edx
f0100475:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100478:	89 f8                	mov    %edi,%eax
f010047a:	0f b6 c0             	movzbl %al,%eax
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	0f 84 b6 00 00 00    	je     f010053c <cons_putc+0x159>
f0100486:	83 f8 09             	cmp    $0x9,%eax
f0100489:	7e 73                	jle    f01004fe <cons_putc+0x11b>
f010048b:	83 f8 0a             	cmp    $0xa,%eax
f010048e:	0f 84 9b 00 00 00    	je     f010052f <cons_putc+0x14c>
f0100494:	83 f8 0d             	cmp    $0xd,%eax
f0100497:	0f 85 d6 00 00 00    	jne    f0100573 <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f010049d:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f01004a4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004aa:	c1 e8 16             	shr    $0x16,%eax
f01004ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b0:	c1 e0 04             	shl    $0x4,%eax
f01004b3:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
	if (crt_pos >= CRT_SIZE) {
f01004b9:	66 81 3d 28 52 21 f0 	cmpw   $0x7cf,0xf0215228
f01004c0:	cf 07 
f01004c2:	0f 87 ce 00 00 00    	ja     f0100596 <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004c8:	8b 0d 30 52 21 f0    	mov    0xf0215230,%ecx
f01004ce:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d3:	89 ca                	mov    %ecx,%edx
f01004d5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d6:	0f b7 1d 28 52 21 f0 	movzwl 0xf0215228,%ebx
f01004dd:	8d 71 01             	lea    0x1(%ecx),%esi
f01004e0:	89 d8                	mov    %ebx,%eax
f01004e2:	66 c1 e8 08          	shr    $0x8,%ax
f01004e6:	89 f2                	mov    %esi,%edx
f01004e8:	ee                   	out    %al,(%dx)
f01004e9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ee:	89 ca                	mov    %ecx,%edx
f01004f0:	ee                   	out    %al,(%dx)
f01004f1:	89 d8                	mov    %ebx,%eax
f01004f3:	89 f2                	mov    %esi,%edx
f01004f5:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f9:	5b                   	pop    %ebx
f01004fa:	5e                   	pop    %esi
f01004fb:	5f                   	pop    %edi
f01004fc:	5d                   	pop    %ebp
f01004fd:	c3                   	ret    
	switch (c & 0xff) {
f01004fe:	83 f8 08             	cmp    $0x8,%eax
f0100501:	75 70                	jne    f0100573 <cons_putc+0x190>
		if (crt_pos > 0) {
f0100503:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f010050a:	66 85 c0             	test   %ax,%ax
f010050d:	74 b9                	je     f01004c8 <cons_putc+0xe5>
			crt_pos--;
f010050f:	83 e8 01             	sub    $0x1,%eax
f0100512:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100518:	0f b7 c0             	movzwl %ax,%eax
f010051b:	66 81 e7 00 ff       	and    $0xff00,%di
f0100520:	83 cf 20             	or     $0x20,%edi
f0100523:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f0100529:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052d:	eb 8a                	jmp    f01004b9 <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f010052f:	66 83 05 28 52 21 f0 	addw   $0x50,0xf0215228
f0100536:	50 
f0100537:	e9 61 ff ff ff       	jmp    f010049d <cons_putc+0xba>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 9d fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 93 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100550:	b8 20 00 00 00       	mov    $0x20,%eax
f0100555:	e8 89 fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f010055a:	b8 20 00 00 00       	mov    $0x20,%eax
f010055f:	e8 7f fe ff ff       	call   f01003e3 <cons_putc>
		cons_putc(' ');
f0100564:	b8 20 00 00 00       	mov    $0x20,%eax
f0100569:	e8 75 fe ff ff       	call   f01003e3 <cons_putc>
f010056e:	e9 46 ff ff ff       	jmp    f01004b9 <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100573:	0f b7 05 28 52 21 f0 	movzwl 0xf0215228,%eax
f010057a:	8d 50 01             	lea    0x1(%eax),%edx
f010057d:	66 89 15 28 52 21 f0 	mov    %dx,0xf0215228
f0100584:	0f b7 c0             	movzwl %ax,%eax
f0100587:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f010058d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100591:	e9 23 ff ff ff       	jmp    f01004b9 <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100596:	a1 2c 52 21 f0       	mov    0xf021522c,%eax
f010059b:	83 ec 04             	sub    $0x4,%esp
f010059e:	68 00 0f 00 00       	push   $0xf00
f01005a3:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005a9:	52                   	push   %edx
f01005aa:	50                   	push   %eax
f01005ab:	e8 85 55 00 00       	call   f0105b35 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005b0:	8b 15 2c 52 21 f0    	mov    0xf021522c,%edx
f01005b6:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005bc:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c2:	83 c4 10             	add    $0x10,%esp
f01005c5:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005ca:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005cd:	39 d0                	cmp    %edx,%eax
f01005cf:	75 f4                	jne    f01005c5 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005d1:	66 83 2d 28 52 21 f0 	subw   $0x50,0xf0215228
f01005d8:	50 
f01005d9:	e9 ea fe ff ff       	jmp    f01004c8 <cons_putc+0xe5>

f01005de <serial_intr>:
	if (serial_exists)
f01005de:	80 3d 34 52 21 f0 00 	cmpb   $0x0,0xf0215234
f01005e5:	75 02                	jne    f01005e9 <serial_intr+0xb>
f01005e7:	f3 c3                	repz ret 
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ef:	b8 64 02 10 f0       	mov    $0xf0100264,%eax
f01005f4:	e8 8a fc ff ff       	call   f0100283 <cons_intr>
}
f01005f9:	c9                   	leave  
f01005fa:	c3                   	ret    

f01005fb <kbd_intr>:
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100601:	b8 c6 02 10 f0       	mov    $0xf01002c6,%eax
f0100606:	e8 78 fc ff ff       	call   f0100283 <cons_intr>
}
f010060b:	c9                   	leave  
f010060c:	c3                   	ret    

f010060d <cons_getc>:
{
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100613:	e8 c6 ff ff ff       	call   f01005de <serial_intr>
	kbd_intr();
f0100618:	e8 de ff ff ff       	call   f01005fb <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010061d:	8b 15 20 52 21 f0    	mov    0xf0215220,%edx
	return 0;
f0100623:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100628:	3b 15 24 52 21 f0    	cmp    0xf0215224,%edx
f010062e:	74 18                	je     f0100648 <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f0100630:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100633:	89 0d 20 52 21 f0    	mov    %ecx,0xf0215220
f0100639:	0f b6 82 20 50 21 f0 	movzbl -0xfdeafe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100640:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100646:	74 02                	je     f010064a <cons_getc+0x3d>
}
f0100648:	c9                   	leave  
f0100649:	c3                   	ret    
			cons.rpos = 0;
f010064a:	c7 05 20 52 21 f0 00 	movl   $0x0,0xf0215220
f0100651:	00 00 00 
f0100654:	eb f2                	jmp    f0100648 <cons_getc+0x3b>

f0100656 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	57                   	push   %edi
f010065a:	56                   	push   %esi
f010065b:	53                   	push   %ebx
f010065c:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010065f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100666:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066d:	5a a5 
	if (*cp != 0xA55A) {
f010066f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100676:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010067a:	0f 84 de 00 00 00    	je     f010075e <cons_init+0x108>
		addr_6845 = MONO_BASE;
f0100680:	c7 05 30 52 21 f0 b4 	movl   $0x3b4,0xf0215230
f0100687:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010068f:	8b 3d 30 52 21 f0    	mov    0xf0215230,%edi
f0100695:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069a:	89 fa                	mov    %edi,%edx
f010069c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 ca                	mov    %ecx,%edx
f01006a2:	ec                   	in     (%dx),%al
f01006a3:	0f b6 c0             	movzbl %al,%eax
f01006a6:	c1 e0 08             	shl    $0x8,%eax
f01006a9:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b0:	89 fa                	mov    %edi,%edx
f01006b2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b3:	89 ca                	mov    %ecx,%edx
f01006b5:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b6:	89 35 2c 52 21 f0    	mov    %esi,0xf021522c
	pos |= inb(addr_6845 + 1);
f01006bc:	0f b6 c0             	movzbl %al,%eax
f01006bf:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006c1:	66 a3 28 52 21 f0    	mov    %ax,0xf0215228
	kbd_intr();
f01006c7:	e8 2f ff ff ff       	call   f01005fb <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006cc:	83 ec 0c             	sub    $0xc,%esp
f01006cf:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006d6:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006db:	50                   	push   %eax
f01006dc:	e8 4c 35 00 00       	call   f0103c2d <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006e6:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006eb:	89 d8                	mov    %ebx,%eax
f01006ed:	89 ca                	mov    %ecx,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006f5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006fa:	89 fa                	mov    %edi,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100702:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100707:	ee                   	out    %al,(%dx)
f0100708:	be f9 03 00 00       	mov    $0x3f9,%esi
f010070d:	89 d8                	mov    %ebx,%eax
f010070f:	89 f2                	mov    %esi,%edx
f0100711:	ee                   	out    %al,(%dx)
f0100712:	b8 03 00 00 00       	mov    $0x3,%eax
f0100717:	89 fa                	mov    %edi,%edx
f0100719:	ee                   	out    %al,(%dx)
f010071a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071f:	89 d8                	mov    %ebx,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	b8 01 00 00 00       	mov    $0x1,%eax
f0100727:	89 f2                	mov    %esi,%edx
f0100729:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072f:	ec                   	in     (%dx),%al
f0100730:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100732:	83 c4 10             	add    $0x10,%esp
f0100735:	3c ff                	cmp    $0xff,%al
f0100737:	0f 95 05 34 52 21 f0 	setne  0xf0215234
f010073e:	89 ca                	mov    %ecx,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100746:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100747:	80 fb ff             	cmp    $0xff,%bl
f010074a:	75 2d                	jne    f0100779 <cons_init+0x123>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
		cprintf("Serial port does not exist!\n");
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	68 0f 68 10 f0       	push   $0xf010680f
f0100754:	e8 2f 36 00 00       	call   f0103d88 <cprintf>
f0100759:	83 c4 10             	add    $0x10,%esp
}
f010075c:	eb 3c                	jmp    f010079a <cons_init+0x144>
		*cp = was;
f010075e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100765:	c7 05 30 52 21 f0 d4 	movl   $0x3d4,0xf0215230
f010076c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010076f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100774:	e9 16 ff ff ff       	jmp    f010068f <cons_init+0x39>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100779:	83 ec 0c             	sub    $0xc,%esp
f010077c:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100783:	25 ef ff 00 00       	and    $0xffef,%eax
f0100788:	50                   	push   %eax
f0100789:	e8 9f 34 00 00       	call   f0103c2d <irq_setmask_8259A>
	if (!serial_exists)
f010078e:	83 c4 10             	add    $0x10,%esp
f0100791:	80 3d 34 52 21 f0 00 	cmpb   $0x0,0xf0215234
f0100798:	74 b2                	je     f010074c <cons_init+0xf6>
}
f010079a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010079d:	5b                   	pop    %ebx
f010079e:	5e                   	pop    %esi
f010079f:	5f                   	pop    %edi
f01007a0:	5d                   	pop    %ebp
f01007a1:	c3                   	ret    

f01007a2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a2:	55                   	push   %ebp
f01007a3:	89 e5                	mov    %esp,%ebp
f01007a5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ab:	e8 33 fc ff ff       	call   f01003e3 <cons_putc>
}
f01007b0:	c9                   	leave  
f01007b1:	c3                   	ret    

f01007b2 <getchar>:

int
getchar(void)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b8:	e8 50 fe ff ff       	call   f010060d <cons_getc>
f01007bd:	85 c0                	test   %eax,%eax
f01007bf:	74 f7                	je     f01007b8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c1:	c9                   	leave  
f01007c2:	c3                   	ret    

f01007c3 <iscons>:

int
iscons(int fdnum)
{
f01007c3:	55                   	push   %ebp
f01007c4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cb:	5d                   	pop    %ebp
f01007cc:	c3                   	ret    

f01007cd <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007cd:	55                   	push   %ebp
f01007ce:	89 e5                	mov    %esp,%ebp
f01007d0:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d3:	68 60 6a 10 f0       	push   $0xf0106a60
f01007d8:	68 7e 6a 10 f0       	push   $0xf0106a7e
f01007dd:	68 83 6a 10 f0       	push   $0xf0106a83
f01007e2:	e8 a1 35 00 00       	call   f0103d88 <cprintf>
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	68 14 6b 10 f0       	push   $0xf0106b14
f01007ef:	68 8c 6a 10 f0       	push   $0xf0106a8c
f01007f4:	68 83 6a 10 f0       	push   $0xf0106a83
f01007f9:	e8 8a 35 00 00       	call   f0103d88 <cprintf>
	return 0;
}
f01007fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100803:	c9                   	leave  
f0100804:	c3                   	ret    

f0100805 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010080b:	68 95 6a 10 f0       	push   $0xf0106a95
f0100810:	e8 73 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100815:	83 c4 08             	add    $0x8,%esp
f0100818:	68 0c 00 10 00       	push   $0x10000c
f010081d:	68 3c 6b 10 f0       	push   $0xf0106b3c
f0100822:	e8 61 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100827:	83 c4 0c             	add    $0xc,%esp
f010082a:	68 0c 00 10 00       	push   $0x10000c
f010082f:	68 0c 00 10 f0       	push   $0xf010000c
f0100834:	68 64 6b 10 f0       	push   $0xf0106b64
f0100839:	e8 4a 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	68 39 67 10 00       	push   $0x106739
f0100846:	68 39 67 10 f0       	push   $0xf0106739
f010084b:	68 88 6b 10 f0       	push   $0xf0106b88
f0100850:	e8 33 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 00 50 21 00       	push   $0x215000
f010085d:	68 00 50 21 f0       	push   $0xf0215000
f0100862:	68 ac 6b 10 f0       	push   $0xf0106bac
f0100867:	e8 1c 35 00 00       	call   f0103d88 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	68 08 70 25 00       	push   $0x257008
f0100874:	68 08 70 25 f0       	push   $0xf0257008
f0100879:	68 d0 6b 10 f0       	push   $0xf0106bd0
f010087e:	e8 05 35 00 00       	call   f0103d88 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100883:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100886:	b8 07 74 25 f0       	mov    $0xf0257407,%eax
f010088b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	c1 f8 0a             	sar    $0xa,%eax
f0100893:	50                   	push   %eax
f0100894:	68 f4 6b 10 f0       	push   $0xf0106bf4
f0100899:	e8 ea 34 00 00       	call   f0103d88 <cprintf>
	return 0;
}
f010089e:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a3:	c9                   	leave  
f01008a4:	c3                   	ret    

f01008a5 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a5:	55                   	push   %ebp
f01008a6:	89 e5                	mov    %esp,%ebp
f01008a8:	57                   	push   %edi
f01008a9:	56                   	push   %esi
f01008aa:	53                   	push   %ebx
f01008ab:	83 ec 38             	sub    $0x38,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ae:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t *ebp = (uint32_t*) read_ebp();
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f01008b0:	68 ae 6a 10 f0       	push   $0xf0106aae
f01008b5:	e8 ce 34 00 00       	call   f0103d88 <cprintf>
        while ((int)ebp != 0) {
f01008ba:	83 c4 10             	add    $0x10,%esp
            cprintf("    ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, *(ebp + 1), *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
            uintptr_t addr = *(ebp + 1);
            if (debuginfo_eip(addr, &info) != -1) {
f01008bd:	8d 7d d0             	lea    -0x30(%ebp),%edi
        while ((int)ebp != 0) {
f01008c0:	eb 02                	jmp    f01008c4 <mon_backtrace+0x1f>
                cprintf("        %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, addr - info.eip_fn_addr);
            }
	    ebp = (uint32_t*) *ebp;
f01008c2:	8b 1b                	mov    (%ebx),%ebx
        while ((int)ebp != 0) {
f01008c4:	85 db                	test   %ebx,%ebx
f01008c6:	74 54                	je     f010091c <mon_backtrace+0x77>
            cprintf("    ebp %x eip %x args %08x %08x %08x %08x %08x\n", ebp, *(ebp + 1), *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
f01008c8:	ff 73 18             	pushl  0x18(%ebx)
f01008cb:	ff 73 14             	pushl  0x14(%ebx)
f01008ce:	ff 73 10             	pushl  0x10(%ebx)
f01008d1:	ff 73 0c             	pushl  0xc(%ebx)
f01008d4:	ff 73 08             	pushl  0x8(%ebx)
f01008d7:	ff 73 04             	pushl  0x4(%ebx)
f01008da:	53                   	push   %ebx
f01008db:	68 20 6c 10 f0       	push   $0xf0106c20
f01008e0:	e8 a3 34 00 00       	call   f0103d88 <cprintf>
            uintptr_t addr = *(ebp + 1);
f01008e5:	8b 73 04             	mov    0x4(%ebx),%esi
            if (debuginfo_eip(addr, &info) != -1) {
f01008e8:	83 c4 18             	add    $0x18,%esp
f01008eb:	57                   	push   %edi
f01008ec:	56                   	push   %esi
f01008ed:	e8 bd 46 00 00       	call   f0104faf <debuginfo_eip>
f01008f2:	83 c4 10             	add    $0x10,%esp
f01008f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01008f8:	74 c8                	je     f01008c2 <mon_backtrace+0x1d>
                cprintf("        %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, addr - info.eip_fn_addr);
f01008fa:	83 ec 08             	sub    $0x8,%esp
f01008fd:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100900:	56                   	push   %esi
f0100901:	ff 75 d8             	pushl  -0x28(%ebp)
f0100904:	ff 75 dc             	pushl  -0x24(%ebp)
f0100907:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090a:	ff 75 d0             	pushl  -0x30(%ebp)
f010090d:	68 c0 6a 10 f0       	push   $0xf0106ac0
f0100912:	e8 71 34 00 00       	call   f0103d88 <cprintf>
f0100917:	83 c4 20             	add    $0x20,%esp
f010091a:	eb a6                	jmp    f01008c2 <mon_backtrace+0x1d>
        }
	return 0;
}
f010091c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100921:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100924:	5b                   	pop    %ebx
f0100925:	5e                   	pop    %esi
f0100926:	5f                   	pop    %edi
f0100927:	5d                   	pop    %ebp
f0100928:	c3                   	ret    

f0100929 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100929:	55                   	push   %ebp
f010092a:	89 e5                	mov    %esp,%ebp
f010092c:	57                   	push   %edi
f010092d:	56                   	push   %esi
f010092e:	53                   	push   %ebx
f010092f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100932:	68 54 6c 10 f0       	push   $0xf0106c54
f0100937:	e8 4c 34 00 00       	call   f0103d88 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010093c:	c7 04 24 78 6c 10 f0 	movl   $0xf0106c78,(%esp)
f0100943:	e8 40 34 00 00       	call   f0103d88 <cprintf>

	if (tf != NULL)
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010094f:	74 57                	je     f01009a8 <monitor+0x7f>
		print_trapframe(tf);
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	ff 75 08             	pushl  0x8(%ebp)
f0100957:	e8 f9 36 00 00       	call   f0104055 <print_trapframe>
f010095c:	83 c4 10             	add    $0x10,%esp
f010095f:	eb 47                	jmp    f01009a8 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100961:	83 ec 08             	sub    $0x8,%esp
f0100964:	0f be c0             	movsbl %al,%eax
f0100967:	50                   	push   %eax
f0100968:	68 dc 6a 10 f0       	push   $0xf0106adc
f010096d:	e8 39 51 00 00       	call   f0105aab <strchr>
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	85 c0                	test   %eax,%eax
f0100977:	74 0a                	je     f0100983 <monitor+0x5a>
			*buf++ = 0;
f0100979:	c6 03 00             	movb   $0x0,(%ebx)
f010097c:	89 f7                	mov    %esi,%edi
f010097e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100981:	eb 6b                	jmp    f01009ee <monitor+0xc5>
		if (*buf == 0)
f0100983:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100986:	74 73                	je     f01009fb <monitor+0xd2>
		if (argc == MAXARGS-1) {
f0100988:	83 fe 0f             	cmp    $0xf,%esi
f010098b:	74 09                	je     f0100996 <monitor+0x6d>
		argv[argc++] = buf;
f010098d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100990:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100994:	eb 39                	jmp    f01009cf <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	6a 10                	push   $0x10
f010099b:	68 e1 6a 10 f0       	push   $0xf0106ae1
f01009a0:	e8 e3 33 00 00       	call   f0103d88 <cprintf>
f01009a5:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a8:	83 ec 0c             	sub    $0xc,%esp
f01009ab:	68 d8 6a 10 f0       	push   $0xf0106ad8
f01009b0:	e8 ab 4e 00 00       	call   f0105860 <readline>
f01009b5:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	74 ea                	je     f01009a8 <monitor+0x7f>
	argv[argc] = 0;
f01009be:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009c5:	be 00 00 00 00       	mov    $0x0,%esi
f01009ca:	eb 24                	jmp    f01009f0 <monitor+0xc7>
			buf++;
f01009cc:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cf:	0f b6 03             	movzbl (%ebx),%eax
f01009d2:	84 c0                	test   %al,%al
f01009d4:	74 18                	je     f01009ee <monitor+0xc5>
f01009d6:	83 ec 08             	sub    $0x8,%esp
f01009d9:	0f be c0             	movsbl %al,%eax
f01009dc:	50                   	push   %eax
f01009dd:	68 dc 6a 10 f0       	push   $0xf0106adc
f01009e2:	e8 c4 50 00 00       	call   f0105aab <strchr>
f01009e7:	83 c4 10             	add    $0x10,%esp
f01009ea:	85 c0                	test   %eax,%eax
f01009ec:	74 de                	je     f01009cc <monitor+0xa3>
			*buf++ = 0;
f01009ee:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009f0:	0f b6 03             	movzbl (%ebx),%eax
f01009f3:	84 c0                	test   %al,%al
f01009f5:	0f 85 66 ff ff ff    	jne    f0100961 <monitor+0x38>
	argv[argc] = 0;
f01009fb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a02:	00 
	if (argc == 0)
f0100a03:	85 f6                	test   %esi,%esi
f0100a05:	74 a1                	je     f01009a8 <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a07:	83 ec 08             	sub    $0x8,%esp
f0100a0a:	68 7e 6a 10 f0       	push   $0xf0106a7e
f0100a0f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a12:	e8 36 50 00 00       	call   f0105a4d <strcmp>
f0100a17:	83 c4 10             	add    $0x10,%esp
f0100a1a:	85 c0                	test   %eax,%eax
f0100a1c:	74 34                	je     f0100a52 <monitor+0x129>
f0100a1e:	83 ec 08             	sub    $0x8,%esp
f0100a21:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0100a26:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a29:	e8 1f 50 00 00       	call   f0105a4d <strcmp>
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	74 18                	je     f0100a4d <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a35:	83 ec 08             	sub    $0x8,%esp
f0100a38:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a3b:	68 fe 6a 10 f0       	push   $0xf0106afe
f0100a40:	e8 43 33 00 00       	call   f0103d88 <cprintf>
f0100a45:	83 c4 10             	add    $0x10,%esp
f0100a48:	e9 5b ff ff ff       	jmp    f01009a8 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a4d:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a52:	83 ec 04             	sub    $0x4,%esp
f0100a55:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a58:	ff 75 08             	pushl  0x8(%ebp)
f0100a5b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a5e:	52                   	push   %edx
f0100a5f:	56                   	push   %esi
f0100a60:	ff 14 85 a8 6c 10 f0 	call   *-0xfef9358(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a67:	83 c4 10             	add    $0x10,%esp
f0100a6a:	85 c0                	test   %eax,%eax
f0100a6c:	0f 89 36 ff ff ff    	jns    f01009a8 <monitor+0x7f>
				break;
	}
}
f0100a72:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a75:	5b                   	pop    %ebx
f0100a76:	5e                   	pop    %esi
f0100a77:	5f                   	pop    %edi
f0100a78:	5d                   	pop    %ebp
f0100a79:	c3                   	ret    

f0100a7a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a7a:	55                   	push   %ebp
f0100a7b:	89 e5                	mov    %esp,%ebp
f0100a7d:	56                   	push   %esi
f0100a7e:	53                   	push   %ebx
f0100a7f:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a81:	83 ec 0c             	sub    $0xc,%esp
f0100a84:	50                   	push   %eax
f0100a85:	e8 75 31 00 00       	call   f0103bff <mc146818_read>
f0100a8a:	89 c3                	mov    %eax,%ebx
f0100a8c:	83 c6 01             	add    $0x1,%esi
f0100a8f:	89 34 24             	mov    %esi,(%esp)
f0100a92:	e8 68 31 00 00       	call   f0103bff <mc146818_read>
f0100a97:	c1 e0 08             	shl    $0x8,%eax
f0100a9a:	09 d8                	or     %ebx,%eax
}
f0100a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a9f:	5b                   	pop    %ebx
f0100aa0:	5e                   	pop    %esi
f0100aa1:	5d                   	pop    %ebp
f0100aa2:	c3                   	ret    

f0100aa3 <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100aa3:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aa5:	83 3d 38 52 21 f0 00 	cmpl   $0x0,0xf0215238
f0100aac:	74 3f                	je     f0100aed <boot_alloc+0x4a>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
    if (n==0) {
f0100aae:	85 d2                	test   %edx,%edx
f0100ab0:	74 4c                	je     f0100afe <boot_alloc+0x5b>
{
f0100ab2:	55                   	push   %ebp
f0100ab3:	89 e5                	mov    %esp,%ebp
f0100ab5:	53                   	push   %ebx
f0100ab6:	83 ec 04             	sub    $0x4,%esp
        return nextfree;
    }
    if (n / PGSIZE > npages) {
f0100ab9:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f0100abe:	89 d1                	mov    %edx,%ecx
f0100ac0:	c1 e9 0c             	shr    $0xc,%ecx
f0100ac3:	39 c1                	cmp    %eax,%ecx
f0100ac5:	77 3d                	ja     f0100b04 <boot_alloc+0x61>
        _panic(__FILE__, __LINE__, "boot_alloc allocate %08lx byte more than total memory %08lx ", n, npages * PGSIZE);
    }
    result = nextfree;
f0100ac7:	a1 38 52 21 f0       	mov    0xf0215238,%eax
f0100acc:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
    while (n > 0){
        nextfree += PGSIZE;
f0100ad2:	89 cb                	mov    %ecx,%ebx
f0100ad4:	81 c1 00 10 00 00    	add    $0x1000,%ecx
    while (n > 0){
f0100ada:	81 ea 00 10 00 00    	sub    $0x1000,%edx
f0100ae0:	75 f0                	jne    f0100ad2 <boot_alloc+0x2f>
f0100ae2:	89 1d 38 52 21 f0    	mov    %ebx,0xf0215238
        n -= PGSIZE;
    }

    return result;
}
f0100ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aeb:	c9                   	leave  
f0100aec:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aed:	b8 07 80 25 f0       	mov    $0xf0258007,%eax
f0100af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af7:	a3 38 52 21 f0       	mov    %eax,0xf0215238
f0100afc:	eb b0                	jmp    f0100aae <boot_alloc+0xb>
        return nextfree;
f0100afe:	a1 38 52 21 f0       	mov    0xf0215238,%eax
}
f0100b03:	c3                   	ret    
        _panic(__FILE__, __LINE__, "boot_alloc allocate %08lx byte more than total memory %08lx ", n, npages * PGSIZE);
f0100b04:	83 ec 0c             	sub    $0xc,%esp
f0100b07:	c1 e0 0c             	shl    $0xc,%eax
f0100b0a:	50                   	push   %eax
f0100b0b:	52                   	push   %edx
f0100b0c:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0100b11:	6a 72                	push   $0x72
f0100b13:	68 b5 77 10 f0       	push   $0xf01077b5
f0100b18:	e8 23 f5 ff ff       	call   f0100040 <_panic>

f0100b1d <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b1d:	89 d1                	mov    %edx,%ecx
f0100b1f:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100b22:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b25:	a8 01                	test   $0x1,%al
f0100b27:	74 52                	je     f0100b7b <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100b2e:	89 c1                	mov    %eax,%ecx
f0100b30:	c1 e9 0c             	shr    $0xc,%ecx
f0100b33:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f0100b39:	73 25                	jae    f0100b60 <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b3b:	c1 ea 0c             	shr    $0xc,%edx
f0100b3e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b44:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b4b:	89 c2                	mov    %eax,%edx
f0100b4d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b50:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b55:	85 d2                	test   %edx,%edx
f0100b57:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b5c:	0f 44 c2             	cmove  %edx,%eax
f0100b5f:	c3                   	ret    
{
f0100b60:	55                   	push   %ebp
f0100b61:	89 e5                	mov    %esp,%ebp
f0100b63:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b66:	50                   	push   %eax
f0100b67:	68 64 67 10 f0       	push   $0xf0106764
f0100b6c:	68 19 04 00 00       	push   $0x419
f0100b71:	68 b5 77 10 f0       	push   $0xf01077b5
f0100b76:	e8 c5 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b80:	c3                   	ret    

f0100b81 <check_page_free_list>:
{
f0100b81:	55                   	push   %ebp
f0100b82:	89 e5                	mov    %esp,%ebp
f0100b84:	57                   	push   %edi
f0100b85:	56                   	push   %esi
f0100b86:	53                   	push   %ebx
f0100b87:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8a:	84 c0                	test   %al,%al
f0100b8c:	0f 85 86 02 00 00    	jne    f0100e18 <check_page_free_list+0x297>
	if (!page_free_list)
f0100b92:	83 3d 40 52 21 f0 00 	cmpl   $0x0,0xf0215240
f0100b99:	74 0a                	je     f0100ba5 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b9b:	be 00 04 00 00       	mov    $0x400,%esi
f0100ba0:	e9 ce 02 00 00       	jmp    f0100e73 <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100ba5:	83 ec 04             	sub    $0x4,%esp
f0100ba8:	68 f8 6c 10 f0       	push   $0xf0106cf8
f0100bad:	68 4c 03 00 00       	push   $0x34c
f0100bb2:	68 b5 77 10 f0       	push   $0xf01077b5
f0100bb7:	e8 84 f4 ff ff       	call   f0100040 <_panic>
f0100bbc:	50                   	push   %eax
f0100bbd:	68 64 67 10 f0       	push   $0xf0106764
f0100bc2:	6a 58                	push   $0x58
f0100bc4:	68 c1 77 10 f0       	push   $0xf01077c1
f0100bc9:	e8 72 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bce:	8b 1b                	mov    (%ebx),%ebx
f0100bd0:	85 db                	test   %ebx,%ebx
f0100bd2:	74 41                	je     f0100c15 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bd4:	89 d8                	mov    %ebx,%eax
f0100bd6:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0100bdc:	c1 f8 03             	sar    $0x3,%eax
f0100bdf:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100be2:	89 c2                	mov    %eax,%edx
f0100be4:	c1 ea 16             	shr    $0x16,%edx
f0100be7:	39 f2                	cmp    %esi,%edx
f0100be9:	73 e3                	jae    f0100bce <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100beb:	89 c2                	mov    %eax,%edx
f0100bed:	c1 ea 0c             	shr    $0xc,%edx
f0100bf0:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0100bf6:	73 c4                	jae    f0100bbc <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bf8:	83 ec 04             	sub    $0x4,%esp
f0100bfb:	68 80 00 00 00       	push   $0x80
f0100c00:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c05:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c0a:	50                   	push   %eax
f0100c0b:	e8 d8 4e 00 00       	call   f0105ae8 <memset>
f0100c10:	83 c4 10             	add    $0x10,%esp
f0100c13:	eb b9                	jmp    f0100bce <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100c15:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1a:	e8 84 fe ff ff       	call   f0100aa3 <boot_alloc>
f0100c1f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c22:	8b 15 40 52 21 f0    	mov    0xf0215240,%edx
		assert(pp >= pages);
f0100c28:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
		assert(pp < pages + npages);
f0100c2e:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f0100c33:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c36:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c3f:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c44:	e9 04 01 00 00       	jmp    f0100d4d <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100c49:	68 cf 77 10 f0       	push   $0xf01077cf
f0100c4e:	68 db 77 10 f0       	push   $0xf01077db
f0100c53:	68 66 03 00 00       	push   $0x366
f0100c58:	68 b5 77 10 f0       	push   $0xf01077b5
f0100c5d:	e8 de f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c62:	68 f0 77 10 f0       	push   $0xf01077f0
f0100c67:	68 db 77 10 f0       	push   $0xf01077db
f0100c6c:	68 67 03 00 00       	push   $0x367
f0100c71:	68 b5 77 10 f0       	push   $0xf01077b5
f0100c76:	e8 c5 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7b:	68 1c 6d 10 f0       	push   $0xf0106d1c
f0100c80:	68 db 77 10 f0       	push   $0xf01077db
f0100c85:	68 68 03 00 00       	push   $0x368
f0100c8a:	68 b5 77 10 f0       	push   $0xf01077b5
f0100c8f:	e8 ac f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c94:	68 04 78 10 f0       	push   $0xf0107804
f0100c99:	68 db 77 10 f0       	push   $0xf01077db
f0100c9e:	68 6b 03 00 00       	push   $0x36b
f0100ca3:	68 b5 77 10 f0       	push   $0xf01077b5
f0100ca8:	e8 93 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cad:	68 15 78 10 f0       	push   $0xf0107815
f0100cb2:	68 db 77 10 f0       	push   $0xf01077db
f0100cb7:	68 6c 03 00 00       	push   $0x36c
f0100cbc:	68 b5 77 10 f0       	push   $0xf01077b5
f0100cc1:	e8 7a f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cc6:	68 50 6d 10 f0       	push   $0xf0106d50
f0100ccb:	68 db 77 10 f0       	push   $0xf01077db
f0100cd0:	68 6d 03 00 00       	push   $0x36d
f0100cd5:	68 b5 77 10 f0       	push   $0xf01077b5
f0100cda:	e8 61 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cdf:	68 2e 78 10 f0       	push   $0xf010782e
f0100ce4:	68 db 77 10 f0       	push   $0xf01077db
f0100ce9:	68 6e 03 00 00       	push   $0x36e
f0100cee:	68 b5 77 10 f0       	push   $0xf01077b5
f0100cf3:	e8 48 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100cf8:	89 c7                	mov    %eax,%edi
f0100cfa:	c1 ef 0c             	shr    $0xc,%edi
f0100cfd:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d00:	76 1b                	jbe    f0100d1d <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100d02:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d08:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d0b:	77 22                	ja     f0100d2f <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d0d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d12:	0f 84 98 00 00 00    	je     f0100db0 <check_page_free_list+0x22f>
			++nfree_extmem;
f0100d18:	83 c3 01             	add    $0x1,%ebx
f0100d1b:	eb 2e                	jmp    f0100d4b <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d1d:	50                   	push   %eax
f0100d1e:	68 64 67 10 f0       	push   $0xf0106764
f0100d23:	6a 58                	push   $0x58
f0100d25:	68 c1 77 10 f0       	push   $0xf01077c1
f0100d2a:	e8 11 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d2f:	68 74 6d 10 f0       	push   $0xf0106d74
f0100d34:	68 db 77 10 f0       	push   $0xf01077db
f0100d39:	68 6f 03 00 00       	push   $0x36f
f0100d3e:	68 b5 77 10 f0       	push   $0xf01077b5
f0100d43:	e8 f8 f2 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d48:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4b:	8b 12                	mov    (%edx),%edx
f0100d4d:	85 d2                	test   %edx,%edx
f0100d4f:	74 78                	je     f0100dc9 <check_page_free_list+0x248>
		assert(pp >= pages);
f0100d51:	39 d1                	cmp    %edx,%ecx
f0100d53:	0f 87 f0 fe ff ff    	ja     f0100c49 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100d59:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d5c:	0f 86 00 ff ff ff    	jbe    f0100c62 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d62:	89 d0                	mov    %edx,%eax
f0100d64:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d67:	a8 07                	test   $0x7,%al
f0100d69:	0f 85 0c ff ff ff    	jne    f0100c7b <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d6f:	c1 f8 03             	sar    $0x3,%eax
f0100d72:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d75:	85 c0                	test   %eax,%eax
f0100d77:	0f 84 17 ff ff ff    	je     f0100c94 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d7d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d82:	0f 84 25 ff ff ff    	je     f0100cad <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d88:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d8d:	0f 84 33 ff ff ff    	je     f0100cc6 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d93:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d98:	0f 84 41 ff ff ff    	je     f0100cdf <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d9e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100da3:	0f 87 4f ff ff ff    	ja     f0100cf8 <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100da9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dae:	75 98                	jne    f0100d48 <check_page_free_list+0x1c7>
f0100db0:	68 48 78 10 f0       	push   $0xf0107848
f0100db5:	68 db 77 10 f0       	push   $0xf01077db
f0100dba:	68 71 03 00 00       	push   $0x371
f0100dbf:	68 b5 77 10 f0       	push   $0xf01077b5
f0100dc4:	e8 77 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100dc9:	85 f6                	test   %esi,%esi
f0100dcb:	7e 19                	jle    f0100de6 <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100dcd:	85 db                	test   %ebx,%ebx
f0100dcf:	7e 2e                	jle    f0100dff <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100dd1:	83 ec 0c             	sub    $0xc,%esp
f0100dd4:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0100dd9:	e8 aa 2f 00 00       	call   f0103d88 <cprintf>
}
f0100dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100de1:	5b                   	pop    %ebx
f0100de2:	5e                   	pop    %esi
f0100de3:	5f                   	pop    %edi
f0100de4:	5d                   	pop    %ebp
f0100de5:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100de6:	68 65 78 10 f0       	push   $0xf0107865
f0100deb:	68 db 77 10 f0       	push   $0xf01077db
f0100df0:	68 79 03 00 00       	push   $0x379
f0100df5:	68 b5 77 10 f0       	push   $0xf01077b5
f0100dfa:	e8 41 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dff:	68 77 78 10 f0       	push   $0xf0107877
f0100e04:	68 db 77 10 f0       	push   $0xf01077db
f0100e09:	68 7a 03 00 00       	push   $0x37a
f0100e0e:	68 b5 77 10 f0       	push   $0xf01077b5
f0100e13:	e8 28 f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100e18:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0100e1d:	85 c0                	test   %eax,%eax
f0100e1f:	0f 84 80 fd ff ff    	je     f0100ba5 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e25:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e28:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e2b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e2e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100e31:	89 c2                	mov    %eax,%edx
f0100e33:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e39:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e3f:	0f 95 c2             	setne  %dl
f0100e42:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e45:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e49:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e4b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e4f:	8b 00                	mov    (%eax),%eax
f0100e51:	85 c0                	test   %eax,%eax
f0100e53:	75 dc                	jne    f0100e31 <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100e55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e61:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e64:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e66:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e69:	a3 40 52 21 f0       	mov    %eax,0xf0215240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e6e:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e73:	8b 1d 40 52 21 f0    	mov    0xf0215240,%ebx
f0100e79:	e9 52 fd ff ff       	jmp    f0100bd0 <check_page_free_list+0x4f>

f0100e7e <page_init>:
    if (npages <= 0) {
f0100e7e:	83 3d 88 5e 21 f0 00 	cmpl   $0x0,0xf0215e88
f0100e85:	75 02                	jne    f0100e89 <page_init+0xb>
f0100e87:	f3 c3                	repz ret 
{
f0100e89:	55                   	push   %ebp
f0100e8a:	89 e5                	mov    %esp,%ebp
f0100e8c:	57                   	push   %edi
f0100e8d:	56                   	push   %esi
f0100e8e:	53                   	push   %ebx
f0100e8f:	83 ec 1c             	sub    $0x1c,%esp
    pages[0].pp_ref = 1;
f0100e92:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f0100e97:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
    uint32_t nextfree = (uint32_t) boot_alloc(0);
f0100e9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea2:	e8 fc fb ff ff       	call   f0100aa3 <boot_alloc>
f0100ea7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        } else if (i < npages_basemem) {
f0100eaa:	8b 3d 44 52 21 f0    	mov    0xf0215244,%edi
f0100eb0:	8b 0d 40 52 21 f0    	mov    0xf0215240,%ecx
    for (i = 1; i < npages; i++) {
f0100eb6:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100eba:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ebf:	eb 2a                	jmp    f0100eeb <page_init+0x6d>
        } else if (i < npages_basemem) {
f0100ec1:	39 c7                	cmp    %eax,%edi
f0100ec3:	76 5e                	jbe    f0100f23 <page_init+0xa5>
            pages[i].pp_ref = 0;
f0100ec5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ecc:	89 d3                	mov    %edx,%ebx
f0100ece:	03 1d 90 5e 21 f0    	add    0xf0215e90,%ebx
f0100ed4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
            pages[i].pp_link = page_free_list;
f0100eda:	89 0b                	mov    %ecx,(%ebx)
            page_free_list = &pages[i];
f0100edc:	89 d1                	mov    %edx,%ecx
f0100ede:	03 0d 90 5e 21 f0    	add    0xf0215e90,%ecx
f0100ee4:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
    for (i = 1; i < npages; i++) {
f0100ee8:	83 c0 01             	add    $0x1,%eax
f0100eeb:	8b 15 88 5e 21 f0    	mov    0xf0215e88,%edx
f0100ef1:	39 c2                	cmp    %eax,%edx
f0100ef3:	0f 86 ba 00 00 00    	jbe    f0100fb3 <page_init+0x135>
f0100ef9:	89 c3                	mov    %eax,%ebx
f0100efb:	c1 e3 0c             	shl    $0xc,%ebx
        if (i * PGSIZE <= MPENTRY_PADDR && (i + 1) * PGSIZE > MPENTRY_PADDR) {
f0100efe:	81 fb 00 70 00 00    	cmp    $0x7000,%ebx
f0100f04:	77 bb                	ja     f0100ec1 <page_init+0x43>
f0100f06:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
f0100f0c:	81 fe 00 70 00 00    	cmp    $0x7000,%esi
f0100f12:	76 ad                	jbe    f0100ec1 <page_init+0x43>
            pages[i].pp_ref = 1;
f0100f14:	8b 15 90 5e 21 f0    	mov    0xf0215e90,%edx
f0100f1a:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
f0100f21:	eb c5                	jmp    f0100ee8 <page_init+0x6a>
        } else if (i >= npages_basemem && i *PGSIZE < EXTPHYSMEM){
f0100f23:	81 fb ff ff 0f 00    	cmp    $0xfffff,%ebx
f0100f29:	77 0f                	ja     f0100f3a <page_init+0xbc>
            pages[i].pp_ref = 1;
f0100f2b:	8b 15 90 5e 21 f0    	mov    0xf0215e90,%edx
f0100f31:	66 c7 44 c2 04 01 00 	movw   $0x1,0x4(%edx,%eax,8)
f0100f38:	eb ae                	jmp    f0100ee8 <page_init+0x6a>
        } else if (i * PGSIZE >= EXTPHYSMEM && (uint32_t)page2kva(pages + i) < nextfree) {
f0100f3a:	8d 34 c5 00 00 00 00 	lea    0x0(,%eax,8),%esi
f0100f41:	89 f3                	mov    %esi,%ebx
f0100f43:	03 1d 90 5e 21 f0    	add    0xf0215e90,%ebx
f0100f49:	89 5d e0             	mov    %ebx,-0x20(%ebp)
f0100f4c:	89 f3                	mov    %esi,%ebx
f0100f4e:	c1 e3 09             	shl    $0x9,%ebx
f0100f51:	89 5d d8             	mov    %ebx,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f0100f54:	c1 eb 0c             	shr    $0xc,%ebx
f0100f57:	39 da                	cmp    %ebx,%edx
f0100f59:	76 1c                	jbe    f0100f77 <page_init+0xf9>
	return (void *)(pa + KERNBASE);
f0100f5b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f5e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f64:	39 55 dc             	cmp    %edx,-0x24(%ebp)
f0100f67:	76 2e                	jbe    f0100f97 <page_init+0x119>
            pages[i].pp_ref = 1;
f0100f69:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f6c:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
f0100f72:	e9 71 ff ff ff       	jmp    f0100ee8 <page_init+0x6a>
f0100f77:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100f7b:	74 06                	je     f0100f83 <page_init+0x105>
f0100f7d:	89 0d 40 52 21 f0    	mov    %ecx,0xf0215240
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f83:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f86:	68 64 67 10 f0       	push   $0xf0106764
f0100f8b:	6a 58                	push   $0x58
f0100f8d:	68 c1 77 10 f0       	push   $0xf01077c1
f0100f92:	e8 a9 f0 ff ff       	call   f0100040 <_panic>
            pages[i].pp_ref = 0;
f0100f97:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f9a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
            pages[i].pp_link = page_free_list;
f0100fa0:	89 0a                	mov    %ecx,(%edx)
            page_free_list = &pages[i];
f0100fa2:	03 35 90 5e 21 f0    	add    0xf0215e90,%esi
f0100fa8:	89 f1                	mov    %esi,%ecx
f0100faa:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
f0100fae:	e9 35 ff ff ff       	jmp    f0100ee8 <page_init+0x6a>
f0100fb3:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100fb7:	75 08                	jne    f0100fc1 <page_init+0x143>
}
f0100fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fbc:	5b                   	pop    %ebx
f0100fbd:	5e                   	pop    %esi
f0100fbe:	5f                   	pop    %edi
f0100fbf:	5d                   	pop    %ebp
f0100fc0:	c3                   	ret    
f0100fc1:	89 0d 40 52 21 f0    	mov    %ecx,0xf0215240
f0100fc7:	eb f0                	jmp    f0100fb9 <page_init+0x13b>

f0100fc9 <page_alloc>:
{
f0100fc9:	55                   	push   %ebp
f0100fca:	89 e5                	mov    %esp,%ebp
f0100fcc:	53                   	push   %ebx
f0100fcd:	83 ec 04             	sub    $0x4,%esp
    if (!page_free_list) {
f0100fd0:	8b 1d 40 52 21 f0    	mov    0xf0215240,%ebx
f0100fd6:	85 db                	test   %ebx,%ebx
f0100fd8:	74 13                	je     f0100fed <page_alloc+0x24>
    page_free_list = page_free_list->pp_link;
f0100fda:	8b 03                	mov    (%ebx),%eax
f0100fdc:	a3 40 52 21 f0       	mov    %eax,0xf0215240
    pp->pp_link = NULL;
f0100fe1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if (alloc_flags & ALLOC_ZERO) {
f0100fe7:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100feb:	75 07                	jne    f0100ff4 <page_alloc+0x2b>
}
f0100fed:	89 d8                	mov    %ebx,%eax
f0100fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ff2:	c9                   	leave  
f0100ff3:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100ff4:	89 d8                	mov    %ebx,%eax
f0100ff6:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0100ffc:	c1 f8 03             	sar    $0x3,%eax
f0100fff:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101002:	89 c2                	mov    %eax,%edx
f0101004:	c1 ea 0c             	shr    $0xc,%edx
f0101007:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f010100d:	73 1a                	jae    f0101029 <page_alloc+0x60>
        memset(page2kva(pp), 0, PGSIZE);
f010100f:	83 ec 04             	sub    $0x4,%esp
f0101012:	68 00 10 00 00       	push   $0x1000
f0101017:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101019:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010101e:	50                   	push   %eax
f010101f:	e8 c4 4a 00 00       	call   f0105ae8 <memset>
f0101024:	83 c4 10             	add    $0x10,%esp
f0101027:	eb c4                	jmp    f0100fed <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101029:	50                   	push   %eax
f010102a:	68 64 67 10 f0       	push   $0xf0106764
f010102f:	6a 58                	push   $0x58
f0101031:	68 c1 77 10 f0       	push   $0xf01077c1
f0101036:	e8 05 f0 ff ff       	call   f0100040 <_panic>

f010103b <page_free>:
{
f010103b:	55                   	push   %ebp
f010103c:	89 e5                	mov    %esp,%ebp
f010103e:	83 ec 08             	sub    $0x8,%esp
f0101041:	8b 45 08             	mov    0x8(%ebp),%eax
    if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0101044:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0101048:	66 85 d2             	test   %dx,%dx
f010104b:	75 14                	jne    f0101061 <page_free+0x26>
f010104d:	83 38 00             	cmpl   $0x0,(%eax)
f0101050:	75 0f                	jne    f0101061 <page_free+0x26>
    pp->pp_link = page_free_list;
f0101052:	8b 15 40 52 21 f0    	mov    0xf0215240,%edx
f0101058:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f010105a:	a3 40 52 21 f0       	mov    %eax,0xf0215240
}
f010105f:	c9                   	leave  
f0101060:	c3                   	ret    
        cprintf("pp->pp_link: %x is a null pointer || pp->pp_ref: %d is nonzero!", pp->pp_link, pp->pp_ref);
f0101061:	83 ec 04             	sub    $0x4,%esp
f0101064:	0f b7 d2             	movzwl %dx,%edx
f0101067:	52                   	push   %edx
f0101068:	ff 30                	pushl  (%eax)
f010106a:	68 e0 6d 10 f0       	push   $0xf0106de0
f010106f:	e8 14 2d 00 00       	call   f0103d88 <cprintf>
        panic("!!!");
f0101074:	83 c4 0c             	add    $0xc,%esp
f0101077:	68 88 78 10 f0       	push   $0xf0107888
f010107c:	68 a7 01 00 00       	push   $0x1a7
f0101081:	68 b5 77 10 f0       	push   $0xf01077b5
f0101086:	e8 b5 ef ff ff       	call   f0100040 <_panic>

f010108b <page_decref>:
{
f010108b:	55                   	push   %ebp
f010108c:	89 e5                	mov    %esp,%ebp
f010108e:	83 ec 08             	sub    $0x8,%esp
f0101091:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101094:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101098:	83 e8 01             	sub    $0x1,%eax
f010109b:	66 89 42 04          	mov    %ax,0x4(%edx)
f010109f:	66 85 c0             	test   %ax,%ax
f01010a2:	74 02                	je     f01010a6 <page_decref+0x1b>
}
f01010a4:	c9                   	leave  
f01010a5:	c3                   	ret    
		page_free(pp);
f01010a6:	83 ec 0c             	sub    $0xc,%esp
f01010a9:	52                   	push   %edx
f01010aa:	e8 8c ff ff ff       	call   f010103b <page_free>
f01010af:	83 c4 10             	add    $0x10,%esp
}
f01010b2:	eb f0                	jmp    f01010a4 <page_decref+0x19>

f01010b4 <pgdir_walk>:
{
f01010b4:	55                   	push   %ebp
f01010b5:	89 e5                	mov    %esp,%ebp
f01010b7:	56                   	push   %esi
f01010b8:	53                   	push   %ebx
f01010b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    pde = &pgdir[PDX(va)];
f01010bc:	89 de                	mov    %ebx,%esi
f01010be:	c1 ee 16             	shr    $0x16,%esi
f01010c1:	c1 e6 02             	shl    $0x2,%esi
f01010c4:	03 75 08             	add    0x8(%ebp),%esi
    if(*pde & PTE_P){
f01010c7:	8b 16                	mov    (%esi),%edx
f01010c9:	f6 c2 01             	test   $0x1,%dl
f01010cc:	74 41                	je     f010110f <pgdir_walk+0x5b>
        pgtab = (pte_t*)KADDR(PTE_ADDR(*pde));
f01010ce:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01010d4:	89 d0                	mov    %edx,%eax
f01010d6:	c1 e8 0c             	shr    $0xc,%eax
f01010d9:	39 05 88 5e 21 f0    	cmp    %eax,0xf0215e88
f01010df:	76 19                	jbe    f01010fa <pgdir_walk+0x46>
	return (void *)(pa + KERNBASE);
f01010e1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
    return &pgtab[PTX(va)];
f01010e7:	c1 eb 0a             	shr    $0xa,%ebx
f01010ea:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01010f0:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
}
f01010f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010f6:	5b                   	pop    %ebx
f01010f7:	5e                   	pop    %esi
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010fa:	52                   	push   %edx
f01010fb:	68 64 67 10 f0       	push   $0xf0106764
f0101100:	68 da 01 00 00       	push   $0x1da
f0101105:	68 b5 77 10 f0       	push   $0xf01077b5
f010110a:	e8 31 ef ff ff       	call   f0100040 <_panic>
        if(!create || (pp = page_alloc(1)) == NULL)
f010110f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101113:	74 70                	je     f0101185 <pgdir_walk+0xd1>
f0101115:	83 ec 0c             	sub    $0xc,%esp
f0101118:	6a 01                	push   $0x1
f010111a:	e8 aa fe ff ff       	call   f0100fc9 <page_alloc>
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	85 c0                	test   %eax,%eax
f0101124:	74 69                	je     f010118f <pgdir_walk+0xdb>
        pp->pp_ref += 1;
f0101126:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010112b:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101131:	c1 f8 03             	sar    $0x3,%eax
f0101134:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101137:	89 c2                	mov    %eax,%edx
f0101139:	c1 ea 0c             	shr    $0xc,%edx
f010113c:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0101142:	73 17                	jae    f010115b <pgdir_walk+0xa7>
	return (void *)(pa + KERNBASE);
f0101144:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f010114a:	89 ca                	mov    %ecx,%edx
	if ((uint32_t)kva < KERNBASE)
f010114c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0101152:	76 1c                	jbe    f0101170 <pgdir_walk+0xbc>
        *pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f0101154:	83 c8 07             	or     $0x7,%eax
f0101157:	89 06                	mov    %eax,(%esi)
f0101159:	eb 8c                	jmp    f01010e7 <pgdir_walk+0x33>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010115b:	50                   	push   %eax
f010115c:	68 64 67 10 f0       	push   $0xf0106764
f0101161:	68 e4 01 00 00       	push   $0x1e4
f0101166:	68 b5 77 10 f0       	push   $0xf01077b5
f010116b:	e8 d0 ee ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101170:	51                   	push   %ecx
f0101171:	68 88 67 10 f0       	push   $0xf0106788
f0101176:	68 e5 01 00 00       	push   $0x1e5
f010117b:	68 b5 77 10 f0       	push   $0xf01077b5
f0101180:	e8 bb ee ff ff       	call   f0100040 <_panic>
            return NULL;
f0101185:	b8 00 00 00 00       	mov    $0x0,%eax
f010118a:	e9 64 ff ff ff       	jmp    f01010f3 <pgdir_walk+0x3f>
f010118f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101194:	e9 5a ff ff ff       	jmp    f01010f3 <pgdir_walk+0x3f>

f0101199 <boot_map_region>:
{
f0101199:	55                   	push   %ebp
f010119a:	89 e5                	mov    %esp,%ebp
f010119c:	57                   	push   %edi
f010119d:	56                   	push   %esi
f010119e:	53                   	push   %ebx
f010119f:	83 ec 1c             	sub    $0x1c,%esp
f01011a2:	89 c7                	mov    %eax,%edi
f01011a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    for (int i = 0; i < size; i += PGSIZE) {
f01011aa:	89 d3                	mov    %edx,%ebx
f01011ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01011af:	29 d6                	sub    %edx,%esi
f01011b1:	89 75 dc             	mov    %esi,-0x24(%ebp)
        *pte = pa | perm | PTE_P;
f01011b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b7:	83 c8 01             	or     $0x1,%eax
f01011ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01011c0:	8d 34 18             	lea    (%eax,%ebx,1),%esi
    for (int i = 0; i < size; i += PGSIZE) {
f01011c3:	89 d8                	mov    %ebx,%eax
f01011c5:	2b 45 e4             	sub    -0x1c(%ebp),%eax
f01011c8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01011cb:	73 42                	jae    f010120f <boot_map_region+0x76>
        pte = pgdir_walk(pgdir, (void *)va, 1);
f01011cd:	83 ec 04             	sub    $0x4,%esp
f01011d0:	6a 01                	push   $0x1
f01011d2:	53                   	push   %ebx
f01011d3:	57                   	push   %edi
f01011d4:	e8 db fe ff ff       	call   f01010b4 <pgdir_walk>
        if (!pte) {
f01011d9:	83 c4 10             	add    $0x10,%esp
f01011dc:	85 c0                	test   %eax,%eax
f01011de:	74 18                	je     f01011f8 <boot_map_region+0x5f>
        *pte = pa | perm | PTE_P;
f01011e0:	0b 75 d8             	or     -0x28(%ebp),%esi
f01011e3:	89 30                	mov    %esi,(%eax)
        pgdir[PDX(va)] |= perm ;
f01011e5:	89 d8                	mov    %ebx,%eax
f01011e7:	c1 e8 16             	shr    $0x16,%eax
f01011ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01011ed:	09 0c 87             	or     %ecx,(%edi,%eax,4)
        va += PGSIZE;
f01011f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011f6:	eb c5                	jmp    f01011bd <boot_map_region+0x24>
            panic("boot_map_region: pgdir_walk failed to create!\n");
f01011f8:	83 ec 04             	sub    $0x4,%esp
f01011fb:	68 20 6e 10 f0       	push   $0xf0106e20
f0101200:	68 fc 01 00 00       	push   $0x1fc
f0101205:	68 b5 77 10 f0       	push   $0xf01077b5
f010120a:	e8 31 ee ff ff       	call   f0100040 <_panic>
}
f010120f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101212:	5b                   	pop    %ebx
f0101213:	5e                   	pop    %esi
f0101214:	5f                   	pop    %edi
f0101215:	5d                   	pop    %ebp
f0101216:	c3                   	ret    

f0101217 <_info_free_page_list>:
{
f0101217:	55                   	push   %ebp
f0101218:	89 e5                	mov    %esp,%ebp
f010121a:	57                   	push   %edi
f010121b:	56                   	push   %esi
f010121c:	53                   	push   %ebx
f010121d:	83 ec 0c             	sub    $0xc,%esp
    pp = page_free_list;
f0101220:	a1 40 52 21 f0       	mov    0xf0215240,%eax
    len = 0;
f0101225:	bb 00 00 00 00       	mov    $0x0,%ebx
    while (pp->pp_link != NULL){
f010122a:	eb 03                	jmp    f010122f <_info_free_page_list+0x18>
        len += 1;
f010122c:	83 c3 01             	add    $0x1,%ebx
    while (pp->pp_link != NULL){
f010122f:	8b 00                	mov    (%eax),%eax
f0101231:	85 c0                	test   %eax,%eax
f0101233:	75 f7                	jne    f010122c <_info_free_page_list+0x15>
    cprintf("============= free_page_list info ===============\n");
f0101235:	83 ec 0c             	sub    $0xc,%esp
f0101238:	68 50 6e 10 f0       	push   $0xf0106e50
f010123d:	e8 46 2b 00 00       	call   f0103d88 <cprintf>
    cprintf("length %x\n", len);
f0101242:	83 c4 08             	add    $0x8,%esp
f0101245:	53                   	push   %ebx
f0101246:	68 8c 78 10 f0       	push   $0xf010788c
f010124b:	e8 38 2b 00 00       	call   f0103d88 <cprintf>
    pp = page_free_list;
f0101250:	8b 3d 40 52 21 f0    	mov    0xf0215240,%edi
    for (int i=0; i< num && i < len; i++){
f0101256:	83 c4 10             	add    $0x10,%esp
f0101259:	be 00 00 00 00       	mov    $0x0,%esi
f010125e:	eb 1d                	jmp    f010127d <_info_free_page_list+0x66>
        cprintf("%s:%d page%d address %x\n", file, line, i, pp);
f0101260:	83 ec 0c             	sub    $0xc,%esp
f0101263:	57                   	push   %edi
f0101264:	56                   	push   %esi
f0101265:	ff 75 0c             	pushl  0xc(%ebp)
f0101268:	ff 75 08             	pushl  0x8(%ebp)
f010126b:	68 97 78 10 f0       	push   $0xf0107897
f0101270:	e8 13 2b 00 00       	call   f0103d88 <cprintf>
        pp = pp->pp_link;
f0101275:	8b 3f                	mov    (%edi),%edi
    for (int i=0; i< num && i < len; i++){
f0101277:	83 c6 01             	add    $0x1,%esi
f010127a:	83 c4 20             	add    $0x20,%esp
f010127d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
f0101280:	89 d8                	mov    %ebx,%eax
f0101282:	0f 4f 45 10          	cmovg  0x10(%ebp),%eax
f0101286:	39 c6                	cmp    %eax,%esi
f0101288:	7c d6                	jl     f0101260 <_info_free_page_list+0x49>
    cprintf("=================== end =========================\n\n");
f010128a:	83 ec 0c             	sub    $0xc,%esp
f010128d:	68 84 6e 10 f0       	push   $0xf0106e84
f0101292:	e8 f1 2a 00 00       	call   f0103d88 <cprintf>
}
f0101297:	83 c4 10             	add    $0x10,%esp
f010129a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010129d:	5b                   	pop    %ebx
f010129e:	5e                   	pop    %esi
f010129f:	5f                   	pop    %edi
f01012a0:	5d                   	pop    %ebp
f01012a1:	c3                   	ret    

f01012a2 <_info_env_list>:
{
f01012a2:	55                   	push   %ebp
f01012a3:	89 e5                	mov    %esp,%ebp
f01012a5:	57                   	push   %edi
f01012a6:	56                   	push   %esi
f01012a7:	53                   	push   %ebx
f01012a8:	83 ec 0c             	sub    $0xc,%esp
f01012ab:	a1 48 52 21 f0       	mov    0xf0215248,%eax
    for (int i=0; i < NENV; i++) {
f01012b0:	bb 00 00 00 00       	mov    $0x0,%ebx
        if ((uint32_t) e == (uint32_t)(envs + i)) {
f01012b5:	39 45 10             	cmp    %eax,0x10(%ebp)
f01012b8:	74 13                	je     f01012cd <_info_env_list+0x2b>
    for (int i=0; i < NENV; i++) {
f01012ba:	83 c3 01             	add    $0x1,%ebx
f01012bd:	83 c0 7c             	add    $0x7c,%eax
f01012c0:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01012c6:	75 ed                	jne    f01012b5 <_info_env_list+0x13>
    int pos=0;
f01012c8:	bb 00 00 00 00       	mov    $0x0,%ebx
    cprintf("++++++++++++++++ this env info ++++++++++++++++ \n");
f01012cd:	83 ec 0c             	sub    $0xc,%esp
f01012d0:	68 b8 6e 10 f0       	push   $0xf0106eb8
f01012d5:	e8 ae 2a 00 00       	call   f0103d88 <cprintf>
    cprintf("%s:%d idx %d, env.addr %x, env.env_tf %x, tf_eip %x \n", file, line, pos, e,
f01012da:	83 c4 0c             	add    $0xc,%esp
f01012dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01012e0:	ff 70 30             	pushl  0x30(%eax)
f01012e3:	83 ec 44             	sub    $0x44,%esp
f01012e6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01012eb:	89 e7                	mov    %esp,%edi
f01012ed:	89 c6                	mov    %eax,%esi
f01012ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01012f1:	50                   	push   %eax
f01012f2:	53                   	push   %ebx
f01012f3:	ff 75 0c             	pushl  0xc(%ebp)
f01012f6:	ff 75 08             	pushl  0x8(%ebp)
f01012f9:	68 ec 6e 10 f0       	push   $0xf0106eec
f01012fe:	e8 85 2a 00 00       	call   f0103d88 <cprintf>
    cprintf("+++++++++++++++++++++ end +++++++++++++++++++++ \n\n");
f0101303:	83 c4 54             	add    $0x54,%esp
f0101306:	68 24 6f 10 f0       	push   $0xf0106f24
f010130b:	e8 78 2a 00 00       	call   f0103d88 <cprintf>
}
f0101310:	83 c4 10             	add    $0x10,%esp
f0101313:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101316:	5b                   	pop    %ebx
f0101317:	5e                   	pop    %esi
f0101318:	5f                   	pop    %edi
f0101319:	5d                   	pop    %ebp
f010131a:	c3                   	ret    

f010131b <_fprintf>:
{
f010131b:	55                   	push   %ebp
f010131c:	89 e5                	mov    %esp,%ebp
f010131e:	83 ec 0c             	sub    $0xc,%esp
    cprintf("%s:%d ", file, line);
f0101321:	ff 75 0c             	pushl  0xc(%ebp)
f0101324:	ff 75 08             	pushl  0x8(%ebp)
f0101327:	68 b0 78 10 f0       	push   $0xf01078b0
f010132c:	e8 57 2a 00 00       	call   f0103d88 <cprintf>
    va_start(ap, fmt);
f0101331:	8d 45 14             	lea    0x14(%ebp),%eax
    vcprintf(fmt, ap);
f0101334:	83 c4 08             	add    $0x8,%esp
f0101337:	50                   	push   %eax
f0101338:	ff 75 10             	pushl  0x10(%ebp)
f010133b:	e8 22 2a 00 00       	call   f0103d62 <vcprintf>
    cprintf("\n");
f0101340:	c7 04 24 ec 78 10 f0 	movl   $0xf01078ec,(%esp)
f0101347:	e8 3c 2a 00 00       	call   f0103d88 <cprintf>
}
f010134c:	83 c4 10             	add    $0x10,%esp
f010134f:	c9                   	leave  
f0101350:	c3                   	ret    

f0101351 <_printf_mem>:
{
f0101351:	55                   	push   %ebp
f0101352:	89 e5                	mov    %esp,%ebp
f0101354:	57                   	push   %edi
f0101355:	56                   	push   %esi
f0101356:	53                   	push   %ebx
f0101357:	83 ec 18             	sub    $0x18,%esp
f010135a:	8b 75 10             	mov    0x10(%ebp),%esi
f010135d:	8b 7d 14             	mov    0x14(%ebp),%edi
    cprintf("%s:%d 0x%x~%x:", file, line, start, (uint32_t *)start + cnt);
f0101360:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0101363:	50                   	push   %eax
f0101364:	56                   	push   %esi
f0101365:	ff 75 0c             	pushl  0xc(%ebp)
f0101368:	ff 75 08             	pushl  0x8(%ebp)
f010136b:	68 b7 78 10 f0       	push   $0xf01078b7
f0101370:	e8 13 2a 00 00       	call   f0103d88 <cprintf>
    for (int i=0; i<cnt; i++)
f0101375:	83 c4 20             	add    $0x20,%esp
f0101378:	bb 00 00 00 00       	mov    $0x0,%ebx
f010137d:	eb 16                	jmp    f0101395 <_printf_mem+0x44>
        cprintf("%x ", *((uint32_t *)start + i));
f010137f:	83 ec 08             	sub    $0x8,%esp
f0101382:	ff 34 9e             	pushl  (%esi,%ebx,4)
f0101385:	68 c6 78 10 f0       	push   $0xf01078c6
f010138a:	e8 f9 29 00 00       	call   f0103d88 <cprintf>
    for (int i=0; i<cnt; i++)
f010138f:	83 c3 01             	add    $0x1,%ebx
f0101392:	83 c4 10             	add    $0x10,%esp
f0101395:	39 fb                	cmp    %edi,%ebx
f0101397:	7c e6                	jl     f010137f <_printf_mem+0x2e>
    cprintf("\n");
f0101399:	83 ec 0c             	sub    $0xc,%esp
f010139c:	68 ec 78 10 f0       	push   $0xf01078ec
f01013a1:	e8 e2 29 00 00       	call   f0103d88 <cprintf>
}
f01013a6:	83 c4 10             	add    $0x10,%esp
f01013a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013ac:	5b                   	pop    %ebx
f01013ad:	5e                   	pop    %esi
f01013ae:	5f                   	pop    %edi
f01013af:	5d                   	pop    %ebp
f01013b0:	c3                   	ret    

f01013b1 <printf_from_page>:
{
f01013b1:	55                   	push   %ebp
f01013b2:	89 e5                	mov    %esp,%ebp
f01013b4:	57                   	push   %edi
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	83 ec 20             	sub    $0x20,%esp
f01013ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    pgtable = pgdir_walk((pte_t *) pgdir, va, 0);
f01013bd:	6a 00                	push   $0x0
f01013bf:	53                   	push   %ebx
f01013c0:	ff 75 08             	pushl  0x8(%ebp)
f01013c3:	e8 ec fc ff ff       	call   f01010b4 <pgdir_walk>
    base  = (uint32_t * )(page2kva(pa2page(PTE_ADDR(pgtable[PTX(va)]))));
f01013c8:	89 de                	mov    %ebx,%esi
f01013ca:	c1 eb 0c             	shr    $0xc,%ebx
f01013cd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01013d3:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f01013d6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d9:	8b 15 88 5e 21 f0    	mov    0xf0215e88,%edx
f01013df:	83 c4 10             	add    $0x10,%esp
f01013e2:	39 c2                	cmp    %eax,%edx
f01013e4:	76 3f                	jbe    f0101425 <printf_from_page+0x74>
	if (PGNUM(pa) >= npages)
f01013e6:	89 c7                	mov    %eax,%edi
f01013e8:	c1 e7 0c             	shl    $0xc,%edi
f01013eb:	39 d0                	cmp    %edx,%eax
f01013ed:	73 4a                	jae    f0101439 <printf_from_page+0x88>
    kprintf("base %x offset %x", base, offset);
f01013ef:	83 ec 0c             	sub    $0xc,%esp
f01013f2:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01013f4:	8d 87 00 00 00 f0    	lea    -0x10000000(%edi),%eax
f01013fa:	50                   	push   %eax
f01013fb:	68 ca 78 10 f0       	push   $0xf01078ca
f0101400:	68 7e 02 00 00       	push   $0x27e
f0101405:	68 b5 77 10 f0       	push   $0xf01077b5
f010140a:	e8 0c ff ff ff       	call   f010131b <_fprintf>
    for (int i=0; i<cnt; i++){
f010140f:	83 c4 20             	add    $0x20,%esp
f0101412:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101417:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
        cprintf("addr:%x, val:%x \n", offset, *offset);
f010141d:	8d 04 3e             	lea    (%esi,%edi,1),%eax
f0101420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (int i=0; i<cnt; i++){
f0101423:	eb 4e                	jmp    f0101473 <printf_from_page+0xc2>
		panic("pa2page called with invalid pa");
f0101425:	83 ec 04             	sub    $0x4,%esp
f0101428:	68 58 6f 10 f0       	push   $0xf0106f58
f010142d:	6a 51                	push   $0x51
f010142f:	68 c1 77 10 f0       	push   $0xf01077c1
f0101434:	e8 07 ec ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101439:	57                   	push   %edi
f010143a:	68 64 67 10 f0       	push   $0xf0106764
f010143f:	6a 58                	push   $0x58
f0101441:	68 c1 77 10 f0       	push   $0xf01077c1
f0101446:	e8 f5 eb ff ff       	call   f0100040 <_panic>
        cprintf("addr:%x, val:%x \n", offset, *offset);
f010144b:	83 ec 04             	sub    $0x4,%esp
f010144e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101451:	ff b4 98 00 00 00 f0 	pushl  -0x10000000(%eax,%ebx,4)
f0101458:	8d 84 37 00 00 00 f0 	lea    -0x10000000(%edi,%esi,1),%eax
f010145f:	8d 04 98             	lea    (%eax,%ebx,4),%eax
f0101462:	50                   	push   %eax
f0101463:	68 dc 78 10 f0       	push   $0xf01078dc
f0101468:	e8 1b 29 00 00       	call   f0103d88 <cprintf>
    for (int i=0; i<cnt; i++){
f010146d:	83 c3 01             	add    $0x1,%ebx
f0101470:	83 c4 10             	add    $0x10,%esp
f0101473:	3b 5d 10             	cmp    0x10(%ebp),%ebx
f0101476:	7c d3                	jl     f010144b <printf_from_page+0x9a>
    cprintf("\n");
f0101478:	83 ec 0c             	sub    $0xc,%esp
f010147b:	68 ec 78 10 f0       	push   $0xf01078ec
f0101480:	e8 03 29 00 00       	call   f0103d88 <cprintf>
}
f0101485:	83 c4 10             	add    $0x10,%esp
f0101488:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010148b:	5b                   	pop    %ebx
f010148c:	5e                   	pop    %esi
f010148d:	5f                   	pop    %edi
f010148e:	5d                   	pop    %ebp
f010148f:	c3                   	ret    

f0101490 <page_lookup>:
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	53                   	push   %ebx
f0101494:	83 ec 08             	sub    $0x8,%esp
f0101497:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f010149a:	6a 00                	push   $0x0
f010149c:	ff 75 0c             	pushl  0xc(%ebp)
f010149f:	ff 75 08             	pushl  0x8(%ebp)
f01014a2:	e8 0d fc ff ff       	call   f01010b4 <pgdir_walk>
    if (pte == NULL) {
f01014a7:	83 c4 10             	add    $0x10,%esp
f01014aa:	85 c0                	test   %eax,%eax
f01014ac:	74 36                	je     f01014e4 <page_lookup+0x54>
f01014ae:	89 c1                	mov    %eax,%ecx
f01014b0:	8b 10                	mov    (%eax),%edx
f01014b2:	c1 ea 0c             	shr    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01014b5:	39 15 88 5e 21 f0    	cmp    %edx,0xf0215e88
f01014bb:	76 13                	jbe    f01014d0 <page_lookup+0x40>
	return &pages[PGNUM(pa)];
f01014bd:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f01014c2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
    if (pte_store != NULL) {
f01014c5:	85 db                	test   %ebx,%ebx
f01014c7:	74 02                	je     f01014cb <page_lookup+0x3b>
        *pte_store = pte;
f01014c9:	89 0b                	mov    %ecx,(%ebx)
}
f01014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014ce:	c9                   	leave  
f01014cf:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01014d0:	83 ec 04             	sub    $0x4,%esp
f01014d3:	68 58 6f 10 f0       	push   $0xf0106f58
f01014d8:	6a 51                	push   $0x51
f01014da:	68 c1 77 10 f0       	push   $0xf01077c1
f01014df:	e8 5c eb ff ff       	call   f0100040 <_panic>
        return NULL;
f01014e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01014e9:	eb e0                	jmp    f01014cb <page_lookup+0x3b>

f01014eb <tlb_invalidate>:
{
f01014eb:	55                   	push   %ebp
f01014ec:	89 e5                	mov    %esp,%ebp
f01014ee:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01014f1:	e8 15 4c 00 00       	call   f010610b <cpunum>
f01014f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01014f9:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0101500:	74 16                	je     f0101518 <tlb_invalidate+0x2d>
f0101502:	e8 04 4c 00 00       	call   f010610b <cpunum>
f0101507:	6b c0 74             	imul   $0x74,%eax,%eax
f010150a:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0101510:	8b 55 08             	mov    0x8(%ebp),%edx
f0101513:	39 50 60             	cmp    %edx,0x60(%eax)
f0101516:	75 06                	jne    f010151e <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101518:	8b 45 0c             	mov    0xc(%ebp),%eax
f010151b:	0f 01 38             	invlpg (%eax)
}
f010151e:	c9                   	leave  
f010151f:	c3                   	ret    

f0101520 <page_remove>:
{
f0101520:	55                   	push   %ebp
f0101521:	89 e5                	mov    %esp,%ebp
f0101523:	56                   	push   %esi
f0101524:	53                   	push   %ebx
f0101525:	83 ec 14             	sub    $0x14,%esp
f0101528:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010152b:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f010152e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101531:	50                   	push   %eax
f0101532:	56                   	push   %esi
f0101533:	53                   	push   %ebx
f0101534:	e8 57 ff ff ff       	call   f0101490 <page_lookup>
    if (pp == NULL) {
f0101539:	83 c4 10             	add    $0x10,%esp
f010153c:	85 c0                	test   %eax,%eax
f010153e:	75 07                	jne    f0101547 <page_remove+0x27>
}
f0101540:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101543:	5b                   	pop    %ebx
f0101544:	5e                   	pop    %esi
f0101545:	5d                   	pop    %ebp
f0101546:	c3                   	ret    
    *pte_store = 0;
f0101547:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010154a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
    page_decref(pp);
f0101550:	83 ec 0c             	sub    $0xc,%esp
f0101553:	50                   	push   %eax
f0101554:	e8 32 fb ff ff       	call   f010108b <page_decref>
    tlb_invalidate(pgdir, va);
f0101559:	83 c4 08             	add    $0x8,%esp
f010155c:	56                   	push   %esi
f010155d:	53                   	push   %ebx
f010155e:	e8 88 ff ff ff       	call   f01014eb <tlb_invalidate>
f0101563:	83 c4 10             	add    $0x10,%esp
f0101566:	eb d8                	jmp    f0101540 <page_remove+0x20>

f0101568 <page_insert>:
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
f010156b:	57                   	push   %edi
f010156c:	56                   	push   %esi
f010156d:	53                   	push   %ebx
f010156e:	83 ec 10             	sub    $0x10,%esp
f0101571:	8b 75 08             	mov    0x8(%ebp),%esi
f0101574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101577:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f010157a:	6a 00                	push   $0x0
f010157c:	57                   	push   %edi
f010157d:	56                   	push   %esi
f010157e:	e8 31 fb ff ff       	call   f01010b4 <pgdir_walk>
    if (pte != NULL) {
f0101583:	83 c4 10             	add    $0x10,%esp
f0101586:	85 c0                	test   %eax,%eax
f0101588:	74 2c                	je     f01015b6 <page_insert+0x4e>
        if ((*pte & PTE_P) && PTE_ADDR(*pte) == page2pa(pp)) {
f010158a:	8b 10                	mov    (%eax),%edx
f010158c:	f6 c2 01             	test   $0x1,%dl
f010158f:	74 25                	je     f01015b6 <page_insert+0x4e>
f0101591:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0101597:	89 d9                	mov    %ebx,%ecx
f0101599:	2b 0d 90 5e 21 f0    	sub    0xf0215e90,%ecx
f010159f:	c1 f9 03             	sar    $0x3,%ecx
f01015a2:	c1 e1 0c             	shl    $0xc,%ecx
f01015a5:	39 ca                	cmp    %ecx,%edx
f01015a7:	74 4a                	je     f01015f3 <page_insert+0x8b>
            page_remove(pgdir, va);
f01015a9:	83 ec 08             	sub    $0x8,%esp
f01015ac:	57                   	push   %edi
f01015ad:	56                   	push   %esi
f01015ae:	e8 6d ff ff ff       	call   f0101520 <page_remove>
f01015b3:	83 c4 10             	add    $0x10,%esp
    pte = pgdir_walk(pgdir, va, 1);
f01015b6:	83 ec 04             	sub    $0x4,%esp
f01015b9:	6a 01                	push   $0x1
f01015bb:	57                   	push   %edi
f01015bc:	56                   	push   %esi
f01015bd:	e8 f2 fa ff ff       	call   f01010b4 <pgdir_walk>
    if (pte == NULL) {
f01015c2:	83 c4 10             	add    $0x10,%esp
f01015c5:	85 c0                	test   %eax,%eax
f01015c7:	74 3b                	je     f0101604 <page_insert+0x9c>
f01015c9:	89 da                	mov    %ebx,%edx
f01015cb:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f01015d1:	c1 fa 03             	sar    $0x3,%edx
f01015d4:	c1 e2 0c             	shl    $0xc,%edx
    *pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f01015d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01015da:	83 c9 01             	or     $0x1,%ecx
f01015dd:	09 ca                	or     %ecx,%edx
f01015df:	89 10                	mov    %edx,(%eax)
    pp->pp_ref += 1;
f01015e1:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    return 0;
f01015e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015ee:	5b                   	pop    %ebx
f01015ef:	5e                   	pop    %esi
f01015f0:	5f                   	pop    %edi
f01015f1:	5d                   	pop    %ebp
f01015f2:	c3                   	ret    
            *pte = PTE_ADDR(*pte) | perm | PTE_P;
f01015f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01015f6:	83 c9 01             	or     $0x1,%ecx
f01015f9:	09 ca                	or     %ecx,%edx
f01015fb:	89 10                	mov    %edx,(%eax)
            return 0;
f01015fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101602:	eb e7                	jmp    f01015eb <page_insert+0x83>
        return -E_NO_MEM;
f0101604:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101609:	eb e0                	jmp    f01015eb <page_insert+0x83>

f010160b <mmio_map_region>:
{
f010160b:	55                   	push   %ebp
f010160c:	89 e5                	mov    %esp,%ebp
f010160e:	56                   	push   %esi
f010160f:	53                   	push   %ebx
    uintptr_t rem = base;
f0101610:	8b 35 00 23 12 f0    	mov    0xf0122300,%esi
    size = ROUNDUP(size, PGSIZE);
f0101616:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101619:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010161f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if (base + size >= MMIOLIM) {
f0101625:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101628:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010162d:	77 25                	ja     f0101654 <mmio_map_region+0x49>
    boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010162f:	83 ec 08             	sub    $0x8,%esp
f0101632:	6a 1a                	push   $0x1a
f0101634:	ff 75 08             	pushl  0x8(%ebp)
f0101637:	89 d9                	mov    %ebx,%ecx
f0101639:	89 f2                	mov    %esi,%edx
f010163b:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101640:	e8 54 fb ff ff       	call   f0101199 <boot_map_region>
    base += size;
f0101645:	01 1d 00 23 12 f0    	add    %ebx,0xf0122300
}
f010164b:	89 f0                	mov    %esi,%eax
f010164d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101650:	5b                   	pop    %ebx
f0101651:	5e                   	pop    %esi
f0101652:	5d                   	pop    %ebp
f0101653:	c3                   	ret    
        panic("MMIO reservation overflow MMIOLIM");
f0101654:	83 ec 04             	sub    $0x4,%esp
f0101657:	68 78 6f 10 f0       	push   $0xf0106f78
f010165c:	68 ef 02 00 00       	push   $0x2ef
f0101661:	68 b5 77 10 f0       	push   $0xf01077b5
f0101666:	e8 d5 e9 ff ff       	call   f0100040 <_panic>

f010166b <mem_init>:
{
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	57                   	push   %edi
f010166f:	56                   	push   %esi
f0101670:	53                   	push   %ebx
f0101671:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101674:	b8 15 00 00 00       	mov    $0x15,%eax
f0101679:	e8 fc f3 ff ff       	call   f0100a7a <nvram_read>
f010167e:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101680:	b8 17 00 00 00       	mov    $0x17,%eax
f0101685:	e8 f0 f3 ff ff       	call   f0100a7a <nvram_read>
f010168a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010168c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101691:	e8 e4 f3 ff ff       	call   f0100a7a <nvram_read>
f0101696:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101699:	85 c0                	test   %eax,%eax
f010169b:	0f 85 fb 00 00 00    	jne    f010179c <mem_init+0x131>
		totalmem = 1 * 1024 + extmem;
f01016a1:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01016a7:	85 f6                	test   %esi,%esi
f01016a9:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f01016ac:	89 c2                	mov    %eax,%edx
f01016ae:	c1 ea 02             	shr    $0x2,%edx
f01016b1:	89 15 88 5e 21 f0    	mov    %edx,0xf0215e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01016b7:	89 da                	mov    %ebx,%edx
f01016b9:	c1 ea 02             	shr    $0x2,%edx
f01016bc:	89 15 44 52 21 f0    	mov    %edx,0xf0215244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016c2:	89 c2                	mov    %eax,%edx
f01016c4:	29 da                	sub    %ebx,%edx
f01016c6:	52                   	push   %edx
f01016c7:	53                   	push   %ebx
f01016c8:	50                   	push   %eax
f01016c9:	68 9c 6f 10 f0       	push   $0xf0106f9c
f01016ce:	e8 b5 26 00 00       	call   f0103d88 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016d3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016d8:	e8 c6 f3 ff ff       	call   f0100aa3 <boot_alloc>
f01016dd:	a3 8c 5e 21 f0       	mov    %eax,0xf0215e8c
	memset(kern_pgdir, 0, PGSIZE);
f01016e2:	83 c4 0c             	add    $0xc,%esp
f01016e5:	68 00 10 00 00       	push   $0x1000
f01016ea:	6a 00                	push   $0x0
f01016ec:	50                   	push   %eax
f01016ed:	e8 f6 43 00 00       	call   f0105ae8 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01016f2:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01016f7:	83 c4 10             	add    $0x10,%esp
f01016fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016ff:	0f 86 a1 00 00 00    	jbe    f01017a6 <mem_init+0x13b>
	return (physaddr_t)kva - KERNBASE;
f0101705:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010170b:	83 ca 05             	or     $0x5,%edx
f010170e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
    pages = (struct PageInfo *) boot_alloc(0);
f0101714:	b8 00 00 00 00       	mov    $0x0,%eax
f0101719:	e8 85 f3 ff ff       	call   f0100aa3 <boot_alloc>
f010171e:	a3 90 5e 21 f0       	mov    %eax,0xf0215e90
    uint32_t size = sizeof(struct PageInfo) * npages;
f0101723:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f0101728:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
    boot_alloc(size);
f010172f:	89 d8                	mov    %ebx,%eax
f0101731:	e8 6d f3 ff ff       	call   f0100aa3 <boot_alloc>
    memset(pages, 0, size);
f0101736:	83 ec 04             	sub    $0x4,%esp
f0101739:	53                   	push   %ebx
f010173a:	6a 00                	push   $0x0
f010173c:	ff 35 90 5e 21 f0    	pushl  0xf0215e90
f0101742:	e8 a1 43 00 00       	call   f0105ae8 <memset>
    envs = (struct Env *) boot_alloc(0);
f0101747:	b8 00 00 00 00       	mov    $0x0,%eax
f010174c:	e8 52 f3 ff ff       	call   f0100aa3 <boot_alloc>
f0101751:	a3 48 52 21 f0       	mov    %eax,0xf0215248
    boot_alloc(size);
f0101756:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010175b:	e8 43 f3 ff ff       	call   f0100aa3 <boot_alloc>
    memset(envs, 0, size);
f0101760:	83 c4 0c             	add    $0xc,%esp
f0101763:	68 00 f0 01 00       	push   $0x1f000
f0101768:	6a 00                	push   $0x0
f010176a:	ff 35 48 52 21 f0    	pushl  0xf0215248
f0101770:	e8 73 43 00 00       	call   f0105ae8 <memset>
	page_init();
f0101775:	e8 04 f7 ff ff       	call   f0100e7e <page_init>
	check_page_free_list(1);
f010177a:	b8 01 00 00 00       	mov    $0x1,%eax
f010177f:	e8 fd f3 ff ff       	call   f0100b81 <check_page_free_list>
	if (!pages)
f0101784:	83 c4 10             	add    $0x10,%esp
f0101787:	83 3d 90 5e 21 f0 00 	cmpl   $0x0,0xf0215e90
f010178e:	74 2b                	je     f01017bb <mem_init+0x150>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101790:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0101795:	bb 00 00 00 00       	mov    $0x0,%ebx
f010179a:	eb 3b                	jmp    f01017d7 <mem_init+0x16c>
		totalmem = 16 * 1024 + ext16mem;
f010179c:	05 00 40 00 00       	add    $0x4000,%eax
f01017a1:	e9 06 ff ff ff       	jmp    f01016ac <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017a6:	50                   	push   %eax
f01017a7:	68 88 67 10 f0       	push   $0xf0106788
f01017ac:	68 9e 00 00 00       	push   $0x9e
f01017b1:	68 b5 77 10 f0       	push   $0xf01077b5
f01017b6:	e8 85 e8 ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01017bb:	83 ec 04             	sub    $0x4,%esp
f01017be:	68 ee 78 10 f0       	push   $0xf01078ee
f01017c3:	68 8d 03 00 00       	push   $0x38d
f01017c8:	68 b5 77 10 f0       	push   $0xf01077b5
f01017cd:	e8 6e e8 ff ff       	call   f0100040 <_panic>
		++nfree;
f01017d2:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017d5:	8b 00                	mov    (%eax),%eax
f01017d7:	85 c0                	test   %eax,%eax
f01017d9:	75 f7                	jne    f01017d2 <mem_init+0x167>
	assert((pp0 = page_alloc(0)));
f01017db:	83 ec 0c             	sub    $0xc,%esp
f01017de:	6a 00                	push   $0x0
f01017e0:	e8 e4 f7 ff ff       	call   f0100fc9 <page_alloc>
f01017e5:	89 c7                	mov    %eax,%edi
f01017e7:	83 c4 10             	add    $0x10,%esp
f01017ea:	85 c0                	test   %eax,%eax
f01017ec:	0f 84 12 02 00 00    	je     f0101a04 <mem_init+0x399>
	assert((pp1 = page_alloc(0)));
f01017f2:	83 ec 0c             	sub    $0xc,%esp
f01017f5:	6a 00                	push   $0x0
f01017f7:	e8 cd f7 ff ff       	call   f0100fc9 <page_alloc>
f01017fc:	89 c6                	mov    %eax,%esi
f01017fe:	83 c4 10             	add    $0x10,%esp
f0101801:	85 c0                	test   %eax,%eax
f0101803:	0f 84 14 02 00 00    	je     f0101a1d <mem_init+0x3b2>
	assert((pp2 = page_alloc(0)));
f0101809:	83 ec 0c             	sub    $0xc,%esp
f010180c:	6a 00                	push   $0x0
f010180e:	e8 b6 f7 ff ff       	call   f0100fc9 <page_alloc>
f0101813:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101816:	83 c4 10             	add    $0x10,%esp
f0101819:	85 c0                	test   %eax,%eax
f010181b:	0f 84 15 02 00 00    	je     f0101a36 <mem_init+0x3cb>
	assert(pp1 && pp1 != pp0);
f0101821:	39 f7                	cmp    %esi,%edi
f0101823:	0f 84 26 02 00 00    	je     f0101a4f <mem_init+0x3e4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101829:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010182c:	39 c6                	cmp    %eax,%esi
f010182e:	0f 84 34 02 00 00    	je     f0101a68 <mem_init+0x3fd>
f0101834:	39 c7                	cmp    %eax,%edi
f0101836:	0f 84 2c 02 00 00    	je     f0101a68 <mem_init+0x3fd>
	return (pp - pages) << PGSHIFT;
f010183c:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101842:	8b 15 88 5e 21 f0    	mov    0xf0215e88,%edx
f0101848:	c1 e2 0c             	shl    $0xc,%edx
f010184b:	89 f8                	mov    %edi,%eax
f010184d:	29 c8                	sub    %ecx,%eax
f010184f:	c1 f8 03             	sar    $0x3,%eax
f0101852:	c1 e0 0c             	shl    $0xc,%eax
f0101855:	39 d0                	cmp    %edx,%eax
f0101857:	0f 83 24 02 00 00    	jae    f0101a81 <mem_init+0x416>
f010185d:	89 f0                	mov    %esi,%eax
f010185f:	29 c8                	sub    %ecx,%eax
f0101861:	c1 f8 03             	sar    $0x3,%eax
f0101864:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101867:	39 c2                	cmp    %eax,%edx
f0101869:	0f 86 2b 02 00 00    	jbe    f0101a9a <mem_init+0x42f>
f010186f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101872:	29 c8                	sub    %ecx,%eax
f0101874:	c1 f8 03             	sar    $0x3,%eax
f0101877:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010187a:	39 c2                	cmp    %eax,%edx
f010187c:	0f 86 31 02 00 00    	jbe    f0101ab3 <mem_init+0x448>
	fl = page_free_list;
f0101882:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0101887:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010188a:	c7 05 40 52 21 f0 00 	movl   $0x0,0xf0215240
f0101891:	00 00 00 
	assert(!page_alloc(0));
f0101894:	83 ec 0c             	sub    $0xc,%esp
f0101897:	6a 00                	push   $0x0
f0101899:	e8 2b f7 ff ff       	call   f0100fc9 <page_alloc>
f010189e:	83 c4 10             	add    $0x10,%esp
f01018a1:	85 c0                	test   %eax,%eax
f01018a3:	0f 85 23 02 00 00    	jne    f0101acc <mem_init+0x461>
	page_free(pp0);
f01018a9:	83 ec 0c             	sub    $0xc,%esp
f01018ac:	57                   	push   %edi
f01018ad:	e8 89 f7 ff ff       	call   f010103b <page_free>
	page_free(pp1);
f01018b2:	89 34 24             	mov    %esi,(%esp)
f01018b5:	e8 81 f7 ff ff       	call   f010103b <page_free>
	page_free(pp2);
f01018ba:	83 c4 04             	add    $0x4,%esp
f01018bd:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018c0:	e8 76 f7 ff ff       	call   f010103b <page_free>
	assert((pp0 = page_alloc(0)));
f01018c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018cc:	e8 f8 f6 ff ff       	call   f0100fc9 <page_alloc>
f01018d1:	89 c6                	mov    %eax,%esi
f01018d3:	83 c4 10             	add    $0x10,%esp
f01018d6:	85 c0                	test   %eax,%eax
f01018d8:	0f 84 07 02 00 00    	je     f0101ae5 <mem_init+0x47a>
	assert((pp1 = page_alloc(0)));
f01018de:	83 ec 0c             	sub    $0xc,%esp
f01018e1:	6a 00                	push   $0x0
f01018e3:	e8 e1 f6 ff ff       	call   f0100fc9 <page_alloc>
f01018e8:	89 c7                	mov    %eax,%edi
f01018ea:	83 c4 10             	add    $0x10,%esp
f01018ed:	85 c0                	test   %eax,%eax
f01018ef:	0f 84 09 02 00 00    	je     f0101afe <mem_init+0x493>
	assert((pp2 = page_alloc(0)));
f01018f5:	83 ec 0c             	sub    $0xc,%esp
f01018f8:	6a 00                	push   $0x0
f01018fa:	e8 ca f6 ff ff       	call   f0100fc9 <page_alloc>
f01018ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101902:	83 c4 10             	add    $0x10,%esp
f0101905:	85 c0                	test   %eax,%eax
f0101907:	0f 84 0a 02 00 00    	je     f0101b17 <mem_init+0x4ac>
	assert(pp1 && pp1 != pp0);
f010190d:	39 fe                	cmp    %edi,%esi
f010190f:	0f 84 1b 02 00 00    	je     f0101b30 <mem_init+0x4c5>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101915:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101918:	39 c6                	cmp    %eax,%esi
f010191a:	0f 84 29 02 00 00    	je     f0101b49 <mem_init+0x4de>
f0101920:	39 c7                	cmp    %eax,%edi
f0101922:	0f 84 21 02 00 00    	je     f0101b49 <mem_init+0x4de>
	assert(!page_alloc(0));
f0101928:	83 ec 0c             	sub    $0xc,%esp
f010192b:	6a 00                	push   $0x0
f010192d:	e8 97 f6 ff ff       	call   f0100fc9 <page_alloc>
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	85 c0                	test   %eax,%eax
f0101937:	0f 85 25 02 00 00    	jne    f0101b62 <mem_init+0x4f7>
f010193d:	89 f0                	mov    %esi,%eax
f010193f:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101945:	c1 f8 03             	sar    $0x3,%eax
f0101948:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010194b:	89 c2                	mov    %eax,%edx
f010194d:	c1 ea 0c             	shr    $0xc,%edx
f0101950:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0101956:	0f 83 1f 02 00 00    	jae    f0101b7b <mem_init+0x510>
	memset(page2kva(pp0), 1, PGSIZE);
f010195c:	83 ec 04             	sub    $0x4,%esp
f010195f:	68 00 10 00 00       	push   $0x1000
f0101964:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101966:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010196b:	50                   	push   %eax
f010196c:	e8 77 41 00 00       	call   f0105ae8 <memset>
	page_free(pp0);
f0101971:	89 34 24             	mov    %esi,(%esp)
f0101974:	e8 c2 f6 ff ff       	call   f010103b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101979:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101980:	e8 44 f6 ff ff       	call   f0100fc9 <page_alloc>
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	85 c0                	test   %eax,%eax
f010198a:	0f 84 fd 01 00 00    	je     f0101b8d <mem_init+0x522>
	assert(pp && pp0 == pp);
f0101990:	39 c6                	cmp    %eax,%esi
f0101992:	0f 85 0e 02 00 00    	jne    f0101ba6 <mem_init+0x53b>
	return (pp - pages) << PGSHIFT;
f0101998:	89 f2                	mov    %esi,%edx
f010199a:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f01019a0:	c1 fa 03             	sar    $0x3,%edx
f01019a3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01019a6:	89 d0                	mov    %edx,%eax
f01019a8:	c1 e8 0c             	shr    $0xc,%eax
f01019ab:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f01019b1:	0f 83 08 02 00 00    	jae    f0101bbf <mem_init+0x554>
	return (void *)(pa + KERNBASE);
f01019b7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01019bd:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01019c3:	80 38 00             	cmpb   $0x0,(%eax)
f01019c6:	0f 85 05 02 00 00    	jne    f0101bd1 <mem_init+0x566>
f01019cc:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01019cf:	39 d0                	cmp    %edx,%eax
f01019d1:	75 f0                	jne    f01019c3 <mem_init+0x358>
	page_free_list = fl;
f01019d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019d6:	a3 40 52 21 f0       	mov    %eax,0xf0215240
	page_free(pp0);
f01019db:	83 ec 0c             	sub    $0xc,%esp
f01019de:	56                   	push   %esi
f01019df:	e8 57 f6 ff ff       	call   f010103b <page_free>
	page_free(pp1);
f01019e4:	89 3c 24             	mov    %edi,(%esp)
f01019e7:	e8 4f f6 ff ff       	call   f010103b <page_free>
	page_free(pp2);
f01019ec:	83 c4 04             	add    $0x4,%esp
f01019ef:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019f2:	e8 44 f6 ff ff       	call   f010103b <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019f7:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f01019fc:	83 c4 10             	add    $0x10,%esp
f01019ff:	e9 eb 01 00 00       	jmp    f0101bef <mem_init+0x584>
	assert((pp0 = page_alloc(0)));
f0101a04:	68 09 79 10 f0       	push   $0xf0107909
f0101a09:	68 db 77 10 f0       	push   $0xf01077db
f0101a0e:	68 95 03 00 00       	push   $0x395
f0101a13:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a18:	e8 23 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a1d:	68 1f 79 10 f0       	push   $0xf010791f
f0101a22:	68 db 77 10 f0       	push   $0xf01077db
f0101a27:	68 96 03 00 00       	push   $0x396
f0101a2c:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a31:	e8 0a e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a36:	68 35 79 10 f0       	push   $0xf0107935
f0101a3b:	68 db 77 10 f0       	push   $0xf01077db
f0101a40:	68 97 03 00 00       	push   $0x397
f0101a45:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a4a:	e8 f1 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a4f:	68 4b 79 10 f0       	push   $0xf010794b
f0101a54:	68 db 77 10 f0       	push   $0xf01077db
f0101a59:	68 9a 03 00 00       	push   $0x39a
f0101a5e:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a63:	e8 d8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a68:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0101a6d:	68 db 77 10 f0       	push   $0xf01077db
f0101a72:	68 9b 03 00 00       	push   $0x39b
f0101a77:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a7c:	e8 bf e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a81:	68 5d 79 10 f0       	push   $0xf010795d
f0101a86:	68 db 77 10 f0       	push   $0xf01077db
f0101a8b:	68 9c 03 00 00       	push   $0x39c
f0101a90:	68 b5 77 10 f0       	push   $0xf01077b5
f0101a95:	e8 a6 e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a9a:	68 7a 79 10 f0       	push   $0xf010797a
f0101a9f:	68 db 77 10 f0       	push   $0xf01077db
f0101aa4:	68 9d 03 00 00       	push   $0x39d
f0101aa9:	68 b5 77 10 f0       	push   $0xf01077b5
f0101aae:	e8 8d e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ab3:	68 97 79 10 f0       	push   $0xf0107997
f0101ab8:	68 db 77 10 f0       	push   $0xf01077db
f0101abd:	68 9e 03 00 00       	push   $0x39e
f0101ac2:	68 b5 77 10 f0       	push   $0xf01077b5
f0101ac7:	e8 74 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101acc:	68 b4 79 10 f0       	push   $0xf01079b4
f0101ad1:	68 db 77 10 f0       	push   $0xf01077db
f0101ad6:	68 a5 03 00 00       	push   $0x3a5
f0101adb:	68 b5 77 10 f0       	push   $0xf01077b5
f0101ae0:	e8 5b e5 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101ae5:	68 09 79 10 f0       	push   $0xf0107909
f0101aea:	68 db 77 10 f0       	push   $0xf01077db
f0101aef:	68 ac 03 00 00       	push   $0x3ac
f0101af4:	68 b5 77 10 f0       	push   $0xf01077b5
f0101af9:	e8 42 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101afe:	68 1f 79 10 f0       	push   $0xf010791f
f0101b03:	68 db 77 10 f0       	push   $0xf01077db
f0101b08:	68 ad 03 00 00       	push   $0x3ad
f0101b0d:	68 b5 77 10 f0       	push   $0xf01077b5
f0101b12:	e8 29 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b17:	68 35 79 10 f0       	push   $0xf0107935
f0101b1c:	68 db 77 10 f0       	push   $0xf01077db
f0101b21:	68 ae 03 00 00       	push   $0x3ae
f0101b26:	68 b5 77 10 f0       	push   $0xf01077b5
f0101b2b:	e8 10 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b30:	68 4b 79 10 f0       	push   $0xf010794b
f0101b35:	68 db 77 10 f0       	push   $0xf01077db
f0101b3a:	68 b0 03 00 00       	push   $0x3b0
f0101b3f:	68 b5 77 10 f0       	push   $0xf01077b5
f0101b44:	e8 f7 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b49:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0101b4e:	68 db 77 10 f0       	push   $0xf01077db
f0101b53:	68 b1 03 00 00       	push   $0x3b1
f0101b58:	68 b5 77 10 f0       	push   $0xf01077b5
f0101b5d:	e8 de e4 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101b62:	68 b4 79 10 f0       	push   $0xf01079b4
f0101b67:	68 db 77 10 f0       	push   $0xf01077db
f0101b6c:	68 b2 03 00 00       	push   $0x3b2
f0101b71:	68 b5 77 10 f0       	push   $0xf01077b5
f0101b76:	e8 c5 e4 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b7b:	50                   	push   %eax
f0101b7c:	68 64 67 10 f0       	push   $0xf0106764
f0101b81:	6a 58                	push   $0x58
f0101b83:	68 c1 77 10 f0       	push   $0xf01077c1
f0101b88:	e8 b3 e4 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b8d:	68 c3 79 10 f0       	push   $0xf01079c3
f0101b92:	68 db 77 10 f0       	push   $0xf01077db
f0101b97:	68 b7 03 00 00       	push   $0x3b7
f0101b9c:	68 b5 77 10 f0       	push   $0xf01077b5
f0101ba1:	e8 9a e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101ba6:	68 e1 79 10 f0       	push   $0xf01079e1
f0101bab:	68 db 77 10 f0       	push   $0xf01077db
f0101bb0:	68 b8 03 00 00       	push   $0x3b8
f0101bb5:	68 b5 77 10 f0       	push   $0xf01077b5
f0101bba:	e8 81 e4 ff ff       	call   f0100040 <_panic>
f0101bbf:	52                   	push   %edx
f0101bc0:	68 64 67 10 f0       	push   $0xf0106764
f0101bc5:	6a 58                	push   $0x58
f0101bc7:	68 c1 77 10 f0       	push   $0xf01077c1
f0101bcc:	e8 6f e4 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101bd1:	68 f1 79 10 f0       	push   $0xf01079f1
f0101bd6:	68 db 77 10 f0       	push   $0xf01077db
f0101bdb:	68 bb 03 00 00       	push   $0x3bb
f0101be0:	68 b5 77 10 f0       	push   $0xf01077b5
f0101be5:	e8 56 e4 ff ff       	call   f0100040 <_panic>
		--nfree;
f0101bea:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101bed:	8b 00                	mov    (%eax),%eax
f0101bef:	85 c0                	test   %eax,%eax
f0101bf1:	75 f7                	jne    f0101bea <mem_init+0x57f>
	assert(nfree == 0);
f0101bf3:	85 db                	test   %ebx,%ebx
f0101bf5:	0f 85 ad 09 00 00    	jne    f01025a8 <mem_init+0xf3d>
	cprintf("check_page_alloc() succeeded!\n");
f0101bfb:	83 ec 0c             	sub    $0xc,%esp
f0101bfe:	68 f8 6f 10 f0       	push   $0xf0106ff8
f0101c03:	e8 80 21 00 00       	call   f0103d88 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c0f:	e8 b5 f3 ff ff       	call   f0100fc9 <page_alloc>
f0101c14:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	0f 84 9f 09 00 00    	je     f01025c1 <mem_init+0xf56>
	assert((pp1 = page_alloc(0)));
f0101c22:	83 ec 0c             	sub    $0xc,%esp
f0101c25:	6a 00                	push   $0x0
f0101c27:	e8 9d f3 ff ff       	call   f0100fc9 <page_alloc>
f0101c2c:	89 c3                	mov    %eax,%ebx
f0101c2e:	83 c4 10             	add    $0x10,%esp
f0101c31:	85 c0                	test   %eax,%eax
f0101c33:	0f 84 a1 09 00 00    	je     f01025da <mem_init+0xf6f>
	assert((pp2 = page_alloc(0)));
f0101c39:	83 ec 0c             	sub    $0xc,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	e8 86 f3 ff ff       	call   f0100fc9 <page_alloc>
f0101c43:	89 c6                	mov    %eax,%esi
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	0f 84 a3 09 00 00    	je     f01025f3 <mem_init+0xf88>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c50:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101c53:	0f 84 b3 09 00 00    	je     f010260c <mem_init+0xfa1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c59:	39 c3                	cmp    %eax,%ebx
f0101c5b:	0f 84 c4 09 00 00    	je     f0102625 <mem_init+0xfba>
f0101c61:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c64:	0f 84 bb 09 00 00    	je     f0102625 <mem_init+0xfba>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c6a:	a1 40 52 21 f0       	mov    0xf0215240,%eax
f0101c6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101c72:	c7 05 40 52 21 f0 00 	movl   $0x0,0xf0215240
f0101c79:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c7c:	83 ec 0c             	sub    $0xc,%esp
f0101c7f:	6a 00                	push   $0x0
f0101c81:	e8 43 f3 ff ff       	call   f0100fc9 <page_alloc>
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	85 c0                	test   %eax,%eax
f0101c8b:	0f 85 ad 09 00 00    	jne    f010263e <mem_init+0xfd3>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c91:	83 ec 04             	sub    $0x4,%esp
f0101c94:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c97:	50                   	push   %eax
f0101c98:	6a 00                	push   $0x0
f0101c9a:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101ca0:	e8 eb f7 ff ff       	call   f0101490 <page_lookup>
f0101ca5:	83 c4 10             	add    $0x10,%esp
f0101ca8:	85 c0                	test   %eax,%eax
f0101caa:	0f 85 a7 09 00 00    	jne    f0102657 <mem_init+0xfec>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cb0:	6a 02                	push   $0x2
f0101cb2:	6a 00                	push   $0x0
f0101cb4:	53                   	push   %ebx
f0101cb5:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101cbb:	e8 a8 f8 ff ff       	call   f0101568 <page_insert>
f0101cc0:	83 c4 10             	add    $0x10,%esp
f0101cc3:	85 c0                	test   %eax,%eax
f0101cc5:	0f 89 a5 09 00 00    	jns    f0102670 <mem_init+0x1005>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ccb:	83 ec 0c             	sub    $0xc,%esp
f0101cce:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cd1:	e8 65 f3 ff ff       	call   f010103b <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cd6:	6a 02                	push   $0x2
f0101cd8:	6a 00                	push   $0x0
f0101cda:	53                   	push   %ebx
f0101cdb:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101ce1:	e8 82 f8 ff ff       	call   f0101568 <page_insert>
f0101ce6:	83 c4 20             	add    $0x20,%esp
f0101ce9:	85 c0                	test   %eax,%eax
f0101ceb:	0f 85 98 09 00 00    	jne    f0102689 <mem_init+0x101e>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cf1:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101cf7:	8b 0d 90 5e 21 f0    	mov    0xf0215e90,%ecx
f0101cfd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101d00:	8b 17                	mov    (%edi),%edx
f0101d02:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d0b:	29 c8                	sub    %ecx,%eax
f0101d0d:	c1 f8 03             	sar    $0x3,%eax
f0101d10:	c1 e0 0c             	shl    $0xc,%eax
f0101d13:	39 c2                	cmp    %eax,%edx
f0101d15:	0f 85 87 09 00 00    	jne    f01026a2 <mem_init+0x1037>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d1b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d20:	89 f8                	mov    %edi,%eax
f0101d22:	e8 f6 ed ff ff       	call   f0100b1d <check_va2pa>
f0101d27:	89 da                	mov    %ebx,%edx
f0101d29:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101d2c:	c1 fa 03             	sar    $0x3,%edx
f0101d2f:	c1 e2 0c             	shl    $0xc,%edx
f0101d32:	39 d0                	cmp    %edx,%eax
f0101d34:	0f 85 81 09 00 00    	jne    f01026bb <mem_init+0x1050>
	assert(pp1->pp_ref == 1);
f0101d3a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d3f:	0f 85 8f 09 00 00    	jne    f01026d4 <mem_init+0x1069>
	assert(pp0->pp_ref == 1);
f0101d45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d48:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d4d:	0f 85 9a 09 00 00    	jne    f01026ed <mem_init+0x1082>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d53:	6a 02                	push   $0x2
f0101d55:	68 00 10 00 00       	push   $0x1000
f0101d5a:	56                   	push   %esi
f0101d5b:	57                   	push   %edi
f0101d5c:	e8 07 f8 ff ff       	call   f0101568 <page_insert>
f0101d61:	83 c4 10             	add    $0x10,%esp
f0101d64:	85 c0                	test   %eax,%eax
f0101d66:	0f 85 9a 09 00 00    	jne    f0102706 <mem_init+0x109b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d6c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d71:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101d76:	e8 a2 ed ff ff       	call   f0100b1d <check_va2pa>
f0101d7b:	89 f2                	mov    %esi,%edx
f0101d7d:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101d83:	c1 fa 03             	sar    $0x3,%edx
f0101d86:	c1 e2 0c             	shl    $0xc,%edx
f0101d89:	39 d0                	cmp    %edx,%eax
f0101d8b:	0f 85 8e 09 00 00    	jne    f010271f <mem_init+0x10b4>
	assert(pp2->pp_ref == 1);
f0101d91:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d96:	0f 85 9c 09 00 00    	jne    f0102738 <mem_init+0x10cd>

	// should be no free memory
	assert(!page_alloc(0));
f0101d9c:	83 ec 0c             	sub    $0xc,%esp
f0101d9f:	6a 00                	push   $0x0
f0101da1:	e8 23 f2 ff ff       	call   f0100fc9 <page_alloc>
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	85 c0                	test   %eax,%eax
f0101dab:	0f 85 a0 09 00 00    	jne    f0102751 <mem_init+0x10e6>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101db1:	6a 02                	push   $0x2
f0101db3:	68 00 10 00 00       	push   $0x1000
f0101db8:	56                   	push   %esi
f0101db9:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101dbf:	e8 a4 f7 ff ff       	call   f0101568 <page_insert>
f0101dc4:	83 c4 10             	add    $0x10,%esp
f0101dc7:	85 c0                	test   %eax,%eax
f0101dc9:	0f 85 9b 09 00 00    	jne    f010276a <mem_init+0x10ff>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dcf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dd4:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101dd9:	e8 3f ed ff ff       	call   f0100b1d <check_va2pa>
f0101dde:	89 f2                	mov    %esi,%edx
f0101de0:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101de6:	c1 fa 03             	sar    $0x3,%edx
f0101de9:	c1 e2 0c             	shl    $0xc,%edx
f0101dec:	39 d0                	cmp    %edx,%eax
f0101dee:	0f 85 8f 09 00 00    	jne    f0102783 <mem_init+0x1118>
	assert(pp2->pp_ref == 1);
f0101df4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101df9:	0f 85 9d 09 00 00    	jne    f010279c <mem_init+0x1131>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101dff:	83 ec 0c             	sub    $0xc,%esp
f0101e02:	6a 00                	push   $0x0
f0101e04:	e8 c0 f1 ff ff       	call   f0100fc9 <page_alloc>
f0101e09:	83 c4 10             	add    $0x10,%esp
f0101e0c:	85 c0                	test   %eax,%eax
f0101e0e:	0f 85 a1 09 00 00    	jne    f01027b5 <mem_init+0x114a>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e14:	8b 15 8c 5e 21 f0    	mov    0xf0215e8c,%edx
f0101e1a:	8b 02                	mov    (%edx),%eax
f0101e1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e21:	89 c1                	mov    %eax,%ecx
f0101e23:	c1 e9 0c             	shr    $0xc,%ecx
f0101e26:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f0101e2c:	0f 83 9c 09 00 00    	jae    f01027ce <mem_init+0x1163>
	return (void *)(pa + KERNBASE);
f0101e32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e3a:	83 ec 04             	sub    $0x4,%esp
f0101e3d:	6a 00                	push   $0x0
f0101e3f:	68 00 10 00 00       	push   $0x1000
f0101e44:	52                   	push   %edx
f0101e45:	e8 6a f2 ff ff       	call   f01010b4 <pgdir_walk>
f0101e4a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101e4d:	8d 51 04             	lea    0x4(%ecx),%edx
f0101e50:	83 c4 10             	add    $0x10,%esp
f0101e53:	39 d0                	cmp    %edx,%eax
f0101e55:	0f 85 88 09 00 00    	jne    f01027e3 <mem_init+0x1178>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e5b:	6a 06                	push   $0x6
f0101e5d:	68 00 10 00 00       	push   $0x1000
f0101e62:	56                   	push   %esi
f0101e63:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101e69:	e8 fa f6 ff ff       	call   f0101568 <page_insert>
f0101e6e:	83 c4 10             	add    $0x10,%esp
f0101e71:	85 c0                	test   %eax,%eax
f0101e73:	0f 85 83 09 00 00    	jne    f01027fc <mem_init+0x1191>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e79:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101e7f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e84:	89 f8                	mov    %edi,%eax
f0101e86:	e8 92 ec ff ff       	call   f0100b1d <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101e8b:	89 f2                	mov    %esi,%edx
f0101e8d:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0101e93:	c1 fa 03             	sar    $0x3,%edx
f0101e96:	c1 e2 0c             	shl    $0xc,%edx
f0101e99:	39 d0                	cmp    %edx,%eax
f0101e9b:	0f 85 74 09 00 00    	jne    f0102815 <mem_init+0x11aa>
	assert(pp2->pp_ref == 1);
f0101ea1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ea6:	0f 85 82 09 00 00    	jne    f010282e <mem_init+0x11c3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101eac:	83 ec 04             	sub    $0x4,%esp
f0101eaf:	6a 00                	push   $0x0
f0101eb1:	68 00 10 00 00       	push   $0x1000
f0101eb6:	57                   	push   %edi
f0101eb7:	e8 f8 f1 ff ff       	call   f01010b4 <pgdir_walk>
f0101ebc:	83 c4 10             	add    $0x10,%esp
f0101ebf:	f6 00 04             	testb  $0x4,(%eax)
f0101ec2:	0f 84 7f 09 00 00    	je     f0102847 <mem_init+0x11dc>
	assert(kern_pgdir[0] & PTE_U);
f0101ec8:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0101ecd:	f6 00 04             	testb  $0x4,(%eax)
f0101ed0:	0f 84 8a 09 00 00    	je     f0102860 <mem_init+0x11f5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ed6:	6a 02                	push   $0x2
f0101ed8:	68 00 10 00 00       	push   $0x1000
f0101edd:	56                   	push   %esi
f0101ede:	50                   	push   %eax
f0101edf:	e8 84 f6 ff ff       	call   f0101568 <page_insert>
f0101ee4:	83 c4 10             	add    $0x10,%esp
f0101ee7:	85 c0                	test   %eax,%eax
f0101ee9:	0f 85 8a 09 00 00    	jne    f0102879 <mem_init+0x120e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101eef:	83 ec 04             	sub    $0x4,%esp
f0101ef2:	6a 00                	push   $0x0
f0101ef4:	68 00 10 00 00       	push   $0x1000
f0101ef9:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101eff:	e8 b0 f1 ff ff       	call   f01010b4 <pgdir_walk>
f0101f04:	83 c4 10             	add    $0x10,%esp
f0101f07:	f6 00 02             	testb  $0x2,(%eax)
f0101f0a:	0f 84 82 09 00 00    	je     f0102892 <mem_init+0x1227>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f10:	83 ec 04             	sub    $0x4,%esp
f0101f13:	6a 00                	push   $0x0
f0101f15:	68 00 10 00 00       	push   $0x1000
f0101f1a:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101f20:	e8 8f f1 ff ff       	call   f01010b4 <pgdir_walk>
f0101f25:	83 c4 10             	add    $0x10,%esp
f0101f28:	f6 00 04             	testb  $0x4,(%eax)
f0101f2b:	0f 85 7a 09 00 00    	jne    f01028ab <mem_init+0x1240>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f31:	6a 02                	push   $0x2
f0101f33:	68 00 00 40 00       	push   $0x400000
f0101f38:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f3b:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101f41:	e8 22 f6 ff ff       	call   f0101568 <page_insert>
f0101f46:	83 c4 10             	add    $0x10,%esp
f0101f49:	85 c0                	test   %eax,%eax
f0101f4b:	0f 89 73 09 00 00    	jns    f01028c4 <mem_init+0x1259>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f51:	6a 02                	push   $0x2
f0101f53:	68 00 10 00 00       	push   $0x1000
f0101f58:	53                   	push   %ebx
f0101f59:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101f5f:	e8 04 f6 ff ff       	call   f0101568 <page_insert>
f0101f64:	83 c4 10             	add    $0x10,%esp
f0101f67:	85 c0                	test   %eax,%eax
f0101f69:	0f 85 6e 09 00 00    	jne    f01028dd <mem_init+0x1272>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f6f:	83 ec 04             	sub    $0x4,%esp
f0101f72:	6a 00                	push   $0x0
f0101f74:	68 00 10 00 00       	push   $0x1000
f0101f79:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0101f7f:	e8 30 f1 ff ff       	call   f01010b4 <pgdir_walk>
f0101f84:	83 c4 10             	add    $0x10,%esp
f0101f87:	f6 00 04             	testb  $0x4,(%eax)
f0101f8a:	0f 85 66 09 00 00    	jne    f01028f6 <mem_init+0x128b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f90:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0101f96:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9b:	89 f8                	mov    %edi,%eax
f0101f9d:	e8 7b eb ff ff       	call   f0100b1d <check_va2pa>
f0101fa2:	89 c1                	mov    %eax,%ecx
f0101fa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fa7:	89 d8                	mov    %ebx,%eax
f0101fa9:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0101faf:	c1 f8 03             	sar    $0x3,%eax
f0101fb2:	c1 e0 0c             	shl    $0xc,%eax
f0101fb5:	39 c1                	cmp    %eax,%ecx
f0101fb7:	0f 85 52 09 00 00    	jne    f010290f <mem_init+0x12a4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fbd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc2:	89 f8                	mov    %edi,%eax
f0101fc4:	e8 54 eb ff ff       	call   f0100b1d <check_va2pa>
f0101fc9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fcc:	0f 85 56 09 00 00    	jne    f0102928 <mem_init+0x12bd>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fd2:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fd7:	0f 85 64 09 00 00    	jne    f0102941 <mem_init+0x12d6>
	assert(pp2->pp_ref == 0);
f0101fdd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fe2:	0f 85 72 09 00 00    	jne    f010295a <mem_init+0x12ef>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101fe8:	83 ec 0c             	sub    $0xc,%esp
f0101feb:	6a 00                	push   $0x0
f0101fed:	e8 d7 ef ff ff       	call   f0100fc9 <page_alloc>
f0101ff2:	83 c4 10             	add    $0x10,%esp
f0101ff5:	85 c0                	test   %eax,%eax
f0101ff7:	0f 84 76 09 00 00    	je     f0102973 <mem_init+0x1308>
f0101ffd:	39 c6                	cmp    %eax,%esi
f0101fff:	0f 85 6e 09 00 00    	jne    f0102973 <mem_init+0x1308>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102005:	83 ec 08             	sub    $0x8,%esp
f0102008:	6a 00                	push   $0x0
f010200a:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102010:	e8 0b f5 ff ff       	call   f0101520 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102015:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f010201b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102020:	89 f8                	mov    %edi,%eax
f0102022:	e8 f6 ea ff ff       	call   f0100b1d <check_va2pa>
f0102027:	83 c4 10             	add    $0x10,%esp
f010202a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010202d:	0f 85 59 09 00 00    	jne    f010298c <mem_init+0x1321>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102033:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102038:	89 f8                	mov    %edi,%eax
f010203a:	e8 de ea ff ff       	call   f0100b1d <check_va2pa>
f010203f:	89 da                	mov    %ebx,%edx
f0102041:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0102047:	c1 fa 03             	sar    $0x3,%edx
f010204a:	c1 e2 0c             	shl    $0xc,%edx
f010204d:	39 d0                	cmp    %edx,%eax
f010204f:	0f 85 50 09 00 00    	jne    f01029a5 <mem_init+0x133a>
	assert(pp1->pp_ref == 1);
f0102055:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010205a:	0f 85 5e 09 00 00    	jne    f01029be <mem_init+0x1353>
	assert(pp2->pp_ref == 0);
f0102060:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102065:	0f 85 6c 09 00 00    	jne    f01029d7 <mem_init+0x136c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010206b:	6a 00                	push   $0x0
f010206d:	68 00 10 00 00       	push   $0x1000
f0102072:	53                   	push   %ebx
f0102073:	57                   	push   %edi
f0102074:	e8 ef f4 ff ff       	call   f0101568 <page_insert>
f0102079:	83 c4 10             	add    $0x10,%esp
f010207c:	85 c0                	test   %eax,%eax
f010207e:	0f 85 6c 09 00 00    	jne    f01029f0 <mem_init+0x1385>
	assert(pp1->pp_ref);
f0102084:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102089:	0f 84 7a 09 00 00    	je     f0102a09 <mem_init+0x139e>
	assert(pp1->pp_link == NULL);
f010208f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102092:	0f 85 8a 09 00 00    	jne    f0102a22 <mem_init+0x13b7>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102098:	83 ec 08             	sub    $0x8,%esp
f010209b:	68 00 10 00 00       	push   $0x1000
f01020a0:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01020a6:	e8 75 f4 ff ff       	call   f0101520 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020ab:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f01020b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01020b6:	89 f8                	mov    %edi,%eax
f01020b8:	e8 60 ea ff ff       	call   f0100b1d <check_va2pa>
f01020bd:	83 c4 10             	add    $0x10,%esp
f01020c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020c3:	0f 85 72 09 00 00    	jne    f0102a3b <mem_init+0x13d0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020c9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ce:	89 f8                	mov    %edi,%eax
f01020d0:	e8 48 ea ff ff       	call   f0100b1d <check_va2pa>
f01020d5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020d8:	0f 85 76 09 00 00    	jne    f0102a54 <mem_init+0x13e9>
	assert(pp1->pp_ref == 0);
f01020de:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020e3:	0f 85 84 09 00 00    	jne    f0102a6d <mem_init+0x1402>
	assert(pp2->pp_ref == 0);
f01020e9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020ee:	0f 85 92 09 00 00    	jne    f0102a86 <mem_init+0x141b>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020f4:	83 ec 0c             	sub    $0xc,%esp
f01020f7:	6a 00                	push   $0x0
f01020f9:	e8 cb ee ff ff       	call   f0100fc9 <page_alloc>
f01020fe:	83 c4 10             	add    $0x10,%esp
f0102101:	39 c3                	cmp    %eax,%ebx
f0102103:	0f 85 96 09 00 00    	jne    f0102a9f <mem_init+0x1434>
f0102109:	85 c0                	test   %eax,%eax
f010210b:	0f 84 8e 09 00 00    	je     f0102a9f <mem_init+0x1434>

	// should be no free memory
	assert(!page_alloc(0));
f0102111:	83 ec 0c             	sub    $0xc,%esp
f0102114:	6a 00                	push   $0x0
f0102116:	e8 ae ee ff ff       	call   f0100fc9 <page_alloc>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	85 c0                	test   %eax,%eax
f0102120:	0f 85 92 09 00 00    	jne    f0102ab8 <mem_init+0x144d>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102126:	8b 0d 8c 5e 21 f0    	mov    0xf0215e8c,%ecx
f010212c:	8b 11                	mov    (%ecx),%edx
f010212e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102134:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102137:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f010213d:	c1 f8 03             	sar    $0x3,%eax
f0102140:	c1 e0 0c             	shl    $0xc,%eax
f0102143:	39 c2                	cmp    %eax,%edx
f0102145:	0f 85 86 09 00 00    	jne    f0102ad1 <mem_init+0x1466>
	kern_pgdir[0] = 0;
f010214b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102151:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102154:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102159:	0f 85 8b 09 00 00    	jne    f0102aea <mem_init+0x147f>
	pp0->pp_ref = 0;
f010215f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102162:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102168:	83 ec 0c             	sub    $0xc,%esp
f010216b:	50                   	push   %eax
f010216c:	e8 ca ee ff ff       	call   f010103b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102171:	83 c4 0c             	add    $0xc,%esp
f0102174:	6a 01                	push   $0x1
f0102176:	68 00 10 40 00       	push   $0x401000
f010217b:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102181:	e8 2e ef ff ff       	call   f01010b4 <pgdir_walk>
f0102186:	89 c7                	mov    %eax,%edi
f0102188:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010218b:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102190:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102193:	8b 40 04             	mov    0x4(%eax),%eax
f0102196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010219b:	8b 0d 88 5e 21 f0    	mov    0xf0215e88,%ecx
f01021a1:	89 c2                	mov    %eax,%edx
f01021a3:	c1 ea 0c             	shr    $0xc,%edx
f01021a6:	83 c4 10             	add    $0x10,%esp
f01021a9:	39 ca                	cmp    %ecx,%edx
f01021ab:	0f 83 52 09 00 00    	jae    f0102b03 <mem_init+0x1498>
	assert(ptep == ptep1 + PTX(va));
f01021b1:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01021b6:	39 c7                	cmp    %eax,%edi
f01021b8:	0f 85 5a 09 00 00    	jne    f0102b18 <mem_init+0x14ad>
	kern_pgdir[PDX(va)] = 0;
f01021be:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01021c1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01021c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021cb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01021d1:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f01021d7:	c1 f8 03             	sar    $0x3,%eax
f01021da:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01021dd:	89 c2                	mov    %eax,%edx
f01021df:	c1 ea 0c             	shr    $0xc,%edx
f01021e2:	39 d1                	cmp    %edx,%ecx
f01021e4:	0f 86 47 09 00 00    	jbe    f0102b31 <mem_init+0x14c6>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021ea:	83 ec 04             	sub    $0x4,%esp
f01021ed:	68 00 10 00 00       	push   $0x1000
f01021f2:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01021f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021fc:	50                   	push   %eax
f01021fd:	e8 e6 38 00 00       	call   f0105ae8 <memset>
	page_free(pp0);
f0102202:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102205:	89 3c 24             	mov    %edi,(%esp)
f0102208:	e8 2e ee ff ff       	call   f010103b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010220d:	83 c4 0c             	add    $0xc,%esp
f0102210:	6a 01                	push   $0x1
f0102212:	6a 00                	push   $0x0
f0102214:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f010221a:	e8 95 ee ff ff       	call   f01010b4 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f010221f:	89 fa                	mov    %edi,%edx
f0102221:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0102227:	c1 fa 03             	sar    $0x3,%edx
f010222a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010222d:	89 d0                	mov    %edx,%eax
f010222f:	c1 e8 0c             	shr    $0xc,%eax
f0102232:	83 c4 10             	add    $0x10,%esp
f0102235:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f010223b:	0f 83 02 09 00 00    	jae    f0102b43 <mem_init+0x14d8>
	return (void *)(pa + KERNBASE);
f0102241:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010224a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102250:	f6 00 01             	testb  $0x1,(%eax)
f0102253:	0f 85 fc 08 00 00    	jne    f0102b55 <mem_init+0x14ea>
f0102259:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f010225c:	39 d0                	cmp    %edx,%eax
f010225e:	75 f0                	jne    f0102250 <mem_init+0xbe5>
	kern_pgdir[0] = 0;
f0102260:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102265:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010226b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010226e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102274:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102277:	89 0d 40 52 21 f0    	mov    %ecx,0xf0215240

	// free the pages we took
	page_free(pp0);
f010227d:	83 ec 0c             	sub    $0xc,%esp
f0102280:	50                   	push   %eax
f0102281:	e8 b5 ed ff ff       	call   f010103b <page_free>
	page_free(pp1);
f0102286:	89 1c 24             	mov    %ebx,(%esp)
f0102289:	e8 ad ed ff ff       	call   f010103b <page_free>
	page_free(pp2);
f010228e:	89 34 24             	mov    %esi,(%esp)
f0102291:	e8 a5 ed ff ff       	call   f010103b <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102296:	83 c4 08             	add    $0x8,%esp
f0102299:	68 01 10 00 00       	push   $0x1001
f010229e:	6a 00                	push   $0x0
f01022a0:	e8 66 f3 ff ff       	call   f010160b <mmio_map_region>
f01022a5:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01022a7:	83 c4 08             	add    $0x8,%esp
f01022aa:	68 00 10 00 00       	push   $0x1000
f01022af:	6a 00                	push   $0x0
f01022b1:	e8 55 f3 ff ff       	call   f010160b <mmio_map_region>
f01022b6:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01022b8:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01022be:	83 c4 10             	add    $0x10,%esp
f01022c1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01022c7:	0f 86 a1 08 00 00    	jbe    f0102b6e <mem_init+0x1503>
f01022cd:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01022d2:	0f 87 96 08 00 00    	ja     f0102b6e <mem_init+0x1503>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f01022d8:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f01022de:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01022e4:	0f 87 9d 08 00 00    	ja     f0102b87 <mem_init+0x151c>
f01022ea:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01022f0:	0f 86 91 08 00 00    	jbe    f0102b87 <mem_init+0x151c>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01022f6:	89 da                	mov    %ebx,%edx
f01022f8:	09 f2                	or     %esi,%edx
f01022fa:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102300:	0f 85 9a 08 00 00    	jne    f0102ba0 <mem_init+0x1535>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102306:	39 c6                	cmp    %eax,%esi
f0102308:	0f 82 ab 08 00 00    	jb     f0102bb9 <mem_init+0x154e>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010230e:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
f0102314:	89 da                	mov    %ebx,%edx
f0102316:	89 f8                	mov    %edi,%eax
f0102318:	e8 00 e8 ff ff       	call   f0100b1d <check_va2pa>
f010231d:	85 c0                	test   %eax,%eax
f010231f:	0f 85 ad 08 00 00    	jne    f0102bd2 <mem_init+0x1567>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102325:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010232b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010232e:	89 c2                	mov    %eax,%edx
f0102330:	89 f8                	mov    %edi,%eax
f0102332:	e8 e6 e7 ff ff       	call   f0100b1d <check_va2pa>
f0102337:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010233c:	0f 85 a9 08 00 00    	jne    f0102beb <mem_init+0x1580>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102342:	89 f2                	mov    %esi,%edx
f0102344:	89 f8                	mov    %edi,%eax
f0102346:	e8 d2 e7 ff ff       	call   f0100b1d <check_va2pa>
f010234b:	85 c0                	test   %eax,%eax
f010234d:	0f 85 b1 08 00 00    	jne    f0102c04 <mem_init+0x1599>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102353:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102359:	89 f8                	mov    %edi,%eax
f010235b:	e8 bd e7 ff ff       	call   f0100b1d <check_va2pa>
f0102360:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102363:	0f 85 b4 08 00 00    	jne    f0102c1d <mem_init+0x15b2>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102369:	83 ec 04             	sub    $0x4,%esp
f010236c:	6a 00                	push   $0x0
f010236e:	53                   	push   %ebx
f010236f:	57                   	push   %edi
f0102370:	e8 3f ed ff ff       	call   f01010b4 <pgdir_walk>
f0102375:	83 c4 10             	add    $0x10,%esp
f0102378:	f6 00 1a             	testb  $0x1a,(%eax)
f010237b:	0f 84 b5 08 00 00    	je     f0102c36 <mem_init+0x15cb>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102381:	83 ec 04             	sub    $0x4,%esp
f0102384:	6a 00                	push   $0x0
f0102386:	53                   	push   %ebx
f0102387:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f010238d:	e8 22 ed ff ff       	call   f01010b4 <pgdir_walk>
f0102392:	83 c4 10             	add    $0x10,%esp
f0102395:	f6 00 04             	testb  $0x4,(%eax)
f0102398:	0f 85 b1 08 00 00    	jne    f0102c4f <mem_init+0x15e4>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010239e:	83 ec 04             	sub    $0x4,%esp
f01023a1:	6a 00                	push   $0x0
f01023a3:	53                   	push   %ebx
f01023a4:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01023aa:	e8 05 ed ff ff       	call   f01010b4 <pgdir_walk>
f01023af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01023b5:	83 c4 0c             	add    $0xc,%esp
f01023b8:	6a 00                	push   $0x0
f01023ba:	ff 75 d4             	pushl  -0x2c(%ebp)
f01023bd:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01023c3:	e8 ec ec ff ff       	call   f01010b4 <pgdir_walk>
f01023c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01023ce:	83 c4 0c             	add    $0xc,%esp
f01023d1:	6a 00                	push   $0x0
f01023d3:	56                   	push   %esi
f01023d4:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01023da:	e8 d5 ec ff ff       	call   f01010b4 <pgdir_walk>
f01023df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01023e5:	c7 04 24 e4 7a 10 f0 	movl   $0xf0107ae4,(%esp)
f01023ec:	e8 97 19 00 00       	call   f0103d88 <cprintf>
    boot_map_region(kern_pgdir, UPAGES, UVPT - UPAGES, PADDR(pages), PTE_U | PTE_P);
f01023f1:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
	if ((uint32_t)kva < KERNBASE)
f01023f6:	83 c4 10             	add    $0x10,%esp
f01023f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023fe:	0f 86 64 08 00 00    	jbe    f0102c68 <mem_init+0x15fd>
f0102404:	83 ec 08             	sub    $0x8,%esp
f0102407:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102409:	05 00 00 00 10       	add    $0x10000000,%eax
f010240e:	50                   	push   %eax
f010240f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102414:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102419:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f010241e:	e8 76 ed ff ff       	call   f0101199 <boot_map_region>
    boot_map_region(kern_pgdir, UENVS, UPAGES - UENVS, PADDR(envs), PTE_U | PTE_P);
f0102423:	a1 48 52 21 f0       	mov    0xf0215248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102428:	83 c4 10             	add    $0x10,%esp
f010242b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102430:	0f 86 47 08 00 00    	jbe    f0102c7d <mem_init+0x1612>
f0102436:	83 ec 08             	sub    $0x8,%esp
f0102439:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010243b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102440:	50                   	push   %eax
f0102441:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102446:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010244b:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102450:	e8 44 ed ff ff       	call   f0101199 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102455:	83 c4 10             	add    $0x10,%esp
f0102458:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010245d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102462:	0f 86 2a 08 00 00    	jbe    f0102c92 <mem_init+0x1627>
    boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102468:	83 ec 08             	sub    $0x8,%esp
f010246b:	6a 02                	push   $0x2
f010246d:	68 00 80 11 00       	push   $0x118000
f0102472:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102477:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010247c:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f0102481:	e8 13 ed ff ff       	call   f0101199 <boot_map_region>
    boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W);
f0102486:	83 c4 08             	add    $0x8,%esp
f0102489:	6a 02                	push   $0x2
f010248b:	6a 00                	push   $0x0
f010248d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102492:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102497:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
f010249c:	e8 f8 ec ff ff       	call   f0101199 <boot_map_region>
f01024a1:	c7 45 cc 00 70 21 f0 	movl   $0xf0217000,-0x34(%ebp)
f01024a8:	b8 00 80 ff ef       	mov    $0xefff8000,%eax
f01024ad:	2d 00 70 21 f0       	sub    $0xf0217000,%eax
f01024b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024b5:	b8 00 80 f3 ef       	mov    $0xeff38000,%eax
f01024ba:	2d 00 70 21 f0       	sub    $0xf0217000,%eax
f01024bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01024c2:	83 c4 10             	add    $0x10,%esp
f01024c5:	c7 45 d0 00 70 21 f0 	movl   $0xf0217000,-0x30(%ebp)
        pa_start = PADDR(percpu_kstacks[n]);
f01024cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024cf:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01024d5:	0f 86 cc 07 00 00    	jbe    f0102ca7 <mem_init+0x163c>
f01024db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024de:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f01024e4:	8d b8 00 80 00 10    	lea    0x10008000(%eax),%edi
            pte = pgdir_walk(kern_pgdir, (void *)(va_start + size), 1);
f01024ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ed:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
f01024f3:	83 ec 04             	sub    $0x4,%esp
f01024f6:	6a 01                	push   $0x1
f01024f8:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01024fb:	50                   	push   %eax
f01024fc:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0102502:	e8 ad eb ff ff       	call   f01010b4 <pgdir_walk>
            if (pte == NULL) {
f0102507:	83 c4 10             	add    $0x10,%esp
f010250a:	85 c0                	test   %eax,%eax
f010250c:	0f 84 aa 07 00 00    	je     f0102cbc <mem_init+0x1651>
            *pte = PTE_ADDR(pa_start + size) | PTE_W | PTE_P;
f0102512:	89 da                	mov    %ebx,%edx
f0102514:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010251a:	83 ca 03             	or     $0x3,%edx
f010251d:	89 10                	mov    %edx,(%eax)
f010251f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
        for (size = 0; size < KSTKSIZE; ) {
f0102525:	39 fb                	cmp    %edi,%ebx
f0102527:	75 ca                	jne    f01024f3 <mem_init+0xe88>
f0102529:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102530:	81 6d d4 00 80 01 00 	subl   $0x18000,-0x2c(%ebp)
f0102537:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    for (n = 0; n < NCPU; n++) {
f010253a:	3b 45 c8             	cmp    -0x38(%ebp),%eax
f010253d:	75 8d                	jne    f01024cc <mem_init+0xe61>
	pgdir = kern_pgdir;
f010253f:	8b 3d 8c 5e 21 f0    	mov    0xf0215e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102545:	a1 88 5e 21 f0       	mov    0xf0215e88,%eax
f010254a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010254d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102554:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102559:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010255c:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f0102561:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102564:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102567:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE)
f010256d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102572:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102575:	0f 86 88 07 00 00    	jbe    f0102d03 <mem_init+0x1698>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010257b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102581:	89 f8                	mov    %edi,%eax
f0102583:	e8 95 e5 ff ff       	call   f0100b1d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102588:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010258f:	0f 86 3e 07 00 00    	jbe    f0102cd3 <mem_init+0x1668>
f0102595:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102598:	39 d0                	cmp    %edx,%eax
f010259a:	0f 85 4a 07 00 00    	jne    f0102cea <mem_init+0x167f>
	for (i = 0; i < n; i += PGSIZE)
f01025a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01025a6:	eb ca                	jmp    f0102572 <mem_init+0xf07>
	assert(nfree == 0);
f01025a8:	68 fb 79 10 f0       	push   $0xf01079fb
f01025ad:	68 db 77 10 f0       	push   $0xf01077db
f01025b2:	68 c8 03 00 00       	push   $0x3c8
f01025b7:	68 b5 77 10 f0       	push   $0xf01077b5
f01025bc:	e8 7f da ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01025c1:	68 09 79 10 f0       	push   $0xf0107909
f01025c6:	68 db 77 10 f0       	push   $0xf01077db
f01025cb:	68 2e 04 00 00       	push   $0x42e
f01025d0:	68 b5 77 10 f0       	push   $0xf01077b5
f01025d5:	e8 66 da ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01025da:	68 1f 79 10 f0       	push   $0xf010791f
f01025df:	68 db 77 10 f0       	push   $0xf01077db
f01025e4:	68 2f 04 00 00       	push   $0x42f
f01025e9:	68 b5 77 10 f0       	push   $0xf01077b5
f01025ee:	e8 4d da ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01025f3:	68 35 79 10 f0       	push   $0xf0107935
f01025f8:	68 db 77 10 f0       	push   $0xf01077db
f01025fd:	68 30 04 00 00       	push   $0x430
f0102602:	68 b5 77 10 f0       	push   $0xf01077b5
f0102607:	e8 34 da ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010260c:	68 4b 79 10 f0       	push   $0xf010794b
f0102611:	68 db 77 10 f0       	push   $0xf01077db
f0102616:	68 33 04 00 00       	push   $0x433
f010261b:	68 b5 77 10 f0       	push   $0xf01077b5
f0102620:	e8 1b da ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102625:	68 d8 6f 10 f0       	push   $0xf0106fd8
f010262a:	68 db 77 10 f0       	push   $0xf01077db
f010262f:	68 34 04 00 00       	push   $0x434
f0102634:	68 b5 77 10 f0       	push   $0xf01077b5
f0102639:	e8 02 da ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010263e:	68 b4 79 10 f0       	push   $0xf01079b4
f0102643:	68 db 77 10 f0       	push   $0xf01077db
f0102648:	68 3b 04 00 00       	push   $0x43b
f010264d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102652:	e8 e9 d9 ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102657:	68 18 70 10 f0       	push   $0xf0107018
f010265c:	68 db 77 10 f0       	push   $0xf01077db
f0102661:	68 3e 04 00 00       	push   $0x43e
f0102666:	68 b5 77 10 f0       	push   $0xf01077b5
f010266b:	e8 d0 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102670:	68 50 70 10 f0       	push   $0xf0107050
f0102675:	68 db 77 10 f0       	push   $0xf01077db
f010267a:	68 41 04 00 00       	push   $0x441
f010267f:	68 b5 77 10 f0       	push   $0xf01077b5
f0102684:	e8 b7 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102689:	68 80 70 10 f0       	push   $0xf0107080
f010268e:	68 db 77 10 f0       	push   $0xf01077db
f0102693:	68 45 04 00 00       	push   $0x445
f0102698:	68 b5 77 10 f0       	push   $0xf01077b5
f010269d:	e8 9e d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026a2:	68 b0 70 10 f0       	push   $0xf01070b0
f01026a7:	68 db 77 10 f0       	push   $0xf01077db
f01026ac:	68 46 04 00 00       	push   $0x446
f01026b1:	68 b5 77 10 f0       	push   $0xf01077b5
f01026b6:	e8 85 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01026bb:	68 d8 70 10 f0       	push   $0xf01070d8
f01026c0:	68 db 77 10 f0       	push   $0xf01077db
f01026c5:	68 47 04 00 00       	push   $0x447
f01026ca:	68 b5 77 10 f0       	push   $0xf01077b5
f01026cf:	e8 6c d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026d4:	68 06 7a 10 f0       	push   $0xf0107a06
f01026d9:	68 db 77 10 f0       	push   $0xf01077db
f01026de:	68 48 04 00 00       	push   $0x448
f01026e3:	68 b5 77 10 f0       	push   $0xf01077b5
f01026e8:	e8 53 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026ed:	68 17 7a 10 f0       	push   $0xf0107a17
f01026f2:	68 db 77 10 f0       	push   $0xf01077db
f01026f7:	68 49 04 00 00       	push   $0x449
f01026fc:	68 b5 77 10 f0       	push   $0xf01077b5
f0102701:	e8 3a d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102706:	68 08 71 10 f0       	push   $0xf0107108
f010270b:	68 db 77 10 f0       	push   $0xf01077db
f0102710:	68 4c 04 00 00       	push   $0x44c
f0102715:	68 b5 77 10 f0       	push   $0xf01077b5
f010271a:	e8 21 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010271f:	68 44 71 10 f0       	push   $0xf0107144
f0102724:	68 db 77 10 f0       	push   $0xf01077db
f0102729:	68 4d 04 00 00       	push   $0x44d
f010272e:	68 b5 77 10 f0       	push   $0xf01077b5
f0102733:	e8 08 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102738:	68 28 7a 10 f0       	push   $0xf0107a28
f010273d:	68 db 77 10 f0       	push   $0xf01077db
f0102742:	68 4e 04 00 00       	push   $0x44e
f0102747:	68 b5 77 10 f0       	push   $0xf01077b5
f010274c:	e8 ef d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102751:	68 b4 79 10 f0       	push   $0xf01079b4
f0102756:	68 db 77 10 f0       	push   $0xf01077db
f010275b:	68 51 04 00 00       	push   $0x451
f0102760:	68 b5 77 10 f0       	push   $0xf01077b5
f0102765:	e8 d6 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010276a:	68 08 71 10 f0       	push   $0xf0107108
f010276f:	68 db 77 10 f0       	push   $0xf01077db
f0102774:	68 54 04 00 00       	push   $0x454
f0102779:	68 b5 77 10 f0       	push   $0xf01077b5
f010277e:	e8 bd d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102783:	68 44 71 10 f0       	push   $0xf0107144
f0102788:	68 db 77 10 f0       	push   $0xf01077db
f010278d:	68 55 04 00 00       	push   $0x455
f0102792:	68 b5 77 10 f0       	push   $0xf01077b5
f0102797:	e8 a4 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010279c:	68 28 7a 10 f0       	push   $0xf0107a28
f01027a1:	68 db 77 10 f0       	push   $0xf01077db
f01027a6:	68 56 04 00 00       	push   $0x456
f01027ab:	68 b5 77 10 f0       	push   $0xf01077b5
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01027b5:	68 b4 79 10 f0       	push   $0xf01079b4
f01027ba:	68 db 77 10 f0       	push   $0xf01077db
f01027bf:	68 5a 04 00 00       	push   $0x45a
f01027c4:	68 b5 77 10 f0       	push   $0xf01077b5
f01027c9:	e8 72 d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ce:	50                   	push   %eax
f01027cf:	68 64 67 10 f0       	push   $0xf0106764
f01027d4:	68 5d 04 00 00       	push   $0x45d
f01027d9:	68 b5 77 10 f0       	push   $0xf01077b5
f01027de:	e8 5d d8 ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01027e3:	68 74 71 10 f0       	push   $0xf0107174
f01027e8:	68 db 77 10 f0       	push   $0xf01077db
f01027ed:	68 5e 04 00 00       	push   $0x45e
f01027f2:	68 b5 77 10 f0       	push   $0xf01077b5
f01027f7:	e8 44 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01027fc:	68 b4 71 10 f0       	push   $0xf01071b4
f0102801:	68 db 77 10 f0       	push   $0xf01077db
f0102806:	68 61 04 00 00       	push   $0x461
f010280b:	68 b5 77 10 f0       	push   $0xf01077b5
f0102810:	e8 2b d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102815:	68 44 71 10 f0       	push   $0xf0107144
f010281a:	68 db 77 10 f0       	push   $0xf01077db
f010281f:	68 62 04 00 00       	push   $0x462
f0102824:	68 b5 77 10 f0       	push   $0xf01077b5
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010282e:	68 28 7a 10 f0       	push   $0xf0107a28
f0102833:	68 db 77 10 f0       	push   $0xf01077db
f0102838:	68 63 04 00 00       	push   $0x463
f010283d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102842:	e8 f9 d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102847:	68 f4 71 10 f0       	push   $0xf01071f4
f010284c:	68 db 77 10 f0       	push   $0xf01077db
f0102851:	68 64 04 00 00       	push   $0x464
f0102856:	68 b5 77 10 f0       	push   $0xf01077b5
f010285b:	e8 e0 d7 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102860:	68 39 7a 10 f0       	push   $0xf0107a39
f0102865:	68 db 77 10 f0       	push   $0xf01077db
f010286a:	68 65 04 00 00       	push   $0x465
f010286f:	68 b5 77 10 f0       	push   $0xf01077b5
f0102874:	e8 c7 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102879:	68 08 71 10 f0       	push   $0xf0107108
f010287e:	68 db 77 10 f0       	push   $0xf01077db
f0102883:	68 68 04 00 00       	push   $0x468
f0102888:	68 b5 77 10 f0       	push   $0xf01077b5
f010288d:	e8 ae d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102892:	68 28 72 10 f0       	push   $0xf0107228
f0102897:	68 db 77 10 f0       	push   $0xf01077db
f010289c:	68 69 04 00 00       	push   $0x469
f01028a1:	68 b5 77 10 f0       	push   $0xf01077b5
f01028a6:	e8 95 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028ab:	68 5c 72 10 f0       	push   $0xf010725c
f01028b0:	68 db 77 10 f0       	push   $0xf01077db
f01028b5:	68 6a 04 00 00       	push   $0x46a
f01028ba:	68 b5 77 10 f0       	push   $0xf01077b5
f01028bf:	e8 7c d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01028c4:	68 94 72 10 f0       	push   $0xf0107294
f01028c9:	68 db 77 10 f0       	push   $0xf01077db
f01028ce:	68 6d 04 00 00       	push   $0x46d
f01028d3:	68 b5 77 10 f0       	push   $0xf01077b5
f01028d8:	e8 63 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01028dd:	68 cc 72 10 f0       	push   $0xf01072cc
f01028e2:	68 db 77 10 f0       	push   $0xf01077db
f01028e7:	68 70 04 00 00       	push   $0x470
f01028ec:	68 b5 77 10 f0       	push   $0xf01077b5
f01028f1:	e8 4a d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028f6:	68 5c 72 10 f0       	push   $0xf010725c
f01028fb:	68 db 77 10 f0       	push   $0xf01077db
f0102900:	68 71 04 00 00       	push   $0x471
f0102905:	68 b5 77 10 f0       	push   $0xf01077b5
f010290a:	e8 31 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010290f:	68 08 73 10 f0       	push   $0xf0107308
f0102914:	68 db 77 10 f0       	push   $0xf01077db
f0102919:	68 74 04 00 00       	push   $0x474
f010291e:	68 b5 77 10 f0       	push   $0xf01077b5
f0102923:	e8 18 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102928:	68 34 73 10 f0       	push   $0xf0107334
f010292d:	68 db 77 10 f0       	push   $0xf01077db
f0102932:	68 75 04 00 00       	push   $0x475
f0102937:	68 b5 77 10 f0       	push   $0xf01077b5
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102941:	68 4f 7a 10 f0       	push   $0xf0107a4f
f0102946:	68 db 77 10 f0       	push   $0xf01077db
f010294b:	68 77 04 00 00       	push   $0x477
f0102950:	68 b5 77 10 f0       	push   $0xf01077b5
f0102955:	e8 e6 d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010295a:	68 60 7a 10 f0       	push   $0xf0107a60
f010295f:	68 db 77 10 f0       	push   $0xf01077db
f0102964:	68 78 04 00 00       	push   $0x478
f0102969:	68 b5 77 10 f0       	push   $0xf01077b5
f010296e:	e8 cd d6 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102973:	68 64 73 10 f0       	push   $0xf0107364
f0102978:	68 db 77 10 f0       	push   $0xf01077db
f010297d:	68 7b 04 00 00       	push   $0x47b
f0102982:	68 b5 77 10 f0       	push   $0xf01077b5
f0102987:	e8 b4 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010298c:	68 88 73 10 f0       	push   $0xf0107388
f0102991:	68 db 77 10 f0       	push   $0xf01077db
f0102996:	68 7f 04 00 00       	push   $0x47f
f010299b:	68 b5 77 10 f0       	push   $0xf01077b5
f01029a0:	e8 9b d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01029a5:	68 34 73 10 f0       	push   $0xf0107334
f01029aa:	68 db 77 10 f0       	push   $0xf01077db
f01029af:	68 80 04 00 00       	push   $0x480
f01029b4:	68 b5 77 10 f0       	push   $0xf01077b5
f01029b9:	e8 82 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01029be:	68 06 7a 10 f0       	push   $0xf0107a06
f01029c3:	68 db 77 10 f0       	push   $0xf01077db
f01029c8:	68 81 04 00 00       	push   $0x481
f01029cd:	68 b5 77 10 f0       	push   $0xf01077b5
f01029d2:	e8 69 d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01029d7:	68 60 7a 10 f0       	push   $0xf0107a60
f01029dc:	68 db 77 10 f0       	push   $0xf01077db
f01029e1:	68 82 04 00 00       	push   $0x482
f01029e6:	68 b5 77 10 f0       	push   $0xf01077b5
f01029eb:	e8 50 d6 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01029f0:	68 ac 73 10 f0       	push   $0xf01073ac
f01029f5:	68 db 77 10 f0       	push   $0xf01077db
f01029fa:	68 85 04 00 00       	push   $0x485
f01029ff:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a04:	e8 37 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102a09:	68 71 7a 10 f0       	push   $0xf0107a71
f0102a0e:	68 db 77 10 f0       	push   $0xf01077db
f0102a13:	68 86 04 00 00       	push   $0x486
f0102a18:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a1d:	e8 1e d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102a22:	68 7d 7a 10 f0       	push   $0xf0107a7d
f0102a27:	68 db 77 10 f0       	push   $0xf01077db
f0102a2c:	68 87 04 00 00       	push   $0x487
f0102a31:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a36:	e8 05 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a3b:	68 88 73 10 f0       	push   $0xf0107388
f0102a40:	68 db 77 10 f0       	push   $0xf01077db
f0102a45:	68 8b 04 00 00       	push   $0x48b
f0102a4a:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a4f:	e8 ec d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a54:	68 e4 73 10 f0       	push   $0xf01073e4
f0102a59:	68 db 77 10 f0       	push   $0xf01077db
f0102a5e:	68 8c 04 00 00       	push   $0x48c
f0102a63:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a68:	e8 d3 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a6d:	68 92 7a 10 f0       	push   $0xf0107a92
f0102a72:	68 db 77 10 f0       	push   $0xf01077db
f0102a77:	68 8d 04 00 00       	push   $0x48d
f0102a7c:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a81:	e8 ba d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a86:	68 60 7a 10 f0       	push   $0xf0107a60
f0102a8b:	68 db 77 10 f0       	push   $0xf01077db
f0102a90:	68 8e 04 00 00       	push   $0x48e
f0102a95:	68 b5 77 10 f0       	push   $0xf01077b5
f0102a9a:	e8 a1 d5 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a9f:	68 0c 74 10 f0       	push   $0xf010740c
f0102aa4:	68 db 77 10 f0       	push   $0xf01077db
f0102aa9:	68 91 04 00 00       	push   $0x491
f0102aae:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ab3:	e8 88 d5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102ab8:	68 b4 79 10 f0       	push   $0xf01079b4
f0102abd:	68 db 77 10 f0       	push   $0xf01077db
f0102ac2:	68 94 04 00 00       	push   $0x494
f0102ac7:	68 b5 77 10 f0       	push   $0xf01077b5
f0102acc:	e8 6f d5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ad1:	68 b0 70 10 f0       	push   $0xf01070b0
f0102ad6:	68 db 77 10 f0       	push   $0xf01077db
f0102adb:	68 97 04 00 00       	push   $0x497
f0102ae0:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ae5:	e8 56 d5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102aea:	68 17 7a 10 f0       	push   $0xf0107a17
f0102aef:	68 db 77 10 f0       	push   $0xf01077db
f0102af4:	68 99 04 00 00       	push   $0x499
f0102af9:	68 b5 77 10 f0       	push   $0xf01077b5
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
f0102b03:	50                   	push   %eax
f0102b04:	68 64 67 10 f0       	push   $0xf0106764
f0102b09:	68 a0 04 00 00       	push   $0x4a0
f0102b0e:	68 b5 77 10 f0       	push   $0xf01077b5
f0102b13:	e8 28 d5 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b18:	68 a3 7a 10 f0       	push   $0xf0107aa3
f0102b1d:	68 db 77 10 f0       	push   $0xf01077db
f0102b22:	68 a1 04 00 00       	push   $0x4a1
f0102b27:	68 b5 77 10 f0       	push   $0xf01077b5
f0102b2c:	e8 0f d5 ff ff       	call   f0100040 <_panic>
f0102b31:	50                   	push   %eax
f0102b32:	68 64 67 10 f0       	push   $0xf0106764
f0102b37:	6a 58                	push   $0x58
f0102b39:	68 c1 77 10 f0       	push   $0xf01077c1
f0102b3e:	e8 fd d4 ff ff       	call   f0100040 <_panic>
f0102b43:	52                   	push   %edx
f0102b44:	68 64 67 10 f0       	push   $0xf0106764
f0102b49:	6a 58                	push   $0x58
f0102b4b:	68 c1 77 10 f0       	push   $0xf01077c1
f0102b50:	e8 eb d4 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b55:	68 bb 7a 10 f0       	push   $0xf0107abb
f0102b5a:	68 db 77 10 f0       	push   $0xf01077db
f0102b5f:	68 ab 04 00 00       	push   $0x4ab
f0102b64:	68 b5 77 10 f0       	push   $0xf01077b5
f0102b69:	e8 d2 d4 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102b6e:	68 30 74 10 f0       	push   $0xf0107430
f0102b73:	68 db 77 10 f0       	push   $0xf01077db
f0102b78:	68 bb 04 00 00       	push   $0x4bb
f0102b7d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102b82:	e8 b9 d4 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102b87:	68 58 74 10 f0       	push   $0xf0107458
f0102b8c:	68 db 77 10 f0       	push   $0xf01077db
f0102b91:	68 bc 04 00 00       	push   $0x4bc
f0102b96:	68 b5 77 10 f0       	push   $0xf01077b5
f0102b9b:	e8 a0 d4 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102ba0:	68 80 74 10 f0       	push   $0xf0107480
f0102ba5:	68 db 77 10 f0       	push   $0xf01077db
f0102baa:	68 be 04 00 00       	push   $0x4be
f0102baf:	68 b5 77 10 f0       	push   $0xf01077b5
f0102bb4:	e8 87 d4 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102bb9:	68 d2 7a 10 f0       	push   $0xf0107ad2
f0102bbe:	68 db 77 10 f0       	push   $0xf01077db
f0102bc3:	68 c0 04 00 00       	push   $0x4c0
f0102bc8:	68 b5 77 10 f0       	push   $0xf01077b5
f0102bcd:	e8 6e d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102bd2:	68 a8 74 10 f0       	push   $0xf01074a8
f0102bd7:	68 db 77 10 f0       	push   $0xf01077db
f0102bdc:	68 c2 04 00 00       	push   $0x4c2
f0102be1:	68 b5 77 10 f0       	push   $0xf01077b5
f0102be6:	e8 55 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102beb:	68 cc 74 10 f0       	push   $0xf01074cc
f0102bf0:	68 db 77 10 f0       	push   $0xf01077db
f0102bf5:	68 c3 04 00 00       	push   $0x4c3
f0102bfa:	68 b5 77 10 f0       	push   $0xf01077b5
f0102bff:	e8 3c d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102c04:	68 fc 74 10 f0       	push   $0xf01074fc
f0102c09:	68 db 77 10 f0       	push   $0xf01077db
f0102c0e:	68 c4 04 00 00       	push   $0x4c4
f0102c13:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c18:	e8 23 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102c1d:	68 20 75 10 f0       	push   $0xf0107520
f0102c22:	68 db 77 10 f0       	push   $0xf01077db
f0102c27:	68 c5 04 00 00       	push   $0x4c5
f0102c2c:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c31:	e8 0a d4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102c36:	68 4c 75 10 f0       	push   $0xf010754c
f0102c3b:	68 db 77 10 f0       	push   $0xf01077db
f0102c40:	68 c7 04 00 00       	push   $0x4c7
f0102c45:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c4a:	e8 f1 d3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102c4f:	68 90 75 10 f0       	push   $0xf0107590
f0102c54:	68 db 77 10 f0       	push   $0xf01077db
f0102c59:	68 c8 04 00 00       	push   $0x4c8
f0102c5e:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c63:	e8 d8 d3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c68:	50                   	push   %eax
f0102c69:	68 88 67 10 f0       	push   $0xf0106788
f0102c6e:	68 cb 00 00 00       	push   $0xcb
f0102c73:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c78:	e8 c3 d3 ff ff       	call   f0100040 <_panic>
f0102c7d:	50                   	push   %eax
f0102c7e:	68 88 67 10 f0       	push   $0xf0106788
f0102c83:	68 d4 00 00 00       	push   $0xd4
f0102c88:	68 b5 77 10 f0       	push   $0xf01077b5
f0102c8d:	e8 ae d3 ff ff       	call   f0100040 <_panic>
f0102c92:	50                   	push   %eax
f0102c93:	68 88 67 10 f0       	push   $0xf0106788
f0102c98:	68 e1 00 00 00       	push   $0xe1
f0102c9d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ca2:	e8 99 d3 ff ff       	call   f0100040 <_panic>
f0102ca7:	51                   	push   %ecx
f0102ca8:	68 88 67 10 f0       	push   $0xf0106788
f0102cad:	68 24 01 00 00       	push   $0x124
f0102cb2:	68 b5 77 10 f0       	push   $0xf01077b5
f0102cb7:	e8 84 d3 ff ff       	call   f0100040 <_panic>
                panic("no free page");
f0102cbc:	83 ec 04             	sub    $0x4,%esp
f0102cbf:	68 fd 7a 10 f0       	push   $0xf0107afd
f0102cc4:	68 29 01 00 00       	push   $0x129
f0102cc9:	68 b5 77 10 f0       	push   $0xf01077b5
f0102cce:	e8 6d d3 ff ff       	call   f0100040 <_panic>
f0102cd3:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102cd6:	68 88 67 10 f0       	push   $0xf0106788
f0102cdb:	68 e0 03 00 00       	push   $0x3e0
f0102ce0:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ce5:	e8 56 d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102cea:	68 c4 75 10 f0       	push   $0xf01075c4
f0102cef:	68 db 77 10 f0       	push   $0xf01077db
f0102cf4:	68 e0 03 00 00       	push   $0x3e0
f0102cf9:	68 b5 77 10 f0       	push   $0xf01077b5
f0102cfe:	e8 3d d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d03:	a1 48 52 21 f0       	mov    0xf0215248,%eax
f0102d08:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102d0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102d0e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102d13:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102d19:	89 da                	mov    %ebx,%edx
f0102d1b:	89 f8                	mov    %edi,%eax
f0102d1d:	e8 fb dd ff ff       	call   f0100b1d <check_va2pa>
f0102d22:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102d29:	76 22                	jbe    f0102d4d <mem_init+0x16e2>
f0102d2b:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102d2e:	39 d0                	cmp    %edx,%eax
f0102d30:	75 32                	jne    f0102d64 <mem_init+0x16f9>
f0102d32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102d38:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102d3e:	75 d9                	jne    f0102d19 <mem_init+0x16ae>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d40:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102d43:	c1 e6 0c             	shl    $0xc,%esi
f0102d46:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102d4b:	eb 4b                	jmp    f0102d98 <mem_init+0x172d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d4d:	ff 75 d0             	pushl  -0x30(%ebp)
f0102d50:	68 88 67 10 f0       	push   $0xf0106788
f0102d55:	68 e5 03 00 00       	push   $0x3e5
f0102d5a:	68 b5 77 10 f0       	push   $0xf01077b5
f0102d5f:	e8 dc d2 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d64:	68 f8 75 10 f0       	push   $0xf01075f8
f0102d69:	68 db 77 10 f0       	push   $0xf01077db
f0102d6e:	68 e5 03 00 00       	push   $0x3e5
f0102d73:	68 b5 77 10 f0       	push   $0xf01077b5
f0102d78:	e8 c3 d2 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d7d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102d83:	89 f8                	mov    %edi,%eax
f0102d85:	e8 93 dd ff ff       	call   f0100b1d <check_va2pa>
f0102d8a:	39 c3                	cmp    %eax,%ebx
f0102d8c:	0f 85 f9 00 00 00    	jne    f0102e8b <mem_init+0x1820>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d92:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d98:	39 f3                	cmp    %esi,%ebx
f0102d9a:	72 e1                	jb     f0102d7d <mem_init+0x1712>
f0102d9c:	c7 45 d4 00 70 21 f0 	movl   $0xf0217000,-0x2c(%ebp)
f0102da3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102da8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dab:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102dae:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102db4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102db7:	89 f3                	mov    %esi,%ebx
f0102db9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102dbc:	05 00 80 00 20       	add    $0x20008000,%eax
f0102dc1:	89 75 c8             	mov    %esi,-0x38(%ebp)
f0102dc4:	89 c6                	mov    %eax,%esi
f0102dc6:	89 da                	mov    %ebx,%edx
f0102dc8:	89 f8                	mov    %edi,%eax
f0102dca:	e8 4e dd ff ff       	call   f0100b1d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102dcf:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102dd6:	0f 86 c8 00 00 00    	jbe    f0102ea4 <mem_init+0x1839>
f0102ddc:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ddf:	39 d0                	cmp    %edx,%eax
f0102de1:	0f 85 d4 00 00 00    	jne    f0102ebb <mem_init+0x1850>
f0102de7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ded:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102df0:	75 d4                	jne    f0102dc6 <mem_init+0x175b>
f0102df2:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0102df5:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102dfb:	89 da                	mov    %ebx,%edx
f0102dfd:	89 f8                	mov    %edi,%eax
f0102dff:	e8 19 dd ff ff       	call   f0100b1d <check_va2pa>
f0102e04:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e07:	0f 85 c7 00 00 00    	jne    f0102ed4 <mem_init+0x1869>
f0102e0d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e13:	39 f3                	cmp    %esi,%ebx
f0102e15:	75 e4                	jne    f0102dfb <mem_init+0x1790>
f0102e17:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102e1d:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f0102e24:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e27:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102e2e:	3d 00 70 2d f0       	cmp    $0xf02d7000,%eax
f0102e33:	0f 85 6f ff ff ff    	jne    f0102da8 <mem_init+0x173d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102e39:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102e3e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102e43:	0f 87 a4 00 00 00    	ja     f0102eed <mem_init+0x1882>
				assert(pgdir[i] == 0);
f0102e49:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102e4d:	0f 85 dd 00 00 00    	jne    f0102f30 <mem_init+0x18c5>
	for (i = 0; i < NPDENTRIES; i++) {
f0102e53:	83 c0 01             	add    $0x1,%eax
f0102e56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102e5b:	0f 87 e8 00 00 00    	ja     f0102f49 <mem_init+0x18de>
		switch (i) {
f0102e61:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e67:	83 fa 04             	cmp    $0x4,%edx
f0102e6a:	77 d2                	ja     f0102e3e <mem_init+0x17d3>
			assert(pgdir[i] & PTE_P);
f0102e6c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102e70:	75 e1                	jne    f0102e53 <mem_init+0x17e8>
f0102e72:	68 0a 7b 10 f0       	push   $0xf0107b0a
f0102e77:	68 db 77 10 f0       	push   $0xf01077db
f0102e7c:	68 fe 03 00 00       	push   $0x3fe
f0102e81:	68 b5 77 10 f0       	push   $0xf01077b5
f0102e86:	e8 b5 d1 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e8b:	68 2c 76 10 f0       	push   $0xf010762c
f0102e90:	68 db 77 10 f0       	push   $0xf01077db
f0102e95:	68 e9 03 00 00       	push   $0x3e9
f0102e9a:	68 b5 77 10 f0       	push   $0xf01077b5
f0102e9f:	e8 9c d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea4:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102ea7:	68 88 67 10 f0       	push   $0xf0106788
f0102eac:	68 f1 03 00 00       	push   $0x3f1
f0102eb1:	68 b5 77 10 f0       	push   $0xf01077b5
f0102eb6:	e8 85 d1 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102ebb:	68 54 76 10 f0       	push   $0xf0107654
f0102ec0:	68 db 77 10 f0       	push   $0xf01077db
f0102ec5:	68 f1 03 00 00       	push   $0x3f1
f0102eca:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ecf:	e8 6c d1 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ed4:	68 9c 76 10 f0       	push   $0xf010769c
f0102ed9:	68 db 77 10 f0       	push   $0xf01077db
f0102ede:	68 f3 03 00 00       	push   $0x3f3
f0102ee3:	68 b5 77 10 f0       	push   $0xf01077b5
f0102ee8:	e8 53 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102eed:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ef0:	f6 c2 01             	test   $0x1,%dl
f0102ef3:	74 22                	je     f0102f17 <mem_init+0x18ac>
				assert(pgdir[i] & PTE_W);
f0102ef5:	f6 c2 02             	test   $0x2,%dl
f0102ef8:	0f 85 55 ff ff ff    	jne    f0102e53 <mem_init+0x17e8>
f0102efe:	68 1b 7b 10 f0       	push   $0xf0107b1b
f0102f03:	68 db 77 10 f0       	push   $0xf01077db
f0102f08:	68 03 04 00 00       	push   $0x403
f0102f0d:	68 b5 77 10 f0       	push   $0xf01077b5
f0102f12:	e8 29 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102f17:	68 0a 7b 10 f0       	push   $0xf0107b0a
f0102f1c:	68 db 77 10 f0       	push   $0xf01077db
f0102f21:	68 02 04 00 00       	push   $0x402
f0102f26:	68 b5 77 10 f0       	push   $0xf01077b5
f0102f2b:	e8 10 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102f30:	68 2c 7b 10 f0       	push   $0xf0107b2c
f0102f35:	68 db 77 10 f0       	push   $0xf01077db
f0102f3a:	68 05 04 00 00       	push   $0x405
f0102f3f:	68 b5 77 10 f0       	push   $0xf01077b5
f0102f44:	e8 f7 d0 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f49:	83 ec 0c             	sub    $0xc,%esp
f0102f4c:	68 c0 76 10 f0       	push   $0xf01076c0
f0102f51:	e8 32 0e 00 00       	call   f0103d88 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102f56:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102f5b:	83 c4 10             	add    $0x10,%esp
f0102f5e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f63:	0f 86 fe 01 00 00    	jbe    f0103167 <mem_init+0x1afc>
	return (physaddr_t)kva - KERNBASE;
f0102f69:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f6e:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102f71:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f76:	e8 06 dc ff ff       	call   f0100b81 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102f7b:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102f7e:	83 e0 f3             	and    $0xfffffff3,%eax
f0102f81:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102f86:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f89:	83 ec 0c             	sub    $0xc,%esp
f0102f8c:	6a 00                	push   $0x0
f0102f8e:	e8 36 e0 ff ff       	call   f0100fc9 <page_alloc>
f0102f93:	89 c3                	mov    %eax,%ebx
f0102f95:	83 c4 10             	add    $0x10,%esp
f0102f98:	85 c0                	test   %eax,%eax
f0102f9a:	0f 84 dc 01 00 00    	je     f010317c <mem_init+0x1b11>
	assert((pp1 = page_alloc(0)));
f0102fa0:	83 ec 0c             	sub    $0xc,%esp
f0102fa3:	6a 00                	push   $0x0
f0102fa5:	e8 1f e0 ff ff       	call   f0100fc9 <page_alloc>
f0102faa:	89 c7                	mov    %eax,%edi
f0102fac:	83 c4 10             	add    $0x10,%esp
f0102faf:	85 c0                	test   %eax,%eax
f0102fb1:	0f 84 de 01 00 00    	je     f0103195 <mem_init+0x1b2a>
	assert((pp2 = page_alloc(0)));
f0102fb7:	83 ec 0c             	sub    $0xc,%esp
f0102fba:	6a 00                	push   $0x0
f0102fbc:	e8 08 e0 ff ff       	call   f0100fc9 <page_alloc>
f0102fc1:	89 c6                	mov    %eax,%esi
f0102fc3:	83 c4 10             	add    $0x10,%esp
f0102fc6:	85 c0                	test   %eax,%eax
f0102fc8:	0f 84 e0 01 00 00    	je     f01031ae <mem_init+0x1b43>
	page_free(pp0);
f0102fce:	83 ec 0c             	sub    $0xc,%esp
f0102fd1:	53                   	push   %ebx
f0102fd2:	e8 64 e0 ff ff       	call   f010103b <page_free>
	return (pp - pages) << PGSHIFT;
f0102fd7:	89 f8                	mov    %edi,%eax
f0102fd9:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0102fdf:	c1 f8 03             	sar    $0x3,%eax
f0102fe2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102fe5:	89 c2                	mov    %eax,%edx
f0102fe7:	c1 ea 0c             	shr    $0xc,%edx
f0102fea:	83 c4 10             	add    $0x10,%esp
f0102fed:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f0102ff3:	0f 83 ce 01 00 00    	jae    f01031c7 <mem_init+0x1b5c>
	memset(page2kva(pp1), 1, PGSIZE);
f0102ff9:	83 ec 04             	sub    $0x4,%esp
f0102ffc:	68 00 10 00 00       	push   $0x1000
f0103001:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103003:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103008:	50                   	push   %eax
f0103009:	e8 da 2a 00 00       	call   f0105ae8 <memset>
	return (pp - pages) << PGSHIFT;
f010300e:	89 f0                	mov    %esi,%eax
f0103010:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0103016:	c1 f8 03             	sar    $0x3,%eax
f0103019:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010301c:	89 c2                	mov    %eax,%edx
f010301e:	c1 ea 0c             	shr    $0xc,%edx
f0103021:	83 c4 10             	add    $0x10,%esp
f0103024:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f010302a:	0f 83 a9 01 00 00    	jae    f01031d9 <mem_init+0x1b6e>
	memset(page2kva(pp2), 2, PGSIZE);
f0103030:	83 ec 04             	sub    $0x4,%esp
f0103033:	68 00 10 00 00       	push   $0x1000
f0103038:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010303a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010303f:	50                   	push   %eax
f0103040:	e8 a3 2a 00 00       	call   f0105ae8 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103045:	6a 02                	push   $0x2
f0103047:	68 00 10 00 00       	push   $0x1000
f010304c:	57                   	push   %edi
f010304d:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0103053:	e8 10 e5 ff ff       	call   f0101568 <page_insert>
	assert(pp1->pp_ref == 1);
f0103058:	83 c4 20             	add    $0x20,%esp
f010305b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103060:	0f 85 85 01 00 00    	jne    f01031eb <mem_init+0x1b80>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103066:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010306d:	01 01 01 
f0103070:	0f 85 8e 01 00 00    	jne    f0103204 <mem_init+0x1b99>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103076:	6a 02                	push   $0x2
f0103078:	68 00 10 00 00       	push   $0x1000
f010307d:	56                   	push   %esi
f010307e:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f0103084:	e8 df e4 ff ff       	call   f0101568 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103089:	83 c4 10             	add    $0x10,%esp
f010308c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103093:	02 02 02 
f0103096:	0f 85 81 01 00 00    	jne    f010321d <mem_init+0x1bb2>
	assert(pp2->pp_ref == 1);
f010309c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01030a1:	0f 85 8f 01 00 00    	jne    f0103236 <mem_init+0x1bcb>
	assert(pp1->pp_ref == 0);
f01030a7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01030ac:	0f 85 9d 01 00 00    	jne    f010324f <mem_init+0x1be4>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01030b2:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01030b9:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01030bc:	89 f0                	mov    %esi,%eax
f01030be:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f01030c4:	c1 f8 03             	sar    $0x3,%eax
f01030c7:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01030ca:	89 c2                	mov    %eax,%edx
f01030cc:	c1 ea 0c             	shr    $0xc,%edx
f01030cf:	3b 15 88 5e 21 f0    	cmp    0xf0215e88,%edx
f01030d5:	0f 83 8d 01 00 00    	jae    f0103268 <mem_init+0x1bfd>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01030db:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01030e2:	03 03 03 
f01030e5:	0f 85 8f 01 00 00    	jne    f010327a <mem_init+0x1c0f>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01030eb:	83 ec 08             	sub    $0x8,%esp
f01030ee:	68 00 10 00 00       	push   $0x1000
f01030f3:	ff 35 8c 5e 21 f0    	pushl  0xf0215e8c
f01030f9:	e8 22 e4 ff ff       	call   f0101520 <page_remove>
	assert(pp2->pp_ref == 0);
f01030fe:	83 c4 10             	add    $0x10,%esp
f0103101:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103106:	0f 85 87 01 00 00    	jne    f0103293 <mem_init+0x1c28>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010310c:	8b 0d 8c 5e 21 f0    	mov    0xf0215e8c,%ecx
f0103112:	8b 11                	mov    (%ecx),%edx
f0103114:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010311a:	89 d8                	mov    %ebx,%eax
f010311c:	2b 05 90 5e 21 f0    	sub    0xf0215e90,%eax
f0103122:	c1 f8 03             	sar    $0x3,%eax
f0103125:	c1 e0 0c             	shl    $0xc,%eax
f0103128:	39 c2                	cmp    %eax,%edx
f010312a:	0f 85 7c 01 00 00    	jne    f01032ac <mem_init+0x1c41>
	kern_pgdir[0] = 0;
f0103130:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103136:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010313b:	0f 85 84 01 00 00    	jne    f01032c5 <mem_init+0x1c5a>
	pp0->pp_ref = 0;
f0103141:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103147:	83 ec 0c             	sub    $0xc,%esp
f010314a:	53                   	push   %ebx
f010314b:	e8 eb de ff ff       	call   f010103b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103150:	c7 04 24 54 77 10 f0 	movl   $0xf0107754,(%esp)
f0103157:	e8 2c 0c 00 00       	call   f0103d88 <cprintf>
}
f010315c:	83 c4 10             	add    $0x10,%esp
f010315f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103162:	5b                   	pop    %ebx
f0103163:	5e                   	pop    %esi
f0103164:	5f                   	pop    %edi
f0103165:	5d                   	pop    %ebp
f0103166:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103167:	50                   	push   %eax
f0103168:	68 88 67 10 f0       	push   $0xf0106788
f010316d:	68 fa 00 00 00       	push   $0xfa
f0103172:	68 b5 77 10 f0       	push   $0xf01077b5
f0103177:	e8 c4 ce ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010317c:	68 09 79 10 f0       	push   $0xf0107909
f0103181:	68 db 77 10 f0       	push   $0xf01077db
f0103186:	68 dd 04 00 00       	push   $0x4dd
f010318b:	68 b5 77 10 f0       	push   $0xf01077b5
f0103190:	e8 ab ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103195:	68 1f 79 10 f0       	push   $0xf010791f
f010319a:	68 db 77 10 f0       	push   $0xf01077db
f010319f:	68 de 04 00 00       	push   $0x4de
f01031a4:	68 b5 77 10 f0       	push   $0xf01077b5
f01031a9:	e8 92 ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031ae:	68 35 79 10 f0       	push   $0xf0107935
f01031b3:	68 db 77 10 f0       	push   $0xf01077db
f01031b8:	68 df 04 00 00       	push   $0x4df
f01031bd:	68 b5 77 10 f0       	push   $0xf01077b5
f01031c2:	e8 79 ce ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031c7:	50                   	push   %eax
f01031c8:	68 64 67 10 f0       	push   $0xf0106764
f01031cd:	6a 58                	push   $0x58
f01031cf:	68 c1 77 10 f0       	push   $0xf01077c1
f01031d4:	e8 67 ce ff ff       	call   f0100040 <_panic>
f01031d9:	50                   	push   %eax
f01031da:	68 64 67 10 f0       	push   $0xf0106764
f01031df:	6a 58                	push   $0x58
f01031e1:	68 c1 77 10 f0       	push   $0xf01077c1
f01031e6:	e8 55 ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01031eb:	68 06 7a 10 f0       	push   $0xf0107a06
f01031f0:	68 db 77 10 f0       	push   $0xf01077db
f01031f5:	68 e4 04 00 00       	push   $0x4e4
f01031fa:	68 b5 77 10 f0       	push   $0xf01077b5
f01031ff:	e8 3c ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103204:	68 e0 76 10 f0       	push   $0xf01076e0
f0103209:	68 db 77 10 f0       	push   $0xf01077db
f010320e:	68 e5 04 00 00       	push   $0x4e5
f0103213:	68 b5 77 10 f0       	push   $0xf01077b5
f0103218:	e8 23 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010321d:	68 04 77 10 f0       	push   $0xf0107704
f0103222:	68 db 77 10 f0       	push   $0xf01077db
f0103227:	68 e7 04 00 00       	push   $0x4e7
f010322c:	68 b5 77 10 f0       	push   $0xf01077b5
f0103231:	e8 0a ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103236:	68 28 7a 10 f0       	push   $0xf0107a28
f010323b:	68 db 77 10 f0       	push   $0xf01077db
f0103240:	68 e8 04 00 00       	push   $0x4e8
f0103245:	68 b5 77 10 f0       	push   $0xf01077b5
f010324a:	e8 f1 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010324f:	68 92 7a 10 f0       	push   $0xf0107a92
f0103254:	68 db 77 10 f0       	push   $0xf01077db
f0103259:	68 e9 04 00 00       	push   $0x4e9
f010325e:	68 b5 77 10 f0       	push   $0xf01077b5
f0103263:	e8 d8 cd ff ff       	call   f0100040 <_panic>
f0103268:	50                   	push   %eax
f0103269:	68 64 67 10 f0       	push   $0xf0106764
f010326e:	6a 58                	push   $0x58
f0103270:	68 c1 77 10 f0       	push   $0xf01077c1
f0103275:	e8 c6 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010327a:	68 28 77 10 f0       	push   $0xf0107728
f010327f:	68 db 77 10 f0       	push   $0xf01077db
f0103284:	68 eb 04 00 00       	push   $0x4eb
f0103289:	68 b5 77 10 f0       	push   $0xf01077b5
f010328e:	e8 ad cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0103293:	68 60 7a 10 f0       	push   $0xf0107a60
f0103298:	68 db 77 10 f0       	push   $0xf01077db
f010329d:	68 ed 04 00 00       	push   $0x4ed
f01032a2:	68 b5 77 10 f0       	push   $0xf01077b5
f01032a7:	e8 94 cd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032ac:	68 b0 70 10 f0       	push   $0xf01070b0
f01032b1:	68 db 77 10 f0       	push   $0xf01077db
f01032b6:	68 f0 04 00 00       	push   $0x4f0
f01032bb:	68 b5 77 10 f0       	push   $0xf01077b5
f01032c0:	e8 7b cd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01032c5:	68 17 7a 10 f0       	push   $0xf0107a17
f01032ca:	68 db 77 10 f0       	push   $0xf01077db
f01032cf:	68 f2 04 00 00       	push   $0x4f2
f01032d4:	68 b5 77 10 f0       	push   $0xf01077b5
f01032d9:	e8 62 cd ff ff       	call   f0100040 <_panic>

f01032de <user_mem_check>:
{
f01032de:	55                   	push   %ebp
f01032df:	89 e5                	mov    %esp,%ebp
f01032e1:	57                   	push   %edi
f01032e2:	56                   	push   %esi
f01032e3:	53                   	push   %ebx
f01032e4:	83 ec 0c             	sub    $0xc,%esp
f01032e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ea:	8b 75 14             	mov    0x14(%ebp),%esi
    end = ROUNDUP(start + len, PGSIZE);
f01032ed:	8b 55 10             	mov    0x10(%ebp),%edx
f01032f0:	8d bc 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edi
f01032f7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if (start >= ULIM) {
f01032fd:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103302:	77 33                	ja     f0103337 <user_mem_check+0x59>
f0103304:	89 c3                	mov    %eax,%ebx
    if (end >= ULIM) {
f0103306:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010330c:	77 35                	ja     f0103343 <user_mem_check+0x65>
    for (i = start; i < end; ) {
f010330e:	39 fb                	cmp    %edi,%ebx
f0103310:	73 58                	jae    f010336a <user_mem_check+0x8c>
        if ((pte = pgdir_walk(env->env_pgdir, (void *)i, 0)) == NULL) {
f0103312:	83 ec 04             	sub    $0x4,%esp
f0103315:	6a 00                	push   $0x0
f0103317:	53                   	push   %ebx
f0103318:	8b 45 08             	mov    0x8(%ebp),%eax
f010331b:	ff 70 60             	pushl  0x60(%eax)
f010331e:	e8 91 dd ff ff       	call   f01010b4 <pgdir_walk>
f0103323:	83 c4 10             	add    $0x10,%esp
f0103326:	85 c0                	test   %eax,%eax
f0103328:	74 26                	je     f0103350 <user_mem_check+0x72>
        if ((*pte & perm) != perm) {
f010332a:	89 f1                	mov    %esi,%ecx
f010332c:	23 08                	and    (%eax),%ecx
f010332e:	39 ce                	cmp    %ecx,%esi
f0103330:	75 2b                	jne    f010335d <user_mem_check+0x7f>
        i += 1;
f0103332:	83 c3 01             	add    $0x1,%ebx
f0103335:	eb d7                	jmp    f010330e <user_mem_check+0x30>
        user_mem_check_addr = start;
f0103337:	a3 3c 52 21 f0       	mov    %eax,0xf021523c
        return -E_FAULT;
f010333c:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103341:	eb 2c                	jmp    f010336f <user_mem_check+0x91>
        user_mem_check_addr = end;
f0103343:	89 3d 3c 52 21 f0    	mov    %edi,0xf021523c
        return -E_FAULT;
f0103349:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010334e:	eb 1f                	jmp    f010336f <user_mem_check+0x91>
            user_mem_check_addr = i;
f0103350:	89 1d 3c 52 21 f0    	mov    %ebx,0xf021523c
            return -E_FAULT;
f0103356:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010335b:	eb 12                	jmp    f010336f <user_mem_check+0x91>
            user_mem_check_addr = i;
f010335d:	89 1d 3c 52 21 f0    	mov    %ebx,0xf021523c
            return -E_FAULT;
f0103363:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103368:	eb 05                	jmp    f010336f <user_mem_check+0x91>
	return 0;
f010336a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010336f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103372:	5b                   	pop    %ebx
f0103373:	5e                   	pop    %esi
f0103374:	5f                   	pop    %edi
f0103375:	5d                   	pop    %ebp
f0103376:	c3                   	ret    

f0103377 <user_mem_assert>:
{
f0103377:	55                   	push   %ebp
f0103378:	89 e5                	mov    %esp,%ebp
f010337a:	53                   	push   %ebx
f010337b:	83 ec 04             	sub    $0x4,%esp
f010337e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103381:	8b 45 14             	mov    0x14(%ebp),%eax
f0103384:	83 c8 04             	or     $0x4,%eax
f0103387:	50                   	push   %eax
f0103388:	ff 75 10             	pushl  0x10(%ebp)
f010338b:	ff 75 0c             	pushl  0xc(%ebp)
f010338e:	53                   	push   %ebx
f010338f:	e8 4a ff ff ff       	call   f01032de <user_mem_check>
f0103394:	83 c4 10             	add    $0x10,%esp
f0103397:	85 c0                	test   %eax,%eax
f0103399:	78 05                	js     f01033a0 <user_mem_assert+0x29>
}
f010339b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010339e:	c9                   	leave  
f010339f:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01033a0:	83 ec 04             	sub    $0x4,%esp
f01033a3:	ff 35 3c 52 21 f0    	pushl  0xf021523c
f01033a9:	ff 73 48             	pushl  0x48(%ebx)
f01033ac:	68 80 77 10 f0       	push   $0xf0107780
f01033b1:	e8 d2 09 00 00       	call   f0103d88 <cprintf>
		env_destroy(env);	// may not return
f01033b6:	89 1c 24             	mov    %ebx,(%esp)
f01033b9:	e8 cb 06 00 00       	call   f0103a89 <env_destroy>
f01033be:	83 c4 10             	add    $0x10,%esp
}
f01033c1:	eb d8                	jmp    f010339b <user_mem_assert+0x24>

f01033c3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01033c3:	55                   	push   %ebp
f01033c4:	89 e5                	mov    %esp,%ebp
f01033c6:	56                   	push   %esi
f01033c7:	53                   	push   %ebx
f01033c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cb:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01033ce:	85 c0                	test   %eax,%eax
f01033d0:	74 2e                	je     f0103400 <envid2env+0x3d>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01033d2:	89 c3                	mov    %eax,%ebx
f01033d4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01033da:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01033dd:	03 1d 48 52 21 f0    	add    0xf0215248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01033e3:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01033e7:	74 31                	je     f010341a <envid2env+0x57>
f01033e9:	39 43 48             	cmp    %eax,0x48(%ebx)
f01033ec:	75 2c                	jne    f010341a <envid2env+0x57>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01033ee:	84 d2                	test   %dl,%dl
f01033f0:	75 38                	jne    f010342a <envid2env+0x67>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f01033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033f5:	89 18                	mov    %ebx,(%eax)
	return 0;
f01033f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033fc:	5b                   	pop    %ebx
f01033fd:	5e                   	pop    %esi
f01033fe:	5d                   	pop    %ebp
f01033ff:	c3                   	ret    
		*env_store = curenv;
f0103400:	e8 06 2d 00 00       	call   f010610b <cpunum>
f0103405:	6b c0 74             	imul   $0x74,%eax,%eax
f0103408:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010340e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103411:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103413:	b8 00 00 00 00       	mov    $0x0,%eax
f0103418:	eb e2                	jmp    f01033fc <envid2env+0x39>
		*env_store = 0;
f010341a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010341d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103423:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103428:	eb d2                	jmp    f01033fc <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010342a:	e8 dc 2c 00 00       	call   f010610b <cpunum>
f010342f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103432:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f0103438:	74 b8                	je     f01033f2 <envid2env+0x2f>
f010343a:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010343d:	e8 c9 2c 00 00       	call   f010610b <cpunum>
f0103442:	6b c0 74             	imul   $0x74,%eax,%eax
f0103445:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010344b:	3b 70 48             	cmp    0x48(%eax),%esi
f010344e:	74 a2                	je     f01033f2 <envid2env+0x2f>
		*env_store = 0;
f0103450:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103453:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103459:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010345e:	eb 9c                	jmp    f01033fc <envid2env+0x39>

f0103460 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103460:	55                   	push   %ebp
f0103461:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0103463:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103468:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010346b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103470:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103472:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103474:	b8 10 00 00 00       	mov    $0x10,%eax
f0103479:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010347b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010347d:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010347f:	ea 86 34 10 f0 08 00 	ljmp   $0x8,$0xf0103486
	asm volatile("lldt %0" : : "r" (sel));
f0103486:	b8 00 00 00 00       	mov    $0x0,%eax
f010348b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010348e:	5d                   	pop    %ebp
f010348f:	c3                   	ret    

f0103490 <env_init>:
{
f0103490:	55                   	push   %ebp
f0103491:	89 e5                	mov    %esp,%ebp
f0103493:	56                   	push   %esi
f0103494:	53                   	push   %ebx
        envs[i].env_id = 0;
f0103495:	8b 35 48 52 21 f0    	mov    0xf0215248,%esi
f010349b:	8b 15 4c 52 21 f0    	mov    0xf021524c,%edx
f01034a1:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01034a7:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01034aa:	89 c1                	mov    %eax,%ecx
f01034ac:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_link = env_free_list;
f01034b3:	89 50 44             	mov    %edx,0x44(%eax)
f01034b6:	83 e8 7c             	sub    $0x7c,%eax
        env_free_list = &envs[i];
f01034b9:	89 ca                	mov    %ecx,%edx
    for (int i=NENV - 1; i >=0 ; i--) {
f01034bb:	39 d8                	cmp    %ebx,%eax
f01034bd:	75 eb                	jne    f01034aa <env_init+0x1a>
f01034bf:	89 35 4c 52 21 f0    	mov    %esi,0xf021524c
	env_init_percpu();
f01034c5:	e8 96 ff ff ff       	call   f0103460 <env_init_percpu>
}
f01034ca:	5b                   	pop    %ebx
f01034cb:	5e                   	pop    %esi
f01034cc:	5d                   	pop    %ebp
f01034cd:	c3                   	ret    

f01034ce <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01034ce:	55                   	push   %ebp
f01034cf:	89 e5                	mov    %esp,%ebp
f01034d1:	53                   	push   %ebx
f01034d2:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01034d5:	8b 1d 4c 52 21 f0    	mov    0xf021524c,%ebx
f01034db:	85 db                	test   %ebx,%ebx
f01034dd:	0f 84 45 01 00 00    	je     f0103628 <env_alloc+0x15a>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034e3:	83 ec 0c             	sub    $0xc,%esp
f01034e6:	6a 01                	push   $0x1
f01034e8:	e8 dc da ff ff       	call   f0100fc9 <page_alloc>
f01034ed:	83 c4 10             	add    $0x10,%esp
f01034f0:	85 c0                	test   %eax,%eax
f01034f2:	0f 84 37 01 00 00    	je     f010362f <env_alloc+0x161>
	return (pp - pages) << PGSHIFT;
f01034f8:	89 c2                	mov    %eax,%edx
f01034fa:	2b 15 90 5e 21 f0    	sub    0xf0215e90,%edx
f0103500:	c1 fa 03             	sar    $0x3,%edx
f0103503:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103506:	89 d1                	mov    %edx,%ecx
f0103508:	c1 e9 0c             	shr    $0xc,%ecx
f010350b:	3b 0d 88 5e 21 f0    	cmp    0xf0215e88,%ecx
f0103511:	0f 83 e7 00 00 00    	jae    f01035fe <env_alloc+0x130>
	return (void *)(pa + KERNBASE);
f0103517:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010351d:	89 53 60             	mov    %edx,0x60(%ebx)
    p->pp_ref += 1;
f0103520:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103525:	b8 ec 0e 00 00       	mov    $0xeec,%eax
        e->env_pgdir[i] = kern_pgdir[i];
f010352a:	8b 15 8c 5e 21 f0    	mov    0xf0215e8c,%edx
f0103530:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103533:	8b 53 60             	mov    0x60(%ebx),%edx
f0103536:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103539:	83 c0 04             	add    $0x4,%eax
    for (i = PDX(UTOP); i <NPDENTRIES; i++) {
f010353c:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103541:	75 e7                	jne    f010352a <env_alloc+0x5c>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103543:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0103546:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010354b:	0f 86 c2 00 00 00    	jbe    f0103613 <env_alloc+0x145>
	return (physaddr_t)kva - KERNBASE;
f0103551:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103557:	83 ca 05             	or     $0x5,%edx
f010355a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103560:	8b 43 48             	mov    0x48(%ebx),%eax
f0103563:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103568:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010356d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103572:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103575:	89 da                	mov    %ebx,%edx
f0103577:	2b 15 48 52 21 f0    	sub    0xf0215248,%edx
f010357d:	c1 fa 02             	sar    $0x2,%edx
f0103580:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103586:	09 d0                	or     %edx,%eax
f0103588:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010358b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010358e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103591:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103598:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010359f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01035a6:	83 ec 04             	sub    $0x4,%esp
f01035a9:	6a 44                	push   $0x44
f01035ab:	6a 00                	push   $0x0
f01035ad:	53                   	push   %ebx
f01035ae:	e8 35 25 00 00       	call   f0105ae8 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01035b3:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01035b9:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01035bf:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01035c5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01035cc:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
    e->env_tf.tf_eflags = e->env_tf.tf_eflags | FL_IF;
f01035d2:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01035d9:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01035e0:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01035e4:	8b 43 44             	mov    0x44(%ebx),%eax
f01035e7:	a3 4c 52 21 f0       	mov    %eax,0xf021524c
	*newenv_store = e;
f01035ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ef:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01035f1:	83 c4 10             	add    $0x10,%esp
f01035f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035fc:	c9                   	leave  
f01035fd:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035fe:	52                   	push   %edx
f01035ff:	68 64 67 10 f0       	push   $0xf0106764
f0103604:	68 be 00 00 00       	push   $0xbe
f0103609:	68 3a 7b 10 f0       	push   $0xf0107b3a
f010360e:	e8 2d ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103613:	50                   	push   %eax
f0103614:	68 88 67 10 f0       	push   $0xf0106788
f0103619:	68 c7 00 00 00       	push   $0xc7
f010361e:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0103623:	e8 18 ca ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103628:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010362d:	eb ca                	jmp    f01035f9 <env_alloc+0x12b>
		return -E_NO_MEM;
f010362f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103634:	eb c3                	jmp    f01035f9 <env_alloc+0x12b>

f0103636 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103636:	55                   	push   %ebp
f0103637:	89 e5                	mov    %esp,%ebp
f0103639:	57                   	push   %edi
f010363a:	56                   	push   %esi
f010363b:	53                   	push   %ebx
f010363c:	81 ec c4 00 00 00    	sub    $0xc4,%esp
	// LAB 3: Your code here.
    struct Env env = {};
f0103642:	8d bd 6c ff ff ff    	lea    -0x94(%ebp),%edi
f0103648:	b9 1f 00 00 00       	mov    $0x1f,%ecx
f010364d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103652:	f3 ab                	rep stos %eax,%es:(%edi)
    struct Env *env_p = &env;
f0103654:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
f010365a:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
    env_alloc(&env_p, 0);
f0103660:	6a 00                	push   $0x0
f0103662:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
f0103668:	50                   	push   %eax
f0103669:	e8 60 fe ff ff       	call   f01034ce <env_alloc>
    env_p->env_type = type;
f010366e:	8b bd 68 ff ff ff    	mov    -0x98(%ebp),%edi
f0103674:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103677:	89 47 50             	mov    %eax,0x50(%edi)
    ph_num = elf->e_phnum;
f010367a:	8b 45 08             	mov    0x8(%ebp),%eax
f010367d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103681:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
    ph = (struct Proghdr *) ((uint32_t) binary + elf->e_phoff);
f0103687:	8b 45 08             	mov    0x8(%ebp),%eax
f010368a:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
f0103690:	03 40 1c             	add    0x1c(%eax),%eax
f0103693:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
f0103699:	83 c4 10             	add    $0x10,%esp
    for (int i=0; i < ph_num; i++) {
f010369c:	c7 85 48 ff ff ff 00 	movl   $0x0,-0xb8(%ebp)
f01036a3:	00 00 00 
        size = PGSIZE;
f01036a6:	c7 85 54 ff ff ff 00 	movl   $0x1000,-0xac(%ebp)
f01036ad:	10 00 00 
f01036b0:	89 bd 60 ff ff ff    	mov    %edi,-0xa0(%ebp)
f01036b6:	e9 1a 01 00 00       	jmp    f01037d5 <env_create+0x19f>
            panic("no page free");
f01036bb:	83 ec 04             	sub    $0x4,%esp
f01036be:	68 45 7b 10 f0       	push   $0xf0107b45
f01036c3:	68 2e 01 00 00       	push   $0x12e
f01036c8:	68 3a 7b 10 f0       	push   $0xf0107b3a
f01036cd:	e8 6e c9 ff ff       	call   f0100040 <_panic>
            panic("page_insert error %e", err);
f01036d2:	50                   	push   %eax
f01036d3:	68 52 7b 10 f0       	push   $0xf0107b52
f01036d8:	68 31 01 00 00       	push   $0x131
f01036dd:	68 3a 7b 10 f0       	push   $0xf0107b3a
f01036e2:	e8 59 c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036e7:	53                   	push   %ebx
f01036e8:	68 64 67 10 f0       	push   $0xf0106764
f01036ed:	6a 58                	push   $0x58
f01036ef:	68 c1 77 10 f0       	push   $0xf01077c1
f01036f4:	e8 47 c9 ff ff       	call   f0100040 <_panic>
            i += size;
f01036f9:	01 d6                	add    %edx,%esi
f01036fb:	eb 10                	jmp    f010370d <env_create+0xd7>
            memcpy(dst, src, size);
f01036fd:	83 ec 04             	sub    $0x4,%esp
f0103700:	52                   	push   %edx
f0103701:	51                   	push   %ecx
f0103702:	50                   	push   %eax
f0103703:	e8 95 24 00 00       	call   f0105b9d <memcpy>
f0103708:	83 c4 10             	add    $0x10,%esp
        i += size;
f010370b:	89 de                	mov    %ebx,%esi
    for (i=0; i < len; ) {
f010370d:	39 b5 64 ff ff ff    	cmp    %esi,-0x9c(%ebp)
f0103713:	0f 86 ae 00 00 00    	jbe    f01037c7 <env_create+0x191>
        if ((pp = page_alloc(1)) == NULL)
f0103719:	83 ec 0c             	sub    $0xc,%esp
f010371c:	6a 01                	push   $0x1
f010371e:	e8 a6 d8 ff ff       	call   f0100fc9 <page_alloc>
f0103723:	89 c3                	mov    %eax,%ebx
f0103725:	83 c4 10             	add    $0x10,%esp
f0103728:	85 c0                	test   %eax,%eax
f010372a:	74 8f                	je     f01036bb <env_create+0x85>
        if ((err = page_insert(e->env_pgdir, pp, (void *)(va + i), PTE_U | PTE_P | PTE_W)) != 0)
f010372c:	6a 07                	push   $0x7
f010372e:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0103734:	01 f0                	add    %esi,%eax
f0103736:	50                   	push   %eax
f0103737:	53                   	push   %ebx
f0103738:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f010373e:	ff 70 60             	pushl  0x60(%eax)
f0103741:	e8 22 de ff ff       	call   f0101568 <page_insert>
f0103746:	83 c4 10             	add    $0x10,%esp
f0103749:	85 c0                	test   %eax,%eax
f010374b:	75 85                	jne    f01036d2 <env_create+0x9c>
	return (pp - pages) << PGSHIFT;
f010374d:	2b 1d 90 5e 21 f0    	sub    0xf0215e90,%ebx
f0103753:	c1 fb 03             	sar    $0x3,%ebx
f0103756:	c1 e3 0c             	shl    $0xc,%ebx
	if (PGNUM(pa) >= npages)
f0103759:	89 d8                	mov    %ebx,%eax
f010375b:	c1 e8 0c             	shr    $0xc,%eax
f010375e:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0103764:	73 81                	jae    f01036e7 <env_create+0xb1>
	return (void *)(pa + KERNBASE);
f0103766:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
        size = PGSIZE;
f010376c:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
        if (i == 0) {
f0103772:	85 f6                	test   %esi,%esi
f0103774:	75 0f                	jne    f0103785 <env_create+0x14f>
            dst = dst + PGOFF(va);
f0103776:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
f010377c:	01 c8                	add    %ecx,%eax
            size -= PGOFF(va);
f010377e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103783:	29 ca                	sub    %ecx,%edx
        if (last >= 1) {
f0103785:	85 ff                	test   %edi,%edi
f0103787:	0f 85 6c ff ff ff    	jne    f01036f9 <env_create+0xc3>
        src = (void *)(offset + i);
f010378d:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
f0103793:	01 f1                	add    %esi,%ecx
        if (i + size > f_len) {
f0103795:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
f0103798:	39 9d 5c ff ff ff    	cmp    %ebx,-0xa4(%ebp)
f010379e:	0f 83 59 ff ff ff    	jae    f01036fd <env_create+0xc7>
            memcpy(dst, src, f_len - i);
f01037a4:	83 ec 04             	sub    $0x4,%esp
f01037a7:	8b 95 5c ff ff ff    	mov    -0xa4(%ebp),%edx
f01037ad:	29 f2                	sub    %esi,%edx
f01037af:	52                   	push   %edx
f01037b0:	51                   	push   %ecx
f01037b1:	50                   	push   %eax
f01037b2:	e8 e6 23 00 00       	call   f0105b9d <memcpy>
f01037b7:	83 c4 10             	add    $0x10,%esp
            last += 1;
f01037ba:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
        i += size;
f01037c0:	89 de                	mov    %ebx,%esi
f01037c2:	e9 46 ff ff ff       	jmp    f010370d <env_create+0xd7>
        ph += 1;
f01037c7:	83 85 4c ff ff ff 20 	addl   $0x20,-0xb4(%ebp)
    for (int i=0; i < ph_num; i++) {
f01037ce:	83 85 48 ff ff ff 01 	addl   $0x1,-0xb8(%ebp)
f01037d5:	8b bd 48 ff ff ff    	mov    -0xb8(%ebp),%edi
f01037db:	39 bd 3c ff ff ff    	cmp    %edi,-0xc4(%ebp)
f01037e1:	74 68                	je     f010384b <env_create+0x215>
        if (ph->p_type == ELF_PROG_LOAD) {
f01037e3:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
f01037e9:	8b 00                	mov    (%eax),%eax
f01037eb:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
f01037f1:	83 f8 01             	cmp    $0x1,%eax
f01037f4:	75 d1                	jne    f01037c7 <env_create+0x191>
            region_alloc(e, (void *) ph->p_va, ph->p_memsz, ph->p_filesz, (uint32_t) binary + ph->p_offset);
f01037f6:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
f01037fc:	8b bd 38 ff ff ff    	mov    -0xc8(%ebp),%edi
f0103802:	03 78 04             	add    0x4(%eax),%edi
f0103805:	89 bd 50 ff ff ff    	mov    %edi,-0xb0(%ebp)
f010380b:	8b 78 10             	mov    0x10(%eax),%edi
f010380e:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
f0103814:	8b 50 08             	mov    0x8(%eax),%edx
f0103817:	89 95 58 ff ff ff    	mov    %edx,-0xa8(%ebp)
    len = ROUNDUP(len, PGSIZE);
f010381d:	8b 40 14             	mov    0x14(%eax),%eax
f0103820:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103825:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010382a:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
    last = 0;
f0103830:	bf 00 00 00 00       	mov    $0x0,%edi
    for (i=0; i < len; ) {
f0103835:	be 00 00 00 00       	mov    $0x0,%esi
            dst = dst + PGOFF(va);
f010383a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0103840:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
f0103846:	e9 c2 fe ff ff       	jmp    f010370d <env_create+0xd7>
f010384b:	8b bd 60 ff ff ff    	mov    -0xa0(%ebp),%edi
    e->env_tf.tf_eip = elf->e_entry;
f0103851:	8b 45 08             	mov    0x8(%ebp),%eax
f0103854:	8b 40 18             	mov    0x18(%eax),%eax
f0103857:	89 47 30             	mov    %eax,0x30(%edi)
    if ((pp = page_alloc(1)) == NULL)
f010385a:	83 ec 0c             	sub    $0xc,%esp
f010385d:	6a 01                	push   $0x1
f010385f:	e8 65 d7 ff ff       	call   f0100fc9 <page_alloc>
f0103864:	83 c4 10             	add    $0x10,%esp
f0103867:	85 c0                	test   %eax,%eax
f0103869:	74 25                	je     f0103890 <env_create+0x25a>
    if ((page_insert(e->env_pgdir, pp, (void *)(USTACKTOP - PGSIZE), PTE_W | PTE_U)) != 0)
f010386b:	6a 06                	push   $0x6
f010386d:	68 00 d0 bf ee       	push   $0xeebfd000
f0103872:	50                   	push   %eax
f0103873:	ff 77 60             	pushl  0x60(%edi)
f0103876:	e8 ed dc ff ff       	call   f0101568 <page_insert>
f010387b:	83 c4 10             	add    $0x10,%esp
f010387e:	85 c0                	test   %eax,%eax
f0103880:	75 24                	jne    f01038a6 <env_create+0x270>

    load_icode(env_p, binary);

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
    if (type == ENV_TYPE_FS) {
f0103882:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103886:	74 35                	je     f01038bd <env_create+0x287>
        env_p->env_tf.tf_eflags |= FL_IOPL_3;
    }
}
f0103888:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010388b:	5b                   	pop    %ebx
f010388c:	5e                   	pop    %esi
f010388d:	5f                   	pop    %edi
f010388e:	5d                   	pop    %ebp
f010388f:	c3                   	ret    
        panic("page_alloc fail %e\n", pp);
f0103890:	6a 00                	push   $0x0
f0103892:	68 67 7b 10 f0       	push   $0xf0107b67
f0103897:	68 99 01 00 00       	push   $0x199
f010389c:	68 3a 7b 10 f0       	push   $0xf0107b3a
f01038a1:	e8 9a c7 ff ff       	call   f0100040 <_panic>
        panic("page insert error");
f01038a6:	83 ec 04             	sub    $0x4,%esp
f01038a9:	68 7b 7b 10 f0       	push   $0xf0107b7b
f01038ae:	68 9b 01 00 00       	push   $0x19b
f01038b3:	68 3a 7b 10 f0       	push   $0xf0107b3a
f01038b8:	e8 83 c7 ff ff       	call   f0100040 <_panic>
        env_p->env_tf.tf_eflags |= FL_IOPL_3;
f01038bd:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
f01038c3:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f01038ca:	eb bc                	jmp    f0103888 <env_create+0x252>

f01038cc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01038cc:	55                   	push   %ebp
f01038cd:	89 e5                	mov    %esp,%ebp
f01038cf:	57                   	push   %edi
f01038d0:	56                   	push   %esi
f01038d1:	53                   	push   %ebx
f01038d2:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01038d5:	e8 31 28 00 00       	call   f010610b <cpunum>
f01038da:	6b c0 74             	imul   $0x74,%eax,%eax
f01038dd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01038e4:	8b 55 08             	mov    0x8(%ebp),%edx
f01038e7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038ea:	39 90 28 60 21 f0    	cmp    %edx,-0xfde9fd8(%eax)
f01038f0:	0f 85 b2 00 00 00    	jne    f01039a8 <env_free+0xdc>
		lcr3(PADDR(kern_pgdir));
f01038f6:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01038fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103900:	76 17                	jbe    f0103919 <env_free+0x4d>
	return (physaddr_t)kva - KERNBASE;
f0103902:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103907:	0f 22 d8             	mov    %eax,%cr3
f010390a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103911:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103914:	e9 8f 00 00 00       	jmp    f01039a8 <env_free+0xdc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103919:	50                   	push   %eax
f010391a:	68 88 67 10 f0       	push   $0xf0106788
f010391f:	68 c5 01 00 00       	push   $0x1c5
f0103924:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0103929:	e8 12 c7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010392e:	50                   	push   %eax
f010392f:	68 64 67 10 f0       	push   $0xf0106764
f0103934:	68 d4 01 00 00       	push   $0x1d4
f0103939:	68 3a 7b 10 f0       	push   $0xf0107b3a
f010393e:	e8 fd c6 ff ff       	call   f0100040 <_panic>
f0103943:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103946:	39 de                	cmp    %ebx,%esi
f0103948:	74 21                	je     f010396b <env_free+0x9f>
			if (pt[pteno] & PTE_P)
f010394a:	f6 03 01             	testb  $0x1,(%ebx)
f010394d:	74 f4                	je     f0103943 <env_free+0x77>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010394f:	83 ec 08             	sub    $0x8,%esp
f0103952:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103955:	01 d8                	add    %ebx,%eax
f0103957:	c1 e0 0a             	shl    $0xa,%eax
f010395a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010395d:	50                   	push   %eax
f010395e:	ff 77 60             	pushl  0x60(%edi)
f0103961:	e8 ba db ff ff       	call   f0101520 <page_remove>
f0103966:	83 c4 10             	add    $0x10,%esp
f0103969:	eb d8                	jmp    f0103943 <env_free+0x77>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010396b:	8b 47 60             	mov    0x60(%edi),%eax
f010396e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103971:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103978:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010397b:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0103981:	73 6a                	jae    f01039ed <env_free+0x121>
		page_decref(pa2page(pa));
f0103983:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103986:	a1 90 5e 21 f0       	mov    0xf0215e90,%eax
f010398b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010398e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103991:	50                   	push   %eax
f0103992:	e8 f4 d6 ff ff       	call   f010108b <page_decref>
f0103997:	83 c4 10             	add    $0x10,%esp
f010399a:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010399e:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039a1:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01039a6:	74 59                	je     f0103a01 <env_free+0x135>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01039a8:	8b 47 60             	mov    0x60(%edi),%eax
f01039ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039ae:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01039b1:	a8 01                	test   $0x1,%al
f01039b3:	74 e5                	je     f010399a <env_free+0xce>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01039b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01039ba:	89 c2                	mov    %eax,%edx
f01039bc:	c1 ea 0c             	shr    $0xc,%edx
f01039bf:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01039c2:	39 15 88 5e 21 f0    	cmp    %edx,0xf0215e88
f01039c8:	0f 86 60 ff ff ff    	jbe    f010392e <env_free+0x62>
	return (void *)(pa + KERNBASE);
f01039ce:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01039d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039d7:	c1 e2 14             	shl    $0x14,%edx
f01039da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01039dd:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f01039e3:	f7 d8                	neg    %eax
f01039e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01039e8:	e9 5d ff ff ff       	jmp    f010394a <env_free+0x7e>
		panic("pa2page called with invalid pa");
f01039ed:	83 ec 04             	sub    $0x4,%esp
f01039f0:	68 58 6f 10 f0       	push   $0xf0106f58
f01039f5:	6a 51                	push   $0x51
f01039f7:	68 c1 77 10 f0       	push   $0xf01077c1
f01039fc:	e8 3f c6 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103a01:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a04:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a07:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a0c:	76 52                	jbe    f0103a60 <env_free+0x194>
	e->env_pgdir = 0;
f0103a0e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a11:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103a18:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103a1d:	c1 e8 0c             	shr    $0xc,%eax
f0103a20:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0103a26:	73 4d                	jae    f0103a75 <env_free+0x1a9>
	page_decref(pa2page(pa));
f0103a28:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a2b:	8b 15 90 5e 21 f0    	mov    0xf0215e90,%edx
f0103a31:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103a34:	50                   	push   %eax
f0103a35:	e8 51 d6 ff ff       	call   f010108b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a3d:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103a44:	a1 4c 52 21 f0       	mov    0xf021524c,%eax
f0103a49:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a4c:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103a4f:	89 15 4c 52 21 f0    	mov    %edx,0xf021524c
}
f0103a55:	83 c4 10             	add    $0x10,%esp
f0103a58:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a5b:	5b                   	pop    %ebx
f0103a5c:	5e                   	pop    %esi
f0103a5d:	5f                   	pop    %edi
f0103a5e:	5d                   	pop    %ebp
f0103a5f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a60:	50                   	push   %eax
f0103a61:	68 88 67 10 f0       	push   $0xf0106788
f0103a66:	68 e2 01 00 00       	push   $0x1e2
f0103a6b:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0103a70:	e8 cb c5 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0103a75:	83 ec 04             	sub    $0x4,%esp
f0103a78:	68 58 6f 10 f0       	push   $0xf0106f58
f0103a7d:	6a 51                	push   $0x51
f0103a7f:	68 c1 77 10 f0       	push   $0xf01077c1
f0103a84:	e8 b7 c5 ff ff       	call   f0100040 <_panic>

f0103a89 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103a89:	55                   	push   %ebp
f0103a8a:	89 e5                	mov    %esp,%ebp
f0103a8c:	53                   	push   %ebx
f0103a8d:	83 ec 04             	sub    $0x4,%esp
f0103a90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103a93:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103a97:	74 21                	je     f0103aba <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103a99:	83 ec 0c             	sub    $0xc,%esp
f0103a9c:	53                   	push   %ebx
f0103a9d:	e8 2a fe ff ff       	call   f01038cc <env_free>

	if (curenv == e) {
f0103aa2:	e8 64 26 00 00       	call   f010610b <cpunum>
f0103aa7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aaa:	83 c4 10             	add    $0x10,%esp
f0103aad:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f0103ab3:	74 1e                	je     f0103ad3 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f0103ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ab8:	c9                   	leave  
f0103ab9:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103aba:	e8 4c 26 00 00       	call   f010610b <cpunum>
f0103abf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac2:	39 98 28 60 21 f0    	cmp    %ebx,-0xfde9fd8(%eax)
f0103ac8:	74 cf                	je     f0103a99 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103aca:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ad1:	eb e2                	jmp    f0103ab5 <env_destroy+0x2c>
		curenv = NULL;
f0103ad3:	e8 33 26 00 00       	call   f010610b <cpunum>
f0103ad8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103adb:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f0103ae2:	00 00 00 
		sched_yield();
f0103ae5:	e8 34 0d 00 00       	call   f010481e <sched_yield>

f0103aea <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103aea:	55                   	push   %ebp
f0103aeb:	89 e5                	mov    %esp,%ebp
f0103aed:	53                   	push   %ebx
f0103aee:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103af1:	e8 15 26 00 00       	call   f010610b <cpunum>
f0103af6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103af9:	8b 98 28 60 21 f0    	mov    -0xfde9fd8(%eax),%ebx
f0103aff:	e8 07 26 00 00       	call   f010610b <cpunum>
f0103b04:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103b07:	8b 65 08             	mov    0x8(%ebp),%esp
f0103b0a:	61                   	popa   
f0103b0b:	07                   	pop    %es
f0103b0c:	1f                   	pop    %ds
f0103b0d:	83 c4 08             	add    $0x8,%esp
f0103b10:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103b11:	83 ec 04             	sub    $0x4,%esp
f0103b14:	68 8d 7b 10 f0       	push   $0xf0107b8d
f0103b19:	68 19 02 00 00       	push   $0x219
f0103b1e:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0103b23:	e8 18 c5 ff ff       	call   f0100040 <_panic>

f0103b28 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103b28:	55                   	push   %ebp
f0103b29:	89 e5                	mov    %esp,%ebp
f0103b2b:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
    if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0103b2e:	e8 d8 25 00 00       	call   f010610b <cpunum>
f0103b33:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b36:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0103b3d:	74 14                	je     f0103b53 <env_run+0x2b>
f0103b3f:	e8 c7 25 00 00       	call   f010610b <cpunum>
f0103b44:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b47:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103b4d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103b51:	74 68                	je     f0103bbb <env_run+0x93>
        curenv->env_status = ENV_RUNNABLE;
    }

    curenv = e;
f0103b53:	e8 b3 25 00 00       	call   f010610b <cpunum>
f0103b58:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b5b:	8b 55 08             	mov    0x8(%ebp),%edx
f0103b5e:	89 90 28 60 21 f0    	mov    %edx,-0xfde9fd8(%eax)
    curenv->env_status = ENV_RUNNING;
f0103b64:	e8 a2 25 00 00       	call   f010610b <cpunum>
f0103b69:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6c:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103b72:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    curenv->env_runs = 0;
f0103b79:	e8 8d 25 00 00       	call   f010610b <cpunum>
f0103b7e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b81:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103b87:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
    lcr3(PADDR(curenv->env_pgdir));
f0103b8e:	e8 78 25 00 00       	call   f010610b <cpunum>
f0103b93:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b96:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103b9c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103b9f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ba4:	77 2c                	ja     f0103bd2 <env_run+0xaa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ba6:	50                   	push   %eax
f0103ba7:	68 88 67 10 f0       	push   $0xf0106788
f0103bac:	68 3e 02 00 00       	push   $0x23e
f0103bb1:	68 3a 7b 10 f0       	push   $0xf0107b3a
f0103bb6:	e8 85 c4 ff ff       	call   f0100040 <_panic>
        curenv->env_status = ENV_RUNNABLE;
f0103bbb:	e8 4b 25 00 00       	call   f010610b <cpunum>
f0103bc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bc3:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0103bc9:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103bd0:	eb 81                	jmp    f0103b53 <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f0103bd2:	05 00 00 00 10       	add    $0x10000000,%eax
f0103bd7:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103bda:	83 ec 0c             	sub    $0xc,%esp
f0103bdd:	68 e0 27 12 f0       	push   $0xf01227e0
f0103be2:	e8 31 28 00 00       	call   f0106418 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103be7:	f3 90                	pause  

    unlock_kernel();
    env_pop_tf(&curenv->env_tf);
f0103be9:	e8 1d 25 00 00       	call   f010610b <cpunum>
f0103bee:	83 c4 04             	add    $0x4,%esp
f0103bf1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf4:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0103bfa:	e8 eb fe ff ff       	call   f0103aea <env_pop_tf>

f0103bff <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103bff:	55                   	push   %ebp
f0103c00:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c02:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c05:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c0a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103c0b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c10:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103c11:	0f b6 c0             	movzbl %al,%eax
}
f0103c14:	5d                   	pop    %ebp
f0103c15:	c3                   	ret    

f0103c16 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103c16:	55                   	push   %ebp
f0103c17:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103c19:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c1c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103c21:	ee                   	out    %al,(%dx)
f0103c22:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c25:	ba 71 00 00 00       	mov    $0x71,%edx
f0103c2a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103c2b:	5d                   	pop    %ebp
f0103c2c:	c3                   	ret    

f0103c2d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103c2d:	55                   	push   %ebp
f0103c2e:	89 e5                	mov    %esp,%ebp
f0103c30:	56                   	push   %esi
f0103c31:	53                   	push   %ebx
f0103c32:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103c35:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0103c3b:	80 3d 50 52 21 f0 00 	cmpb   $0x0,0xf0215250
f0103c42:	75 07                	jne    f0103c4b <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c47:	5b                   	pop    %ebx
f0103c48:	5e                   	pop    %esi
f0103c49:	5d                   	pop    %ebp
f0103c4a:	c3                   	ret    
f0103c4b:	89 c6                	mov    %eax,%esi
f0103c4d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103c52:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103c53:	66 c1 e8 08          	shr    $0x8,%ax
f0103c57:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103c5c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103c5d:	83 ec 0c             	sub    $0xc,%esp
f0103c60:	68 99 7b 10 f0       	push   $0xf0107b99
f0103c65:	e8 1e 01 00 00       	call   f0103d88 <cprintf>
f0103c6a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103c72:	0f b7 f6             	movzwl %si,%esi
f0103c75:	f7 d6                	not    %esi
f0103c77:	eb 08                	jmp    f0103c81 <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f0103c79:	83 c3 01             	add    $0x1,%ebx
f0103c7c:	83 fb 10             	cmp    $0x10,%ebx
f0103c7f:	74 18                	je     f0103c99 <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103c81:	0f a3 de             	bt     %ebx,%esi
f0103c84:	73 f3                	jae    f0103c79 <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f0103c86:	83 ec 08             	sub    $0x8,%esp
f0103c89:	53                   	push   %ebx
f0103c8a:	68 6b 80 10 f0       	push   $0xf010806b
f0103c8f:	e8 f4 00 00 00       	call   f0103d88 <cprintf>
f0103c94:	83 c4 10             	add    $0x10,%esp
f0103c97:	eb e0                	jmp    f0103c79 <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103c99:	83 ec 0c             	sub    $0xc,%esp
f0103c9c:	68 ec 78 10 f0       	push   $0xf01078ec
f0103ca1:	e8 e2 00 00 00       	call   f0103d88 <cprintf>
f0103ca6:	83 c4 10             	add    $0x10,%esp
f0103ca9:	eb 99                	jmp    f0103c44 <irq_setmask_8259A+0x17>

f0103cab <pic_init>:
{
f0103cab:	55                   	push   %ebp
f0103cac:	89 e5                	mov    %esp,%ebp
f0103cae:	57                   	push   %edi
f0103caf:	56                   	push   %esi
f0103cb0:	53                   	push   %ebx
f0103cb1:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103cb4:	c6 05 50 52 21 f0 01 	movb   $0x1,0xf0215250
f0103cbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cc0:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103cc5:	89 da                	mov    %ebx,%edx
f0103cc7:	ee                   	out    %al,(%dx)
f0103cc8:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103ccd:	89 ca                	mov    %ecx,%edx
f0103ccf:	ee                   	out    %al,(%dx)
f0103cd0:	bf 11 00 00 00       	mov    $0x11,%edi
f0103cd5:	be 20 00 00 00       	mov    $0x20,%esi
f0103cda:	89 f8                	mov    %edi,%eax
f0103cdc:	89 f2                	mov    %esi,%edx
f0103cde:	ee                   	out    %al,(%dx)
f0103cdf:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ce4:	89 da                	mov    %ebx,%edx
f0103ce6:	ee                   	out    %al,(%dx)
f0103ce7:	b8 04 00 00 00       	mov    $0x4,%eax
f0103cec:	ee                   	out    %al,(%dx)
f0103ced:	b8 03 00 00 00       	mov    $0x3,%eax
f0103cf2:	ee                   	out    %al,(%dx)
f0103cf3:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103cf8:	89 f8                	mov    %edi,%eax
f0103cfa:	89 da                	mov    %ebx,%edx
f0103cfc:	ee                   	out    %al,(%dx)
f0103cfd:	b8 28 00 00 00       	mov    $0x28,%eax
f0103d02:	89 ca                	mov    %ecx,%edx
f0103d04:	ee                   	out    %al,(%dx)
f0103d05:	b8 02 00 00 00       	mov    $0x2,%eax
f0103d0a:	ee                   	out    %al,(%dx)
f0103d0b:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d10:	ee                   	out    %al,(%dx)
f0103d11:	bf 68 00 00 00       	mov    $0x68,%edi
f0103d16:	89 f8                	mov    %edi,%eax
f0103d18:	89 f2                	mov    %esi,%edx
f0103d1a:	ee                   	out    %al,(%dx)
f0103d1b:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103d20:	89 c8                	mov    %ecx,%eax
f0103d22:	ee                   	out    %al,(%dx)
f0103d23:	89 f8                	mov    %edi,%eax
f0103d25:	89 da                	mov    %ebx,%edx
f0103d27:	ee                   	out    %al,(%dx)
f0103d28:	89 c8                	mov    %ecx,%eax
f0103d2a:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103d2b:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0103d32:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103d36:	74 0f                	je     f0103d47 <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f0103d38:	83 ec 0c             	sub    $0xc,%esp
f0103d3b:	0f b7 c0             	movzwl %ax,%eax
f0103d3e:	50                   	push   %eax
f0103d3f:	e8 e9 fe ff ff       	call   f0103c2d <irq_setmask_8259A>
f0103d44:	83 c4 10             	add    $0x10,%esp
}
f0103d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d4a:	5b                   	pop    %ebx
f0103d4b:	5e                   	pop    %esi
f0103d4c:	5f                   	pop    %edi
f0103d4d:	5d                   	pop    %ebp
f0103d4e:	c3                   	ret    

f0103d4f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103d4f:	55                   	push   %ebp
f0103d50:	89 e5                	mov    %esp,%ebp
f0103d52:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103d55:	ff 75 08             	pushl  0x8(%ebp)
f0103d58:	e8 45 ca ff ff       	call   f01007a2 <cputchar>
	*cnt++;
}
f0103d5d:	83 c4 10             	add    $0x10,%esp
f0103d60:	c9                   	leave  
f0103d61:	c3                   	ret    

f0103d62 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d62:	55                   	push   %ebp
f0103d63:	89 e5                	mov    %esp,%ebp
f0103d65:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d6f:	ff 75 0c             	pushl  0xc(%ebp)
f0103d72:	ff 75 08             	pushl  0x8(%ebp)
f0103d75:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d78:	50                   	push   %eax
f0103d79:	68 4f 3d 10 f0       	push   $0xf0103d4f
f0103d7e:	e8 f2 15 00 00       	call   f0105375 <vprintfmt>
	return cnt;
}
f0103d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d86:	c9                   	leave  
f0103d87:	c3                   	ret    

f0103d88 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d88:	55                   	push   %ebp
f0103d89:	89 e5                	mov    %esp,%ebp
f0103d8b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d8e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d91:	50                   	push   %eax
f0103d92:	ff 75 08             	pushl  0x8(%ebp)
f0103d95:	e8 c8 ff ff ff       	call   f0103d62 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d9a:	c9                   	leave  
f0103d9b:	c3                   	ret    

f0103d9c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d9c:	55                   	push   %ebp
f0103d9d:	89 e5                	mov    %esp,%ebp
f0103d9f:	57                   	push   %edi
f0103da0:	56                   	push   %esi
f0103da1:	53                   	push   %ebx
f0103da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
    thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP) ;
f0103da5:	e8 61 23 00 00       	call   f010610b <cpunum>
f0103daa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dad:	0f b6 98 20 60 21 f0 	movzbl -0xfde9fe0(%eax),%ebx
f0103db4:	c1 e3 10             	shl    $0x10,%ebx
f0103db7:	e8 4f 23 00 00       	call   f010610b <cpunum>
f0103dbc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dbf:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103dc4:	29 da                	sub    %ebx,%edx
f0103dc6:	89 90 30 60 21 f0    	mov    %edx,-0xfde9fd0(%eax)
    thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103dcc:	e8 3a 23 00 00       	call   f010610b <cpunum>
f0103dd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dd4:	66 c7 80 34 60 21 f0 	movw   $0x10,-0xfde9fcc(%eax)
f0103ddb:	10 00 
    thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ddd:	e8 29 23 00 00       	call   f010610b <cpunum>
f0103de2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103de5:	66 c7 80 92 60 21 f0 	movw   $0x68,-0xfde9f6e(%eax)
f0103dec:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103dee:	e8 18 23 00 00       	call   f010610b <cpunum>
f0103df3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df6:	0f b6 98 20 60 21 f0 	movzbl -0xfde9fe0(%eax),%ebx
f0103dfd:	83 c3 05             	add    $0x5,%ebx
f0103e00:	e8 06 23 00 00       	call   f010610b <cpunum>
f0103e05:	89 c7                	mov    %eax,%edi
f0103e07:	e8 ff 22 00 00       	call   f010610b <cpunum>
f0103e0c:	89 c6                	mov    %eax,%esi
f0103e0e:	e8 f8 22 00 00       	call   f010610b <cpunum>
f0103e13:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0103e1a:	f0 67 00 
f0103e1d:	6b ff 74             	imul   $0x74,%edi,%edi
f0103e20:	81 c7 2c 60 21 f0    	add    $0xf021602c,%edi
f0103e26:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f0103e2d:	f0 
f0103e2e:	6b d6 74             	imul   $0x74,%esi,%edx
f0103e31:	81 c2 2c 60 21 f0    	add    $0xf021602c,%edx
f0103e37:	c1 ea 10             	shr    $0x10,%edx
f0103e3a:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0103e41:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0103e48:	99 
f0103e49:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0103e50:	40 
f0103e51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e54:	05 2c 60 21 f0       	add    $0xf021602c,%eax
f0103e59:	c1 e8 18             	shr    $0x18,%eax
f0103e5c:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103e63:	e8 a3 22 00 00       	call   f010610b <cpunum>
f0103e68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e6b:	0f b6 80 20 60 21 f0 	movzbl -0xfde9fe0(%eax),%eax
f0103e72:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f0103e79:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + ((thiscpu->cpu_id) << 3));
f0103e7a:	e8 8c 22 00 00       	call   f010610b <cpunum>
f0103e7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e82:	0f b6 80 20 60 21 f0 	movzbl -0xfde9fe0(%eax),%eax
f0103e89:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103e90:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103e93:	b8 c0 27 12 f0       	mov    $0xf01227c0,%eax
f0103e98:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103e9b:	83 c4 0c             	add    $0xc,%esp
f0103e9e:	5b                   	pop    %ebx
f0103e9f:	5e                   	pop    %esi
f0103ea0:	5f                   	pop    %edi
f0103ea1:	5d                   	pop    %ebp
f0103ea2:	c3                   	ret    

f0103ea3 <trap_init>:
{
f0103ea3:	55                   	push   %ebp
f0103ea4:	89 e5                	mov    %esp,%ebp
f0103ea6:	83 ec 08             	sub    $0x8,%esp
    for(i = 0; i < 20; i++)
f0103ea9:	b8 00 00 00 00       	mov    $0x0,%eax
        SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103eae:	8b 14 85 c0 23 12 f0 	mov    -0xfeddc40(,%eax,4),%edx
f0103eb5:	66 89 14 c5 60 52 21 	mov    %dx,-0xfdeada0(,%eax,8)
f0103ebc:	f0 
f0103ebd:	66 c7 04 c5 62 52 21 	movw   $0x8,-0xfdead9e(,%eax,8)
f0103ec4:	f0 08 00 
f0103ec7:	c6 04 c5 64 52 21 f0 	movb   $0x0,-0xfdead9c(,%eax,8)
f0103ece:	00 
f0103ecf:	c6 04 c5 65 52 21 f0 	movb   $0x8e,-0xfdead9b(,%eax,8)
f0103ed6:	8e 
f0103ed7:	c1 ea 10             	shr    $0x10,%edx
f0103eda:	66 89 14 c5 66 52 21 	mov    %dx,-0xfdead9a(,%eax,8)
f0103ee1:	f0 
    for(i = 0; i < 20; i++)
f0103ee2:	83 c0 01             	add    $0x1,%eax
f0103ee5:	83 f8 14             	cmp    $0x14,%eax
f0103ee8:	75 c4                	jne    f0103eae <trap_init+0xb>
        SETGATE(idt[i], 0, GD_KT, vectors[9], 0);
f0103eea:	8b 15 e4 23 12 f0    	mov    0xf01223e4,%edx
f0103ef0:	89 d1                	mov    %edx,%ecx
f0103ef2:	c1 ea 10             	shr    $0x10,%edx
f0103ef5:	66 89 0c c5 60 52 21 	mov    %cx,-0xfdeada0(,%eax,8)
f0103efc:	f0 
f0103efd:	66 c7 04 c5 62 52 21 	movw   $0x8,-0xfdead9e(,%eax,8)
f0103f04:	f0 08 00 
f0103f07:	c6 04 c5 64 52 21 f0 	movb   $0x0,-0xfdead9c(,%eax,8)
f0103f0e:	00 
f0103f0f:	c6 04 c5 65 52 21 f0 	movb   $0x8e,-0xfdead9b(,%eax,8)
f0103f16:	8e 
f0103f17:	66 89 14 c5 66 52 21 	mov    %dx,-0xfdead9a(,%eax,8)
f0103f1e:	f0 
    for(i = 20; i < 256; i++)
f0103f1f:	83 c0 01             	add    $0x1,%eax
f0103f22:	3d 00 01 00 00       	cmp    $0x100,%eax
f0103f27:	75 cc                	jne    f0103ef5 <trap_init+0x52>
    for(i = IRQ_OFFSET; i < IRQ_OFFSET + 16; i++)
f0103f29:	b8 20 00 00 00       	mov    $0x20,%eax
        SETGATE(idt[i], 0, GD_KT, vectors[i], 0);
f0103f2e:	8b 14 85 c0 23 12 f0 	mov    -0xfeddc40(,%eax,4),%edx
f0103f35:	66 89 14 c5 60 52 21 	mov    %dx,-0xfdeada0(,%eax,8)
f0103f3c:	f0 
f0103f3d:	66 c7 04 c5 62 52 21 	movw   $0x8,-0xfdead9e(,%eax,8)
f0103f44:	f0 08 00 
f0103f47:	c6 04 c5 64 52 21 f0 	movb   $0x0,-0xfdead9c(,%eax,8)
f0103f4e:	00 
f0103f4f:	c6 04 c5 65 52 21 f0 	movb   $0x8e,-0xfdead9b(,%eax,8)
f0103f56:	8e 
f0103f57:	c1 ea 10             	shr    $0x10,%edx
f0103f5a:	66 89 14 c5 66 52 21 	mov    %dx,-0xfdead9a(,%eax,8)
f0103f61:	f0 
    for(i = IRQ_OFFSET; i < IRQ_OFFSET + 16; i++)
f0103f62:	83 c0 01             	add    $0x1,%eax
f0103f65:	83 f8 30             	cmp    $0x30,%eax
f0103f68:	75 c4                	jne    f0103f2e <trap_init+0x8b>
    SETGATE(idt[T_BRKPT], 0, GD_KT, vectors[T_BRKPT], 3);  // breakpoint as a pseudo-system call
f0103f6a:	a1 cc 23 12 f0       	mov    0xf01223cc,%eax
f0103f6f:	66 a3 78 52 21 f0    	mov    %ax,0xf0215278
f0103f75:	66 c7 05 7a 52 21 f0 	movw   $0x8,0xf021527a
f0103f7c:	08 00 
f0103f7e:	c6 05 7c 52 21 f0 00 	movb   $0x0,0xf021527c
f0103f85:	c6 05 7d 52 21 f0 ee 	movb   $0xee,0xf021527d
f0103f8c:	c1 e8 10             	shr    $0x10,%eax
f0103f8f:	66 a3 7e 52 21 f0    	mov    %ax,0xf021527e
    SETGATE(idt[T_SYSCALL], 0, GD_KT, vectors[T_SYSCALL], 3);
f0103f95:	a1 80 24 12 f0       	mov    0xf0122480,%eax
f0103f9a:	66 a3 e0 53 21 f0    	mov    %ax,0xf02153e0
f0103fa0:	66 c7 05 e2 53 21 f0 	movw   $0x8,0xf02153e2
f0103fa7:	08 00 
f0103fa9:	c6 05 e4 53 21 f0 00 	movb   $0x0,0xf02153e4
f0103fb0:	c6 05 e5 53 21 f0 ee 	movb   $0xee,0xf02153e5
f0103fb7:	c1 e8 10             	shr    $0x10,%eax
f0103fba:	66 a3 e6 53 21 f0    	mov    %ax,0xf02153e6
	trap_init_percpu();
f0103fc0:	e8 d7 fd ff ff       	call   f0103d9c <trap_init_percpu>
}
f0103fc5:	c9                   	leave  
f0103fc6:	c3                   	ret    

f0103fc7 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103fc7:	55                   	push   %ebp
f0103fc8:	89 e5                	mov    %esp,%ebp
f0103fca:	53                   	push   %ebx
f0103fcb:	83 ec 0c             	sub    $0xc,%esp
f0103fce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103fd1:	ff 33                	pushl  (%ebx)
f0103fd3:	68 ad 7b 10 f0       	push   $0xf0107bad
f0103fd8:	e8 ab fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103fdd:	83 c4 08             	add    $0x8,%esp
f0103fe0:	ff 73 04             	pushl  0x4(%ebx)
f0103fe3:	68 bc 7b 10 f0       	push   $0xf0107bbc
f0103fe8:	e8 9b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103fed:	83 c4 08             	add    $0x8,%esp
f0103ff0:	ff 73 08             	pushl  0x8(%ebx)
f0103ff3:	68 cb 7b 10 f0       	push   $0xf0107bcb
f0103ff8:	e8 8b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103ffd:	83 c4 08             	add    $0x8,%esp
f0104000:	ff 73 0c             	pushl  0xc(%ebx)
f0104003:	68 da 7b 10 f0       	push   $0xf0107bda
f0104008:	e8 7b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010400d:	83 c4 08             	add    $0x8,%esp
f0104010:	ff 73 10             	pushl  0x10(%ebx)
f0104013:	68 e9 7b 10 f0       	push   $0xf0107be9
f0104018:	e8 6b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010401d:	83 c4 08             	add    $0x8,%esp
f0104020:	ff 73 14             	pushl  0x14(%ebx)
f0104023:	68 f8 7b 10 f0       	push   $0xf0107bf8
f0104028:	e8 5b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010402d:	83 c4 08             	add    $0x8,%esp
f0104030:	ff 73 18             	pushl  0x18(%ebx)
f0104033:	68 07 7c 10 f0       	push   $0xf0107c07
f0104038:	e8 4b fd ff ff       	call   f0103d88 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010403d:	83 c4 08             	add    $0x8,%esp
f0104040:	ff 73 1c             	pushl  0x1c(%ebx)
f0104043:	68 16 7c 10 f0       	push   $0xf0107c16
f0104048:	e8 3b fd ff ff       	call   f0103d88 <cprintf>
}
f010404d:	83 c4 10             	add    $0x10,%esp
f0104050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104053:	c9                   	leave  
f0104054:	c3                   	ret    

f0104055 <print_trapframe>:
{
f0104055:	55                   	push   %ebp
f0104056:	89 e5                	mov    %esp,%ebp
f0104058:	56                   	push   %esi
f0104059:	53                   	push   %ebx
f010405a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010405d:	e8 a9 20 00 00       	call   f010610b <cpunum>
f0104062:	83 ec 04             	sub    $0x4,%esp
f0104065:	50                   	push   %eax
f0104066:	53                   	push   %ebx
f0104067:	68 7a 7c 10 f0       	push   $0xf0107c7a
f010406c:	e8 17 fd ff ff       	call   f0103d88 <cprintf>
	print_regs(&tf->tf_regs);
f0104071:	89 1c 24             	mov    %ebx,(%esp)
f0104074:	e8 4e ff ff ff       	call   f0103fc7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104079:	83 c4 08             	add    $0x8,%esp
f010407c:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104080:	50                   	push   %eax
f0104081:	68 98 7c 10 f0       	push   $0xf0107c98
f0104086:	e8 fd fc ff ff       	call   f0103d88 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010408b:	83 c4 08             	add    $0x8,%esp
f010408e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104092:	50                   	push   %eax
f0104093:	68 ab 7c 10 f0       	push   $0xf0107cab
f0104098:	e8 eb fc ff ff       	call   f0103d88 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010409d:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01040a0:	83 c4 10             	add    $0x10,%esp
f01040a3:	83 f8 13             	cmp    $0x13,%eax
f01040a6:	76 1f                	jbe    f01040c7 <print_trapframe+0x72>
		return "System call";
f01040a8:	ba 25 7c 10 f0       	mov    $0xf0107c25,%edx
	if (trapno == T_SYSCALL)
f01040ad:	83 f8 30             	cmp    $0x30,%eax
f01040b0:	74 1c                	je     f01040ce <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01040b2:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f01040b5:	83 fa 10             	cmp    $0x10,%edx
f01040b8:	ba 31 7c 10 f0       	mov    $0xf0107c31,%edx
f01040bd:	b9 44 7c 10 f0       	mov    $0xf0107c44,%ecx
f01040c2:	0f 43 d1             	cmovae %ecx,%edx
f01040c5:	eb 07                	jmp    f01040ce <print_trapframe+0x79>
		return excnames[trapno];
f01040c7:	8b 14 85 80 7f 10 f0 	mov    -0xfef8080(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01040ce:	83 ec 04             	sub    $0x4,%esp
f01040d1:	52                   	push   %edx
f01040d2:	50                   	push   %eax
f01040d3:	68 be 7c 10 f0       	push   $0xf0107cbe
f01040d8:	e8 ab fc ff ff       	call   f0103d88 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040dd:	83 c4 10             	add    $0x10,%esp
f01040e0:	39 1d 60 5a 21 f0    	cmp    %ebx,0xf0215a60
f01040e6:	0f 84 a6 00 00 00    	je     f0104192 <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f01040ec:	83 ec 08             	sub    $0x8,%esp
f01040ef:	ff 73 2c             	pushl  0x2c(%ebx)
f01040f2:	68 df 7c 10 f0       	push   $0xf0107cdf
f01040f7:	e8 8c fc ff ff       	call   f0103d88 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01040fc:	83 c4 10             	add    $0x10,%esp
f01040ff:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104103:	0f 85 ac 00 00 00    	jne    f01041b5 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104109:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010410c:	89 c2                	mov    %eax,%edx
f010410e:	83 e2 01             	and    $0x1,%edx
f0104111:	b9 53 7c 10 f0       	mov    $0xf0107c53,%ecx
f0104116:	ba 5e 7c 10 f0       	mov    $0xf0107c5e,%edx
f010411b:	0f 44 ca             	cmove  %edx,%ecx
f010411e:	89 c2                	mov    %eax,%edx
f0104120:	83 e2 02             	and    $0x2,%edx
f0104123:	be 6a 7c 10 f0       	mov    $0xf0107c6a,%esi
f0104128:	ba 70 7c 10 f0       	mov    $0xf0107c70,%edx
f010412d:	0f 45 d6             	cmovne %esi,%edx
f0104130:	83 e0 04             	and    $0x4,%eax
f0104133:	b8 75 7c 10 f0       	mov    $0xf0107c75,%eax
f0104138:	be bf 7d 10 f0       	mov    $0xf0107dbf,%esi
f010413d:	0f 44 c6             	cmove  %esi,%eax
f0104140:	51                   	push   %ecx
f0104141:	52                   	push   %edx
f0104142:	50                   	push   %eax
f0104143:	68 ed 7c 10 f0       	push   $0xf0107ced
f0104148:	e8 3b fc ff ff       	call   f0103d88 <cprintf>
f010414d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104150:	83 ec 08             	sub    $0x8,%esp
f0104153:	ff 73 30             	pushl  0x30(%ebx)
f0104156:	68 fc 7c 10 f0       	push   $0xf0107cfc
f010415b:	e8 28 fc ff ff       	call   f0103d88 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104160:	83 c4 08             	add    $0x8,%esp
f0104163:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104167:	50                   	push   %eax
f0104168:	68 0b 7d 10 f0       	push   $0xf0107d0b
f010416d:	e8 16 fc ff ff       	call   f0103d88 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104172:	83 c4 08             	add    $0x8,%esp
f0104175:	ff 73 38             	pushl  0x38(%ebx)
f0104178:	68 1e 7d 10 f0       	push   $0xf0107d1e
f010417d:	e8 06 fc ff ff       	call   f0103d88 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104182:	83 c4 10             	add    $0x10,%esp
f0104185:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104189:	75 3c                	jne    f01041c7 <print_trapframe+0x172>
}
f010418b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010418e:	5b                   	pop    %ebx
f010418f:	5e                   	pop    %esi
f0104190:	5d                   	pop    %ebp
f0104191:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104192:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104196:	0f 85 50 ff ff ff    	jne    f01040ec <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010419c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010419f:	83 ec 08             	sub    $0x8,%esp
f01041a2:	50                   	push   %eax
f01041a3:	68 d0 7c 10 f0       	push   $0xf0107cd0
f01041a8:	e8 db fb ff ff       	call   f0103d88 <cprintf>
f01041ad:	83 c4 10             	add    $0x10,%esp
f01041b0:	e9 37 ff ff ff       	jmp    f01040ec <print_trapframe+0x97>
		cprintf("\n");
f01041b5:	83 ec 0c             	sub    $0xc,%esp
f01041b8:	68 ec 78 10 f0       	push   $0xf01078ec
f01041bd:	e8 c6 fb ff ff       	call   f0103d88 <cprintf>
f01041c2:	83 c4 10             	add    $0x10,%esp
f01041c5:	eb 89                	jmp    f0104150 <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01041c7:	83 ec 08             	sub    $0x8,%esp
f01041ca:	ff 73 3c             	pushl  0x3c(%ebx)
f01041cd:	68 2d 7d 10 f0       	push   $0xf0107d2d
f01041d2:	e8 b1 fb ff ff       	call   f0103d88 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01041d7:	83 c4 08             	add    $0x8,%esp
f01041da:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01041de:	50                   	push   %eax
f01041df:	68 3c 7d 10 f0       	push   $0xf0107d3c
f01041e4:	e8 9f fb ff ff       	call   f0103d88 <cprintf>
f01041e9:	83 c4 10             	add    $0x10,%esp
}
f01041ec:	eb 9d                	jmp    f010418b <print_trapframe+0x136>

f01041ee <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01041ee:	55                   	push   %ebp
f01041ef:	89 e5                	mov    %esp,%ebp
f01041f1:	57                   	push   %edi
f01041f2:	56                   	push   %esi
f01041f3:	53                   	push   %ebx
f01041f4:	83 ec 4c             	sub    $0x4c,%esp
f01041f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01041fa:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    if ((tf->tf_cs & 3) != 3) {
f01041fd:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104201:	83 e0 03             	and    $0x3,%eax
f0104204:	66 83 f8 03          	cmp    $0x3,%ax
f0104208:	0f 85 a0 00 00 00    	jne    f01042ae <page_fault_handler+0xc0>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
    if (curenv->env_pgfault_upcall != NULL) {
f010420e:	e8 f8 1e 00 00       	call   f010610b <cpunum>
f0104213:	6b c0 74             	imul   $0x74,%eax,%eax
f0104216:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f010421c:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104220:	74 43                	je     f0104265 <page_fault_handler+0x77>
        int recur;
        uintptr_t esp_addr;
        recur = tf->tf_esp >= UXSTACKTOP - PGSIZE ? 1 : 0;
f0104222:	8b 73 3c             	mov    0x3c(%ebx),%esi
        // push an UTrapframe on user-expression-stack
        struct UTrapframe utf = {};
        utf.utf_fault_va = fault_va;
        utf.utf_err = tf->tf_err;
        utf.utf_regs = tf->tf_regs;
        utf.utf_eip = tf->tf_eip;
f0104225:	8b 43 30             	mov    0x30(%ebx),%eax
f0104228:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        utf.utf_eflags = tf->tf_eflags;
        utf.utf_esp = tf->tf_esp;

        esp_addr = tf->tf_esp;
        if (!recur) {
f010422b:	81 fe ff ef bf ee    	cmp    $0xeebfefff,%esi
f0104231:	0f 87 8c 00 00 00    	ja     f01042c3 <page_fault_handler+0xd5>
            // user stack left a word check
            if (esp_addr < USTACKTOP - PGSIZE + 4) {
f0104237:	81 fe 03 d0 bf ee    	cmp    $0xeebfd003,%esi
f010423d:	0f 87 71 01 00 00    	ja     f01043b4 <page_fault_handler+0x1c6>
                cprintf("[%08x] user stack left not a word, eip: %08x, esp: %08x\n", curenv->env_id, tf->tf_eip, esp_addr);
f0104243:	e8 c3 1e 00 00       	call   f010610b <cpunum>
f0104248:	56                   	push   %esi
f0104249:	ff 75 e4             	pushl  -0x1c(%ebp)
f010424c:	6b c0 74             	imul   $0x74,%eax,%eax
f010424f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104255:	ff 70 48             	pushl  0x48(%eax)
f0104258:	68 0c 7f 10 f0       	push   $0xf0107f0c
f010425d:	e8 26 fb ff ff       	call   f0103d88 <cprintf>
f0104262:	83 c4 10             	add    $0x10,%esp
        env_run(curenv);
    }

	// Destroy the environment that caused the fault.
    destroy:
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104265:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104268:	e8 9e 1e 00 00       	call   f010610b <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010426d:	56                   	push   %esi
f010426e:	57                   	push   %edi
		curenv->env_id, fault_va, tf->tf_eip);
f010426f:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104272:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104278:	ff 70 48             	pushl  0x48(%eax)
f010427b:	68 48 7f 10 f0       	push   $0xf0107f48
f0104280:	e8 03 fb ff ff       	call   f0103d88 <cprintf>
	print_trapframe(tf);
f0104285:	89 1c 24             	mov    %ebx,(%esp)
f0104288:	e8 c8 fd ff ff       	call   f0104055 <print_trapframe>
	env_destroy(curenv);
f010428d:	e8 79 1e 00 00       	call   f010610b <cpunum>
f0104292:	83 c4 04             	add    $0x4,%esp
f0104295:	6b c0 74             	imul   $0x74,%eax,%eax
f0104298:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f010429e:	e8 e6 f7 ff ff       	call   f0103a89 <env_destroy>
}
f01042a3:	83 c4 10             	add    $0x10,%esp
f01042a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042a9:	5b                   	pop    %ebx
f01042aa:	5e                   	pop    %esi
f01042ab:	5f                   	pop    %edi
f01042ac:	5d                   	pop    %ebp
f01042ad:	c3                   	ret    
        panic("kernel page fault %x", fault_va);
f01042ae:	57                   	push   %edi
f01042af:	68 4f 7d 10 f0       	push   $0xf0107d4f
f01042b4:	68 6e 01 00 00       	push   $0x16e
f01042b9:	68 64 7d 10 f0       	push   $0xf0107d64
f01042be:	e8 7d bd ff ff       	call   f0100040 <_panic>
            esp_addr -= 4;
f01042c3:	8d 46 fc             	lea    -0x4(%esi),%eax
f01042c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        utf.utf_err = tf->tf_err;
f01042c9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01042cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
        utf.utf_regs = tf->tf_regs;
f01042cf:	8b 0b                	mov    (%ebx),%ecx
f01042d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01042d4:	8b 53 04             	mov    0x4(%ebx),%edx
f01042d7:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01042da:	8b 53 08             	mov    0x8(%ebx),%edx
f01042dd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01042e0:	8b 4b 0c             	mov    0xc(%ebx),%ecx
f01042e3:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01042e6:	8b 53 10             	mov    0x10(%ebx),%edx
f01042e9:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01042ec:	8b 53 14             	mov    0x14(%ebx),%edx
f01042ef:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01042f2:	8b 4b 18             	mov    0x18(%ebx),%ecx
f01042f5:	89 4d b4             	mov    %ecx,-0x4c(%ebp)
f01042f8:	8b 53 1c             	mov    0x1c(%ebx),%edx
f01042fb:	89 55 b0             	mov    %edx,-0x50(%ebp)
        utf.utf_eflags = tf->tf_eflags;
f01042fe:	8b 53 38             	mov    0x38(%ebx),%edx
f0104301:	89 55 d4             	mov    %edx,-0x2c(%ebp)
        esp_addr -= sizeof(utf); // make space for utf, let tf_esp point at utf
f0104304:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104307:	8d 50 cc             	lea    -0x34(%eax),%edx
        user_mem_assert(curenv, (void *)esp_addr, ROUNDUP(esp_addr, PGSIZE) - esp_addr, PTE_W | PTE_U | PTE_P);
f010430a:	05 cb 0f 00 00       	add    $0xfcb,%eax
f010430f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104314:	89 c1                	mov    %eax,%ecx
f0104316:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104319:	29 d1                	sub    %edx,%ecx
f010431b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010431e:	e8 e8 1d 00 00       	call   f010610b <cpunum>
f0104323:	6a 07                	push   $0x7
f0104325:	ff 75 d0             	pushl  -0x30(%ebp)
f0104328:	ff 75 dc             	pushl  -0x24(%ebp)
f010432b:	6b c0 74             	imul   $0x74,%eax,%eax
f010432e:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104334:	e8 3e f0 ff ff       	call   f0103377 <user_mem_assert>
        *(struct UTrapframe *)esp_addr = utf;
f0104339:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010433c:	89 78 cc             	mov    %edi,-0x34(%eax)
f010433f:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0104342:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104345:	89 47 04             	mov    %eax,0x4(%edi)
f0104348:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010434b:	89 4f 08             	mov    %ecx,0x8(%edi)
f010434e:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104351:	89 47 0c             	mov    %eax,0xc(%edi)
f0104354:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104357:	89 47 10             	mov    %eax,0x10(%edi)
f010435a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010435d:	89 4f 14             	mov    %ecx,0x14(%edi)
f0104360:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104363:	89 47 18             	mov    %eax,0x18(%edi)
f0104366:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104369:	89 47 1c             	mov    %eax,0x1c(%edi)
f010436c:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010436f:	89 4f 20             	mov    %ecx,0x20(%edi)
f0104372:	8b 45 b0             	mov    -0x50(%ebp),%eax
f0104375:	89 47 24             	mov    %eax,0x24(%edi)
f0104378:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010437b:	89 4f 28             	mov    %ecx,0x28(%edi)
f010437e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104381:	89 47 2c             	mov    %eax,0x2c(%edi)
f0104384:	89 77 30             	mov    %esi,0x30(%edi)
        tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0104387:	e8 7f 1d 00 00       	call   f010610b <cpunum>
f010438c:	6b c0 74             	imul   $0x74,%eax,%eax
f010438f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104395:	8b 40 64             	mov    0x64(%eax),%eax
f0104398:	89 43 30             	mov    %eax,0x30(%ebx)
        tf->tf_esp = esp_addr;
f010439b:	89 7b 3c             	mov    %edi,0x3c(%ebx)
        env_run(curenv);
f010439e:	e8 68 1d 00 00       	call   f010610b <cpunum>
f01043a3:	83 c4 04             	add    $0x4,%esp
f01043a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043a9:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f01043af:	e8 74 f7 ff ff       	call   f0103b28 <env_run>
            esp_addr = UXSTACKTOP;
f01043b4:	c7 45 e0 00 00 c0 ee 	movl   $0xeec00000,-0x20(%ebp)
f01043bb:	e9 09 ff ff ff       	jmp    f01042c9 <page_fault_handler+0xdb>

f01043c0 <trap>:
{
f01043c0:	55                   	push   %ebp
f01043c1:	89 e5                	mov    %esp,%ebp
f01043c3:	57                   	push   %edi
f01043c4:	56                   	push   %esi
f01043c5:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01043c8:	fc                   	cld    
	if (panicstr)
f01043c9:	83 3d 80 5e 21 f0 00 	cmpl   $0x0,0xf0215e80
f01043d0:	74 01                	je     f01043d3 <trap+0x13>
		asm volatile("hlt");
f01043d2:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01043d3:	e8 33 1d 00 00       	call   f010610b <cpunum>
f01043d8:	6b d0 74             	imul   $0x74,%eax,%edx
f01043db:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01043de:	b8 01 00 00 00       	mov    $0x1,%eax
f01043e3:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
f01043ea:	83 f8 02             	cmp    $0x2,%eax
f01043ed:	0f 84 c2 00 00 00    	je     f01044b5 <trap+0xf5>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01043f3:	9c                   	pushf  
f01043f4:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01043f5:	f6 c4 02             	test   $0x2,%ah
f01043f8:	0f 85 cc 00 00 00    	jne    f01044ca <trap+0x10a>
	if ((tf->tf_cs & 3) == 3) {
f01043fe:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104402:	83 e0 03             	and    $0x3,%eax
f0104405:	66 83 f8 03          	cmp    $0x3,%ax
f0104409:	0f 84 d4 00 00 00    	je     f01044e3 <trap+0x123>
	last_tf = tf;
f010440f:	89 35 60 5a 21 f0    	mov    %esi,0xf0215a60
    if (tf->tf_trapno == T_PGFLT) {
f0104415:	8b 46 28             	mov    0x28(%esi),%eax
f0104418:	83 f8 0e             	cmp    $0xe,%eax
f010441b:	0f 84 67 01 00 00    	je     f0104588 <trap+0x1c8>
    if (tf->tf_trapno == T_BRKPT) {
f0104421:	83 f8 03             	cmp    $0x3,%eax
f0104424:	0f 84 6f 01 00 00    	je     f0104599 <trap+0x1d9>
    if (tf->tf_trapno == T_SYSCALL) {
f010442a:	83 f8 30             	cmp    $0x30,%eax
f010442d:	0f 84 77 01 00 00    	je     f01045aa <trap+0x1ea>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104433:	83 f8 27             	cmp    $0x27,%eax
f0104436:	0f 84 92 01 00 00    	je     f01045ce <trap+0x20e>
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010443c:	83 f8 20             	cmp    $0x20,%eax
f010443f:	0f 84 a6 01 00 00    	je     f01045eb <trap+0x22b>
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104445:	83 f8 21             	cmp    $0x21,%eax
f0104448:	0f 84 a7 01 00 00    	je     f01045f5 <trap+0x235>
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f010444e:	83 f8 24             	cmp    $0x24,%eax
f0104451:	0f 84 a8 01 00 00    	je     f01045ff <trap+0x23f>
	print_trapframe(tf);
f0104457:	83 ec 0c             	sub    $0xc,%esp
f010445a:	56                   	push   %esi
f010445b:	e8 f5 fb ff ff       	call   f0104055 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104460:	83 c4 10             	add    $0x10,%esp
f0104463:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104468:	0f 84 9b 01 00 00    	je     f0104609 <trap+0x249>
		env_destroy(curenv);
f010446e:	e8 98 1c 00 00       	call   f010610b <cpunum>
f0104473:	83 ec 0c             	sub    $0xc,%esp
f0104476:	6b c0 74             	imul   $0x74,%eax,%eax
f0104479:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f010447f:	e8 05 f6 ff ff       	call   f0103a89 <env_destroy>
f0104484:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104487:	e8 7f 1c 00 00       	call   f010610b <cpunum>
f010448c:	6b c0 74             	imul   $0x74,%eax,%eax
f010448f:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0104496:	74 18                	je     f01044b0 <trap+0xf0>
f0104498:	e8 6e 1c 00 00       	call   f010610b <cpunum>
f010449d:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a0:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01044a6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044aa:	0f 84 70 01 00 00    	je     f0104620 <trap+0x260>
		sched_yield();
f01044b0:	e8 69 03 00 00       	call   f010481e <sched_yield>
	spin_lock(&kernel_lock);
f01044b5:	83 ec 0c             	sub    $0xc,%esp
f01044b8:	68 e0 27 12 f0       	push   $0xf01227e0
f01044bd:	e8 b9 1e 00 00       	call   f010637b <spin_lock>
f01044c2:	83 c4 10             	add    $0x10,%esp
f01044c5:	e9 29 ff ff ff       	jmp    f01043f3 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01044ca:	68 70 7d 10 f0       	push   $0xf0107d70
f01044cf:	68 db 77 10 f0       	push   $0xf01077db
f01044d4:	68 38 01 00 00       	push   $0x138
f01044d9:	68 64 7d 10 f0       	push   $0xf0107d64
f01044de:	e8 5d bb ff ff       	call   f0100040 <_panic>
f01044e3:	83 ec 0c             	sub    $0xc,%esp
f01044e6:	68 e0 27 12 f0       	push   $0xf01227e0
f01044eb:	e8 8b 1e 00 00       	call   f010637b <spin_lock>
		assert(curenv);
f01044f0:	e8 16 1c 00 00       	call   f010610b <cpunum>
f01044f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f8:	83 c4 10             	add    $0x10,%esp
f01044fb:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0104502:	74 3e                	je     f0104542 <trap+0x182>
		if (curenv->env_status == ENV_DYING) {
f0104504:	e8 02 1c 00 00       	call   f010610b <cpunum>
f0104509:	6b c0 74             	imul   $0x74,%eax,%eax
f010450c:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104512:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104516:	74 43                	je     f010455b <trap+0x19b>
		curenv->env_tf = *tf;
f0104518:	e8 ee 1b 00 00       	call   f010610b <cpunum>
f010451d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104520:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104526:	b9 11 00 00 00       	mov    $0x11,%ecx
f010452b:	89 c7                	mov    %eax,%edi
f010452d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f010452f:	e8 d7 1b 00 00       	call   f010610b <cpunum>
f0104534:	6b c0 74             	imul   $0x74,%eax,%eax
f0104537:	8b b0 28 60 21 f0    	mov    -0xfde9fd8(%eax),%esi
f010453d:	e9 cd fe ff ff       	jmp    f010440f <trap+0x4f>
		assert(curenv);
f0104542:	68 89 7d 10 f0       	push   $0xf0107d89
f0104547:	68 db 77 10 f0       	push   $0xf01077db
f010454c:	68 40 01 00 00       	push   $0x140
f0104551:	68 64 7d 10 f0       	push   $0xf0107d64
f0104556:	e8 e5 ba ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010455b:	e8 ab 1b 00 00       	call   f010610b <cpunum>
f0104560:	83 ec 0c             	sub    $0xc,%esp
f0104563:	6b c0 74             	imul   $0x74,%eax,%eax
f0104566:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f010456c:	e8 5b f3 ff ff       	call   f01038cc <env_free>
			curenv = NULL;
f0104571:	e8 95 1b 00 00       	call   f010610b <cpunum>
f0104576:	6b c0 74             	imul   $0x74,%eax,%eax
f0104579:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f0104580:	00 00 00 
			sched_yield();
f0104583:	e8 96 02 00 00       	call   f010481e <sched_yield>
        page_fault_handler(tf);
f0104588:	83 ec 0c             	sub    $0xc,%esp
f010458b:	56                   	push   %esi
f010458c:	e8 5d fc ff ff       	call   f01041ee <page_fault_handler>
f0104591:	83 c4 10             	add    $0x10,%esp
f0104594:	e9 ee fe ff ff       	jmp    f0104487 <trap+0xc7>
        monitor(tf);
f0104599:	83 ec 0c             	sub    $0xc,%esp
f010459c:	56                   	push   %esi
f010459d:	e8 87 c3 ff ff       	call   f0100929 <monitor>
f01045a2:	83 c4 10             	add    $0x10,%esp
f01045a5:	e9 dd fe ff ff       	jmp    f0104487 <trap+0xc7>
        ret_val = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,
f01045aa:	83 ec 08             	sub    $0x8,%esp
f01045ad:	ff 76 04             	pushl  0x4(%esi)
f01045b0:	ff 36                	pushl  (%esi)
f01045b2:	ff 76 10             	pushl  0x10(%esi)
f01045b5:	ff 76 18             	pushl  0x18(%esi)
f01045b8:	ff 76 14             	pushl  0x14(%esi)
f01045bb:	ff 76 1c             	pushl  0x1c(%esi)
f01045be:	e8 ed 02 00 00       	call   f01048b0 <syscall>
        regs->reg_eax = (uint32_t)ret_val;
f01045c3:	89 46 1c             	mov    %eax,0x1c(%esi)
f01045c6:	83 c4 20             	add    $0x20,%esp
f01045c9:	e9 b9 fe ff ff       	jmp    f0104487 <trap+0xc7>
		cprintf("Spurious interrupt on irq 7\n");
f01045ce:	83 ec 0c             	sub    $0xc,%esp
f01045d1:	68 90 7d 10 f0       	push   $0xf0107d90
f01045d6:	e8 ad f7 ff ff       	call   f0103d88 <cprintf>
		print_trapframe(tf);
f01045db:	89 34 24             	mov    %esi,(%esp)
f01045de:	e8 72 fa ff ff       	call   f0104055 <print_trapframe>
f01045e3:	83 c4 10             	add    $0x10,%esp
f01045e6:	e9 9c fe ff ff       	jmp    f0104487 <trap+0xc7>
        lapic_eoi();
f01045eb:	e8 67 1c 00 00       	call   f0106257 <lapic_eoi>
        sched_yield();
f01045f0:	e8 29 02 00 00       	call   f010481e <sched_yield>
        kbd_intr();
f01045f5:	e8 01 c0 ff ff       	call   f01005fb <kbd_intr>
f01045fa:	e9 88 fe ff ff       	jmp    f0104487 <trap+0xc7>
        serial_intr();
f01045ff:	e8 da bf ff ff       	call   f01005de <serial_intr>
f0104604:	e9 7e fe ff ff       	jmp    f0104487 <trap+0xc7>
		panic("unhandled trap in kernel");
f0104609:	83 ec 04             	sub    $0x4,%esp
f010460c:	68 ad 7d 10 f0       	push   $0xf0107dad
f0104611:	68 1e 01 00 00       	push   $0x11e
f0104616:	68 64 7d 10 f0       	push   $0xf0107d64
f010461b:	e8 20 ba ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104620:	e8 e6 1a 00 00       	call   f010610b <cpunum>
f0104625:	83 ec 0c             	sub    $0xc,%esp
f0104628:	6b c0 74             	imul   $0x74,%eax,%eax
f010462b:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0104631:	e8 f2 f4 ff ff       	call   f0103b28 <env_run>

f0104636 <divide_error>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(divide_error, T_DIVIDE)
f0104636:	6a 00                	push   $0x0
f0104638:	6a 00                	push   $0x0
f010463a:	e9 f9 00 00 00       	jmp    f0104738 <_alltraps>
f010463f:	90                   	nop

f0104640 <debug_exception>:
TRAPHANDLER_NOEC(debug_exception, T_DEBUG)
f0104640:	6a 00                	push   $0x0
f0104642:	6a 01                	push   $0x1
f0104644:	e9 ef 00 00 00       	jmp    f0104738 <_alltraps>
f0104649:	90                   	nop

f010464a <non_maskable_interrupt>:
TRAPHANDLER_NOEC(non_maskable_interrupt, T_NMI)
f010464a:	6a 00                	push   $0x0
f010464c:	6a 02                	push   $0x2
f010464e:	e9 e5 00 00 00       	jmp    f0104738 <_alltraps>
f0104653:	90                   	nop

f0104654 <breakpoint_int>:
TRAPHANDLER_NOEC(breakpoint_int, T_BRKPT)
f0104654:	6a 00                	push   $0x0
f0104656:	6a 03                	push   $0x3
f0104658:	e9 db 00 00 00       	jmp    f0104738 <_alltraps>
f010465d:	90                   	nop

f010465e <overflow>:
TRAPHANDLER_NOEC(overflow, T_OFLOW)
f010465e:	6a 00                	push   $0x0
f0104660:	6a 04                	push   $0x4
f0104662:	e9 d1 00 00 00       	jmp    f0104738 <_alltraps>
f0104667:	90                   	nop

f0104668 <bounds_check>:
TRAPHANDLER_NOEC(bounds_check, T_BOUND)
f0104668:	6a 00                	push   $0x0
f010466a:	6a 05                	push   $0x5
f010466c:	e9 c7 00 00 00       	jmp    f0104738 <_alltraps>
f0104671:	90                   	nop

f0104672 <illegal_opcode>:
TRAPHANDLER_NOEC(illegal_opcode, T_ILLOP)
f0104672:	6a 00                	push   $0x0
f0104674:	6a 06                	push   $0x6
f0104676:	e9 bd 00 00 00       	jmp    f0104738 <_alltraps>
f010467b:	90                   	nop

f010467c <device_not_available>:
TRAPHANDLER_NOEC(device_not_available, T_DEVICE)
f010467c:	6a 00                	push   $0x0
f010467e:	6a 07                	push   $0x7
f0104680:	e9 b3 00 00 00       	jmp    f0104738 <_alltraps>
f0104685:	90                   	nop

f0104686 <double_fault>:

TRAPHANDLER(double_fault, T_DBLFLT)
f0104686:	6a 08                	push   $0x8
f0104688:	e9 ab 00 00 00       	jmp    f0104738 <_alltraps>
f010468d:	90                   	nop

f010468e <reserved>:
TRAPHANDLER(reserved, 9)
f010468e:	6a 09                	push   $0x9
f0104690:	e9 a3 00 00 00       	jmp    f0104738 <_alltraps>
f0104695:	90                   	nop

f0104696 <invalid_task_switch_segment>:
TRAPHANDLER(invalid_task_switch_segment, T_TSS)
f0104696:	6a 0a                	push   $0xa
f0104698:	e9 9b 00 00 00       	jmp    f0104738 <_alltraps>
f010469d:	90                   	nop

f010469e <segment_not_present>:
TRAPHANDLER(segment_not_present, T_SEGNP)
f010469e:	6a 0b                	push   $0xb
f01046a0:	e9 93 00 00 00       	jmp    f0104738 <_alltraps>
f01046a5:	90                   	nop

f01046a6 <stack_exception>:
TRAPHANDLER(stack_exception, T_STACK)
f01046a6:	6a 0c                	push   $0xc
f01046a8:	e9 8b 00 00 00       	jmp    f0104738 <_alltraps>
f01046ad:	90                   	nop

f01046ae <general_protection_fault>:
TRAPHANDLER(general_protection_fault, T_GPFLT)
f01046ae:	6a 0d                	push   $0xd
f01046b0:	e9 83 00 00 00       	jmp    f0104738 <_alltraps>
f01046b5:	90                   	nop

f01046b6 <page_fault>:
TRAPHANDLER(page_fault, T_PGFLT)
f01046b6:	6a 0e                	push   $0xe
f01046b8:	eb 7e                	jmp    f0104738 <_alltraps>

f01046ba <floating_point_error>:

TRAPHANDLER_NOEC(floating_point_error, T_FPERR)
f01046ba:	6a 00                	push   $0x0
f01046bc:	6a 10                	push   $0x10
f01046be:	eb 78                	jmp    f0104738 <_alltraps>

f01046c0 <aligment_check>:
TRAPHANDLER_NOEC(aligment_check, T_ALIGN)
f01046c0:	6a 00                	push   $0x0
f01046c2:	6a 11                	push   $0x11
f01046c4:	eb 72                	jmp    f0104738 <_alltraps>

f01046c6 <machine_check>:
TRAPHANDLER_NOEC(machine_check, T_MCHK)
f01046c6:	6a 00                	push   $0x0
f01046c8:	6a 12                	push   $0x12
f01046ca:	eb 6c                	jmp    f0104738 <_alltraps>

f01046cc <SIMD_floating_point_error>:
TRAPHANDLER_NOEC(SIMD_floating_point_error, T_SIMDERR)
f01046cc:	6a 00                	push   $0x0
f01046ce:	6a 13                	push   $0x13
f01046d0:	eb 66                	jmp    f0104738 <_alltraps>

f01046d2 <system_call>:

TRAPHANDLER_NOEC(system_call, T_SYSCALL)
f01046d2:	6a 00                	push   $0x0
f01046d4:	6a 30                	push   $0x30
f01046d6:	eb 60                	jmp    f0104738 <_alltraps>

f01046d8 <irq_0_timer>:

TRAPHANDLER_NOEC(irq_0_timer, IRQ_0)
f01046d8:	6a 00                	push   $0x0
f01046da:	6a 20                	push   $0x20
f01046dc:	eb 5a                	jmp    f0104738 <_alltraps>

f01046de <irq_1>:
TRAPHANDLER_NOEC(irq_1, IRQ_1)
f01046de:	6a 00                	push   $0x0
f01046e0:	6a 21                	push   $0x21
f01046e2:	eb 54                	jmp    f0104738 <_alltraps>

f01046e4 <irq_2>:
TRAPHANDLER_NOEC(irq_2, IRQ_2)
f01046e4:	6a 00                	push   $0x0
f01046e6:	6a 22                	push   $0x22
f01046e8:	eb 4e                	jmp    f0104738 <_alltraps>

f01046ea <irq_3>:
TRAPHANDLER_NOEC(irq_3, IRQ_3)
f01046ea:	6a 00                	push   $0x0
f01046ec:	6a 23                	push   $0x23
f01046ee:	eb 48                	jmp    f0104738 <_alltraps>

f01046f0 <irq_4>:
TRAPHANDLER_NOEC(irq_4, IRQ_4)
f01046f0:	6a 00                	push   $0x0
f01046f2:	6a 24                	push   $0x24
f01046f4:	eb 42                	jmp    f0104738 <_alltraps>

f01046f6 <irq_5>:
TRAPHANDLER_NOEC(irq_5, IRQ_5)
f01046f6:	6a 00                	push   $0x0
f01046f8:	6a 25                	push   $0x25
f01046fa:	eb 3c                	jmp    f0104738 <_alltraps>

f01046fc <irq_6>:
TRAPHANDLER_NOEC(irq_6, IRQ_6)
f01046fc:	6a 00                	push   $0x0
f01046fe:	6a 26                	push   $0x26
f0104700:	eb 36                	jmp    f0104738 <_alltraps>

f0104702 <irq_7>:
TRAPHANDLER_NOEC(irq_7, IRQ_7)
f0104702:	6a 00                	push   $0x0
f0104704:	6a 27                	push   $0x27
f0104706:	eb 30                	jmp    f0104738 <_alltraps>

f0104708 <irq_8>:
TRAPHANDLER_NOEC(irq_8, IRQ_8)
f0104708:	6a 00                	push   $0x0
f010470a:	6a 28                	push   $0x28
f010470c:	eb 2a                	jmp    f0104738 <_alltraps>

f010470e <irq_9>:
TRAPHANDLER_NOEC(irq_9, IRQ_9)
f010470e:	6a 00                	push   $0x0
f0104710:	6a 29                	push   $0x29
f0104712:	eb 24                	jmp    f0104738 <_alltraps>

f0104714 <irq_10>:
TRAPHANDLER_NOEC(irq_10, IRQ_10)
f0104714:	6a 00                	push   $0x0
f0104716:	6a 2a                	push   $0x2a
f0104718:	eb 1e                	jmp    f0104738 <_alltraps>

f010471a <irq_11>:
TRAPHANDLER_NOEC(irq_11, IRQ_11)
f010471a:	6a 00                	push   $0x0
f010471c:	6a 2b                	push   $0x2b
f010471e:	eb 18                	jmp    f0104738 <_alltraps>

f0104720 <irq_12>:
TRAPHANDLER_NOEC(irq_12, IRQ_12)
f0104720:	6a 00                	push   $0x0
f0104722:	6a 2c                	push   $0x2c
f0104724:	eb 12                	jmp    f0104738 <_alltraps>

f0104726 <irq_13>:
TRAPHANDLER_NOEC(irq_13, IRQ_13)
f0104726:	6a 00                	push   $0x0
f0104728:	6a 2d                	push   $0x2d
f010472a:	eb 0c                	jmp    f0104738 <_alltraps>

f010472c <irq_14>:
TRAPHANDLER_NOEC(irq_14, IRQ_14)
f010472c:	6a 00                	push   $0x0
f010472e:	6a 2e                	push   $0x2e
f0104730:	eb 06                	jmp    f0104738 <_alltraps>

f0104732 <irq_15>:
TRAPHANDLER_NOEC(irq_15, IRQ_15)
f0104732:	6a 00                	push   $0x0
f0104734:	6a 2f                	push   $0x2f
f0104736:	eb 00                	jmp    f0104738 <_alltraps>

f0104738 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
# Build push other trapframe fields
  pushl %ds
f0104738:	1e                   	push   %ds
  pushl %es
f0104739:	06                   	push   %es
  pushal
f010473a:	60                   	pusha  

  movw $GD_KD, %ax
f010473b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
f010473f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0104741:	8e c0                	mov    %eax,%es

  pushl %esp
f0104743:	54                   	push   %esp
  call trap
f0104744:	e8 77 fc ff ff       	call   f01043c0 <trap>
  addl $4, %esp
f0104749:	83 c4 04             	add    $0x4,%esp

f010474c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010474c:	55                   	push   %ebp
f010474d:	89 e5                	mov    %esp,%ebp
f010474f:	83 ec 08             	sub    $0x8,%esp
f0104752:	a1 48 52 21 f0       	mov    0xf0215248,%eax
f0104757:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010475a:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010475f:	8b 10                	mov    (%eax),%edx
f0104761:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104764:	83 fa 02             	cmp    $0x2,%edx
f0104767:	76 2d                	jbe    f0104796 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f0104769:	83 c1 01             	add    $0x1,%ecx
f010476c:	83 c0 7c             	add    $0x7c,%eax
f010476f:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104775:	75 e8                	jne    f010475f <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104777:	83 ec 0c             	sub    $0xc,%esp
f010477a:	68 d0 7f 10 f0       	push   $0xf0107fd0
f010477f:	e8 04 f6 ff ff       	call   f0103d88 <cprintf>
f0104784:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104787:	83 ec 0c             	sub    $0xc,%esp
f010478a:	6a 00                	push   $0x0
f010478c:	e8 98 c1 ff ff       	call   f0100929 <monitor>
f0104791:	83 c4 10             	add    $0x10,%esp
f0104794:	eb f1                	jmp    f0104787 <sched_halt+0x3b>
	if (i == NENV) {
f0104796:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010479c:	74 d9                	je     f0104777 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010479e:	e8 68 19 00 00       	call   f010610b <cpunum>
f01047a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a6:	c7 80 28 60 21 f0 00 	movl   $0x0,-0xfde9fd8(%eax)
f01047ad:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01047b0:	a1 8c 5e 21 f0       	mov    0xf0215e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01047b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01047ba:	76 50                	jbe    f010480c <sched_halt+0xc0>
	return (physaddr_t)kva - KERNBASE;
f01047bc:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01047c1:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01047c4:	e8 42 19 00 00       	call   f010610b <cpunum>
f01047c9:	6b d0 74             	imul   $0x74,%eax,%edx
f01047cc:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01047cf:	b8 02 00 00 00       	mov    $0x2,%eax
f01047d4:	f0 87 82 20 60 21 f0 	lock xchg %eax,-0xfde9fe0(%edx)
	spin_unlock(&kernel_lock);
f01047db:	83 ec 0c             	sub    $0xc,%esp
f01047de:	68 e0 27 12 f0       	push   $0xf01227e0
f01047e3:	e8 30 1c 00 00       	call   f0106418 <spin_unlock>
	asm volatile("pause");
f01047e8:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01047ea:	e8 1c 19 00 00       	call   f010610b <cpunum>
f01047ef:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01047f2:	8b 80 30 60 21 f0    	mov    -0xfde9fd0(%eax),%eax
f01047f8:	bd 00 00 00 00       	mov    $0x0,%ebp
f01047fd:	89 c4                	mov    %eax,%esp
f01047ff:	6a 00                	push   $0x0
f0104801:	6a 00                	push   $0x0
f0104803:	fb                   	sti    
f0104804:	f4                   	hlt    
f0104805:	eb fd                	jmp    f0104804 <sched_halt+0xb8>
}
f0104807:	83 c4 10             	add    $0x10,%esp
f010480a:	c9                   	leave  
f010480b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010480c:	50                   	push   %eax
f010480d:	68 88 67 10 f0       	push   $0xf0106788
f0104812:	6a 50                	push   $0x50
f0104814:	68 f9 7f 10 f0       	push   $0xf0107ff9
f0104819:	e8 22 b8 ff ff       	call   f0100040 <_panic>

f010481e <sched_yield>:
{
f010481e:	55                   	push   %ebp
f010481f:	89 e5                	mov    %esp,%ebp
f0104821:	57                   	push   %edi
f0104822:	56                   	push   %esi
f0104823:	53                   	push   %ebx
f0104824:	83 ec 1c             	sub    $0x1c,%esp
    idle = curenv;
f0104827:	e8 df 18 00 00       	call   f010610b <cpunum>
f010482c:	6b c0 74             	imul   $0x74,%eax,%eax
f010482f:	8b b8 28 60 21 f0    	mov    -0xfde9fd8(%eax),%edi
    if (curenv == NULL) {
f0104835:	e8 d1 18 00 00       	call   f010610b <cpunum>
f010483a:	6b c0 74             	imul   $0x74,%eax,%eax
f010483d:	83 b8 28 60 21 f0 00 	cmpl   $0x0,-0xfde9fd8(%eax)
f0104844:	74 0a                	je     f0104850 <sched_yield+0x32>
    idle ++;
f0104846:	8d 5f 7c             	lea    0x7c(%edi),%ebx
f0104849:	be 00 04 00 00       	mov    $0x400,%esi
f010484e:	eb 19                	jmp    f0104869 <sched_yield+0x4b>
        idle = envs;
f0104850:	8b 3d 48 52 21 f0    	mov    0xf0215248,%edi
f0104856:	eb ee                	jmp    f0104846 <sched_yield+0x28>
            env_run(idle);;
f0104858:	83 ec 0c             	sub    $0xc,%esp
f010485b:	53                   	push   %ebx
f010485c:	e8 c7 f2 ff ff       	call   f0103b28 <env_run>
    for (cnt=0; cnt < NENV ; cnt++, idle++) {
f0104861:	83 c3 7c             	add    $0x7c,%ebx
f0104864:	83 ee 01             	sub    $0x1,%esi
f0104867:	74 3a                	je     f01048a3 <sched_yield+0x85>
        if (idle >= envs + NENV) {
f0104869:	a1 48 52 21 f0       	mov    0xf0215248,%eax
f010486e:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
            idle = envs;
f0104874:	39 d3                	cmp    %edx,%ebx
f0104876:	0f 43 d8             	cmovae %eax,%ebx
        if (idle->env_status == ENV_RUNNABLE) {
f0104879:	8b 43 54             	mov    0x54(%ebx),%eax
f010487c:	83 f8 02             	cmp    $0x2,%eax
f010487f:	74 d7                	je     f0104858 <sched_yield+0x3a>
        if (idle == temp && idle->env_status == ENV_RUNNING && idle->env_cpunum == cpunum()) {
f0104881:	83 f8 03             	cmp    $0x3,%eax
f0104884:	75 db                	jne    f0104861 <sched_yield+0x43>
f0104886:	39 df                	cmp    %ebx,%edi
f0104888:	75 d7                	jne    f0104861 <sched_yield+0x43>
f010488a:	8b 43 5c             	mov    0x5c(%ebx),%eax
f010488d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104890:	e8 76 18 00 00       	call   f010610b <cpunum>
f0104895:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0104898:	75 c7                	jne    f0104861 <sched_yield+0x43>
            env_run(idle);;
f010489a:	83 ec 0c             	sub    $0xc,%esp
f010489d:	53                   	push   %ebx
f010489e:	e8 85 f2 ff ff       	call   f0103b28 <env_run>
	sched_halt();
f01048a3:	e8 a4 fe ff ff       	call   f010474c <sched_halt>
}
f01048a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048ab:	5b                   	pop    %ebx
f01048ac:	5e                   	pop    %esi
f01048ad:	5f                   	pop    %edi
f01048ae:	5d                   	pop    %ebp
f01048af:	c3                   	ret    

f01048b0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01048b0:	55                   	push   %ebp
f01048b1:	89 e5                	mov    %esp,%ebp
f01048b3:	57                   	push   %edi
f01048b4:	56                   	push   %esi
f01048b5:	53                   	push   %ebx
f01048b6:	83 ec 1c             	sub    $0x1c,%esp
f01048b9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f01048bc:	83 f8 0d             	cmp    $0xd,%eax
f01048bf:	0f 87 82 05 00 00    	ja     f0104e47 <syscall+0x597>
f01048c5:	ff 24 85 0c 80 10 f0 	jmp    *-0xfef7ff4(,%eax,4)
    user_mem_assert(curenv, s, len, PTE_P);
f01048cc:	e8 3a 18 00 00       	call   f010610b <cpunum>
f01048d1:	6a 01                	push   $0x1
f01048d3:	ff 75 10             	pushl  0x10(%ebp)
f01048d6:	ff 75 0c             	pushl  0xc(%ebp)
f01048d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01048dc:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f01048e2:	e8 90 ea ff ff       	call   f0103377 <user_mem_assert>
	cprintf("%.*s", len, s);
f01048e7:	83 c4 0c             	add    $0xc,%esp
f01048ea:	ff 75 0c             	pushl  0xc(%ebp)
f01048ed:	ff 75 10             	pushl  0x10(%ebp)
f01048f0:	68 06 80 10 f0       	push   $0xf0108006
f01048f5:	e8 8e f4 ff ff       	call   f0103d88 <cprintf>
f01048fa:	83 c4 10             	add    $0x10,%esp
        case SYS_cputs:
            sys_cputs((char *)a1, a2);
            return 0;
f01048fd:	bb 00 00 00 00       	mov    $0x0,%ebx
        case SYS_env_set_trapframe:
            return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
        default:
		return -E_INVAL;
	}
}
f0104902:	89 d8                	mov    %ebx,%eax
f0104904:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104907:	5b                   	pop    %ebx
f0104908:	5e                   	pop    %esi
f0104909:	5f                   	pop    %edi
f010490a:	5d                   	pop    %ebp
f010490b:	c3                   	ret    
	return cons_getc();
f010490c:	e8 fc bc ff ff       	call   f010060d <cons_getc>
f0104911:	89 c3                	mov    %eax,%ebx
            return sys_cgetc();
f0104913:	eb ed                	jmp    f0104902 <syscall+0x52>
	return curenv->env_id;
f0104915:	e8 f1 17 00 00       	call   f010610b <cpunum>
f010491a:	6b c0 74             	imul   $0x74,%eax,%eax
f010491d:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104923:	8b 58 48             	mov    0x48(%eax),%ebx
            return sys_getenvid();
f0104926:	eb da                	jmp    f0104902 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104928:	83 ec 04             	sub    $0x4,%esp
f010492b:	6a 01                	push   $0x1
f010492d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104930:	50                   	push   %eax
f0104931:	ff 75 0c             	pushl  0xc(%ebp)
f0104934:	e8 8a ea ff ff       	call   f01033c3 <envid2env>
f0104939:	89 c3                	mov    %eax,%ebx
f010493b:	83 c4 10             	add    $0x10,%esp
f010493e:	85 c0                	test   %eax,%eax
f0104940:	78 c0                	js     f0104902 <syscall+0x52>
	env_destroy(e);
f0104942:	83 ec 0c             	sub    $0xc,%esp
f0104945:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104948:	e8 3c f1 ff ff       	call   f0103a89 <env_destroy>
f010494d:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104950:	bb 00 00 00 00       	mov    $0x0,%ebx
            return sys_env_destroy((envid_t)a1);
f0104955:	eb ab                	jmp    f0104902 <syscall+0x52>
	sched_yield();
f0104957:	e8 c2 fe ff ff       	call   f010481e <sched_yield>
    if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f010495c:	8b 45 10             	mov    0x10(%ebp),%eax
f010495f:	83 e8 02             	sub    $0x2,%eax
f0104962:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104967:	75 28                	jne    f0104991 <syscall+0xe1>
    if (envid2env(envid, &e, 1) != 0) {
f0104969:	83 ec 04             	sub    $0x4,%esp
f010496c:	6a 01                	push   $0x1
f010496e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104971:	50                   	push   %eax
f0104972:	ff 75 0c             	pushl  0xc(%ebp)
f0104975:	e8 49 ea ff ff       	call   f01033c3 <envid2env>
f010497a:	89 c3                	mov    %eax,%ebx
f010497c:	83 c4 10             	add    $0x10,%esp
f010497f:	85 c0                	test   %eax,%eax
f0104981:	75 18                	jne    f010499b <syscall+0xeb>
    e->env_status = status;
f0104983:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104986:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104989:	89 48 54             	mov    %ecx,0x54(%eax)
f010498c:	e9 71 ff ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104991:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104996:	e9 67 ff ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f010499b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
            return sys_env_set_status((envid_t)a1, (int)a2);
f01049a0:	e9 5d ff ff ff       	jmp    f0104902 <syscall+0x52>
    if ((code = env_alloc(&e, curenv->env_id)) != 0) {
f01049a5:	e8 61 17 00 00       	call   f010610b <cpunum>
f01049aa:	83 ec 08             	sub    $0x8,%esp
f01049ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b0:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f01049b6:	ff 70 48             	pushl  0x48(%eax)
f01049b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049bc:	50                   	push   %eax
f01049bd:	e8 0c eb ff ff       	call   f01034ce <env_alloc>
f01049c2:	89 c3                	mov    %eax,%ebx
f01049c4:	83 c4 10             	add    $0x10,%esp
f01049c7:	85 c0                	test   %eax,%eax
f01049c9:	0f 85 33 ff ff ff    	jne    f0104902 <syscall+0x52>
    memcpy(&e->env_tf, &curenv->env_tf, sizeof(e->env_tf));
f01049cf:	e8 37 17 00 00       	call   f010610b <cpunum>
f01049d4:	83 ec 04             	sub    $0x4,%esp
f01049d7:	6a 44                	push   $0x44
f01049d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049dc:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f01049e2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049e5:	e8 b3 11 00 00       	call   f0105b9d <memcpy>
    e->env_status = ENV_NOT_RUNNABLE;
f01049ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049ed:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    e->env_tf.tf_regs.reg_eax = 0;
f01049f4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    return e->env_id;
f01049fb:	8b 58 48             	mov    0x48(%eax),%ebx
f01049fe:	83 c4 10             	add    $0x10,%esp
            return sys_exofork();
f0104a01:	e9 fc fe ff ff       	jmp    f0104902 <syscall+0x52>
    if ((uint32_t) va >= UTOP || PTE_ADDR(va) != (uint32_t)va) {
f0104a06:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a0d:	77 6e                	ja     f0104a7d <syscall+0x1cd>
f0104a0f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104a16:	75 6f                	jne    f0104a87 <syscall+0x1d7>
    perm = perm | PTE_U | PTE_P;
f0104a18:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104a1b:	83 cb 05             	or     $0x5,%ebx
    if ((perm | PTE_SYSCALL) != PTE_SYSCALL) {
f0104a1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a21:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104a26:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104a2b:	75 64                	jne    f0104a91 <syscall+0x1e1>
    if (envid2env(envid, &e, 1) != 0) {
f0104a2d:	83 ec 04             	sub    $0x4,%esp
f0104a30:	6a 01                	push   $0x1
f0104a32:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a35:	50                   	push   %eax
f0104a36:	ff 75 0c             	pushl  0xc(%ebp)
f0104a39:	e8 85 e9 ff ff       	call   f01033c3 <envid2env>
f0104a3e:	83 c4 10             	add    $0x10,%esp
f0104a41:	85 c0                	test   %eax,%eax
f0104a43:	75 56                	jne    f0104a9b <syscall+0x1eb>
    if ((pp = page_alloc(1)) == NULL) {
f0104a45:	83 ec 0c             	sub    $0xc,%esp
f0104a48:	6a 01                	push   $0x1
f0104a4a:	e8 7a c5 ff ff       	call   f0100fc9 <page_alloc>
f0104a4f:	83 c4 10             	add    $0x10,%esp
f0104a52:	85 c0                	test   %eax,%eax
f0104a54:	74 4f                	je     f0104aa5 <syscall+0x1f5>
    if (page_insert(e->env_pgdir, pp, va, perm) != 0) {
f0104a56:	53                   	push   %ebx
f0104a57:	ff 75 10             	pushl  0x10(%ebp)
f0104a5a:	50                   	push   %eax
f0104a5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a5e:	ff 70 60             	pushl  0x60(%eax)
f0104a61:	e8 02 cb ff ff       	call   f0101568 <page_insert>
f0104a66:	89 c3                	mov    %eax,%ebx
f0104a68:	83 c4 10             	add    $0x10,%esp
f0104a6b:	85 c0                	test   %eax,%eax
f0104a6d:	0f 84 8f fe ff ff    	je     f0104902 <syscall+0x52>
        return -E_NO_MEM;
f0104a73:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
            return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104a78:	e9 85 fe ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104a7d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a82:	e9 7b fe ff ff       	jmp    f0104902 <syscall+0x52>
f0104a87:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a8c:	e9 71 fe ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104a91:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a96:	e9 67 fe ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104a9b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104aa0:	e9 5d fe ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_NO_MEM;
f0104aa5:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104aaa:	e9 53 fe ff ff       	jmp    f0104902 <syscall+0x52>
    if ((uint32_t) srcva >= UTOP || PTE_ADDR(srcva) != (uint32_t)srcva) {
f0104aaf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ab6:	0f 87 de 00 00 00    	ja     f0104b9a <syscall+0x2ea>
    if ((uint32_t) dstva >= UTOP || PTE_ADDR(dstva) != (uint32_t)dstva) {
f0104abc:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ac3:	0f 85 db 00 00 00    	jne    f0104ba4 <syscall+0x2f4>
f0104ac9:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104ad0:	0f 87 ce 00 00 00    	ja     f0104ba4 <syscall+0x2f4>
f0104ad6:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104add:	0f 85 cb 00 00 00    	jne    f0104bae <syscall+0x2fe>
    if (envid2env(srcenvid, &src_e, 1) != 0) {
f0104ae3:	83 ec 04             	sub    $0x4,%esp
f0104ae6:	6a 01                	push   $0x1
f0104ae8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104aeb:	50                   	push   %eax
f0104aec:	ff 75 0c             	pushl  0xc(%ebp)
f0104aef:	e8 cf e8 ff ff       	call   f01033c3 <envid2env>
f0104af4:	83 c4 10             	add    $0x10,%esp
f0104af7:	85 c0                	test   %eax,%eax
f0104af9:	0f 85 b9 00 00 00    	jne    f0104bb8 <syscall+0x308>
    if (envid2env(dstenvid, &dst_e, 1) != 0) {
f0104aff:	83 ec 04             	sub    $0x4,%esp
f0104b02:	6a 01                	push   $0x1
f0104b04:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104b07:	50                   	push   %eax
f0104b08:	ff 75 14             	pushl  0x14(%ebp)
f0104b0b:	e8 b3 e8 ff ff       	call   f01033c3 <envid2env>
f0104b10:	83 c4 10             	add    $0x10,%esp
f0104b13:	85 c0                	test   %eax,%eax
f0104b15:	0f 85 a7 00 00 00    	jne    f0104bc2 <syscall+0x312>
    if ((pp = page_lookup(src_e->env_pgdir, srcva, &pte)) == NULL) {
f0104b1b:	83 ec 04             	sub    $0x4,%esp
f0104b1e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b21:	50                   	push   %eax
f0104b22:	ff 75 10             	pushl  0x10(%ebp)
f0104b25:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b28:	ff 70 60             	pushl  0x60(%eax)
f0104b2b:	e8 60 c9 ff ff       	call   f0101490 <page_lookup>
f0104b30:	89 c3                	mov    %eax,%ebx
f0104b32:	83 c4 10             	add    $0x10,%esp
f0104b35:	85 c0                	test   %eax,%eax
f0104b37:	0f 84 8f 00 00 00    	je     f0104bcc <syscall+0x31c>
    perm = perm | PTE_U | PTE_P;
f0104b3d:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0104b40:	83 ce 05             	or     $0x5,%esi
    if ((perm | PTE_SYSCALL) != PTE_SYSCALL) {
f0104b43:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104b46:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104b4b:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104b50:	0f 85 80 00 00 00    	jne    f0104bd6 <syscall+0x326>
    if ((pte = pgdir_walk(dst_e->env_pgdir, dstva, 1)) == NULL) {
f0104b56:	83 ec 04             	sub    $0x4,%esp
f0104b59:	6a 01                	push   $0x1
f0104b5b:	ff 75 18             	pushl  0x18(%ebp)
f0104b5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b61:	ff 70 60             	pushl  0x60(%eax)
f0104b64:	e8 4b c5 ff ff       	call   f01010b4 <pgdir_walk>
f0104b69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104b6c:	83 c4 10             	add    $0x10,%esp
f0104b6f:	85 c0                	test   %eax,%eax
f0104b71:	74 6d                	je     f0104be0 <syscall+0x330>
    if (page_insert(dst_e->env_pgdir, pp, dstva, perm) != 0) {
f0104b73:	56                   	push   %esi
f0104b74:	ff 75 18             	pushl  0x18(%ebp)
f0104b77:	53                   	push   %ebx
f0104b78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b7b:	ff 70 60             	pushl  0x60(%eax)
f0104b7e:	e8 e5 c9 ff ff       	call   f0101568 <page_insert>
f0104b83:	89 c3                	mov    %eax,%ebx
f0104b85:	83 c4 10             	add    $0x10,%esp
f0104b88:	85 c0                	test   %eax,%eax
f0104b8a:	0f 84 72 fd ff ff    	je     f0104902 <syscall+0x52>
        return -E_NO_MEM;
f0104b90:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
            return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104b95:	e9 68 fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104b9a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b9f:	e9 5e fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104ba4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ba9:	e9 54 fd ff ff       	jmp    f0104902 <syscall+0x52>
f0104bae:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bb3:	e9 4a fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104bb8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bbd:	e9 40 fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104bc2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104bc7:	e9 36 fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104bcc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bd1:	e9 2c fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104bd6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bdb:	e9 22 fd ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_NO_MEM;
f0104be0:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104be5:	e9 18 fd ff ff       	jmp    f0104902 <syscall+0x52>
    if (envid2env(envid, &e, 1) != 0) {
f0104bea:	83 ec 04             	sub    $0x4,%esp
f0104bed:	6a 01                	push   $0x1
f0104bef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bf2:	50                   	push   %eax
f0104bf3:	ff 75 0c             	pushl  0xc(%ebp)
f0104bf6:	e8 c8 e7 ff ff       	call   f01033c3 <envid2env>
f0104bfb:	89 c3                	mov    %eax,%ebx
f0104bfd:	83 c4 10             	add    $0x10,%esp
f0104c00:	85 c0                	test   %eax,%eax
f0104c02:	75 2b                	jne    f0104c2f <syscall+0x37f>
    if ((uint32_t) va >= UTOP || PTE_ADDR(va) != (uint32_t)va) {
f0104c04:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c0b:	77 2c                	ja     f0104c39 <syscall+0x389>
f0104c0d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c14:	75 2d                	jne    f0104c43 <syscall+0x393>
    page_remove(e->env_pgdir, va);
f0104c16:	83 ec 08             	sub    $0x8,%esp
f0104c19:	ff 75 10             	pushl  0x10(%ebp)
f0104c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c1f:	ff 70 60             	pushl  0x60(%eax)
f0104c22:	e8 f9 c8 ff ff       	call   f0101520 <page_remove>
f0104c27:	83 c4 10             	add    $0x10,%esp
f0104c2a:	e9 d3 fc ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104c2f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104c34:	e9 c9 fc ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_INVAL;
f0104c39:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c3e:	e9 bf fc ff ff       	jmp    f0104902 <syscall+0x52>
f0104c43:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
            return sys_page_unmap((envid_t)a1, (void *)a2);
f0104c48:	e9 b5 fc ff ff       	jmp    f0104902 <syscall+0x52>
    if (envid2env(envid, &e, 1) != 0) {
f0104c4d:	83 ec 04             	sub    $0x4,%esp
f0104c50:	6a 01                	push   $0x1
f0104c52:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c55:	50                   	push   %eax
f0104c56:	ff 75 0c             	pushl  0xc(%ebp)
f0104c59:	e8 65 e7 ff ff       	call   f01033c3 <envid2env>
f0104c5e:	89 c3                	mov    %eax,%ebx
f0104c60:	83 c4 10             	add    $0x10,%esp
f0104c63:	85 c0                	test   %eax,%eax
f0104c65:	75 0e                	jne    f0104c75 <syscall+0x3c5>
    e->env_pgfault_upcall = func;
f0104c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c6a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c6d:	89 78 64             	mov    %edi,0x64(%eax)
f0104c70:	e9 8d fc ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104c75:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
            return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104c7a:	e9 83 fc ff ff       	jmp    f0104902 <syscall+0x52>
    if ((uint32_t)dstva < UTOP && PTE_ADDR(dstva) != (uint32_t)dstva) {
f0104c7f:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104c86:	0f 87 1a 02 00 00    	ja     f0104ea6 <syscall+0x5f6>
f0104c8c:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104c93:	0f 84 b8 01 00 00    	je     f0104e51 <syscall+0x5a1>
            return sys_ipc_recv((void *)a1);
f0104c99:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c9e:	e9 5f fc ff ff       	jmp    f0104902 <syscall+0x52>
    if (envid2env(envid, &to_env, 0) != 0) {
f0104ca3:	83 ec 04             	sub    $0x4,%esp
f0104ca6:	6a 00                	push   $0x0
f0104ca8:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cab:	50                   	push   %eax
f0104cac:	ff 75 0c             	pushl  0xc(%ebp)
f0104caf:	e8 0f e7 ff ff       	call   f01033c3 <envid2env>
f0104cb4:	89 c3                	mov    %eax,%ebx
f0104cb6:	83 c4 10             	add    $0x10,%esp
f0104cb9:	85 c0                	test   %eax,%eax
f0104cbb:	0f 85 d6 00 00 00    	jne    f0104d97 <syscall+0x4e7>
    if (to_env->env_ipc_recving != 1) {
f0104cc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cc4:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104cc8:	0f 84 d3 00 00 00    	je     f0104da1 <syscall+0x4f1>
    if ((uint32_t)srcva < UTOP) {
f0104cce:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104cd5:	0f 87 89 00 00 00    	ja     f0104d64 <syscall+0x4b4>
        if (PTE_ADDR(srcva) != (uint32_t)srcva) {
f0104cdb:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104ce2:	0f 85 c3 00 00 00    	jne    f0104dab <syscall+0x4fb>
        perm = perm | PTE_U | PTE_P;
f0104ce8:	8b 75 18             	mov    0x18(%ebp),%esi
f0104ceb:	83 ce 05             	or     $0x5,%esi
        if ((perm | PTE_SYSCALL) != PTE_SYSCALL) {
f0104cee:	8b 45 18             	mov    0x18(%ebp),%eax
f0104cf1:	0d 07 0e 00 00       	or     $0xe07,%eax
f0104cf6:	3d 07 0e 00 00       	cmp    $0xe07,%eax
f0104cfb:	0f 85 b4 00 00 00    	jne    f0104db5 <syscall+0x505>
        if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL) {
f0104d01:	e8 05 14 00 00       	call   f010610b <cpunum>
f0104d06:	83 ec 04             	sub    $0x4,%esp
f0104d09:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d0c:	52                   	push   %edx
f0104d0d:	ff 75 14             	pushl  0x14(%ebp)
f0104d10:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d13:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104d19:	ff 70 60             	pushl  0x60(%eax)
f0104d1c:	e8 6f c7 ff ff       	call   f0101490 <page_lookup>
f0104d21:	83 c4 10             	add    $0x10,%esp
f0104d24:	85 c0                	test   %eax,%eax
f0104d26:	0f 84 93 00 00 00    	je     f0104dbf <syscall+0x50f>
        if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0104d2c:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104d30:	74 0c                	je     f0104d3e <syscall+0x48e>
f0104d32:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d35:	f6 02 02             	testb  $0x2,(%edx)
f0104d38:	0f 84 8b 00 00 00    	je     f0104dc9 <syscall+0x519>
        if (to_env->env_ipc_dstva != NULL) {
f0104d3e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d41:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104d44:	85 c9                	test   %ecx,%ecx
f0104d46:	74 1f                	je     f0104d67 <syscall+0x4b7>
            if (page_insert(to_env->env_pgdir, pp, to_env->env_ipc_dstva, (int)perm) < 0) {
f0104d48:	56                   	push   %esi
f0104d49:	51                   	push   %ecx
f0104d4a:	50                   	push   %eax
f0104d4b:	ff 72 60             	pushl  0x60(%edx)
f0104d4e:	e8 15 c8 ff ff       	call   f0101568 <page_insert>
f0104d53:	83 c4 10             	add    $0x10,%esp
f0104d56:	85 c0                	test   %eax,%eax
f0104d58:	79 0d                	jns    f0104d67 <syscall+0x4b7>
                return -E_NO_MEM;
f0104d5a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
            return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned )a4);
f0104d5f:	e9 9e fb ff ff       	jmp    f0104902 <syscall+0x52>
    if ((uint32_t)srcva < UTOP) {
f0104d64:	8b 75 18             	mov    0x18(%ebp),%esi
    to_env->env_ipc_from = curenv->env_id;
f0104d67:	e8 9f 13 00 00       	call   f010610b <cpunum>
f0104d6c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104d6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d72:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104d78:	8b 40 48             	mov    0x48(%eax),%eax
f0104d7b:	89 42 74             	mov    %eax,0x74(%edx)
    to_env->env_ipc_value = value;
f0104d7e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d81:	89 42 70             	mov    %eax,0x70(%edx)
    to_env->env_ipc_perm = (int)perm;
f0104d84:	89 72 78             	mov    %esi,0x78(%edx)
    to_env->env_status = ENV_RUNNABLE;
f0104d87:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
    to_env->env_ipc_recving = 0;
f0104d8e:	c6 42 68 00          	movb   $0x0,0x68(%edx)
f0104d92:	e9 6b fb ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104d97:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104d9c:	e9 61 fb ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_IPC_NOT_RECV;
f0104da1:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104da6:	e9 57 fb ff ff       	jmp    f0104902 <syscall+0x52>
            return -E_INVAL;
f0104dab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104db0:	e9 4d fb ff ff       	jmp    f0104902 <syscall+0x52>
            return -E_INVAL;
f0104db5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dba:	e9 43 fb ff ff       	jmp    f0104902 <syscall+0x52>
            return -E_INVAL;
f0104dbf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dc4:	e9 39 fb ff ff       	jmp    f0104902 <syscall+0x52>
            return -E_INVAL;
f0104dc9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dce:	e9 2f fb ff ff       	jmp    f0104902 <syscall+0x52>
            return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104dd3:	8b 75 10             	mov    0x10(%ebp),%esi
    if (envid2env(envid, &e, 1) != 0) {
f0104dd6:	83 ec 04             	sub    $0x4,%esp
f0104dd9:	6a 01                	push   $0x1
f0104ddb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dde:	50                   	push   %eax
f0104ddf:	ff 75 0c             	pushl  0xc(%ebp)
f0104de2:	e8 dc e5 ff ff       	call   f01033c3 <envid2env>
f0104de7:	89 c3                	mov    %eax,%ebx
f0104de9:	83 c4 10             	add    $0x10,%esp
f0104dec:	85 c0                	test   %eax,%eax
f0104dee:	75 4d                	jne    f0104e3d <syscall+0x58d>
    e->env_tf = *tf;
f0104df0:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104df8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    e->env_tf.tf_ds = GD_UD | 3;
f0104dfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dfd:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
    e->env_tf.tf_es = GD_UD | 3;
f0104e03:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
    e->env_tf.tf_ss = GD_UD | 3;
f0104e09:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
    e->env_tf.tf_cs = GD_UT | 3;
f0104e0f:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
    e->env_parent_id = curenv->env_id;
f0104e15:	e8 f1 12 00 00       	call   f010610b <cpunum>
f0104e1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e20:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104e26:	8b 40 48             	mov    0x48(%eax),%eax
f0104e29:	89 42 4c             	mov    %eax,0x4c(%edx)
    e->env_tf.tf_eflags &= ~(FL_IOPL_3 | FL_IOPL_2 | FL_IOPL_1);
f0104e2c:	8b 42 38             	mov    0x38(%edx),%eax
f0104e2f:	80 e4 cf             	and    $0xcf,%ah
f0104e32:	80 cc 02             	or     $0x2,%ah
f0104e35:	89 42 38             	mov    %eax,0x38(%edx)
f0104e38:	e9 c5 fa ff ff       	jmp    f0104902 <syscall+0x52>
        return -E_BAD_ENV;
f0104e3d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
            return sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f0104e42:	e9 bb fa ff ff       	jmp    f0104902 <syscall+0x52>
		return -E_INVAL;
f0104e47:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e4c:	e9 b1 fa ff ff       	jmp    f0104902 <syscall+0x52>
            return sys_ipc_recv((void *)a1);
f0104e51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    curenv->env_ipc_recving = 1;
f0104e54:	e8 b2 12 00 00       	call   f010610b <cpunum>
f0104e59:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e5c:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104e62:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_ipc_dstva = (uint32_t)dstva < UTOP ? dstva : (void *) UTOP;
f0104e66:	e8 a0 12 00 00       	call   f010610b <cpunum>
f0104e6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e6e:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104e74:	89 58 6c             	mov    %ebx,0x6c(%eax)
    curenv->env_tf.tf_regs.reg_eax = 0;
f0104e77:	e8 8f 12 00 00       	call   f010610b <cpunum>
f0104e7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7f:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104e85:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    curenv->env_status = ENV_NOT_RUNNABLE;
f0104e8c:	e8 7a 12 00 00       	call   f010610b <cpunum>
f0104e91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e94:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104e9a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
    sched_yield();
f0104ea1:	e8 78 f9 ff ff       	call   f010481e <sched_yield>
    curenv->env_ipc_recving = 1;
f0104ea6:	e8 60 12 00 00       	call   f010610b <cpunum>
f0104eab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eae:	8b 80 28 60 21 f0    	mov    -0xfde9fd8(%eax),%eax
f0104eb4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
    curenv->env_ipc_dstva = (uint32_t)dstva < UTOP ? dstva : (void *) UTOP;
f0104eb8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0104ebd:	eb a7                	jmp    f0104e66 <syscall+0x5b6>

f0104ebf <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ebf:	55                   	push   %ebp
f0104ec0:	89 e5                	mov    %esp,%ebp
f0104ec2:	57                   	push   %edi
f0104ec3:	56                   	push   %esi
f0104ec4:	53                   	push   %ebx
f0104ec5:	83 ec 14             	sub    $0x14,%esp
f0104ec8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ecb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ece:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ed1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ed4:	8b 32                	mov    (%edx),%esi
f0104ed6:	8b 01                	mov    (%ecx),%eax
f0104ed8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104edb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ee2:	eb 2f                	jmp    f0104f13 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104ee4:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104ee7:	39 c6                	cmp    %eax,%esi
f0104ee9:	7f 49                	jg     f0104f34 <stab_binsearch+0x75>
f0104eeb:	0f b6 0a             	movzbl (%edx),%ecx
f0104eee:	83 ea 0c             	sub    $0xc,%edx
f0104ef1:	39 f9                	cmp    %edi,%ecx
f0104ef3:	75 ef                	jne    f0104ee4 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104ef5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ef8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104efb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104eff:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f02:	73 35                	jae    f0104f39 <stab_binsearch+0x7a>
			*region_left = m;
f0104f04:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f07:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104f09:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104f0c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104f13:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104f16:	7f 4e                	jg     f0104f66 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f1b:	01 f0                	add    %esi,%eax
f0104f1d:	89 c3                	mov    %eax,%ebx
f0104f1f:	c1 eb 1f             	shr    $0x1f,%ebx
f0104f22:	01 c3                	add    %eax,%ebx
f0104f24:	d1 fb                	sar    %ebx
f0104f26:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104f29:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f2c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104f30:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104f32:	eb b3                	jmp    f0104ee7 <stab_binsearch+0x28>
			l = true_m + 1;
f0104f34:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104f37:	eb da                	jmp    f0104f13 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104f39:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104f3c:	76 14                	jbe    f0104f52 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104f3e:	83 e8 01             	sub    $0x1,%eax
f0104f41:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f44:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104f47:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104f49:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f50:	eb c1                	jmp    f0104f13 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104f52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f55:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104f57:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104f5b:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104f5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f64:	eb ad                	jmp    f0104f13 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104f66:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104f6a:	74 16                	je     f0104f82 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f6f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104f71:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f74:	8b 0e                	mov    (%esi),%ecx
f0104f76:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f79:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104f7c:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104f80:	eb 12                	jmp    f0104f94 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f85:	8b 00                	mov    (%eax),%eax
f0104f87:	83 e8 01             	sub    $0x1,%eax
f0104f8a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104f8d:	89 07                	mov    %eax,(%edi)
f0104f8f:	eb 16                	jmp    f0104fa7 <stab_binsearch+0xe8>
		     l--)
f0104f91:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104f94:	39 c1                	cmp    %eax,%ecx
f0104f96:	7d 0a                	jge    f0104fa2 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104f98:	0f b6 1a             	movzbl (%edx),%ebx
f0104f9b:	83 ea 0c             	sub    $0xc,%edx
f0104f9e:	39 fb                	cmp    %edi,%ebx
f0104fa0:	75 ef                	jne    f0104f91 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104fa2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fa5:	89 07                	mov    %eax,(%edi)
	}
}
f0104fa7:	83 c4 14             	add    $0x14,%esp
f0104faa:	5b                   	pop    %ebx
f0104fab:	5e                   	pop    %esi
f0104fac:	5f                   	pop    %edi
f0104fad:	5d                   	pop    %ebp
f0104fae:	c3                   	ret    

f0104faf <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104faf:	55                   	push   %ebp
f0104fb0:	89 e5                	mov    %esp,%ebp
f0104fb2:	57                   	push   %edi
f0104fb3:	56                   	push   %esi
f0104fb4:	53                   	push   %ebx
f0104fb5:	83 ec 4c             	sub    $0x4c,%esp
f0104fb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104fbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104fbe:	c7 07 44 80 10 f0    	movl   $0xf0108044,(%edi)
	info->eip_line = 0;
f0104fc4:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0104fcb:	c7 47 08 44 80 10 f0 	movl   $0xf0108044,0x8(%edi)
	info->eip_fn_namelen = 9;
f0104fd2:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104fd9:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0104fdc:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104fe3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0104fe9:	0f 86 2a 01 00 00    	jbe    f0105119 <debuginfo_eip+0x16a>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104fef:	c7 45 b8 72 7d 11 f0 	movl   $0xf0117d72,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104ff6:	c7 45 b4 8d 44 11 f0 	movl   $0xf011448d,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104ffd:	be 8c 44 11 f0       	mov    $0xf011448c,%esi
		stabs = __STAB_BEGIN__;
f0105002:	c7 45 bc 30 86 10 f0 	movl   $0xf0108630,-0x44(%ebp)
        user_mem_check(curenv, stabs, stab_end - stabs, PTE_P);
        user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_P);
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105009:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010500c:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f010500f:	0f 83 4e 02 00 00    	jae    f0105263 <debuginfo_eip+0x2b4>
f0105015:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105019:	0f 85 4b 02 00 00    	jne    f010526a <debuginfo_eip+0x2bb>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010501f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105026:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0105029:	c1 fe 02             	sar    $0x2,%esi
f010502c:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105032:	83 e8 01             	sub    $0x1,%eax
f0105035:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105038:	83 ec 08             	sub    $0x8,%esp
f010503b:	53                   	push   %ebx
f010503c:	6a 64                	push   $0x64
f010503e:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105041:	89 d1                	mov    %edx,%ecx
f0105043:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105046:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105049:	89 f0                	mov    %esi,%eax
f010504b:	e8 6f fe ff ff       	call   f0104ebf <stab_binsearch>
	if (lfile == 0)
f0105050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105053:	83 c4 10             	add    $0x10,%esp
f0105056:	85 c0                	test   %eax,%eax
f0105058:	0f 84 13 02 00 00    	je     f0105271 <debuginfo_eip+0x2c2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010505e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105061:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105064:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105067:	83 ec 08             	sub    $0x8,%esp
f010506a:	53                   	push   %ebx
f010506b:	6a 24                	push   $0x24
f010506d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105070:	89 d1                	mov    %edx,%ecx
f0105072:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105075:	89 f0                	mov    %esi,%eax
f0105077:	e8 43 fe ff ff       	call   f0104ebf <stab_binsearch>

	if (lfun <= rfun) {
f010507c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010507f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105082:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0105085:	83 c4 10             	add    $0x10,%esp
f0105088:	39 c8                	cmp    %ecx,%eax
f010508a:	0f 8f 16 01 00 00    	jg     f01051a6 <debuginfo_eip+0x1f7>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105090:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105093:	8d 0c 96             	lea    (%esi,%edx,4),%ecx
f0105096:	8b 11                	mov    (%ecx),%edx
f0105098:	8b 75 b8             	mov    -0x48(%ebp),%esi
f010509b:	2b 75 b4             	sub    -0x4c(%ebp),%esi
f010509e:	39 f2                	cmp    %esi,%edx
f01050a0:	73 06                	jae    f01050a8 <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01050a2:	03 55 b4             	add    -0x4c(%ebp),%edx
f01050a5:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01050a8:	8b 51 08             	mov    0x8(%ecx),%edx
f01050ab:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f01050ae:	29 d3                	sub    %edx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f01050b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01050b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01050b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01050b9:	83 ec 08             	sub    $0x8,%esp
f01050bc:	6a 3a                	push   $0x3a
f01050be:	ff 77 08             	pushl  0x8(%edi)
f01050c1:	e8 06 0a 00 00       	call   f0105acc <strfind>
f01050c6:	2b 47 08             	sub    0x8(%edi),%eax
f01050c9:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01050cc:	83 c4 08             	add    $0x8,%esp
f01050cf:	53                   	push   %ebx
f01050d0:	6a 44                	push   $0x44
f01050d2:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01050d5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01050d8:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f01050db:	89 d8                	mov    %ebx,%eax
f01050dd:	e8 dd fd ff ff       	call   f0104ebf <stab_binsearch>
        if (lline <= rline) {
f01050e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01050e5:	83 c4 10             	add    $0x10,%esp
f01050e8:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01050eb:	0f 8f 87 01 00 00    	jg     f0105278 <debuginfo_eip+0x2c9>
            info->eip_line = stabs[lline].n_desc;
f01050f1:	89 d0                	mov    %edx,%eax
f01050f3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01050f6:	c1 e2 02             	shl    $0x2,%edx
f01050f9:	0f b7 4c 13 06       	movzwl 0x6(%ebx,%edx,1),%ecx
f01050fe:	89 4f 04             	mov    %ecx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105101:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105104:	8d 54 13 04          	lea    0x4(%ebx,%edx,1),%edx
f0105108:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010510c:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105111:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105114:	e9 aa 00 00 00       	jmp    f01051c3 <debuginfo_eip+0x214>
        user_mem_check(curenv, usd, 0, PTE_P);
f0105119:	e8 ed 0f 00 00       	call   f010610b <cpunum>
f010511e:	6a 01                	push   $0x1
f0105120:	6a 00                	push   $0x0
f0105122:	68 00 00 20 00       	push   $0x200000
f0105127:	6b c0 74             	imul   $0x74,%eax,%eax
f010512a:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0105130:	e8 a9 e1 ff ff       	call   f01032de <user_mem_check>
		stabs = usd->stabs;
f0105135:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f010513b:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f010513e:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105144:	a1 08 00 20 00       	mov    0x200008,%eax
f0105149:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010514c:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105152:	89 55 b8             	mov    %edx,-0x48(%ebp)
        user_mem_check(curenv, stabs, stab_end - stabs, PTE_P);
f0105155:	e8 b1 0f 00 00       	call   f010610b <cpunum>
f010515a:	6a 01                	push   $0x1
f010515c:	89 f2                	mov    %esi,%edx
f010515e:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105161:	29 ca                	sub    %ecx,%edx
f0105163:	c1 fa 02             	sar    $0x2,%edx
f0105166:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010516c:	52                   	push   %edx
f010516d:	51                   	push   %ecx
f010516e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105171:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0105177:	e8 62 e1 ff ff       	call   f01032de <user_mem_check>
        user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_P);
f010517c:	83 c4 20             	add    $0x20,%esp
f010517f:	e8 87 0f 00 00       	call   f010610b <cpunum>
f0105184:	6a 01                	push   $0x1
f0105186:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105189:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010518c:	29 ca                	sub    %ecx,%edx
f010518e:	52                   	push   %edx
f010518f:	51                   	push   %ecx
f0105190:	6b c0 74             	imul   $0x74,%eax,%eax
f0105193:	ff b0 28 60 21 f0    	pushl  -0xfde9fd8(%eax)
f0105199:	e8 40 e1 ff ff       	call   f01032de <user_mem_check>
f010519e:	83 c4 10             	add    $0x10,%esp
f01051a1:	e9 63 fe ff ff       	jmp    f0105009 <debuginfo_eip+0x5a>
		info->eip_fn_addr = addr;
f01051a6:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f01051a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01051af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01051b5:	e9 ff fe ff ff       	jmp    f01050b9 <debuginfo_eip+0x10a>
f01051ba:	83 e8 01             	sub    $0x1,%eax
f01051bd:	83 ea 0c             	sub    $0xc,%edx
f01051c0:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f01051c3:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f01051c6:	39 c6                	cmp    %eax,%esi
f01051c8:	7f 24                	jg     f01051ee <debuginfo_eip+0x23f>
	       && stabs[lline].n_type != N_SOL
f01051ca:	0f b6 0a             	movzbl (%edx),%ecx
f01051cd:	80 f9 84             	cmp    $0x84,%cl
f01051d0:	74 46                	je     f0105218 <debuginfo_eip+0x269>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01051d2:	80 f9 64             	cmp    $0x64,%cl
f01051d5:	75 e3                	jne    f01051ba <debuginfo_eip+0x20b>
f01051d7:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01051db:	74 dd                	je     f01051ba <debuginfo_eip+0x20b>
f01051dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01051e0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01051e4:	74 3b                	je     f0105221 <debuginfo_eip+0x272>
f01051e6:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01051e9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01051ec:	eb 33                	jmp    f0105221 <debuginfo_eip+0x272>
f01051ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01051f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051f4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01051f7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01051fc:	39 da                	cmp    %ebx,%edx
f01051fe:	0f 8d 80 00 00 00    	jge    f0105284 <debuginfo_eip+0x2d5>
		for (lline = lfun + 1;
f0105204:	83 c2 01             	add    $0x1,%edx
f0105207:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010520a:	89 d0                	mov    %edx,%eax
f010520c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010520f:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105212:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0105216:	eb 32                	jmp    f010524a <debuginfo_eip+0x29b>
f0105218:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010521b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010521f:	75 1d                	jne    f010523e <debuginfo_eip+0x28f>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105221:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105224:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105227:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010522a:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010522d:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0105230:	29 f0                	sub    %esi,%eax
f0105232:	39 c2                	cmp    %eax,%edx
f0105234:	73 bb                	jae    f01051f1 <debuginfo_eip+0x242>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105236:	89 f0                	mov    %esi,%eax
f0105238:	01 d0                	add    %edx,%eax
f010523a:	89 07                	mov    %eax,(%edi)
f010523c:	eb b3                	jmp    f01051f1 <debuginfo_eip+0x242>
f010523e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105241:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105244:	eb db                	jmp    f0105221 <debuginfo_eip+0x272>
			info->eip_fn_narg++;
f0105246:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f010524a:	39 c3                	cmp    %eax,%ebx
f010524c:	7e 31                	jle    f010527f <debuginfo_eip+0x2d0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010524e:	0f b6 0a             	movzbl (%edx),%ecx
f0105251:	83 c0 01             	add    $0x1,%eax
f0105254:	83 c2 0c             	add    $0xc,%edx
f0105257:	80 f9 a0             	cmp    $0xa0,%cl
f010525a:	74 ea                	je     f0105246 <debuginfo_eip+0x297>
	return 0;
f010525c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105261:	eb 21                	jmp    f0105284 <debuginfo_eip+0x2d5>
		return -1;
f0105263:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105268:	eb 1a                	jmp    f0105284 <debuginfo_eip+0x2d5>
f010526a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010526f:	eb 13                	jmp    f0105284 <debuginfo_eip+0x2d5>
		return -1;
f0105271:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105276:	eb 0c                	jmp    f0105284 <debuginfo_eip+0x2d5>
            return -1;
f0105278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010527d:	eb 05                	jmp    f0105284 <debuginfo_eip+0x2d5>
	return 0;
f010527f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105284:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105287:	5b                   	pop    %ebx
f0105288:	5e                   	pop    %esi
f0105289:	5f                   	pop    %edi
f010528a:	5d                   	pop    %ebp
f010528b:	c3                   	ret    

f010528c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010528c:	55                   	push   %ebp
f010528d:	89 e5                	mov    %esp,%ebp
f010528f:	57                   	push   %edi
f0105290:	56                   	push   %esi
f0105291:	53                   	push   %ebx
f0105292:	83 ec 1c             	sub    $0x1c,%esp
f0105295:	89 c7                	mov    %eax,%edi
f0105297:	89 d6                	mov    %edx,%esi
f0105299:	8b 45 08             	mov    0x8(%ebp),%eax
f010529c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010529f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01052a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052a8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01052b3:	39 d3                	cmp    %edx,%ebx
f01052b5:	72 05                	jb     f01052bc <printnum+0x30>
f01052b7:	39 45 10             	cmp    %eax,0x10(%ebp)
f01052ba:	77 7a                	ja     f0105336 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01052bc:	83 ec 0c             	sub    $0xc,%esp
f01052bf:	ff 75 18             	pushl  0x18(%ebp)
f01052c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01052c8:	53                   	push   %ebx
f01052c9:	ff 75 10             	pushl  0x10(%ebp)
f01052cc:	83 ec 08             	sub    $0x8,%esp
f01052cf:	ff 75 e4             	pushl  -0x1c(%ebp)
f01052d2:	ff 75 e0             	pushl  -0x20(%ebp)
f01052d5:	ff 75 dc             	pushl  -0x24(%ebp)
f01052d8:	ff 75 d8             	pushl  -0x28(%ebp)
f01052db:	e8 20 12 00 00       	call   f0106500 <__udivdi3>
f01052e0:	83 c4 18             	add    $0x18,%esp
f01052e3:	52                   	push   %edx
f01052e4:	50                   	push   %eax
f01052e5:	89 f2                	mov    %esi,%edx
f01052e7:	89 f8                	mov    %edi,%eax
f01052e9:	e8 9e ff ff ff       	call   f010528c <printnum>
f01052ee:	83 c4 20             	add    $0x20,%esp
f01052f1:	eb 13                	jmp    f0105306 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01052f3:	83 ec 08             	sub    $0x8,%esp
f01052f6:	56                   	push   %esi
f01052f7:	ff 75 18             	pushl  0x18(%ebp)
f01052fa:	ff d7                	call   *%edi
f01052fc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01052ff:	83 eb 01             	sub    $0x1,%ebx
f0105302:	85 db                	test   %ebx,%ebx
f0105304:	7f ed                	jg     f01052f3 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105306:	83 ec 08             	sub    $0x8,%esp
f0105309:	56                   	push   %esi
f010530a:	83 ec 04             	sub    $0x4,%esp
f010530d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105310:	ff 75 e0             	pushl  -0x20(%ebp)
f0105313:	ff 75 dc             	pushl  -0x24(%ebp)
f0105316:	ff 75 d8             	pushl  -0x28(%ebp)
f0105319:	e8 02 13 00 00       	call   f0106620 <__umoddi3>
f010531e:	83 c4 14             	add    $0x14,%esp
f0105321:	0f be 80 4e 80 10 f0 	movsbl -0xfef7fb2(%eax),%eax
f0105328:	50                   	push   %eax
f0105329:	ff d7                	call   *%edi
}
f010532b:	83 c4 10             	add    $0x10,%esp
f010532e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105331:	5b                   	pop    %ebx
f0105332:	5e                   	pop    %esi
f0105333:	5f                   	pop    %edi
f0105334:	5d                   	pop    %ebp
f0105335:	c3                   	ret    
f0105336:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105339:	eb c4                	jmp    f01052ff <printnum+0x73>

f010533b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010533b:	55                   	push   %ebp
f010533c:	89 e5                	mov    %esp,%ebp
f010533e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105341:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105345:	8b 10                	mov    (%eax),%edx
f0105347:	3b 50 04             	cmp    0x4(%eax),%edx
f010534a:	73 0a                	jae    f0105356 <sprintputch+0x1b>
		*b->buf++ = ch;
f010534c:	8d 4a 01             	lea    0x1(%edx),%ecx
f010534f:	89 08                	mov    %ecx,(%eax)
f0105351:	8b 45 08             	mov    0x8(%ebp),%eax
f0105354:	88 02                	mov    %al,(%edx)
}
f0105356:	5d                   	pop    %ebp
f0105357:	c3                   	ret    

f0105358 <printfmt>:
{
f0105358:	55                   	push   %ebp
f0105359:	89 e5                	mov    %esp,%ebp
f010535b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010535e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105361:	50                   	push   %eax
f0105362:	ff 75 10             	pushl  0x10(%ebp)
f0105365:	ff 75 0c             	pushl  0xc(%ebp)
f0105368:	ff 75 08             	pushl  0x8(%ebp)
f010536b:	e8 05 00 00 00       	call   f0105375 <vprintfmt>
}
f0105370:	83 c4 10             	add    $0x10,%esp
f0105373:	c9                   	leave  
f0105374:	c3                   	ret    

f0105375 <vprintfmt>:
{
f0105375:	55                   	push   %ebp
f0105376:	89 e5                	mov    %esp,%ebp
f0105378:	57                   	push   %edi
f0105379:	56                   	push   %esi
f010537a:	53                   	push   %ebx
f010537b:	83 ec 2c             	sub    $0x2c,%esp
f010537e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105381:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105384:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105387:	e9 c1 03 00 00       	jmp    f010574d <vprintfmt+0x3d8>
		padc = ' ';
f010538c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0105390:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0105397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f010539e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01053a5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01053aa:	8d 47 01             	lea    0x1(%edi),%eax
f01053ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053b0:	0f b6 17             	movzbl (%edi),%edx
f01053b3:	8d 42 dd             	lea    -0x23(%edx),%eax
f01053b6:	3c 55                	cmp    $0x55,%al
f01053b8:	0f 87 12 04 00 00    	ja     f01057d0 <vprintfmt+0x45b>
f01053be:	0f b6 c0             	movzbl %al,%eax
f01053c1:	ff 24 85 a0 81 10 f0 	jmp    *-0xfef7e60(,%eax,4)
f01053c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01053cb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01053cf:	eb d9                	jmp    f01053aa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f01053d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01053d4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01053d8:	eb d0                	jmp    f01053aa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f01053da:	0f b6 d2             	movzbl %dl,%edx
f01053dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f01053e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01053e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f01053e8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01053eb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01053ef:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01053f2:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01053f5:	83 f9 09             	cmp    $0x9,%ecx
f01053f8:	77 55                	ja     f010544f <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f01053fa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01053fd:	eb e9                	jmp    f01053e8 <vprintfmt+0x73>
			precision = va_arg(ap, int);
f01053ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105402:	8b 00                	mov    (%eax),%eax
f0105404:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105407:	8b 45 14             	mov    0x14(%ebp),%eax
f010540a:	8d 40 04             	lea    0x4(%eax),%eax
f010540d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0105413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105417:	79 91                	jns    f01053aa <vprintfmt+0x35>
				width = precision, precision = -1;
f0105419:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010541c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010541f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105426:	eb 82                	jmp    f01053aa <vprintfmt+0x35>
f0105428:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010542b:	85 c0                	test   %eax,%eax
f010542d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105432:	0f 49 d0             	cmovns %eax,%edx
f0105435:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010543b:	e9 6a ff ff ff       	jmp    f01053aa <vprintfmt+0x35>
f0105440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0105443:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010544a:	e9 5b ff ff ff       	jmp    f01053aa <vprintfmt+0x35>
f010544f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105452:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105455:	eb bc                	jmp    f0105413 <vprintfmt+0x9e>
			lflag++;
f0105457:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010545a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010545d:	e9 48 ff ff ff       	jmp    f01053aa <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0105462:	8b 45 14             	mov    0x14(%ebp),%eax
f0105465:	8d 78 04             	lea    0x4(%eax),%edi
f0105468:	83 ec 08             	sub    $0x8,%esp
f010546b:	53                   	push   %ebx
f010546c:	ff 30                	pushl  (%eax)
f010546e:	ff d6                	call   *%esi
			break;
f0105470:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105473:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105476:	e9 cf 02 00 00       	jmp    f010574a <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f010547b:	8b 45 14             	mov    0x14(%ebp),%eax
f010547e:	8d 78 04             	lea    0x4(%eax),%edi
f0105481:	8b 00                	mov    (%eax),%eax
f0105483:	99                   	cltd   
f0105484:	31 d0                	xor    %edx,%eax
f0105486:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105488:	83 f8 0f             	cmp    $0xf,%eax
f010548b:	7f 23                	jg     f01054b0 <vprintfmt+0x13b>
f010548d:	8b 14 85 00 83 10 f0 	mov    -0xfef7d00(,%eax,4),%edx
f0105494:	85 d2                	test   %edx,%edx
f0105496:	74 18                	je     f01054b0 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f0105498:	52                   	push   %edx
f0105499:	68 ed 77 10 f0       	push   $0xf01077ed
f010549e:	53                   	push   %ebx
f010549f:	56                   	push   %esi
f01054a0:	e8 b3 fe ff ff       	call   f0105358 <printfmt>
f01054a5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01054a8:	89 7d 14             	mov    %edi,0x14(%ebp)
f01054ab:	e9 9a 02 00 00       	jmp    f010574a <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f01054b0:	50                   	push   %eax
f01054b1:	68 66 80 10 f0       	push   $0xf0108066
f01054b6:	53                   	push   %ebx
f01054b7:	56                   	push   %esi
f01054b8:	e8 9b fe ff ff       	call   f0105358 <printfmt>
f01054bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01054c0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01054c3:	e9 82 02 00 00       	jmp    f010574a <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f01054c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054cb:	83 c0 04             	add    $0x4,%eax
f01054ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01054d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01054d4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01054d6:	85 ff                	test   %edi,%edi
f01054d8:	b8 5f 80 10 f0       	mov    $0xf010805f,%eax
f01054dd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01054e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054e4:	0f 8e bd 00 00 00    	jle    f01055a7 <vprintfmt+0x232>
f01054ea:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01054ee:	75 0e                	jne    f01054fe <vprintfmt+0x189>
f01054f0:	89 75 08             	mov    %esi,0x8(%ebp)
f01054f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01054f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01054f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01054fc:	eb 6d                	jmp    f010556b <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f01054fe:	83 ec 08             	sub    $0x8,%esp
f0105501:	ff 75 d0             	pushl  -0x30(%ebp)
f0105504:	57                   	push   %edi
f0105505:	e8 7e 04 00 00       	call   f0105988 <strnlen>
f010550a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010550d:	29 c1                	sub    %eax,%ecx
f010550f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105512:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105515:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105519:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010551c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010551f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105521:	eb 0f                	jmp    f0105532 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0105523:	83 ec 08             	sub    $0x8,%esp
f0105526:	53                   	push   %ebx
f0105527:	ff 75 e0             	pushl  -0x20(%ebp)
f010552a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010552c:	83 ef 01             	sub    $0x1,%edi
f010552f:	83 c4 10             	add    $0x10,%esp
f0105532:	85 ff                	test   %edi,%edi
f0105534:	7f ed                	jg     f0105523 <vprintfmt+0x1ae>
f0105536:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105539:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010553c:	85 c9                	test   %ecx,%ecx
f010553e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105543:	0f 49 c1             	cmovns %ecx,%eax
f0105546:	29 c1                	sub    %eax,%ecx
f0105548:	89 75 08             	mov    %esi,0x8(%ebp)
f010554b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010554e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105551:	89 cb                	mov    %ecx,%ebx
f0105553:	eb 16                	jmp    f010556b <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f0105555:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105559:	75 31                	jne    f010558c <vprintfmt+0x217>
					putch(ch, putdat);
f010555b:	83 ec 08             	sub    $0x8,%esp
f010555e:	ff 75 0c             	pushl  0xc(%ebp)
f0105561:	50                   	push   %eax
f0105562:	ff 55 08             	call   *0x8(%ebp)
f0105565:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105568:	83 eb 01             	sub    $0x1,%ebx
f010556b:	83 c7 01             	add    $0x1,%edi
f010556e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0105572:	0f be c2             	movsbl %dl,%eax
f0105575:	85 c0                	test   %eax,%eax
f0105577:	74 59                	je     f01055d2 <vprintfmt+0x25d>
f0105579:	85 f6                	test   %esi,%esi
f010557b:	78 d8                	js     f0105555 <vprintfmt+0x1e0>
f010557d:	83 ee 01             	sub    $0x1,%esi
f0105580:	79 d3                	jns    f0105555 <vprintfmt+0x1e0>
f0105582:	89 df                	mov    %ebx,%edi
f0105584:	8b 75 08             	mov    0x8(%ebp),%esi
f0105587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010558a:	eb 37                	jmp    f01055c3 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f010558c:	0f be d2             	movsbl %dl,%edx
f010558f:	83 ea 20             	sub    $0x20,%edx
f0105592:	83 fa 5e             	cmp    $0x5e,%edx
f0105595:	76 c4                	jbe    f010555b <vprintfmt+0x1e6>
					putch('?', putdat);
f0105597:	83 ec 08             	sub    $0x8,%esp
f010559a:	ff 75 0c             	pushl  0xc(%ebp)
f010559d:	6a 3f                	push   $0x3f
f010559f:	ff 55 08             	call   *0x8(%ebp)
f01055a2:	83 c4 10             	add    $0x10,%esp
f01055a5:	eb c1                	jmp    f0105568 <vprintfmt+0x1f3>
f01055a7:	89 75 08             	mov    %esi,0x8(%ebp)
f01055aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01055b3:	eb b6                	jmp    f010556b <vprintfmt+0x1f6>
				putch(' ', putdat);
f01055b5:	83 ec 08             	sub    $0x8,%esp
f01055b8:	53                   	push   %ebx
f01055b9:	6a 20                	push   $0x20
f01055bb:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01055bd:	83 ef 01             	sub    $0x1,%edi
f01055c0:	83 c4 10             	add    $0x10,%esp
f01055c3:	85 ff                	test   %edi,%edi
f01055c5:	7f ee                	jg     f01055b5 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f01055c7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01055ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01055cd:	e9 78 01 00 00       	jmp    f010574a <vprintfmt+0x3d5>
f01055d2:	89 df                	mov    %ebx,%edi
f01055d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01055d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01055da:	eb e7                	jmp    f01055c3 <vprintfmt+0x24e>
	if (lflag >= 2)
f01055dc:	83 f9 01             	cmp    $0x1,%ecx
f01055df:	7e 3f                	jle    f0105620 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f01055e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01055e4:	8b 50 04             	mov    0x4(%eax),%edx
f01055e7:	8b 00                	mov    (%eax),%eax
f01055e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01055ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01055f2:	8d 40 08             	lea    0x8(%eax),%eax
f01055f5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01055f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01055fc:	79 5c                	jns    f010565a <vprintfmt+0x2e5>
				putch('-', putdat);
f01055fe:	83 ec 08             	sub    $0x8,%esp
f0105601:	53                   	push   %ebx
f0105602:	6a 2d                	push   $0x2d
f0105604:	ff d6                	call   *%esi
				num = -(long long) num;
f0105606:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105609:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010560c:	f7 da                	neg    %edx
f010560e:	83 d1 00             	adc    $0x0,%ecx
f0105611:	f7 d9                	neg    %ecx
f0105613:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105616:	b8 0a 00 00 00       	mov    $0xa,%eax
f010561b:	e9 10 01 00 00       	jmp    f0105730 <vprintfmt+0x3bb>
	else if (lflag)
f0105620:	85 c9                	test   %ecx,%ecx
f0105622:	75 1b                	jne    f010563f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f0105624:	8b 45 14             	mov    0x14(%ebp),%eax
f0105627:	8b 00                	mov    (%eax),%eax
f0105629:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010562c:	89 c1                	mov    %eax,%ecx
f010562e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105631:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105634:	8b 45 14             	mov    0x14(%ebp),%eax
f0105637:	8d 40 04             	lea    0x4(%eax),%eax
f010563a:	89 45 14             	mov    %eax,0x14(%ebp)
f010563d:	eb b9                	jmp    f01055f8 <vprintfmt+0x283>
		return va_arg(*ap, long);
f010563f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105642:	8b 00                	mov    (%eax),%eax
f0105644:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105647:	89 c1                	mov    %eax,%ecx
f0105649:	c1 f9 1f             	sar    $0x1f,%ecx
f010564c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010564f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105652:	8d 40 04             	lea    0x4(%eax),%eax
f0105655:	89 45 14             	mov    %eax,0x14(%ebp)
f0105658:	eb 9e                	jmp    f01055f8 <vprintfmt+0x283>
			num = getint(&ap, lflag);
f010565a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010565d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105660:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105665:	e9 c6 00 00 00       	jmp    f0105730 <vprintfmt+0x3bb>
	if (lflag >= 2)
f010566a:	83 f9 01             	cmp    $0x1,%ecx
f010566d:	7e 18                	jle    f0105687 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f010566f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105672:	8b 10                	mov    (%eax),%edx
f0105674:	8b 48 04             	mov    0x4(%eax),%ecx
f0105677:	8d 40 08             	lea    0x8(%eax),%eax
f010567a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010567d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105682:	e9 a9 00 00 00       	jmp    f0105730 <vprintfmt+0x3bb>
	else if (lflag)
f0105687:	85 c9                	test   %ecx,%ecx
f0105689:	75 1a                	jne    f01056a5 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f010568b:	8b 45 14             	mov    0x14(%ebp),%eax
f010568e:	8b 10                	mov    (%eax),%edx
f0105690:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105695:	8d 40 04             	lea    0x4(%eax),%eax
f0105698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010569b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056a0:	e9 8b 00 00 00       	jmp    f0105730 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01056a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a8:	8b 10                	mov    (%eax),%edx
f01056aa:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056af:	8d 40 04             	lea    0x4(%eax),%eax
f01056b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056b5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056ba:	eb 74                	jmp    f0105730 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01056bc:	83 f9 01             	cmp    $0x1,%ecx
f01056bf:	7e 15                	jle    f01056d6 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f01056c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056c4:	8b 10                	mov    (%eax),%edx
f01056c6:	8b 48 04             	mov    0x4(%eax),%ecx
f01056c9:	8d 40 08             	lea    0x8(%eax),%eax
f01056cc:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f01056cf:	b8 08 00 00 00       	mov    $0x8,%eax
f01056d4:	eb 5a                	jmp    f0105730 <vprintfmt+0x3bb>
	else if (lflag)
f01056d6:	85 c9                	test   %ecx,%ecx
f01056d8:	75 17                	jne    f01056f1 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f01056da:	8b 45 14             	mov    0x14(%ebp),%eax
f01056dd:	8b 10                	mov    (%eax),%edx
f01056df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056e4:	8d 40 04             	lea    0x4(%eax),%eax
f01056e7:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f01056ea:	b8 08 00 00 00       	mov    $0x8,%eax
f01056ef:	eb 3f                	jmp    f0105730 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01056f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f4:	8b 10                	mov    (%eax),%edx
f01056f6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056fb:	8d 40 04             	lea    0x4(%eax),%eax
f01056fe:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
f0105701:	b8 08 00 00 00       	mov    $0x8,%eax
f0105706:	eb 28                	jmp    f0105730 <vprintfmt+0x3bb>
			putch('0', putdat);
f0105708:	83 ec 08             	sub    $0x8,%esp
f010570b:	53                   	push   %ebx
f010570c:	6a 30                	push   $0x30
f010570e:	ff d6                	call   *%esi
			putch('x', putdat);
f0105710:	83 c4 08             	add    $0x8,%esp
f0105713:	53                   	push   %ebx
f0105714:	6a 78                	push   $0x78
f0105716:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105718:	8b 45 14             	mov    0x14(%ebp),%eax
f010571b:	8b 10                	mov    (%eax),%edx
f010571d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105722:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105725:	8d 40 04             	lea    0x4(%eax),%eax
f0105728:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010572b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105730:	83 ec 0c             	sub    $0xc,%esp
f0105733:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105737:	57                   	push   %edi
f0105738:	ff 75 e0             	pushl  -0x20(%ebp)
f010573b:	50                   	push   %eax
f010573c:	51                   	push   %ecx
f010573d:	52                   	push   %edx
f010573e:	89 da                	mov    %ebx,%edx
f0105740:	89 f0                	mov    %esi,%eax
f0105742:	e8 45 fb ff ff       	call   f010528c <printnum>
			break;
f0105747:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010574a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010574d:	83 c7 01             	add    $0x1,%edi
f0105750:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105754:	83 f8 25             	cmp    $0x25,%eax
f0105757:	0f 84 2f fc ff ff    	je     f010538c <vprintfmt+0x17>
			if (ch == '\0')
f010575d:	85 c0                	test   %eax,%eax
f010575f:	0f 84 8b 00 00 00    	je     f01057f0 <vprintfmt+0x47b>
			putch(ch, putdat);
f0105765:	83 ec 08             	sub    $0x8,%esp
f0105768:	53                   	push   %ebx
f0105769:	50                   	push   %eax
f010576a:	ff d6                	call   *%esi
f010576c:	83 c4 10             	add    $0x10,%esp
f010576f:	eb dc                	jmp    f010574d <vprintfmt+0x3d8>
	if (lflag >= 2)
f0105771:	83 f9 01             	cmp    $0x1,%ecx
f0105774:	7e 15                	jle    f010578b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f0105776:	8b 45 14             	mov    0x14(%ebp),%eax
f0105779:	8b 10                	mov    (%eax),%edx
f010577b:	8b 48 04             	mov    0x4(%eax),%ecx
f010577e:	8d 40 08             	lea    0x8(%eax),%eax
f0105781:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105784:	b8 10 00 00 00       	mov    $0x10,%eax
f0105789:	eb a5                	jmp    f0105730 <vprintfmt+0x3bb>
	else if (lflag)
f010578b:	85 c9                	test   %ecx,%ecx
f010578d:	75 17                	jne    f01057a6 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f010578f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105792:	8b 10                	mov    (%eax),%edx
f0105794:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105799:	8d 40 04             	lea    0x4(%eax),%eax
f010579c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010579f:	b8 10 00 00 00       	mov    $0x10,%eax
f01057a4:	eb 8a                	jmp    f0105730 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f01057a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01057a9:	8b 10                	mov    (%eax),%edx
f01057ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057b0:	8d 40 04             	lea    0x4(%eax),%eax
f01057b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057b6:	b8 10 00 00 00       	mov    $0x10,%eax
f01057bb:	e9 70 ff ff ff       	jmp    f0105730 <vprintfmt+0x3bb>
			putch(ch, putdat);
f01057c0:	83 ec 08             	sub    $0x8,%esp
f01057c3:	53                   	push   %ebx
f01057c4:	6a 25                	push   $0x25
f01057c6:	ff d6                	call   *%esi
			break;
f01057c8:	83 c4 10             	add    $0x10,%esp
f01057cb:	e9 7a ff ff ff       	jmp    f010574a <vprintfmt+0x3d5>
			putch('%', putdat);
f01057d0:	83 ec 08             	sub    $0x8,%esp
f01057d3:	53                   	push   %ebx
f01057d4:	6a 25                	push   $0x25
f01057d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01057d8:	83 c4 10             	add    $0x10,%esp
f01057db:	89 f8                	mov    %edi,%eax
f01057dd:	eb 03                	jmp    f01057e2 <vprintfmt+0x46d>
f01057df:	83 e8 01             	sub    $0x1,%eax
f01057e2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01057e6:	75 f7                	jne    f01057df <vprintfmt+0x46a>
f01057e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01057eb:	e9 5a ff ff ff       	jmp    f010574a <vprintfmt+0x3d5>
}
f01057f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057f3:	5b                   	pop    %ebx
f01057f4:	5e                   	pop    %esi
f01057f5:	5f                   	pop    %edi
f01057f6:	5d                   	pop    %ebp
f01057f7:	c3                   	ret    

f01057f8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01057f8:	55                   	push   %ebp
f01057f9:	89 e5                	mov    %esp,%ebp
f01057fb:	83 ec 18             	sub    $0x18,%esp
f01057fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105801:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105804:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105807:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010580b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010580e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105815:	85 c0                	test   %eax,%eax
f0105817:	74 26                	je     f010583f <vsnprintf+0x47>
f0105819:	85 d2                	test   %edx,%edx
f010581b:	7e 22                	jle    f010583f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010581d:	ff 75 14             	pushl  0x14(%ebp)
f0105820:	ff 75 10             	pushl  0x10(%ebp)
f0105823:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105826:	50                   	push   %eax
f0105827:	68 3b 53 10 f0       	push   $0xf010533b
f010582c:	e8 44 fb ff ff       	call   f0105375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105831:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105834:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105837:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010583a:	83 c4 10             	add    $0x10,%esp
}
f010583d:	c9                   	leave  
f010583e:	c3                   	ret    
		return -E_INVAL;
f010583f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105844:	eb f7                	jmp    f010583d <vsnprintf+0x45>

f0105846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105846:	55                   	push   %ebp
f0105847:	89 e5                	mov    %esp,%ebp
f0105849:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010584c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010584f:	50                   	push   %eax
f0105850:	ff 75 10             	pushl  0x10(%ebp)
f0105853:	ff 75 0c             	pushl  0xc(%ebp)
f0105856:	ff 75 08             	pushl  0x8(%ebp)
f0105859:	e8 9a ff ff ff       	call   f01057f8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010585e:	c9                   	leave  
f010585f:	c3                   	ret    

f0105860 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105860:	55                   	push   %ebp
f0105861:	89 e5                	mov    %esp,%ebp
f0105863:	57                   	push   %edi
f0105864:	56                   	push   %esi
f0105865:	53                   	push   %ebx
f0105866:	83 ec 0c             	sub    $0xc,%esp
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105869:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010586d:	74 13                	je     f0105882 <readline+0x22>
		cprintf("%s", prompt);
f010586f:	83 ec 08             	sub    $0x8,%esp
f0105872:	ff 75 08             	pushl  0x8(%ebp)
f0105875:	68 ed 77 10 f0       	push   $0xf01077ed
f010587a:	e8 09 e5 ff ff       	call   f0103d88 <cprintf>
f010587f:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105882:	83 ec 0c             	sub    $0xc,%esp
f0105885:	6a 00                	push   $0x0
f0105887:	e8 37 af ff ff       	call   f01007c3 <iscons>
f010588c:	89 c7                	mov    %eax,%edi
f010588e:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105891:	be 00 00 00 00       	mov    $0x0,%esi
f0105896:	eb 57                	jmp    f01058ef <readline+0x8f>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105898:	83 f8 f8             	cmp    $0xfffffff8,%eax
f010589b:	74 11                	je     f01058ae <readline+0x4e>
				cprintf("read error: %e\n", c);
f010589d:	83 ec 08             	sub    $0x8,%esp
f01058a0:	50                   	push   %eax
f01058a1:	68 5f 83 10 f0       	push   $0xf010835f
f01058a6:	e8 dd e4 ff ff       	call   f0103d88 <cprintf>
f01058ab:	83 c4 10             	add    $0x10,%esp
            cprintf("[readline]------------- 1 %s \n", prompt);
f01058ae:	83 ec 08             	sub    $0x8,%esp
f01058b1:	ff 75 08             	pushl  0x8(%ebp)
f01058b4:	68 70 83 10 f0       	push   $0xf0108370
f01058b9:	e8 ca e4 ff ff       	call   f0103d88 <cprintf>
			return NULL;
f01058be:	83 c4 10             	add    $0x10,%esp
f01058c1:	b8 00 00 00 00       	mov    $0x0,%eax
			buf[i] = 0;
            cprintf("[readline]------------- 2 %s \n", buf );
			return buf;
		}
	}
}
f01058c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058c9:	5b                   	pop    %ebx
f01058ca:	5e                   	pop    %esi
f01058cb:	5f                   	pop    %edi
f01058cc:	5d                   	pop    %ebp
f01058cd:	c3                   	ret    
			if (echoing)
f01058ce:	85 ff                	test   %edi,%edi
f01058d0:	75 05                	jne    f01058d7 <readline+0x77>
			i--;
f01058d2:	83 ee 01             	sub    $0x1,%esi
f01058d5:	eb 18                	jmp    f01058ef <readline+0x8f>
				cputchar('\b');
f01058d7:	83 ec 0c             	sub    $0xc,%esp
f01058da:	6a 08                	push   $0x8
f01058dc:	e8 c1 ae ff ff       	call   f01007a2 <cputchar>
f01058e1:	83 c4 10             	add    $0x10,%esp
f01058e4:	eb ec                	jmp    f01058d2 <readline+0x72>
			buf[i++] = c;
f01058e6:	88 9e 80 5a 21 f0    	mov    %bl,-0xfdea580(%esi)
f01058ec:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01058ef:	e8 be ae ff ff       	call   f01007b2 <getchar>
f01058f4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01058f6:	85 c0                	test   %eax,%eax
f01058f8:	78 9e                	js     f0105898 <readline+0x38>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01058fa:	83 f8 08             	cmp    $0x8,%eax
f01058fd:	0f 94 c2             	sete   %dl
f0105900:	83 f8 7f             	cmp    $0x7f,%eax
f0105903:	0f 94 c0             	sete   %al
f0105906:	08 c2                	or     %al,%dl
f0105908:	74 04                	je     f010590e <readline+0xae>
f010590a:	85 f6                	test   %esi,%esi
f010590c:	7f c0                	jg     f01058ce <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010590e:	83 fb 1f             	cmp    $0x1f,%ebx
f0105911:	7e 1a                	jle    f010592d <readline+0xcd>
f0105913:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105919:	7f 12                	jg     f010592d <readline+0xcd>
			if (echoing)
f010591b:	85 ff                	test   %edi,%edi
f010591d:	74 c7                	je     f01058e6 <readline+0x86>
				cputchar(c);
f010591f:	83 ec 0c             	sub    $0xc,%esp
f0105922:	53                   	push   %ebx
f0105923:	e8 7a ae ff ff       	call   f01007a2 <cputchar>
f0105928:	83 c4 10             	add    $0x10,%esp
f010592b:	eb b9                	jmp    f01058e6 <readline+0x86>
		} else if (c == '\n' || c == '\r') {
f010592d:	83 fb 0a             	cmp    $0xa,%ebx
f0105930:	74 05                	je     f0105937 <readline+0xd7>
f0105932:	83 fb 0d             	cmp    $0xd,%ebx
f0105935:	75 b8                	jne    f01058ef <readline+0x8f>
			if (echoing)
f0105937:	85 ff                	test   %edi,%edi
f0105939:	75 26                	jne    f0105961 <readline+0x101>
			buf[i] = 0;
f010593b:	c6 86 80 5a 21 f0 00 	movb   $0x0,-0xfdea580(%esi)
            cprintf("[readline]------------- 2 %s \n", buf );
f0105942:	83 ec 08             	sub    $0x8,%esp
f0105945:	68 80 5a 21 f0       	push   $0xf0215a80
f010594a:	68 90 83 10 f0       	push   $0xf0108390
f010594f:	e8 34 e4 ff ff       	call   f0103d88 <cprintf>
			return buf;
f0105954:	83 c4 10             	add    $0x10,%esp
f0105957:	b8 80 5a 21 f0       	mov    $0xf0215a80,%eax
f010595c:	e9 65 ff ff ff       	jmp    f01058c6 <readline+0x66>
				cputchar('\n');
f0105961:	83 ec 0c             	sub    $0xc,%esp
f0105964:	6a 0a                	push   $0xa
f0105966:	e8 37 ae ff ff       	call   f01007a2 <cputchar>
f010596b:	83 c4 10             	add    $0x10,%esp
f010596e:	eb cb                	jmp    f010593b <readline+0xdb>

f0105970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105970:	55                   	push   %ebp
f0105971:	89 e5                	mov    %esp,%ebp
f0105973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105976:	b8 00 00 00 00       	mov    $0x0,%eax
f010597b:	eb 03                	jmp    f0105980 <strlen+0x10>
		n++;
f010597d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105984:	75 f7                	jne    f010597d <strlen+0xd>
	return n;
}
f0105986:	5d                   	pop    %ebp
f0105987:	c3                   	ret    

f0105988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105988:	55                   	push   %ebp
f0105989:	89 e5                	mov    %esp,%ebp
f010598b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010598e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105991:	b8 00 00 00 00       	mov    $0x0,%eax
f0105996:	eb 03                	jmp    f010599b <strnlen+0x13>
		n++;
f0105998:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010599b:	39 d0                	cmp    %edx,%eax
f010599d:	74 06                	je     f01059a5 <strnlen+0x1d>
f010599f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01059a3:	75 f3                	jne    f0105998 <strnlen+0x10>
	return n;
}
f01059a5:	5d                   	pop    %ebp
f01059a6:	c3                   	ret    

f01059a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059a7:	55                   	push   %ebp
f01059a8:	89 e5                	mov    %esp,%ebp
f01059aa:	53                   	push   %ebx
f01059ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01059ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059b1:	89 c2                	mov    %eax,%edx
f01059b3:	83 c1 01             	add    $0x1,%ecx
f01059b6:	83 c2 01             	add    $0x1,%edx
f01059b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01059bd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01059c0:	84 db                	test   %bl,%bl
f01059c2:	75 ef                	jne    f01059b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01059c4:	5b                   	pop    %ebx
f01059c5:	5d                   	pop    %ebp
f01059c6:	c3                   	ret    

f01059c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01059c7:	55                   	push   %ebp
f01059c8:	89 e5                	mov    %esp,%ebp
f01059ca:	53                   	push   %ebx
f01059cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01059ce:	53                   	push   %ebx
f01059cf:	e8 9c ff ff ff       	call   f0105970 <strlen>
f01059d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01059d7:	ff 75 0c             	pushl  0xc(%ebp)
f01059da:	01 d8                	add    %ebx,%eax
f01059dc:	50                   	push   %eax
f01059dd:	e8 c5 ff ff ff       	call   f01059a7 <strcpy>
	return dst;
}
f01059e2:	89 d8                	mov    %ebx,%eax
f01059e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01059e7:	c9                   	leave  
f01059e8:	c3                   	ret    

f01059e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01059e9:	55                   	push   %ebp
f01059ea:	89 e5                	mov    %esp,%ebp
f01059ec:	56                   	push   %esi
f01059ed:	53                   	push   %ebx
f01059ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01059f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01059f4:	89 f3                	mov    %esi,%ebx
f01059f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01059f9:	89 f2                	mov    %esi,%edx
f01059fb:	eb 0f                	jmp    f0105a0c <strncpy+0x23>
		*dst++ = *src;
f01059fd:	83 c2 01             	add    $0x1,%edx
f0105a00:	0f b6 01             	movzbl (%ecx),%eax
f0105a03:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a06:	80 39 01             	cmpb   $0x1,(%ecx)
f0105a09:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105a0c:	39 da                	cmp    %ebx,%edx
f0105a0e:	75 ed                	jne    f01059fd <strncpy+0x14>
	}
	return ret;
}
f0105a10:	89 f0                	mov    %esi,%eax
f0105a12:	5b                   	pop    %ebx
f0105a13:	5e                   	pop    %esi
f0105a14:	5d                   	pop    %ebp
f0105a15:	c3                   	ret    

f0105a16 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a16:	55                   	push   %ebp
f0105a17:	89 e5                	mov    %esp,%ebp
f0105a19:	56                   	push   %esi
f0105a1a:	53                   	push   %ebx
f0105a1b:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a21:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105a24:	89 f0                	mov    %esi,%eax
f0105a26:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a2a:	85 c9                	test   %ecx,%ecx
f0105a2c:	75 0b                	jne    f0105a39 <strlcpy+0x23>
f0105a2e:	eb 17                	jmp    f0105a47 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a30:	83 c2 01             	add    $0x1,%edx
f0105a33:	83 c0 01             	add    $0x1,%eax
f0105a36:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105a39:	39 d8                	cmp    %ebx,%eax
f0105a3b:	74 07                	je     f0105a44 <strlcpy+0x2e>
f0105a3d:	0f b6 0a             	movzbl (%edx),%ecx
f0105a40:	84 c9                	test   %cl,%cl
f0105a42:	75 ec                	jne    f0105a30 <strlcpy+0x1a>
		*dst = '\0';
f0105a44:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105a47:	29 f0                	sub    %esi,%eax
}
f0105a49:	5b                   	pop    %ebx
f0105a4a:	5e                   	pop    %esi
f0105a4b:	5d                   	pop    %ebp
f0105a4c:	c3                   	ret    

f0105a4d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a4d:	55                   	push   %ebp
f0105a4e:	89 e5                	mov    %esp,%ebp
f0105a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a53:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105a56:	eb 06                	jmp    f0105a5e <strcmp+0x11>
		p++, q++;
f0105a58:	83 c1 01             	add    $0x1,%ecx
f0105a5b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105a5e:	0f b6 01             	movzbl (%ecx),%eax
f0105a61:	84 c0                	test   %al,%al
f0105a63:	74 04                	je     f0105a69 <strcmp+0x1c>
f0105a65:	3a 02                	cmp    (%edx),%al
f0105a67:	74 ef                	je     f0105a58 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a69:	0f b6 c0             	movzbl %al,%eax
f0105a6c:	0f b6 12             	movzbl (%edx),%edx
f0105a6f:	29 d0                	sub    %edx,%eax
}
f0105a71:	5d                   	pop    %ebp
f0105a72:	c3                   	ret    

f0105a73 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105a73:	55                   	push   %ebp
f0105a74:	89 e5                	mov    %esp,%ebp
f0105a76:	53                   	push   %ebx
f0105a77:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a7d:	89 c3                	mov    %eax,%ebx
f0105a7f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105a82:	eb 06                	jmp    f0105a8a <strncmp+0x17>
		n--, p++, q++;
f0105a84:	83 c0 01             	add    $0x1,%eax
f0105a87:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105a8a:	39 d8                	cmp    %ebx,%eax
f0105a8c:	74 16                	je     f0105aa4 <strncmp+0x31>
f0105a8e:	0f b6 08             	movzbl (%eax),%ecx
f0105a91:	84 c9                	test   %cl,%cl
f0105a93:	74 04                	je     f0105a99 <strncmp+0x26>
f0105a95:	3a 0a                	cmp    (%edx),%cl
f0105a97:	74 eb                	je     f0105a84 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a99:	0f b6 00             	movzbl (%eax),%eax
f0105a9c:	0f b6 12             	movzbl (%edx),%edx
f0105a9f:	29 d0                	sub    %edx,%eax
}
f0105aa1:	5b                   	pop    %ebx
f0105aa2:	5d                   	pop    %ebp
f0105aa3:	c3                   	ret    
		return 0;
f0105aa4:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aa9:	eb f6                	jmp    f0105aa1 <strncmp+0x2e>

f0105aab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105aab:	55                   	push   %ebp
f0105aac:	89 e5                	mov    %esp,%ebp
f0105aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ab5:	0f b6 10             	movzbl (%eax),%edx
f0105ab8:	84 d2                	test   %dl,%dl
f0105aba:	74 09                	je     f0105ac5 <strchr+0x1a>
		if (*s == c)
f0105abc:	38 ca                	cmp    %cl,%dl
f0105abe:	74 0a                	je     f0105aca <strchr+0x1f>
	for (; *s; s++)
f0105ac0:	83 c0 01             	add    $0x1,%eax
f0105ac3:	eb f0                	jmp    f0105ab5 <strchr+0xa>
			return (char *) s;
	return 0;
f0105ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105aca:	5d                   	pop    %ebp
f0105acb:	c3                   	ret    

f0105acc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105acc:	55                   	push   %ebp
f0105acd:	89 e5                	mov    %esp,%ebp
f0105acf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ad2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105ad6:	eb 03                	jmp    f0105adb <strfind+0xf>
f0105ad8:	83 c0 01             	add    $0x1,%eax
f0105adb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105ade:	38 ca                	cmp    %cl,%dl
f0105ae0:	74 04                	je     f0105ae6 <strfind+0x1a>
f0105ae2:	84 d2                	test   %dl,%dl
f0105ae4:	75 f2                	jne    f0105ad8 <strfind+0xc>
			break;
	return (char *) s;
}
f0105ae6:	5d                   	pop    %ebp
f0105ae7:	c3                   	ret    

f0105ae8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105ae8:	55                   	push   %ebp
f0105ae9:	89 e5                	mov    %esp,%ebp
f0105aeb:	57                   	push   %edi
f0105aec:	56                   	push   %esi
f0105aed:	53                   	push   %ebx
f0105aee:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105af1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105af4:	85 c9                	test   %ecx,%ecx
f0105af6:	74 13                	je     f0105b0b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105af8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105afe:	75 05                	jne    f0105b05 <memset+0x1d>
f0105b00:	f6 c1 03             	test   $0x3,%cl
f0105b03:	74 0d                	je     f0105b12 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b08:	fc                   	cld    
f0105b09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b0b:	89 f8                	mov    %edi,%eax
f0105b0d:	5b                   	pop    %ebx
f0105b0e:	5e                   	pop    %esi
f0105b0f:	5f                   	pop    %edi
f0105b10:	5d                   	pop    %ebp
f0105b11:	c3                   	ret    
		c &= 0xFF;
f0105b12:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b16:	89 d3                	mov    %edx,%ebx
f0105b18:	c1 e3 08             	shl    $0x8,%ebx
f0105b1b:	89 d0                	mov    %edx,%eax
f0105b1d:	c1 e0 18             	shl    $0x18,%eax
f0105b20:	89 d6                	mov    %edx,%esi
f0105b22:	c1 e6 10             	shl    $0x10,%esi
f0105b25:	09 f0                	or     %esi,%eax
f0105b27:	09 c2                	or     %eax,%edx
f0105b29:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105b2b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105b2e:	89 d0                	mov    %edx,%eax
f0105b30:	fc                   	cld    
f0105b31:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b33:	eb d6                	jmp    f0105b0b <memset+0x23>

f0105b35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b35:	55                   	push   %ebp
f0105b36:	89 e5                	mov    %esp,%ebp
f0105b38:	57                   	push   %edi
f0105b39:	56                   	push   %esi
f0105b3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b43:	39 c6                	cmp    %eax,%esi
f0105b45:	73 35                	jae    f0105b7c <memmove+0x47>
f0105b47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b4a:	39 c2                	cmp    %eax,%edx
f0105b4c:	76 2e                	jbe    f0105b7c <memmove+0x47>
		s += n;
		d += n;
f0105b4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b51:	89 d6                	mov    %edx,%esi
f0105b53:	09 fe                	or     %edi,%esi
f0105b55:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105b5b:	74 0c                	je     f0105b69 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105b5d:	83 ef 01             	sub    $0x1,%edi
f0105b60:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105b63:	fd                   	std    
f0105b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105b66:	fc                   	cld    
f0105b67:	eb 21                	jmp    f0105b8a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b69:	f6 c1 03             	test   $0x3,%cl
f0105b6c:	75 ef                	jne    f0105b5d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105b6e:	83 ef 04             	sub    $0x4,%edi
f0105b71:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105b74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105b77:	fd                   	std    
f0105b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b7a:	eb ea                	jmp    f0105b66 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b7c:	89 f2                	mov    %esi,%edx
f0105b7e:	09 c2                	or     %eax,%edx
f0105b80:	f6 c2 03             	test   $0x3,%dl
f0105b83:	74 09                	je     f0105b8e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105b85:	89 c7                	mov    %eax,%edi
f0105b87:	fc                   	cld    
f0105b88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105b8a:	5e                   	pop    %esi
f0105b8b:	5f                   	pop    %edi
f0105b8c:	5d                   	pop    %ebp
f0105b8d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b8e:	f6 c1 03             	test   $0x3,%cl
f0105b91:	75 f2                	jne    f0105b85 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105b93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105b96:	89 c7                	mov    %eax,%edi
f0105b98:	fc                   	cld    
f0105b99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b9b:	eb ed                	jmp    f0105b8a <memmove+0x55>

f0105b9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105b9d:	55                   	push   %ebp
f0105b9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105ba0:	ff 75 10             	pushl  0x10(%ebp)
f0105ba3:	ff 75 0c             	pushl  0xc(%ebp)
f0105ba6:	ff 75 08             	pushl  0x8(%ebp)
f0105ba9:	e8 87 ff ff ff       	call   f0105b35 <memmove>
}
f0105bae:	c9                   	leave  
f0105baf:	c3                   	ret    

f0105bb0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105bb0:	55                   	push   %ebp
f0105bb1:	89 e5                	mov    %esp,%ebp
f0105bb3:	56                   	push   %esi
f0105bb4:	53                   	push   %ebx
f0105bb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bbb:	89 c6                	mov    %eax,%esi
f0105bbd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bc0:	39 f0                	cmp    %esi,%eax
f0105bc2:	74 1c                	je     f0105be0 <memcmp+0x30>
		if (*s1 != *s2)
f0105bc4:	0f b6 08             	movzbl (%eax),%ecx
f0105bc7:	0f b6 1a             	movzbl (%edx),%ebx
f0105bca:	38 d9                	cmp    %bl,%cl
f0105bcc:	75 08                	jne    f0105bd6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105bce:	83 c0 01             	add    $0x1,%eax
f0105bd1:	83 c2 01             	add    $0x1,%edx
f0105bd4:	eb ea                	jmp    f0105bc0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105bd6:	0f b6 c1             	movzbl %cl,%eax
f0105bd9:	0f b6 db             	movzbl %bl,%ebx
f0105bdc:	29 d8                	sub    %ebx,%eax
f0105bde:	eb 05                	jmp    f0105be5 <memcmp+0x35>
	}

	return 0;
f0105be0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105be5:	5b                   	pop    %ebx
f0105be6:	5e                   	pop    %esi
f0105be7:	5d                   	pop    %ebp
f0105be8:	c3                   	ret    

f0105be9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105be9:	55                   	push   %ebp
f0105bea:	89 e5                	mov    %esp,%ebp
f0105bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105bf2:	89 c2                	mov    %eax,%edx
f0105bf4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105bf7:	39 d0                	cmp    %edx,%eax
f0105bf9:	73 09                	jae    f0105c04 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105bfb:	38 08                	cmp    %cl,(%eax)
f0105bfd:	74 05                	je     f0105c04 <memfind+0x1b>
	for (; s < ends; s++)
f0105bff:	83 c0 01             	add    $0x1,%eax
f0105c02:	eb f3                	jmp    f0105bf7 <memfind+0xe>
			break;
	return (void *) s;
}
f0105c04:	5d                   	pop    %ebp
f0105c05:	c3                   	ret    

f0105c06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c06:	55                   	push   %ebp
f0105c07:	89 e5                	mov    %esp,%ebp
f0105c09:	57                   	push   %edi
f0105c0a:	56                   	push   %esi
f0105c0b:	53                   	push   %ebx
f0105c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c12:	eb 03                	jmp    f0105c17 <strtol+0x11>
		s++;
f0105c14:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105c17:	0f b6 01             	movzbl (%ecx),%eax
f0105c1a:	3c 20                	cmp    $0x20,%al
f0105c1c:	74 f6                	je     f0105c14 <strtol+0xe>
f0105c1e:	3c 09                	cmp    $0x9,%al
f0105c20:	74 f2                	je     f0105c14 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105c22:	3c 2b                	cmp    $0x2b,%al
f0105c24:	74 2e                	je     f0105c54 <strtol+0x4e>
	int neg = 0;
f0105c26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105c2b:	3c 2d                	cmp    $0x2d,%al
f0105c2d:	74 2f                	je     f0105c5e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105c35:	75 05                	jne    f0105c3c <strtol+0x36>
f0105c37:	80 39 30             	cmpb   $0x30,(%ecx)
f0105c3a:	74 2c                	je     f0105c68 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c3c:	85 db                	test   %ebx,%ebx
f0105c3e:	75 0a                	jne    f0105c4a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105c40:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105c45:	80 39 30             	cmpb   $0x30,(%ecx)
f0105c48:	74 28                	je     f0105c72 <strtol+0x6c>
		base = 10;
f0105c4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105c52:	eb 50                	jmp    f0105ca4 <strtol+0x9e>
		s++;
f0105c54:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105c57:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c5c:	eb d1                	jmp    f0105c2f <strtol+0x29>
		s++, neg = 1;
f0105c5e:	83 c1 01             	add    $0x1,%ecx
f0105c61:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c66:	eb c7                	jmp    f0105c2f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105c6c:	74 0e                	je     f0105c7c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105c6e:	85 db                	test   %ebx,%ebx
f0105c70:	75 d8                	jne    f0105c4a <strtol+0x44>
		s++, base = 8;
f0105c72:	83 c1 01             	add    $0x1,%ecx
f0105c75:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105c7a:	eb ce                	jmp    f0105c4a <strtol+0x44>
		s += 2, base = 16;
f0105c7c:	83 c1 02             	add    $0x2,%ecx
f0105c7f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105c84:	eb c4                	jmp    f0105c4a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105c86:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105c89:	89 f3                	mov    %esi,%ebx
f0105c8b:	80 fb 19             	cmp    $0x19,%bl
f0105c8e:	77 29                	ja     f0105cb9 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105c90:	0f be d2             	movsbl %dl,%edx
f0105c93:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105c96:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105c99:	7d 30                	jge    f0105ccb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105c9b:	83 c1 01             	add    $0x1,%ecx
f0105c9e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105ca2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105ca4:	0f b6 11             	movzbl (%ecx),%edx
f0105ca7:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105caa:	89 f3                	mov    %esi,%ebx
f0105cac:	80 fb 09             	cmp    $0x9,%bl
f0105caf:	77 d5                	ja     f0105c86 <strtol+0x80>
			dig = *s - '0';
f0105cb1:	0f be d2             	movsbl %dl,%edx
f0105cb4:	83 ea 30             	sub    $0x30,%edx
f0105cb7:	eb dd                	jmp    f0105c96 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105cb9:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105cbc:	89 f3                	mov    %esi,%ebx
f0105cbe:	80 fb 19             	cmp    $0x19,%bl
f0105cc1:	77 08                	ja     f0105ccb <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105cc3:	0f be d2             	movsbl %dl,%edx
f0105cc6:	83 ea 37             	sub    $0x37,%edx
f0105cc9:	eb cb                	jmp    f0105c96 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105ccb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105ccf:	74 05                	je     f0105cd6 <strtol+0xd0>
		*endptr = (char *) s;
f0105cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105cd4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105cd6:	89 c2                	mov    %eax,%edx
f0105cd8:	f7 da                	neg    %edx
f0105cda:	85 ff                	test   %edi,%edi
f0105cdc:	0f 45 c2             	cmovne %edx,%eax
}
f0105cdf:	5b                   	pop    %ebx
f0105ce0:	5e                   	pop    %esi
f0105ce1:	5f                   	pop    %edi
f0105ce2:	5d                   	pop    %ebp
f0105ce3:	c3                   	ret    

f0105ce4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105ce4:	fa                   	cli    

	xorw    %ax, %ax
f0105ce5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105ce7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ce9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ceb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ced:	0f 01 16             	lgdtl  (%esi)
f0105cf0:	74 70                	je     f0105d62 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105cf2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105cf5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105cf9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105cfc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d02:	08 00                	or     %al,(%eax)

f0105d04 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d04:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d08:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d0a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d0c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d0e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d12:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d14:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d16:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105d1b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d1e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d21:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d26:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d29:	8b 25 84 5e 21 f0    	mov    0xf0215e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105d2f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105d34:	b8 b4 01 10 f0       	mov    $0xf01001b4,%eax
	call    *%eax
f0105d39:	ff d0                	call   *%eax

f0105d3b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105d3b:	eb fe                	jmp    f0105d3b <spin>
f0105d3d:	8d 76 00             	lea    0x0(%esi),%esi

f0105d40 <gdt>:
	...
f0105d48:	ff                   	(bad)  
f0105d49:	ff 00                	incl   (%eax)
f0105d4b:	00 00                	add    %al,(%eax)
f0105d4d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d54:	00                   	.byte 0x0
f0105d55:	92                   	xchg   %eax,%edx
f0105d56:	cf                   	iret   
	...

f0105d58 <gdtdesc>:
f0105d58:	17                   	pop    %ss
f0105d59:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105d5e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105d5e:	90                   	nop

f0105d5f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105d5f:	55                   	push   %ebp
f0105d60:	89 e5                	mov    %esp,%ebp
f0105d62:	57                   	push   %edi
f0105d63:	56                   	push   %esi
f0105d64:	53                   	push   %ebx
f0105d65:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105d68:	8b 0d 88 5e 21 f0    	mov    0xf0215e88,%ecx
f0105d6e:	89 c3                	mov    %eax,%ebx
f0105d70:	c1 eb 0c             	shr    $0xc,%ebx
f0105d73:	39 cb                	cmp    %ecx,%ebx
f0105d75:	73 1a                	jae    f0105d91 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105d77:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d7d:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f0105d80:	89 f0                	mov    %esi,%eax
f0105d82:	c1 e8 0c             	shr    $0xc,%eax
f0105d85:	39 c8                	cmp    %ecx,%eax
f0105d87:	73 1a                	jae    f0105da3 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105d89:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105d8f:	eb 27                	jmp    f0105db8 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d91:	50                   	push   %eax
f0105d92:	68 64 67 10 f0       	push   $0xf0106764
f0105d97:	6a 57                	push   $0x57
f0105d99:	68 3d 85 10 f0       	push   $0xf010853d
f0105d9e:	e8 9d a2 ff ff       	call   f0100040 <_panic>
f0105da3:	56                   	push   %esi
f0105da4:	68 64 67 10 f0       	push   $0xf0106764
f0105da9:	6a 57                	push   $0x57
f0105dab:	68 3d 85 10 f0       	push   $0xf010853d
f0105db0:	e8 8b a2 ff ff       	call   f0100040 <_panic>
f0105db5:	83 c3 10             	add    $0x10,%ebx
f0105db8:	39 f3                	cmp    %esi,%ebx
f0105dba:	73 2e                	jae    f0105dea <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105dbc:	83 ec 04             	sub    $0x4,%esp
f0105dbf:	6a 04                	push   $0x4
f0105dc1:	68 4d 85 10 f0       	push   $0xf010854d
f0105dc6:	53                   	push   %ebx
f0105dc7:	e8 e4 fd ff ff       	call   f0105bb0 <memcmp>
f0105dcc:	83 c4 10             	add    $0x10,%esp
f0105dcf:	85 c0                	test   %eax,%eax
f0105dd1:	75 e2                	jne    f0105db5 <mpsearch1+0x56>
f0105dd3:	89 da                	mov    %ebx,%edx
f0105dd5:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105dd8:	0f b6 0a             	movzbl (%edx),%ecx
f0105ddb:	01 c8                	add    %ecx,%eax
f0105ddd:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105de0:	39 fa                	cmp    %edi,%edx
f0105de2:	75 f4                	jne    f0105dd8 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105de4:	84 c0                	test   %al,%al
f0105de6:	75 cd                	jne    f0105db5 <mpsearch1+0x56>
f0105de8:	eb 05                	jmp    f0105def <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105dea:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105def:	89 d8                	mov    %ebx,%eax
f0105df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df4:	5b                   	pop    %ebx
f0105df5:	5e                   	pop    %esi
f0105df6:	5f                   	pop    %edi
f0105df7:	5d                   	pop    %ebp
f0105df8:	c3                   	ret    

f0105df9 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105df9:	55                   	push   %ebp
f0105dfa:	89 e5                	mov    %esp,%ebp
f0105dfc:	57                   	push   %edi
f0105dfd:	56                   	push   %esi
f0105dfe:	53                   	push   %ebx
f0105dff:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e02:	c7 05 c0 63 21 f0 20 	movl   $0xf0216020,0xf02163c0
f0105e09:	60 21 f0 
	if (PGNUM(pa) >= npages)
f0105e0c:	83 3d 88 5e 21 f0 00 	cmpl   $0x0,0xf0215e88
f0105e13:	0f 84 87 00 00 00    	je     f0105ea0 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e19:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105e20:	85 c0                	test   %eax,%eax
f0105e22:	0f 84 8e 00 00 00    	je     f0105eb6 <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105e28:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105e2b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e30:	e8 2a ff ff ff       	call   f0105d5f <mpsearch1>
f0105e35:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105e38:	85 c0                	test   %eax,%eax
f0105e3a:	0f 84 9a 00 00 00    	je     f0105eda <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105e40:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105e43:	8b 41 04             	mov    0x4(%ecx),%eax
f0105e46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e49:	85 c0                	test   %eax,%eax
f0105e4b:	0f 84 a8 00 00 00    	je     f0105ef9 <mp_init+0x100>
f0105e51:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f0105e55:	0f 85 9e 00 00 00    	jne    f0105ef9 <mp_init+0x100>
f0105e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e5e:	c1 e8 0c             	shr    $0xc,%eax
f0105e61:	3b 05 88 5e 21 f0    	cmp    0xf0215e88,%eax
f0105e67:	0f 83 a1 00 00 00    	jae    f0105f0e <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f0105e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e70:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105e76:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105e78:	83 ec 04             	sub    $0x4,%esp
f0105e7b:	6a 04                	push   $0x4
f0105e7d:	68 52 85 10 f0       	push   $0xf0108552
f0105e82:	53                   	push   %ebx
f0105e83:	e8 28 fd ff ff       	call   f0105bb0 <memcmp>
f0105e88:	83 c4 10             	add    $0x10,%esp
f0105e8b:	85 c0                	test   %eax,%eax
f0105e8d:	0f 85 92 00 00 00    	jne    f0105f25 <mp_init+0x12c>
f0105e93:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105e97:	01 df                	add    %ebx,%edi
	sum = 0;
f0105e99:	89 c2                	mov    %eax,%edx
f0105e9b:	e9 a2 00 00 00       	jmp    f0105f42 <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ea0:	68 00 04 00 00       	push   $0x400
f0105ea5:	68 64 67 10 f0       	push   $0xf0106764
f0105eaa:	6a 6f                	push   $0x6f
f0105eac:	68 3d 85 10 f0       	push   $0xf010853d
f0105eb1:	e8 8a a1 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105eb6:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105ebd:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105ec0:	2d 00 04 00 00       	sub    $0x400,%eax
f0105ec5:	ba 00 04 00 00       	mov    $0x400,%edx
f0105eca:	e8 90 fe ff ff       	call   f0105d5f <mpsearch1>
f0105ecf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ed2:	85 c0                	test   %eax,%eax
f0105ed4:	0f 85 66 ff ff ff    	jne    f0105e40 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105eda:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105edf:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ee4:	e8 76 fe ff ff       	call   f0105d5f <mpsearch1>
f0105ee9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105eec:	85 c0                	test   %eax,%eax
f0105eee:	0f 85 4c ff ff ff    	jne    f0105e40 <mp_init+0x47>
f0105ef4:	e9 a8 01 00 00       	jmp    f01060a1 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105ef9:	83 ec 0c             	sub    $0xc,%esp
f0105efc:	68 b0 83 10 f0       	push   $0xf01083b0
f0105f01:	e8 82 de ff ff       	call   f0103d88 <cprintf>
f0105f06:	83 c4 10             	add    $0x10,%esp
f0105f09:	e9 93 01 00 00       	jmp    f01060a1 <mp_init+0x2a8>
f0105f0e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105f11:	68 64 67 10 f0       	push   $0xf0106764
f0105f16:	68 90 00 00 00       	push   $0x90
f0105f1b:	68 3d 85 10 f0       	push   $0xf010853d
f0105f20:	e8 1b a1 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105f25:	83 ec 0c             	sub    $0xc,%esp
f0105f28:	68 e0 83 10 f0       	push   $0xf01083e0
f0105f2d:	e8 56 de ff ff       	call   f0103d88 <cprintf>
f0105f32:	83 c4 10             	add    $0x10,%esp
f0105f35:	e9 67 01 00 00       	jmp    f01060a1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105f3a:	0f b6 0b             	movzbl (%ebx),%ecx
f0105f3d:	01 ca                	add    %ecx,%edx
f0105f3f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105f42:	39 fb                	cmp    %edi,%ebx
f0105f44:	75 f4                	jne    f0105f3a <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f0105f46:	84 d2                	test   %dl,%dl
f0105f48:	75 16                	jne    f0105f60 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0105f4a:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105f4e:	80 fa 01             	cmp    $0x1,%dl
f0105f51:	74 05                	je     f0105f58 <mp_init+0x15f>
f0105f53:	80 fa 04             	cmp    $0x4,%dl
f0105f56:	75 1d                	jne    f0105f75 <mp_init+0x17c>
f0105f58:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105f5c:	01 d9                	add    %ebx,%ecx
f0105f5e:	eb 36                	jmp    f0105f96 <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f60:	83 ec 0c             	sub    $0xc,%esp
f0105f63:	68 14 84 10 f0       	push   $0xf0108414
f0105f68:	e8 1b de ff ff       	call   f0103d88 <cprintf>
f0105f6d:	83 c4 10             	add    $0x10,%esp
f0105f70:	e9 2c 01 00 00       	jmp    f01060a1 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105f75:	83 ec 08             	sub    $0x8,%esp
f0105f78:	0f b6 d2             	movzbl %dl,%edx
f0105f7b:	52                   	push   %edx
f0105f7c:	68 38 84 10 f0       	push   $0xf0108438
f0105f81:	e8 02 de ff ff       	call   f0103d88 <cprintf>
f0105f86:	83 c4 10             	add    $0x10,%esp
f0105f89:	e9 13 01 00 00       	jmp    f01060a1 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105f8e:	0f b6 13             	movzbl (%ebx),%edx
f0105f91:	01 d0                	add    %edx,%eax
f0105f93:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105f96:	39 d9                	cmp    %ebx,%ecx
f0105f98:	75 f4                	jne    f0105f8e <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f9a:	02 46 2a             	add    0x2a(%esi),%al
f0105f9d:	75 29                	jne    f0105fc8 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f0105f9f:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105fa6:	0f 84 f5 00 00 00    	je     f01060a1 <mp_init+0x2a8>
		return;
	ismp = 1;
f0105fac:	c7 05 00 60 21 f0 01 	movl   $0x1,0xf0216000
f0105fb3:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105fb6:	8b 46 24             	mov    0x24(%esi),%eax
f0105fb9:	a3 00 70 25 f0       	mov    %eax,0xf0257000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fbe:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105fc6:	eb 4d                	jmp    f0106015 <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105fc8:	83 ec 0c             	sub    $0xc,%esp
f0105fcb:	68 58 84 10 f0       	push   $0xf0108458
f0105fd0:	e8 b3 dd ff ff       	call   f0103d88 <cprintf>
f0105fd5:	83 c4 10             	add    $0x10,%esp
f0105fd8:	e9 c4 00 00 00       	jmp    f01060a1 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105fdd:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105fe1:	74 11                	je     f0105ff4 <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105fe3:	6b 05 c4 63 21 f0 74 	imul   $0x74,0xf02163c4,%eax
f0105fea:	05 20 60 21 f0       	add    $0xf0216020,%eax
f0105fef:	a3 c0 63 21 f0       	mov    %eax,0xf02163c0
			if (ncpu < NCPU) {
f0105ff4:	a1 c4 63 21 f0       	mov    0xf02163c4,%eax
f0105ff9:	83 f8 07             	cmp    $0x7,%eax
f0105ffc:	7f 2f                	jg     f010602d <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0105ffe:	6b d0 74             	imul   $0x74,%eax,%edx
f0106001:	88 82 20 60 21 f0    	mov    %al,-0xfde9fe0(%edx)
				ncpu++;
f0106007:	83 c0 01             	add    $0x1,%eax
f010600a:	a3 c4 63 21 f0       	mov    %eax,0xf02163c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010600f:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106012:	83 c3 01             	add    $0x1,%ebx
f0106015:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0106019:	39 d8                	cmp    %ebx,%eax
f010601b:	76 4b                	jbe    f0106068 <mp_init+0x26f>
		switch (*p) {
f010601d:	0f b6 07             	movzbl (%edi),%eax
f0106020:	84 c0                	test   %al,%al
f0106022:	74 b9                	je     f0105fdd <mp_init+0x1e4>
f0106024:	3c 04                	cmp    $0x4,%al
f0106026:	77 1c                	ja     f0106044 <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106028:	83 c7 08             	add    $0x8,%edi
			continue;
f010602b:	eb e5                	jmp    f0106012 <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010602d:	83 ec 08             	sub    $0x8,%esp
f0106030:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106034:	50                   	push   %eax
f0106035:	68 88 84 10 f0       	push   $0xf0108488
f010603a:	e8 49 dd ff ff       	call   f0103d88 <cprintf>
f010603f:	83 c4 10             	add    $0x10,%esp
f0106042:	eb cb                	jmp    f010600f <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106044:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0106047:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010604a:	50                   	push   %eax
f010604b:	68 b0 84 10 f0       	push   $0xf01084b0
f0106050:	e8 33 dd ff ff       	call   f0103d88 <cprintf>
			ismp = 0;
f0106055:	c7 05 00 60 21 f0 00 	movl   $0x0,0xf0216000
f010605c:	00 00 00 
			i = conf->entry;
f010605f:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0106063:	83 c4 10             	add    $0x10,%esp
f0106066:	eb aa                	jmp    f0106012 <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106068:	a1 c0 63 21 f0       	mov    0xf02163c0,%eax
f010606d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106074:	83 3d 00 60 21 f0 00 	cmpl   $0x0,0xf0216000
f010607b:	75 2c                	jne    f01060a9 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010607d:	c7 05 c4 63 21 f0 01 	movl   $0x1,0xf02163c4
f0106084:	00 00 00 
		lapicaddr = 0;
f0106087:	c7 05 00 70 25 f0 00 	movl   $0x0,0xf0257000
f010608e:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106091:	83 ec 0c             	sub    $0xc,%esp
f0106094:	68 d0 84 10 f0       	push   $0xf01084d0
f0106099:	e8 ea dc ff ff       	call   f0103d88 <cprintf>
		return;
f010609e:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01060a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060a4:	5b                   	pop    %ebx
f01060a5:	5e                   	pop    %esi
f01060a6:	5f                   	pop    %edi
f01060a7:	5d                   	pop    %ebp
f01060a8:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01060a9:	83 ec 04             	sub    $0x4,%esp
f01060ac:	ff 35 c4 63 21 f0    	pushl  0xf02163c4
f01060b2:	0f b6 00             	movzbl (%eax),%eax
f01060b5:	50                   	push   %eax
f01060b6:	68 57 85 10 f0       	push   $0xf0108557
f01060bb:	e8 c8 dc ff ff       	call   f0103d88 <cprintf>
	if (mp->imcrp) {
f01060c0:	83 c4 10             	add    $0x10,%esp
f01060c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060c6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01060ca:	74 d5                	je     f01060a1 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01060cc:	83 ec 0c             	sub    $0xc,%esp
f01060cf:	68 fc 84 10 f0       	push   $0xf01084fc
f01060d4:	e8 af dc ff ff       	call   f0103d88 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060d9:	b8 70 00 00 00       	mov    $0x70,%eax
f01060de:	ba 22 00 00 00       	mov    $0x22,%edx
f01060e3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01060e4:	ba 23 00 00 00       	mov    $0x23,%edx
f01060e9:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01060ea:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060ed:	ee                   	out    %al,(%dx)
f01060ee:	83 c4 10             	add    $0x10,%esp
f01060f1:	eb ae                	jmp    f01060a1 <mp_init+0x2a8>

f01060f3 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01060f3:	55                   	push   %ebp
f01060f4:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01060f6:	8b 0d 04 70 25 f0    	mov    0xf0257004,%ecx
f01060fc:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01060ff:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106101:	a1 04 70 25 f0       	mov    0xf0257004,%eax
f0106106:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106109:	5d                   	pop    %ebp
f010610a:	c3                   	ret    

f010610b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010610b:	55                   	push   %ebp
f010610c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010610e:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106114:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106119:	85 d2                	test   %edx,%edx
f010611b:	74 06                	je     f0106123 <cpunum+0x18>
		return lapic[ID] >> 24;
f010611d:	8b 42 20             	mov    0x20(%edx),%eax
f0106120:	c1 e8 18             	shr    $0x18,%eax
}
f0106123:	5d                   	pop    %ebp
f0106124:	c3                   	ret    

f0106125 <lapic_init>:
	if (!lapicaddr)
f0106125:	a1 00 70 25 f0       	mov    0xf0257000,%eax
f010612a:	85 c0                	test   %eax,%eax
f010612c:	75 02                	jne    f0106130 <lapic_init+0xb>
f010612e:	f3 c3                	repz ret 
{
f0106130:	55                   	push   %ebp
f0106131:	89 e5                	mov    %esp,%ebp
f0106133:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106136:	68 00 10 00 00       	push   $0x1000
f010613b:	50                   	push   %eax
f010613c:	e8 ca b4 ff ff       	call   f010160b <mmio_map_region>
f0106141:	a3 04 70 25 f0       	mov    %eax,0xf0257004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106146:	ba 27 01 00 00       	mov    $0x127,%edx
f010614b:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106150:	e8 9e ff ff ff       	call   f01060f3 <lapicw>
	lapicw(TDCR, X1);
f0106155:	ba 0b 00 00 00       	mov    $0xb,%edx
f010615a:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010615f:	e8 8f ff ff ff       	call   f01060f3 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106164:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106169:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010616e:	e8 80 ff ff ff       	call   f01060f3 <lapicw>
	lapicw(TICR, 10000000); 
f0106173:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106178:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010617d:	e8 71 ff ff ff       	call   f01060f3 <lapicw>
	if (thiscpu != bootcpu)
f0106182:	e8 84 ff ff ff       	call   f010610b <cpunum>
f0106187:	6b c0 74             	imul   $0x74,%eax,%eax
f010618a:	05 20 60 21 f0       	add    $0xf0216020,%eax
f010618f:	83 c4 10             	add    $0x10,%esp
f0106192:	39 05 c0 63 21 f0    	cmp    %eax,0xf02163c0
f0106198:	74 0f                	je     f01061a9 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f010619a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010619f:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01061a4:	e8 4a ff ff ff       	call   f01060f3 <lapicw>
	lapicw(LINT1, MASKED);
f01061a9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061ae:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01061b3:	e8 3b ff ff ff       	call   f01060f3 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01061b8:	a1 04 70 25 f0       	mov    0xf0257004,%eax
f01061bd:	8b 40 30             	mov    0x30(%eax),%eax
f01061c0:	c1 e8 10             	shr    $0x10,%eax
f01061c3:	3c 03                	cmp    $0x3,%al
f01061c5:	77 7c                	ja     f0106243 <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01061c7:	ba 33 00 00 00       	mov    $0x33,%edx
f01061cc:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01061d1:	e8 1d ff ff ff       	call   f01060f3 <lapicw>
	lapicw(ESR, 0);
f01061d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01061db:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061e0:	e8 0e ff ff ff       	call   f01060f3 <lapicw>
	lapicw(ESR, 0);
f01061e5:	ba 00 00 00 00       	mov    $0x0,%edx
f01061ea:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061ef:	e8 ff fe ff ff       	call   f01060f3 <lapicw>
	lapicw(EOI, 0);
f01061f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01061f9:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01061fe:	e8 f0 fe ff ff       	call   f01060f3 <lapicw>
	lapicw(ICRHI, 0);
f0106203:	ba 00 00 00 00       	mov    $0x0,%edx
f0106208:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010620d:	e8 e1 fe ff ff       	call   f01060f3 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106212:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106217:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010621c:	e8 d2 fe ff ff       	call   f01060f3 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106221:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
f0106227:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010622d:	f6 c4 10             	test   $0x10,%ah
f0106230:	75 f5                	jne    f0106227 <lapic_init+0x102>
	lapicw(TPR, 0);
f0106232:	ba 00 00 00 00       	mov    $0x0,%edx
f0106237:	b8 20 00 00 00       	mov    $0x20,%eax
f010623c:	e8 b2 fe ff ff       	call   f01060f3 <lapicw>
}
f0106241:	c9                   	leave  
f0106242:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106243:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106248:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010624d:	e8 a1 fe ff ff       	call   f01060f3 <lapicw>
f0106252:	e9 70 ff ff ff       	jmp    f01061c7 <lapic_init+0xa2>

f0106257 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106257:	83 3d 04 70 25 f0 00 	cmpl   $0x0,0xf0257004
f010625e:	74 14                	je     f0106274 <lapic_eoi+0x1d>
{
f0106260:	55                   	push   %ebp
f0106261:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106263:	ba 00 00 00 00       	mov    $0x0,%edx
f0106268:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010626d:	e8 81 fe ff ff       	call   f01060f3 <lapicw>
}
f0106272:	5d                   	pop    %ebp
f0106273:	c3                   	ret    
f0106274:	f3 c3                	repz ret 

f0106276 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106276:	55                   	push   %ebp
f0106277:	89 e5                	mov    %esp,%ebp
f0106279:	56                   	push   %esi
f010627a:	53                   	push   %ebx
f010627b:	8b 75 08             	mov    0x8(%ebp),%esi
f010627e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106281:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106286:	ba 70 00 00 00       	mov    $0x70,%edx
f010628b:	ee                   	out    %al,(%dx)
f010628c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106291:	ba 71 00 00 00       	mov    $0x71,%edx
f0106296:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106297:	83 3d 88 5e 21 f0 00 	cmpl   $0x0,0xf0215e88
f010629e:	74 7e                	je     f010631e <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01062a0:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01062a7:	00 00 
	wrv[1] = addr >> 4;
f01062a9:	89 d8                	mov    %ebx,%eax
f01062ab:	c1 e8 04             	shr    $0x4,%eax
f01062ae:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01062b4:	c1 e6 18             	shl    $0x18,%esi
f01062b7:	89 f2                	mov    %esi,%edx
f01062b9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062be:	e8 30 fe ff ff       	call   f01060f3 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01062c3:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01062c8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062cd:	e8 21 fe ff ff       	call   f01060f3 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01062d2:	ba 00 85 00 00       	mov    $0x8500,%edx
f01062d7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062dc:	e8 12 fe ff ff       	call   f01060f3 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062e1:	c1 eb 0c             	shr    $0xc,%ebx
f01062e4:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01062e7:	89 f2                	mov    %esi,%edx
f01062e9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062ee:	e8 00 fe ff ff       	call   f01060f3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062f3:	89 da                	mov    %ebx,%edx
f01062f5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062fa:	e8 f4 fd ff ff       	call   f01060f3 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01062ff:	89 f2                	mov    %esi,%edx
f0106301:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106306:	e8 e8 fd ff ff       	call   f01060f3 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010630b:	89 da                	mov    %ebx,%edx
f010630d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106312:	e8 dc fd ff ff       	call   f01060f3 <lapicw>
		microdelay(200);
	}
}
f0106317:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010631a:	5b                   	pop    %ebx
f010631b:	5e                   	pop    %esi
f010631c:	5d                   	pop    %ebp
f010631d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010631e:	68 67 04 00 00       	push   $0x467
f0106323:	68 64 67 10 f0       	push   $0xf0106764
f0106328:	68 98 00 00 00       	push   $0x98
f010632d:	68 74 85 10 f0       	push   $0xf0108574
f0106332:	e8 09 9d ff ff       	call   f0100040 <_panic>

f0106337 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106337:	55                   	push   %ebp
f0106338:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010633a:	8b 55 08             	mov    0x8(%ebp),%edx
f010633d:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106343:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106348:	e8 a6 fd ff ff       	call   f01060f3 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010634d:	8b 15 04 70 25 f0    	mov    0xf0257004,%edx
f0106353:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106359:	f6 c4 10             	test   $0x10,%ah
f010635c:	75 f5                	jne    f0106353 <lapic_ipi+0x1c>
		;
}
f010635e:	5d                   	pop    %ebp
f010635f:	c3                   	ret    

f0106360 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106360:	55                   	push   %ebp
f0106361:	89 e5                	mov    %esp,%ebp
f0106363:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106366:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010636c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010636f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106372:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106379:	5d                   	pop    %ebp
f010637a:	c3                   	ret    

f010637b <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010637b:	55                   	push   %ebp
f010637c:	89 e5                	mov    %esp,%ebp
f010637e:	56                   	push   %esi
f010637f:	53                   	push   %ebx
f0106380:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106383:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106386:	75 07                	jne    f010638f <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106388:	ba 01 00 00 00       	mov    $0x1,%edx
f010638d:	eb 34                	jmp    f01063c3 <spin_lock+0x48>
f010638f:	8b 73 08             	mov    0x8(%ebx),%esi
f0106392:	e8 74 fd ff ff       	call   f010610b <cpunum>
f0106397:	6b c0 74             	imul   $0x74,%eax,%eax
f010639a:	05 20 60 21 f0       	add    $0xf0216020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010639f:	39 c6                	cmp    %eax,%esi
f01063a1:	75 e5                	jne    f0106388 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01063a3:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01063a6:	e8 60 fd ff ff       	call   f010610b <cpunum>
f01063ab:	83 ec 0c             	sub    $0xc,%esp
f01063ae:	53                   	push   %ebx
f01063af:	50                   	push   %eax
f01063b0:	68 84 85 10 f0       	push   $0xf0108584
f01063b5:	6a 41                	push   $0x41
f01063b7:	68 e8 85 10 f0       	push   $0xf01085e8
f01063bc:	e8 7f 9c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01063c1:	f3 90                	pause  
f01063c3:	89 d0                	mov    %edx,%eax
f01063c5:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f01063c8:	85 c0                	test   %eax,%eax
f01063ca:	75 f5                	jne    f01063c1 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01063cc:	e8 3a fd ff ff       	call   f010610b <cpunum>
f01063d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01063d4:	05 20 60 21 f0       	add    $0xf0216020,%eax
f01063d9:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01063dc:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01063df:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01063e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01063e6:	eb 0b                	jmp    f01063f3 <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f01063e8:	8b 4a 04             	mov    0x4(%edx),%ecx
f01063eb:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01063ee:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01063f0:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01063f3:	83 f8 09             	cmp    $0x9,%eax
f01063f6:	7f 14                	jg     f010640c <spin_lock+0x91>
f01063f8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01063fe:	77 e8                	ja     f01063e8 <spin_lock+0x6d>
f0106400:	eb 0a                	jmp    f010640c <spin_lock+0x91>
		pcs[i] = 0;
f0106402:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106409:	83 c0 01             	add    $0x1,%eax
f010640c:	83 f8 09             	cmp    $0x9,%eax
f010640f:	7e f1                	jle    f0106402 <spin_lock+0x87>
#endif
}
f0106411:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106414:	5b                   	pop    %ebx
f0106415:	5e                   	pop    %esi
f0106416:	5d                   	pop    %ebp
f0106417:	c3                   	ret    

f0106418 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106418:	55                   	push   %ebp
f0106419:	89 e5                	mov    %esp,%ebp
f010641b:	57                   	push   %edi
f010641c:	56                   	push   %esi
f010641d:	53                   	push   %ebx
f010641e:	83 ec 4c             	sub    $0x4c,%esp
f0106421:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106424:	83 3e 00             	cmpl   $0x0,(%esi)
f0106427:	75 35                	jne    f010645e <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106429:	83 ec 04             	sub    $0x4,%esp
f010642c:	6a 28                	push   $0x28
f010642e:	8d 46 0c             	lea    0xc(%esi),%eax
f0106431:	50                   	push   %eax
f0106432:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106435:	53                   	push   %ebx
f0106436:	e8 fa f6 ff ff       	call   f0105b35 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010643b:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010643e:	0f b6 38             	movzbl (%eax),%edi
f0106441:	8b 76 04             	mov    0x4(%esi),%esi
f0106444:	e8 c2 fc ff ff       	call   f010610b <cpunum>
f0106449:	57                   	push   %edi
f010644a:	56                   	push   %esi
f010644b:	50                   	push   %eax
f010644c:	68 b0 85 10 f0       	push   $0xf01085b0
f0106451:	e8 32 d9 ff ff       	call   f0103d88 <cprintf>
f0106456:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106459:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010645c:	eb 61                	jmp    f01064bf <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f010645e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106461:	e8 a5 fc ff ff       	call   f010610b <cpunum>
f0106466:	6b c0 74             	imul   $0x74,%eax,%eax
f0106469:	05 20 60 21 f0       	add    $0xf0216020,%eax
	if (!holding(lk)) {
f010646e:	39 c3                	cmp    %eax,%ebx
f0106470:	75 b7                	jne    f0106429 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106472:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106479:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106480:	b8 00 00 00 00       	mov    $0x0,%eax
f0106485:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106488:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010648b:	5b                   	pop    %ebx
f010648c:	5e                   	pop    %esi
f010648d:	5f                   	pop    %edi
f010648e:	5d                   	pop    %ebp
f010648f:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0106490:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106492:	83 ec 04             	sub    $0x4,%esp
f0106495:	89 c2                	mov    %eax,%edx
f0106497:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010649a:	52                   	push   %edx
f010649b:	ff 75 b0             	pushl  -0x50(%ebp)
f010649e:	ff 75 b4             	pushl  -0x4c(%ebp)
f01064a1:	ff 75 ac             	pushl  -0x54(%ebp)
f01064a4:	ff 75 a8             	pushl  -0x58(%ebp)
f01064a7:	50                   	push   %eax
f01064a8:	68 f8 85 10 f0       	push   $0xf01085f8
f01064ad:	e8 d6 d8 ff ff       	call   f0103d88 <cprintf>
f01064b2:	83 c4 20             	add    $0x20,%esp
f01064b5:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01064b8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01064bb:	39 c3                	cmp    %eax,%ebx
f01064bd:	74 2d                	je     f01064ec <spin_unlock+0xd4>
f01064bf:	89 de                	mov    %ebx,%esi
f01064c1:	8b 03                	mov    (%ebx),%eax
f01064c3:	85 c0                	test   %eax,%eax
f01064c5:	74 25                	je     f01064ec <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064c7:	83 ec 08             	sub    $0x8,%esp
f01064ca:	57                   	push   %edi
f01064cb:	50                   	push   %eax
f01064cc:	e8 de ea ff ff       	call   f0104faf <debuginfo_eip>
f01064d1:	83 c4 10             	add    $0x10,%esp
f01064d4:	85 c0                	test   %eax,%eax
f01064d6:	79 b8                	jns    f0106490 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f01064d8:	83 ec 08             	sub    $0x8,%esp
f01064db:	ff 36                	pushl  (%esi)
f01064dd:	68 0f 86 10 f0       	push   $0xf010860f
f01064e2:	e8 a1 d8 ff ff       	call   f0103d88 <cprintf>
f01064e7:	83 c4 10             	add    $0x10,%esp
f01064ea:	eb c9                	jmp    f01064b5 <spin_unlock+0x9d>
		panic("spin_unlock");
f01064ec:	83 ec 04             	sub    $0x4,%esp
f01064ef:	68 17 86 10 f0       	push   $0xf0108617
f01064f4:	6a 67                	push   $0x67
f01064f6:	68 e8 85 10 f0       	push   $0xf01085e8
f01064fb:	e8 40 9b ff ff       	call   f0100040 <_panic>

f0106500 <__udivdi3>:
f0106500:	55                   	push   %ebp
f0106501:	57                   	push   %edi
f0106502:	56                   	push   %esi
f0106503:	53                   	push   %ebx
f0106504:	83 ec 1c             	sub    $0x1c,%esp
f0106507:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010650b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010650f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106513:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106517:	85 d2                	test   %edx,%edx
f0106519:	75 35                	jne    f0106550 <__udivdi3+0x50>
f010651b:	39 f3                	cmp    %esi,%ebx
f010651d:	0f 87 bd 00 00 00    	ja     f01065e0 <__udivdi3+0xe0>
f0106523:	85 db                	test   %ebx,%ebx
f0106525:	89 d9                	mov    %ebx,%ecx
f0106527:	75 0b                	jne    f0106534 <__udivdi3+0x34>
f0106529:	b8 01 00 00 00       	mov    $0x1,%eax
f010652e:	31 d2                	xor    %edx,%edx
f0106530:	f7 f3                	div    %ebx
f0106532:	89 c1                	mov    %eax,%ecx
f0106534:	31 d2                	xor    %edx,%edx
f0106536:	89 f0                	mov    %esi,%eax
f0106538:	f7 f1                	div    %ecx
f010653a:	89 c6                	mov    %eax,%esi
f010653c:	89 e8                	mov    %ebp,%eax
f010653e:	89 f7                	mov    %esi,%edi
f0106540:	f7 f1                	div    %ecx
f0106542:	89 fa                	mov    %edi,%edx
f0106544:	83 c4 1c             	add    $0x1c,%esp
f0106547:	5b                   	pop    %ebx
f0106548:	5e                   	pop    %esi
f0106549:	5f                   	pop    %edi
f010654a:	5d                   	pop    %ebp
f010654b:	c3                   	ret    
f010654c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106550:	39 f2                	cmp    %esi,%edx
f0106552:	77 7c                	ja     f01065d0 <__udivdi3+0xd0>
f0106554:	0f bd fa             	bsr    %edx,%edi
f0106557:	83 f7 1f             	xor    $0x1f,%edi
f010655a:	0f 84 98 00 00 00    	je     f01065f8 <__udivdi3+0xf8>
f0106560:	89 f9                	mov    %edi,%ecx
f0106562:	b8 20 00 00 00       	mov    $0x20,%eax
f0106567:	29 f8                	sub    %edi,%eax
f0106569:	d3 e2                	shl    %cl,%edx
f010656b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010656f:	89 c1                	mov    %eax,%ecx
f0106571:	89 da                	mov    %ebx,%edx
f0106573:	d3 ea                	shr    %cl,%edx
f0106575:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106579:	09 d1                	or     %edx,%ecx
f010657b:	89 f2                	mov    %esi,%edx
f010657d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106581:	89 f9                	mov    %edi,%ecx
f0106583:	d3 e3                	shl    %cl,%ebx
f0106585:	89 c1                	mov    %eax,%ecx
f0106587:	d3 ea                	shr    %cl,%edx
f0106589:	89 f9                	mov    %edi,%ecx
f010658b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010658f:	d3 e6                	shl    %cl,%esi
f0106591:	89 eb                	mov    %ebp,%ebx
f0106593:	89 c1                	mov    %eax,%ecx
f0106595:	d3 eb                	shr    %cl,%ebx
f0106597:	09 de                	or     %ebx,%esi
f0106599:	89 f0                	mov    %esi,%eax
f010659b:	f7 74 24 08          	divl   0x8(%esp)
f010659f:	89 d6                	mov    %edx,%esi
f01065a1:	89 c3                	mov    %eax,%ebx
f01065a3:	f7 64 24 0c          	mull   0xc(%esp)
f01065a7:	39 d6                	cmp    %edx,%esi
f01065a9:	72 0c                	jb     f01065b7 <__udivdi3+0xb7>
f01065ab:	89 f9                	mov    %edi,%ecx
f01065ad:	d3 e5                	shl    %cl,%ebp
f01065af:	39 c5                	cmp    %eax,%ebp
f01065b1:	73 5d                	jae    f0106610 <__udivdi3+0x110>
f01065b3:	39 d6                	cmp    %edx,%esi
f01065b5:	75 59                	jne    f0106610 <__udivdi3+0x110>
f01065b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01065ba:	31 ff                	xor    %edi,%edi
f01065bc:	89 fa                	mov    %edi,%edx
f01065be:	83 c4 1c             	add    $0x1c,%esp
f01065c1:	5b                   	pop    %ebx
f01065c2:	5e                   	pop    %esi
f01065c3:	5f                   	pop    %edi
f01065c4:	5d                   	pop    %ebp
f01065c5:	c3                   	ret    
f01065c6:	8d 76 00             	lea    0x0(%esi),%esi
f01065c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01065d0:	31 ff                	xor    %edi,%edi
f01065d2:	31 c0                	xor    %eax,%eax
f01065d4:	89 fa                	mov    %edi,%edx
f01065d6:	83 c4 1c             	add    $0x1c,%esp
f01065d9:	5b                   	pop    %ebx
f01065da:	5e                   	pop    %esi
f01065db:	5f                   	pop    %edi
f01065dc:	5d                   	pop    %ebp
f01065dd:	c3                   	ret    
f01065de:	66 90                	xchg   %ax,%ax
f01065e0:	31 ff                	xor    %edi,%edi
f01065e2:	89 e8                	mov    %ebp,%eax
f01065e4:	89 f2                	mov    %esi,%edx
f01065e6:	f7 f3                	div    %ebx
f01065e8:	89 fa                	mov    %edi,%edx
f01065ea:	83 c4 1c             	add    $0x1c,%esp
f01065ed:	5b                   	pop    %ebx
f01065ee:	5e                   	pop    %esi
f01065ef:	5f                   	pop    %edi
f01065f0:	5d                   	pop    %ebp
f01065f1:	c3                   	ret    
f01065f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065f8:	39 f2                	cmp    %esi,%edx
f01065fa:	72 06                	jb     f0106602 <__udivdi3+0x102>
f01065fc:	31 c0                	xor    %eax,%eax
f01065fe:	39 eb                	cmp    %ebp,%ebx
f0106600:	77 d2                	ja     f01065d4 <__udivdi3+0xd4>
f0106602:	b8 01 00 00 00       	mov    $0x1,%eax
f0106607:	eb cb                	jmp    f01065d4 <__udivdi3+0xd4>
f0106609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106610:	89 d8                	mov    %ebx,%eax
f0106612:	31 ff                	xor    %edi,%edi
f0106614:	eb be                	jmp    f01065d4 <__udivdi3+0xd4>
f0106616:	66 90                	xchg   %ax,%ax
f0106618:	66 90                	xchg   %ax,%ax
f010661a:	66 90                	xchg   %ax,%ax
f010661c:	66 90                	xchg   %ax,%ax
f010661e:	66 90                	xchg   %ax,%ax

f0106620 <__umoddi3>:
f0106620:	55                   	push   %ebp
f0106621:	57                   	push   %edi
f0106622:	56                   	push   %esi
f0106623:	53                   	push   %ebx
f0106624:	83 ec 1c             	sub    $0x1c,%esp
f0106627:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010662b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010662f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106633:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106637:	85 ed                	test   %ebp,%ebp
f0106639:	89 f0                	mov    %esi,%eax
f010663b:	89 da                	mov    %ebx,%edx
f010663d:	75 19                	jne    f0106658 <__umoddi3+0x38>
f010663f:	39 df                	cmp    %ebx,%edi
f0106641:	0f 86 b1 00 00 00    	jbe    f01066f8 <__umoddi3+0xd8>
f0106647:	f7 f7                	div    %edi
f0106649:	89 d0                	mov    %edx,%eax
f010664b:	31 d2                	xor    %edx,%edx
f010664d:	83 c4 1c             	add    $0x1c,%esp
f0106650:	5b                   	pop    %ebx
f0106651:	5e                   	pop    %esi
f0106652:	5f                   	pop    %edi
f0106653:	5d                   	pop    %ebp
f0106654:	c3                   	ret    
f0106655:	8d 76 00             	lea    0x0(%esi),%esi
f0106658:	39 dd                	cmp    %ebx,%ebp
f010665a:	77 f1                	ja     f010664d <__umoddi3+0x2d>
f010665c:	0f bd cd             	bsr    %ebp,%ecx
f010665f:	83 f1 1f             	xor    $0x1f,%ecx
f0106662:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106666:	0f 84 b4 00 00 00    	je     f0106720 <__umoddi3+0x100>
f010666c:	b8 20 00 00 00       	mov    $0x20,%eax
f0106671:	89 c2                	mov    %eax,%edx
f0106673:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106677:	29 c2                	sub    %eax,%edx
f0106679:	89 c1                	mov    %eax,%ecx
f010667b:	89 f8                	mov    %edi,%eax
f010667d:	d3 e5                	shl    %cl,%ebp
f010667f:	89 d1                	mov    %edx,%ecx
f0106681:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106685:	d3 e8                	shr    %cl,%eax
f0106687:	09 c5                	or     %eax,%ebp
f0106689:	8b 44 24 04          	mov    0x4(%esp),%eax
f010668d:	89 c1                	mov    %eax,%ecx
f010668f:	d3 e7                	shl    %cl,%edi
f0106691:	89 d1                	mov    %edx,%ecx
f0106693:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106697:	89 df                	mov    %ebx,%edi
f0106699:	d3 ef                	shr    %cl,%edi
f010669b:	89 c1                	mov    %eax,%ecx
f010669d:	89 f0                	mov    %esi,%eax
f010669f:	d3 e3                	shl    %cl,%ebx
f01066a1:	89 d1                	mov    %edx,%ecx
f01066a3:	89 fa                	mov    %edi,%edx
f01066a5:	d3 e8                	shr    %cl,%eax
f01066a7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01066ac:	09 d8                	or     %ebx,%eax
f01066ae:	f7 f5                	div    %ebp
f01066b0:	d3 e6                	shl    %cl,%esi
f01066b2:	89 d1                	mov    %edx,%ecx
f01066b4:	f7 64 24 08          	mull   0x8(%esp)
f01066b8:	39 d1                	cmp    %edx,%ecx
f01066ba:	89 c3                	mov    %eax,%ebx
f01066bc:	89 d7                	mov    %edx,%edi
f01066be:	72 06                	jb     f01066c6 <__umoddi3+0xa6>
f01066c0:	75 0e                	jne    f01066d0 <__umoddi3+0xb0>
f01066c2:	39 c6                	cmp    %eax,%esi
f01066c4:	73 0a                	jae    f01066d0 <__umoddi3+0xb0>
f01066c6:	2b 44 24 08          	sub    0x8(%esp),%eax
f01066ca:	19 ea                	sbb    %ebp,%edx
f01066cc:	89 d7                	mov    %edx,%edi
f01066ce:	89 c3                	mov    %eax,%ebx
f01066d0:	89 ca                	mov    %ecx,%edx
f01066d2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01066d7:	29 de                	sub    %ebx,%esi
f01066d9:	19 fa                	sbb    %edi,%edx
f01066db:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01066df:	89 d0                	mov    %edx,%eax
f01066e1:	d3 e0                	shl    %cl,%eax
f01066e3:	89 d9                	mov    %ebx,%ecx
f01066e5:	d3 ee                	shr    %cl,%esi
f01066e7:	d3 ea                	shr    %cl,%edx
f01066e9:	09 f0                	or     %esi,%eax
f01066eb:	83 c4 1c             	add    $0x1c,%esp
f01066ee:	5b                   	pop    %ebx
f01066ef:	5e                   	pop    %esi
f01066f0:	5f                   	pop    %edi
f01066f1:	5d                   	pop    %ebp
f01066f2:	c3                   	ret    
f01066f3:	90                   	nop
f01066f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01066f8:	85 ff                	test   %edi,%edi
f01066fa:	89 f9                	mov    %edi,%ecx
f01066fc:	75 0b                	jne    f0106709 <__umoddi3+0xe9>
f01066fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0106703:	31 d2                	xor    %edx,%edx
f0106705:	f7 f7                	div    %edi
f0106707:	89 c1                	mov    %eax,%ecx
f0106709:	89 d8                	mov    %ebx,%eax
f010670b:	31 d2                	xor    %edx,%edx
f010670d:	f7 f1                	div    %ecx
f010670f:	89 f0                	mov    %esi,%eax
f0106711:	f7 f1                	div    %ecx
f0106713:	e9 31 ff ff ff       	jmp    f0106649 <__umoddi3+0x29>
f0106718:	90                   	nop
f0106719:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106720:	39 dd                	cmp    %ebx,%ebp
f0106722:	72 08                	jb     f010672c <__umoddi3+0x10c>
f0106724:	39 f7                	cmp    %esi,%edi
f0106726:	0f 87 21 ff ff ff    	ja     f010664d <__umoddi3+0x2d>
f010672c:	89 da                	mov    %ebx,%edx
f010672e:	89 f0                	mov    %esi,%eax
f0106730:	29 f8                	sub    %edi,%eax
f0106732:	19 ea                	sbb    %ebp,%edx
f0106734:	e9 14 ff ff ff       	jmp    f010664d <__umoddi3+0x2d>
