
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 5e 1b 00 00       	call   801b8f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800075:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800086:	a8 a1                	test   $0xa1,%al
  800088:	74 0b                	je     800095 <ide_probe_disk1+0x36>
	     x++)
  80008a:	83 c1 01             	add    $0x1,%ecx
	for (x = 0;
  80008d:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800093:	75 f0                	jne    800085 <ide_probe_disk1+0x26>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800095:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009a:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a6:	0f 9e c3             	setle  %bl
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	0f b6 c3             	movzbl %bl,%eax
  8000af:	50                   	push   %eax
  8000b0:	68 c0 39 80 00       	push   $0x8039c0
  8000b5:	e8 10 1c 00 00       	call   801cca <cprintf>
	return (x < 1000);
}
  8000ba:	89 d8                	mov    %ebx,%eax
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000ca:	83 f8 01             	cmp    $0x1,%eax
  8000cd:	77 07                	ja     8000d6 <ide_set_disk+0x15>
		panic("bad disk number");
	diskno = d;
  8000cf:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    
		panic("bad disk number");
  8000d6:	83 ec 04             	sub    $0x4,%esp
  8000d9:	68 d7 39 80 00       	push   $0x8039d7
  8000de:	6a 3a                	push   $0x3a
  8000e0:	68 e7 39 80 00       	push   $0x8039e7
  8000e5:	e8 05 1b 00 00       	call   801bef <_panic>

008000ea <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fc:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800102:	0f 87 87 00 00 00    	ja     80018f <ide_read+0xa5>

	ide_wait_ready(0);
  800108:	b8 00 00 00 00       	mov    $0x0,%eax
  80010d:	e8 21 ff ff ff       	call   800033 <ide_wait_ready>
  800112:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800117:	89 f0                	mov    %esi,%eax
  800119:	ee                   	out    %al,(%dx)
  80011a:	ba f3 01 00 00       	mov    $0x1f3,%edx
  80011f:	89 f8                	mov    %edi,%eax
  800121:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800122:	89 f8                	mov    %edi,%eax
  800124:	c1 e8 08             	shr    $0x8,%eax
  800127:	ba f4 01 00 00       	mov    $0x1f4,%edx
  80012c:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  80012d:	89 f8                	mov    %edi,%eax
  80012f:	c1 e8 10             	shr    $0x10,%eax
  800132:	ba f5 01 00 00       	mov    $0x1f5,%edx
  800137:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800138:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  80013f:	c1 e0 04             	shl    $0x4,%eax
  800142:	83 e0 10             	and    $0x10,%eax
  800145:	83 c8 e0             	or     $0xffffffe0,%eax
  800148:	c1 ef 18             	shr    $0x18,%edi
  80014b:	83 e7 0f             	and    $0xf,%edi
  80014e:	09 f8                	or     %edi,%eax
  800150:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800155:	ee                   	out    %al,(%dx)
  800156:	b8 20 00 00 00       	mov    $0x20,%eax
  80015b:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800160:	ee                   	out    %al,(%dx)
  800161:	c1 e6 09             	shl    $0x9,%esi
  800164:	01 de                	add    %ebx,%esi
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800166:	39 f3                	cmp    %esi,%ebx
  800168:	74 3b                	je     8001a5 <ide_read+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  80016a:	b8 01 00 00 00       	mov    $0x1,%eax
  80016f:	e8 bf fe ff ff       	call   800033 <ide_wait_ready>
  800174:	85 c0                	test   %eax,%eax
  800176:	78 32                	js     8001aa <ide_read+0xc0>
	asm volatile("cld\n\trepne\n\tinsl"
  800178:	89 df                	mov    %ebx,%edi
  80017a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80017f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800184:	fc                   	cld    
  800185:	f2 6d                	repnz insl (%dx),%es:(%edi)
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800187:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80018d:	eb d7                	jmp    800166 <ide_read+0x7c>
	assert(nsecs <= 256);
  80018f:	68 f0 39 80 00       	push   $0x8039f0
  800194:	68 fd 39 80 00       	push   $0x8039fd
  800199:	6a 44                	push   $0x44
  80019b:	68 e7 39 80 00       	push   $0x8039e7
  8001a0:	e8 4a 1a 00 00       	call   801bef <_panic>
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c1:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c4:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001ca:	0f 87 87 00 00 00    	ja     800257 <ide_write+0xa5>

	ide_wait_ready(0);
  8001d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d5:	e8 59 fe ff ff       	call   800033 <ide_wait_ready>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001da:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001df:	89 f8                	mov    %edi,%eax
  8001e1:	ee                   	out    %al,(%dx)
  8001e2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001e7:	89 f0                	mov    %esi,%eax
  8001e9:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001ea:	89 f0                	mov    %esi,%eax
  8001ec:	c1 e8 08             	shr    $0x8,%eax
  8001ef:	ba f4 01 00 00       	mov    $0x1f4,%edx
  8001f4:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001f5:	89 f0                	mov    %esi,%eax
  8001f7:	c1 e8 10             	shr    $0x10,%eax
  8001fa:	ba f5 01 00 00       	mov    $0x1f5,%edx
  8001ff:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800200:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800207:	c1 e0 04             	shl    $0x4,%eax
  80020a:	83 e0 10             	and    $0x10,%eax
  80020d:	83 c8 e0             	or     $0xffffffe0,%eax
  800210:	c1 ee 18             	shr    $0x18,%esi
  800213:	83 e6 0f             	and    $0xf,%esi
  800216:	09 f0                	or     %esi,%eax
  800218:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80021d:	ee                   	out    %al,(%dx)
  80021e:	b8 30 00 00 00       	mov    $0x30,%eax
  800223:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800228:	ee                   	out    %al,(%dx)
  800229:	c1 e7 09             	shl    $0x9,%edi
  80022c:	01 df                	add    %ebx,%edi
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80022e:	39 fb                	cmp    %edi,%ebx
  800230:	74 3b                	je     80026d <ide_write+0xbb>
		if ((r = ide_wait_ready(1)) < 0)
  800232:	b8 01 00 00 00       	mov    $0x1,%eax
  800237:	e8 f7 fd ff ff       	call   800033 <ide_wait_ready>
  80023c:	85 c0                	test   %eax,%eax
  80023e:	78 32                	js     800272 <ide_write+0xc0>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800240:	89 de                	mov    %ebx,%esi
  800242:	b9 80 00 00 00       	mov    $0x80,%ecx
  800247:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80024c:	fc                   	cld    
  80024d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80024f:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800255:	eb d7                	jmp    80022e <ide_write+0x7c>
	assert(nsecs <= 256);
  800257:	68 f0 39 80 00       	push   $0x8039f0
  80025c:	68 fd 39 80 00       	push   $0x8039fd
  800261:	6a 5d                	push   $0x5d
  800263:	68 e7 39 80 00       	push   $0x8039e7
  800268:	e8 82 19 00 00       	call   801bef <_panic>
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800282:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800284:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80028a:	89 c6                	mov    %eax,%esi
  80028c:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80028f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800294:	0f 87 95 00 00 00    	ja     80032f <bc_pgfault+0xb5>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80029a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80029f:	85 c0                	test   %eax,%eax
  8002a1:	74 09                	je     8002ac <bc_pgfault+0x32>
  8002a3:	39 70 04             	cmp    %esi,0x4(%eax)
  8002a6:	0f 86 9e 00 00 00    	jbe    80034a <bc_pgfault+0xd0>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
    addr = (void *)(void *) ROUNDDOWN(addr, PGSIZE);
  8002ac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    if ((r = sys_page_alloc(0, addr, PTE_U | PTE_W | PTE_P)) < 0)
  8002b2:	83 ec 04             	sub    $0x4,%esp
  8002b5:	6a 07                	push   $0x7
  8002b7:	53                   	push   %ebx
  8002b8:	6a 00                	push   $0x0
  8002ba:	e8 23 24 00 00       	call   8026e2 <sys_page_alloc>
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 88 92 00 00 00    	js     80035c <bc_pgfault+0xe2>
        panic("in bc_pgfault, sys_page_alloc: %e", r);

    if (ide_read(blockno * BLKSECTS, addr, BLKSECTS) < 0)
  8002ca:	83 ec 04             	sub    $0x4,%esp
  8002cd:	6a 08                	push   $0x8
  8002cf:	53                   	push   %ebx
  8002d0:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002d7:	50                   	push   %eax
  8002d8:	e8 0d fe ff ff       	call   8000ea <ide_read>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 88 86 00 00 00    	js     80036e <bc_pgfault+0xf4>
        panic("in bc_pgfault, ide_read read error");

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002e8:	89 d8                	mov    %ebx,%eax
  8002ea:	c1 e8 0c             	shr    $0xc,%eax
  8002ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8002fc:	50                   	push   %eax
  8002fd:	53                   	push   %ebx
  8002fe:	6a 00                	push   $0x0
  800300:	53                   	push   %ebx
  800301:	6a 00                	push   $0x0
  800303:	e8 1d 24 00 00       	call   802725 <sys_page_map>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	85 c0                	test   %eax,%eax
  80030d:	78 73                	js     800382 <bc_pgfault+0x108>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80030f:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800316:	74 10                	je     800328 <bc_pgfault+0xae>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	56                   	push   %esi
  80031c:	e8 11 05 00 00       	call   800832 <block_is_free>
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	84 c0                	test   %al,%al
  800326:	75 6c                	jne    800394 <bc_pgfault+0x11a>
		panic("reading free block %08x\n", blockno);
}
  800328:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	ff 72 04             	pushl  0x4(%edx)
  800335:	53                   	push   %ebx
  800336:	ff 72 28             	pushl  0x28(%edx)
  800339:	68 14 3a 80 00       	push   $0x803a14
  80033e:	6a 27                	push   $0x27
  800340:	68 64 3b 80 00       	push   $0x803b64
  800345:	e8 a5 18 00 00       	call   801bef <_panic>
		panic("reading non-existent block %08x\n", blockno);
  80034a:	56                   	push   %esi
  80034b:	68 44 3a 80 00       	push   $0x803a44
  800350:	6a 2b                	push   $0x2b
  800352:	68 64 3b 80 00       	push   $0x803b64
  800357:	e8 93 18 00 00       	call   801bef <_panic>
        panic("in bc_pgfault, sys_page_alloc: %e", r);
  80035c:	50                   	push   %eax
  80035d:	68 68 3a 80 00       	push   $0x803a68
  800362:	6a 35                	push   $0x35
  800364:	68 64 3b 80 00       	push   $0x803b64
  800369:	e8 81 18 00 00       	call   801bef <_panic>
        panic("in bc_pgfault, ide_read read error");
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	68 8c 3a 80 00       	push   $0x803a8c
  800376:	6a 38                	push   $0x38
  800378:	68 64 3b 80 00       	push   $0x803b64
  80037d:	e8 6d 18 00 00       	call   801bef <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800382:	50                   	push   %eax
  800383:	68 b0 3a 80 00       	push   $0x803ab0
  800388:	6a 3d                	push   $0x3d
  80038a:	68 64 3b 80 00       	push   $0x803b64
  80038f:	e8 5b 18 00 00       	call   801bef <_panic>
		panic("reading free block %08x\n", blockno);
  800394:	56                   	push   %esi
  800395:	68 6c 3b 80 00       	push   $0x803b6c
  80039a:	6a 43                	push   $0x43
  80039c:	68 64 3b 80 00       	push   $0x803b64
  8003a1:	e8 49 18 00 00       	call   801bef <_panic>

008003a6 <diskaddr>:
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	74 19                	je     8003cc <diskaddr+0x26>
  8003b3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	74 05                	je     8003c2 <diskaddr+0x1c>
  8003bd:	39 42 04             	cmp    %eax,0x4(%edx)
  8003c0:	76 0a                	jbe    8003cc <diskaddr+0x26>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c2:	05 00 00 01 00       	add    $0x10000,%eax
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  8003cc:	50                   	push   %eax
  8003cd:	68 d0 3a 80 00       	push   $0x803ad0
  8003d2:	6a 09                	push   $0x9
  8003d4:	68 64 3b 80 00       	push   $0x803b64
  8003d9:	e8 11 18 00 00       	call   801bef <_panic>

008003de <va_is_mapped>:
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003e4:	89 d0                	mov    %edx,%eax
  8003e6:	c1 e8 16             	shr    $0x16,%eax
  8003e9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	f6 c1 01             	test   $0x1,%cl
  8003f8:	74 0d                	je     800407 <va_is_mapped+0x29>
  8003fa:	c1 ea 0c             	shr    $0xc,%edx
  8003fd:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800404:	83 e0 01             	and    $0x1,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <va_is_dirty>:
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
  800412:	c1 e8 0c             	shr    $0xc,%eax
  800415:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80041c:	c1 e8 06             	shr    $0x6,%eax
  80041f:	83 e0 01             	and    $0x1,%eax
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    

00800424 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	56                   	push   %esi
  800428:	53                   	push   %ebx
  800429:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
    int r;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80042c:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800432:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800437:	77 1f                	ja     800458 <flush_block+0x34>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
    addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800439:	89 de                	mov    %ebx,%esi
  80043b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    if (!va_is_mapped(addr))
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	56                   	push   %esi
  800445:	e8 94 ff ff ff       	call   8003de <va_is_mapped>
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	84 c0                	test   %al,%al
  80044f:	75 19                	jne    80046a <flush_block+0x46>
        return;
    if (ide_write(blockno * BLKSECTS, addr, BLKSECTS) < 0)
        panic("in flush_block, ide_write read error");
    if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
        panic("in flush_block, sys_page_map: %e", r);
}
  800451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800454:	5b                   	pop    %ebx
  800455:	5e                   	pop    %esi
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  800458:	53                   	push   %ebx
  800459:	68 85 3b 80 00       	push   $0x803b85
  80045e:	6a 54                	push   $0x54
  800460:	68 64 3b 80 00       	push   $0x803b64
  800465:	e8 85 17 00 00       	call   801bef <_panic>
    if (!va_is_dirty(addr))
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	56                   	push   %esi
  80046e:	e8 99 ff ff ff       	call   80040c <va_is_dirty>
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	84 c0                	test   %al,%al
  800478:	74 d7                	je     800451 <flush_block+0x2d>
    if (ide_write(blockno * BLKSECTS, addr, BLKSECTS) < 0)
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	6a 08                	push   $0x8
  80047f:	56                   	push   %esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800480:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800486:	c1 eb 0c             	shr    $0xc,%ebx
    if (ide_write(blockno * BLKSECTS, addr, BLKSECTS) < 0)
  800489:	c1 e3 03             	shl    $0x3,%ebx
  80048c:	53                   	push   %ebx
  80048d:	e8 20 fd ff ff       	call   8001b2 <ide_write>
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 c0                	test   %eax,%eax
  800497:	78 39                	js     8004d2 <flush_block+0xae>
    if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800499:	89 f0                	mov    %esi,%eax
  80049b:	c1 e8 0c             	shr    $0xc,%eax
  80049e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004a5:	83 ec 0c             	sub    $0xc,%esp
  8004a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8004ad:	50                   	push   %eax
  8004ae:	56                   	push   %esi
  8004af:	6a 00                	push   $0x0
  8004b1:	56                   	push   %esi
  8004b2:	6a 00                	push   $0x0
  8004b4:	e8 6c 22 00 00       	call   802725 <sys_page_map>
  8004b9:	83 c4 20             	add    $0x20,%esp
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	79 91                	jns    800451 <flush_block+0x2d>
        panic("in flush_block, sys_page_map: %e", r);
  8004c0:	50                   	push   %eax
  8004c1:	68 1c 3b 80 00       	push   $0x803b1c
  8004c6:	6a 5f                	push   $0x5f
  8004c8:	68 64 3b 80 00       	push   $0x803b64
  8004cd:	e8 1d 17 00 00       	call   801bef <_panic>
        panic("in flush_block, ide_write read error");
  8004d2:	83 ec 04             	sub    $0x4,%esp
  8004d5:	68 f4 3a 80 00       	push   $0x803af4
  8004da:	6a 5d                	push   $0x5d
  8004dc:	68 64 3b 80 00       	push   $0x803b64
  8004e1:	e8 09 17 00 00       	call   801bef <_panic>

008004e6 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	53                   	push   %ebx
  8004ea:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004f0:	68 7a 02 80 00       	push   $0x80027a
  8004f5:	e8 d9 23 00 00       	call   8028d3 <set_pgfault_handler>
	memmove(&backup, diskaddr(1), sizeof backup);
  8004fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800501:	e8 a0 fe ff ff       	call   8003a6 <diskaddr>
  800506:	83 c4 0c             	add    $0xc,%esp
  800509:	68 08 01 00 00       	push   $0x108
  80050e:	50                   	push   %eax
  80050f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800515:	50                   	push   %eax
  800516:	e8 5c 1f 00 00       	call   802477 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80051b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800522:	e8 7f fe ff ff       	call   8003a6 <diskaddr>
  800527:	83 c4 08             	add    $0x8,%esp
  80052a:	68 a0 3b 80 00       	push   $0x803ba0
  80052f:	50                   	push   %eax
  800530:	e8 b4 1d 00 00       	call   8022e9 <strcpy>
	flush_block(diskaddr(1));
  800535:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053c:	e8 65 fe ff ff       	call   8003a6 <diskaddr>
  800541:	89 04 24             	mov    %eax,(%esp)
  800544:	e8 db fe ff ff       	call   800424 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800549:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800550:	e8 51 fe ff ff       	call   8003a6 <diskaddr>
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	e8 81 fe ff ff       	call   8003de <va_is_mapped>
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	84 c0                	test   %al,%al
  800562:	0f 84 d1 01 00 00    	je     800739 <bc_init+0x253>
	assert(!va_is_dirty(diskaddr(1)));
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	6a 01                	push   $0x1
  80056d:	e8 34 fe ff ff       	call   8003a6 <diskaddr>
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	e8 92 fe ff ff       	call   80040c <va_is_dirty>
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	84 c0                	test   %al,%al
  80057f:	0f 85 ca 01 00 00    	jne    80074f <bc_init+0x269>
	sys_page_unmap(0, diskaddr(1));
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	6a 01                	push   $0x1
  80058a:	e8 17 fe ff ff       	call   8003a6 <diskaddr>
  80058f:	83 c4 08             	add    $0x8,%esp
  800592:	50                   	push   %eax
  800593:	6a 00                	push   $0x0
  800595:	e8 cd 21 00 00       	call   802767 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80059a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a1:	e8 00 fe ff ff       	call   8003a6 <diskaddr>
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	e8 30 fe ff ff       	call   8003de <va_is_mapped>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	84 c0                	test   %al,%al
  8005b3:	0f 85 ac 01 00 00    	jne    800765 <bc_init+0x27f>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	6a 01                	push   $0x1
  8005be:	e8 e3 fd ff ff       	call   8003a6 <diskaddr>
  8005c3:	83 c4 08             	add    $0x8,%esp
  8005c6:	68 a0 3b 80 00       	push   $0x803ba0
  8005cb:	50                   	push   %eax
  8005cc:	e8 be 1d 00 00       	call   80238f <strcmp>
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	0f 85 9f 01 00 00    	jne    80077b <bc_init+0x295>
	memmove(diskaddr(1), &backup, sizeof backup);
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	6a 01                	push   $0x1
  8005e1:	e8 c0 fd ff ff       	call   8003a6 <diskaddr>
  8005e6:	83 c4 0c             	add    $0xc,%esp
  8005e9:	68 08 01 00 00       	push   $0x108
  8005ee:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8005f4:	53                   	push   %ebx
  8005f5:	50                   	push   %eax
  8005f6:	e8 7c 1e 00 00       	call   802477 <memmove>
	flush_block(diskaddr(1));
  8005fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800602:	e8 9f fd ff ff       	call   8003a6 <diskaddr>
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	e8 15 fe ff ff       	call   800424 <flush_block>
	memmove(&backup, diskaddr(1), sizeof backup);
  80060f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800616:	e8 8b fd ff ff       	call   8003a6 <diskaddr>
  80061b:	83 c4 0c             	add    $0xc,%esp
  80061e:	68 08 01 00 00       	push   $0x108
  800623:	50                   	push   %eax
  800624:	53                   	push   %ebx
  800625:	e8 4d 1e 00 00       	call   802477 <memmove>
	strcpy(diskaddr(1), "OOPS!\n");
  80062a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800631:	e8 70 fd ff ff       	call   8003a6 <diskaddr>
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	68 a0 3b 80 00       	push   $0x803ba0
  80063e:	50                   	push   %eax
  80063f:	e8 a5 1c 00 00       	call   8022e9 <strcpy>
	flush_block(diskaddr(1) + 20);
  800644:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80064b:	e8 56 fd ff ff       	call   8003a6 <diskaddr>
  800650:	83 c0 14             	add    $0x14,%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	e8 c9 fd ff ff       	call   800424 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80065b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800662:	e8 3f fd ff ff       	call   8003a6 <diskaddr>
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 6f fd ff ff       	call   8003de <va_is_mapped>
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	84 c0                	test   %al,%al
  800674:	0f 84 17 01 00 00    	je     800791 <bc_init+0x2ab>
	sys_page_unmap(0, diskaddr(1));
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	6a 01                	push   $0x1
  80067f:	e8 22 fd ff ff       	call   8003a6 <diskaddr>
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	50                   	push   %eax
  800688:	6a 00                	push   $0x0
  80068a:	e8 d8 20 00 00       	call   802767 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80068f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800696:	e8 0b fd ff ff       	call   8003a6 <diskaddr>
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	e8 3b fd ff ff       	call   8003de <va_is_mapped>
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	84 c0                	test   %al,%al
  8006a8:	0f 85 fc 00 00 00    	jne    8007aa <bc_init+0x2c4>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006ae:	83 ec 0c             	sub    $0xc,%esp
  8006b1:	6a 01                	push   $0x1
  8006b3:	e8 ee fc ff ff       	call   8003a6 <diskaddr>
  8006b8:	83 c4 08             	add    $0x8,%esp
  8006bb:	68 a0 3b 80 00       	push   $0x803ba0
  8006c0:	50                   	push   %eax
  8006c1:	e8 c9 1c 00 00       	call   80238f <strcmp>
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	0f 85 f2 00 00 00    	jne    8007c3 <bc_init+0x2dd>
	memmove(diskaddr(1), &backup, sizeof backup);
  8006d1:	83 ec 0c             	sub    $0xc,%esp
  8006d4:	6a 01                	push   $0x1
  8006d6:	e8 cb fc ff ff       	call   8003a6 <diskaddr>
  8006db:	83 c4 0c             	add    $0xc,%esp
  8006de:	68 08 01 00 00       	push   $0x108
  8006e3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8006e9:	52                   	push   %edx
  8006ea:	50                   	push   %eax
  8006eb:	e8 87 1d 00 00       	call   802477 <memmove>
	flush_block(diskaddr(1));
  8006f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006f7:	e8 aa fc ff ff       	call   8003a6 <diskaddr>
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	e8 20 fd ff ff       	call   800424 <flush_block>
	cprintf("block cache is good\n");
  800704:	c7 04 24 dc 3b 80 00 	movl   $0x803bdc,(%esp)
  80070b:	e8 ba 15 00 00       	call   801cca <cprintf>
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800710:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800717:	e8 8a fc ff ff       	call   8003a6 <diskaddr>
  80071c:	83 c4 0c             	add    $0xc,%esp
  80071f:	68 08 01 00 00       	push   $0x108
  800724:	50                   	push   %eax
  800725:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80072b:	50                   	push   %eax
  80072c:	e8 46 1d 00 00       	call   802477 <memmove>
}
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800737:	c9                   	leave  
  800738:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  800739:	68 c2 3b 80 00       	push   $0x803bc2
  80073e:	68 fd 39 80 00       	push   $0x8039fd
  800743:	6a 6f                	push   $0x6f
  800745:	68 64 3b 80 00       	push   $0x803b64
  80074a:	e8 a0 14 00 00       	call   801bef <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80074f:	68 a7 3b 80 00       	push   $0x803ba7
  800754:	68 fd 39 80 00       	push   $0x8039fd
  800759:	6a 70                	push   $0x70
  80075b:	68 64 3b 80 00       	push   $0x803b64
  800760:	e8 8a 14 00 00       	call   801bef <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800765:	68 c1 3b 80 00       	push   $0x803bc1
  80076a:	68 fd 39 80 00       	push   $0x8039fd
  80076f:	6a 74                	push   $0x74
  800771:	68 64 3b 80 00       	push   $0x803b64
  800776:	e8 74 14 00 00       	call   801bef <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80077b:	68 40 3b 80 00       	push   $0x803b40
  800780:	68 fd 39 80 00       	push   $0x8039fd
  800785:	6a 77                	push   $0x77
  800787:	68 64 3b 80 00       	push   $0x803b64
  80078c:	e8 5e 14 00 00       	call   801bef <_panic>
	assert(va_is_mapped(diskaddr(1)));
  800791:	68 c2 3b 80 00       	push   $0x803bc2
  800796:	68 fd 39 80 00       	push   $0x8039fd
  80079b:	68 88 00 00 00       	push   $0x88
  8007a0:	68 64 3b 80 00       	push   $0x803b64
  8007a5:	e8 45 14 00 00       	call   801bef <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  8007aa:	68 c1 3b 80 00       	push   $0x803bc1
  8007af:	68 fd 39 80 00       	push   $0x8039fd
  8007b4:	68 90 00 00 00       	push   $0x90
  8007b9:	68 64 3b 80 00       	push   $0x803b64
  8007be:	e8 2c 14 00 00       	call   801bef <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007c3:	68 40 3b 80 00       	push   $0x803b40
  8007c8:	68 fd 39 80 00       	push   $0x8039fd
  8007cd:	68 93 00 00 00       	push   $0x93
  8007d2:	68 64 3b 80 00       	push   $0x803b64
  8007d7:	e8 13 14 00 00       	call   801bef <_panic>

008007dc <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  8007e2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007e7:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8007ed:	75 1b                	jne    80080a <check_super+0x2e>
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007ef:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007f6:	77 26                	ja     80081e <check_super+0x42>
		panic("file system is too large");

	cprintf("superblock is good\n");
  8007f8:	83 ec 0c             	sub    $0xc,%esp
  8007fb:	68 2f 3c 80 00       	push   $0x803c2f
  800800:	e8 c5 14 00 00       	call   801cca <cprintf>
}
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	c9                   	leave  
  800809:	c3                   	ret    
		panic("bad file system magic number");
  80080a:	83 ec 04             	sub    $0x4,%esp
  80080d:	68 f1 3b 80 00       	push   $0x803bf1
  800812:	6a 0f                	push   $0xf
  800814:	68 0e 3c 80 00       	push   $0x803c0e
  800819:	e8 d1 13 00 00       	call   801bef <_panic>
		panic("file system is too large");
  80081e:	83 ec 04             	sub    $0x4,%esp
  800821:	68 16 3c 80 00       	push   $0x803c16
  800826:	6a 12                	push   $0x12
  800828:	68 0e 3c 80 00       	push   $0x803c0e
  80082d:	e8 bd 13 00 00       	call   801bef <_panic>

00800832 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800839:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
		return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800844:	85 d2                	test   %edx,%edx
  800846:	74 1d                	je     800865 <block_is_free+0x33>
  800848:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80084b:	76 18                	jbe    800865 <block_is_free+0x33>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80084d:	89 cb                	mov    %ecx,%ebx
  80084f:	c1 eb 05             	shr    $0x5,%ebx
  800852:	b8 01 00 00 00       	mov    $0x1,%eax
  800857:	d3 e0                	shl    %cl,%eax
  800859:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80085f:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800862:	0f 95 c0             	setne  %al
		return 1;
	return 0;
}
  800865:	5b                   	pop    %ebx
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	83 ec 04             	sub    $0x4,%esp
  80086f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800872:	85 c9                	test   %ecx,%ecx
  800874:	74 1a                	je     800890 <free_block+0x28>
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
  800876:	89 cb                	mov    %ecx,%ebx
  800878:	c1 eb 05             	shr    $0x5,%ebx
  80087b:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800881:	b8 01 00 00 00       	mov    $0x1,%eax
  800886:	d3 e0                	shl    %cl,%eax
  800888:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80088b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    
		panic("attempt to free zero block");
  800890:	83 ec 04             	sub    $0x4,%esp
  800893:	68 43 3c 80 00       	push   $0x803c43
  800898:	6a 2d                	push   $0x2d
  80089a:	68 0e 3c 80 00       	push   $0x803c0e
  80089f:	e8 4b 13 00 00       	call   801bef <_panic>

008008a4 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 2c             	sub    $0x2c,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
    int i, j, blockno;
    if (super == 0) {
  8008ad:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	0f 84 99 00 00 00    	je     800953 <alloc_block+0xaf>
  8008ba:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8008c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        return -E_NO_DISK;
    }
	for (i=0; i < super->s_nblocks / 32; i++ ) {
  8008c3:	8b 40 04             	mov    0x4(%eax),%eax
  8008c6:	c1 e8 05             	shr    $0x5,%eax
  8008c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8008d1:	eb 37                	jmp    80090a <alloc_block+0x66>
			continue;

        blockno = i * 32;
        for (j =0; j < 32; j++) {
            if (block_is_free(blockno)) {
                bitmap[i] &= ~(1<<j);
  8008d3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
  8008d8:	89 f1                	mov    %esi,%ecx
  8008da:	d3 c0                	rol    %cl,%eax
  8008dc:	23 45 d8             	and    -0x28(%ebp),%eax
  8008df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008e2:	89 02                	mov    %eax,(%edx)
                flush_block(bitmap + i);
  8008e4:	83 ec 0c             	sub    $0xc,%esp
  8008e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008ea:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008f0:	50                   	push   %eax
  8008f1:	e8 2e fb ff ff       	call   800424 <flush_block>
                return blockno;
  8008f6:	83 c4 10             	add    $0x10,%esp
            }
            blockno ++;
        }
	}
	return -E_NO_DISK;
}
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5f                   	pop    %edi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
	for (i=0; i < super->s_nblocks / 32; i++ ) {
  800903:	83 c7 01             	add    $0x1,%edi
  800906:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
  80090a:	3b 7d e0             	cmp    -0x20(%ebp),%edi
  80090d:	74 3d                	je     80094c <alloc_block+0xa8>
  80090f:	8d 04 bd 00 00 00 00 	lea    0x0(,%edi,4),%eax
  800916:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if (bitmap[i] == 0)
  800919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800924:	85 c0                	test   %eax,%eax
  800926:	74 db                	je     800903 <alloc_block+0x5f>
  800928:	89 fb                	mov    %edi,%ebx
  80092a:	c1 e3 05             	shl    $0x5,%ebx
        for (j =0; j < 32; j++) {
  80092d:	be 00 00 00 00       	mov    $0x0,%esi
            if (block_is_free(blockno)) {
  800932:	53                   	push   %ebx
  800933:	e8 fa fe ff ff       	call   800832 <block_is_free>
  800938:	83 c4 04             	add    $0x4,%esp
  80093b:	84 c0                	test   %al,%al
  80093d:	75 94                	jne    8008d3 <alloc_block+0x2f>
            blockno ++;
  80093f:	83 c3 01             	add    $0x1,%ebx
        for (j =0; j < 32; j++) {
  800942:	83 c6 01             	add    $0x1,%esi
  800945:	83 fe 20             	cmp    $0x20,%esi
  800948:	75 e8                	jne    800932 <alloc_block+0x8e>
  80094a:	eb b7                	jmp    800903 <alloc_block+0x5f>
	return -E_NO_DISK;
  80094c:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
  800951:	eb a6                	jmp    8008f9 <alloc_block+0x55>
        return -E_NO_DISK;
  800953:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
  800958:	eb 9f                	jmp    8008f9 <alloc_block+0x55>

0080095a <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	57                   	push   %edi
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	83 ec 1c             	sub    $0x1c,%esp
  800963:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
    uint32_t *addr, *indr_addr;
    int r;
    if (filebno  >= NDIRECT + NINDIRECT) {
  800966:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80096c:	0f 87 f8 00 00 00    	ja     800a6a <file_block_walk+0x110>
  800972:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800975:	89 d3                	mov    %edx,%ebx
  800977:	89 c6                	mov    %eax,%esi
        return -E_INVAL;
    }
    // in f_direct
    if (filebno < NDIRECT) {
  800979:	83 fa 09             	cmp    $0x9,%edx
  80097c:	77 54                	ja     8009d2 <file_block_walk+0x78>
  80097e:	8d 04 90             	lea    (%eax,%edx,4),%eax
        // if not have this direct block
        if (f->f_direct[filebno] == 0) {
  800981:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800984:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80098b:	75 28                	jne    8009b5 <file_block_walk+0x5b>
            if (!alloc)
  80098d:	89 f8                	mov    %edi,%eax
  80098f:	84 c0                	test   %al,%al
  800991:	0f 84 dd 00 00 00    	je     800a74 <file_block_walk+0x11a>
                return -E_NOT_FOUND;
            if ((r = alloc_block()) < 0)
  800997:	e8 08 ff ff ff       	call   8008a4 <alloc_block>
  80099c:	85 c0                	test   %eax,%eax
  80099e:	78 2a                	js     8009ca <file_block_walk+0x70>
                return r;
            f->f_direct[filebno] = r;
  8009a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a3:	89 81 88 00 00 00    	mov    %eax,0x88(%ecx)
            flush_block(f);
  8009a9:	83 ec 0c             	sub    $0xc,%esp
  8009ac:	56                   	push   %esi
  8009ad:	e8 72 fa ff ff       	call   800424 <flush_block>
  8009b2:	83 c4 10             	add    $0x10,%esp
        }
        addr = &(f->f_direct[filebno]);
  8009b5:	8d 9c 9e 88 00 00 00 	lea    0x88(%esi,%ebx,4),%ebx
        addr = indr_addr + filebno;
    }
    if (ppdiskbno != NULL) {
        *ppdiskbno = addr;
    }
    return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
    if (ppdiskbno != NULL) {
  8009c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009c4:	85 ff                	test   %edi,%edi
  8009c6:	74 02                	je     8009ca <file_block_walk+0x70>
        *ppdiskbno = addr;
  8009c8:	89 1f                	mov    %ebx,(%edi)
}
  8009ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    
        if (f->f_indirect == 0) {
  8009d2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	75 65                	jne    800a41 <file_block_walk+0xe7>
            if (!alloc) {
  8009dc:	89 f8                	mov    %edi,%eax
  8009de:	84 c0                	test   %al,%al
  8009e0:	0f 84 98 00 00 00    	je     800a7e <file_block_walk+0x124>
            if ((r = alloc_block()) < 0)
  8009e6:	e8 b9 fe ff ff       	call   8008a4 <alloc_block>
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	78 db                	js     8009ca <file_block_walk+0x70>
            f->f_indirect = r;
  8009ef:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
            flush_block(f);
  8009f5:	83 ec 0c             	sub    $0xc,%esp
  8009f8:	56                   	push   %esi
  8009f9:	e8 26 fa ff ff       	call   800424 <flush_block>
        indr_addr = (uint32_t *)diskaddr(f->f_indirect);
  8009fe:	83 c4 04             	add    $0x4,%esp
  800a01:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800a07:	e8 9a f9 ff ff       	call   8003a6 <diskaddr>
        if (*(indr_addr + filebno) == 0) {
  800a0c:	8d 5c 98 d8          	lea    -0x28(%eax,%ebx,4),%ebx
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	83 3b 00             	cmpl   $0x0,(%ebx)
  800a16:	75 a4                	jne    8009bc <file_block_walk+0x62>
            if ((r = alloc_block()) < 0)
  800a18:	e8 87 fe ff ff       	call   8008a4 <alloc_block>
  800a1d:	85 c0                	test   %eax,%eax
  800a1f:	78 a9                	js     8009ca <file_block_walk+0x70>
            *(indr_addr + filebno) = r;
  800a21:	89 03                	mov    %eax,(%ebx)
            flush_block(diskaddr(f->f_indirect));
  800a23:	83 ec 0c             	sub    $0xc,%esp
  800a26:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800a2c:	e8 75 f9 ff ff       	call   8003a6 <diskaddr>
  800a31:	89 04 24             	mov    %eax,(%esp)
  800a34:	e8 eb f9 ff ff       	call   800424 <flush_block>
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	e9 7b ff ff ff       	jmp    8009bc <file_block_walk+0x62>
        indr_addr = (uint32_t *)diskaddr(f->f_indirect);
  800a41:	83 ec 0c             	sub    $0xc,%esp
  800a44:	50                   	push   %eax
  800a45:	e8 5c f9 ff ff       	call   8003a6 <diskaddr>
        if (*(indr_addr + filebno) == 0) {
  800a4a:	8d 5c 98 d8          	lea    -0x28(%eax,%ebx,4),%ebx
  800a4e:	83 c4 10             	add    $0x10,%esp
  800a51:	83 3b 00             	cmpl   $0x0,(%ebx)
  800a54:	0f 85 62 ff ff ff    	jne    8009bc <file_block_walk+0x62>
            if (!alloc)
  800a5a:	89 f8                	mov    %edi,%eax
  800a5c:	84 c0                	test   %al,%al
  800a5e:	75 b8                	jne    800a18 <file_block_walk+0xbe>
                return -E_NOT_FOUND;
  800a60:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a65:	e9 60 ff ff ff       	jmp    8009ca <file_block_walk+0x70>
        return -E_INVAL;
  800a6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a6f:	e9 56 ff ff ff       	jmp    8009ca <file_block_walk+0x70>
                return -E_NOT_FOUND;
  800a74:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a79:	e9 4c ff ff ff       	jmp    8009ca <file_block_walk+0x70>
                return -E_NOT_FOUND;
  800a7e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a83:	e9 42 ff ff ff       	jmp    8009ca <file_block_walk+0x70>

00800a88 <check_bitmap>:
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a8d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800a92:	8b 70 04             	mov    0x4(%eax),%esi
  800a95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	c1 e0 0f             	shl    $0xf,%eax
  800a9f:	39 c6                	cmp    %eax,%esi
  800aa1:	76 2b                	jbe    800ace <check_bitmap+0x46>
		assert(!block_is_free(2+i));
  800aa3:	8d 43 02             	lea    0x2(%ebx),%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 86 fd ff ff       	call   800832 <block_is_free>
  800aac:	83 c4 04             	add    $0x4,%esp
  800aaf:	84 c0                	test   %al,%al
  800ab1:	75 05                	jne    800ab8 <check_bitmap+0x30>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800ab3:	83 c3 01             	add    $0x1,%ebx
  800ab6:	eb e2                	jmp    800a9a <check_bitmap+0x12>
		assert(!block_is_free(2+i));
  800ab8:	68 5e 3c 80 00       	push   $0x803c5e
  800abd:	68 fd 39 80 00       	push   $0x8039fd
  800ac2:	6a 61                	push   $0x61
  800ac4:	68 0e 3c 80 00       	push   $0x803c0e
  800ac9:	e8 21 11 00 00       	call   801bef <_panic>
	assert(!block_is_free(0));
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	6a 00                	push   $0x0
  800ad3:	e8 5a fd ff ff       	call   800832 <block_is_free>
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	84 c0                	test   %al,%al
  800add:	75 28                	jne    800b07 <check_bitmap+0x7f>
	assert(!block_is_free(1));
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	6a 01                	push   $0x1
  800ae4:	e8 49 fd ff ff       	call   800832 <block_is_free>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	84 c0                	test   %al,%al
  800aee:	75 2d                	jne    800b1d <check_bitmap+0x95>
	cprintf("bitmap is good\n");
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	68 96 3c 80 00       	push   $0x803c96
  800af8:	e8 cd 11 00 00       	call   801cca <cprintf>
}
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
	assert(!block_is_free(0));
  800b07:	68 72 3c 80 00       	push   $0x803c72
  800b0c:	68 fd 39 80 00       	push   $0x8039fd
  800b11:	6a 64                	push   $0x64
  800b13:	68 0e 3c 80 00       	push   $0x803c0e
  800b18:	e8 d2 10 00 00       	call   801bef <_panic>
	assert(!block_is_free(1));
  800b1d:	68 84 3c 80 00       	push   $0x803c84
  800b22:	68 fd 39 80 00       	push   $0x8039fd
  800b27:	6a 65                	push   $0x65
  800b29:	68 0e 3c 80 00       	push   $0x803c0e
  800b2e:	e8 bc 10 00 00       	call   801bef <_panic>

00800b33 <fs_init>:
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800b39:	e8 21 f5 ff ff       	call   80005f <ide_probe_disk1>
  800b3e:	84 c0                	test   %al,%al
  800b40:	75 41                	jne    800b83 <fs_init+0x50>
		ide_set_disk(0);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	6a 00                	push   $0x0
  800b47:	e8 75 f5 ff ff       	call   8000c1 <ide_set_disk>
  800b4c:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800b4f:	e8 92 f9 ff ff       	call   8004e6 <bc_init>
	super = diskaddr(1);
  800b54:	83 ec 0c             	sub    $0xc,%esp
  800b57:	6a 01                	push   $0x1
  800b59:	e8 48 f8 ff ff       	call   8003a6 <diskaddr>
  800b5e:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800b63:	e8 74 fc ff ff       	call   8007dc <check_super>
	bitmap = diskaddr(2);
  800b68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b6f:	e8 32 f8 ff ff       	call   8003a6 <diskaddr>
  800b74:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800b79:	e8 0a ff ff ff       	call   800a88 <check_bitmap>
}
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    
		ide_set_disk(1);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	6a 01                	push   $0x1
  800b88:	e8 34 f5 ff ff       	call   8000c1 <ide_set_disk>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	eb bd                	jmp    800b4f <fs_init+0x1c>

00800b92 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	83 ec 24             	sub    $0x24,%esp
       // LAB 5: Your code here.
	int r;
	uint32_t *ptr;
    if ((r = file_block_walk(f, filebno, &ptr, 1)) < 0)
  800b98:	6a 01                	push   $0x1
  800b9a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	e8 b2 fd ff ff       	call   80095a <file_block_walk>
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	85 c0                	test   %eax,%eax
  800bad:	78 0e                	js     800bbd <file_get_block+0x2b>
		return r;
    if (*ptr) {
  800baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bb2:	8b 10                	mov    (%eax),%edx
        *blk = diskaddr(*ptr);
    }
    return 0;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
    if (*ptr) {
  800bb9:	85 d2                	test   %edx,%edx
  800bbb:	75 02                	jne    800bbf <file_get_block+0x2d>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    
        *blk = diskaddr(*ptr);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	52                   	push   %edx
  800bc3:	e8 de f7 ff ff       	call   8003a6 <diskaddr>
  800bc8:	8b 55 10             	mov    0x10(%ebp),%edx
  800bcb:	89 02                	mov    %eax,(%edx)
  800bcd:	83 c4 10             	add    $0x10,%esp
    return 0;
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	eb e6                	jmp    800bbd <file_get_block+0x2b>

00800bd7 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800be3:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800be9:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800bef:	eb 03                	jmp    800bf4 <walk_path+0x1d>
		p++;
  800bf1:	83 c0 01             	add    $0x1,%eax
	while (*p == '/')
  800bf4:	80 38 2f             	cmpb   $0x2f,(%eax)
  800bf7:	74 f8                	je     800bf1 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800bf9:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800bff:	83 c1 08             	add    $0x8,%ecx
  800c02:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800c08:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800c0f:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800c15:	85 c9                	test   %ecx,%ecx
  800c17:	74 06                	je     800c1f <walk_path+0x48>
		*pdir = 0;
  800c19:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800c1f:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800c25:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	dir = 0;
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800c30:	e9 b4 01 00 00       	jmp    800de9 <walk_path+0x212>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800c35:	83 c7 01             	add    $0x1,%edi
		while (*path != '/' && *path != '\0')
  800c38:	0f b6 17             	movzbl (%edi),%edx
  800c3b:	80 fa 2f             	cmp    $0x2f,%dl
  800c3e:	74 04                	je     800c44 <walk_path+0x6d>
  800c40:	84 d2                	test   %dl,%dl
  800c42:	75 f1                	jne    800c35 <walk_path+0x5e>
		if (path - p >= MAXNAMELEN)
  800c44:	89 fb                	mov    %edi,%ebx
  800c46:	29 c3                	sub    %eax,%ebx
  800c48:	83 fb 7f             	cmp    $0x7f,%ebx
  800c4b:	0f 8f 70 01 00 00    	jg     800dc1 <walk_path+0x1ea>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c51:	83 ec 04             	sub    $0x4,%esp
  800c54:	53                   	push   %ebx
  800c55:	50                   	push   %eax
  800c56:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c5c:	50                   	push   %eax
  800c5d:	e8 15 18 00 00       	call   802477 <memmove>
		name[path - p] = '\0';
  800c62:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c69:	00 
  800c6a:	83 c4 10             	add    $0x10,%esp
  800c6d:	eb 03                	jmp    800c72 <walk_path+0x9b>
		p++;
  800c6f:	83 c7 01             	add    $0x1,%edi
	while (*p == '/')
  800c72:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800c75:	74 f8                	je     800c6f <walk_path+0x98>
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800c77:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c7d:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c84:	0f 85 3e 01 00 00    	jne    800dc8 <walk_path+0x1f1>
	assert((dir->f_size % BLKSIZE) == 0);
  800c8a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800c90:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800c95:	0f 85 98 00 00 00    	jne    800d33 <walk_path+0x15c>
	nblock = dir->f_size / BLKSIZE;
  800c9b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	0f 48 c2             	cmovs  %edx,%eax
  800ca6:	c1 f8 0c             	sar    $0xc,%eax
  800ca9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800caf:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800cb6:	00 00 00 
			if (strcmp(f[j].f_name, name) == 0) {
  800cb9:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  800cbf:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800cc5:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800ccb:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800cd1:	74 79                	je     800d4c <walk_path+0x175>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800cd3:	83 ec 04             	sub    $0x4,%esp
  800cd6:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800cdc:	50                   	push   %eax
  800cdd:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800ce3:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ce9:	e8 a4 fe ff ff       	call   800b92 <file_get_block>
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	0f 88 fc 00 00 00    	js     800df5 <walk_path+0x21e>
  800cf9:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800cff:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800d05:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	e8 7a 16 00 00       	call   80238f <strcmp>
  800d15:	83 c4 10             	add    $0x10,%esp
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	0f 84 af 00 00 00    	je     800dcf <walk_path+0x1f8>
  800d20:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800d26:	39 fb                	cmp    %edi,%ebx
  800d28:	75 db                	jne    800d05 <walk_path+0x12e>
	for (i = 0; i < nblock; i++) {
  800d2a:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800d31:	eb 92                	jmp    800cc5 <walk_path+0xee>
	assert((dir->f_size % BLKSIZE) == 0);
  800d33:	68 a6 3c 80 00       	push   $0x803ca6
  800d38:	68 fd 39 80 00       	push   $0x8039fd
  800d3d:	68 f0 00 00 00       	push   $0xf0
  800d42:	68 0e 3c 80 00       	push   $0x803c0e
  800d47:	e8 a3 0e 00 00       	call   801bef <_panic>
  800d4c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800d52:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d57:	80 3f 00             	cmpb   $0x0,(%edi)
  800d5a:	0f 85 a4 00 00 00    	jne    800e04 <walk_path+0x22d>
				if (pdir)
  800d60:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d66:	85 c0                	test   %eax,%eax
  800d68:	74 08                	je     800d72 <walk_path+0x19b>
					*pdir = dir;
  800d6a:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d70:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800d72:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d76:	74 15                	je     800d8d <walk_path+0x1b6>
					strcpy(lastelem, name);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800d81:	50                   	push   %eax
  800d82:	ff 75 08             	pushl  0x8(%ebp)
  800d85:	e8 5f 15 00 00       	call   8022e9 <strcpy>
  800d8a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800d8d:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800d93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return r;
  800d99:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d9e:	eb 64                	jmp    800e04 <walk_path+0x22d>
		}
	}

	if (pdir)
  800da0:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800da6:	85 c0                	test   %eax,%eax
  800da8:	74 02                	je     800dac <walk_path+0x1d5>
		*pdir = dir;
  800daa:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800dac:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800db2:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800db8:	89 08                	mov    %ecx,(%eax)
	return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbf:	eb 43                	jmp    800e04 <walk_path+0x22d>
			return -E_BAD_PATH;
  800dc1:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800dc6:	eb 3c                	jmp    800e04 <walk_path+0x22d>
			return -E_NOT_FOUND;
  800dc8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800dcd:	eb 35                	jmp    800e04 <walk_path+0x22d>
  800dcf:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800dd5:	89 f8                	mov    %edi,%eax
  800dd7:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
			if (strcmp(f[j].f_name, name) == 0) {
  800ddd:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800de3:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	while (*path != '\0') {
  800de9:	80 38 00             	cmpb   $0x0,(%eax)
  800dec:	74 b2                	je     800da0 <walk_path+0x1c9>
  800dee:	89 c7                	mov    %eax,%edi
  800df0:	e9 43 fe ff ff       	jmp    800c38 <walk_path+0x61>
  800df5:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
			if (r == -E_NOT_FOUND && *path == '\0') {
  800dfb:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800dfe:	0f 84 4e ff ff ff    	je     800d52 <walk_path+0x17b>
}
  800e04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800e12:	6a 00                	push   $0x0
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	e8 b3 fd ff ff       	call   800bd7 <walk_path>
}
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 2c             	sub    $0x2c,%esp
  800e2f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e32:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  800e43:	39 ca                	cmp    %ecx,%edx
  800e45:	0f 8e 80 00 00 00    	jle    800ecb <file_read+0xa5>

	count = MIN(count, f->f_size - offset);
  800e4b:	29 ca                	sub    %ecx,%edx
  800e4d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e50:	89 d0                	mov    %edx,%eax
  800e52:	0f 47 45 10          	cmova  0x10(%ebp),%eax
  800e56:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800e59:	89 ce                	mov    %ecx,%esi
  800e5b:	01 c1                	add    %eax,%ecx
  800e5d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800e60:	89 f3                	mov    %esi,%ebx
  800e62:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e65:	76 61                	jbe    800ec8 <file_read+0xa2>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e6d:	50                   	push   %eax
  800e6e:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e74:	85 f6                	test   %esi,%esi
  800e76:	0f 49 c6             	cmovns %esi,%eax
  800e79:	c1 f8 0c             	sar    $0xc,%eax
  800e7c:	50                   	push   %eax
  800e7d:	ff 75 08             	pushl  0x8(%ebp)
  800e80:	e8 0d fd ff ff       	call   800b92 <file_get_block>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 3f                	js     800ecb <file_read+0xa5>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e8c:	89 f2                	mov    %esi,%edx
  800e8e:	c1 fa 1f             	sar    $0x1f,%edx
  800e91:	c1 ea 14             	shr    $0x14,%edx
  800e94:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e97:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e9c:	29 d0                	sub    %edx,%eax
  800e9e:	ba 00 10 00 00       	mov    $0x1000,%edx
  800ea3:	29 c2                	sub    %eax,%edx
  800ea5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ea8:	29 d9                	sub    %ebx,%ecx
  800eaa:	89 cb                	mov    %ecx,%ebx
  800eac:	39 ca                	cmp    %ecx,%edx
  800eae:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800eb1:	83 ec 04             	sub    $0x4,%esp
  800eb4:	53                   	push   %ebx
  800eb5:	03 45 e4             	add    -0x1c(%ebp),%eax
  800eb8:	50                   	push   %eax
  800eb9:	57                   	push   %edi
  800eba:	e8 b8 15 00 00       	call   802477 <memmove>
		pos += bn;
  800ebf:	01 de                	add    %ebx,%esi
		buf += bn;
  800ec1:	01 df                	add    %ebx,%edi
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	eb 98                	jmp    800e60 <file_read+0x3a>
	}

	return count;
  800ec8:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 2c             	sub    $0x2c,%esp
  800edc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800edf:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800ee5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800ee8:	7f 1f                	jg     800f09 <file_set_size+0x36>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	56                   	push   %esi
  800ef7:	e8 28 f5 ff ff       	call   800424 <flush_block>
	return 0;
}
  800efc:	b8 00 00 00 00       	mov    $0x0,%eax
  800f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800f09:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800f0f:	05 ff 0f 00 00       	add    $0xfff,%eax
  800f14:	0f 49 f8             	cmovns %eax,%edi
  800f17:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800f2b:	0f 49 c2             	cmovns %edx,%eax
  800f2e:	c1 f8 0c             	sar    $0xc,%eax
  800f31:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	eb 3c                	jmp    800f74 <file_set_size+0xa1>
	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800f38:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800f3c:	77 ac                	ja     800eea <file_set_size+0x17>
  800f3e:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 a2                	je     800eea <file_set_size+0x17>
		free_block(f->f_indirect);
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	50                   	push   %eax
  800f4c:	e8 17 f9 ff ff       	call   800868 <free_block>
		f->f_indirect = 0;
  800f51:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800f58:	00 00 00 
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	eb 8a                	jmp    800eea <file_set_size+0x17>
			cprintf("warning: file_free_block: %e", r);
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	50                   	push   %eax
  800f64:	68 c3 3c 80 00       	push   $0x803cc3
  800f69:	e8 5c 0d 00 00       	call   801cca <cprintf>
  800f6e:	83 c4 10             	add    $0x10,%esp
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f71:	83 c3 01             	add    $0x1,%ebx
  800f74:	39 df                	cmp    %ebx,%edi
  800f76:	76 c0                	jbe    800f38 <file_set_size+0x65>
	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	6a 00                	push   $0x0
  800f7d:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800f80:	89 da                	mov    %ebx,%edx
  800f82:	89 f0                	mov    %esi,%eax
  800f84:	e8 d1 f9 ff ff       	call   80095a <file_block_walk>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 d0                	js     800f60 <file_set_size+0x8d>
	if (*ptr) {
  800f90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f93:	8b 00                	mov    (%eax),%eax
  800f95:	85 c0                	test   %eax,%eax
  800f97:	74 d8                	je     800f71 <file_set_size+0x9e>
		free_block(*ptr);
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	50                   	push   %eax
  800f9d:	e8 c6 f8 ff ff       	call   800868 <free_block>
		*ptr = 0;
  800fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	eb c1                	jmp    800f71 <file_set_size+0x9e>

00800fb0 <file_write>:
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	57                   	push   %edi
  800fb4:	56                   	push   %esi
  800fb5:	53                   	push   %ebx
  800fb6:	83 ec 2c             	sub    $0x2c,%esp
  800fb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fbc:	8b 75 14             	mov    0x14(%ebp),%esi
	if (offset + count > f->f_size)
  800fbf:	89 f0                	mov    %esi,%eax
  800fc1:	03 45 10             	add    0x10(%ebp),%eax
  800fc4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fca:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800fd0:	77 68                	ja     80103a <file_write+0x8a>
	for (pos = offset; pos < offset + count; ) {
  800fd2:	89 f3                	mov    %esi,%ebx
  800fd4:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800fd7:	76 74                	jbe    80104d <file_write+0x9d>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800fd9:	83 ec 04             	sub    $0x4,%esp
  800fdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800fe6:	85 f6                	test   %esi,%esi
  800fe8:	0f 49 c6             	cmovns %esi,%eax
  800feb:	c1 f8 0c             	sar    $0xc,%eax
  800fee:	50                   	push   %eax
  800fef:	ff 75 08             	pushl  0x8(%ebp)
  800ff2:	e8 9b fb ff ff       	call   800b92 <file_get_block>
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 52                	js     801050 <file_write+0xa0>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ffe:	89 f2                	mov    %esi,%edx
  801000:	c1 fa 1f             	sar    $0x1f,%edx
  801003:	c1 ea 14             	shr    $0x14,%edx
  801006:	8d 04 16             	lea    (%esi,%edx,1),%eax
  801009:	25 ff 0f 00 00       	and    $0xfff,%eax
  80100e:	29 d0                	sub    %edx,%eax
  801010:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801015:	29 c1                	sub    %eax,%ecx
  801017:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80101a:	29 da                	sub    %ebx,%edx
  80101c:	39 d1                	cmp    %edx,%ecx
  80101e:	89 d3                	mov    %edx,%ebx
  801020:	0f 46 d9             	cmovbe %ecx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	53                   	push   %ebx
  801027:	57                   	push   %edi
  801028:	03 45 e4             	add    -0x1c(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	e8 46 14 00 00       	call   802477 <memmove>
		pos += bn;
  801031:	01 de                	add    %ebx,%esi
		buf += bn;
  801033:	01 df                	add    %ebx,%edi
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	eb 98                	jmp    800fd2 <file_write+0x22>
		if ((r = file_set_size(f, offset + count)) < 0)
  80103a:	83 ec 08             	sub    $0x8,%esp
  80103d:	50                   	push   %eax
  80103e:	51                   	push   %ecx
  80103f:	e8 8f fe ff ff       	call   800ed3 <file_set_size>
  801044:	83 c4 10             	add    $0x10,%esp
  801047:	85 c0                	test   %eax,%eax
  801049:	79 87                	jns    800fd2 <file_write+0x22>
  80104b:	eb 03                	jmp    801050 <file_write+0xa0>
	return count;
  80104d:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 10             	sub    $0x10,%esp
  801060:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801063:	bb 00 00 00 00       	mov    $0x0,%ebx
  801068:	eb 03                	jmp    80106d <file_flush+0x15>
  80106a:	83 c3 01             	add    $0x1,%ebx
  80106d:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  801073:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  801079:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80107f:	85 c9                	test   %ecx,%ecx
  801081:	0f 49 c1             	cmovns %ecx,%eax
  801084:	c1 f8 0c             	sar    $0xc,%eax
  801087:	39 d8                	cmp    %ebx,%eax
  801089:	7e 3b                	jle    8010c6 <file_flush+0x6e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	6a 00                	push   $0x0
  801090:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801093:	89 da                	mov    %ebx,%edx
  801095:	89 f0                	mov    %esi,%eax
  801097:	e8 be f8 ff ff       	call   80095a <file_block_walk>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 c7                	js     80106a <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  8010a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	74 c0                	je     80106a <file_flush+0x12>
		    pdiskbno == NULL || *pdiskbno == 0)
  8010aa:	8b 00                	mov    (%eax),%eax
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	74 ba                	je     80106a <file_flush+0x12>
			continue;
		flush_block(diskaddr(*pdiskbno));
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	50                   	push   %eax
  8010b4:	e8 ed f2 ff ff       	call   8003a6 <diskaddr>
  8010b9:	89 04 24             	mov    %eax,(%esp)
  8010bc:	e8 63 f3 ff ff       	call   800424 <flush_block>
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	eb a4                	jmp    80106a <file_flush+0x12>
	}
	flush_block(f);
  8010c6:	83 ec 0c             	sub    $0xc,%esp
  8010c9:	56                   	push   %esi
  8010ca:	e8 55 f3 ff ff       	call   800424 <flush_block>
	if (f->f_indirect)
  8010cf:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	75 07                	jne    8010e3 <file_flush+0x8b>
		flush_block(diskaddr(f->f_indirect));
}
  8010dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	50                   	push   %eax
  8010e7:	e8 ba f2 ff ff       	call   8003a6 <diskaddr>
  8010ec:	89 04 24             	mov    %eax,(%esp)
  8010ef:	e8 30 f3 ff ff       	call   800424 <flush_block>
  8010f4:	83 c4 10             	add    $0x10,%esp
}
  8010f7:	eb e3                	jmp    8010dc <file_flush+0x84>

008010f9 <file_create>:
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801105:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801112:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801118:	8b 45 08             	mov    0x8(%ebp),%eax
  80111b:	e8 b7 fa ff ff       	call   800bd7 <walk_path>
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	0f 84 0e 01 00 00    	je     801239 <file_create+0x140>
	if (r != -E_NOT_FOUND || dir == 0)
  80112b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80112e:	74 08                	je     801138 <file_create+0x3f>
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
  801138:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  80113e:	85 db                	test   %ebx,%ebx
  801140:	74 ee                	je     801130 <file_create+0x37>
	assert((dir->f_size % BLKSIZE) == 0);
  801142:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801148:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80114d:	75 5c                	jne    8011ab <file_create+0xb2>
	nblock = dir->f_size / BLKSIZE;
  80114f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801155:	85 c0                	test   %eax,%eax
  801157:	0f 48 c2             	cmovs  %edx,%eax
  80115a:	c1 f8 0c             	sar    $0xc,%eax
  80115d:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801163:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801168:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  80116e:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  801174:	0f 84 8b 00 00 00    	je     801205 <file_create+0x10c>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	e8 0d fa ff ff       	call   800b92 <file_get_block>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 a4                	js     801130 <file_create+0x37>
  80118c:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801192:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
			if (f[j].f_name[0] == '\0') {
  801198:	80 38 00             	cmpb   $0x0,(%eax)
  80119b:	74 27                	je     8011c4 <file_create+0xcb>
  80119d:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  8011a2:	39 c8                	cmp    %ecx,%eax
  8011a4:	75 f2                	jne    801198 <file_create+0x9f>
	for (i = 0; i < nblock; i++) {
  8011a6:	83 c6 01             	add    $0x1,%esi
  8011a9:	eb c3                	jmp    80116e <file_create+0x75>
	assert((dir->f_size % BLKSIZE) == 0);
  8011ab:	68 a6 3c 80 00       	push   $0x803ca6
  8011b0:	68 fd 39 80 00       	push   $0x8039fd
  8011b5:	68 09 01 00 00       	push   $0x109
  8011ba:	68 0e 3c 80 00       	push   $0x803c0e
  8011bf:	e8 2b 0a 00 00       	call   801bef <_panic>
				*file = &f[j];
  8011c4:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
	strcpy(f->f_name, name);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  8011da:	e8 0a 11 00 00       	call   8022e9 <strcpy>
	*pf = f;
  8011df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e2:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8011e8:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8011ea:	83 c4 04             	add    $0x4,%esp
  8011ed:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  8011f3:	e8 60 fe ff ff       	call   801058 <file_flush>
	return 0;
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801200:	e9 2b ff ff ff       	jmp    801130 <file_create+0x37>
	dir->f_size += BLKSIZE;
  801205:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  80120c:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	e8 72 f9 ff ff       	call   800b92 <file_get_block>
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	0f 88 05 ff ff ff    	js     801130 <file_create+0x37>
	*file = &f[0];
  80122b:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801231:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801237:	eb 91                	jmp    8011ca <file_create+0xd1>
		return -E_FILE_EXISTS;
  801239:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80123e:	e9 ed fe ff ff       	jmp    801130 <file_create+0x37>

00801243 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80124a:	bb 01 00 00 00       	mov    $0x1,%ebx
  80124f:	eb 17                	jmp    801268 <fs_sync+0x25>
		flush_block(diskaddr(i));
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	53                   	push   %ebx
  801255:	e8 4c f1 ff ff       	call   8003a6 <diskaddr>
  80125a:	89 04 24             	mov    %eax,(%esp)
  80125d:	e8 c2 f1 ff ff       	call   800424 <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  801262:	83 c3 01             	add    $0x1,%ebx
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80126d:	39 58 04             	cmp    %ebx,0x4(%eax)
  801270:	77 df                	ja     801251 <fs_sync+0xe>
}
  801272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801275:	c9                   	leave  
  801276:	c3                   	ret    

00801277 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80127d:	e8 c1 ff ff ff       	call   801243 <fs_sync>
	return 0;
}
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <serve_init>:
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  801291:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801296:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  80129b:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80129d:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8012a0:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8012a6:	83 c0 01             	add    $0x1,%eax
  8012a9:	83 c2 10             	add    $0x10,%edx
  8012ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012b1:	75 e8                	jne    80129b <serve_init+0x12>
}
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    

008012b5 <openfile_alloc>:
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	57                   	push   %edi
  8012b9:	56                   	push   %esi
  8012ba:	53                   	push   %ebx
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c6:	89 de                	mov    %ebx,%esi
  8012c8:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  8012d4:	e8 89 1f 00 00       	call   803262 <pageref>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	74 17                	je     8012f7 <openfile_alloc+0x42>
  8012e0:	83 f8 01             	cmp    $0x1,%eax
  8012e3:	74 30                	je     801315 <openfile_alloc+0x60>
	for (i = 0; i < MAXOPEN; i++) {
  8012e5:	83 c3 01             	add    $0x1,%ebx
  8012e8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012ee:	75 d6                	jne    8012c6 <openfile_alloc+0x11>
	return -E_MAX_OPEN;
  8012f0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012f5:	eb 4f                	jmp    801346 <openfile_alloc+0x91>
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	6a 07                	push   $0x7
  8012fc:	89 d8                	mov    %ebx,%eax
  8012fe:	c1 e0 04             	shl    $0x4,%eax
  801301:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801307:	6a 00                	push   $0x0
  801309:	e8 d4 13 00 00       	call   8026e2 <sys_page_alloc>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 31                	js     801346 <openfile_alloc+0x91>
			opentab[i].o_fileid += MAXOPEN;
  801315:	c1 e3 04             	shl    $0x4,%ebx
  801318:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80131f:	04 00 00 
			*o = &opentab[i];
  801322:	81 c6 60 50 80 00    	add    $0x805060,%esi
  801328:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80132a:	83 ec 04             	sub    $0x4,%esp
  80132d:	68 00 10 00 00       	push   $0x1000
  801332:	6a 00                	push   $0x0
  801334:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80133a:	e8 eb 10 00 00       	call   80242a <memset>
			return (*o)->o_fileid;
  80133f:	8b 07                	mov    (%edi),%eax
  801341:	8b 00                	mov    (%eax),%eax
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5f                   	pop    %edi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <openfile_lookup>:
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	57                   	push   %edi
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
  801354:	83 ec 18             	sub    $0x18,%esp
  801357:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  80135a:	89 fb                	mov    %edi,%ebx
  80135c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801362:	89 de                	mov    %ebx,%esi
  801364:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801367:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  80136d:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801373:	e8 ea 1e 00 00       	call   803262 <pageref>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	83 f8 01             	cmp    $0x1,%eax
  80137e:	7e 1d                	jle    80139d <openfile_lookup+0x4f>
  801380:	c1 e3 04             	shl    $0x4,%ebx
  801383:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  801389:	75 19                	jne    8013a4 <openfile_lookup+0x56>
	*po = o;
  80138b:	8b 45 10             	mov    0x10(%ebp),%eax
  80138e:	89 30                	mov    %esi,(%eax)
	return 0;
  801390:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
		return -E_INVAL;
  80139d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a2:	eb f1                	jmp    801395 <openfile_lookup+0x47>
  8013a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a9:	eb ea                	jmp    801395 <openfile_lookup+0x47>

008013ab <serve_set_size>:
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 18             	sub    $0x18,%esp
  8013b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	ff 33                	pushl  (%ebx)
  8013bb:	ff 75 08             	pushl  0x8(%ebp)
  8013be:	e8 8b ff ff ff       	call   80134e <openfile_lookup>
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 14                	js     8013de <serve_set_size+0x33>
	return file_set_size(o->o_file, req->req_size);
  8013ca:	83 ec 08             	sub    $0x8,%esp
  8013cd:	ff 73 04             	pushl  0x4(%ebx)
  8013d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d3:	ff 70 04             	pushl  0x4(%eax)
  8013d6:	e8 f8 fa ff ff       	call   800ed3 <file_set_size>
  8013db:	83 c4 10             	add    $0x10,%esp
}
  8013de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <serve_read>:
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 18             	sub    $0x18,%esp
  8013ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	ff 33                	pushl  (%ebx)
  8013f3:	ff 75 08             	pushl  0x8(%ebp)
  8013f6:	e8 53 ff ff ff       	call   80134e <openfile_lookup>
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 25                	js     801427 <serve_read+0x44>
    if ((r = file_read(o->o_file, ret, req->req_n, o->o_fd->fd_offset)) > 0)
  801402:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801405:	8b 50 0c             	mov    0xc(%eax),%edx
  801408:	ff 72 04             	pushl  0x4(%edx)
  80140b:	ff 73 04             	pushl  0x4(%ebx)
  80140e:	53                   	push   %ebx
  80140f:	ff 70 04             	pushl  0x4(%eax)
  801412:	e8 0f fa ff ff       	call   800e26 <file_read>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	7e 09                	jle    801427 <serve_read+0x44>
        o->o_fd->fd_offset += r;
  80141e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801421:	8b 52 0c             	mov    0xc(%edx),%edx
  801424:	01 42 04             	add    %eax,0x4(%edx)
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <serve_write>:
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	83 ec 14             	sub    $0x14,%esp
  801434:	8b 75 0c             	mov    0xc(%ebp),%esi
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801437:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	ff 36                	pushl  (%esi)
  80143d:	ff 75 08             	pushl  0x8(%ebp)
  801440:	e8 09 ff ff ff       	call   80134e <openfile_lookup>
  801445:	89 c3                	mov    %eax,%ebx
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 3b                	js     801489 <serve_write+0x5d>
    if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) > 0) {
  80144e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801451:	8b 50 0c             	mov    0xc(%eax),%edx
  801454:	ff 72 04             	pushl  0x4(%edx)
  801457:	ff 76 04             	pushl  0x4(%esi)
  80145a:	83 c6 08             	add    $0x8,%esi
  80145d:	56                   	push   %esi
  80145e:	ff 70 04             	pushl  0x4(%eax)
  801461:	e8 4a fb ff ff       	call   800fb0 <file_write>
  801466:	89 c3                	mov    %eax,%ebx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	7e 1a                	jle    801489 <serve_write+0x5d>
        file_flush(o->o_file);
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	ff 70 04             	pushl  0x4(%eax)
  801478:	e8 db fb ff ff       	call   801058 <file_flush>
        o->o_fd->fd_offset += r;
  80147d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801480:	8b 40 0c             	mov    0xc(%eax),%eax
  801483:	01 58 04             	add    %ebx,0x4(%eax)
  801486:	83 c4 10             	add    $0x10,%esp
}
  801489:	89 d8                	mov    %ebx,%eax
  80148b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    

00801492 <serve_stat>:
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	53                   	push   %ebx
  801496:	83 ec 18             	sub    $0x18,%esp
  801499:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	ff 33                	pushl  (%ebx)
  8014a2:	ff 75 08             	pushl  0x8(%ebp)
  8014a5:	e8 a4 fe ff ff       	call   80134e <openfile_lookup>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 3f                	js     8014f0 <serve_stat+0x5e>
	strcpy(ret->ret_name, o->o_file->f_name);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	ff 70 04             	pushl  0x4(%eax)
  8014ba:	53                   	push   %ebx
  8014bb:	e8 29 0e 00 00       	call   8022e9 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	8b 50 04             	mov    0x4(%eax),%edx
  8014c6:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8014cc:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8014d2:	8b 40 04             	mov    0x4(%eax),%eax
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8014df:	0f 94 c0             	sete   %al
  8014e2:	0f b6 c0             	movzbl %al,%eax
  8014e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <serve_flush>:
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	ff 30                	pushl  (%eax)
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 42 fe ff ff       	call   80134e <openfile_lookup>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 16                	js     801529 <serve_flush+0x34>
	file_flush(o->o_file);
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801519:	ff 70 04             	pushl  0x4(%eax)
  80151c:	e8 37 fb ff ff       	call   801058 <file_flush>
	return 0;
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <serve_open>:
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  801538:	68 00 04 00 00       	push   $0x400
  80153d:	53                   	push   %ebx
  80153e:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	e8 2d 0f 00 00       	call   802477 <memmove>
	path[MAXPATHLEN-1] = 0;
  80154a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  80154e:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	e8 59 fd ff ff       	call   8012b5 <openfile_alloc>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	0f 88 f0 00 00 00    	js     801657 <serve_open+0x12c>
	if (req->req_omode & O_CREAT) {
  801567:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80156e:	74 33                	je     8015a3 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	e8 73 fb ff ff       	call   8010f9 <file_create>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	79 37                	jns    8015c4 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80158d:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801594:	0f 85 bd 00 00 00    	jne    801657 <serve_open+0x12c>
  80159a:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80159d:	0f 85 b4 00 00 00    	jne    801657 <serve_open+0x12c>
		if ((r = file_open(path, &f)) < 0) {
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	e8 53 f8 ff ff       	call   800e0c <file_open>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	0f 88 93 00 00 00    	js     801657 <serve_open+0x12c>
	if (req->req_omode & O_TRUNC) {
  8015c4:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8015cb:	74 17                	je     8015e4 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	6a 00                	push   $0x0
  8015d2:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8015d8:	e8 f6 f8 ff ff       	call   800ed3 <file_set_size>
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 73                	js     801657 <serve_open+0x12c>
	if ((r = file_open(path, &f)) < 0) {
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	e8 12 f8 ff ff       	call   800e0c <file_open>
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 56                	js     801657 <serve_open+0x12c>
	o->o_file = f;
  801601:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801607:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80160d:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  801610:	8b 50 0c             	mov    0xc(%eax),%edx
  801613:	8b 08                	mov    (%eax),%ecx
  801615:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801618:	8b 48 0c             	mov    0xc(%eax),%ecx
  80161b:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801621:	83 e2 03             	and    $0x3,%edx
  801624:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801627:	8b 40 0c             	mov    0xc(%eax),%eax
  80162a:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801630:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801632:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801638:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80163e:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  801641:	8b 50 0c             	mov    0xc(%eax),%edx
  801644:	8b 45 10             	mov    0x10(%ebp),%eax
  801647:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801649:	8b 45 14             	mov    0x14(%ebp),%eax
  80164c:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  801652:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801664:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801667:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80166a:	eb 68                	jmp    8016d4 <serve+0x78>
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
			cprintf("Invalid request from %08x: no argument page\n",
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	ff 75 f4             	pushl  -0xc(%ebp)
  801672:	68 e0 3c 80 00       	push   $0x803ce0
  801677:	e8 4e 06 00 00       	call   801cca <cprintf>
				whom);
			continue; // just leave it hanging...
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb 53                	jmp    8016d4 <serve+0x78>
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801681:	53                   	push   %ebx
  801682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	ff 35 44 50 80 00    	pushl  0x805044
  80168c:	ff 75 f4             	pushl  -0xc(%ebp)
  80168f:	e8 97 fe ff ff       	call   80152b <serve_open>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	eb 19                	jmp    8016b2 <serve+0x56>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	ff 75 f4             	pushl  -0xc(%ebp)
  80169f:	50                   	push   %eax
  8016a0:	68 10 3d 80 00       	push   $0x803d10
  8016a5:	e8 20 06 00 00       	call   801cca <cprintf>
  8016aa:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8016ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8016b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b5:	ff 75 ec             	pushl  -0x14(%ebp)
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016bc:	e8 fc 12 00 00       	call   8029bd <ipc_send>
		sys_page_unmap(0, fsreq);
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	ff 35 44 50 80 00    	pushl  0x805044
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 96 10 00 00       	call   802767 <sys_page_unmap>
  8016d1:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  8016d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	53                   	push   %ebx
  8016df:	ff 35 44 50 80 00    	pushl  0x805044
  8016e5:	56                   	push   %esi
  8016e6:	e8 71 12 00 00       	call   80295c <ipc_recv>
		if (!(perm & PTE_P)) {
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8016f2:	0f 84 74 ff ff ff    	je     80166c <serve+0x10>
		pg = NULL;
  8016f8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8016ff:	83 f8 01             	cmp    $0x1,%eax
  801702:	0f 84 79 ff ff ff    	je     801681 <serve+0x25>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801708:	83 f8 08             	cmp    $0x8,%eax
  80170b:	77 8c                	ja     801699 <serve+0x3d>
  80170d:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801714:	85 d2                	test   %edx,%edx
  801716:	74 81                	je     801699 <serve+0x3d>
			r = handlers[req](whom, fsreq);
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	ff 35 44 50 80 00    	pushl  0x805044
  801721:	ff 75 f4             	pushl  -0xc(%ebp)
  801724:	ff d2                	call   *%edx
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	eb 87                	jmp    8016b2 <serve+0x56>

0080172b <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801731:	c7 05 60 90 80 00 33 	movl   $0x803d33,0x809060
  801738:	3d 80 00 
	cprintf("FS is running\n");
  80173b:	68 36 3d 80 00       	push   $0x803d36
  801740:	e8 85 05 00 00       	call   801cca <cprintf>
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801745:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80174a:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80174f:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801751:	c7 04 24 45 3d 80 00 	movl   $0x803d45,(%esp)
  801758:	e8 6d 05 00 00       	call   801cca <cprintf>

	serve_init();
  80175d:	e8 27 fb ff ff       	call   801289 <serve_init>
	fs_init();
  801762:	e8 cc f3 ff ff       	call   800b33 <fs_init>
        fs_test();
  801767:	e8 05 00 00 00       	call   801771 <fs_test>
	serve();
  80176c:	e8 eb fe ff ff       	call   80165c <serve>

00801771 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	53                   	push   %ebx
  801775:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801778:	6a 07                	push   $0x7
  80177a:	68 00 10 00 00       	push   $0x1000
  80177f:	6a 00                	push   $0x0
  801781:	e8 5c 0f 00 00       	call   8026e2 <sys_page_alloc>
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	0f 88 6a 02 00 00    	js     8019fb <fs_test+0x28a>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	68 00 10 00 00       	push   $0x1000
  801799:	ff 35 04 a0 80 00    	pushl  0x80a004
  80179f:	68 00 10 00 00       	push   $0x1000
  8017a4:	e8 ce 0c 00 00       	call   802477 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8017a9:	e8 f6 f0 ff ff       	call   8008a4 <alloc_block>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	0f 88 54 02 00 00    	js     801a0d <fs_test+0x29c>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8017b9:	8d 50 1f             	lea    0x1f(%eax),%edx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	0f 49 d0             	cmovns %eax,%edx
  8017c1:	c1 fa 05             	sar    $0x5,%edx
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	c1 fb 1f             	sar    $0x1f,%ebx
  8017c9:	c1 eb 1b             	shr    $0x1b,%ebx
  8017cc:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8017cf:	83 e1 1f             	and    $0x1f,%ecx
  8017d2:	29 d9                	sub    %ebx,%ecx
  8017d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d9:	d3 e0                	shl    %cl,%eax
  8017db:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8017e2:	0f 84 37 02 00 00    	je     801a1f <fs_test+0x2ae>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017e8:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8017ee:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8017f1:	0f 85 3e 02 00 00    	jne    801a35 <fs_test+0x2c4>
	cprintf("alloc_block is good\n");
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	68 9c 3d 80 00       	push   $0x803d9c
  8017ff:	e8 c6 04 00 00       	call   801cca <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801804:	83 c4 08             	add    $0x8,%esp
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	50                   	push   %eax
  80180b:	68 b1 3d 80 00       	push   $0x803db1
  801810:	e8 f7 f5 ff ff       	call   800e0c <file_open>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80181b:	74 08                	je     801825 <fs_test+0xb4>
  80181d:	85 c0                	test   %eax,%eax
  80181f:	0f 88 26 02 00 00    	js     801a4b <fs_test+0x2da>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 84 30 02 00 00    	je     801a5d <fs_test+0x2ec>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  80182d:	83 ec 08             	sub    $0x8,%esp
  801830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801833:	50                   	push   %eax
  801834:	68 d5 3d 80 00       	push   $0x803dd5
  801839:	e8 ce f5 ff ff       	call   800e0c <file_open>
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	0f 88 28 02 00 00    	js     801a71 <fs_test+0x300>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  801849:	83 ec 0c             	sub    $0xc,%esp
  80184c:	68 f5 3d 80 00       	push   $0x803df5
  801851:	e8 74 04 00 00       	call   801cca <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801856:	83 c4 0c             	add    $0xc,%esp
  801859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	6a 00                	push   $0x0
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 2b f3 ff ff       	call   800b92 <file_get_block>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	0f 88 11 02 00 00    	js     801a83 <fs_test+0x312>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	68 3c 3f 80 00       	push   $0x803f3c
  80187a:	ff 75 f0             	pushl  -0x10(%ebp)
  80187d:	e8 0d 0b 00 00       	call   80238f <strcmp>
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 85 08 02 00 00    	jne    801a95 <fs_test+0x324>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	68 1b 3e 80 00       	push   $0x803e1b
  801895:	e8 30 04 00 00       	call   801cca <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189d:	0f b6 10             	movzbl (%eax),%edx
  8018a0:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a5:	c1 e8 0c             	shr    $0xc,%eax
  8018a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	a8 40                	test   $0x40,%al
  8018b4:	0f 84 ef 01 00 00    	je     801aa9 <fs_test+0x338>
	file_flush(f);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 93 f7 ff ff       	call   801058 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c8:	c1 e8 0c             	shr    $0xc,%eax
  8018cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	a8 40                	test   $0x40,%al
  8018d7:	0f 85 e2 01 00 00    	jne    801abf <fs_test+0x34e>
	cprintf("file_flush is good\n");
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	68 4f 3e 80 00       	push   $0x803e4f
  8018e5:	e8 e0 03 00 00       	call   801cca <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f2:	e8 dc f5 ff ff       	call   800ed3 <file_set_size>
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	0f 88 d3 01 00 00    	js     801ad5 <fs_test+0x364>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  80190c:	0f 85 d5 01 00 00    	jne    801ae7 <fs_test+0x376>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801912:	c1 e8 0c             	shr    $0xc,%eax
  801915:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80191c:	a8 40                	test   $0x40,%al
  80191e:	0f 85 d9 01 00 00    	jne    801afd <fs_test+0x38c>
	cprintf("file_truncate is good\n");
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	68 a3 3e 80 00       	push   $0x803ea3
  80192c:	e8 99 03 00 00       	call   801cca <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801931:	c7 04 24 3c 3f 80 00 	movl   $0x803f3c,(%esp)
  801938:	e8 75 09 00 00       	call   8022b2 <strlen>
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	50                   	push   %eax
  801941:	ff 75 f4             	pushl  -0xc(%ebp)
  801944:	e8 8a f5 ff ff       	call   800ed3 <file_set_size>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	0f 88 bf 01 00 00    	js     801b13 <fs_test+0x3a2>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801954:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801957:	89 c2                	mov    %eax,%edx
  801959:	c1 ea 0c             	shr    $0xc,%edx
  80195c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801963:	f6 c2 40             	test   $0x40,%dl
  801966:	0f 85 b9 01 00 00    	jne    801b25 <fs_test+0x3b4>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801972:	52                   	push   %edx
  801973:	6a 00                	push   $0x0
  801975:	50                   	push   %eax
  801976:	e8 17 f2 ff ff       	call   800b92 <file_get_block>
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	85 c0                	test   %eax,%eax
  801980:	0f 88 b5 01 00 00    	js     801b3b <fs_test+0x3ca>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	68 3c 3f 80 00       	push   $0x803f3c
  80198e:	ff 75 f0             	pushl  -0x10(%ebp)
  801991:	e8 53 09 00 00       	call   8022e9 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801996:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801999:	c1 e8 0c             	shr    $0xc,%eax
  80199c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	a8 40                	test   $0x40,%al
  8019a8:	0f 84 9f 01 00 00    	je     801b4d <fs_test+0x3dc>
	file_flush(f);
  8019ae:	83 ec 0c             	sub    $0xc,%esp
  8019b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b4:	e8 9f f6 ff ff       	call   801058 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bc:	c1 e8 0c             	shr    $0xc,%eax
  8019bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	a8 40                	test   $0x40,%al
  8019cb:	0f 85 92 01 00 00    	jne    801b63 <fs_test+0x3f2>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	c1 e8 0c             	shr    $0xc,%eax
  8019d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019de:	a8 40                	test   $0x40,%al
  8019e0:	0f 85 93 01 00 00    	jne    801b79 <fs_test+0x408>
	cprintf("file rewrite is good\n");
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	68 e3 3e 80 00       	push   $0x803ee3
  8019ee:	e8 d7 02 00 00       	call   801cca <cprintf>
}
  8019f3:	83 c4 10             	add    $0x10,%esp
  8019f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f9:	c9                   	leave  
  8019fa:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8019fb:	50                   	push   %eax
  8019fc:	68 54 3d 80 00       	push   $0x803d54
  801a01:	6a 12                	push   $0x12
  801a03:	68 67 3d 80 00       	push   $0x803d67
  801a08:	e8 e2 01 00 00       	call   801bef <_panic>
		panic("alloc_block: %e", r);
  801a0d:	50                   	push   %eax
  801a0e:	68 71 3d 80 00       	push   $0x803d71
  801a13:	6a 17                	push   $0x17
  801a15:	68 67 3d 80 00       	push   $0x803d67
  801a1a:	e8 d0 01 00 00       	call   801bef <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801a1f:	68 81 3d 80 00       	push   $0x803d81
  801a24:	68 fd 39 80 00       	push   $0x8039fd
  801a29:	6a 19                	push   $0x19
  801a2b:	68 67 3d 80 00       	push   $0x803d67
  801a30:	e8 ba 01 00 00       	call   801bef <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801a35:	68 fc 3e 80 00       	push   $0x803efc
  801a3a:	68 fd 39 80 00       	push   $0x8039fd
  801a3f:	6a 1b                	push   $0x1b
  801a41:	68 67 3d 80 00       	push   $0x803d67
  801a46:	e8 a4 01 00 00       	call   801bef <_panic>
		panic("file_open /not-found: %e", r);
  801a4b:	50                   	push   %eax
  801a4c:	68 bc 3d 80 00       	push   $0x803dbc
  801a51:	6a 1f                	push   $0x1f
  801a53:	68 67 3d 80 00       	push   $0x803d67
  801a58:	e8 92 01 00 00       	call   801bef <_panic>
		panic("file_open /not-found succeeded!");
  801a5d:	83 ec 04             	sub    $0x4,%esp
  801a60:	68 1c 3f 80 00       	push   $0x803f1c
  801a65:	6a 21                	push   $0x21
  801a67:	68 67 3d 80 00       	push   $0x803d67
  801a6c:	e8 7e 01 00 00       	call   801bef <_panic>
		panic("file_open /newmotd: %e", r);
  801a71:	50                   	push   %eax
  801a72:	68 de 3d 80 00       	push   $0x803dde
  801a77:	6a 23                	push   $0x23
  801a79:	68 67 3d 80 00       	push   $0x803d67
  801a7e:	e8 6c 01 00 00       	call   801bef <_panic>
		panic("file_get_block: %e", r);
  801a83:	50                   	push   %eax
  801a84:	68 08 3e 80 00       	push   $0x803e08
  801a89:	6a 27                	push   $0x27
  801a8b:	68 67 3d 80 00       	push   $0x803d67
  801a90:	e8 5a 01 00 00       	call   801bef <_panic>
		panic("file_get_block returned wrong data");
  801a95:	83 ec 04             	sub    $0x4,%esp
  801a98:	68 64 3f 80 00       	push   $0x803f64
  801a9d:	6a 29                	push   $0x29
  801a9f:	68 67 3d 80 00       	push   $0x803d67
  801aa4:	e8 46 01 00 00       	call   801bef <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801aa9:	68 34 3e 80 00       	push   $0x803e34
  801aae:	68 fd 39 80 00       	push   $0x8039fd
  801ab3:	6a 2d                	push   $0x2d
  801ab5:	68 67 3d 80 00       	push   $0x803d67
  801aba:	e8 30 01 00 00       	call   801bef <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801abf:	68 33 3e 80 00       	push   $0x803e33
  801ac4:	68 fd 39 80 00       	push   $0x8039fd
  801ac9:	6a 2f                	push   $0x2f
  801acb:	68 67 3d 80 00       	push   $0x803d67
  801ad0:	e8 1a 01 00 00       	call   801bef <_panic>
		panic("file_set_size: %e", r);
  801ad5:	50                   	push   %eax
  801ad6:	68 63 3e 80 00       	push   $0x803e63
  801adb:	6a 33                	push   $0x33
  801add:	68 67 3d 80 00       	push   $0x803d67
  801ae2:	e8 08 01 00 00       	call   801bef <_panic>
	assert(f->f_direct[0] == 0);
  801ae7:	68 75 3e 80 00       	push   $0x803e75
  801aec:	68 fd 39 80 00       	push   $0x8039fd
  801af1:	6a 34                	push   $0x34
  801af3:	68 67 3d 80 00       	push   $0x803d67
  801af8:	e8 f2 00 00 00       	call   801bef <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801afd:	68 89 3e 80 00       	push   $0x803e89
  801b02:	68 fd 39 80 00       	push   $0x8039fd
  801b07:	6a 35                	push   $0x35
  801b09:	68 67 3d 80 00       	push   $0x803d67
  801b0e:	e8 dc 00 00 00       	call   801bef <_panic>
		panic("file_set_size 2: %e", r);
  801b13:	50                   	push   %eax
  801b14:	68 ba 3e 80 00       	push   $0x803eba
  801b19:	6a 39                	push   $0x39
  801b1b:	68 67 3d 80 00       	push   $0x803d67
  801b20:	e8 ca 00 00 00       	call   801bef <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b25:	68 89 3e 80 00       	push   $0x803e89
  801b2a:	68 fd 39 80 00       	push   $0x8039fd
  801b2f:	6a 3a                	push   $0x3a
  801b31:	68 67 3d 80 00       	push   $0x803d67
  801b36:	e8 b4 00 00 00       	call   801bef <_panic>
		panic("file_get_block 2: %e", r);
  801b3b:	50                   	push   %eax
  801b3c:	68 ce 3e 80 00       	push   $0x803ece
  801b41:	6a 3c                	push   $0x3c
  801b43:	68 67 3d 80 00       	push   $0x803d67
  801b48:	e8 a2 00 00 00       	call   801bef <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b4d:	68 34 3e 80 00       	push   $0x803e34
  801b52:	68 fd 39 80 00       	push   $0x8039fd
  801b57:	6a 3e                	push   $0x3e
  801b59:	68 67 3d 80 00       	push   $0x803d67
  801b5e:	e8 8c 00 00 00       	call   801bef <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b63:	68 33 3e 80 00       	push   $0x803e33
  801b68:	68 fd 39 80 00       	push   $0x8039fd
  801b6d:	6a 40                	push   $0x40
  801b6f:	68 67 3d 80 00       	push   $0x803d67
  801b74:	e8 76 00 00 00       	call   801bef <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b79:	68 89 3e 80 00       	push   $0x803e89
  801b7e:	68 fd 39 80 00       	push   $0x8039fd
  801b83:	6a 41                	push   $0x41
  801b85:	68 67 3d 80 00       	push   $0x803d67
  801b8a:	e8 60 00 00 00       	call   801bef <_panic>

00801b8f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b97:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  801b9a:	e8 05 0b 00 00       	call   8026a4 <sys_getenvid>
  801b9f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ba4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ba7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bac:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801bb1:	85 db                	test   %ebx,%ebx
  801bb3:	7e 07                	jle    801bbc <libmain+0x2d>
		binaryname = argv[0];
  801bb5:	8b 06                	mov    (%esi),%eax
  801bb7:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	e8 65 fb ff ff       	call   80172b <umain>

	// exit gracefully
	exit();
  801bc6:	e8 0a 00 00 00       	call   801bd5 <exit>
}
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801bdb:	e8 39 10 00 00       	call   802c19 <close_all>
	sys_env_destroy(0);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	6a 00                	push   $0x0
  801be5:	e8 79 0a 00 00       	call   802663 <sys_env_destroy>
}
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    

00801bef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801bf4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801bf7:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801bfd:	e8 a2 0a 00 00       	call   8026a4 <sys_getenvid>
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 0c             	pushl  0xc(%ebp)
  801c08:	ff 75 08             	pushl  0x8(%ebp)
  801c0b:	56                   	push   %esi
  801c0c:	50                   	push   %eax
  801c0d:	68 94 3f 80 00       	push   $0x803f94
  801c12:	e8 b3 00 00 00       	call   801cca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c17:	83 c4 18             	add    $0x18,%esp
  801c1a:	53                   	push   %ebx
  801c1b:	ff 75 10             	pushl  0x10(%ebp)
  801c1e:	e8 56 00 00 00       	call   801c79 <vcprintf>
	cprintf("\n");
  801c23:	c7 04 24 a5 3b 80 00 	movl   $0x803ba5,(%esp)
  801c2a:	e8 9b 00 00 00       	call   801cca <cprintf>
  801c2f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c32:	cc                   	int3   
  801c33:	eb fd                	jmp    801c32 <_panic+0x43>

00801c35 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	53                   	push   %ebx
  801c39:	83 ec 04             	sub    $0x4,%esp
  801c3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801c3f:	8b 13                	mov    (%ebx),%edx
  801c41:	8d 42 01             	lea    0x1(%edx),%eax
  801c44:	89 03                	mov    %eax,(%ebx)
  801c46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801c4d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801c52:	74 09                	je     801c5d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801c54:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801c58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801c5d:	83 ec 08             	sub    $0x8,%esp
  801c60:	68 ff 00 00 00       	push   $0xff
  801c65:	8d 43 08             	lea    0x8(%ebx),%eax
  801c68:	50                   	push   %eax
  801c69:	e8 b8 09 00 00       	call   802626 <sys_cputs>
		b->idx = 0;
  801c6e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	eb db                	jmp    801c54 <putch+0x1f>

00801c79 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801c82:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801c89:	00 00 00 
	b.cnt = 0;
  801c8c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801c93:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801c96:	ff 75 0c             	pushl  0xc(%ebp)
  801c99:	ff 75 08             	pushl  0x8(%ebp)
  801c9c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801ca2:	50                   	push   %eax
  801ca3:	68 35 1c 80 00       	push   $0x801c35
  801ca8:	e8 1a 01 00 00       	call   801dc7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801cad:	83 c4 08             	add    $0x8,%esp
  801cb0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801cb6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 64 09 00 00       	call   802626 <sys_cputs>

	return b.cnt;
}
  801cc2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801cd0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801cd3:	50                   	push   %eax
  801cd4:	ff 75 08             	pushl  0x8(%ebp)
  801cd7:	e8 9d ff ff ff       	call   801c79 <vcprintf>
	va_end(ap);

	return cnt;
}
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	89 c7                	mov    %eax,%edi
  801ce9:	89 d6                	mov    %edx,%esi
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801cf4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801cf7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801d02:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801d05:	39 d3                	cmp    %edx,%ebx
  801d07:	72 05                	jb     801d0e <printnum+0x30>
  801d09:	39 45 10             	cmp    %eax,0x10(%ebp)
  801d0c:	77 7a                	ja     801d88 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801d0e:	83 ec 0c             	sub    $0xc,%esp
  801d11:	ff 75 18             	pushl  0x18(%ebp)
  801d14:	8b 45 14             	mov    0x14(%ebp),%eax
  801d17:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801d1a:	53                   	push   %ebx
  801d1b:	ff 75 10             	pushl  0x10(%ebp)
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d24:	ff 75 e0             	pushl  -0x20(%ebp)
  801d27:	ff 75 dc             	pushl  -0x24(%ebp)
  801d2a:	ff 75 d8             	pushl  -0x28(%ebp)
  801d2d:	e8 3e 1a 00 00       	call   803770 <__udivdi3>
  801d32:	83 c4 18             	add    $0x18,%esp
  801d35:	52                   	push   %edx
  801d36:	50                   	push   %eax
  801d37:	89 f2                	mov    %esi,%edx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	e8 9e ff ff ff       	call   801cde <printnum>
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	eb 13                	jmp    801d58 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	56                   	push   %esi
  801d49:	ff 75 18             	pushl  0x18(%ebp)
  801d4c:	ff d7                	call   *%edi
  801d4e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	85 db                	test   %ebx,%ebx
  801d56:	7f ed                	jg     801d45 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801d58:	83 ec 08             	sub    $0x8,%esp
  801d5b:	56                   	push   %esi
  801d5c:	83 ec 04             	sub    $0x4,%esp
  801d5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d62:	ff 75 e0             	pushl  -0x20(%ebp)
  801d65:	ff 75 dc             	pushl  -0x24(%ebp)
  801d68:	ff 75 d8             	pushl  -0x28(%ebp)
  801d6b:	e8 20 1b 00 00       	call   803890 <__umoddi3>
  801d70:	83 c4 14             	add    $0x14,%esp
  801d73:	0f be 80 b7 3f 80 00 	movsbl 0x803fb7(%eax),%eax
  801d7a:	50                   	push   %eax
  801d7b:	ff d7                	call   *%edi
}
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
  801d88:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801d8b:	eb c4                	jmp    801d51 <printnum+0x73>

00801d8d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d93:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801d97:	8b 10                	mov    (%eax),%edx
  801d99:	3b 50 04             	cmp    0x4(%eax),%edx
  801d9c:	73 0a                	jae    801da8 <sprintputch+0x1b>
		*b->buf++ = ch;
  801d9e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801da1:	89 08                	mov    %ecx,(%eax)
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	88 02                	mov    %al,(%edx)
}
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <printfmt>:
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801db0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801db3:	50                   	push   %eax
  801db4:	ff 75 10             	pushl  0x10(%ebp)
  801db7:	ff 75 0c             	pushl  0xc(%ebp)
  801dba:	ff 75 08             	pushl  0x8(%ebp)
  801dbd:	e8 05 00 00 00       	call   801dc7 <vprintfmt>
}
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    

00801dc7 <vprintfmt>:
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 2c             	sub    $0x2c,%esp
  801dd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dd6:	8b 7d 10             	mov    0x10(%ebp),%edi
  801dd9:	e9 c1 03 00 00       	jmp    80219f <vprintfmt+0x3d8>
		padc = ' ';
  801dde:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801de2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801de9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801df0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801df7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801dfc:	8d 47 01             	lea    0x1(%edi),%eax
  801dff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e02:	0f b6 17             	movzbl (%edi),%edx
  801e05:	8d 42 dd             	lea    -0x23(%edx),%eax
  801e08:	3c 55                	cmp    $0x55,%al
  801e0a:	0f 87 12 04 00 00    	ja     802222 <vprintfmt+0x45b>
  801e10:	0f b6 c0             	movzbl %al,%eax
  801e13:	ff 24 85 00 41 80 00 	jmp    *0x804100(,%eax,4)
  801e1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801e1d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801e21:	eb d9                	jmp    801dfc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801e23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801e26:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801e2a:	eb d0                	jmp    801dfc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801e2c:	0f b6 d2             	movzbl %dl,%edx
  801e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
  801e37:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801e3a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801e3d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801e41:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801e44:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801e47:	83 f9 09             	cmp    $0x9,%ecx
  801e4a:	77 55                	ja     801ea1 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801e4c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801e4f:	eb e9                	jmp    801e3a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801e51:	8b 45 14             	mov    0x14(%ebp),%eax
  801e54:	8b 00                	mov    (%eax),%eax
  801e56:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801e59:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5c:	8d 40 04             	lea    0x4(%eax),%eax
  801e5f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801e62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801e65:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e69:	79 91                	jns    801dfc <vprintfmt+0x35>
				width = precision, precision = -1;
  801e6b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e71:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801e78:	eb 82                	jmp    801dfc <vprintfmt+0x35>
  801e7a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e84:	0f 49 d0             	cmovns %eax,%edx
  801e87:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801e8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e8d:	e9 6a ff ff ff       	jmp    801dfc <vprintfmt+0x35>
  801e92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801e95:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801e9c:	e9 5b ff ff ff       	jmp    801dfc <vprintfmt+0x35>
  801ea1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801ea4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801ea7:	eb bc                	jmp    801e65 <vprintfmt+0x9e>
			lflag++;
  801ea9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801eac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801eaf:	e9 48 ff ff ff       	jmp    801dfc <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  801eb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb7:	8d 78 04             	lea    0x4(%eax),%edi
  801eba:	83 ec 08             	sub    $0x8,%esp
  801ebd:	53                   	push   %ebx
  801ebe:	ff 30                	pushl  (%eax)
  801ec0:	ff d6                	call   *%esi
			break;
  801ec2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801ec5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801ec8:	e9 cf 02 00 00       	jmp    80219c <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801ecd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed0:	8d 78 04             	lea    0x4(%eax),%edi
  801ed3:	8b 00                	mov    (%eax),%eax
  801ed5:	99                   	cltd   
  801ed6:	31 d0                	xor    %edx,%eax
  801ed8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801eda:	83 f8 0f             	cmp    $0xf,%eax
  801edd:	7f 23                	jg     801f02 <vprintfmt+0x13b>
  801edf:	8b 14 85 60 42 80 00 	mov    0x804260(,%eax,4),%edx
  801ee6:	85 d2                	test   %edx,%edx
  801ee8:	74 18                	je     801f02 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801eea:	52                   	push   %edx
  801eeb:	68 0f 3a 80 00       	push   $0x803a0f
  801ef0:	53                   	push   %ebx
  801ef1:	56                   	push   %esi
  801ef2:	e8 b3 fe ff ff       	call   801daa <printfmt>
  801ef7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801efa:	89 7d 14             	mov    %edi,0x14(%ebp)
  801efd:	e9 9a 02 00 00       	jmp    80219c <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801f02:	50                   	push   %eax
  801f03:	68 cf 3f 80 00       	push   $0x803fcf
  801f08:	53                   	push   %ebx
  801f09:	56                   	push   %esi
  801f0a:	e8 9b fe ff ff       	call   801daa <printfmt>
  801f0f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801f12:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801f15:	e9 82 02 00 00       	jmp    80219c <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1d:	83 c0 04             	add    $0x4,%eax
  801f20:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801f23:	8b 45 14             	mov    0x14(%ebp),%eax
  801f26:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801f28:	85 ff                	test   %edi,%edi
  801f2a:	b8 c8 3f 80 00       	mov    $0x803fc8,%eax
  801f2f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801f32:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801f36:	0f 8e bd 00 00 00    	jle    801ff9 <vprintfmt+0x232>
  801f3c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801f40:	75 0e                	jne    801f50 <vprintfmt+0x189>
  801f42:	89 75 08             	mov    %esi,0x8(%ebp)
  801f45:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801f48:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f4b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f4e:	eb 6d                	jmp    801fbd <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801f50:	83 ec 08             	sub    $0x8,%esp
  801f53:	ff 75 d0             	pushl  -0x30(%ebp)
  801f56:	57                   	push   %edi
  801f57:	e8 6e 03 00 00       	call   8022ca <strnlen>
  801f5c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801f5f:	29 c1                	sub    %eax,%ecx
  801f61:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801f64:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801f67:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801f6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f6e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801f71:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801f73:	eb 0f                	jmp    801f84 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801f75:	83 ec 08             	sub    $0x8,%esp
  801f78:	53                   	push   %ebx
  801f79:	ff 75 e0             	pushl  -0x20(%ebp)
  801f7c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801f7e:	83 ef 01             	sub    $0x1,%edi
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	85 ff                	test   %edi,%edi
  801f86:	7f ed                	jg     801f75 <vprintfmt+0x1ae>
  801f88:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801f8b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801f8e:	85 c9                	test   %ecx,%ecx
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
  801f95:	0f 49 c1             	cmovns %ecx,%eax
  801f98:	29 c1                	sub    %eax,%ecx
  801f9a:	89 75 08             	mov    %esi,0x8(%ebp)
  801f9d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801fa0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801fa3:	89 cb                	mov    %ecx,%ebx
  801fa5:	eb 16                	jmp    801fbd <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  801fa7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801fab:	75 31                	jne    801fde <vprintfmt+0x217>
					putch(ch, putdat);
  801fad:	83 ec 08             	sub    $0x8,%esp
  801fb0:	ff 75 0c             	pushl  0xc(%ebp)
  801fb3:	50                   	push   %eax
  801fb4:	ff 55 08             	call   *0x8(%ebp)
  801fb7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801fba:	83 eb 01             	sub    $0x1,%ebx
  801fbd:	83 c7 01             	add    $0x1,%edi
  801fc0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801fc4:	0f be c2             	movsbl %dl,%eax
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	74 59                	je     802024 <vprintfmt+0x25d>
  801fcb:	85 f6                	test   %esi,%esi
  801fcd:	78 d8                	js     801fa7 <vprintfmt+0x1e0>
  801fcf:	83 ee 01             	sub    $0x1,%esi
  801fd2:	79 d3                	jns    801fa7 <vprintfmt+0x1e0>
  801fd4:	89 df                	mov    %ebx,%edi
  801fd6:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fdc:	eb 37                	jmp    802015 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801fde:	0f be d2             	movsbl %dl,%edx
  801fe1:	83 ea 20             	sub    $0x20,%edx
  801fe4:	83 fa 5e             	cmp    $0x5e,%edx
  801fe7:	76 c4                	jbe    801fad <vprintfmt+0x1e6>
					putch('?', putdat);
  801fe9:	83 ec 08             	sub    $0x8,%esp
  801fec:	ff 75 0c             	pushl  0xc(%ebp)
  801fef:	6a 3f                	push   $0x3f
  801ff1:	ff 55 08             	call   *0x8(%ebp)
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	eb c1                	jmp    801fba <vprintfmt+0x1f3>
  801ff9:	89 75 08             	mov    %esi,0x8(%ebp)
  801ffc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801fff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  802002:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  802005:	eb b6                	jmp    801fbd <vprintfmt+0x1f6>
				putch(' ', putdat);
  802007:	83 ec 08             	sub    $0x8,%esp
  80200a:	53                   	push   %ebx
  80200b:	6a 20                	push   $0x20
  80200d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80200f:	83 ef 01             	sub    $0x1,%edi
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	85 ff                	test   %edi,%edi
  802017:	7f ee                	jg     802007 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  802019:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80201c:	89 45 14             	mov    %eax,0x14(%ebp)
  80201f:	e9 78 01 00 00       	jmp    80219c <vprintfmt+0x3d5>
  802024:	89 df                	mov    %ebx,%edi
  802026:	8b 75 08             	mov    0x8(%ebp),%esi
  802029:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80202c:	eb e7                	jmp    802015 <vprintfmt+0x24e>
	if (lflag >= 2)
  80202e:	83 f9 01             	cmp    $0x1,%ecx
  802031:	7e 3f                	jle    802072 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  802033:	8b 45 14             	mov    0x14(%ebp),%eax
  802036:	8b 50 04             	mov    0x4(%eax),%edx
  802039:	8b 00                	mov    (%eax),%eax
  80203b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80203e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  802041:	8b 45 14             	mov    0x14(%ebp),%eax
  802044:	8d 40 08             	lea    0x8(%eax),%eax
  802047:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80204a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80204e:	79 5c                	jns    8020ac <vprintfmt+0x2e5>
				putch('-', putdat);
  802050:	83 ec 08             	sub    $0x8,%esp
  802053:	53                   	push   %ebx
  802054:	6a 2d                	push   $0x2d
  802056:	ff d6                	call   *%esi
				num = -(long long) num;
  802058:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80205b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80205e:	f7 da                	neg    %edx
  802060:	83 d1 00             	adc    $0x0,%ecx
  802063:	f7 d9                	neg    %ecx
  802065:	83 c4 10             	add    $0x10,%esp
			base = 10;
  802068:	b8 0a 00 00 00       	mov    $0xa,%eax
  80206d:	e9 10 01 00 00       	jmp    802182 <vprintfmt+0x3bb>
	else if (lflag)
  802072:	85 c9                	test   %ecx,%ecx
  802074:	75 1b                	jne    802091 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  802076:	8b 45 14             	mov    0x14(%ebp),%eax
  802079:	8b 00                	mov    (%eax),%eax
  80207b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80207e:	89 c1                	mov    %eax,%ecx
  802080:	c1 f9 1f             	sar    $0x1f,%ecx
  802083:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802086:	8b 45 14             	mov    0x14(%ebp),%eax
  802089:	8d 40 04             	lea    0x4(%eax),%eax
  80208c:	89 45 14             	mov    %eax,0x14(%ebp)
  80208f:	eb b9                	jmp    80204a <vprintfmt+0x283>
		return va_arg(*ap, long);
  802091:	8b 45 14             	mov    0x14(%ebp),%eax
  802094:	8b 00                	mov    (%eax),%eax
  802096:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802099:	89 c1                	mov    %eax,%ecx
  80209b:	c1 f9 1f             	sar    $0x1f,%ecx
  80209e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8020a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8020a4:	8d 40 04             	lea    0x4(%eax),%eax
  8020a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8020aa:	eb 9e                	jmp    80204a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8020ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8020af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8020b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8020b7:	e9 c6 00 00 00       	jmp    802182 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8020bc:	83 f9 01             	cmp    $0x1,%ecx
  8020bf:	7e 18                	jle    8020d9 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8020c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c4:	8b 10                	mov    (%eax),%edx
  8020c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8020c9:	8d 40 08             	lea    0x8(%eax),%eax
  8020cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8020cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8020d4:	e9 a9 00 00 00       	jmp    802182 <vprintfmt+0x3bb>
	else if (lflag)
  8020d9:	85 c9                	test   %ecx,%ecx
  8020db:	75 1a                	jne    8020f7 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8020dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8020e0:	8b 10                	mov    (%eax),%edx
  8020e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020e7:	8d 40 04             	lea    0x4(%eax),%eax
  8020ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8020ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8020f2:	e9 8b 00 00 00       	jmp    802182 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8020f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020fa:	8b 10                	mov    (%eax),%edx
  8020fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  802101:	8d 40 04             	lea    0x4(%eax),%eax
  802104:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  802107:	b8 0a 00 00 00       	mov    $0xa,%eax
  80210c:	eb 74                	jmp    802182 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80210e:	83 f9 01             	cmp    $0x1,%ecx
  802111:	7e 15                	jle    802128 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  802113:	8b 45 14             	mov    0x14(%ebp),%eax
  802116:	8b 10                	mov    (%eax),%edx
  802118:	8b 48 04             	mov    0x4(%eax),%ecx
  80211b:	8d 40 08             	lea    0x8(%eax),%eax
  80211e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  802121:	b8 08 00 00 00       	mov    $0x8,%eax
  802126:	eb 5a                	jmp    802182 <vprintfmt+0x3bb>
	else if (lflag)
  802128:	85 c9                	test   %ecx,%ecx
  80212a:	75 17                	jne    802143 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80212c:	8b 45 14             	mov    0x14(%ebp),%eax
  80212f:	8b 10                	mov    (%eax),%edx
  802131:	b9 00 00 00 00       	mov    $0x0,%ecx
  802136:	8d 40 04             	lea    0x4(%eax),%eax
  802139:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80213c:	b8 08 00 00 00       	mov    $0x8,%eax
  802141:	eb 3f                	jmp    802182 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  802143:	8b 45 14             	mov    0x14(%ebp),%eax
  802146:	8b 10                	mov    (%eax),%edx
  802148:	b9 00 00 00 00       	mov    $0x0,%ecx
  80214d:	8d 40 04             	lea    0x4(%eax),%eax
  802150:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  802153:	b8 08 00 00 00       	mov    $0x8,%eax
  802158:	eb 28                	jmp    802182 <vprintfmt+0x3bb>
			putch('0', putdat);
  80215a:	83 ec 08             	sub    $0x8,%esp
  80215d:	53                   	push   %ebx
  80215e:	6a 30                	push   $0x30
  802160:	ff d6                	call   *%esi
			putch('x', putdat);
  802162:	83 c4 08             	add    $0x8,%esp
  802165:	53                   	push   %ebx
  802166:	6a 78                	push   $0x78
  802168:	ff d6                	call   *%esi
			num = (unsigned long long)
  80216a:	8b 45 14             	mov    0x14(%ebp),%eax
  80216d:	8b 10                	mov    (%eax),%edx
  80216f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  802174:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  802177:	8d 40 04             	lea    0x4(%eax),%eax
  80217a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80217d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  802182:	83 ec 0c             	sub    $0xc,%esp
  802185:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  802189:	57                   	push   %edi
  80218a:	ff 75 e0             	pushl  -0x20(%ebp)
  80218d:	50                   	push   %eax
  80218e:	51                   	push   %ecx
  80218f:	52                   	push   %edx
  802190:	89 da                	mov    %ebx,%edx
  802192:	89 f0                	mov    %esi,%eax
  802194:	e8 45 fb ff ff       	call   801cde <printnum>
			break;
  802199:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80219c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80219f:	83 c7 01             	add    $0x1,%edi
  8021a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8021a6:	83 f8 25             	cmp    $0x25,%eax
  8021a9:	0f 84 2f fc ff ff    	je     801dde <vprintfmt+0x17>
			if (ch == '\0')
  8021af:	85 c0                	test   %eax,%eax
  8021b1:	0f 84 8b 00 00 00    	je     802242 <vprintfmt+0x47b>
			putch(ch, putdat);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	53                   	push   %ebx
  8021bb:	50                   	push   %eax
  8021bc:	ff d6                	call   *%esi
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	eb dc                	jmp    80219f <vprintfmt+0x3d8>
	if (lflag >= 2)
  8021c3:	83 f9 01             	cmp    $0x1,%ecx
  8021c6:	7e 15                	jle    8021dd <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8021c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8021cb:	8b 10                	mov    (%eax),%edx
  8021cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8021d0:	8d 40 08             	lea    0x8(%eax),%eax
  8021d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8021d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8021db:	eb a5                	jmp    802182 <vprintfmt+0x3bb>
	else if (lflag)
  8021dd:	85 c9                	test   %ecx,%ecx
  8021df:	75 17                	jne    8021f8 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8021e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021e4:	8b 10                	mov    (%eax),%edx
  8021e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8021eb:	8d 40 04             	lea    0x4(%eax),%eax
  8021ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8021f1:	b8 10 00 00 00       	mov    $0x10,%eax
  8021f6:	eb 8a                	jmp    802182 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8021f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fb:	8b 10                	mov    (%eax),%edx
  8021fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  802202:	8d 40 04             	lea    0x4(%eax),%eax
  802205:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  802208:	b8 10 00 00 00       	mov    $0x10,%eax
  80220d:	e9 70 ff ff ff       	jmp    802182 <vprintfmt+0x3bb>
			putch(ch, putdat);
  802212:	83 ec 08             	sub    $0x8,%esp
  802215:	53                   	push   %ebx
  802216:	6a 25                	push   $0x25
  802218:	ff d6                	call   *%esi
			break;
  80221a:	83 c4 10             	add    $0x10,%esp
  80221d:	e9 7a ff ff ff       	jmp    80219c <vprintfmt+0x3d5>
			putch('%', putdat);
  802222:	83 ec 08             	sub    $0x8,%esp
  802225:	53                   	push   %ebx
  802226:	6a 25                	push   $0x25
  802228:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80222a:	83 c4 10             	add    $0x10,%esp
  80222d:	89 f8                	mov    %edi,%eax
  80222f:	eb 03                	jmp    802234 <vprintfmt+0x46d>
  802231:	83 e8 01             	sub    $0x1,%eax
  802234:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  802238:	75 f7                	jne    802231 <vprintfmt+0x46a>
  80223a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80223d:	e9 5a ff ff ff       	jmp    80219c <vprintfmt+0x3d5>
}
  802242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	83 ec 18             	sub    $0x18,%esp
  802250:	8b 45 08             	mov    0x8(%ebp),%eax
  802253:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802256:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802259:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80225d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802260:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802267:	85 c0                	test   %eax,%eax
  802269:	74 26                	je     802291 <vsnprintf+0x47>
  80226b:	85 d2                	test   %edx,%edx
  80226d:	7e 22                	jle    802291 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80226f:	ff 75 14             	pushl  0x14(%ebp)
  802272:	ff 75 10             	pushl  0x10(%ebp)
  802275:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802278:	50                   	push   %eax
  802279:	68 8d 1d 80 00       	push   $0x801d8d
  80227e:	e8 44 fb ff ff       	call   801dc7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802283:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802286:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228c:	83 c4 10             	add    $0x10,%esp
}
  80228f:	c9                   	leave  
  802290:	c3                   	ret    
		return -E_INVAL;
  802291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802296:	eb f7                	jmp    80228f <vsnprintf+0x45>

00802298 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802298:	55                   	push   %ebp
  802299:	89 e5                	mov    %esp,%ebp
  80229b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80229e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8022a1:	50                   	push   %eax
  8022a2:	ff 75 10             	pushl  0x10(%ebp)
  8022a5:	ff 75 0c             	pushl  0xc(%ebp)
  8022a8:	ff 75 08             	pushl  0x8(%ebp)
  8022ab:	e8 9a ff ff ff       	call   80224a <vsnprintf>
	va_end(ap);

	return rc;
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8022bd:	eb 03                	jmp    8022c2 <strlen+0x10>
		n++;
  8022bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8022c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022c6:	75 f7                	jne    8022bf <strlen+0xd>
	return n;
}
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    

008022ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d8:	eb 03                	jmp    8022dd <strnlen+0x13>
		n++;
  8022da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022dd:	39 d0                	cmp    %edx,%eax
  8022df:	74 06                	je     8022e7 <strnlen+0x1d>
  8022e1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8022e5:	75 f3                	jne    8022da <strnlen+0x10>
	return n;
}
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    

008022e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	53                   	push   %ebx
  8022ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8022f3:	89 c2                	mov    %eax,%edx
  8022f5:	83 c1 01             	add    $0x1,%ecx
  8022f8:	83 c2 01             	add    $0x1,%edx
  8022fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8022ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  802302:	84 db                	test   %bl,%bl
  802304:	75 ef                	jne    8022f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802306:	5b                   	pop    %ebx
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	53                   	push   %ebx
  80230d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802310:	53                   	push   %ebx
  802311:	e8 9c ff ff ff       	call   8022b2 <strlen>
  802316:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802319:	ff 75 0c             	pushl  0xc(%ebp)
  80231c:	01 d8                	add    %ebx,%eax
  80231e:	50                   	push   %eax
  80231f:	e8 c5 ff ff ff       	call   8022e9 <strcpy>
	return dst;
}
  802324:	89 d8                	mov    %ebx,%eax
  802326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802329:	c9                   	leave  
  80232a:	c3                   	ret    

0080232b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80232b:	55                   	push   %ebp
  80232c:	89 e5                	mov    %esp,%ebp
  80232e:	56                   	push   %esi
  80232f:	53                   	push   %ebx
  802330:	8b 75 08             	mov    0x8(%ebp),%esi
  802333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802336:	89 f3                	mov    %esi,%ebx
  802338:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80233b:	89 f2                	mov    %esi,%edx
  80233d:	eb 0f                	jmp    80234e <strncpy+0x23>
		*dst++ = *src;
  80233f:	83 c2 01             	add    $0x1,%edx
  802342:	0f b6 01             	movzbl (%ecx),%eax
  802345:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802348:	80 39 01             	cmpb   $0x1,(%ecx)
  80234b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80234e:	39 da                	cmp    %ebx,%edx
  802350:	75 ed                	jne    80233f <strncpy+0x14>
	}
	return ret;
}
  802352:	89 f0                	mov    %esi,%eax
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    

00802358 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	56                   	push   %esi
  80235c:	53                   	push   %ebx
  80235d:	8b 75 08             	mov    0x8(%ebp),%esi
  802360:	8b 55 0c             	mov    0xc(%ebp),%edx
  802363:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802366:	89 f0                	mov    %esi,%eax
  802368:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80236c:	85 c9                	test   %ecx,%ecx
  80236e:	75 0b                	jne    80237b <strlcpy+0x23>
  802370:	eb 17                	jmp    802389 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802372:	83 c2 01             	add    $0x1,%edx
  802375:	83 c0 01             	add    $0x1,%eax
  802378:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80237b:	39 d8                	cmp    %ebx,%eax
  80237d:	74 07                	je     802386 <strlcpy+0x2e>
  80237f:	0f b6 0a             	movzbl (%edx),%ecx
  802382:	84 c9                	test   %cl,%cl
  802384:	75 ec                	jne    802372 <strlcpy+0x1a>
		*dst = '\0';
  802386:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  802389:	29 f0                	sub    %esi,%eax
}
  80238b:	5b                   	pop    %ebx
  80238c:	5e                   	pop    %esi
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    

0080238f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802395:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802398:	eb 06                	jmp    8023a0 <strcmp+0x11>
		p++, q++;
  80239a:	83 c1 01             	add    $0x1,%ecx
  80239d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8023a0:	0f b6 01             	movzbl (%ecx),%eax
  8023a3:	84 c0                	test   %al,%al
  8023a5:	74 04                	je     8023ab <strcmp+0x1c>
  8023a7:	3a 02                	cmp    (%edx),%al
  8023a9:	74 ef                	je     80239a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8023ab:	0f b6 c0             	movzbl %al,%eax
  8023ae:	0f b6 12             	movzbl (%edx),%edx
  8023b1:	29 d0                	sub    %edx,%eax
}
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    

008023b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8023b5:	55                   	push   %ebp
  8023b6:	89 e5                	mov    %esp,%ebp
  8023b8:	53                   	push   %ebx
  8023b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023bf:	89 c3                	mov    %eax,%ebx
  8023c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8023c4:	eb 06                	jmp    8023cc <strncmp+0x17>
		n--, p++, q++;
  8023c6:	83 c0 01             	add    $0x1,%eax
  8023c9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8023cc:	39 d8                	cmp    %ebx,%eax
  8023ce:	74 16                	je     8023e6 <strncmp+0x31>
  8023d0:	0f b6 08             	movzbl (%eax),%ecx
  8023d3:	84 c9                	test   %cl,%cl
  8023d5:	74 04                	je     8023db <strncmp+0x26>
  8023d7:	3a 0a                	cmp    (%edx),%cl
  8023d9:	74 eb                	je     8023c6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8023db:	0f b6 00             	movzbl (%eax),%eax
  8023de:	0f b6 12             	movzbl (%edx),%edx
  8023e1:	29 d0                	sub    %edx,%eax
}
  8023e3:	5b                   	pop    %ebx
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
		return 0;
  8023e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8023eb:	eb f6                	jmp    8023e3 <strncmp+0x2e>

008023ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8023ed:	55                   	push   %ebp
  8023ee:	89 e5                	mov    %esp,%ebp
  8023f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8023f7:	0f b6 10             	movzbl (%eax),%edx
  8023fa:	84 d2                	test   %dl,%dl
  8023fc:	74 09                	je     802407 <strchr+0x1a>
		if (*s == c)
  8023fe:	38 ca                	cmp    %cl,%dl
  802400:	74 0a                	je     80240c <strchr+0x1f>
	for (; *s; s++)
  802402:	83 c0 01             	add    $0x1,%eax
  802405:	eb f0                	jmp    8023f7 <strchr+0xa>
			return (char *) s;
	return 0;
  802407:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80240c:	5d                   	pop    %ebp
  80240d:	c3                   	ret    

0080240e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
  802411:	8b 45 08             	mov    0x8(%ebp),%eax
  802414:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802418:	eb 03                	jmp    80241d <strfind+0xf>
  80241a:	83 c0 01             	add    $0x1,%eax
  80241d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802420:	38 ca                	cmp    %cl,%dl
  802422:	74 04                	je     802428 <strfind+0x1a>
  802424:	84 d2                	test   %dl,%dl
  802426:	75 f2                	jne    80241a <strfind+0xc>
			break;
	return (char *) s;
}
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    

0080242a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80242a:	55                   	push   %ebp
  80242b:	89 e5                	mov    %esp,%ebp
  80242d:	57                   	push   %edi
  80242e:	56                   	push   %esi
  80242f:	53                   	push   %ebx
  802430:	8b 7d 08             	mov    0x8(%ebp),%edi
  802433:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802436:	85 c9                	test   %ecx,%ecx
  802438:	74 13                	je     80244d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80243a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802440:	75 05                	jne    802447 <memset+0x1d>
  802442:	f6 c1 03             	test   $0x3,%cl
  802445:	74 0d                	je     802454 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802447:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244a:	fc                   	cld    
  80244b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80244d:	89 f8                	mov    %edi,%eax
  80244f:	5b                   	pop    %ebx
  802450:	5e                   	pop    %esi
  802451:	5f                   	pop    %edi
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    
		c &= 0xFF;
  802454:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802458:	89 d3                	mov    %edx,%ebx
  80245a:	c1 e3 08             	shl    $0x8,%ebx
  80245d:	89 d0                	mov    %edx,%eax
  80245f:	c1 e0 18             	shl    $0x18,%eax
  802462:	89 d6                	mov    %edx,%esi
  802464:	c1 e6 10             	shl    $0x10,%esi
  802467:	09 f0                	or     %esi,%eax
  802469:	09 c2                	or     %eax,%edx
  80246b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80246d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  802470:	89 d0                	mov    %edx,%eax
  802472:	fc                   	cld    
  802473:	f3 ab                	rep stos %eax,%es:(%edi)
  802475:	eb d6                	jmp    80244d <memset+0x23>

00802477 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	57                   	push   %edi
  80247b:	56                   	push   %esi
  80247c:	8b 45 08             	mov    0x8(%ebp),%eax
  80247f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802482:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802485:	39 c6                	cmp    %eax,%esi
  802487:	73 35                	jae    8024be <memmove+0x47>
  802489:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80248c:	39 c2                	cmp    %eax,%edx
  80248e:	76 2e                	jbe    8024be <memmove+0x47>
		s += n;
		d += n;
  802490:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802493:	89 d6                	mov    %edx,%esi
  802495:	09 fe                	or     %edi,%esi
  802497:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80249d:	74 0c                	je     8024ab <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80249f:	83 ef 01             	sub    $0x1,%edi
  8024a2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8024a5:	fd                   	std    
  8024a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8024a8:	fc                   	cld    
  8024a9:	eb 21                	jmp    8024cc <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024ab:	f6 c1 03             	test   $0x3,%cl
  8024ae:	75 ef                	jne    80249f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8024b0:	83 ef 04             	sub    $0x4,%edi
  8024b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8024b6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8024b9:	fd                   	std    
  8024ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024bc:	eb ea                	jmp    8024a8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024be:	89 f2                	mov    %esi,%edx
  8024c0:	09 c2                	or     %eax,%edx
  8024c2:	f6 c2 03             	test   $0x3,%dl
  8024c5:	74 09                	je     8024d0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8024c7:	89 c7                	mov    %eax,%edi
  8024c9:	fc                   	cld    
  8024ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8024cc:	5e                   	pop    %esi
  8024cd:	5f                   	pop    %edi
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024d0:	f6 c1 03             	test   $0x3,%cl
  8024d3:	75 f2                	jne    8024c7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8024d5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8024d8:	89 c7                	mov    %eax,%edi
  8024da:	fc                   	cld    
  8024db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024dd:	eb ed                	jmp    8024cc <memmove+0x55>

008024df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8024e2:	ff 75 10             	pushl  0x10(%ebp)
  8024e5:	ff 75 0c             	pushl  0xc(%ebp)
  8024e8:	ff 75 08             	pushl  0x8(%ebp)
  8024eb:	e8 87 ff ff ff       	call   802477 <memmove>
}
  8024f0:	c9                   	leave  
  8024f1:	c3                   	ret    

008024f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	56                   	push   %esi
  8024f6:	53                   	push   %ebx
  8024f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024fd:	89 c6                	mov    %eax,%esi
  8024ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802502:	39 f0                	cmp    %esi,%eax
  802504:	74 1c                	je     802522 <memcmp+0x30>
		if (*s1 != *s2)
  802506:	0f b6 08             	movzbl (%eax),%ecx
  802509:	0f b6 1a             	movzbl (%edx),%ebx
  80250c:	38 d9                	cmp    %bl,%cl
  80250e:	75 08                	jne    802518 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  802510:	83 c0 01             	add    $0x1,%eax
  802513:	83 c2 01             	add    $0x1,%edx
  802516:	eb ea                	jmp    802502 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  802518:	0f b6 c1             	movzbl %cl,%eax
  80251b:	0f b6 db             	movzbl %bl,%ebx
  80251e:	29 d8                	sub    %ebx,%eax
  802520:	eb 05                	jmp    802527 <memcmp+0x35>
	}

	return 0;
  802522:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802527:	5b                   	pop    %ebx
  802528:	5e                   	pop    %esi
  802529:	5d                   	pop    %ebp
  80252a:	c3                   	ret    

0080252b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80252b:	55                   	push   %ebp
  80252c:	89 e5                	mov    %esp,%ebp
  80252e:	8b 45 08             	mov    0x8(%ebp),%eax
  802531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802534:	89 c2                	mov    %eax,%edx
  802536:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802539:	39 d0                	cmp    %edx,%eax
  80253b:	73 09                	jae    802546 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80253d:	38 08                	cmp    %cl,(%eax)
  80253f:	74 05                	je     802546 <memfind+0x1b>
	for (; s < ends; s++)
  802541:	83 c0 01             	add    $0x1,%eax
  802544:	eb f3                	jmp    802539 <memfind+0xe>
			break;
	return (void *) s;
}
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    

00802548 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802548:	55                   	push   %ebp
  802549:	89 e5                	mov    %esp,%ebp
  80254b:	57                   	push   %edi
  80254c:	56                   	push   %esi
  80254d:	53                   	push   %ebx
  80254e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802551:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802554:	eb 03                	jmp    802559 <strtol+0x11>
		s++;
  802556:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  802559:	0f b6 01             	movzbl (%ecx),%eax
  80255c:	3c 20                	cmp    $0x20,%al
  80255e:	74 f6                	je     802556 <strtol+0xe>
  802560:	3c 09                	cmp    $0x9,%al
  802562:	74 f2                	je     802556 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  802564:	3c 2b                	cmp    $0x2b,%al
  802566:	74 2e                	je     802596 <strtol+0x4e>
	int neg = 0;
  802568:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80256d:	3c 2d                	cmp    $0x2d,%al
  80256f:	74 2f                	je     8025a0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802571:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802577:	75 05                	jne    80257e <strtol+0x36>
  802579:	80 39 30             	cmpb   $0x30,(%ecx)
  80257c:	74 2c                	je     8025aa <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80257e:	85 db                	test   %ebx,%ebx
  802580:	75 0a                	jne    80258c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802582:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  802587:	80 39 30             	cmpb   $0x30,(%ecx)
  80258a:	74 28                	je     8025b4 <strtol+0x6c>
		base = 10;
  80258c:	b8 00 00 00 00       	mov    $0x0,%eax
  802591:	89 5d 10             	mov    %ebx,0x10(%ebp)
  802594:	eb 50                	jmp    8025e6 <strtol+0x9e>
		s++;
  802596:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  802599:	bf 00 00 00 00       	mov    $0x0,%edi
  80259e:	eb d1                	jmp    802571 <strtol+0x29>
		s++, neg = 1;
  8025a0:	83 c1 01             	add    $0x1,%ecx
  8025a3:	bf 01 00 00 00       	mov    $0x1,%edi
  8025a8:	eb c7                	jmp    802571 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8025aa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8025ae:	74 0e                	je     8025be <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8025b0:	85 db                	test   %ebx,%ebx
  8025b2:	75 d8                	jne    80258c <strtol+0x44>
		s++, base = 8;
  8025b4:	83 c1 01             	add    $0x1,%ecx
  8025b7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8025bc:	eb ce                	jmp    80258c <strtol+0x44>
		s += 2, base = 16;
  8025be:	83 c1 02             	add    $0x2,%ecx
  8025c1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8025c6:	eb c4                	jmp    80258c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8025c8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8025cb:	89 f3                	mov    %esi,%ebx
  8025cd:	80 fb 19             	cmp    $0x19,%bl
  8025d0:	77 29                	ja     8025fb <strtol+0xb3>
			dig = *s - 'a' + 10;
  8025d2:	0f be d2             	movsbl %dl,%edx
  8025d5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8025d8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8025db:	7d 30                	jge    80260d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8025dd:	83 c1 01             	add    $0x1,%ecx
  8025e0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8025e4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8025e6:	0f b6 11             	movzbl (%ecx),%edx
  8025e9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8025ec:	89 f3                	mov    %esi,%ebx
  8025ee:	80 fb 09             	cmp    $0x9,%bl
  8025f1:	77 d5                	ja     8025c8 <strtol+0x80>
			dig = *s - '0';
  8025f3:	0f be d2             	movsbl %dl,%edx
  8025f6:	83 ea 30             	sub    $0x30,%edx
  8025f9:	eb dd                	jmp    8025d8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8025fb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8025fe:	89 f3                	mov    %esi,%ebx
  802600:	80 fb 19             	cmp    $0x19,%bl
  802603:	77 08                	ja     80260d <strtol+0xc5>
			dig = *s - 'A' + 10;
  802605:	0f be d2             	movsbl %dl,%edx
  802608:	83 ea 37             	sub    $0x37,%edx
  80260b:	eb cb                	jmp    8025d8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80260d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802611:	74 05                	je     802618 <strtol+0xd0>
		*endptr = (char *) s;
  802613:	8b 75 0c             	mov    0xc(%ebp),%esi
  802616:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  802618:	89 c2                	mov    %eax,%edx
  80261a:	f7 da                	neg    %edx
  80261c:	85 ff                	test   %edi,%edi
  80261e:	0f 45 c2             	cmovne %edx,%eax
}
  802621:	5b                   	pop    %ebx
  802622:	5e                   	pop    %esi
  802623:	5f                   	pop    %edi
  802624:	5d                   	pop    %ebp
  802625:	c3                   	ret    

00802626 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802626:	55                   	push   %ebp
  802627:	89 e5                	mov    %esp,%ebp
  802629:	57                   	push   %edi
  80262a:	56                   	push   %esi
  80262b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80262c:	b8 00 00 00 00       	mov    $0x0,%eax
  802631:	8b 55 08             	mov    0x8(%ebp),%edx
  802634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802637:	89 c3                	mov    %eax,%ebx
  802639:	89 c7                	mov    %eax,%edi
  80263b:	89 c6                	mov    %eax,%esi
  80263d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80263f:	5b                   	pop    %ebx
  802640:	5e                   	pop    %esi
  802641:	5f                   	pop    %edi
  802642:	5d                   	pop    %ebp
  802643:	c3                   	ret    

00802644 <sys_cgetc>:

int
sys_cgetc(void)
{
  802644:	55                   	push   %ebp
  802645:	89 e5                	mov    %esp,%ebp
  802647:	57                   	push   %edi
  802648:	56                   	push   %esi
  802649:	53                   	push   %ebx
	asm volatile("int %1\n"
  80264a:	ba 00 00 00 00       	mov    $0x0,%edx
  80264f:	b8 01 00 00 00       	mov    $0x1,%eax
  802654:	89 d1                	mov    %edx,%ecx
  802656:	89 d3                	mov    %edx,%ebx
  802658:	89 d7                	mov    %edx,%edi
  80265a:	89 d6                	mov    %edx,%esi
  80265c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80265e:	5b                   	pop    %ebx
  80265f:	5e                   	pop    %esi
  802660:	5f                   	pop    %edi
  802661:	5d                   	pop    %ebp
  802662:	c3                   	ret    

00802663 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802663:	55                   	push   %ebp
  802664:	89 e5                	mov    %esp,%ebp
  802666:	57                   	push   %edi
  802667:	56                   	push   %esi
  802668:	53                   	push   %ebx
  802669:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80266c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802671:	8b 55 08             	mov    0x8(%ebp),%edx
  802674:	b8 03 00 00 00       	mov    $0x3,%eax
  802679:	89 cb                	mov    %ecx,%ebx
  80267b:	89 cf                	mov    %ecx,%edi
  80267d:	89 ce                	mov    %ecx,%esi
  80267f:	cd 30                	int    $0x30
	if(check && ret > 0)
  802681:	85 c0                	test   %eax,%eax
  802683:	7f 08                	jg     80268d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80268d:	83 ec 0c             	sub    $0xc,%esp
  802690:	50                   	push   %eax
  802691:	6a 03                	push   $0x3
  802693:	68 bf 42 80 00       	push   $0x8042bf
  802698:	6a 23                	push   $0x23
  80269a:	68 dc 42 80 00       	push   $0x8042dc
  80269f:	e8 4b f5 ff ff       	call   801bef <_panic>

008026a4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	57                   	push   %edi
  8026a8:	56                   	push   %esi
  8026a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8026aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8026af:	b8 02 00 00 00       	mov    $0x2,%eax
  8026b4:	89 d1                	mov    %edx,%ecx
  8026b6:	89 d3                	mov    %edx,%ebx
  8026b8:	89 d7                	mov    %edx,%edi
  8026ba:	89 d6                	mov    %edx,%esi
  8026bc:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8026be:	5b                   	pop    %ebx
  8026bf:	5e                   	pop    %esi
  8026c0:	5f                   	pop    %edi
  8026c1:	5d                   	pop    %ebp
  8026c2:	c3                   	ret    

008026c3 <sys_yield>:

void
sys_yield(void)
{
  8026c3:	55                   	push   %ebp
  8026c4:	89 e5                	mov    %esp,%ebp
  8026c6:	57                   	push   %edi
  8026c7:	56                   	push   %esi
  8026c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8026c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8026ce:	b8 0b 00 00 00       	mov    $0xb,%eax
  8026d3:	89 d1                	mov    %edx,%ecx
  8026d5:	89 d3                	mov    %edx,%ebx
  8026d7:	89 d7                	mov    %edx,%edi
  8026d9:	89 d6                	mov    %edx,%esi
  8026db:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5f                   	pop    %edi
  8026e0:	5d                   	pop    %ebp
  8026e1:	c3                   	ret    

008026e2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8026e2:	55                   	push   %ebp
  8026e3:	89 e5                	mov    %esp,%ebp
  8026e5:	57                   	push   %edi
  8026e6:	56                   	push   %esi
  8026e7:	53                   	push   %ebx
  8026e8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8026eb:	be 00 00 00 00       	mov    $0x0,%esi
  8026f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8026f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026f6:	b8 04 00 00 00       	mov    $0x4,%eax
  8026fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026fe:	89 f7                	mov    %esi,%edi
  802700:	cd 30                	int    $0x30
	if(check && ret > 0)
  802702:	85 c0                	test   %eax,%eax
  802704:	7f 08                	jg     80270e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802709:	5b                   	pop    %ebx
  80270a:	5e                   	pop    %esi
  80270b:	5f                   	pop    %edi
  80270c:	5d                   	pop    %ebp
  80270d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80270e:	83 ec 0c             	sub    $0xc,%esp
  802711:	50                   	push   %eax
  802712:	6a 04                	push   $0x4
  802714:	68 bf 42 80 00       	push   $0x8042bf
  802719:	6a 23                	push   $0x23
  80271b:	68 dc 42 80 00       	push   $0x8042dc
  802720:	e8 ca f4 ff ff       	call   801bef <_panic>

00802725 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802725:	55                   	push   %ebp
  802726:	89 e5                	mov    %esp,%ebp
  802728:	57                   	push   %edi
  802729:	56                   	push   %esi
  80272a:	53                   	push   %ebx
  80272b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80272e:	8b 55 08             	mov    0x8(%ebp),%edx
  802731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802734:	b8 05 00 00 00       	mov    $0x5,%eax
  802739:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80273c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80273f:	8b 75 18             	mov    0x18(%ebp),%esi
  802742:	cd 30                	int    $0x30
	if(check && ret > 0)
  802744:	85 c0                	test   %eax,%eax
  802746:	7f 08                	jg     802750 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80274b:	5b                   	pop    %ebx
  80274c:	5e                   	pop    %esi
  80274d:	5f                   	pop    %edi
  80274e:	5d                   	pop    %ebp
  80274f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802750:	83 ec 0c             	sub    $0xc,%esp
  802753:	50                   	push   %eax
  802754:	6a 05                	push   $0x5
  802756:	68 bf 42 80 00       	push   $0x8042bf
  80275b:	6a 23                	push   $0x23
  80275d:	68 dc 42 80 00       	push   $0x8042dc
  802762:	e8 88 f4 ff ff       	call   801bef <_panic>

00802767 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802767:	55                   	push   %ebp
  802768:	89 e5                	mov    %esp,%ebp
  80276a:	57                   	push   %edi
  80276b:	56                   	push   %esi
  80276c:	53                   	push   %ebx
  80276d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802770:	bb 00 00 00 00       	mov    $0x0,%ebx
  802775:	8b 55 08             	mov    0x8(%ebp),%edx
  802778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80277b:	b8 06 00 00 00       	mov    $0x6,%eax
  802780:	89 df                	mov    %ebx,%edi
  802782:	89 de                	mov    %ebx,%esi
  802784:	cd 30                	int    $0x30
	if(check && ret > 0)
  802786:	85 c0                	test   %eax,%eax
  802788:	7f 08                	jg     802792 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80278a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80278d:	5b                   	pop    %ebx
  80278e:	5e                   	pop    %esi
  80278f:	5f                   	pop    %edi
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802792:	83 ec 0c             	sub    $0xc,%esp
  802795:	50                   	push   %eax
  802796:	6a 06                	push   $0x6
  802798:	68 bf 42 80 00       	push   $0x8042bf
  80279d:	6a 23                	push   $0x23
  80279f:	68 dc 42 80 00       	push   $0x8042dc
  8027a4:	e8 46 f4 ff ff       	call   801bef <_panic>

008027a9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027a9:	55                   	push   %ebp
  8027aa:	89 e5                	mov    %esp,%ebp
  8027ac:	57                   	push   %edi
  8027ad:	56                   	push   %esi
  8027ae:	53                   	push   %ebx
  8027af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8027b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8027ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8027c2:	89 df                	mov    %ebx,%edi
  8027c4:	89 de                	mov    %ebx,%esi
  8027c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	7f 08                	jg     8027d4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8027cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027cf:	5b                   	pop    %ebx
  8027d0:	5e                   	pop    %esi
  8027d1:	5f                   	pop    %edi
  8027d2:	5d                   	pop    %ebp
  8027d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8027d4:	83 ec 0c             	sub    $0xc,%esp
  8027d7:	50                   	push   %eax
  8027d8:	6a 08                	push   $0x8
  8027da:	68 bf 42 80 00       	push   $0x8042bf
  8027df:	6a 23                	push   $0x23
  8027e1:	68 dc 42 80 00       	push   $0x8042dc
  8027e6:	e8 04 f4 ff ff       	call   801bef <_panic>

008027eb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8027eb:	55                   	push   %ebp
  8027ec:	89 e5                	mov    %esp,%ebp
  8027ee:	57                   	push   %edi
  8027ef:	56                   	push   %esi
  8027f0:	53                   	push   %ebx
  8027f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8027f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027ff:	b8 09 00 00 00       	mov    $0x9,%eax
  802804:	89 df                	mov    %ebx,%edi
  802806:	89 de                	mov    %ebx,%esi
  802808:	cd 30                	int    $0x30
	if(check && ret > 0)
  80280a:	85 c0                	test   %eax,%eax
  80280c:	7f 08                	jg     802816 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80280e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802811:	5b                   	pop    %ebx
  802812:	5e                   	pop    %esi
  802813:	5f                   	pop    %edi
  802814:	5d                   	pop    %ebp
  802815:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802816:	83 ec 0c             	sub    $0xc,%esp
  802819:	50                   	push   %eax
  80281a:	6a 09                	push   $0x9
  80281c:	68 bf 42 80 00       	push   $0x8042bf
  802821:	6a 23                	push   $0x23
  802823:	68 dc 42 80 00       	push   $0x8042dc
  802828:	e8 c2 f3 ff ff       	call   801bef <_panic>

0080282d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80282d:	55                   	push   %ebp
  80282e:	89 e5                	mov    %esp,%ebp
  802830:	57                   	push   %edi
  802831:	56                   	push   %esi
  802832:	53                   	push   %ebx
  802833:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  802836:	bb 00 00 00 00       	mov    $0x0,%ebx
  80283b:	8b 55 08             	mov    0x8(%ebp),%edx
  80283e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802841:	b8 0a 00 00 00       	mov    $0xa,%eax
  802846:	89 df                	mov    %ebx,%edi
  802848:	89 de                	mov    %ebx,%esi
  80284a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80284c:	85 c0                	test   %eax,%eax
  80284e:	7f 08                	jg     802858 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802850:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802853:	5b                   	pop    %ebx
  802854:	5e                   	pop    %esi
  802855:	5f                   	pop    %edi
  802856:	5d                   	pop    %ebp
  802857:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  802858:	83 ec 0c             	sub    $0xc,%esp
  80285b:	50                   	push   %eax
  80285c:	6a 0a                	push   $0xa
  80285e:	68 bf 42 80 00       	push   $0x8042bf
  802863:	6a 23                	push   $0x23
  802865:	68 dc 42 80 00       	push   $0x8042dc
  80286a:	e8 80 f3 ff ff       	call   801bef <_panic>

0080286f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80286f:	55                   	push   %ebp
  802870:	89 e5                	mov    %esp,%ebp
  802872:	57                   	push   %edi
  802873:	56                   	push   %esi
  802874:	53                   	push   %ebx
	asm volatile("int %1\n"
  802875:	8b 55 08             	mov    0x8(%ebp),%edx
  802878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80287b:	b8 0c 00 00 00       	mov    $0xc,%eax
  802880:	be 00 00 00 00       	mov    $0x0,%esi
  802885:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802888:	8b 7d 14             	mov    0x14(%ebp),%edi
  80288b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80288d:	5b                   	pop    %ebx
  80288e:	5e                   	pop    %esi
  80288f:	5f                   	pop    %edi
  802890:	5d                   	pop    %ebp
  802891:	c3                   	ret    

00802892 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802892:	55                   	push   %ebp
  802893:	89 e5                	mov    %esp,%ebp
  802895:	57                   	push   %edi
  802896:	56                   	push   %esi
  802897:	53                   	push   %ebx
  802898:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80289b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8028a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8028a3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028a8:	89 cb                	mov    %ecx,%ebx
  8028aa:	89 cf                	mov    %ecx,%edi
  8028ac:	89 ce                	mov    %ecx,%esi
  8028ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8028b0:	85 c0                	test   %eax,%eax
  8028b2:	7f 08                	jg     8028bc <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8028b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028b7:	5b                   	pop    %ebx
  8028b8:	5e                   	pop    %esi
  8028b9:	5f                   	pop    %edi
  8028ba:	5d                   	pop    %ebp
  8028bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8028bc:	83 ec 0c             	sub    $0xc,%esp
  8028bf:	50                   	push   %eax
  8028c0:	6a 0d                	push   $0xd
  8028c2:	68 bf 42 80 00       	push   $0x8042bf
  8028c7:	6a 23                	push   $0x23
  8028c9:	68 dc 42 80 00       	push   $0x8042dc
  8028ce:	e8 1c f3 ff ff       	call   801bef <_panic>

008028d3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028d3:	55                   	push   %ebp
  8028d4:	89 e5                	mov    %esp,%ebp
  8028d6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028d9:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8028e0:	74 23                	je     802905 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e5:	a3 10 a0 80 00       	mov    %eax,0x80a010
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8028ea:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028ef:	8b 40 48             	mov    0x48(%eax),%eax
  8028f2:	83 ec 08             	sub    $0x8,%esp
  8028f5:	68 36 29 80 00       	push   $0x802936
  8028fa:	50                   	push   %eax
  8028fb:	e8 2d ff ff ff       	call   80282d <sys_env_set_pgfault_upcall>
}
  802900:	83 c4 10             	add    $0x10,%esp
  802903:	c9                   	leave  
  802904:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  802905:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80290a:	8b 40 48             	mov    0x48(%eax),%eax
  80290d:	83 ec 04             	sub    $0x4,%esp
  802910:	6a 07                	push   $0x7
  802912:	68 00 f0 bf ee       	push   $0xeebff000
  802917:	50                   	push   %eax
  802918:	e8 c5 fd ff ff       	call   8026e2 <sys_page_alloc>
  80291d:	83 c4 10             	add    $0x10,%esp
  802920:	85 c0                	test   %eax,%eax
  802922:	79 be                	jns    8028e2 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  802924:	50                   	push   %eax
  802925:	68 54 3d 80 00       	push   $0x803d54
  80292a:	6a 21                	push   $0x21
  80292c:	68 ea 42 80 00       	push   $0x8042ea
  802931:	e8 b9 f2 ff ff       	call   801bef <_panic>

00802936 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802936:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802937:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  80293c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80293e:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  802941:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  802944:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  802948:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  80294c:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  80294f:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  802953:	89 18                	mov    %ebx,(%eax)

    popal
  802955:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  802956:	83 c4 04             	add    $0x4,%esp
    popfl
  802959:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  80295a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  80295b:	c3                   	ret    

0080295c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
  80295f:	56                   	push   %esi
  802960:	53                   	push   %ebx
  802961:	8b 75 08             	mov    0x8(%ebp),%esi
  802964:	8b 45 0c             	mov    0xc(%ebp),%eax
  802967:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  80296a:	85 c0                	test   %eax,%eax
  80296c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802971:	0f 44 c2             	cmove  %edx,%eax
  802974:	83 ec 0c             	sub    $0xc,%esp
  802977:	50                   	push   %eax
  802978:	e8 15 ff ff ff       	call   802892 <sys_ipc_recv>
  80297d:	83 c4 10             	add    $0x10,%esp
  802980:	85 c0                	test   %eax,%eax
  802982:	78 2b                	js     8029af <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  802984:	85 f6                	test   %esi,%esi
  802986:	74 0a                	je     802992 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  802988:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80298d:	8b 40 74             	mov    0x74(%eax),%eax
  802990:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  802992:	85 db                	test   %ebx,%ebx
  802994:	74 0a                	je     8029a0 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  802996:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80299b:	8b 40 78             	mov    0x78(%eax),%eax
  80299e:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  8029a0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029a5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029ab:	5b                   	pop    %ebx
  8029ac:	5e                   	pop    %esi
  8029ad:	5d                   	pop    %ebp
  8029ae:	c3                   	ret    
        *from_env_store = 0;
  8029af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  8029b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  8029bb:	eb eb                	jmp    8029a8 <ipc_recv+0x4c>

008029bd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029bd:	55                   	push   %ebp
  8029be:	89 e5                	mov    %esp,%ebp
  8029c0:	57                   	push   %edi
  8029c1:	56                   	push   %esi
  8029c2:	53                   	push   %ebx
  8029c3:	83 ec 0c             	sub    $0xc,%esp
  8029c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  8029cf:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  8029d1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029d6:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  8029d9:	ff 75 14             	pushl  0x14(%ebp)
  8029dc:	53                   	push   %ebx
  8029dd:	56                   	push   %esi
  8029de:	57                   	push   %edi
  8029df:	e8 8b fe ff ff       	call   80286f <sys_ipc_try_send>
  8029e4:	83 c4 10             	add    $0x10,%esp
  8029e7:	85 c0                	test   %eax,%eax
  8029e9:	74 17                	je     802a02 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  8029eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029ee:	74 e9                	je     8029d9 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  8029f0:	50                   	push   %eax
  8029f1:	68 f8 42 80 00       	push   $0x8042f8
  8029f6:	6a 3e                	push   $0x3e
  8029f8:	68 0a 43 80 00       	push   $0x80430a
  8029fd:	e8 ed f1 ff ff       	call   801bef <_panic>
        }
    }
}
  802a02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a05:	5b                   	pop    %ebx
  802a06:	5e                   	pop    %esi
  802a07:	5f                   	pop    %edi
  802a08:	5d                   	pop    %ebp
  802a09:	c3                   	ret    

00802a0a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a0a:	55                   	push   %ebp
  802a0b:	89 e5                	mov    %esp,%ebp
  802a0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a10:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a15:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a18:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a1e:	8b 52 50             	mov    0x50(%edx),%edx
  802a21:	39 ca                	cmp    %ecx,%edx
  802a23:	74 11                	je     802a36 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802a25:	83 c0 01             	add    $0x1,%eax
  802a28:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a2d:	75 e6                	jne    802a15 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802a34:	eb 0b                	jmp    802a41 <ipc_find_env+0x37>
			return envs[i].env_id;
  802a36:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a3e:	8b 40 48             	mov    0x48(%eax),%eax
}
  802a41:	5d                   	pop    %ebp
  802a42:	c3                   	ret    

00802a43 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802a43:	55                   	push   %ebp
  802a44:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a46:	8b 45 08             	mov    0x8(%ebp),%eax
  802a49:	05 00 00 00 30       	add    $0x30000000,%eax
  802a4e:	c1 e8 0c             	shr    $0xc,%eax
}
  802a51:	5d                   	pop    %ebp
  802a52:	c3                   	ret    

00802a53 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a53:	55                   	push   %ebp
  802a54:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a56:	8b 45 08             	mov    0x8(%ebp),%eax
  802a59:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  802a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802a63:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a68:	5d                   	pop    %ebp
  802a69:	c3                   	ret    

00802a6a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a6a:	55                   	push   %ebp
  802a6b:	89 e5                	mov    %esp,%ebp
  802a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a70:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802a75:	89 c2                	mov    %eax,%edx
  802a77:	c1 ea 16             	shr    $0x16,%edx
  802a7a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a81:	f6 c2 01             	test   $0x1,%dl
  802a84:	74 2a                	je     802ab0 <fd_alloc+0x46>
  802a86:	89 c2                	mov    %eax,%edx
  802a88:	c1 ea 0c             	shr    $0xc,%edx
  802a8b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802a92:	f6 c2 01             	test   $0x1,%dl
  802a95:	74 19                	je     802ab0 <fd_alloc+0x46>
  802a97:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802a9c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802aa1:	75 d2                	jne    802a75 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802aa3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802aa9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  802aae:	eb 07                	jmp    802ab7 <fd_alloc+0x4d>
			*fd_store = fd;
  802ab0:	89 01                	mov    %eax,(%ecx)
			return 0;
  802ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ab7:	5d                   	pop    %ebp
  802ab8:	c3                   	ret    

00802ab9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802ab9:	55                   	push   %ebp
  802aba:	89 e5                	mov    %esp,%ebp
  802abc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802abf:	83 f8 1f             	cmp    $0x1f,%eax
  802ac2:	77 36                	ja     802afa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802ac4:	c1 e0 0c             	shl    $0xc,%eax
  802ac7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802acc:	89 c2                	mov    %eax,%edx
  802ace:	c1 ea 16             	shr    $0x16,%edx
  802ad1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ad8:	f6 c2 01             	test   $0x1,%dl
  802adb:	74 24                	je     802b01 <fd_lookup+0x48>
  802add:	89 c2                	mov    %eax,%edx
  802adf:	c1 ea 0c             	shr    $0xc,%edx
  802ae2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ae9:	f6 c2 01             	test   $0x1,%dl
  802aec:	74 1a                	je     802b08 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  802af1:	89 02                	mov    %eax,(%edx)
	return 0;
  802af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802af8:	5d                   	pop    %ebp
  802af9:	c3                   	ret    
		return -E_INVAL;
  802afa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802aff:	eb f7                	jmp    802af8 <fd_lookup+0x3f>
		return -E_INVAL;
  802b01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b06:	eb f0                	jmp    802af8 <fd_lookup+0x3f>
  802b08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b0d:	eb e9                	jmp    802af8 <fd_lookup+0x3f>

00802b0f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802b0f:	55                   	push   %ebp
  802b10:	89 e5                	mov    %esp,%ebp
  802b12:	83 ec 08             	sub    $0x8,%esp
  802b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b18:	ba 90 43 80 00       	mov    $0x804390,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802b1d:	b8 64 90 80 00       	mov    $0x809064,%eax
		if (devtab[i]->dev_id == dev_id) {
  802b22:	39 08                	cmp    %ecx,(%eax)
  802b24:	74 33                	je     802b59 <dev_lookup+0x4a>
  802b26:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  802b29:	8b 02                	mov    (%edx),%eax
  802b2b:	85 c0                	test   %eax,%eax
  802b2d:	75 f3                	jne    802b22 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b2f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b34:	8b 40 48             	mov    0x48(%eax),%eax
  802b37:	83 ec 04             	sub    $0x4,%esp
  802b3a:	51                   	push   %ecx
  802b3b:	50                   	push   %eax
  802b3c:	68 14 43 80 00       	push   $0x804314
  802b41:	e8 84 f1 ff ff       	call   801cca <cprintf>
	*dev = 0;
  802b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b4f:	83 c4 10             	add    $0x10,%esp
  802b52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b57:	c9                   	leave  
  802b58:	c3                   	ret    
			*dev = devtab[i];
  802b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  802b63:	eb f2                	jmp    802b57 <dev_lookup+0x48>

00802b65 <fd_close>:
{
  802b65:	55                   	push   %ebp
  802b66:	89 e5                	mov    %esp,%ebp
  802b68:	57                   	push   %edi
  802b69:	56                   	push   %esi
  802b6a:	53                   	push   %ebx
  802b6b:	83 ec 1c             	sub    $0x1c,%esp
  802b6e:	8b 75 08             	mov    0x8(%ebp),%esi
  802b71:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802b77:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802b78:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802b7e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802b81:	50                   	push   %eax
  802b82:	e8 32 ff ff ff       	call   802ab9 <fd_lookup>
  802b87:	89 c3                	mov    %eax,%ebx
  802b89:	83 c4 08             	add    $0x8,%esp
  802b8c:	85 c0                	test   %eax,%eax
  802b8e:	78 05                	js     802b95 <fd_close+0x30>
	    || fd != fd2)
  802b90:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802b93:	74 16                	je     802bab <fd_close+0x46>
		return (must_exist ? r : 0);
  802b95:	89 f8                	mov    %edi,%eax
  802b97:	84 c0                	test   %al,%al
  802b99:	b8 00 00 00 00       	mov    $0x0,%eax
  802b9e:	0f 44 d8             	cmove  %eax,%ebx
}
  802ba1:	89 d8                	mov    %ebx,%eax
  802ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba6:	5b                   	pop    %ebx
  802ba7:	5e                   	pop    %esi
  802ba8:	5f                   	pop    %edi
  802ba9:	5d                   	pop    %ebp
  802baa:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802bab:	83 ec 08             	sub    $0x8,%esp
  802bae:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802bb1:	50                   	push   %eax
  802bb2:	ff 36                	pushl  (%esi)
  802bb4:	e8 56 ff ff ff       	call   802b0f <dev_lookup>
  802bb9:	89 c3                	mov    %eax,%ebx
  802bbb:	83 c4 10             	add    $0x10,%esp
  802bbe:	85 c0                	test   %eax,%eax
  802bc0:	78 15                	js     802bd7 <fd_close+0x72>
		if (dev->dev_close)
  802bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802bc5:	8b 40 10             	mov    0x10(%eax),%eax
  802bc8:	85 c0                	test   %eax,%eax
  802bca:	74 1b                	je     802be7 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  802bcc:	83 ec 0c             	sub    $0xc,%esp
  802bcf:	56                   	push   %esi
  802bd0:	ff d0                	call   *%eax
  802bd2:	89 c3                	mov    %eax,%ebx
  802bd4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802bd7:	83 ec 08             	sub    $0x8,%esp
  802bda:	56                   	push   %esi
  802bdb:	6a 00                	push   $0x0
  802bdd:	e8 85 fb ff ff       	call   802767 <sys_page_unmap>
	return r;
  802be2:	83 c4 10             	add    $0x10,%esp
  802be5:	eb ba                	jmp    802ba1 <fd_close+0x3c>
			r = 0;
  802be7:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bec:	eb e9                	jmp    802bd7 <fd_close+0x72>

00802bee <close>:

int
close(int fdnum)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bf4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bf7:	50                   	push   %eax
  802bf8:	ff 75 08             	pushl  0x8(%ebp)
  802bfb:	e8 b9 fe ff ff       	call   802ab9 <fd_lookup>
  802c00:	83 c4 08             	add    $0x8,%esp
  802c03:	85 c0                	test   %eax,%eax
  802c05:	78 10                	js     802c17 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802c07:	83 ec 08             	sub    $0x8,%esp
  802c0a:	6a 01                	push   $0x1
  802c0c:	ff 75 f4             	pushl  -0xc(%ebp)
  802c0f:	e8 51 ff ff ff       	call   802b65 <fd_close>
  802c14:	83 c4 10             	add    $0x10,%esp
}
  802c17:	c9                   	leave  
  802c18:	c3                   	ret    

00802c19 <close_all>:

void
close_all(void)
{
  802c19:	55                   	push   %ebp
  802c1a:	89 e5                	mov    %esp,%ebp
  802c1c:	53                   	push   %ebx
  802c1d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802c20:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c25:	83 ec 0c             	sub    $0xc,%esp
  802c28:	53                   	push   %ebx
  802c29:	e8 c0 ff ff ff       	call   802bee <close>
	for (i = 0; i < MAXFD; i++)
  802c2e:	83 c3 01             	add    $0x1,%ebx
  802c31:	83 c4 10             	add    $0x10,%esp
  802c34:	83 fb 20             	cmp    $0x20,%ebx
  802c37:	75 ec                	jne    802c25 <close_all+0xc>
}
  802c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c3c:	c9                   	leave  
  802c3d:	c3                   	ret    

00802c3e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c3e:	55                   	push   %ebp
  802c3f:	89 e5                	mov    %esp,%ebp
  802c41:	57                   	push   %edi
  802c42:	56                   	push   %esi
  802c43:	53                   	push   %ebx
  802c44:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c4a:	50                   	push   %eax
  802c4b:	ff 75 08             	pushl  0x8(%ebp)
  802c4e:	e8 66 fe ff ff       	call   802ab9 <fd_lookup>
  802c53:	89 c3                	mov    %eax,%ebx
  802c55:	83 c4 08             	add    $0x8,%esp
  802c58:	85 c0                	test   %eax,%eax
  802c5a:	0f 88 81 00 00 00    	js     802ce1 <dup+0xa3>
		return r;
	close(newfdnum);
  802c60:	83 ec 0c             	sub    $0xc,%esp
  802c63:	ff 75 0c             	pushl  0xc(%ebp)
  802c66:	e8 83 ff ff ff       	call   802bee <close>

	newfd = INDEX2FD(newfdnum);
  802c6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  802c6e:	c1 e6 0c             	shl    $0xc,%esi
  802c71:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802c77:	83 c4 04             	add    $0x4,%esp
  802c7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  802c7d:	e8 d1 fd ff ff       	call   802a53 <fd2data>
  802c82:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802c84:	89 34 24             	mov    %esi,(%esp)
  802c87:	e8 c7 fd ff ff       	call   802a53 <fd2data>
  802c8c:	83 c4 10             	add    $0x10,%esp
  802c8f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802c91:	89 d8                	mov    %ebx,%eax
  802c93:	c1 e8 16             	shr    $0x16,%eax
  802c96:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802c9d:	a8 01                	test   $0x1,%al
  802c9f:	74 11                	je     802cb2 <dup+0x74>
  802ca1:	89 d8                	mov    %ebx,%eax
  802ca3:	c1 e8 0c             	shr    $0xc,%eax
  802ca6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802cad:	f6 c2 01             	test   $0x1,%dl
  802cb0:	75 39                	jne    802ceb <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802cb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802cb5:	89 d0                	mov    %edx,%eax
  802cb7:	c1 e8 0c             	shr    $0xc,%eax
  802cba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cc1:	83 ec 0c             	sub    $0xc,%esp
  802cc4:	25 07 0e 00 00       	and    $0xe07,%eax
  802cc9:	50                   	push   %eax
  802cca:	56                   	push   %esi
  802ccb:	6a 00                	push   $0x0
  802ccd:	52                   	push   %edx
  802cce:	6a 00                	push   $0x0
  802cd0:	e8 50 fa ff ff       	call   802725 <sys_page_map>
  802cd5:	89 c3                	mov    %eax,%ebx
  802cd7:	83 c4 20             	add    $0x20,%esp
  802cda:	85 c0                	test   %eax,%eax
  802cdc:	78 31                	js     802d0f <dup+0xd1>
		goto err;

	return newfdnum;
  802cde:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802ce1:	89 d8                	mov    %ebx,%eax
  802ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ce6:	5b                   	pop    %ebx
  802ce7:	5e                   	pop    %esi
  802ce8:	5f                   	pop    %edi
  802ce9:	5d                   	pop    %ebp
  802cea:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802ceb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802cf2:	83 ec 0c             	sub    $0xc,%esp
  802cf5:	25 07 0e 00 00       	and    $0xe07,%eax
  802cfa:	50                   	push   %eax
  802cfb:	57                   	push   %edi
  802cfc:	6a 00                	push   $0x0
  802cfe:	53                   	push   %ebx
  802cff:	6a 00                	push   $0x0
  802d01:	e8 1f fa ff ff       	call   802725 <sys_page_map>
  802d06:	89 c3                	mov    %eax,%ebx
  802d08:	83 c4 20             	add    $0x20,%esp
  802d0b:	85 c0                	test   %eax,%eax
  802d0d:	79 a3                	jns    802cb2 <dup+0x74>
	sys_page_unmap(0, newfd);
  802d0f:	83 ec 08             	sub    $0x8,%esp
  802d12:	56                   	push   %esi
  802d13:	6a 00                	push   $0x0
  802d15:	e8 4d fa ff ff       	call   802767 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802d1a:	83 c4 08             	add    $0x8,%esp
  802d1d:	57                   	push   %edi
  802d1e:	6a 00                	push   $0x0
  802d20:	e8 42 fa ff ff       	call   802767 <sys_page_unmap>
	return r;
  802d25:	83 c4 10             	add    $0x10,%esp
  802d28:	eb b7                	jmp    802ce1 <dup+0xa3>

00802d2a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d2a:	55                   	push   %ebp
  802d2b:	89 e5                	mov    %esp,%ebp
  802d2d:	53                   	push   %ebx
  802d2e:	83 ec 14             	sub    $0x14,%esp
  802d31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d37:	50                   	push   %eax
  802d38:	53                   	push   %ebx
  802d39:	e8 7b fd ff ff       	call   802ab9 <fd_lookup>
  802d3e:	83 c4 08             	add    $0x8,%esp
  802d41:	85 c0                	test   %eax,%eax
  802d43:	78 3f                	js     802d84 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d45:	83 ec 08             	sub    $0x8,%esp
  802d48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d4b:	50                   	push   %eax
  802d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d4f:	ff 30                	pushl  (%eax)
  802d51:	e8 b9 fd ff ff       	call   802b0f <dev_lookup>
  802d56:	83 c4 10             	add    $0x10,%esp
  802d59:	85 c0                	test   %eax,%eax
  802d5b:	78 27                	js     802d84 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802d5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d60:	8b 42 08             	mov    0x8(%edx),%eax
  802d63:	83 e0 03             	and    $0x3,%eax
  802d66:	83 f8 01             	cmp    $0x1,%eax
  802d69:	74 1e                	je     802d89 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d6e:	8b 40 08             	mov    0x8(%eax),%eax
  802d71:	85 c0                	test   %eax,%eax
  802d73:	74 35                	je     802daa <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802d75:	83 ec 04             	sub    $0x4,%esp
  802d78:	ff 75 10             	pushl  0x10(%ebp)
  802d7b:	ff 75 0c             	pushl  0xc(%ebp)
  802d7e:	52                   	push   %edx
  802d7f:	ff d0                	call   *%eax
  802d81:	83 c4 10             	add    $0x10,%esp
}
  802d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d87:	c9                   	leave  
  802d88:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802d89:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802d8e:	8b 40 48             	mov    0x48(%eax),%eax
  802d91:	83 ec 04             	sub    $0x4,%esp
  802d94:	53                   	push   %ebx
  802d95:	50                   	push   %eax
  802d96:	68 55 43 80 00       	push   $0x804355
  802d9b:	e8 2a ef ff ff       	call   801cca <cprintf>
		return -E_INVAL;
  802da0:	83 c4 10             	add    $0x10,%esp
  802da3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802da8:	eb da                	jmp    802d84 <read+0x5a>
		return -E_NOT_SUPP;
  802daa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802daf:	eb d3                	jmp    802d84 <read+0x5a>

00802db1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802db1:	55                   	push   %ebp
  802db2:	89 e5                	mov    %esp,%ebp
  802db4:	57                   	push   %edi
  802db5:	56                   	push   %esi
  802db6:	53                   	push   %ebx
  802db7:	83 ec 0c             	sub    $0xc,%esp
  802dba:	8b 7d 08             	mov    0x8(%ebp),%edi
  802dbd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  802dc5:	39 f3                	cmp    %esi,%ebx
  802dc7:	73 25                	jae    802dee <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802dc9:	83 ec 04             	sub    $0x4,%esp
  802dcc:	89 f0                	mov    %esi,%eax
  802dce:	29 d8                	sub    %ebx,%eax
  802dd0:	50                   	push   %eax
  802dd1:	89 d8                	mov    %ebx,%eax
  802dd3:	03 45 0c             	add    0xc(%ebp),%eax
  802dd6:	50                   	push   %eax
  802dd7:	57                   	push   %edi
  802dd8:	e8 4d ff ff ff       	call   802d2a <read>
		if (m < 0)
  802ddd:	83 c4 10             	add    $0x10,%esp
  802de0:	85 c0                	test   %eax,%eax
  802de2:	78 08                	js     802dec <readn+0x3b>
			return m;
		if (m == 0)
  802de4:	85 c0                	test   %eax,%eax
  802de6:	74 06                	je     802dee <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  802de8:	01 c3                	add    %eax,%ebx
  802dea:	eb d9                	jmp    802dc5 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802dec:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802dee:	89 d8                	mov    %ebx,%eax
  802df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802df3:	5b                   	pop    %ebx
  802df4:	5e                   	pop    %esi
  802df5:	5f                   	pop    %edi
  802df6:	5d                   	pop    %ebp
  802df7:	c3                   	ret    

00802df8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802df8:	55                   	push   %ebp
  802df9:	89 e5                	mov    %esp,%ebp
  802dfb:	53                   	push   %ebx
  802dfc:	83 ec 14             	sub    $0x14,%esp
  802dff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e05:	50                   	push   %eax
  802e06:	53                   	push   %ebx
  802e07:	e8 ad fc ff ff       	call   802ab9 <fd_lookup>
  802e0c:	83 c4 08             	add    $0x8,%esp
  802e0f:	85 c0                	test   %eax,%eax
  802e11:	78 3a                	js     802e4d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e13:	83 ec 08             	sub    $0x8,%esp
  802e16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e19:	50                   	push   %eax
  802e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e1d:	ff 30                	pushl  (%eax)
  802e1f:	e8 eb fc ff ff       	call   802b0f <dev_lookup>
  802e24:	83 c4 10             	add    $0x10,%esp
  802e27:	85 c0                	test   %eax,%eax
  802e29:	78 22                	js     802e4d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e2e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e32:	74 1e                	je     802e52 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e37:	8b 52 0c             	mov    0xc(%edx),%edx
  802e3a:	85 d2                	test   %edx,%edx
  802e3c:	74 35                	je     802e73 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e3e:	83 ec 04             	sub    $0x4,%esp
  802e41:	ff 75 10             	pushl  0x10(%ebp)
  802e44:	ff 75 0c             	pushl  0xc(%ebp)
  802e47:	50                   	push   %eax
  802e48:	ff d2                	call   *%edx
  802e4a:	83 c4 10             	add    $0x10,%esp
}
  802e4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e50:	c9                   	leave  
  802e51:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802e52:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802e57:	8b 40 48             	mov    0x48(%eax),%eax
  802e5a:	83 ec 04             	sub    $0x4,%esp
  802e5d:	53                   	push   %ebx
  802e5e:	50                   	push   %eax
  802e5f:	68 71 43 80 00       	push   $0x804371
  802e64:	e8 61 ee ff ff       	call   801cca <cprintf>
		return -E_INVAL;
  802e69:	83 c4 10             	add    $0x10,%esp
  802e6c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e71:	eb da                	jmp    802e4d <write+0x55>
		return -E_NOT_SUPP;
  802e73:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802e78:	eb d3                	jmp    802e4d <write+0x55>

00802e7a <seek>:

int
seek(int fdnum, off_t offset)
{
  802e7a:	55                   	push   %ebp
  802e7b:	89 e5                	mov    %esp,%ebp
  802e7d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e80:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802e83:	50                   	push   %eax
  802e84:	ff 75 08             	pushl  0x8(%ebp)
  802e87:	e8 2d fc ff ff       	call   802ab9 <fd_lookup>
  802e8c:	83 c4 08             	add    $0x8,%esp
  802e8f:	85 c0                	test   %eax,%eax
  802e91:	78 0e                	js     802ea1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802e93:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e96:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802e99:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802e9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ea1:	c9                   	leave  
  802ea2:	c3                   	ret    

00802ea3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802ea3:	55                   	push   %ebp
  802ea4:	89 e5                	mov    %esp,%ebp
  802ea6:	53                   	push   %ebx
  802ea7:	83 ec 14             	sub    $0x14,%esp
  802eaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ead:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802eb0:	50                   	push   %eax
  802eb1:	53                   	push   %ebx
  802eb2:	e8 02 fc ff ff       	call   802ab9 <fd_lookup>
  802eb7:	83 c4 08             	add    $0x8,%esp
  802eba:	85 c0                	test   %eax,%eax
  802ebc:	78 37                	js     802ef5 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ebe:	83 ec 08             	sub    $0x8,%esp
  802ec1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ec4:	50                   	push   %eax
  802ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ec8:	ff 30                	pushl  (%eax)
  802eca:	e8 40 fc ff ff       	call   802b0f <dev_lookup>
  802ecf:	83 c4 10             	add    $0x10,%esp
  802ed2:	85 c0                	test   %eax,%eax
  802ed4:	78 1f                	js     802ef5 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802ed6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ed9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802edd:	74 1b                	je     802efa <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802edf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ee2:	8b 52 18             	mov    0x18(%edx),%edx
  802ee5:	85 d2                	test   %edx,%edx
  802ee7:	74 32                	je     802f1b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802ee9:	83 ec 08             	sub    $0x8,%esp
  802eec:	ff 75 0c             	pushl  0xc(%ebp)
  802eef:	50                   	push   %eax
  802ef0:	ff d2                	call   *%edx
  802ef2:	83 c4 10             	add    $0x10,%esp
}
  802ef5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ef8:	c9                   	leave  
  802ef9:	c3                   	ret    
			thisenv->env_id, fdnum);
  802efa:	a1 0c a0 80 00       	mov    0x80a00c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802eff:	8b 40 48             	mov    0x48(%eax),%eax
  802f02:	83 ec 04             	sub    $0x4,%esp
  802f05:	53                   	push   %ebx
  802f06:	50                   	push   %eax
  802f07:	68 34 43 80 00       	push   $0x804334
  802f0c:	e8 b9 ed ff ff       	call   801cca <cprintf>
		return -E_INVAL;
  802f11:	83 c4 10             	add    $0x10,%esp
  802f14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802f19:	eb da                	jmp    802ef5 <ftruncate+0x52>
		return -E_NOT_SUPP;
  802f1b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f20:	eb d3                	jmp    802ef5 <ftruncate+0x52>

00802f22 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f22:	55                   	push   %ebp
  802f23:	89 e5                	mov    %esp,%ebp
  802f25:	53                   	push   %ebx
  802f26:	83 ec 14             	sub    $0x14,%esp
  802f29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f2f:	50                   	push   %eax
  802f30:	ff 75 08             	pushl  0x8(%ebp)
  802f33:	e8 81 fb ff ff       	call   802ab9 <fd_lookup>
  802f38:	83 c4 08             	add    $0x8,%esp
  802f3b:	85 c0                	test   %eax,%eax
  802f3d:	78 4b                	js     802f8a <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f3f:	83 ec 08             	sub    $0x8,%esp
  802f42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f45:	50                   	push   %eax
  802f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f49:	ff 30                	pushl  (%eax)
  802f4b:	e8 bf fb ff ff       	call   802b0f <dev_lookup>
  802f50:	83 c4 10             	add    $0x10,%esp
  802f53:	85 c0                	test   %eax,%eax
  802f55:	78 33                	js     802f8a <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  802f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f5a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802f5e:	74 2f                	je     802f8f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802f60:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802f63:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802f6a:	00 00 00 
	stat->st_isdir = 0;
  802f6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802f74:	00 00 00 
	stat->st_dev = dev;
  802f77:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802f7d:	83 ec 08             	sub    $0x8,%esp
  802f80:	53                   	push   %ebx
  802f81:	ff 75 f0             	pushl  -0x10(%ebp)
  802f84:	ff 50 14             	call   *0x14(%eax)
  802f87:	83 c4 10             	add    $0x10,%esp
}
  802f8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f8d:	c9                   	leave  
  802f8e:	c3                   	ret    
		return -E_NOT_SUPP;
  802f8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f94:	eb f4                	jmp    802f8a <fstat+0x68>

00802f96 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802f96:	55                   	push   %ebp
  802f97:	89 e5                	mov    %esp,%ebp
  802f99:	56                   	push   %esi
  802f9a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802f9b:	83 ec 08             	sub    $0x8,%esp
  802f9e:	6a 00                	push   $0x0
  802fa0:	ff 75 08             	pushl  0x8(%ebp)
  802fa3:	e8 e7 01 00 00       	call   80318f <open>
  802fa8:	89 c3                	mov    %eax,%ebx
  802faa:	83 c4 10             	add    $0x10,%esp
  802fad:	85 c0                	test   %eax,%eax
  802faf:	78 1b                	js     802fcc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802fb1:	83 ec 08             	sub    $0x8,%esp
  802fb4:	ff 75 0c             	pushl  0xc(%ebp)
  802fb7:	50                   	push   %eax
  802fb8:	e8 65 ff ff ff       	call   802f22 <fstat>
  802fbd:	89 c6                	mov    %eax,%esi
	close(fd);
  802fbf:	89 1c 24             	mov    %ebx,(%esp)
  802fc2:	e8 27 fc ff ff       	call   802bee <close>
	return r;
  802fc7:	83 c4 10             	add    $0x10,%esp
  802fca:	89 f3                	mov    %esi,%ebx
}
  802fcc:	89 d8                	mov    %ebx,%eax
  802fce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802fd1:	5b                   	pop    %ebx
  802fd2:	5e                   	pop    %esi
  802fd3:	5d                   	pop    %ebp
  802fd4:	c3                   	ret    

00802fd5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802fd5:	55                   	push   %ebp
  802fd6:	89 e5                	mov    %esp,%ebp
  802fd8:	56                   	push   %esi
  802fd9:	53                   	push   %ebx
  802fda:	89 c6                	mov    %eax,%esi
  802fdc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802fde:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802fe5:	74 27                	je     80300e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802fe7:	6a 07                	push   $0x7
  802fe9:	68 00 b0 80 00       	push   $0x80b000
  802fee:	56                   	push   %esi
  802fef:	ff 35 00 a0 80 00    	pushl  0x80a000
  802ff5:	e8 c3 f9 ff ff       	call   8029bd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802ffa:	83 c4 0c             	add    $0xc,%esp
  802ffd:	6a 00                	push   $0x0
  802fff:	53                   	push   %ebx
  803000:	6a 00                	push   $0x0
  803002:	e8 55 f9 ff ff       	call   80295c <ipc_recv>
}
  803007:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80300a:	5b                   	pop    %ebx
  80300b:	5e                   	pop    %esi
  80300c:	5d                   	pop    %ebp
  80300d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80300e:	83 ec 0c             	sub    $0xc,%esp
  803011:	6a 01                	push   $0x1
  803013:	e8 f2 f9 ff ff       	call   802a0a <ipc_find_env>
  803018:	a3 00 a0 80 00       	mov    %eax,0x80a000
  80301d:	83 c4 10             	add    $0x10,%esp
  803020:	eb c5                	jmp    802fe7 <fsipc+0x12>

00803022 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803022:	55                   	push   %ebp
  803023:	89 e5                	mov    %esp,%ebp
  803025:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803028:	8b 45 08             	mov    0x8(%ebp),%eax
  80302b:	8b 40 0c             	mov    0xc(%eax),%eax
  80302e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803033:	8b 45 0c             	mov    0xc(%ebp),%eax
  803036:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80303b:	ba 00 00 00 00       	mov    $0x0,%edx
  803040:	b8 02 00 00 00       	mov    $0x2,%eax
  803045:	e8 8b ff ff ff       	call   802fd5 <fsipc>
}
  80304a:	c9                   	leave  
  80304b:	c3                   	ret    

0080304c <devfile_flush>:
{
  80304c:	55                   	push   %ebp
  80304d:	89 e5                	mov    %esp,%ebp
  80304f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803052:	8b 45 08             	mov    0x8(%ebp),%eax
  803055:	8b 40 0c             	mov    0xc(%eax),%eax
  803058:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80305d:	ba 00 00 00 00       	mov    $0x0,%edx
  803062:	b8 06 00 00 00       	mov    $0x6,%eax
  803067:	e8 69 ff ff ff       	call   802fd5 <fsipc>
}
  80306c:	c9                   	leave  
  80306d:	c3                   	ret    

0080306e <devfile_stat>:
{
  80306e:	55                   	push   %ebp
  80306f:	89 e5                	mov    %esp,%ebp
  803071:	53                   	push   %ebx
  803072:	83 ec 04             	sub    $0x4,%esp
  803075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803078:	8b 45 08             	mov    0x8(%ebp),%eax
  80307b:	8b 40 0c             	mov    0xc(%eax),%eax
  80307e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803083:	ba 00 00 00 00       	mov    $0x0,%edx
  803088:	b8 05 00 00 00       	mov    $0x5,%eax
  80308d:	e8 43 ff ff ff       	call   802fd5 <fsipc>
  803092:	85 c0                	test   %eax,%eax
  803094:	78 2c                	js     8030c2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803096:	83 ec 08             	sub    $0x8,%esp
  803099:	68 00 b0 80 00       	push   $0x80b000
  80309e:	53                   	push   %ebx
  80309f:	e8 45 f2 ff ff       	call   8022e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8030a4:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8030a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8030af:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8030b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8030ba:	83 c4 10             	add    $0x10,%esp
  8030bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8030c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030c5:	c9                   	leave  
  8030c6:	c3                   	ret    

008030c7 <devfile_write>:
{
  8030c7:	55                   	push   %ebp
  8030c8:	89 e5                	mov    %esp,%ebp
  8030ca:	83 ec 0c             	sub    $0xc,%esp
  8030cd:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8030d0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8030d5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8030da:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8030dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8030e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8030e3:	89 15 00 b0 80 00    	mov    %edx,0x80b000
    fsipcbuf.write.req_n = n;
  8030e9:	a3 04 b0 80 00       	mov    %eax,0x80b004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8030ee:	50                   	push   %eax
  8030ef:	ff 75 0c             	pushl  0xc(%ebp)
  8030f2:	68 08 b0 80 00       	push   $0x80b008
  8030f7:	e8 7b f3 ff ff       	call   802477 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8030fc:	ba 00 00 00 00       	mov    $0x0,%edx
  803101:	b8 04 00 00 00       	mov    $0x4,%eax
  803106:	e8 ca fe ff ff       	call   802fd5 <fsipc>
}
  80310b:	c9                   	leave  
  80310c:	c3                   	ret    

0080310d <devfile_read>:
{
  80310d:	55                   	push   %ebp
  80310e:	89 e5                	mov    %esp,%ebp
  803110:	56                   	push   %esi
  803111:	53                   	push   %ebx
  803112:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  803115:	8b 45 08             	mov    0x8(%ebp),%eax
  803118:	8b 40 0c             	mov    0xc(%eax),%eax
  80311b:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803120:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  803126:	ba 00 00 00 00       	mov    $0x0,%edx
  80312b:	b8 03 00 00 00       	mov    $0x3,%eax
  803130:	e8 a0 fe ff ff       	call   802fd5 <fsipc>
  803135:	89 c3                	mov    %eax,%ebx
  803137:	85 c0                	test   %eax,%eax
  803139:	78 1f                	js     80315a <devfile_read+0x4d>
	assert(r <= n);
  80313b:	39 f0                	cmp    %esi,%eax
  80313d:	77 24                	ja     803163 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80313f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803144:	7f 33                	jg     803179 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803146:	83 ec 04             	sub    $0x4,%esp
  803149:	50                   	push   %eax
  80314a:	68 00 b0 80 00       	push   $0x80b000
  80314f:	ff 75 0c             	pushl  0xc(%ebp)
  803152:	e8 20 f3 ff ff       	call   802477 <memmove>
	return r;
  803157:	83 c4 10             	add    $0x10,%esp
}
  80315a:	89 d8                	mov    %ebx,%eax
  80315c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80315f:	5b                   	pop    %ebx
  803160:	5e                   	pop    %esi
  803161:	5d                   	pop    %ebp
  803162:	c3                   	ret    
	assert(r <= n);
  803163:	68 a0 43 80 00       	push   $0x8043a0
  803168:	68 fd 39 80 00       	push   $0x8039fd
  80316d:	6a 7d                	push   $0x7d
  80316f:	68 a7 43 80 00       	push   $0x8043a7
  803174:	e8 76 ea ff ff       	call   801bef <_panic>
	assert(r <= PGSIZE);
  803179:	68 b2 43 80 00       	push   $0x8043b2
  80317e:	68 fd 39 80 00       	push   $0x8039fd
  803183:	6a 7e                	push   $0x7e
  803185:	68 a7 43 80 00       	push   $0x8043a7
  80318a:	e8 60 ea ff ff       	call   801bef <_panic>

0080318f <open>:
{
  80318f:	55                   	push   %ebp
  803190:	89 e5                	mov    %esp,%ebp
  803192:	56                   	push   %esi
  803193:	53                   	push   %ebx
  803194:	83 ec 1c             	sub    $0x1c,%esp
  803197:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80319a:	56                   	push   %esi
  80319b:	e8 12 f1 ff ff       	call   8022b2 <strlen>
  8031a0:	83 c4 10             	add    $0x10,%esp
  8031a3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8031a8:	0f 8f 96 00 00 00    	jg     803244 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8031ae:	83 ec 0c             	sub    $0xc,%esp
  8031b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031b4:	50                   	push   %eax
  8031b5:	e8 b0 f8 ff ff       	call   802a6a <fd_alloc>
  8031ba:	89 c3                	mov    %eax,%ebx
  8031bc:	83 c4 10             	add    $0x10,%esp
  8031bf:	85 c0                	test   %eax,%eax
  8031c1:	78 66                	js     803229 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8031c3:	83 ec 08             	sub    $0x8,%esp
  8031c6:	56                   	push   %esi
  8031c7:	68 00 b0 80 00       	push   $0x80b000
  8031cc:	e8 18 f1 ff ff       	call   8022e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8031d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031d4:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8031d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8031e1:	e8 ef fd ff ff       	call   802fd5 <fsipc>
  8031e6:	89 c3                	mov    %eax,%ebx
  8031e8:	83 c4 10             	add    $0x10,%esp
  8031eb:	85 c0                	test   %eax,%eax
  8031ed:	78 43                	js     803232 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  8031ef:	83 ec 0c             	sub    $0xc,%esp
  8031f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8031f5:	e8 49 f8 ff ff       	call   802a43 <fd2num>
  8031fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031fd:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  803203:	8b 49 48             	mov    0x48(%ecx),%ecx
  803206:	83 c4 08             	add    $0x8,%esp
  803209:	50                   	push   %eax
  80320a:	52                   	push   %edx
  80320b:	ff 32                	pushl  (%edx)
  80320d:	56                   	push   %esi
  80320e:	51                   	push   %ecx
  80320f:	68 c0 43 80 00       	push   $0x8043c0
  803214:	e8 b1 ea ff ff       	call   801cca <cprintf>
	return fd2num(fd);
  803219:	83 c4 14             	add    $0x14,%esp
  80321c:	ff 75 f4             	pushl  -0xc(%ebp)
  80321f:	e8 1f f8 ff ff       	call   802a43 <fd2num>
  803224:	89 c3                	mov    %eax,%ebx
  803226:	83 c4 10             	add    $0x10,%esp
}
  803229:	89 d8                	mov    %ebx,%eax
  80322b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80322e:	5b                   	pop    %ebx
  80322f:	5e                   	pop    %esi
  803230:	5d                   	pop    %ebp
  803231:	c3                   	ret    
		fd_close(fd, 0);
  803232:	83 ec 08             	sub    $0x8,%esp
  803235:	6a 00                	push   $0x0
  803237:	ff 75 f4             	pushl  -0xc(%ebp)
  80323a:	e8 26 f9 ff ff       	call   802b65 <fd_close>
		return r;
  80323f:	83 c4 10             	add    $0x10,%esp
  803242:	eb e5                	jmp    803229 <open+0x9a>
		return -E_BAD_PATH;
  803244:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  803249:	eb de                	jmp    803229 <open+0x9a>

0080324b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80324b:	55                   	push   %ebp
  80324c:	89 e5                	mov    %esp,%ebp
  80324e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803251:	ba 00 00 00 00       	mov    $0x0,%edx
  803256:	b8 08 00 00 00       	mov    $0x8,%eax
  80325b:	e8 75 fd ff ff       	call   802fd5 <fsipc>
}
  803260:	c9                   	leave  
  803261:	c3                   	ret    

00803262 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803262:	55                   	push   %ebp
  803263:	89 e5                	mov    %esp,%ebp
  803265:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803268:	89 d0                	mov    %edx,%eax
  80326a:	c1 e8 16             	shr    $0x16,%eax
  80326d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803274:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  803279:	f6 c1 01             	test   $0x1,%cl
  80327c:	74 1d                	je     80329b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80327e:	c1 ea 0c             	shr    $0xc,%edx
  803281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  803288:	f6 c2 01             	test   $0x1,%dl
  80328b:	74 0e                	je     80329b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80328d:	c1 ea 0c             	shr    $0xc,%edx
  803290:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  803297:	ef 
  803298:	0f b7 c0             	movzwl %ax,%eax
}
  80329b:	5d                   	pop    %ebp
  80329c:	c3                   	ret    

0080329d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80329d:	55                   	push   %ebp
  80329e:	89 e5                	mov    %esp,%ebp
  8032a0:	56                   	push   %esi
  8032a1:	53                   	push   %ebx
  8032a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8032a5:	83 ec 0c             	sub    $0xc,%esp
  8032a8:	ff 75 08             	pushl  0x8(%ebp)
  8032ab:	e8 a3 f7 ff ff       	call   802a53 <fd2data>
  8032b0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8032b2:	83 c4 08             	add    $0x8,%esp
  8032b5:	68 00 44 80 00       	push   $0x804400
  8032ba:	53                   	push   %ebx
  8032bb:	e8 29 f0 ff ff       	call   8022e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8032c0:	8b 46 04             	mov    0x4(%esi),%eax
  8032c3:	2b 06                	sub    (%esi),%eax
  8032c5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8032cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8032d2:	00 00 00 
	stat->st_dev = &devpipe;
  8032d5:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  8032dc:	90 80 00 
	return 0;
}
  8032df:	b8 00 00 00 00       	mov    $0x0,%eax
  8032e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032e7:	5b                   	pop    %ebx
  8032e8:	5e                   	pop    %esi
  8032e9:	5d                   	pop    %ebp
  8032ea:	c3                   	ret    

008032eb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8032eb:	55                   	push   %ebp
  8032ec:	89 e5                	mov    %esp,%ebp
  8032ee:	53                   	push   %ebx
  8032ef:	83 ec 0c             	sub    $0xc,%esp
  8032f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8032f5:	53                   	push   %ebx
  8032f6:	6a 00                	push   $0x0
  8032f8:	e8 6a f4 ff ff       	call   802767 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8032fd:	89 1c 24             	mov    %ebx,(%esp)
  803300:	e8 4e f7 ff ff       	call   802a53 <fd2data>
  803305:	83 c4 08             	add    $0x8,%esp
  803308:	50                   	push   %eax
  803309:	6a 00                	push   $0x0
  80330b:	e8 57 f4 ff ff       	call   802767 <sys_page_unmap>
}
  803310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803313:	c9                   	leave  
  803314:	c3                   	ret    

00803315 <_pipeisclosed>:
{
  803315:	55                   	push   %ebp
  803316:	89 e5                	mov    %esp,%ebp
  803318:	57                   	push   %edi
  803319:	56                   	push   %esi
  80331a:	53                   	push   %ebx
  80331b:	83 ec 1c             	sub    $0x1c,%esp
  80331e:	89 c7                	mov    %eax,%edi
  803320:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  803322:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803327:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80332a:	83 ec 0c             	sub    $0xc,%esp
  80332d:	57                   	push   %edi
  80332e:	e8 2f ff ff ff       	call   803262 <pageref>
  803333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803336:	89 34 24             	mov    %esi,(%esp)
  803339:	e8 24 ff ff ff       	call   803262 <pageref>
		nn = thisenv->env_runs;
  80333e:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803344:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803347:	83 c4 10             	add    $0x10,%esp
  80334a:	39 cb                	cmp    %ecx,%ebx
  80334c:	74 1b                	je     803369 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80334e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803351:	75 cf                	jne    803322 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803353:	8b 42 58             	mov    0x58(%edx),%eax
  803356:	6a 01                	push   $0x1
  803358:	50                   	push   %eax
  803359:	53                   	push   %ebx
  80335a:	68 07 44 80 00       	push   $0x804407
  80335f:	e8 66 e9 ff ff       	call   801cca <cprintf>
  803364:	83 c4 10             	add    $0x10,%esp
  803367:	eb b9                	jmp    803322 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  803369:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80336c:	0f 94 c0             	sete   %al
  80336f:	0f b6 c0             	movzbl %al,%eax
}
  803372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803375:	5b                   	pop    %ebx
  803376:	5e                   	pop    %esi
  803377:	5f                   	pop    %edi
  803378:	5d                   	pop    %ebp
  803379:	c3                   	ret    

0080337a <devpipe_write>:
{
  80337a:	55                   	push   %ebp
  80337b:	89 e5                	mov    %esp,%ebp
  80337d:	57                   	push   %edi
  80337e:	56                   	push   %esi
  80337f:	53                   	push   %ebx
  803380:	83 ec 28             	sub    $0x28,%esp
  803383:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  803386:	56                   	push   %esi
  803387:	e8 c7 f6 ff ff       	call   802a53 <fd2data>
  80338c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80338e:	83 c4 10             	add    $0x10,%esp
  803391:	bf 00 00 00 00       	mov    $0x0,%edi
  803396:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803399:	74 4f                	je     8033ea <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80339b:	8b 43 04             	mov    0x4(%ebx),%eax
  80339e:	8b 0b                	mov    (%ebx),%ecx
  8033a0:	8d 51 20             	lea    0x20(%ecx),%edx
  8033a3:	39 d0                	cmp    %edx,%eax
  8033a5:	72 14                	jb     8033bb <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8033a7:	89 da                	mov    %ebx,%edx
  8033a9:	89 f0                	mov    %esi,%eax
  8033ab:	e8 65 ff ff ff       	call   803315 <_pipeisclosed>
  8033b0:	85 c0                	test   %eax,%eax
  8033b2:	75 3a                	jne    8033ee <devpipe_write+0x74>
			sys_yield();
  8033b4:	e8 0a f3 ff ff       	call   8026c3 <sys_yield>
  8033b9:	eb e0                	jmp    80339b <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8033bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8033be:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8033c2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8033c5:	89 c2                	mov    %eax,%edx
  8033c7:	c1 fa 1f             	sar    $0x1f,%edx
  8033ca:	89 d1                	mov    %edx,%ecx
  8033cc:	c1 e9 1b             	shr    $0x1b,%ecx
  8033cf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8033d2:	83 e2 1f             	and    $0x1f,%edx
  8033d5:	29 ca                	sub    %ecx,%edx
  8033d7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8033db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8033df:	83 c0 01             	add    $0x1,%eax
  8033e2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8033e5:	83 c7 01             	add    $0x1,%edi
  8033e8:	eb ac                	jmp    803396 <devpipe_write+0x1c>
	return i;
  8033ea:	89 f8                	mov    %edi,%eax
  8033ec:	eb 05                	jmp    8033f3 <devpipe_write+0x79>
				return 0;
  8033ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8033f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033f6:	5b                   	pop    %ebx
  8033f7:	5e                   	pop    %esi
  8033f8:	5f                   	pop    %edi
  8033f9:	5d                   	pop    %ebp
  8033fa:	c3                   	ret    

008033fb <devpipe_read>:
{
  8033fb:	55                   	push   %ebp
  8033fc:	89 e5                	mov    %esp,%ebp
  8033fe:	57                   	push   %edi
  8033ff:	56                   	push   %esi
  803400:	53                   	push   %ebx
  803401:	83 ec 18             	sub    $0x18,%esp
  803404:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803407:	57                   	push   %edi
  803408:	e8 46 f6 ff ff       	call   802a53 <fd2data>
  80340d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80340f:	83 c4 10             	add    $0x10,%esp
  803412:	be 00 00 00 00       	mov    $0x0,%esi
  803417:	3b 75 10             	cmp    0x10(%ebp),%esi
  80341a:	74 47                	je     803463 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80341c:	8b 03                	mov    (%ebx),%eax
  80341e:	3b 43 04             	cmp    0x4(%ebx),%eax
  803421:	75 22                	jne    803445 <devpipe_read+0x4a>
			if (i > 0)
  803423:	85 f6                	test   %esi,%esi
  803425:	75 14                	jne    80343b <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  803427:	89 da                	mov    %ebx,%edx
  803429:	89 f8                	mov    %edi,%eax
  80342b:	e8 e5 fe ff ff       	call   803315 <_pipeisclosed>
  803430:	85 c0                	test   %eax,%eax
  803432:	75 33                	jne    803467 <devpipe_read+0x6c>
			sys_yield();
  803434:	e8 8a f2 ff ff       	call   8026c3 <sys_yield>
  803439:	eb e1                	jmp    80341c <devpipe_read+0x21>
				return i;
  80343b:	89 f0                	mov    %esi,%eax
}
  80343d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803440:	5b                   	pop    %ebx
  803441:	5e                   	pop    %esi
  803442:	5f                   	pop    %edi
  803443:	5d                   	pop    %ebp
  803444:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803445:	99                   	cltd   
  803446:	c1 ea 1b             	shr    $0x1b,%edx
  803449:	01 d0                	add    %edx,%eax
  80344b:	83 e0 1f             	and    $0x1f,%eax
  80344e:	29 d0                	sub    %edx,%eax
  803450:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803458:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80345b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80345e:	83 c6 01             	add    $0x1,%esi
  803461:	eb b4                	jmp    803417 <devpipe_read+0x1c>
	return i;
  803463:	89 f0                	mov    %esi,%eax
  803465:	eb d6                	jmp    80343d <devpipe_read+0x42>
				return 0;
  803467:	b8 00 00 00 00       	mov    $0x0,%eax
  80346c:	eb cf                	jmp    80343d <devpipe_read+0x42>

0080346e <pipe>:
{
  80346e:	55                   	push   %ebp
  80346f:	89 e5                	mov    %esp,%ebp
  803471:	56                   	push   %esi
  803472:	53                   	push   %ebx
  803473:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  803476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803479:	50                   	push   %eax
  80347a:	e8 eb f5 ff ff       	call   802a6a <fd_alloc>
  80347f:	89 c3                	mov    %eax,%ebx
  803481:	83 c4 10             	add    $0x10,%esp
  803484:	85 c0                	test   %eax,%eax
  803486:	78 5b                	js     8034e3 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803488:	83 ec 04             	sub    $0x4,%esp
  80348b:	68 07 04 00 00       	push   $0x407
  803490:	ff 75 f4             	pushl  -0xc(%ebp)
  803493:	6a 00                	push   $0x0
  803495:	e8 48 f2 ff ff       	call   8026e2 <sys_page_alloc>
  80349a:	89 c3                	mov    %eax,%ebx
  80349c:	83 c4 10             	add    $0x10,%esp
  80349f:	85 c0                	test   %eax,%eax
  8034a1:	78 40                	js     8034e3 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8034a3:	83 ec 0c             	sub    $0xc,%esp
  8034a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8034a9:	50                   	push   %eax
  8034aa:	e8 bb f5 ff ff       	call   802a6a <fd_alloc>
  8034af:	89 c3                	mov    %eax,%ebx
  8034b1:	83 c4 10             	add    $0x10,%esp
  8034b4:	85 c0                	test   %eax,%eax
  8034b6:	78 1b                	js     8034d3 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034b8:	83 ec 04             	sub    $0x4,%esp
  8034bb:	68 07 04 00 00       	push   $0x407
  8034c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8034c3:	6a 00                	push   $0x0
  8034c5:	e8 18 f2 ff ff       	call   8026e2 <sys_page_alloc>
  8034ca:	89 c3                	mov    %eax,%ebx
  8034cc:	83 c4 10             	add    $0x10,%esp
  8034cf:	85 c0                	test   %eax,%eax
  8034d1:	79 19                	jns    8034ec <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8034d3:	83 ec 08             	sub    $0x8,%esp
  8034d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8034d9:	6a 00                	push   $0x0
  8034db:	e8 87 f2 ff ff       	call   802767 <sys_page_unmap>
  8034e0:	83 c4 10             	add    $0x10,%esp
}
  8034e3:	89 d8                	mov    %ebx,%eax
  8034e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034e8:	5b                   	pop    %ebx
  8034e9:	5e                   	pop    %esi
  8034ea:	5d                   	pop    %ebp
  8034eb:	c3                   	ret    
	va = fd2data(fd0);
  8034ec:	83 ec 0c             	sub    $0xc,%esp
  8034ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8034f2:	e8 5c f5 ff ff       	call   802a53 <fd2data>
  8034f7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034f9:	83 c4 0c             	add    $0xc,%esp
  8034fc:	68 07 04 00 00       	push   $0x407
  803501:	50                   	push   %eax
  803502:	6a 00                	push   $0x0
  803504:	e8 d9 f1 ff ff       	call   8026e2 <sys_page_alloc>
  803509:	89 c3                	mov    %eax,%ebx
  80350b:	83 c4 10             	add    $0x10,%esp
  80350e:	85 c0                	test   %eax,%eax
  803510:	0f 88 8c 00 00 00    	js     8035a2 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803516:	83 ec 0c             	sub    $0xc,%esp
  803519:	ff 75 f0             	pushl  -0x10(%ebp)
  80351c:	e8 32 f5 ff ff       	call   802a53 <fd2data>
  803521:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803528:	50                   	push   %eax
  803529:	6a 00                	push   $0x0
  80352b:	56                   	push   %esi
  80352c:	6a 00                	push   $0x0
  80352e:	e8 f2 f1 ff ff       	call   802725 <sys_page_map>
  803533:	89 c3                	mov    %eax,%ebx
  803535:	83 c4 20             	add    $0x20,%esp
  803538:	85 c0                	test   %eax,%eax
  80353a:	78 58                	js     803594 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80353c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80353f:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803545:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803547:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80354a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  803551:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803554:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80355a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80355c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80355f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  803566:	83 ec 0c             	sub    $0xc,%esp
  803569:	ff 75 f4             	pushl  -0xc(%ebp)
  80356c:	e8 d2 f4 ff ff       	call   802a43 <fd2num>
  803571:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803574:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803576:	83 c4 04             	add    $0x4,%esp
  803579:	ff 75 f0             	pushl  -0x10(%ebp)
  80357c:	e8 c2 f4 ff ff       	call   802a43 <fd2num>
  803581:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803584:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803587:	83 c4 10             	add    $0x10,%esp
  80358a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80358f:	e9 4f ff ff ff       	jmp    8034e3 <pipe+0x75>
	sys_page_unmap(0, va);
  803594:	83 ec 08             	sub    $0x8,%esp
  803597:	56                   	push   %esi
  803598:	6a 00                	push   $0x0
  80359a:	e8 c8 f1 ff ff       	call   802767 <sys_page_unmap>
  80359f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8035a2:	83 ec 08             	sub    $0x8,%esp
  8035a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8035a8:	6a 00                	push   $0x0
  8035aa:	e8 b8 f1 ff ff       	call   802767 <sys_page_unmap>
  8035af:	83 c4 10             	add    $0x10,%esp
  8035b2:	e9 1c ff ff ff       	jmp    8034d3 <pipe+0x65>

008035b7 <pipeisclosed>:
{
  8035b7:	55                   	push   %ebp
  8035b8:	89 e5                	mov    %esp,%ebp
  8035ba:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8035c0:	50                   	push   %eax
  8035c1:	ff 75 08             	pushl  0x8(%ebp)
  8035c4:	e8 f0 f4 ff ff       	call   802ab9 <fd_lookup>
  8035c9:	83 c4 10             	add    $0x10,%esp
  8035cc:	85 c0                	test   %eax,%eax
  8035ce:	78 18                	js     8035e8 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8035d0:	83 ec 0c             	sub    $0xc,%esp
  8035d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8035d6:	e8 78 f4 ff ff       	call   802a53 <fd2data>
	return _pipeisclosed(fd, p);
  8035db:	89 c2                	mov    %eax,%edx
  8035dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035e0:	e8 30 fd ff ff       	call   803315 <_pipeisclosed>
  8035e5:	83 c4 10             	add    $0x10,%esp
}
  8035e8:	c9                   	leave  
  8035e9:	c3                   	ret    

008035ea <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8035ea:	55                   	push   %ebp
  8035eb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8035ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8035f2:	5d                   	pop    %ebp
  8035f3:	c3                   	ret    

008035f4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8035f4:	55                   	push   %ebp
  8035f5:	89 e5                	mov    %esp,%ebp
  8035f7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8035fa:	68 1f 44 80 00       	push   $0x80441f
  8035ff:	ff 75 0c             	pushl  0xc(%ebp)
  803602:	e8 e2 ec ff ff       	call   8022e9 <strcpy>
	return 0;
}
  803607:	b8 00 00 00 00       	mov    $0x0,%eax
  80360c:	c9                   	leave  
  80360d:	c3                   	ret    

0080360e <devcons_write>:
{
  80360e:	55                   	push   %ebp
  80360f:	89 e5                	mov    %esp,%ebp
  803611:	57                   	push   %edi
  803612:	56                   	push   %esi
  803613:	53                   	push   %ebx
  803614:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80361a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80361f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  803625:	eb 2f                	jmp    803656 <devcons_write+0x48>
		m = n - tot;
  803627:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80362a:	29 f3                	sub    %esi,%ebx
  80362c:	83 fb 7f             	cmp    $0x7f,%ebx
  80362f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  803634:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  803637:	83 ec 04             	sub    $0x4,%esp
  80363a:	53                   	push   %ebx
  80363b:	89 f0                	mov    %esi,%eax
  80363d:	03 45 0c             	add    0xc(%ebp),%eax
  803640:	50                   	push   %eax
  803641:	57                   	push   %edi
  803642:	e8 30 ee ff ff       	call   802477 <memmove>
		sys_cputs(buf, m);
  803647:	83 c4 08             	add    $0x8,%esp
  80364a:	53                   	push   %ebx
  80364b:	57                   	push   %edi
  80364c:	e8 d5 ef ff ff       	call   802626 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  803651:	01 de                	add    %ebx,%esi
  803653:	83 c4 10             	add    $0x10,%esp
  803656:	3b 75 10             	cmp    0x10(%ebp),%esi
  803659:	72 cc                	jb     803627 <devcons_write+0x19>
}
  80365b:	89 f0                	mov    %esi,%eax
  80365d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803660:	5b                   	pop    %ebx
  803661:	5e                   	pop    %esi
  803662:	5f                   	pop    %edi
  803663:	5d                   	pop    %ebp
  803664:	c3                   	ret    

00803665 <devcons_read>:
{
  803665:	55                   	push   %ebp
  803666:	89 e5                	mov    %esp,%ebp
  803668:	83 ec 08             	sub    $0x8,%esp
  80366b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  803670:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803674:	75 07                	jne    80367d <devcons_read+0x18>
}
  803676:	c9                   	leave  
  803677:	c3                   	ret    
		sys_yield();
  803678:	e8 46 f0 ff ff       	call   8026c3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80367d:	e8 c2 ef ff ff       	call   802644 <sys_cgetc>
  803682:	85 c0                	test   %eax,%eax
  803684:	74 f2                	je     803678 <devcons_read+0x13>
	if (c < 0)
  803686:	85 c0                	test   %eax,%eax
  803688:	78 ec                	js     803676 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80368a:	83 f8 04             	cmp    $0x4,%eax
  80368d:	74 0c                	je     80369b <devcons_read+0x36>
	*(char*)vbuf = c;
  80368f:	8b 55 0c             	mov    0xc(%ebp),%edx
  803692:	88 02                	mov    %al,(%edx)
	return 1;
  803694:	b8 01 00 00 00       	mov    $0x1,%eax
  803699:	eb db                	jmp    803676 <devcons_read+0x11>
		return 0;
  80369b:	b8 00 00 00 00       	mov    $0x0,%eax
  8036a0:	eb d4                	jmp    803676 <devcons_read+0x11>

008036a2 <cputchar>:
{
  8036a2:	55                   	push   %ebp
  8036a3:	89 e5                	mov    %esp,%ebp
  8036a5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8036a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ab:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8036ae:	6a 01                	push   $0x1
  8036b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036b3:	50                   	push   %eax
  8036b4:	e8 6d ef ff ff       	call   802626 <sys_cputs>
}
  8036b9:	83 c4 10             	add    $0x10,%esp
  8036bc:	c9                   	leave  
  8036bd:	c3                   	ret    

008036be <getchar>:
{
  8036be:	55                   	push   %ebp
  8036bf:	89 e5                	mov    %esp,%ebp
  8036c1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8036c4:	6a 01                	push   $0x1
  8036c6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8036c9:	50                   	push   %eax
  8036ca:	6a 00                	push   $0x0
  8036cc:	e8 59 f6 ff ff       	call   802d2a <read>
	if (r < 0)
  8036d1:	83 c4 10             	add    $0x10,%esp
  8036d4:	85 c0                	test   %eax,%eax
  8036d6:	78 08                	js     8036e0 <getchar+0x22>
	if (r < 1)
  8036d8:	85 c0                	test   %eax,%eax
  8036da:	7e 06                	jle    8036e2 <getchar+0x24>
	return c;
  8036dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8036e0:	c9                   	leave  
  8036e1:	c3                   	ret    
		return -E_EOF;
  8036e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8036e7:	eb f7                	jmp    8036e0 <getchar+0x22>

008036e9 <iscons>:
{
  8036e9:	55                   	push   %ebp
  8036ea:	89 e5                	mov    %esp,%ebp
  8036ec:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8036ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036f2:	50                   	push   %eax
  8036f3:	ff 75 08             	pushl  0x8(%ebp)
  8036f6:	e8 be f3 ff ff       	call   802ab9 <fd_lookup>
  8036fb:	83 c4 10             	add    $0x10,%esp
  8036fe:	85 c0                	test   %eax,%eax
  803700:	78 11                	js     803713 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  803702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803705:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80370b:	39 10                	cmp    %edx,(%eax)
  80370d:	0f 94 c0             	sete   %al
  803710:	0f b6 c0             	movzbl %al,%eax
}
  803713:	c9                   	leave  
  803714:	c3                   	ret    

00803715 <opencons>:
{
  803715:	55                   	push   %ebp
  803716:	89 e5                	mov    %esp,%ebp
  803718:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80371b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80371e:	50                   	push   %eax
  80371f:	e8 46 f3 ff ff       	call   802a6a <fd_alloc>
  803724:	83 c4 10             	add    $0x10,%esp
  803727:	85 c0                	test   %eax,%eax
  803729:	78 3a                	js     803765 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80372b:	83 ec 04             	sub    $0x4,%esp
  80372e:	68 07 04 00 00       	push   $0x407
  803733:	ff 75 f4             	pushl  -0xc(%ebp)
  803736:	6a 00                	push   $0x0
  803738:	e8 a5 ef ff ff       	call   8026e2 <sys_page_alloc>
  80373d:	83 c4 10             	add    $0x10,%esp
  803740:	85 c0                	test   %eax,%eax
  803742:	78 21                	js     803765 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  803744:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803747:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80374d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80374f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803752:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803759:	83 ec 0c             	sub    $0xc,%esp
  80375c:	50                   	push   %eax
  80375d:	e8 e1 f2 ff ff       	call   802a43 <fd2num>
  803762:	83 c4 10             	add    $0x10,%esp
}
  803765:	c9                   	leave  
  803766:	c3                   	ret    
  803767:	66 90                	xchg   %ax,%ax
  803769:	66 90                	xchg   %ax,%ax
  80376b:	66 90                	xchg   %ax,%ax
  80376d:	66 90                	xchg   %ax,%ax
  80376f:	90                   	nop

00803770 <__udivdi3>:
  803770:	55                   	push   %ebp
  803771:	57                   	push   %edi
  803772:	56                   	push   %esi
  803773:	53                   	push   %ebx
  803774:	83 ec 1c             	sub    $0x1c,%esp
  803777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80377b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80377f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803783:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  803787:	85 d2                	test   %edx,%edx
  803789:	75 35                	jne    8037c0 <__udivdi3+0x50>
  80378b:	39 f3                	cmp    %esi,%ebx
  80378d:	0f 87 bd 00 00 00    	ja     803850 <__udivdi3+0xe0>
  803793:	85 db                	test   %ebx,%ebx
  803795:	89 d9                	mov    %ebx,%ecx
  803797:	75 0b                	jne    8037a4 <__udivdi3+0x34>
  803799:	b8 01 00 00 00       	mov    $0x1,%eax
  80379e:	31 d2                	xor    %edx,%edx
  8037a0:	f7 f3                	div    %ebx
  8037a2:	89 c1                	mov    %eax,%ecx
  8037a4:	31 d2                	xor    %edx,%edx
  8037a6:	89 f0                	mov    %esi,%eax
  8037a8:	f7 f1                	div    %ecx
  8037aa:	89 c6                	mov    %eax,%esi
  8037ac:	89 e8                	mov    %ebp,%eax
  8037ae:	89 f7                	mov    %esi,%edi
  8037b0:	f7 f1                	div    %ecx
  8037b2:	89 fa                	mov    %edi,%edx
  8037b4:	83 c4 1c             	add    $0x1c,%esp
  8037b7:	5b                   	pop    %ebx
  8037b8:	5e                   	pop    %esi
  8037b9:	5f                   	pop    %edi
  8037ba:	5d                   	pop    %ebp
  8037bb:	c3                   	ret    
  8037bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8037c0:	39 f2                	cmp    %esi,%edx
  8037c2:	77 7c                	ja     803840 <__udivdi3+0xd0>
  8037c4:	0f bd fa             	bsr    %edx,%edi
  8037c7:	83 f7 1f             	xor    $0x1f,%edi
  8037ca:	0f 84 98 00 00 00    	je     803868 <__udivdi3+0xf8>
  8037d0:	89 f9                	mov    %edi,%ecx
  8037d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8037d7:	29 f8                	sub    %edi,%eax
  8037d9:	d3 e2                	shl    %cl,%edx
  8037db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8037df:	89 c1                	mov    %eax,%ecx
  8037e1:	89 da                	mov    %ebx,%edx
  8037e3:	d3 ea                	shr    %cl,%edx
  8037e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8037e9:	09 d1                	or     %edx,%ecx
  8037eb:	89 f2                	mov    %esi,%edx
  8037ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8037f1:	89 f9                	mov    %edi,%ecx
  8037f3:	d3 e3                	shl    %cl,%ebx
  8037f5:	89 c1                	mov    %eax,%ecx
  8037f7:	d3 ea                	shr    %cl,%edx
  8037f9:	89 f9                	mov    %edi,%ecx
  8037fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8037ff:	d3 e6                	shl    %cl,%esi
  803801:	89 eb                	mov    %ebp,%ebx
  803803:	89 c1                	mov    %eax,%ecx
  803805:	d3 eb                	shr    %cl,%ebx
  803807:	09 de                	or     %ebx,%esi
  803809:	89 f0                	mov    %esi,%eax
  80380b:	f7 74 24 08          	divl   0x8(%esp)
  80380f:	89 d6                	mov    %edx,%esi
  803811:	89 c3                	mov    %eax,%ebx
  803813:	f7 64 24 0c          	mull   0xc(%esp)
  803817:	39 d6                	cmp    %edx,%esi
  803819:	72 0c                	jb     803827 <__udivdi3+0xb7>
  80381b:	89 f9                	mov    %edi,%ecx
  80381d:	d3 e5                	shl    %cl,%ebp
  80381f:	39 c5                	cmp    %eax,%ebp
  803821:	73 5d                	jae    803880 <__udivdi3+0x110>
  803823:	39 d6                	cmp    %edx,%esi
  803825:	75 59                	jne    803880 <__udivdi3+0x110>
  803827:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80382a:	31 ff                	xor    %edi,%edi
  80382c:	89 fa                	mov    %edi,%edx
  80382e:	83 c4 1c             	add    $0x1c,%esp
  803831:	5b                   	pop    %ebx
  803832:	5e                   	pop    %esi
  803833:	5f                   	pop    %edi
  803834:	5d                   	pop    %ebp
  803835:	c3                   	ret    
  803836:	8d 76 00             	lea    0x0(%esi),%esi
  803839:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803840:	31 ff                	xor    %edi,%edi
  803842:	31 c0                	xor    %eax,%eax
  803844:	89 fa                	mov    %edi,%edx
  803846:	83 c4 1c             	add    $0x1c,%esp
  803849:	5b                   	pop    %ebx
  80384a:	5e                   	pop    %esi
  80384b:	5f                   	pop    %edi
  80384c:	5d                   	pop    %ebp
  80384d:	c3                   	ret    
  80384e:	66 90                	xchg   %ax,%ax
  803850:	31 ff                	xor    %edi,%edi
  803852:	89 e8                	mov    %ebp,%eax
  803854:	89 f2                	mov    %esi,%edx
  803856:	f7 f3                	div    %ebx
  803858:	89 fa                	mov    %edi,%edx
  80385a:	83 c4 1c             	add    $0x1c,%esp
  80385d:	5b                   	pop    %ebx
  80385e:	5e                   	pop    %esi
  80385f:	5f                   	pop    %edi
  803860:	5d                   	pop    %ebp
  803861:	c3                   	ret    
  803862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803868:	39 f2                	cmp    %esi,%edx
  80386a:	72 06                	jb     803872 <__udivdi3+0x102>
  80386c:	31 c0                	xor    %eax,%eax
  80386e:	39 eb                	cmp    %ebp,%ebx
  803870:	77 d2                	ja     803844 <__udivdi3+0xd4>
  803872:	b8 01 00 00 00       	mov    $0x1,%eax
  803877:	eb cb                	jmp    803844 <__udivdi3+0xd4>
  803879:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803880:	89 d8                	mov    %ebx,%eax
  803882:	31 ff                	xor    %edi,%edi
  803884:	eb be                	jmp    803844 <__udivdi3+0xd4>
  803886:	66 90                	xchg   %ax,%ax
  803888:	66 90                	xchg   %ax,%ax
  80388a:	66 90                	xchg   %ax,%ax
  80388c:	66 90                	xchg   %ax,%ax
  80388e:	66 90                	xchg   %ax,%ax

00803890 <__umoddi3>:
  803890:	55                   	push   %ebp
  803891:	57                   	push   %edi
  803892:	56                   	push   %esi
  803893:	53                   	push   %ebx
  803894:	83 ec 1c             	sub    $0x1c,%esp
  803897:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80389b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80389f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8038a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8038a7:	85 ed                	test   %ebp,%ebp
  8038a9:	89 f0                	mov    %esi,%eax
  8038ab:	89 da                	mov    %ebx,%edx
  8038ad:	75 19                	jne    8038c8 <__umoddi3+0x38>
  8038af:	39 df                	cmp    %ebx,%edi
  8038b1:	0f 86 b1 00 00 00    	jbe    803968 <__umoddi3+0xd8>
  8038b7:	f7 f7                	div    %edi
  8038b9:	89 d0                	mov    %edx,%eax
  8038bb:	31 d2                	xor    %edx,%edx
  8038bd:	83 c4 1c             	add    $0x1c,%esp
  8038c0:	5b                   	pop    %ebx
  8038c1:	5e                   	pop    %esi
  8038c2:	5f                   	pop    %edi
  8038c3:	5d                   	pop    %ebp
  8038c4:	c3                   	ret    
  8038c5:	8d 76 00             	lea    0x0(%esi),%esi
  8038c8:	39 dd                	cmp    %ebx,%ebp
  8038ca:	77 f1                	ja     8038bd <__umoddi3+0x2d>
  8038cc:	0f bd cd             	bsr    %ebp,%ecx
  8038cf:	83 f1 1f             	xor    $0x1f,%ecx
  8038d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8038d6:	0f 84 b4 00 00 00    	je     803990 <__umoddi3+0x100>
  8038dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8038e1:	89 c2                	mov    %eax,%edx
  8038e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8038e7:	29 c2                	sub    %eax,%edx
  8038e9:	89 c1                	mov    %eax,%ecx
  8038eb:	89 f8                	mov    %edi,%eax
  8038ed:	d3 e5                	shl    %cl,%ebp
  8038ef:	89 d1                	mov    %edx,%ecx
  8038f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8038f5:	d3 e8                	shr    %cl,%eax
  8038f7:	09 c5                	or     %eax,%ebp
  8038f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8038fd:	89 c1                	mov    %eax,%ecx
  8038ff:	d3 e7                	shl    %cl,%edi
  803901:	89 d1                	mov    %edx,%ecx
  803903:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803907:	89 df                	mov    %ebx,%edi
  803909:	d3 ef                	shr    %cl,%edi
  80390b:	89 c1                	mov    %eax,%ecx
  80390d:	89 f0                	mov    %esi,%eax
  80390f:	d3 e3                	shl    %cl,%ebx
  803911:	89 d1                	mov    %edx,%ecx
  803913:	89 fa                	mov    %edi,%edx
  803915:	d3 e8                	shr    %cl,%eax
  803917:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80391c:	09 d8                	or     %ebx,%eax
  80391e:	f7 f5                	div    %ebp
  803920:	d3 e6                	shl    %cl,%esi
  803922:	89 d1                	mov    %edx,%ecx
  803924:	f7 64 24 08          	mull   0x8(%esp)
  803928:	39 d1                	cmp    %edx,%ecx
  80392a:	89 c3                	mov    %eax,%ebx
  80392c:	89 d7                	mov    %edx,%edi
  80392e:	72 06                	jb     803936 <__umoddi3+0xa6>
  803930:	75 0e                	jne    803940 <__umoddi3+0xb0>
  803932:	39 c6                	cmp    %eax,%esi
  803934:	73 0a                	jae    803940 <__umoddi3+0xb0>
  803936:	2b 44 24 08          	sub    0x8(%esp),%eax
  80393a:	19 ea                	sbb    %ebp,%edx
  80393c:	89 d7                	mov    %edx,%edi
  80393e:	89 c3                	mov    %eax,%ebx
  803940:	89 ca                	mov    %ecx,%edx
  803942:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  803947:	29 de                	sub    %ebx,%esi
  803949:	19 fa                	sbb    %edi,%edx
  80394b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80394f:	89 d0                	mov    %edx,%eax
  803951:	d3 e0                	shl    %cl,%eax
  803953:	89 d9                	mov    %ebx,%ecx
  803955:	d3 ee                	shr    %cl,%esi
  803957:	d3 ea                	shr    %cl,%edx
  803959:	09 f0                	or     %esi,%eax
  80395b:	83 c4 1c             	add    $0x1c,%esp
  80395e:	5b                   	pop    %ebx
  80395f:	5e                   	pop    %esi
  803960:	5f                   	pop    %edi
  803961:	5d                   	pop    %ebp
  803962:	c3                   	ret    
  803963:	90                   	nop
  803964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803968:	85 ff                	test   %edi,%edi
  80396a:	89 f9                	mov    %edi,%ecx
  80396c:	75 0b                	jne    803979 <__umoddi3+0xe9>
  80396e:	b8 01 00 00 00       	mov    $0x1,%eax
  803973:	31 d2                	xor    %edx,%edx
  803975:	f7 f7                	div    %edi
  803977:	89 c1                	mov    %eax,%ecx
  803979:	89 d8                	mov    %ebx,%eax
  80397b:	31 d2                	xor    %edx,%edx
  80397d:	f7 f1                	div    %ecx
  80397f:	89 f0                	mov    %esi,%eax
  803981:	f7 f1                	div    %ecx
  803983:	e9 31 ff ff ff       	jmp    8038b9 <__umoddi3+0x29>
  803988:	90                   	nop
  803989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803990:	39 dd                	cmp    %ebx,%ebp
  803992:	72 08                	jb     80399c <__umoddi3+0x10c>
  803994:	39 f7                	cmp    %esi,%edi
  803996:	0f 87 21 ff ff ff    	ja     8038bd <__umoddi3+0x2d>
  80399c:	89 da                	mov    %ebx,%edx
  80399e:	89 f0                	mov    %esi,%eax
  8039a0:	29 f8                	sub    %edi,%eax
  8039a2:	19 ea                	sbb    %ebp,%edx
  8039a4:	e9 14 ff ff ff       	jmp    8038bd <__umoddi3+0x2d>
