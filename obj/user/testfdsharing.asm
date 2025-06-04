
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 9b 01 00 00       	call   8001cc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 60 23 80 00       	push   $0x802360
  800043:	e8 8f 19 00 00       	call   8019d7 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	0f 88 01 01 00 00    	js     800156 <umain+0x123>
		panic("open motd: %e", fd);
	seek(fd, 0);
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	6a 00                	push   $0x0
  80005a:	50                   	push   %eax
  80005b:	e8 62 16 00 00       	call   8016c2 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800060:	83 c4 0c             	add    $0xc,%esp
  800063:	68 00 02 00 00       	push   $0x200
  800068:	68 20 42 80 00       	push   $0x804220
  80006d:	53                   	push   %ebx
  80006e:	e8 86 15 00 00       	call   8015f9 <readn>
  800073:	89 c6                	mov    %eax,%esi
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	85 c0                	test   %eax,%eax
  80007a:	0f 8e e8 00 00 00    	jle    800168 <umain+0x135>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800080:	e8 91 10 00 00       	call   801116 <fork>
  800085:	89 c7                	mov    %eax,%edi
  800087:	85 c0                	test   %eax,%eax
  800089:	0f 88 eb 00 00 00    	js     80017a <umain+0x147>
		panic("fork: %e", r);
	if (r == 0) {
  80008f:	85 c0                	test   %eax,%eax
  800091:	75 7b                	jne    80010e <umain+0xdb>
		seek(fd, 0);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	6a 00                	push   $0x0
  800098:	53                   	push   %ebx
  800099:	e8 24 16 00 00       	call   8016c2 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  80009e:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  8000a5:	e8 5d 02 00 00       	call   800307 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 02 00 00       	push   $0x200
  8000b2:	68 20 40 80 00       	push   $0x804020
  8000b7:	53                   	push   %ebx
  8000b8:	e8 3c 15 00 00       	call   8015f9 <readn>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	39 c6                	cmp    %eax,%esi
  8000c2:	0f 85 c4 00 00 00    	jne    80018c <umain+0x159>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000c8:	83 ec 04             	sub    $0x4,%esp
  8000cb:	56                   	push   %esi
  8000cc:	68 20 40 80 00       	push   $0x804020
  8000d1:	68 20 42 80 00       	push   $0x804220
  8000d6:	e8 54 0a 00 00       	call   800b2f <memcmp>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	85 c0                	test   %eax,%eax
  8000e0:	0f 85 bc 00 00 00    	jne    8001a2 <umain+0x16f>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	68 9b 23 80 00       	push   $0x80239b
  8000ee:	e8 14 02 00 00       	call   800307 <cprintf>
		seek(fd, 0);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6a 00                	push   $0x0
  8000f8:	53                   	push   %ebx
  8000f9:	e8 c4 15 00 00       	call   8016c2 <seek>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 30 13 00 00       	call   801436 <close>
		exit();
  800106:	e8 07 01 00 00       	call   800212 <exit>
  80010b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	57                   	push   %edi
  800112:	e8 e0 1c 00 00       	call   801df7 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800117:	83 c4 0c             	add    $0xc,%esp
  80011a:	68 00 02 00 00       	push   $0x200
  80011f:	68 20 40 80 00       	push   $0x804020
  800124:	53                   	push   %ebx
  800125:	e8 cf 14 00 00       	call   8015f9 <readn>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	39 c6                	cmp    %eax,%esi
  80012f:	0f 85 81 00 00 00    	jne    8001b6 <umain+0x183>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	68 b4 23 80 00       	push   $0x8023b4
  80013d:	e8 c5 01 00 00       	call   800307 <cprintf>
	close(fd);
  800142:	89 1c 24             	mov    %ebx,(%esp)
  800145:	e8 ec 12 00 00       	call   801436 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80014a:	cc                   	int3   

	breakpoint();
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    
		panic("open motd: %e", fd);
  800156:	50                   	push   %eax
  800157:	68 65 23 80 00       	push   $0x802365
  80015c:	6a 0c                	push   $0xc
  80015e:	68 73 23 80 00       	push   $0x802373
  800163:	e8 c4 00 00 00       	call   80022c <_panic>
		panic("readn: %e", n);
  800168:	50                   	push   %eax
  800169:	68 88 23 80 00       	push   $0x802388
  80016e:	6a 0f                	push   $0xf
  800170:	68 73 23 80 00       	push   $0x802373
  800175:	e8 b2 00 00 00       	call   80022c <_panic>
		panic("fork: %e", r);
  80017a:	50                   	push   %eax
  80017b:	68 92 23 80 00       	push   $0x802392
  800180:	6a 12                	push   $0x12
  800182:	68 73 23 80 00       	push   $0x802373
  800187:	e8 a0 00 00 00       	call   80022c <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	56                   	push   %esi
  800191:	68 14 24 80 00       	push   $0x802414
  800196:	6a 17                	push   $0x17
  800198:	68 73 23 80 00       	push   $0x802373
  80019d:	e8 8a 00 00 00       	call   80022c <_panic>
			panic("read in parent got different bytes from read in child");
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	68 40 24 80 00       	push   $0x802440
  8001aa:	6a 19                	push   $0x19
  8001ac:	68 73 23 80 00       	push   $0x802373
  8001b1:	e8 76 00 00 00       	call   80022c <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	50                   	push   %eax
  8001ba:	56                   	push   %esi
  8001bb:	68 78 24 80 00       	push   $0x802478
  8001c0:	6a 21                	push   $0x21
  8001c2:	68 73 23 80 00       	push   $0x802373
  8001c7:	e8 60 00 00 00       	call   80022c <_panic>

008001cc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001d7:	e8 05 0b 00 00       	call   800ce1 <sys_getenvid>
  8001dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e9:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7e 07                	jle    8001f9 <libmain+0x2d>
		binaryname = argv[0];
  8001f2:	8b 06                	mov    (%esi),%eax
  8001f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	e8 30 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800203:	e8 0a 00 00 00       	call   800212 <exit>
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800218:	e8 44 12 00 00       	call   801461 <close_all>
	sys_env_destroy(0);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	6a 00                	push   $0x0
  800222:	e8 79 0a 00 00       	call   800ca0 <sys_env_destroy>
}
  800227:	83 c4 10             	add    $0x10,%esp
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800231:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800234:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023a:	e8 a2 0a 00 00       	call   800ce1 <sys_getenvid>
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	ff 75 08             	pushl  0x8(%ebp)
  800248:	56                   	push   %esi
  800249:	50                   	push   %eax
  80024a:	68 a8 24 80 00       	push   $0x8024a8
  80024f:	e8 b3 00 00 00       	call   800307 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800254:	83 c4 18             	add    $0x18,%esp
  800257:	53                   	push   %ebx
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	e8 56 00 00 00       	call   8002b6 <vcprintf>
	cprintf("\n");
  800260:	c7 04 24 b2 23 80 00 	movl   $0x8023b2,(%esp)
  800267:	e8 9b 00 00 00       	call   800307 <cprintf>
  80026c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026f:	cc                   	int3   
  800270:	eb fd                	jmp    80026f <_panic+0x43>

00800272 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	53                   	push   %ebx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027c:	8b 13                	mov    (%ebx),%edx
  80027e:	8d 42 01             	lea    0x1(%edx),%eax
  800281:	89 03                	mov    %eax,(%ebx)
  800283:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800286:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028f:	74 09                	je     80029a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800291:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	68 ff 00 00 00       	push   $0xff
  8002a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a5:	50                   	push   %eax
  8002a6:	e8 b8 09 00 00       	call   800c63 <sys_cputs>
		b->idx = 0;
  8002ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	eb db                	jmp    800291 <putch+0x1f>

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 72 02 80 00       	push   $0x800272
  8002e5:	e8 1a 01 00 00       	call   800404 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ea:	83 c4 08             	add    $0x8,%esp
  8002ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 64 09 00 00       	call   800c63 <sys_cputs>

	return b.cnt;
}
  8002ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800310:	50                   	push   %eax
  800311:	ff 75 08             	pushl  0x8(%ebp)
  800314:	e8 9d ff ff ff       	call   8002b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 1c             	sub    $0x1c,%esp
  800324:	89 c7                	mov    %eax,%edi
  800326:	89 d6                	mov    %edx,%esi
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800331:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800334:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800337:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80033f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800342:	39 d3                	cmp    %edx,%ebx
  800344:	72 05                	jb     80034b <printnum+0x30>
  800346:	39 45 10             	cmp    %eax,0x10(%ebp)
  800349:	77 7a                	ja     8003c5 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	ff 75 18             	pushl  0x18(%ebp)
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800361:	ff 75 e0             	pushl  -0x20(%ebp)
  800364:	ff 75 dc             	pushl  -0x24(%ebp)
  800367:	ff 75 d8             	pushl  -0x28(%ebp)
  80036a:	e8 a1 1d 00 00       	call   802110 <__udivdi3>
  80036f:	83 c4 18             	add    $0x18,%esp
  800372:	52                   	push   %edx
  800373:	50                   	push   %eax
  800374:	89 f2                	mov    %esi,%edx
  800376:	89 f8                	mov    %edi,%eax
  800378:	e8 9e ff ff ff       	call   80031b <printnum>
  80037d:	83 c4 20             	add    $0x20,%esp
  800380:	eb 13                	jmp    800395 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	56                   	push   %esi
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	ff d7                	call   *%edi
  80038b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038e:	83 eb 01             	sub    $0x1,%ebx
  800391:	85 db                	test   %ebx,%ebx
  800393:	7f ed                	jg     800382 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	56                   	push   %esi
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80039f:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8003a8:	e8 83 1e 00 00       	call   802230 <__umoddi3>
  8003ad:	83 c4 14             	add    $0x14,%esp
  8003b0:	0f be 80 cb 24 80 00 	movsbl 0x8024cb(%eax),%eax
  8003b7:	50                   	push   %eax
  8003b8:	ff d7                	call   *%edi
}
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    
  8003c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c8:	eb c4                	jmp    80038e <printnum+0x73>

008003ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d9:	73 0a                	jae    8003e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003de:	89 08                	mov    %ecx,(%eax)
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	88 02                	mov    %al,(%edx)
}
  8003e5:	5d                   	pop    %ebp
  8003e6:	c3                   	ret    

008003e7 <printfmt>:
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f0:	50                   	push   %eax
  8003f1:	ff 75 10             	pushl  0x10(%ebp)
  8003f4:	ff 75 0c             	pushl  0xc(%ebp)
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 05 00 00 00       	call   800404 <vprintfmt>
}
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <vprintfmt>:
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 2c             	sub    $0x2c,%esp
  80040d:	8b 75 08             	mov    0x8(%ebp),%esi
  800410:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800413:	8b 7d 10             	mov    0x10(%ebp),%edi
  800416:	e9 c1 03 00 00       	jmp    8007dc <vprintfmt+0x3d8>
		padc = ' ';
  80041b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80041f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80042d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800434:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8d 47 01             	lea    0x1(%edi),%eax
  80043c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043f:	0f b6 17             	movzbl (%edi),%edx
  800442:	8d 42 dd             	lea    -0x23(%edx),%eax
  800445:	3c 55                	cmp    $0x55,%al
  800447:	0f 87 12 04 00 00    	ja     80085f <vprintfmt+0x45b>
  80044d:	0f b6 c0             	movzbl %al,%eax
  800450:	ff 24 85 00 26 80 00 	jmp    *0x802600(,%eax,4)
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80045a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80045e:	eb d9                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800463:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800467:	eb d0                	jmp    800439 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800469:	0f b6 d2             	movzbl %dl,%edx
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800477:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80047e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800481:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800484:	83 f9 09             	cmp    $0x9,%ecx
  800487:	77 55                	ja     8004de <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800489:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80048c:	eb e9                	jmp    800477 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 00                	mov    (%eax),%eax
  800493:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 40 04             	lea    0x4(%eax),%eax
  80049c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	79 91                	jns    800439 <vprintfmt+0x35>
				width = precision, precision = -1;
  8004a8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b5:	eb 82                	jmp    800439 <vprintfmt+0x35>
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 49 d0             	cmovns %eax,%edx
  8004c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ca:	e9 6a ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d9:	e9 5b ff ff ff       	jmp    800439 <vprintfmt+0x35>
  8004de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e4:	eb bc                	jmp    8004a2 <vprintfmt+0x9e>
			lflag++;
  8004e6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ec:	e9 48 ff ff ff       	jmp    800439 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 78 04             	lea    0x4(%eax),%edi
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800502:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800505:	e9 cf 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 78 04             	lea    0x4(%eax),%edi
  800510:	8b 00                	mov    (%eax),%eax
  800512:	99                   	cltd   
  800513:	31 d0                	xor    %edx,%eax
  800515:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800517:	83 f8 0f             	cmp    $0xf,%eax
  80051a:	7f 23                	jg     80053f <vprintfmt+0x13b>
  80051c:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800527:	52                   	push   %edx
  800528:	68 d5 29 80 00       	push   $0x8029d5
  80052d:	53                   	push   %ebx
  80052e:	56                   	push   %esi
  80052f:	e8 b3 fe ff ff       	call   8003e7 <printfmt>
  800534:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800537:	89 7d 14             	mov    %edi,0x14(%ebp)
  80053a:	e9 9a 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80053f:	50                   	push   %eax
  800540:	68 e3 24 80 00       	push   $0x8024e3
  800545:	53                   	push   %ebx
  800546:	56                   	push   %esi
  800547:	e8 9b fe ff ff       	call   8003e7 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800552:	e9 82 02 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	83 c0 04             	add    $0x4,%eax
  80055d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 dc 24 80 00       	mov    $0x8024dc,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e bd 00 00 00    	jle    800636 <vprintfmt+0x232>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	75 0e                	jne    80058d <vprintfmt+0x189>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	eb 6d                	jmp    8005fa <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 d0             	pushl  -0x30(%ebp)
  800593:	57                   	push   %edi
  800594:	e8 6e 03 00 00       	call   800907 <strnlen>
  800599:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059c:	29 c1                	sub    %eax,%ecx
  80059e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ae:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b0:	eb 0f                	jmp    8005c1 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	83 ef 01             	sub    $0x1,%edi
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	7f ed                	jg     8005b2 <vprintfmt+0x1ae>
  8005c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d2:	0f 49 c1             	cmovns %ecx,%eax
  8005d5:	29 c1                	sub    %eax,%ecx
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	89 cb                	mov    %ecx,%ebx
  8005e2:	eb 16                	jmp    8005fa <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	75 31                	jne    80061b <vprintfmt+0x217>
					putch(ch, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	50                   	push   %eax
  8005f1:	ff 55 08             	call   *0x8(%ebp)
  8005f4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f7:	83 eb 01             	sub    $0x1,%ebx
  8005fa:	83 c7 01             	add    $0x1,%edi
  8005fd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800601:	0f be c2             	movsbl %dl,%eax
  800604:	85 c0                	test   %eax,%eax
  800606:	74 59                	je     800661 <vprintfmt+0x25d>
  800608:	85 f6                	test   %esi,%esi
  80060a:	78 d8                	js     8005e4 <vprintfmt+0x1e0>
  80060c:	83 ee 01             	sub    $0x1,%esi
  80060f:	79 d3                	jns    8005e4 <vprintfmt+0x1e0>
  800611:	89 df                	mov    %ebx,%edi
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800619:	eb 37                	jmp    800652 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80061b:	0f be d2             	movsbl %dl,%edx
  80061e:	83 ea 20             	sub    $0x20,%edx
  800621:	83 fa 5e             	cmp    $0x5e,%edx
  800624:	76 c4                	jbe    8005ea <vprintfmt+0x1e6>
					putch('?', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	ff 75 0c             	pushl  0xc(%ebp)
  80062c:	6a 3f                	push   $0x3f
  80062e:	ff 55 08             	call   *0x8(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb c1                	jmp    8005f7 <vprintfmt+0x1f3>
  800636:	89 75 08             	mov    %esi,0x8(%ebp)
  800639:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800642:	eb b6                	jmp    8005fa <vprintfmt+0x1f6>
				putch(' ', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 20                	push   $0x20
  80064a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80064c:	83 ef 01             	sub    $0x1,%edi
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	85 ff                	test   %edi,%edi
  800654:	7f ee                	jg     800644 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800656:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
  80065c:	e9 78 01 00 00       	jmp    8007d9 <vprintfmt+0x3d5>
  800661:	89 df                	mov    %ebx,%edi
  800663:	8b 75 08             	mov    0x8(%ebp),%esi
  800666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800669:	eb e7                	jmp    800652 <vprintfmt+0x24e>
	if (lflag >= 2)
  80066b:	83 f9 01             	cmp    $0x1,%ecx
  80066e:	7e 3f                	jle    8006af <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 50 04             	mov    0x4(%eax),%edx
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 40 08             	lea    0x8(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800687:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068b:	79 5c                	jns    8006e9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 2d                	push   $0x2d
  800693:	ff d6                	call   *%esi
				num = -(long long) num;
  800695:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800698:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069b:	f7 da                	neg    %edx
  80069d:	83 d1 00             	adc    $0x0,%ecx
  8006a0:	f7 d9                	neg    %ecx
  8006a2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006aa:	e9 10 01 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	75 1b                	jne    8006ce <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bb:	89 c1                	mov    %eax,%ecx
  8006bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006cc:	eb b9                	jmp    800687 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 c1                	mov    %eax,%ecx
  8006d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 40 04             	lea    0x4(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e7:	eb 9e                	jmp    800687 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006e9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f4:	e9 c6 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006f9:	83 f9 01             	cmp    $0x1,%ecx
  8006fc:	7e 18                	jle    800716 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	8b 48 04             	mov    0x4(%eax),%ecx
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800711:	e9 a9 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800716:	85 c9                	test   %ecx,%ecx
  800718:	75 1a                	jne    800734 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 8b 00 00 00       	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 74                	jmp    8007bf <vprintfmt+0x3bb>
	if (lflag >= 2)
  80074b:	83 f9 01             	cmp    $0x1,%ecx
  80074e:	7e 15                	jle    800765 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	8b 48 04             	mov    0x4(%eax),%ecx
  800758:	8d 40 08             	lea    0x8(%eax),%eax
  80075b:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80075e:	b8 08 00 00 00       	mov    $0x8,%eax
  800763:	eb 5a                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  800765:	85 c9                	test   %ecx,%ecx
  800767:	75 17                	jne    800780 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8b 10                	mov    (%eax),%edx
  80076e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800779:	b8 08 00 00 00       	mov    $0x8,%eax
  80077e:	eb 3f                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 10                	mov    (%eax),%edx
  800785:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078a:	8d 40 04             	lea    0x4(%eax),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800790:	b8 08 00 00 00       	mov    $0x8,%eax
  800795:	eb 28                	jmp    8007bf <vprintfmt+0x3bb>
			putch('0', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 30                	push   $0x30
  80079d:	ff d6                	call   *%esi
			putch('x', putdat);
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 78                	push   $0x78
  8007a5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007b4:	8d 40 04             	lea    0x4(%eax),%eax
  8007b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007bf:	83 ec 0c             	sub    $0xc,%esp
  8007c2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c6:	57                   	push   %edi
  8007c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ca:	50                   	push   %eax
  8007cb:	51                   	push   %ecx
  8007cc:	52                   	push   %edx
  8007cd:	89 da                	mov    %ebx,%edx
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	e8 45 fb ff ff       	call   80031b <printnum>
			break;
  8007d6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007dc:	83 c7 01             	add    $0x1,%edi
  8007df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e3:	83 f8 25             	cmp    $0x25,%eax
  8007e6:	0f 84 2f fc ff ff    	je     80041b <vprintfmt+0x17>
			if (ch == '\0')
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	0f 84 8b 00 00 00    	je     80087f <vprintfmt+0x47b>
			putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	53                   	push   %ebx
  8007f8:	50                   	push   %eax
  8007f9:	ff d6                	call   *%esi
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb dc                	jmp    8007dc <vprintfmt+0x3d8>
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7e 15                	jle    80081a <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	8b 48 04             	mov    0x4(%eax),%ecx
  80080d:	8d 40 08             	lea    0x8(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
  800818:	eb a5                	jmp    8007bf <vprintfmt+0x3bb>
	else if (lflag)
  80081a:	85 c9                	test   %ecx,%ecx
  80081c:	75 17                	jne    800835 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082e:	b8 10 00 00 00       	mov    $0x10,%eax
  800833:	eb 8a                	jmp    8007bf <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800845:	b8 10 00 00 00       	mov    $0x10,%eax
  80084a:	e9 70 ff ff ff       	jmp    8007bf <vprintfmt+0x3bb>
			putch(ch, putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 25                	push   $0x25
  800855:	ff d6                	call   *%esi
			break;
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	e9 7a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
			putch('%', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 25                	push   $0x25
  800865:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	89 f8                	mov    %edi,%eax
  80086c:	eb 03                	jmp    800871 <vprintfmt+0x46d>
  80086e:	83 e8 01             	sub    $0x1,%eax
  800871:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800875:	75 f7                	jne    80086e <vprintfmt+0x46a>
  800877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087a:	e9 5a ff ff ff       	jmp    8007d9 <vprintfmt+0x3d5>
}
  80087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5f                   	pop    %edi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 26                	je     8008ce <vsnprintf+0x47>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 22                	jle    8008ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	ff 75 14             	pushl  0x14(%ebp)
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	68 ca 03 80 00       	push   $0x8003ca
  8008bb:	e8 44 fb ff ff       	call   800404 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c9:	83 c4 10             	add    $0x10,%esp
}
  8008cc:	c9                   	leave  
  8008cd:	c3                   	ret    
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d3:	eb f7                	jmp    8008cc <vsnprintf+0x45>

008008d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008de:	50                   	push   %eax
  8008df:	ff 75 10             	pushl  0x10(%ebp)
  8008e2:	ff 75 0c             	pushl  0xc(%ebp)
  8008e5:	ff 75 08             	pushl  0x8(%ebp)
  8008e8:	e8 9a ff ff ff       	call   800887 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ed:	c9                   	leave  
  8008ee:	c3                   	ret    

008008ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 03                	jmp    8008ff <strlen+0x10>
		n++;
  8008fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800903:	75 f7                	jne    8008fc <strlen+0xd>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 03                	jmp    80091a <strnlen+0x13>
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	74 06                	je     800924 <strnlen+0x1d>
  80091e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800922:	75 f3                	jne    800917 <strnlen+0x10>
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800930:	89 c2                	mov    %eax,%edx
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093f:	84 db                	test   %bl,%bl
  800941:	75 ef                	jne    800932 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094d:	53                   	push   %ebx
  80094e:	e8 9c ff ff ff       	call   8008ef <strlen>
  800953:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	01 d8                	add    %ebx,%eax
  80095b:	50                   	push   %eax
  80095c:	e8 c5 ff ff ff       	call   800926 <strcpy>
	return dst;
}
  800961:	89 d8                	mov    %ebx,%eax
  800963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800973:	89 f3                	mov    %esi,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	89 f2                	mov    %esi,%edx
  80097a:	eb 0f                	jmp    80098b <strncpy+0x23>
		*dst++ = *src;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800985:	80 39 01             	cmpb   $0x1,(%ecx)
  800988:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 ed                	jne    80097c <strncpy+0x14>
	}
	return ret;
}
  80098f:	89 f0                	mov    %esi,%eax
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	75 0b                	jne    8009b8 <strlcpy+0x23>
  8009ad:	eb 17                	jmp    8009c6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009af:	83 c2 01             	add    $0x1,%edx
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	74 07                	je     8009c3 <strlcpy+0x2e>
  8009bc:	0f b6 0a             	movzbl (%edx),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	75 ec                	jne    8009af <strlcpy+0x1a>
		*dst = '\0';
  8009c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c6:	29 f0                	sub    %esi,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strcmp+0x11>
		p++, q++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 04                	je     8009e8 <strcmp+0x1c>
  8009e4:	3a 02                	cmp    (%edx),%al
  8009e6:	74 ef                	je     8009d7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 c0             	movzbl %al,%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a01:	eb 06                	jmp    800a09 <strncmp+0x17>
		n--, p++, q++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a09:	39 d8                	cmp    %ebx,%eax
  800a0b:	74 16                	je     800a23 <strncmp+0x31>
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 04                	je     800a18 <strncmp+0x26>
  800a14:	3a 0a                	cmp    (%edx),%cl
  800a16:	74 eb                	je     800a03 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
		return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb f6                	jmp    800a20 <strncmp+0x2e>

00800a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	74 09                	je     800a44 <strchr+0x1a>
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 0a                	je     800a49 <strchr+0x1f>
	for (; *s; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	eb f0                	jmp    800a34 <strchr+0xa>
			return (char *) s;
	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 03                	jmp    800a5a <strfind+0xf>
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 04                	je     800a65 <strfind+0x1a>
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strfind+0xc>
			break;
	return (char *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	74 13                	je     800a8a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 05                	jne    800a84 <memset+0x1d>
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	74 0d                	je     800a91 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	fc                   	cld    
  800a88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8a:	89 f8                	mov    %edi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    
		c &= 0xFF;
  800a91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e0 18             	shl    $0x18,%eax
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	c1 e6 10             	shl    $0x10,%esi
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aad:	89 d0                	mov    %edx,%eax
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb d6                	jmp    800a8a <memset+0x23>

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 35                	jae    800afb <memmove+0x47>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 c2                	cmp    %eax,%edx
  800acb:	76 2e                	jbe    800afb <memmove+0x47>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	09 fe                	or     %edi,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	74 0c                	je     800ae8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adc:	83 ef 01             	sub    $0x1,%edi
  800adf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae2:	fd                   	std    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae5:	fc                   	cld    
  800ae6:	eb 21                	jmp    800b09 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 ef                	jne    800adc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aed:	83 ef 04             	sub    $0x4,%edi
  800af0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af6:	fd                   	std    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb ea                	jmp    800ae5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	89 f2                	mov    %esi,%edx
  800afd:	09 c2                	or     %eax,%edx
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	74 09                	je     800b0d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0d:	f6 c1 03             	test   $0x3,%cl
  800b10:	75 f2                	jne    800b04 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb ed                	jmp    800b09 <memmove+0x55>

00800b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1f:	ff 75 10             	pushl  0x10(%ebp)
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	ff 75 08             	pushl  0x8(%ebp)
  800b28:	e8 87 ff ff ff       	call   800ab4 <memmove>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	89 c6                	mov    %eax,%esi
  800b3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 f0                	cmp    %esi,%eax
  800b41:	74 1c                	je     800b5f <memcmp+0x30>
		if (*s1 != *s2)
  800b43:	0f b6 08             	movzbl (%eax),%ecx
  800b46:	0f b6 1a             	movzbl (%edx),%ebx
  800b49:	38 d9                	cmp    %bl,%cl
  800b4b:	75 08                	jne    800b55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	eb ea                	jmp    800b3f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c1             	movzbl %cl,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 05                	jmp    800b64 <memcmp+0x35>
	}

	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 09                	jae    800b83 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	74 05                	je     800b83 <memfind+0x1b>
	for (; s < ends; s++)
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	eb f3                	jmp    800b76 <memfind+0xe>
			break;
	return (void *) s;
}
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b91:	eb 03                	jmp    800b96 <strtol+0x11>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b96:	0f b6 01             	movzbl (%ecx),%eax
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f6                	je     800b93 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f2                	je     800b93 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	74 2e                	je     800bd3 <strtol+0x4e>
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	74 2f                	je     800bdd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb4:	75 05                	jne    800bbb <strtol+0x36>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	74 2c                	je     800be7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbb:	85 db                	test   %ebx,%ebx
  800bbd:	75 0a                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	74 28                	je     800bf1 <strtol+0x6c>
		base = 10;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd1:	eb 50                	jmp    800c23 <strtol+0x9e>
		s++;
  800bd3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdb:	eb d1                	jmp    800bae <strtol+0x29>
		s++, neg = 1;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb c7                	jmp    800bae <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800beb:	74 0e                	je     800bfb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bed:	85 db                	test   %ebx,%ebx
  800bef:	75 d8                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf9:	eb ce                	jmp    800bc9 <strtol+0x44>
		s += 2, base = 16;
  800bfb:	83 c1 02             	add    $0x2,%ecx
  800bfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c03:	eb c4                	jmp    800bc9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c08:	89 f3                	mov    %esi,%ebx
  800c0a:	80 fb 19             	cmp    $0x19,%bl
  800c0d:	77 29                	ja     800c38 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c0f:	0f be d2             	movsbl %dl,%edx
  800c12:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c18:	7d 30                	jge    800c4a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c21:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c29:	89 f3                	mov    %esi,%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 d5                	ja     800c05 <strtol+0x80>
			dig = *s - '0';
  800c30:	0f be d2             	movsbl %dl,%edx
  800c33:	83 ea 30             	sub    $0x30,%edx
  800c36:	eb dd                	jmp    800c15 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 37             	sub    $0x37,%edx
  800c48:	eb cb                	jmp    800c15 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 05                	je     800c55 <strtol+0xd0>
		*endptr = (char *) s;
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	f7 da                	neg    %edx
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	0f 45 c2             	cmovne %edx,%eax
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	89 c7                	mov    %eax,%edi
  800c78:	89 c6                	mov    %eax,%esi
  800c7a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c87:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	89 d3                	mov    %edx,%ebx
  800c95:	89 d7                	mov    %edx,%edi
  800c97:	89 d6                	mov    %edx,%esi
  800c99:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb6:	89 cb                	mov    %ecx,%ebx
  800cb8:	89 cf                	mov    %ecx,%edi
  800cba:	89 ce                	mov    %ecx,%esi
  800cbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7f 08                	jg     800cca <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 03                	push   $0x3
  800cd0:	68 bf 27 80 00       	push   $0x8027bf
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 dc 27 80 00       	push   $0x8027dc
  800cdc:	e8 4b f5 ff ff       	call   80022c <_panic>

00800ce1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf1:	89 d1                	mov    %edx,%ecx
  800cf3:	89 d3                	mov    %edx,%ebx
  800cf5:	89 d7                	mov    %edx,%edi
  800cf7:	89 d6                	mov    %edx,%esi
  800cf9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_yield>:

void
sys_yield(void)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d10:	89 d1                	mov    %edx,%ecx
  800d12:	89 d3                	mov    %edx,%ebx
  800d14:	89 d7                	mov    %edx,%edi
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	be 00 00 00 00       	mov    $0x0,%esi
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	b8 04 00 00 00       	mov    $0x4,%eax
  800d38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3b:	89 f7                	mov    %esi,%edi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 04                	push   $0x4
  800d51:	68 bf 27 80 00       	push   $0x8027bf
  800d56:	6a 23                	push   $0x23
  800d58:	68 dc 27 80 00       	push   $0x8027dc
  800d5d:	e8 ca f4 ff ff       	call   80022c <_panic>

00800d62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	b8 05 00 00 00       	mov    $0x5,%eax
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7f 08                	jg     800d8d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 05                	push   $0x5
  800d93:	68 bf 27 80 00       	push   $0x8027bf
  800d98:	6a 23                	push   $0x23
  800d9a:	68 dc 27 80 00       	push   $0x8027dc
  800d9f:	e8 88 f4 ff ff       	call   80022c <_panic>

00800da4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7f 08                	jg     800dcf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	50                   	push   %eax
  800dd3:	6a 06                	push   $0x6
  800dd5:	68 bf 27 80 00       	push   $0x8027bf
  800dda:	6a 23                	push   $0x23
  800ddc:	68 dc 27 80 00       	push   $0x8027dc
  800de1:	e8 46 f4 ff ff       	call   80022c <_panic>

00800de6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800def:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800dff:	89 df                	mov    %ebx,%edi
  800e01:	89 de                	mov    %ebx,%esi
  800e03:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e05:	85 c0                	test   %eax,%eax
  800e07:	7f 08                	jg     800e11 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	50                   	push   %eax
  800e15:	6a 08                	push   $0x8
  800e17:	68 bf 27 80 00       	push   $0x8027bf
  800e1c:	6a 23                	push   $0x23
  800e1e:	68 dc 27 80 00       	push   $0x8027dc
  800e23:	e8 04 f4 ff ff       	call   80022c <_panic>

00800e28 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	57                   	push   %edi
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7f 08                	jg     800e53 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	50                   	push   %eax
  800e57:	6a 09                	push   $0x9
  800e59:	68 bf 27 80 00       	push   $0x8027bf
  800e5e:	6a 23                	push   $0x23
  800e60:	68 dc 27 80 00       	push   $0x8027dc
  800e65:	e8 c2 f3 ff ff       	call   80022c <_panic>

00800e6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e83:	89 df                	mov    %ebx,%edi
  800e85:	89 de                	mov    %ebx,%esi
  800e87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7f 08                	jg     800e95 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0a                	push   $0xa
  800e9b:	68 bf 27 80 00       	push   $0x8027bf
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 dc 27 80 00       	push   $0x8027dc
  800ea7:	e8 80 f3 ff ff       	call   80022c <_panic>

00800eac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ebd:	be 00 00 00 00       	mov    $0x0,%esi
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec8:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7f 08                	jg     800ef9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	50                   	push   %eax
  800efd:	6a 0d                	push   $0xd
  800eff:	68 bf 27 80 00       	push   $0x8027bf
  800f04:	6a 23                	push   $0x23
  800f06:	68 dc 27 80 00       	push   $0x8027dc
  800f0b:	e8 1c f3 ff ff       	call   80022c <_panic>

00800f10 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	53                   	push   %ebx
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f1a:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f1c:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f1f:	a8 02                	test   $0x2,%al
  800f21:	0f 84 89 00 00 00    	je     800fb0 <pgfault+0xa0>
  800f27:	89 da                	mov    %ebx,%edx
  800f29:	c1 ea 0c             	shr    $0xc,%edx
  800f2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f33:	f6 c6 08             	test   $0x8,%dh
  800f36:	74 78                	je     800fb0 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	6a 07                	push   $0x7
  800f3d:	68 00 f0 7f 00       	push   $0x7ff000
  800f42:	6a 00                	push   $0x0
  800f44:	e8 d6 fd ff ff       	call   800d1f <sys_page_alloc>
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	0f 88 8b 00 00 00    	js     800fdf <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 00 10 00 00       	push   $0x1000
  800f5c:	53                   	push   %ebx
  800f5d:	68 00 f0 7f 00       	push   $0x7ff000
  800f62:	e8 4d fb ff ff       	call   800ab4 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f67:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f6e:	53                   	push   %ebx
  800f6f:	6a 00                	push   $0x0
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 e5 fd ff ff       	call   800d62 <sys_page_map>
  800f7d:	83 c4 20             	add    $0x20,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 6d                	js     800ff1 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	68 00 f0 7f 00       	push   $0x7ff000
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 11 fe ff ff       	call   800da4 <sys_page_unmap>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 69                	js     801003 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800f9a:	83 ec 08             	sub    $0x8,%esp
  800f9d:	53                   	push   %ebx
  800f9e:	68 48 28 80 00       	push   $0x802848
  800fa3:	e8 5f f3 ff ff       	call   800307 <cprintf>

}
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800fb0:	8b 15 20 44 80 00    	mov    0x804420,%edx
  800fb6:	8b 4a 48             	mov    0x48(%edx),%ecx
  800fb9:	89 da                	mov    %ebx,%edx
  800fbb:	c1 ea 0c             	shr    $0xc,%edx
  800fbe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc5:	51                   	push   %ecx
  800fc6:	53                   	push   %ebx
  800fc7:	68 00 00 40 ef       	push   $0xef400000
  800fcc:	52                   	push   %edx
  800fcd:	50                   	push   %eax
  800fce:	68 ec 27 80 00       	push   $0x8027ec
  800fd3:	6a 1e                	push   $0x1e
  800fd5:	68 69 28 80 00       	push   $0x802869
  800fda:	e8 4d f2 ff ff       	call   80022c <_panic>
        panic("sys_page_alloc error %e", r);
  800fdf:	50                   	push   %eax
  800fe0:	68 74 28 80 00       	push   $0x802874
  800fe5:	6a 28                	push   $0x28
  800fe7:	68 69 28 80 00       	push   $0x802869
  800fec:	e8 3b f2 ff ff       	call   80022c <_panic>
        panic("sys_page_map error %e", r);
  800ff1:	50                   	push   %eax
  800ff2:	68 8c 28 80 00       	push   $0x80288c
  800ff7:	6a 2b                	push   $0x2b
  800ff9:	68 69 28 80 00       	push   $0x802869
  800ffe:	e8 29 f2 ff ff       	call   80022c <_panic>
        panic("sys_page_unmap error %e", r);
  801003:	50                   	push   %eax
  801004:	68 a2 28 80 00       	push   $0x8028a2
  801009:	6a 2d                	push   $0x2d
  80100b:	68 69 28 80 00       	push   $0x802869
  801010:	e8 17 f2 ff ff       	call   80022c <_panic>

00801015 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80101b:	83 3d 24 44 80 00 00 	cmpl   $0x0,0x804424
  801022:	74 23                	je     801047 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	a3 24 44 80 00       	mov    %eax,0x804424
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80102c:	a1 20 44 80 00       	mov    0x804420,%eax
  801031:	8b 40 48             	mov    0x48(%eax),%eax
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	68 c3 1f 80 00       	push   $0x801fc3
  80103c:	50                   	push   %eax
  80103d:	e8 28 fe ff ff       	call   800e6a <sys_env_set_pgfault_upcall>
}
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	c9                   	leave  
  801046:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801047:	a1 20 44 80 00       	mov    0x804420,%eax
  80104c:	8b 40 48             	mov    0x48(%eax),%eax
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	6a 07                	push   $0x7
  801054:	68 00 f0 bf ee       	push   $0xeebff000
  801059:	50                   	push   %eax
  80105a:	e8 c0 fc ff ff       	call   800d1f <sys_page_alloc>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	79 be                	jns    801024 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  801066:	50                   	push   %eax
  801067:	68 ba 28 80 00       	push   $0x8028ba
  80106c:	6a 21                	push   $0x21
  80106e:	68 cd 28 80 00       	push   $0x8028cd
  801073:	e8 b4 f1 ff ff       	call   80022c <_panic>

00801078 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
  80107d:	8b 75 08             	mov    0x8(%ebp),%esi
  801080:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	6a 07                	push   $0x7
  801088:	53                   	push   %ebx
  801089:	56                   	push   %esi
  80108a:	e8 90 fc ff ff       	call   800d1f <sys_page_alloc>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 4a                	js     8010e0 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	6a 07                	push   $0x7
  80109b:	68 00 00 40 00       	push   $0x400000
  8010a0:	6a 00                	push   $0x0
  8010a2:	53                   	push   %ebx
  8010a3:	56                   	push   %esi
  8010a4:	e8 b9 fc ff ff       	call   800d62 <sys_page_map>
  8010a9:	83 c4 20             	add    $0x20,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 42                	js     8010f2 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	68 00 10 00 00       	push   $0x1000
  8010b8:	53                   	push   %ebx
  8010b9:	68 00 00 40 00       	push   $0x400000
  8010be:	e8 f1 f9 ff ff       	call   800ab4 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	68 00 00 40 00       	push   $0x400000
  8010cb:	6a 00                	push   $0x0
  8010cd:	e8 d2 fc ff ff       	call   800da4 <sys_page_unmap>
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 2b                	js     801104 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  8010d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  8010e0:	50                   	push   %eax
  8010e1:	68 ba 28 80 00       	push   $0x8028ba
  8010e6:	6a 63                	push   $0x63
  8010e8:	68 69 28 80 00       	push   $0x802869
  8010ed:	e8 3a f1 ff ff       	call   80022c <_panic>
        panic("sys_page_map: %e", r);
  8010f2:	50                   	push   %eax
  8010f3:	68 dd 28 80 00       	push   $0x8028dd
  8010f8:	6a 65                	push   $0x65
  8010fa:	68 69 28 80 00       	push   $0x802869
  8010ff:	e8 28 f1 ff ff       	call   80022c <_panic>
        panic("sys_page_unmap: %e", r);
  801104:	50                   	push   %eax
  801105:	68 ee 28 80 00       	push   $0x8028ee
  80110a:	6a 68                	push   $0x68
  80110c:	68 69 28 80 00       	push   $0x802869
  801111:	e8 16 f1 ff ff       	call   80022c <_panic>

00801116 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	53                   	push   %ebx
  80111c:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  80111f:	a1 20 44 80 00       	mov    0x804420,%eax
  801124:	8b 40 64             	mov    0x64(%eax),%eax
  801127:	85 c0                	test   %eax,%eax
  801129:	74 1f                	je     80114a <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80112b:	b8 07 00 00 00       	mov    $0x7,%eax
  801130:	cd 30                	int    $0x30
  801132:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801134:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801137:	85 c0                	test   %eax,%eax
  801139:	74 21                	je     80115c <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  80113b:	be 24 44 80 00       	mov    $0x804424,%esi
  801140:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801143:	bb 00 00 00 00       	mov    $0x0,%ebx
  801148:	eb 7b                	jmp    8011c5 <fork+0xaf>
        set_pgfault_handler(pgfault);
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	68 10 0f 80 00       	push   $0x800f10
  801152:	e8 be fe ff ff       	call   801015 <set_pgfault_handler>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	eb cf                	jmp    80112b <fork+0x15>
        set_pgfault_handler(pgfault);
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	68 10 0f 80 00       	push   $0x800f10
  801164:	e8 ac fe ff ff       	call   801015 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801169:	e8 73 fb ff ff       	call   800ce1 <sys_getenvid>
  80116e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801173:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801176:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117b:	a3 20 44 80 00       	mov    %eax,0x804420
        return 0;
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	e9 ca 00 00 00       	jmp    801252 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801188:	89 d1                	mov    %edx,%ecx
  80118a:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801190:	81 e2 02 08 00 00    	and    $0x802,%edx
  801196:	89 cf                	mov    %ecx,%edi
  801198:	81 cf 00 08 00 00    	or     $0x800,%edi
  80119e:	85 d2                	test   %edx,%edx
  8011a0:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	51                   	push   %ecx
  8011a7:	50                   	push   %eax
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	50                   	push   %eax
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 af fb ff ff       	call   800d62 <sys_page_map>
  8011b3:	83 c4 20             	add    $0x20,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 45                	js     8011ff <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8011ba:	83 c3 01             	add    $0x1,%ebx
  8011bd:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8011c3:	74 4c                	je     801211 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8011c5:	39 de                	cmp    %ebx,%esi
  8011c7:	74 f1                	je     8011ba <fork+0xa4>
  8011c9:	89 d8                	mov    %ebx,%eax
  8011cb:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8011ce:	89 c2                	mov    %eax,%edx
  8011d0:	c1 ea 16             	shr    $0x16,%edx
  8011d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8011da:	f6 c2 05             	test   $0x5,%dl
  8011dd:	74 db                	je     8011ba <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	c1 ea 0c             	shr    $0xc,%edx
  8011e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8011eb:	f6 c2 04             	test   $0x4,%dl
  8011ee:	74 ca                	je     8011ba <fork+0xa4>
    if (perm & PTE_SHARE) {
  8011f0:	f6 c6 04             	test   $0x4,%dh
  8011f3:	74 93                	je     801188 <fork+0x72>
        perm &= ~PTE_COW;
  8011f5:	89 d1                	mov    %edx,%ecx
  8011f7:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8011fd:	eb a4                	jmp    8011a3 <fork+0x8d>
        panic("sys_page_map error %e", r);
  8011ff:	50                   	push   %eax
  801200:	68 8c 28 80 00       	push   $0x80288c
  801205:	6a 57                	push   $0x57
  801207:	68 69 28 80 00       	push   $0x802869
  80120c:	e8 1b f0 ff ff       	call   80022c <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	b8 24 44 80 00       	mov    $0x804424,%eax
  801219:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121e:	50                   	push   %eax
  80121f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801222:	e8 51 fe ff ff       	call   801078 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801227:	83 c4 08             	add    $0x8,%esp
  80122a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801232:	50                   	push   %eax
  801233:	ff 75 e4             	pushl  -0x1c(%ebp)
  801236:	e8 3d fe ff ff       	call   801078 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80123b:	83 c4 08             	add    $0x8,%esp
  80123e:	6a 02                	push   $0x2
  801240:	ff 75 e4             	pushl  -0x1c(%ebp)
  801243:	e8 9e fb ff ff       	call   800de6 <sys_env_set_status>
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	78 0d                	js     80125c <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  80124f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801252:	89 d8                	mov    %ebx,%eax
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  80125c:	50                   	push   %eax
  80125d:	68 01 29 80 00       	push   $0x802901
  801262:	68 a0 00 00 00       	push   $0xa0
  801267:	68 69 28 80 00       	push   $0x802869
  80126c:	e8 bb ef ff ff       	call   80022c <_panic>

00801271 <sfork>:

// Challenge!
int
sfork(void)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801277:	68 18 29 80 00       	push   $0x802918
  80127c:	68 a9 00 00 00       	push   $0xa9
  801281:	68 69 28 80 00       	push   $0x802869
  801286:	e8 a1 ef ff ff       	call   80022c <_panic>

0080128b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	05 00 00 00 30       	add    $0x30000000,%eax
  801296:	c1 e8 0c             	shr    $0xc,%eax
}
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012ab:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	c1 ea 16             	shr    $0x16,%edx
  8012c2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c9:	f6 c2 01             	test   $0x1,%dl
  8012cc:	74 2a                	je     8012f8 <fd_alloc+0x46>
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	c1 ea 0c             	shr    $0xc,%edx
  8012d3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012da:	f6 c2 01             	test   $0x1,%dl
  8012dd:	74 19                	je     8012f8 <fd_alloc+0x46>
  8012df:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e9:	75 d2                	jne    8012bd <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012eb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012f6:	eb 07                	jmp    8012ff <fd_alloc+0x4d>
			*fd_store = fd;
  8012f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801307:	83 f8 1f             	cmp    $0x1f,%eax
  80130a:	77 36                	ja     801342 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80130c:	c1 e0 0c             	shl    $0xc,%eax
  80130f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801314:	89 c2                	mov    %eax,%edx
  801316:	c1 ea 16             	shr    $0x16,%edx
  801319:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801320:	f6 c2 01             	test   $0x1,%dl
  801323:	74 24                	je     801349 <fd_lookup+0x48>
  801325:	89 c2                	mov    %eax,%edx
  801327:	c1 ea 0c             	shr    $0xc,%edx
  80132a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801331:	f6 c2 01             	test   $0x1,%dl
  801334:	74 1a                	je     801350 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801336:	8b 55 0c             	mov    0xc(%ebp),%edx
  801339:	89 02                	mov    %eax,(%edx)
	return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
		return -E_INVAL;
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801347:	eb f7                	jmp    801340 <fd_lookup+0x3f>
		return -E_INVAL;
  801349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134e:	eb f0                	jmp    801340 <fd_lookup+0x3f>
  801350:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801355:	eb e9                	jmp    801340 <fd_lookup+0x3f>

00801357 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801360:	ba ac 29 80 00       	mov    $0x8029ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801365:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80136a:	39 08                	cmp    %ecx,(%eax)
  80136c:	74 33                	je     8013a1 <dev_lookup+0x4a>
  80136e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801371:	8b 02                	mov    (%edx),%eax
  801373:	85 c0                	test   %eax,%eax
  801375:	75 f3                	jne    80136a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801377:	a1 20 44 80 00       	mov    0x804420,%eax
  80137c:	8b 40 48             	mov    0x48(%eax),%eax
  80137f:	83 ec 04             	sub    $0x4,%esp
  801382:	51                   	push   %ecx
  801383:	50                   	push   %eax
  801384:	68 30 29 80 00       	push   $0x802930
  801389:	e8 79 ef ff ff       	call   800307 <cprintf>
	*dev = 0;
  80138e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801391:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    
			*dev = devtab[i];
  8013a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ab:	eb f2                	jmp    80139f <dev_lookup+0x48>

008013ad <fd_close>:
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	57                   	push   %edi
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 1c             	sub    $0x1c,%esp
  8013b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bf:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013c6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c9:	50                   	push   %eax
  8013ca:	e8 32 ff ff ff       	call   801301 <fd_lookup>
  8013cf:	89 c3                	mov    %eax,%ebx
  8013d1:	83 c4 08             	add    $0x8,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 05                	js     8013dd <fd_close+0x30>
	    || fd != fd2)
  8013d8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013db:	74 16                	je     8013f3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013dd:	89 f8                	mov    %edi,%eax
  8013df:	84 c0                	test   %al,%al
  8013e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e6:	0f 44 d8             	cmove  %eax,%ebx
}
  8013e9:	89 d8                	mov    %ebx,%eax
  8013eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5e                   	pop    %esi
  8013f0:	5f                   	pop    %edi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 36                	pushl  (%esi)
  8013fc:	e8 56 ff ff ff       	call   801357 <dev_lookup>
  801401:	89 c3                	mov    %eax,%ebx
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 15                	js     80141f <fd_close+0x72>
		if (dev->dev_close)
  80140a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140d:	8b 40 10             	mov    0x10(%eax),%eax
  801410:	85 c0                	test   %eax,%eax
  801412:	74 1b                	je     80142f <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801414:	83 ec 0c             	sub    $0xc,%esp
  801417:	56                   	push   %esi
  801418:	ff d0                	call   *%eax
  80141a:	89 c3                	mov    %eax,%ebx
  80141c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	56                   	push   %esi
  801423:	6a 00                	push   $0x0
  801425:	e8 7a f9 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	eb ba                	jmp    8013e9 <fd_close+0x3c>
			r = 0;
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801434:	eb e9                	jmp    80141f <fd_close+0x72>

00801436 <close>:

int
close(int fdnum)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	ff 75 08             	pushl  0x8(%ebp)
  801443:	e8 b9 fe ff ff       	call   801301 <fd_lookup>
  801448:	83 c4 08             	add    $0x8,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 10                	js     80145f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	6a 01                	push   $0x1
  801454:	ff 75 f4             	pushl  -0xc(%ebp)
  801457:	e8 51 ff ff ff       	call   8013ad <fd_close>
  80145c:	83 c4 10             	add    $0x10,%esp
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <close_all>:

void
close_all(void)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	53                   	push   %ebx
  801465:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801468:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	53                   	push   %ebx
  801471:	e8 c0 ff ff ff       	call   801436 <close>
	for (i = 0; i < MAXFD; i++)
  801476:	83 c3 01             	add    $0x1,%ebx
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	83 fb 20             	cmp    $0x20,%ebx
  80147f:	75 ec                	jne    80146d <close_all+0xc>
}
  801481:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80148f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	e8 66 fe ff ff       	call   801301 <fd_lookup>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 08             	add    $0x8,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	0f 88 81 00 00 00    	js     801529 <dup+0xa3>
		return r;
	close(newfdnum);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	e8 83 ff ff ff       	call   801436 <close>

	newfd = INDEX2FD(newfdnum);
  8014b3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b6:	c1 e6 0c             	shl    $0xc,%esi
  8014b9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014bf:	83 c4 04             	add    $0x4,%esp
  8014c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c5:	e8 d1 fd ff ff       	call   80129b <fd2data>
  8014ca:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014cc:	89 34 24             	mov    %esi,(%esp)
  8014cf:	e8 c7 fd ff ff       	call   80129b <fd2data>
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	c1 e8 16             	shr    $0x16,%eax
  8014de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e5:	a8 01                	test   $0x1,%al
  8014e7:	74 11                	je     8014fa <dup+0x74>
  8014e9:	89 d8                	mov    %ebx,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
  8014ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014f5:	f6 c2 01             	test   $0x1,%dl
  8014f8:	75 39                	jne    801533 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fd:	89 d0                	mov    %edx,%eax
  8014ff:	c1 e8 0c             	shr    $0xc,%eax
  801502:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	25 07 0e 00 00       	and    $0xe07,%eax
  801511:	50                   	push   %eax
  801512:	56                   	push   %esi
  801513:	6a 00                	push   $0x0
  801515:	52                   	push   %edx
  801516:	6a 00                	push   $0x0
  801518:	e8 45 f8 ff ff       	call   800d62 <sys_page_map>
  80151d:	89 c3                	mov    %eax,%ebx
  80151f:	83 c4 20             	add    $0x20,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 31                	js     801557 <dup+0xd1>
		goto err;

	return newfdnum;
  801526:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801529:	89 d8                	mov    %ebx,%eax
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801533:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80153a:	83 ec 0c             	sub    $0xc,%esp
  80153d:	25 07 0e 00 00       	and    $0xe07,%eax
  801542:	50                   	push   %eax
  801543:	57                   	push   %edi
  801544:	6a 00                	push   $0x0
  801546:	53                   	push   %ebx
  801547:	6a 00                	push   $0x0
  801549:	e8 14 f8 ff ff       	call   800d62 <sys_page_map>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	83 c4 20             	add    $0x20,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	79 a3                	jns    8014fa <dup+0x74>
	sys_page_unmap(0, newfd);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	56                   	push   %esi
  80155b:	6a 00                	push   $0x0
  80155d:	e8 42 f8 ff ff       	call   800da4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801562:	83 c4 08             	add    $0x8,%esp
  801565:	57                   	push   %edi
  801566:	6a 00                	push   $0x0
  801568:	e8 37 f8 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb b7                	jmp    801529 <dup+0xa3>

00801572 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 14             	sub    $0x14,%esp
  801579:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	53                   	push   %ebx
  801581:	e8 7b fd ff ff       	call   801301 <fd_lookup>
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 3f                	js     8015cc <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801597:	ff 30                	pushl  (%eax)
  801599:	e8 b9 fd ff ff       	call   801357 <dev_lookup>
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 27                	js     8015cc <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a8:	8b 42 08             	mov    0x8(%edx),%eax
  8015ab:	83 e0 03             	and    $0x3,%eax
  8015ae:	83 f8 01             	cmp    $0x1,%eax
  8015b1:	74 1e                	je     8015d1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b6:	8b 40 08             	mov    0x8(%eax),%eax
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	74 35                	je     8015f2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	ff 75 10             	pushl  0x10(%ebp)
  8015c3:	ff 75 0c             	pushl  0xc(%ebp)
  8015c6:	52                   	push   %edx
  8015c7:	ff d0                	call   *%eax
  8015c9:	83 c4 10             	add    $0x10,%esp
}
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d1:	a1 20 44 80 00       	mov    0x804420,%eax
  8015d6:	8b 40 48             	mov    0x48(%eax),%eax
  8015d9:	83 ec 04             	sub    $0x4,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	50                   	push   %eax
  8015de:	68 71 29 80 00       	push   $0x802971
  8015e3:	e8 1f ed ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f0:	eb da                	jmp    8015cc <read+0x5a>
		return -E_NOT_SUPP;
  8015f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f7:	eb d3                	jmp    8015cc <read+0x5a>

008015f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	57                   	push   %edi
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 0c             	sub    $0xc,%esp
  801602:	8b 7d 08             	mov    0x8(%ebp),%edi
  801605:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160d:	39 f3                	cmp    %esi,%ebx
  80160f:	73 25                	jae    801636 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	89 f0                	mov    %esi,%eax
  801616:	29 d8                	sub    %ebx,%eax
  801618:	50                   	push   %eax
  801619:	89 d8                	mov    %ebx,%eax
  80161b:	03 45 0c             	add    0xc(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	57                   	push   %edi
  801620:	e8 4d ff ff ff       	call   801572 <read>
		if (m < 0)
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 08                	js     801634 <readn+0x3b>
			return m;
		if (m == 0)
  80162c:	85 c0                	test   %eax,%eax
  80162e:	74 06                	je     801636 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801630:	01 c3                	add    %eax,%ebx
  801632:	eb d9                	jmp    80160d <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801634:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801636:	89 d8                	mov    %ebx,%eax
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	53                   	push   %ebx
  80164f:	e8 ad fc ff ff       	call   801301 <fd_lookup>
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 3a                	js     801695 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 eb fc ff ff       	call   801357 <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 22                	js     801695 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167a:	74 1e                	je     80169a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80167c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167f:	8b 52 0c             	mov    0xc(%edx),%edx
  801682:	85 d2                	test   %edx,%edx
  801684:	74 35                	je     8016bb <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801686:	83 ec 04             	sub    $0x4,%esp
  801689:	ff 75 10             	pushl  0x10(%ebp)
  80168c:	ff 75 0c             	pushl  0xc(%ebp)
  80168f:	50                   	push   %eax
  801690:	ff d2                	call   *%edx
  801692:	83 c4 10             	add    $0x10,%esp
}
  801695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801698:	c9                   	leave  
  801699:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80169a:	a1 20 44 80 00       	mov    0x804420,%eax
  80169f:	8b 40 48             	mov    0x48(%eax),%eax
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	53                   	push   %ebx
  8016a6:	50                   	push   %eax
  8016a7:	68 8d 29 80 00       	push   $0x80298d
  8016ac:	e8 56 ec ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b9:	eb da                	jmp    801695 <write+0x55>
		return -E_NOT_SUPP;
  8016bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c0:	eb d3                	jmp    801695 <write+0x55>

008016c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	ff 75 08             	pushl  0x8(%ebp)
  8016cf:	e8 2d fc ff ff       	call   801301 <fd_lookup>
  8016d4:	83 c4 08             	add    $0x8,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 0e                	js     8016e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	83 ec 14             	sub    $0x14,%esp
  8016f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	53                   	push   %ebx
  8016fa:	e8 02 fc ff ff       	call   801301 <fd_lookup>
  8016ff:	83 c4 08             	add    $0x8,%esp
  801702:	85 c0                	test   %eax,%eax
  801704:	78 37                	js     80173d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	ff 30                	pushl  (%eax)
  801712:	e8 40 fc ff ff       	call   801357 <dev_lookup>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 1f                	js     80173d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801721:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801725:	74 1b                	je     801742 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801727:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172a:	8b 52 18             	mov    0x18(%edx),%edx
  80172d:	85 d2                	test   %edx,%edx
  80172f:	74 32                	je     801763 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	50                   	push   %eax
  801738:	ff d2                	call   *%edx
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    
			thisenv->env_id, fdnum);
  801742:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801747:	8b 40 48             	mov    0x48(%eax),%eax
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	53                   	push   %ebx
  80174e:	50                   	push   %eax
  80174f:	68 50 29 80 00       	push   $0x802950
  801754:	e8 ae eb ff ff       	call   800307 <cprintf>
		return -E_INVAL;
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801761:	eb da                	jmp    80173d <ftruncate+0x52>
		return -E_NOT_SUPP;
  801763:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801768:	eb d3                	jmp    80173d <ftruncate+0x52>

0080176a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	ff 75 08             	pushl  0x8(%ebp)
  80177b:	e8 81 fb ff ff       	call   801301 <fd_lookup>
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 4b                	js     8017d2 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 bf fb ff ff       	call   801357 <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 33                	js     8017d2 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a6:	74 2f                	je     8017d7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017ab:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b2:	00 00 00 
	stat->st_isdir = 0;
  8017b5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017bc:	00 00 00 
	stat->st_dev = dev;
  8017bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	53                   	push   %ebx
  8017c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cc:	ff 50 14             	call   *0x14(%eax)
  8017cf:	83 c4 10             	add    $0x10,%esp
}
  8017d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    
		return -E_NOT_SUPP;
  8017d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017dc:	eb f4                	jmp    8017d2 <fstat+0x68>

008017de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	6a 00                	push   $0x0
  8017e8:	ff 75 08             	pushl  0x8(%ebp)
  8017eb:	e8 e7 01 00 00       	call   8019d7 <open>
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 1b                	js     801814 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	ff 75 0c             	pushl  0xc(%ebp)
  8017ff:	50                   	push   %eax
  801800:	e8 65 ff ff ff       	call   80176a <fstat>
  801805:	89 c6                	mov    %eax,%esi
	close(fd);
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 27 fc ff ff       	call   801436 <close>
	return r;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	89 f3                	mov    %esi,%ebx
}
  801814:	89 d8                	mov    %ebx,%eax
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	89 c6                	mov    %eax,%esi
  801824:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801826:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182d:	74 27                	je     801856 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80182f:	6a 07                	push   $0x7
  801831:	68 00 50 80 00       	push   $0x805000
  801836:	56                   	push   %esi
  801837:	ff 35 00 40 80 00    	pushl  0x804000
  80183d:	e8 08 08 00 00       	call   80204a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801842:	83 c4 0c             	add    $0xc,%esp
  801845:	6a 00                	push   $0x0
  801847:	53                   	push   %ebx
  801848:	6a 00                	push   $0x0
  80184a:	e8 9a 07 00 00       	call   801fe9 <ipc_recv>
}
  80184f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801852:	5b                   	pop    %ebx
  801853:	5e                   	pop    %esi
  801854:	5d                   	pop    %ebp
  801855:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	6a 01                	push   $0x1
  80185b:	e8 37 08 00 00       	call   802097 <ipc_find_env>
  801860:	a3 00 40 80 00       	mov    %eax,0x804000
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	eb c5                	jmp    80182f <fsipc+0x12>

0080186a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 40 0c             	mov    0xc(%eax),%eax
  801876:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80187b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801883:	ba 00 00 00 00       	mov    $0x0,%edx
  801888:	b8 02 00 00 00       	mov    $0x2,%eax
  80188d:	e8 8b ff ff ff       	call   80181d <fsipc>
}
  801892:	c9                   	leave  
  801893:	c3                   	ret    

00801894 <devfile_flush>:
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80189a:	8b 45 08             	mov    0x8(%ebp),%eax
  80189d:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8018af:	e8 69 ff ff ff       	call   80181d <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_stat>:
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	53                   	push   %ebx
  8018ba:	83 ec 04             	sub    $0x4,%esp
  8018bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d5:	e8 43 ff ff ff       	call   80181d <fsipc>
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 2c                	js     80190a <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	68 00 50 80 00       	push   $0x805000
  8018e6:	53                   	push   %ebx
  8018e7:	e8 3a f0 ff ff       	call   800926 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ec:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <devfile_write>:
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801918:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80191d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801922:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801925:	8b 55 08             	mov    0x8(%ebp),%edx
  801928:	8b 52 0c             	mov    0xc(%edx),%edx
  80192b:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801931:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801936:	50                   	push   %eax
  801937:	ff 75 0c             	pushl  0xc(%ebp)
  80193a:	68 08 50 80 00       	push   $0x805008
  80193f:	e8 70 f1 ff ff       	call   800ab4 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801944:	ba 00 00 00 00       	mov    $0x0,%edx
  801949:	b8 04 00 00 00       	mov    $0x4,%eax
  80194e:	e8 ca fe ff ff       	call   80181d <fsipc>
}
  801953:	c9                   	leave  
  801954:	c3                   	ret    

00801955 <devfile_read>:
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195d:	8b 45 08             	mov    0x8(%ebp),%eax
  801960:	8b 40 0c             	mov    0xc(%eax),%eax
  801963:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801968:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196e:	ba 00 00 00 00       	mov    $0x0,%edx
  801973:	b8 03 00 00 00       	mov    $0x3,%eax
  801978:	e8 a0 fe ff ff       	call   80181d <fsipc>
  80197d:	89 c3                	mov    %eax,%ebx
  80197f:	85 c0                	test   %eax,%eax
  801981:	78 1f                	js     8019a2 <devfile_read+0x4d>
	assert(r <= n);
  801983:	39 f0                	cmp    %esi,%eax
  801985:	77 24                	ja     8019ab <devfile_read+0x56>
	assert(r <= PGSIZE);
  801987:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80198c:	7f 33                	jg     8019c1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80198e:	83 ec 04             	sub    $0x4,%esp
  801991:	50                   	push   %eax
  801992:	68 00 50 80 00       	push   $0x805000
  801997:	ff 75 0c             	pushl  0xc(%ebp)
  80199a:	e8 15 f1 ff ff       	call   800ab4 <memmove>
	return r;
  80199f:	83 c4 10             	add    $0x10,%esp
}
  8019a2:	89 d8                	mov    %ebx,%eax
  8019a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a7:	5b                   	pop    %ebx
  8019a8:	5e                   	pop    %esi
  8019a9:	5d                   	pop    %ebp
  8019aa:	c3                   	ret    
	assert(r <= n);
  8019ab:	68 bc 29 80 00       	push   $0x8029bc
  8019b0:	68 c3 29 80 00       	push   $0x8029c3
  8019b5:	6a 7d                	push   $0x7d
  8019b7:	68 d8 29 80 00       	push   $0x8029d8
  8019bc:	e8 6b e8 ff ff       	call   80022c <_panic>
	assert(r <= PGSIZE);
  8019c1:	68 e3 29 80 00       	push   $0x8029e3
  8019c6:	68 c3 29 80 00       	push   $0x8029c3
  8019cb:	6a 7e                	push   $0x7e
  8019cd:	68 d8 29 80 00       	push   $0x8029d8
  8019d2:	e8 55 e8 ff ff       	call   80022c <_panic>

008019d7 <open>:
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	56                   	push   %esi
  8019db:	53                   	push   %ebx
  8019dc:	83 ec 1c             	sub    $0x1c,%esp
  8019df:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019e2:	56                   	push   %esi
  8019e3:	e8 07 ef ff ff       	call   8008ef <strlen>
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f0:	0f 8f 96 00 00 00    	jg     801a8c <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019fc:	50                   	push   %eax
  8019fd:	e8 b0 f8 ff ff       	call   8012b2 <fd_alloc>
  801a02:	89 c3                	mov    %eax,%ebx
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	85 c0                	test   %eax,%eax
  801a09:	78 66                	js     801a71 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	56                   	push   %esi
  801a0f:	68 00 50 80 00       	push   $0x805000
  801a14:	e8 0d ef ff ff       	call   800926 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a24:	b8 01 00 00 00       	mov    $0x1,%eax
  801a29:	e8 ef fd ff ff       	call   80181d <fsipc>
  801a2e:	89 c3                	mov    %eax,%ebx
  801a30:	83 c4 10             	add    $0x10,%esp
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 43                	js     801a7a <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801a37:	83 ec 0c             	sub    $0xc,%esp
  801a3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3d:	e8 49 f8 ff ff       	call   80128b <fd2num>
  801a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a45:	8b 0d 20 44 80 00    	mov    0x804420,%ecx
  801a4b:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a4e:	83 c4 08             	add    $0x8,%esp
  801a51:	50                   	push   %eax
  801a52:	52                   	push   %edx
  801a53:	ff 32                	pushl  (%edx)
  801a55:	56                   	push   %esi
  801a56:	51                   	push   %ecx
  801a57:	68 f0 29 80 00       	push   $0x8029f0
  801a5c:	e8 a6 e8 ff ff       	call   800307 <cprintf>
	return fd2num(fd);
  801a61:	83 c4 14             	add    $0x14,%esp
  801a64:	ff 75 f4             	pushl  -0xc(%ebp)
  801a67:	e8 1f f8 ff ff       	call   80128b <fd2num>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	83 c4 10             	add    $0x10,%esp
}
  801a71:	89 d8                	mov    %ebx,%eax
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    
		fd_close(fd, 0);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	6a 00                	push   $0x0
  801a7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a82:	e8 26 f9 ff ff       	call   8013ad <fd_close>
		return r;
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	eb e5                	jmp    801a71 <open+0x9a>
		return -E_BAD_PATH;
  801a8c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a91:	eb de                	jmp    801a71 <open+0x9a>

00801a93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a99:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9e:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa3:	e8 75 fd ff ff       	call   80181d <fsipc>
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    

00801aaa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	56                   	push   %esi
  801aae:	53                   	push   %ebx
  801aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	ff 75 08             	pushl  0x8(%ebp)
  801ab8:	e8 de f7 ff ff       	call   80129b <fd2data>
  801abd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abf:	83 c4 08             	add    $0x8,%esp
  801ac2:	68 30 2a 80 00       	push   $0x802a30
  801ac7:	53                   	push   %ebx
  801ac8:	e8 59 ee ff ff       	call   800926 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acd:	8b 46 04             	mov    0x4(%esi),%eax
  801ad0:	2b 06                	sub    (%esi),%eax
  801ad2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801adf:	00 00 00 
	stat->st_dev = &devpipe;
  801ae2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ae9:	30 80 00 
	return 0;
}
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
  801af1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af4:	5b                   	pop    %ebx
  801af5:	5e                   	pop    %esi
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	53                   	push   %ebx
  801afc:	83 ec 0c             	sub    $0xc,%esp
  801aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b02:	53                   	push   %ebx
  801b03:	6a 00                	push   $0x0
  801b05:	e8 9a f2 ff ff       	call   800da4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 89 f7 ff ff       	call   80129b <fd2data>
  801b12:	83 c4 08             	add    $0x8,%esp
  801b15:	50                   	push   %eax
  801b16:	6a 00                	push   $0x0
  801b18:	e8 87 f2 ff ff       	call   800da4 <sys_page_unmap>
}
  801b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <_pipeisclosed>:
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
  801b2b:	89 c7                	mov    %eax,%edi
  801b2d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b2f:	a1 20 44 80 00       	mov    0x804420,%eax
  801b34:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	57                   	push   %edi
  801b3b:	e8 90 05 00 00       	call   8020d0 <pageref>
  801b40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b43:	89 34 24             	mov    %esi,(%esp)
  801b46:	e8 85 05 00 00       	call   8020d0 <pageref>
		nn = thisenv->env_runs;
  801b4b:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	39 cb                	cmp    %ecx,%ebx
  801b59:	74 1b                	je     801b76 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b5b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b5e:	75 cf                	jne    801b2f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b60:	8b 42 58             	mov    0x58(%edx),%eax
  801b63:	6a 01                	push   $0x1
  801b65:	50                   	push   %eax
  801b66:	53                   	push   %ebx
  801b67:	68 37 2a 80 00       	push   $0x802a37
  801b6c:	e8 96 e7 ff ff       	call   800307 <cprintf>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb b9                	jmp    801b2f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b76:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b79:	0f 94 c0             	sete   %al
  801b7c:	0f b6 c0             	movzbl %al,%eax
}
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_write>:
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 28             	sub    $0x28,%esp
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b93:	56                   	push   %esi
  801b94:	e8 02 f7 ff ff       	call   80129b <fd2data>
  801b99:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ba6:	74 4f                	je     801bf7 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba8:	8b 43 04             	mov    0x4(%ebx),%eax
  801bab:	8b 0b                	mov    (%ebx),%ecx
  801bad:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb0:	39 d0                	cmp    %edx,%eax
  801bb2:	72 14                	jb     801bc8 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801bb4:	89 da                	mov    %ebx,%edx
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	e8 65 ff ff ff       	call   801b22 <_pipeisclosed>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	75 3a                	jne    801bfb <devpipe_write+0x74>
			sys_yield();
  801bc1:	e8 3a f1 ff ff       	call   800d00 <sys_yield>
  801bc6:	eb e0                	jmp    801ba8 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bcf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	c1 fa 1f             	sar    $0x1f,%edx
  801bd7:	89 d1                	mov    %edx,%ecx
  801bd9:	c1 e9 1b             	shr    $0x1b,%ecx
  801bdc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bdf:	83 e2 1f             	and    $0x1f,%edx
  801be2:	29 ca                	sub    %ecx,%edx
  801be4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801be8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bec:	83 c0 01             	add    $0x1,%eax
  801bef:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bf2:	83 c7 01             	add    $0x1,%edi
  801bf5:	eb ac                	jmp    801ba3 <devpipe_write+0x1c>
	return i;
  801bf7:	89 f8                	mov    %edi,%eax
  801bf9:	eb 05                	jmp    801c00 <devpipe_write+0x79>
				return 0;
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <devpipe_read>:
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	57                   	push   %edi
  801c0c:	56                   	push   %esi
  801c0d:	53                   	push   %ebx
  801c0e:	83 ec 18             	sub    $0x18,%esp
  801c11:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c14:	57                   	push   %edi
  801c15:	e8 81 f6 ff ff       	call   80129b <fd2data>
  801c1a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	be 00 00 00 00       	mov    $0x0,%esi
  801c24:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c27:	74 47                	je     801c70 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c29:	8b 03                	mov    (%ebx),%eax
  801c2b:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c2e:	75 22                	jne    801c52 <devpipe_read+0x4a>
			if (i > 0)
  801c30:	85 f6                	test   %esi,%esi
  801c32:	75 14                	jne    801c48 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c34:	89 da                	mov    %ebx,%edx
  801c36:	89 f8                	mov    %edi,%eax
  801c38:	e8 e5 fe ff ff       	call   801b22 <_pipeisclosed>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	75 33                	jne    801c74 <devpipe_read+0x6c>
			sys_yield();
  801c41:	e8 ba f0 ff ff       	call   800d00 <sys_yield>
  801c46:	eb e1                	jmp    801c29 <devpipe_read+0x21>
				return i;
  801c48:	89 f0                	mov    %esi,%eax
}
  801c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c52:	99                   	cltd   
  801c53:	c1 ea 1b             	shr    $0x1b,%edx
  801c56:	01 d0                	add    %edx,%eax
  801c58:	83 e0 1f             	and    $0x1f,%eax
  801c5b:	29 d0                	sub    %edx,%eax
  801c5d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c65:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c68:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c6b:	83 c6 01             	add    $0x1,%esi
  801c6e:	eb b4                	jmp    801c24 <devpipe_read+0x1c>
	return i;
  801c70:	89 f0                	mov    %esi,%eax
  801c72:	eb d6                	jmp    801c4a <devpipe_read+0x42>
				return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
  801c79:	eb cf                	jmp    801c4a <devpipe_read+0x42>

00801c7b <pipe>:
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	56                   	push   %esi
  801c7f:	53                   	push   %ebx
  801c80:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c86:	50                   	push   %eax
  801c87:	e8 26 f6 ff ff       	call   8012b2 <fd_alloc>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 5b                	js     801cf0 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c95:	83 ec 04             	sub    $0x4,%esp
  801c98:	68 07 04 00 00       	push   $0x407
  801c9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca0:	6a 00                	push   $0x0
  801ca2:	e8 78 f0 ff ff       	call   800d1f <sys_page_alloc>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 40                	js     801cf0 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	e8 f6 f5 ff ff       	call   8012b2 <fd_alloc>
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 1b                	js     801ce0 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc5:	83 ec 04             	sub    $0x4,%esp
  801cc8:	68 07 04 00 00       	push   $0x407
  801ccd:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd0:	6a 00                	push   $0x0
  801cd2:	e8 48 f0 ff ff       	call   800d1f <sys_page_alloc>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	85 c0                	test   %eax,%eax
  801cde:	79 19                	jns    801cf9 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 b7 f0 ff ff       	call   800da4 <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
}
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
	va = fd2data(fd0);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	e8 97 f5 ff ff       	call   80129b <fd2data>
  801d04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d06:	83 c4 0c             	add    $0xc,%esp
  801d09:	68 07 04 00 00       	push   $0x407
  801d0e:	50                   	push   %eax
  801d0f:	6a 00                	push   $0x0
  801d11:	e8 09 f0 ff ff       	call   800d1f <sys_page_alloc>
  801d16:	89 c3                	mov    %eax,%ebx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	0f 88 8c 00 00 00    	js     801daf <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	ff 75 f0             	pushl  -0x10(%ebp)
  801d29:	e8 6d f5 ff ff       	call   80129b <fd2data>
  801d2e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d35:	50                   	push   %eax
  801d36:	6a 00                	push   $0x0
  801d38:	56                   	push   %esi
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 22 f0 ff ff       	call   800d62 <sys_page_map>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	83 c4 20             	add    $0x20,%esp
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 58                	js     801da1 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d73:	83 ec 0c             	sub    $0xc,%esp
  801d76:	ff 75 f4             	pushl  -0xc(%ebp)
  801d79:	e8 0d f5 ff ff       	call   80128b <fd2num>
  801d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d83:	83 c4 04             	add    $0x4,%esp
  801d86:	ff 75 f0             	pushl  -0x10(%ebp)
  801d89:	e8 fd f4 ff ff       	call   80128b <fd2num>
  801d8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d91:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d9c:	e9 4f ff ff ff       	jmp    801cf0 <pipe+0x75>
	sys_page_unmap(0, va);
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	56                   	push   %esi
  801da5:	6a 00                	push   $0x0
  801da7:	e8 f8 ef ff ff       	call   800da4 <sys_page_unmap>
  801dac:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	ff 75 f0             	pushl  -0x10(%ebp)
  801db5:	6a 00                	push   $0x0
  801db7:	e8 e8 ef ff ff       	call   800da4 <sys_page_unmap>
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	e9 1c ff ff ff       	jmp    801ce0 <pipe+0x65>

00801dc4 <pipeisclosed>:
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcd:	50                   	push   %eax
  801dce:	ff 75 08             	pushl  0x8(%ebp)
  801dd1:	e8 2b f5 ff ff       	call   801301 <fd_lookup>
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 18                	js     801df5 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ddd:	83 ec 0c             	sub    $0xc,%esp
  801de0:	ff 75 f4             	pushl  -0xc(%ebp)
  801de3:	e8 b3 f4 ff ff       	call   80129b <fd2data>
	return _pipeisclosed(fd, p);
  801de8:	89 c2                	mov    %eax,%edx
  801dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ded:	e8 30 fd ff ff       	call   801b22 <_pipeisclosed>
  801df2:	83 c4 10             	add    $0x10,%esp
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801dff:	85 f6                	test   %esi,%esi
  801e01:	74 13                	je     801e16 <wait+0x1f>
	e = &envs[ENVX(envid)];
  801e03:	89 f3                	mov    %esi,%ebx
  801e05:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e0b:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e0e:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e14:	eb 1b                	jmp    801e31 <wait+0x3a>
	assert(envid != 0);
  801e16:	68 4f 2a 80 00       	push   $0x802a4f
  801e1b:	68 c3 29 80 00       	push   $0x8029c3
  801e20:	6a 09                	push   $0x9
  801e22:	68 5a 2a 80 00       	push   $0x802a5a
  801e27:	e8 00 e4 ff ff       	call   80022c <_panic>
		sys_yield();
  801e2c:	e8 cf ee ff ff       	call   800d00 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e31:	8b 43 48             	mov    0x48(%ebx),%eax
  801e34:	39 f0                	cmp    %esi,%eax
  801e36:	75 07                	jne    801e3f <wait+0x48>
  801e38:	8b 43 54             	mov    0x54(%ebx),%eax
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	75 ed                	jne    801e2c <wait+0x35>
}
  801e3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e42:	5b                   	pop    %ebx
  801e43:	5e                   	pop    %esi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e56:	68 65 2a 80 00       	push   $0x802a65
  801e5b:	ff 75 0c             	pushl  0xc(%ebp)
  801e5e:	e8 c3 ea ff ff       	call   800926 <strcpy>
	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <devcons_write>:
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	57                   	push   %edi
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
  801e70:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e76:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e7b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e81:	eb 2f                	jmp    801eb2 <devcons_write+0x48>
		m = n - tot;
  801e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e86:	29 f3                	sub    %esi,%ebx
  801e88:	83 fb 7f             	cmp    $0x7f,%ebx
  801e8b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e90:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e93:	83 ec 04             	sub    $0x4,%esp
  801e96:	53                   	push   %ebx
  801e97:	89 f0                	mov    %esi,%eax
  801e99:	03 45 0c             	add    0xc(%ebp),%eax
  801e9c:	50                   	push   %eax
  801e9d:	57                   	push   %edi
  801e9e:	e8 11 ec ff ff       	call   800ab4 <memmove>
		sys_cputs(buf, m);
  801ea3:	83 c4 08             	add    $0x8,%esp
  801ea6:	53                   	push   %ebx
  801ea7:	57                   	push   %edi
  801ea8:	e8 b6 ed ff ff       	call   800c63 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ead:	01 de                	add    %ebx,%esi
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eb5:	72 cc                	jb     801e83 <devcons_write+0x19>
}
  801eb7:	89 f0                	mov    %esi,%eax
  801eb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5f                   	pop    %edi
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <devcons_read>:
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 08             	sub    $0x8,%esp
  801ec7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ecc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ed0:	75 07                	jne    801ed9 <devcons_read+0x18>
}
  801ed2:	c9                   	leave  
  801ed3:	c3                   	ret    
		sys_yield();
  801ed4:	e8 27 ee ff ff       	call   800d00 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ed9:	e8 a3 ed ff ff       	call   800c81 <sys_cgetc>
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	74 f2                	je     801ed4 <devcons_read+0x13>
	if (c < 0)
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 ec                	js     801ed2 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801ee6:	83 f8 04             	cmp    $0x4,%eax
  801ee9:	74 0c                	je     801ef7 <devcons_read+0x36>
	*(char*)vbuf = c;
  801eeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eee:	88 02                	mov    %al,(%edx)
	return 1;
  801ef0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef5:	eb db                	jmp    801ed2 <devcons_read+0x11>
		return 0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	eb d4                	jmp    801ed2 <devcons_read+0x11>

00801efe <cputchar>:
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f0a:	6a 01                	push   $0x1
  801f0c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f0f:	50                   	push   %eax
  801f10:	e8 4e ed ff ff       	call   800c63 <sys_cputs>
}
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <getchar>:
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f20:	6a 01                	push   $0x1
  801f22:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f25:	50                   	push   %eax
  801f26:	6a 00                	push   $0x0
  801f28:	e8 45 f6 ff ff       	call   801572 <read>
	if (r < 0)
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	85 c0                	test   %eax,%eax
  801f32:	78 08                	js     801f3c <getchar+0x22>
	if (r < 1)
  801f34:	85 c0                	test   %eax,%eax
  801f36:	7e 06                	jle    801f3e <getchar+0x24>
	return c;
  801f38:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    
		return -E_EOF;
  801f3e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f43:	eb f7                	jmp    801f3c <getchar+0x22>

00801f45 <iscons>:
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4e:	50                   	push   %eax
  801f4f:	ff 75 08             	pushl  0x8(%ebp)
  801f52:	e8 aa f3 ff ff       	call   801301 <fd_lookup>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	78 11                	js     801f6f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f67:	39 10                	cmp    %edx,(%eax)
  801f69:	0f 94 c0             	sete   %al
  801f6c:	0f b6 c0             	movzbl %al,%eax
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <opencons>:
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	e8 32 f3 ff ff       	call   8012b2 <fd_alloc>
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 3a                	js     801fc1 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f87:	83 ec 04             	sub    $0x4,%esp
  801f8a:	68 07 04 00 00       	push   $0x407
  801f8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f92:	6a 00                	push   $0x0
  801f94:	e8 86 ed ff ff       	call   800d1f <sys_page_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 21                	js     801fc1 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	50                   	push   %eax
  801fb9:	e8 cd f2 ff ff       	call   80128b <fd2num>
  801fbe:	83 c4 10             	add    $0x10,%esp
}
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc4:	a1 24 44 80 00       	mov    0x804424,%eax
	call *%eax
  801fc9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fcb:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801fce:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801fd1:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801fd5:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801fd9:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801fdc:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801fe0:	89 18                	mov    %ebx,(%eax)

    popal
  801fe2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801fe3:	83 c4 04             	add    $0x4,%esp
    popfl
  801fe6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801fe7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801fe8:	c3                   	ret    

00801fe9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	8b 75 08             	mov    0x8(%ebp),%esi
  801ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ffe:	0f 44 c2             	cmove  %edx,%eax
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	50                   	push   %eax
  802005:	e8 c5 ee ff ff       	call   800ecf <sys_ipc_recv>
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 2b                	js     80203c <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  802011:	85 f6                	test   %esi,%esi
  802013:	74 0a                	je     80201f <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  802015:	a1 20 44 80 00       	mov    0x804420,%eax
  80201a:	8b 40 74             	mov    0x74(%eax),%eax
  80201d:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  80201f:	85 db                	test   %ebx,%ebx
  802021:	74 0a                	je     80202d <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  802023:	a1 20 44 80 00       	mov    0x804420,%eax
  802028:	8b 40 78             	mov    0x78(%eax),%eax
  80202b:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  80202d:	a1 20 44 80 00       	mov    0x804420,%eax
  802032:	8b 40 70             	mov    0x70(%eax),%eax
}
  802035:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
        *from_env_store = 0;
  80203c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  802042:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802048:	eb eb                	jmp    802035 <ipc_recv+0x4c>

0080204a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	83 ec 0c             	sub    $0xc,%esp
  802053:	8b 7d 08             	mov    0x8(%ebp),%edi
  802056:	8b 75 0c             	mov    0xc(%ebp),%esi
  802059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  80205c:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80205e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802063:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802066:	ff 75 14             	pushl  0x14(%ebp)
  802069:	53                   	push   %ebx
  80206a:	56                   	push   %esi
  80206b:	57                   	push   %edi
  80206c:	e8 3b ee ff ff       	call   800eac <sys_ipc_try_send>
  802071:	83 c4 10             	add    $0x10,%esp
  802074:	85 c0                	test   %eax,%eax
  802076:	74 17                	je     80208f <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802078:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80207b:	74 e9                	je     802066 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  80207d:	50                   	push   %eax
  80207e:	68 71 2a 80 00       	push   $0x802a71
  802083:	6a 3e                	push   $0x3e
  802085:	68 83 2a 80 00       	push   $0x802a83
  80208a:	e8 9d e1 ff ff       	call   80022c <_panic>
        }
    }
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    

00802097 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80209d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ab:	8b 52 50             	mov    0x50(%edx),%edx
  8020ae:	39 ca                	cmp    %ecx,%edx
  8020b0:	74 11                	je     8020c3 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020b2:	83 c0 01             	add    $0x1,%eax
  8020b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ba:	75 e6                	jne    8020a2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c1:	eb 0b                	jmp    8020ce <ipc_find_env+0x37>
			return envs[i].env_id;
  8020c3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020cb:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020ce:	5d                   	pop    %ebp
  8020cf:	c3                   	ret    

008020d0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	c1 e8 16             	shr    $0x16,%eax
  8020db:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e7:	f6 c1 01             	test   $0x1,%cl
  8020ea:	74 1d                	je     802109 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020ec:	c1 ea 0c             	shr    $0xc,%edx
  8020ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f6:	f6 c2 01             	test   $0x1,%dl
  8020f9:	74 0e                	je     802109 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fb:	c1 ea 0c             	shr    $0xc,%edx
  8020fe:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802105:	ef 
  802106:	0f b7 c0             	movzwl %ax,%eax
}
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    
  80210b:	66 90                	xchg   %ax,%ax
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802127:	85 d2                	test   %edx,%edx
  802129:	75 35                	jne    802160 <__udivdi3+0x50>
  80212b:	39 f3                	cmp    %esi,%ebx
  80212d:	0f 87 bd 00 00 00    	ja     8021f0 <__udivdi3+0xe0>
  802133:	85 db                	test   %ebx,%ebx
  802135:	89 d9                	mov    %ebx,%ecx
  802137:	75 0b                	jne    802144 <__udivdi3+0x34>
  802139:	b8 01 00 00 00       	mov    $0x1,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f3                	div    %ebx
  802142:	89 c1                	mov    %eax,%ecx
  802144:	31 d2                	xor    %edx,%edx
  802146:	89 f0                	mov    %esi,%eax
  802148:	f7 f1                	div    %ecx
  80214a:	89 c6                	mov    %eax,%esi
  80214c:	89 e8                	mov    %ebp,%eax
  80214e:	89 f7                	mov    %esi,%edi
  802150:	f7 f1                	div    %ecx
  802152:	89 fa                	mov    %edi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	39 f2                	cmp    %esi,%edx
  802162:	77 7c                	ja     8021e0 <__udivdi3+0xd0>
  802164:	0f bd fa             	bsr    %edx,%edi
  802167:	83 f7 1f             	xor    $0x1f,%edi
  80216a:	0f 84 98 00 00 00    	je     802208 <__udivdi3+0xf8>
  802170:	89 f9                	mov    %edi,%ecx
  802172:	b8 20 00 00 00       	mov    $0x20,%eax
  802177:	29 f8                	sub    %edi,%eax
  802179:	d3 e2                	shl    %cl,%edx
  80217b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	89 da                	mov    %ebx,%edx
  802183:	d3 ea                	shr    %cl,%edx
  802185:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802189:	09 d1                	or     %edx,%ecx
  80218b:	89 f2                	mov    %esi,%edx
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e3                	shl    %cl,%ebx
  802195:	89 c1                	mov    %eax,%ecx
  802197:	d3 ea                	shr    %cl,%edx
  802199:	89 f9                	mov    %edi,%ecx
  80219b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80219f:	d3 e6                	shl    %cl,%esi
  8021a1:	89 eb                	mov    %ebp,%ebx
  8021a3:	89 c1                	mov    %eax,%ecx
  8021a5:	d3 eb                	shr    %cl,%ebx
  8021a7:	09 de                	or     %ebx,%esi
  8021a9:	89 f0                	mov    %esi,%eax
  8021ab:	f7 74 24 08          	divl   0x8(%esp)
  8021af:	89 d6                	mov    %edx,%esi
  8021b1:	89 c3                	mov    %eax,%ebx
  8021b3:	f7 64 24 0c          	mull   0xc(%esp)
  8021b7:	39 d6                	cmp    %edx,%esi
  8021b9:	72 0c                	jb     8021c7 <__udivdi3+0xb7>
  8021bb:	89 f9                	mov    %edi,%ecx
  8021bd:	d3 e5                	shl    %cl,%ebp
  8021bf:	39 c5                	cmp    %eax,%ebp
  8021c1:	73 5d                	jae    802220 <__udivdi3+0x110>
  8021c3:	39 d6                	cmp    %edx,%esi
  8021c5:	75 59                	jne    802220 <__udivdi3+0x110>
  8021c7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ca:	31 ff                	xor    %edi,%edi
  8021cc:	89 fa                	mov    %edi,%edx
  8021ce:	83 c4 1c             	add    $0x1c,%esp
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    
  8021d6:	8d 76 00             	lea    0x0(%esi),%esi
  8021d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021e0:	31 ff                	xor    %edi,%edi
  8021e2:	31 c0                	xor    %eax,%eax
  8021e4:	89 fa                	mov    %edi,%edx
  8021e6:	83 c4 1c             	add    $0x1c,%esp
  8021e9:	5b                   	pop    %ebx
  8021ea:	5e                   	pop    %esi
  8021eb:	5f                   	pop    %edi
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    
  8021ee:	66 90                	xchg   %ax,%ax
  8021f0:	31 ff                	xor    %edi,%edi
  8021f2:	89 e8                	mov    %ebp,%eax
  8021f4:	89 f2                	mov    %esi,%edx
  8021f6:	f7 f3                	div    %ebx
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	72 06                	jb     802212 <__udivdi3+0x102>
  80220c:	31 c0                	xor    %eax,%eax
  80220e:	39 eb                	cmp    %ebp,%ebx
  802210:	77 d2                	ja     8021e4 <__udivdi3+0xd4>
  802212:	b8 01 00 00 00       	mov    $0x1,%eax
  802217:	eb cb                	jmp    8021e4 <__udivdi3+0xd4>
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	31 ff                	xor    %edi,%edi
  802224:	eb be                	jmp    8021e4 <__udivdi3+0xd4>
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80223b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80223f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 ed                	test   %ebp,%ebp
  802249:	89 f0                	mov    %esi,%eax
  80224b:	89 da                	mov    %ebx,%edx
  80224d:	75 19                	jne    802268 <__umoddi3+0x38>
  80224f:	39 df                	cmp    %ebx,%edi
  802251:	0f 86 b1 00 00 00    	jbe    802308 <__umoddi3+0xd8>
  802257:	f7 f7                	div    %edi
  802259:	89 d0                	mov    %edx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	83 c4 1c             	add    $0x1c,%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	39 dd                	cmp    %ebx,%ebp
  80226a:	77 f1                	ja     80225d <__umoddi3+0x2d>
  80226c:	0f bd cd             	bsr    %ebp,%ecx
  80226f:	83 f1 1f             	xor    $0x1f,%ecx
  802272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802276:	0f 84 b4 00 00 00    	je     802330 <__umoddi3+0x100>
  80227c:	b8 20 00 00 00       	mov    $0x20,%eax
  802281:	89 c2                	mov    %eax,%edx
  802283:	8b 44 24 04          	mov    0x4(%esp),%eax
  802287:	29 c2                	sub    %eax,%edx
  802289:	89 c1                	mov    %eax,%ecx
  80228b:	89 f8                	mov    %edi,%eax
  80228d:	d3 e5                	shl    %cl,%ebp
  80228f:	89 d1                	mov    %edx,%ecx
  802291:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802295:	d3 e8                	shr    %cl,%eax
  802297:	09 c5                	or     %eax,%ebp
  802299:	8b 44 24 04          	mov    0x4(%esp),%eax
  80229d:	89 c1                	mov    %eax,%ecx
  80229f:	d3 e7                	shl    %cl,%edi
  8022a1:	89 d1                	mov    %edx,%ecx
  8022a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8022a7:	89 df                	mov    %ebx,%edi
  8022a9:	d3 ef                	shr    %cl,%edi
  8022ab:	89 c1                	mov    %eax,%ecx
  8022ad:	89 f0                	mov    %esi,%eax
  8022af:	d3 e3                	shl    %cl,%ebx
  8022b1:	89 d1                	mov    %edx,%ecx
  8022b3:	89 fa                	mov    %edi,%edx
  8022b5:	d3 e8                	shr    %cl,%eax
  8022b7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022bc:	09 d8                	or     %ebx,%eax
  8022be:	f7 f5                	div    %ebp
  8022c0:	d3 e6                	shl    %cl,%esi
  8022c2:	89 d1                	mov    %edx,%ecx
  8022c4:	f7 64 24 08          	mull   0x8(%esp)
  8022c8:	39 d1                	cmp    %edx,%ecx
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	89 d7                	mov    %edx,%edi
  8022ce:	72 06                	jb     8022d6 <__umoddi3+0xa6>
  8022d0:	75 0e                	jne    8022e0 <__umoddi3+0xb0>
  8022d2:	39 c6                	cmp    %eax,%esi
  8022d4:	73 0a                	jae    8022e0 <__umoddi3+0xb0>
  8022d6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022da:	19 ea                	sbb    %ebp,%edx
  8022dc:	89 d7                	mov    %edx,%edi
  8022de:	89 c3                	mov    %eax,%ebx
  8022e0:	89 ca                	mov    %ecx,%edx
  8022e2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022e7:	29 de                	sub    %ebx,%esi
  8022e9:	19 fa                	sbb    %edi,%edx
  8022eb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022ef:	89 d0                	mov    %edx,%eax
  8022f1:	d3 e0                	shl    %cl,%eax
  8022f3:	89 d9                	mov    %ebx,%ecx
  8022f5:	d3 ee                	shr    %cl,%esi
  8022f7:	d3 ea                	shr    %cl,%edx
  8022f9:	09 f0                	or     %esi,%eax
  8022fb:	83 c4 1c             	add    $0x1c,%esp
  8022fe:	5b                   	pop    %ebx
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
  802303:	90                   	nop
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	85 ff                	test   %edi,%edi
  80230a:	89 f9                	mov    %edi,%ecx
  80230c:	75 0b                	jne    802319 <__umoddi3+0xe9>
  80230e:	b8 01 00 00 00       	mov    $0x1,%eax
  802313:	31 d2                	xor    %edx,%edx
  802315:	f7 f7                	div    %edi
  802317:	89 c1                	mov    %eax,%ecx
  802319:	89 d8                	mov    %ebx,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f1                	div    %ecx
  80231f:	89 f0                	mov    %esi,%eax
  802321:	f7 f1                	div    %ecx
  802323:	e9 31 ff ff ff       	jmp    802259 <__umoddi3+0x29>
  802328:	90                   	nop
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	39 dd                	cmp    %ebx,%ebp
  802332:	72 08                	jb     80233c <__umoddi3+0x10c>
  802334:	39 f7                	cmp    %esi,%edi
  802336:	0f 87 21 ff ff ff    	ja     80225d <__umoddi3+0x2d>
  80233c:	89 da                	mov    %ebx,%edx
  80233e:	89 f0                	mov    %esi,%eax
  802340:	29 f8                	sub    %edi,%eax
  802342:	19 ea                	sbb    %ebp,%edx
  802344:	e9 14 ff ff ff       	jmp    80225d <__umoddi3+0x2d>
