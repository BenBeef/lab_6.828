
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a1 01 00 00       	call   8001d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 28             	sub    $0x28,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 20 23 80 00       	push   $0x802320
  800041:	e8 c7 02 00 00       	call   80030d <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 30 1c 00 00       	call   801c81 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	78 5d                	js     8000b5 <umain+0x82>
		panic("pipe: %e", r);
	if ((r = fork()) < 0)
  800058:	e8 bf 10 00 00       	call   80111c <fork>
  80005d:	89 c7                	mov    %eax,%edi
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 64                	js     8000c7 <umain+0x94>
		panic("fork: %e", r);
	if (r == 0) {
  800063:	85 c0                	test   %eax,%eax
  800065:	74 72                	je     8000d9 <umain+0xa6>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800067:	89 fb                	mov    %edi,%ebx
  800069:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80006f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  800072:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800078:	8b 43 54             	mov    0x54(%ebx),%eax
  80007b:	83 f8 02             	cmp    $0x2,%eax
  80007e:	0f 85 d1 00 00 00    	jne    800155 <umain+0x122>
		if (pipeisclosed(p[0]) != 0) {
  800084:	83 ec 0c             	sub    $0xc,%esp
  800087:	ff 75 e0             	pushl  -0x20(%ebp)
  80008a:	e8 3b 1d 00 00       	call   801dca <pipeisclosed>
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	85 c0                	test   %eax,%eax
  800094:	74 e2                	je     800078 <umain+0x45>
			cprintf("\nRACE: pipe appears closed\n");
  800096:	83 ec 0c             	sub    $0xc,%esp
  800099:	68 99 23 80 00       	push   $0x802399
  80009e:	e8 6a 02 00 00       	call   80030d <cprintf>
			sys_env_destroy(r);
  8000a3:	89 3c 24             	mov    %edi,(%esp)
  8000a6:	e8 fb 0b 00 00       	call   800ca6 <sys_env_destroy>
			exit();
  8000ab:	e8 68 01 00 00       	call   800218 <exit>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb c3                	jmp    800078 <umain+0x45>
		panic("pipe: %e", r);
  8000b5:	50                   	push   %eax
  8000b6:	68 6e 23 80 00       	push   $0x80236e
  8000bb:	6a 0d                	push   $0xd
  8000bd:	68 77 23 80 00       	push   $0x802377
  8000c2:	e8 6b 01 00 00       	call   800232 <_panic>
		panic("fork: %e", r);
  8000c7:	50                   	push   %eax
  8000c8:	68 8c 23 80 00       	push   $0x80238c
  8000cd:	6a 0f                	push   $0xf
  8000cf:	68 77 23 80 00       	push   $0x802377
  8000d4:	e8 59 01 00 00       	call   800232 <_panic>
		close(p[1]);
  8000d9:	83 ec 0c             	sub    $0xc,%esp
  8000dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000df:	e8 58 13 00 00       	call   80143c <close>
  8000e4:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  8000e7:	89 fb                	mov    %edi,%ebx
			if (i % 10 == 0)
  8000e9:	be 67 66 66 66       	mov    $0x66666667,%esi
  8000ee:	eb 31                	jmp    800121 <umain+0xee>
			dup(p[0], 10);
  8000f0:	83 ec 08             	sub    $0x8,%esp
  8000f3:	6a 0a                	push   $0xa
  8000f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f8:	e8 8f 13 00 00       	call   80148c <dup>
			sys_yield();
  8000fd:	e8 04 0c 00 00       	call   800d06 <sys_yield>
			close(10);
  800102:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800109:	e8 2e 13 00 00       	call   80143c <close>
			sys_yield();
  80010e:	e8 f3 0b 00 00       	call   800d06 <sys_yield>
		for (i = 0; i < 200; i++) {
  800113:	83 c3 01             	add    $0x1,%ebx
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  80011f:	74 2a                	je     80014b <umain+0x118>
			if (i % 10 == 0)
  800121:	89 d8                	mov    %ebx,%eax
  800123:	f7 ee                	imul   %esi
  800125:	c1 fa 02             	sar    $0x2,%edx
  800128:	89 d8                	mov    %ebx,%eax
  80012a:	c1 f8 1f             	sar    $0x1f,%eax
  80012d:	29 c2                	sub    %eax,%edx
  80012f:	8d 04 92             	lea    (%edx,%edx,4),%eax
  800132:	01 c0                	add    %eax,%eax
  800134:	39 c3                	cmp    %eax,%ebx
  800136:	75 b8                	jne    8000f0 <umain+0xbd>
				cprintf("%d.", i);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	53                   	push   %ebx
  80013c:	68 95 23 80 00       	push   $0x802395
  800141:	e8 c7 01 00 00       	call   80030d <cprintf>
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	eb a5                	jmp    8000f0 <umain+0xbd>
		exit();
  80014b:	e8 c8 00 00 00       	call   800218 <exit>
  800150:	e9 12 ff ff ff       	jmp    800067 <umain+0x34>
		}
	cprintf("child done with loop\n");
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	68 b5 23 80 00       	push   $0x8023b5
  80015d:	e8 ab 01 00 00       	call   80030d <cprintf>
	if (pipeisclosed(p[0]))
  800162:	83 c4 04             	add    $0x4,%esp
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	e8 5d 1c 00 00       	call   801dca <pipeisclosed>
  80016d:	83 c4 10             	add    $0x10,%esp
  800170:	85 c0                	test   %eax,%eax
  800172:	75 38                	jne    8001ac <umain+0x179>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800174:	83 ec 08             	sub    $0x8,%esp
  800177:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	ff 75 e0             	pushl  -0x20(%ebp)
  80017e:	e8 84 11 00 00       	call   801307 <fd_lookup>
  800183:	83 c4 10             	add    $0x10,%esp
  800186:	85 c0                	test   %eax,%eax
  800188:	78 36                	js     8001c0 <umain+0x18d>
		panic("cannot look up p[0]: %e", r);
	(void) fd2data(fd);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 dc             	pushl  -0x24(%ebp)
  800190:	e8 0c 11 00 00       	call   8012a1 <fd2data>
	cprintf("race didn't happen\n");
  800195:	c7 04 24 e3 23 80 00 	movl   $0x8023e3,(%esp)
  80019c:	e8 6c 01 00 00       	call   80030d <cprintf>
}
  8001a1:	83 c4 10             	add    $0x10,%esp
  8001a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a7:	5b                   	pop    %ebx
  8001a8:	5e                   	pop    %esi
  8001a9:	5f                   	pop    %edi
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	68 44 23 80 00       	push   $0x802344
  8001b4:	6a 40                	push   $0x40
  8001b6:	68 77 23 80 00       	push   $0x802377
  8001bb:	e8 72 00 00 00       	call   800232 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c0:	50                   	push   %eax
  8001c1:	68 cb 23 80 00       	push   $0x8023cb
  8001c6:	6a 42                	push   $0x42
  8001c8:	68 77 23 80 00       	push   $0x802377
  8001cd:	e8 60 00 00 00       	call   800232 <_panic>

008001d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001dd:	e8 05 0b 00 00       	call   800ce7 <sys_getenvid>
  8001e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ef:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7e 07                	jle    8001ff <libmain+0x2d>
		binaryname = argv[0];
  8001f8:	8b 06                	mov    (%esi),%eax
  8001fa:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	e8 2a fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800209:	e8 0a 00 00 00       	call   800218 <exit>
}
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021e:	e8 44 12 00 00       	call   801467 <close_all>
	sys_env_destroy(0);
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	6a 00                	push   $0x0
  800228:	e8 79 0a 00 00       	call   800ca6 <sys_env_destroy>
}
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800240:	e8 a2 0a 00 00       	call   800ce7 <sys_getenvid>
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 0c             	pushl  0xc(%ebp)
  80024b:	ff 75 08             	pushl  0x8(%ebp)
  80024e:	56                   	push   %esi
  80024f:	50                   	push   %eax
  800250:	68 04 24 80 00       	push   $0x802404
  800255:	e8 b3 00 00 00       	call   80030d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	53                   	push   %ebx
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	e8 56 00 00 00       	call   8002bc <vcprintf>
	cprintf("\n");
  800266:	c7 04 24 a8 29 80 00 	movl   $0x8029a8,(%esp)
  80026d:	e8 9b 00 00 00       	call   80030d <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800275:	cc                   	int3   
  800276:	eb fd                	jmp    800275 <_panic+0x43>

00800278 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	53                   	push   %ebx
  80027c:	83 ec 04             	sub    $0x4,%esp
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800282:	8b 13                	mov    (%ebx),%edx
  800284:	8d 42 01             	lea    0x1(%edx),%eax
  800287:	89 03                	mov    %eax,(%ebx)
  800289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800290:	3d ff 00 00 00       	cmp    $0xff,%eax
  800295:	74 09                	je     8002a0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 b8 09 00 00       	call   800c69 <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	eb db                	jmp    800297 <putch+0x1f>

008002bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cc:	00 00 00 
	b.cnt = 0;
  8002cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d9:	ff 75 0c             	pushl  0xc(%ebp)
  8002dc:	ff 75 08             	pushl  0x8(%ebp)
  8002df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e5:	50                   	push   %eax
  8002e6:	68 78 02 80 00       	push   $0x800278
  8002eb:	e8 1a 01 00 00       	call   80040a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f0:	83 c4 08             	add    $0x8,%esp
  8002f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	e8 64 09 00 00       	call   800c69 <sys_cputs>

	return b.cnt;
}
  800305:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800313:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800316:	50                   	push   %eax
  800317:	ff 75 08             	pushl  0x8(%ebp)
  80031a:	e8 9d ff ff ff       	call   8002bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 1c             	sub    $0x1c,%esp
  80032a:	89 c7                	mov    %eax,%edi
  80032c:	89 d6                	mov    %edx,%esi
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	8b 55 0c             	mov    0xc(%ebp),%edx
  800334:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800337:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800345:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800348:	39 d3                	cmp    %edx,%ebx
  80034a:	72 05                	jb     800351 <printnum+0x30>
  80034c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80034f:	77 7a                	ja     8003cb <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 18             	pushl  0x18(%ebp)
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	ff 75 e4             	pushl  -0x1c(%ebp)
  800367:	ff 75 e0             	pushl  -0x20(%ebp)
  80036a:	ff 75 dc             	pushl  -0x24(%ebp)
  80036d:	ff 75 d8             	pushl  -0x28(%ebp)
  800370:	e8 5b 1d 00 00       	call   8020d0 <__udivdi3>
  800375:	83 c4 18             	add    $0x18,%esp
  800378:	52                   	push   %edx
  800379:	50                   	push   %eax
  80037a:	89 f2                	mov    %esi,%edx
  80037c:	89 f8                	mov    %edi,%eax
  80037e:	e8 9e ff ff ff       	call   800321 <printnum>
  800383:	83 c4 20             	add    $0x20,%esp
  800386:	eb 13                	jmp    80039b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	56                   	push   %esi
  80038c:	ff 75 18             	pushl  0x18(%ebp)
  80038f:	ff d7                	call   *%edi
  800391:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800394:	83 eb 01             	sub    $0x1,%ebx
  800397:	85 db                	test   %ebx,%ebx
  800399:	7f ed                	jg     800388 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	56                   	push   %esi
  80039f:	83 ec 04             	sub    $0x4,%esp
  8003a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ae:	e8 3d 1e 00 00       	call   8021f0 <__umoddi3>
  8003b3:	83 c4 14             	add    $0x14,%esp
  8003b6:	0f be 80 27 24 80 00 	movsbl 0x802427(%eax),%eax
  8003bd:	50                   	push   %eax
  8003be:	ff d7                	call   *%edi
}
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    
  8003cb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ce:	eb c4                	jmp    800394 <printnum+0x73>

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003df:	73 0a                	jae    8003eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e4:	89 08                	mov    %ecx,(%eax)
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	88 02                	mov    %al,(%edx)
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <printfmt>:
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f6:	50                   	push   %eax
  8003f7:	ff 75 10             	pushl  0x10(%ebp)
  8003fa:	ff 75 0c             	pushl  0xc(%ebp)
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	e8 05 00 00 00       	call   80040a <vprintfmt>
}
  800405:	83 c4 10             	add    $0x10,%esp
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <vprintfmt>:
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 2c             	sub    $0x2c,%esp
  800413:	8b 75 08             	mov    0x8(%ebp),%esi
  800416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800419:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041c:	e9 c1 03 00 00       	jmp    8007e2 <vprintfmt+0x3d8>
		padc = ' ';
  800421:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800425:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80042c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800433:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80043a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8d 47 01             	lea    0x1(%edi),%eax
  800442:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800445:	0f b6 17             	movzbl (%edi),%edx
  800448:	8d 42 dd             	lea    -0x23(%edx),%eax
  80044b:	3c 55                	cmp    $0x55,%al
  80044d:	0f 87 12 04 00 00    	ja     800865 <vprintfmt+0x45b>
  800453:	0f b6 c0             	movzbl %al,%eax
  800456:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800460:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800464:	eb d9                	jmp    80043f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800469:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046d:	eb d0                	jmp    80043f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	0f b6 d2             	movzbl %dl,%edx
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80047d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800480:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800484:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800487:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80048a:	83 f9 09             	cmp    $0x9,%ecx
  80048d:	77 55                	ja     8004e4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80048f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800492:	eb e9                	jmp    80047d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8b 00                	mov    (%eax),%eax
  800499:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 40 04             	lea    0x4(%eax),%eax
  8004a2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ac:	79 91                	jns    80043f <vprintfmt+0x35>
				width = precision, precision = -1;
  8004ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004bb:	eb 82                	jmp    80043f <vprintfmt+0x35>
  8004bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c7:	0f 49 d0             	cmovns %eax,%edx
  8004ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d0:	e9 6a ff ff ff       	jmp    80043f <vprintfmt+0x35>
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004df:	e9 5b ff ff ff       	jmp    80043f <vprintfmt+0x35>
  8004e4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ea:	eb bc                	jmp    8004a8 <vprintfmt+0x9e>
			lflag++;
  8004ec:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f2:	e9 48 ff ff ff       	jmp    80043f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 78 04             	lea    0x4(%eax),%edi
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 30                	pushl  (%eax)
  800503:	ff d6                	call   *%esi
			break;
  800505:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800508:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80050b:	e9 cf 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 78 04             	lea    0x4(%eax),%edi
  800516:	8b 00                	mov    (%eax),%eax
  800518:	99                   	cltd   
  800519:	31 d0                	xor    %edx,%eax
  80051b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 0f             	cmp    $0xf,%eax
  800520:	7f 23                	jg     800545 <vprintfmt+0x13b>
  800522:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80052d:	52                   	push   %edx
  80052e:	68 35 29 80 00       	push   $0x802935
  800533:	53                   	push   %ebx
  800534:	56                   	push   %esi
  800535:	e8 b3 fe ff ff       	call   8003ed <printfmt>
  80053a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80053d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800540:	e9 9a 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800545:	50                   	push   %eax
  800546:	68 3f 24 80 00       	push   $0x80243f
  80054b:	53                   	push   %ebx
  80054c:	56                   	push   %esi
  80054d:	e8 9b fe ff ff       	call   8003ed <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800555:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800558:	e9 82 02 00 00       	jmp    8007df <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	83 c0 04             	add    $0x4,%eax
  800563:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80056b:	85 ff                	test   %edi,%edi
  80056d:	b8 38 24 80 00       	mov    $0x802438,%eax
  800572:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	0f 8e bd 00 00 00    	jle    80063c <vprintfmt+0x232>
  80057f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800583:	75 0e                	jne    800593 <vprintfmt+0x189>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 6d                	jmp    800600 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	ff 75 d0             	pushl  -0x30(%ebp)
  800599:	57                   	push   %edi
  80059a:	e8 6e 03 00 00       	call   80090d <strnlen>
  80059f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a2:	29 c1                	sub    %eax,%ecx
  8005a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b6:	eb 0f                	jmp    8005c7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	53                   	push   %ebx
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c1:	83 ef 01             	sub    $0x1,%edi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	7f ed                	jg     8005b8 <vprintfmt+0x1ae>
  8005cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d8:	0f 49 c1             	cmovns %ecx,%eax
  8005db:	29 c1                	sub    %eax,%ecx
  8005dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	89 cb                	mov    %ecx,%ebx
  8005e8:	eb 16                	jmp    800600 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ee:	75 31                	jne    800621 <vprintfmt+0x217>
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	50                   	push   %eax
  8005f7:	ff 55 08             	call   *0x8(%ebp)
  8005fa:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fd:	83 eb 01             	sub    $0x1,%ebx
  800600:	83 c7 01             	add    $0x1,%edi
  800603:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800607:	0f be c2             	movsbl %dl,%eax
  80060a:	85 c0                	test   %eax,%eax
  80060c:	74 59                	je     800667 <vprintfmt+0x25d>
  80060e:	85 f6                	test   %esi,%esi
  800610:	78 d8                	js     8005ea <vprintfmt+0x1e0>
  800612:	83 ee 01             	sub    $0x1,%esi
  800615:	79 d3                	jns    8005ea <vprintfmt+0x1e0>
  800617:	89 df                	mov    %ebx,%edi
  800619:	8b 75 08             	mov    0x8(%ebp),%esi
  80061c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061f:	eb 37                	jmp    800658 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800621:	0f be d2             	movsbl %dl,%edx
  800624:	83 ea 20             	sub    $0x20,%edx
  800627:	83 fa 5e             	cmp    $0x5e,%edx
  80062a:	76 c4                	jbe    8005f0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 0c             	pushl  0xc(%ebp)
  800632:	6a 3f                	push   $0x3f
  800634:	ff 55 08             	call   *0x8(%ebp)
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	eb c1                	jmp    8005fd <vprintfmt+0x1f3>
  80063c:	89 75 08             	mov    %esi,0x8(%ebp)
  80063f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800642:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800645:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800648:	eb b6                	jmp    800600 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 20                	push   $0x20
  800650:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800652:	83 ef 01             	sub    $0x1,%edi
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 ff                	test   %edi,%edi
  80065a:	7f ee                	jg     80064a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80065c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	e9 78 01 00 00       	jmp    8007df <vprintfmt+0x3d5>
  800667:	89 df                	mov    %ebx,%edi
  800669:	8b 75 08             	mov    0x8(%ebp),%esi
  80066c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066f:	eb e7                	jmp    800658 <vprintfmt+0x24e>
	if (lflag >= 2)
  800671:	83 f9 01             	cmp    $0x1,%ecx
  800674:	7e 3f                	jle    8006b5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 50 04             	mov    0x4(%eax),%edx
  80067c:	8b 00                	mov    (%eax),%eax
  80067e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800681:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 40 08             	lea    0x8(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800691:	79 5c                	jns    8006ef <vprintfmt+0x2e5>
				putch('-', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 2d                	push   $0x2d
  800699:	ff d6                	call   *%esi
				num = -(long long) num;
  80069b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a1:	f7 da                	neg    %edx
  8006a3:	83 d1 00             	adc    $0x0,%ecx
  8006a6:	f7 d9                	neg    %ecx
  8006a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b0:	e9 10 01 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	75 1b                	jne    8006d4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c1:	89 c1                	mov    %eax,%ecx
  8006c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d2:	eb b9                	jmp    80068d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 c1                	mov    %eax,%ecx
  8006de:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ed:	eb 9e                	jmp    80068d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fa:	e9 c6 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 18                	jle    80071c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	e9 a9 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  80071c:	85 c9                	test   %ecx,%ecx
  80071e:	75 1a                	jne    80073a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072a:	8d 40 04             	lea    0x4(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 8b 00 00 00       	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074f:	eb 74                	jmp    8007c5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800751:	83 f9 01             	cmp    $0x1,%ecx
  800754:	7e 15                	jle    80076b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 10                	mov    (%eax),%edx
  80075b:	8b 48 04             	mov    0x4(%eax),%ecx
  80075e:	8d 40 08             	lea    0x8(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800764:	b8 08 00 00 00       	mov    $0x8,%eax
  800769:	eb 5a                	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	75 17                	jne    800786 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	b9 00 00 00 00       	mov    $0x0,%ecx
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80077f:	b8 08 00 00 00       	mov    $0x8,%eax
  800784:	eb 3f                	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800796:	b8 08 00 00 00       	mov    $0x8,%eax
  80079b:	eb 28                	jmp    8007c5 <vprintfmt+0x3bb>
			putch('0', putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	53                   	push   %ebx
  8007a1:	6a 30                	push   $0x30
  8007a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	53                   	push   %ebx
  8007a9:	6a 78                	push   $0x78
  8007ab:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007b7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ba:	8d 40 04             	lea    0x4(%eax),%eax
  8007bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007c5:	83 ec 0c             	sub    $0xc,%esp
  8007c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007cc:	57                   	push   %edi
  8007cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d0:	50                   	push   %eax
  8007d1:	51                   	push   %ecx
  8007d2:	52                   	push   %edx
  8007d3:	89 da                	mov    %ebx,%edx
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	e8 45 fb ff ff       	call   800321 <printnum>
			break;
  8007dc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e2:	83 c7 01             	add    $0x1,%edi
  8007e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e9:	83 f8 25             	cmp    $0x25,%eax
  8007ec:	0f 84 2f fc ff ff    	je     800421 <vprintfmt+0x17>
			if (ch == '\0')
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	0f 84 8b 00 00 00    	je     800885 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	53                   	push   %ebx
  8007fe:	50                   	push   %eax
  8007ff:	ff d6                	call   *%esi
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	eb dc                	jmp    8007e2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800806:	83 f9 01             	cmp    $0x1,%ecx
  800809:	7e 15                	jle    800820 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	8b 48 04             	mov    0x4(%eax),%ecx
  800813:	8d 40 08             	lea    0x8(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800819:	b8 10 00 00 00       	mov    $0x10,%eax
  80081e:	eb a5                	jmp    8007c5 <vprintfmt+0x3bb>
	else if (lflag)
  800820:	85 c9                	test   %ecx,%ecx
  800822:	75 17                	jne    80083b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800834:	b8 10 00 00 00       	mov    $0x10,%eax
  800839:	eb 8a                	jmp    8007c5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084b:	b8 10 00 00 00       	mov    $0x10,%eax
  800850:	e9 70 ff ff ff       	jmp    8007c5 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	53                   	push   %ebx
  800859:	6a 25                	push   $0x25
  80085b:	ff d6                	call   *%esi
			break;
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	e9 7a ff ff ff       	jmp    8007df <vprintfmt+0x3d5>
			putch('%', putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 25                	push   $0x25
  80086b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	89 f8                	mov    %edi,%eax
  800872:	eb 03                	jmp    800877 <vprintfmt+0x46d>
  800874:	83 e8 01             	sub    $0x1,%eax
  800877:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80087b:	75 f7                	jne    800874 <vprintfmt+0x46a>
  80087d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800880:	e9 5a ff ff ff       	jmp    8007df <vprintfmt+0x3d5>
}
  800885:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5f                   	pop    %edi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 18             	sub    $0x18,%esp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800899:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	74 26                	je     8008d4 <vsnprintf+0x47>
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	7e 22                	jle    8008d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b2:	ff 75 14             	pushl  0x14(%ebp)
  8008b5:	ff 75 10             	pushl  0x10(%ebp)
  8008b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bb:	50                   	push   %eax
  8008bc:	68 d0 03 80 00       	push   $0x8003d0
  8008c1:	e8 44 fb ff ff       	call   80040a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cf:	83 c4 10             	add    $0x10,%esp
}
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    
		return -E_INVAL;
  8008d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d9:	eb f7                	jmp    8008d2 <vsnprintf+0x45>

008008db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e4:	50                   	push   %eax
  8008e5:	ff 75 10             	pushl  0x10(%ebp)
  8008e8:	ff 75 0c             	pushl  0xc(%ebp)
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 9a ff ff ff       	call   80088d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800900:	eb 03                	jmp    800905 <strlen+0x10>
		n++;
  800902:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800905:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800909:	75 f7                	jne    800902 <strlen+0xd>
	return n;
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 03                	jmp    800920 <strnlen+0x13>
		n++;
  80091d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800920:	39 d0                	cmp    %edx,%eax
  800922:	74 06                	je     80092a <strnlen+0x1d>
  800924:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800928:	75 f3                	jne    80091d <strnlen+0x10>
	return n;
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800936:	89 c2                	mov    %eax,%edx
  800938:	83 c1 01             	add    $0x1,%ecx
  80093b:	83 c2 01             	add    $0x1,%edx
  80093e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800942:	88 5a ff             	mov    %bl,-0x1(%edx)
  800945:	84 db                	test   %bl,%bl
  800947:	75 ef                	jne    800938 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800949:	5b                   	pop    %ebx
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800953:	53                   	push   %ebx
  800954:	e8 9c ff ff ff       	call   8008f5 <strlen>
  800959:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	01 d8                	add    %ebx,%eax
  800961:	50                   	push   %eax
  800962:	e8 c5 ff ff ff       	call   80092c <strcpy>
	return dst;
}
  800967:	89 d8                	mov    %ebx,%eax
  800969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096c:	c9                   	leave  
  80096d:	c3                   	ret    

0080096e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 75 08             	mov    0x8(%ebp),%esi
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800979:	89 f3                	mov    %esi,%ebx
  80097b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097e:	89 f2                	mov    %esi,%edx
  800980:	eb 0f                	jmp    800991 <strncpy+0x23>
		*dst++ = *src;
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098b:	80 39 01             	cmpb   $0x1,(%ecx)
  80098e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800991:	39 da                	cmp    %ebx,%edx
  800993:	75 ed                	jne    800982 <strncpy+0x14>
	}
	return ret;
}
  800995:	89 f0                	mov    %esi,%eax
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a9:	89 f0                	mov    %esi,%eax
  8009ab:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009af:	85 c9                	test   %ecx,%ecx
  8009b1:	75 0b                	jne    8009be <strlcpy+0x23>
  8009b3:	eb 17                	jmp    8009cc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009be:	39 d8                	cmp    %ebx,%eax
  8009c0:	74 07                	je     8009c9 <strlcpy+0x2e>
  8009c2:	0f b6 0a             	movzbl (%edx),%ecx
  8009c5:	84 c9                	test   %cl,%cl
  8009c7:	75 ec                	jne    8009b5 <strlcpy+0x1a>
		*dst = '\0';
  8009c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cc:	29 f0                	sub    %esi,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009db:	eb 06                	jmp    8009e3 <strcmp+0x11>
		p++, q++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009e3:	0f b6 01             	movzbl (%ecx),%eax
  8009e6:	84 c0                	test   %al,%al
  8009e8:	74 04                	je     8009ee <strcmp+0x1c>
  8009ea:	3a 02                	cmp    (%edx),%al
  8009ec:	74 ef                	je     8009dd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 c0             	movzbl %al,%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c3                	mov    %eax,%ebx
  800a04:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a07:	eb 06                	jmp    800a0f <strncmp+0x17>
		n--, p++, q++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0f:	39 d8                	cmp    %ebx,%eax
  800a11:	74 16                	je     800a29 <strncmp+0x31>
  800a13:	0f b6 08             	movzbl (%eax),%ecx
  800a16:	84 c9                	test   %cl,%cl
  800a18:	74 04                	je     800a1e <strncmp+0x26>
  800a1a:	3a 0a                	cmp    (%edx),%cl
  800a1c:	74 eb                	je     800a09 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1e:	0f b6 00             	movzbl (%eax),%eax
  800a21:	0f b6 12             	movzbl (%edx),%edx
  800a24:	29 d0                	sub    %edx,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2e:	eb f6                	jmp    800a26 <strncmp+0x2e>

00800a30 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3a:	0f b6 10             	movzbl (%eax),%edx
  800a3d:	84 d2                	test   %dl,%dl
  800a3f:	74 09                	je     800a4a <strchr+0x1a>
		if (*s == c)
  800a41:	38 ca                	cmp    %cl,%dl
  800a43:	74 0a                	je     800a4f <strchr+0x1f>
	for (; *s; s++)
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	eb f0                	jmp    800a3a <strchr+0xa>
			return (char *) s;
	return 0;
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5b:	eb 03                	jmp    800a60 <strfind+0xf>
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a63:	38 ca                	cmp    %cl,%dl
  800a65:	74 04                	je     800a6b <strfind+0x1a>
  800a67:	84 d2                	test   %dl,%dl
  800a69:	75 f2                	jne    800a5d <strfind+0xc>
			break;
	return (char *) s;
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 13                	je     800a90 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a83:	75 05                	jne    800a8a <memset+0x1d>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	74 0d                	je     800a97 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8d:	fc                   	cld    
  800a8e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a90:	89 f8                	mov    %edi,%eax
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    
		c &= 0xFF;
  800a97:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9b:	89 d3                	mov    %edx,%ebx
  800a9d:	c1 e3 08             	shl    $0x8,%ebx
  800aa0:	89 d0                	mov    %edx,%eax
  800aa2:	c1 e0 18             	shl    $0x18,%eax
  800aa5:	89 d6                	mov    %edx,%esi
  800aa7:	c1 e6 10             	shl    $0x10,%esi
  800aaa:	09 f0                	or     %esi,%eax
  800aac:	09 c2                	or     %eax,%edx
  800aae:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ab0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab3:	89 d0                	mov    %edx,%eax
  800ab5:	fc                   	cld    
  800ab6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab8:	eb d6                	jmp    800a90 <memset+0x23>

00800aba <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac8:	39 c6                	cmp    %eax,%esi
  800aca:	73 35                	jae    800b01 <memmove+0x47>
  800acc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800acf:	39 c2                	cmp    %eax,%edx
  800ad1:	76 2e                	jbe    800b01 <memmove+0x47>
		s += n;
		d += n;
  800ad3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	09 fe                	or     %edi,%esi
  800ada:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae0:	74 0c                	je     800aee <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae2:	83 ef 01             	sub    $0x1,%edi
  800ae5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae8:	fd                   	std    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aeb:	fc                   	cld    
  800aec:	eb 21                	jmp    800b0f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aee:	f6 c1 03             	test   $0x3,%cl
  800af1:	75 ef                	jne    800ae2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af3:	83 ef 04             	sub    $0x4,%edi
  800af6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800afc:	fd                   	std    
  800afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aff:	eb ea                	jmp    800aeb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b01:	89 f2                	mov    %esi,%edx
  800b03:	09 c2                	or     %eax,%edx
  800b05:	f6 c2 03             	test   $0x3,%dl
  800b08:	74 09                	je     800b13 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0a:	89 c7                	mov    %eax,%edi
  800b0c:	fc                   	cld    
  800b0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	f6 c1 03             	test   $0x3,%cl
  800b16:	75 f2                	jne    800b0a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b18:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	fc                   	cld    
  800b1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b20:	eb ed                	jmp    800b0f <memmove+0x55>

00800b22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b25:	ff 75 10             	pushl  0x10(%ebp)
  800b28:	ff 75 0c             	pushl  0xc(%ebp)
  800b2b:	ff 75 08             	pushl  0x8(%ebp)
  800b2e:	e8 87 ff ff ff       	call   800aba <memmove>
}
  800b33:	c9                   	leave  
  800b34:	c3                   	ret    

00800b35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b40:	89 c6                	mov    %eax,%esi
  800b42:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b45:	39 f0                	cmp    %esi,%eax
  800b47:	74 1c                	je     800b65 <memcmp+0x30>
		if (*s1 != *s2)
  800b49:	0f b6 08             	movzbl (%eax),%ecx
  800b4c:	0f b6 1a             	movzbl (%edx),%ebx
  800b4f:	38 d9                	cmp    %bl,%cl
  800b51:	75 08                	jne    800b5b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b53:	83 c0 01             	add    $0x1,%eax
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	eb ea                	jmp    800b45 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b5b:	0f b6 c1             	movzbl %cl,%eax
  800b5e:	0f b6 db             	movzbl %bl,%ebx
  800b61:	29 d8                	sub    %ebx,%eax
  800b63:	eb 05                	jmp    800b6a <memcmp+0x35>
	}

	return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6a:	5b                   	pop    %ebx
  800b6b:	5e                   	pop    %esi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7c:	39 d0                	cmp    %edx,%eax
  800b7e:	73 09                	jae    800b89 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b80:	38 08                	cmp    %cl,(%eax)
  800b82:	74 05                	je     800b89 <memfind+0x1b>
	for (; s < ends; s++)
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	eb f3                	jmp    800b7c <memfind+0xe>
			break;
	return (void *) s;
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b97:	eb 03                	jmp    800b9c <strtol+0x11>
		s++;
  800b99:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b9c:	0f b6 01             	movzbl (%ecx),%eax
  800b9f:	3c 20                	cmp    $0x20,%al
  800ba1:	74 f6                	je     800b99 <strtol+0xe>
  800ba3:	3c 09                	cmp    $0x9,%al
  800ba5:	74 f2                	je     800b99 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba7:	3c 2b                	cmp    $0x2b,%al
  800ba9:	74 2e                	je     800bd9 <strtol+0x4e>
	int neg = 0;
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	74 2f                	je     800be3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bba:	75 05                	jne    800bc1 <strtol+0x36>
  800bbc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbf:	74 2c                	je     800bed <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc1:	85 db                	test   %ebx,%ebx
  800bc3:	75 0a                	jne    800bcf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bca:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcd:	74 28                	je     800bf7 <strtol+0x6c>
		base = 10;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd7:	eb 50                	jmp    800c29 <strtol+0x9e>
		s++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
  800be1:	eb d1                	jmp    800bb4 <strtol+0x29>
		s++, neg = 1;
  800be3:	83 c1 01             	add    $0x1,%ecx
  800be6:	bf 01 00 00 00       	mov    $0x1,%edi
  800beb:	eb c7                	jmp    800bb4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf1:	74 0e                	je     800c01 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	75 d8                	jne    800bcf <strtol+0x44>
		s++, base = 8;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bff:	eb ce                	jmp    800bcf <strtol+0x44>
		s += 2, base = 16;
  800c01:	83 c1 02             	add    $0x2,%ecx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb c4                	jmp    800bcf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 29                	ja     800c3e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c15:	0f be d2             	movsbl %dl,%edx
  800c18:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1e:	7d 30                	jge    800c50 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c20:	83 c1 01             	add    $0x1,%ecx
  800c23:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c27:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c29:	0f b6 11             	movzbl (%ecx),%edx
  800c2c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2f:	89 f3                	mov    %esi,%ebx
  800c31:	80 fb 09             	cmp    $0x9,%bl
  800c34:	77 d5                	ja     800c0b <strtol+0x80>
			dig = *s - '0';
  800c36:	0f be d2             	movsbl %dl,%edx
  800c39:	83 ea 30             	sub    $0x30,%edx
  800c3c:	eb dd                	jmp    800c1b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 08                	ja     800c50 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c48:	0f be d2             	movsbl %dl,%edx
  800c4b:	83 ea 37             	sub    $0x37,%edx
  800c4e:	eb cb                	jmp    800c1b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c54:	74 05                	je     800c5b <strtol+0xd0>
		*endptr = (char *) s;
  800c56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	f7 da                	neg    %edx
  800c5f:	85 ff                	test   %edi,%edi
  800c61:	0f 45 c2             	cmovne %edx,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	89 c3                	mov    %eax,%ebx
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	89 c6                	mov    %eax,%esi
  800c80:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbc:	89 cb                	mov    %ecx,%ebx
  800cbe:	89 cf                	mov    %ecx,%edi
  800cc0:	89 ce                	mov    %ecx,%esi
  800cc2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7f 08                	jg     800cd0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	50                   	push   %eax
  800cd4:	6a 03                	push   $0x3
  800cd6:	68 1f 27 80 00       	push   $0x80271f
  800cdb:	6a 23                	push   $0x23
  800cdd:	68 3c 27 80 00       	push   $0x80273c
  800ce2:	e8 4b f5 ff ff       	call   800232 <_panic>

00800ce7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_yield>:

void
sys_yield(void)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d16:	89 d1                	mov    %edx,%ecx
  800d18:	89 d3                	mov    %edx,%ebx
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	89 d6                	mov    %edx,%esi
  800d1e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	89 f7                	mov    %esi,%edi
  800d43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7f 08                	jg     800d51 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	50                   	push   %eax
  800d55:	6a 04                	push   $0x4
  800d57:	68 1f 27 80 00       	push   $0x80271f
  800d5c:	6a 23                	push   $0x23
  800d5e:	68 3c 27 80 00       	push   $0x80273c
  800d63:	e8 ca f4 ff ff       	call   800232 <_panic>

00800d68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d82:	8b 75 18             	mov    0x18(%ebp),%esi
  800d85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7f 08                	jg     800d93 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5f                   	pop    %edi
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 05                	push   $0x5
  800d99:	68 1f 27 80 00       	push   $0x80271f
  800d9e:	6a 23                	push   $0x23
  800da0:	68 3c 27 80 00       	push   $0x80273c
  800da5:	e8 88 f4 ff ff       	call   800232 <_panic>

00800daa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbe:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7f 08                	jg     800dd5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	50                   	push   %eax
  800dd9:	6a 06                	push   $0x6
  800ddb:	68 1f 27 80 00       	push   $0x80271f
  800de0:	6a 23                	push   $0x23
  800de2:	68 3c 27 80 00       	push   $0x80273c
  800de7:	e8 46 f4 ff ff       	call   800232 <_panic>

00800dec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
  800df2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	b8 08 00 00 00       	mov    $0x8,%eax
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	7f 08                	jg     800e17 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	50                   	push   %eax
  800e1b:	6a 08                	push   $0x8
  800e1d:	68 1f 27 80 00       	push   $0x80271f
  800e22:	6a 23                	push   $0x23
  800e24:	68 3c 27 80 00       	push   $0x80273c
  800e29:	e8 04 f4 ff ff       	call   800232 <_panic>

00800e2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	b8 09 00 00 00       	mov    $0x9,%eax
  800e47:	89 df                	mov    %ebx,%edi
  800e49:	89 de                	mov    %ebx,%esi
  800e4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7f 08                	jg     800e59 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e59:	83 ec 0c             	sub    $0xc,%esp
  800e5c:	50                   	push   %eax
  800e5d:	6a 09                	push   $0x9
  800e5f:	68 1f 27 80 00       	push   $0x80271f
  800e64:	6a 23                	push   $0x23
  800e66:	68 3c 27 80 00       	push   $0x80273c
  800e6b:	e8 c2 f3 ff ff       	call   800232 <_panic>

00800e70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e84:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e89:	89 df                	mov    %ebx,%edi
  800e8b:	89 de                	mov    %ebx,%esi
  800e8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	7f 08                	jg     800e9b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5f                   	pop    %edi
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	50                   	push   %eax
  800e9f:	6a 0a                	push   $0xa
  800ea1:	68 1f 27 80 00       	push   $0x80271f
  800ea6:	6a 23                	push   $0x23
  800ea8:	68 3c 27 80 00       	push   $0x80273c
  800ead:	e8 80 f3 ff ff       	call   800232 <_panic>

00800eb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec3:	be 00 00 00 00       	mov    $0x0,%esi
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ece:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ede:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eeb:	89 cb                	mov    %ecx,%ebx
  800eed:	89 cf                	mov    %ecx,%edi
  800eef:	89 ce                	mov    %ecx,%esi
  800ef1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7f 08                	jg     800eff <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 0d                	push   $0xd
  800f05:	68 1f 27 80 00       	push   $0x80271f
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 3c 27 80 00       	push   $0x80273c
  800f11:	e8 1c f3 ff ff       	call   800232 <_panic>

00800f16 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 04             	sub    $0x4,%esp
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f20:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f22:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f25:	a8 02                	test   $0x2,%al
  800f27:	0f 84 89 00 00 00    	je     800fb6 <pgfault+0xa0>
  800f2d:	89 da                	mov    %ebx,%edx
  800f2f:	c1 ea 0c             	shr    $0xc,%edx
  800f32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f39:	f6 c6 08             	test   $0x8,%dh
  800f3c:	74 78                	je     800fb6 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	6a 07                	push   $0x7
  800f43:	68 00 f0 7f 00       	push   $0x7ff000
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 d6 fd ff ff       	call   800d25 <sys_page_alloc>
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	0f 88 8b 00 00 00    	js     800fe5 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 00 10 00 00       	push   $0x1000
  800f62:	53                   	push   %ebx
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	e8 4d fb ff ff       	call   800aba <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 e5 fd ff ff       	call   800d68 <sys_page_map>
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 6d                	js     800ff7 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f8a:	83 ec 08             	sub    $0x8,%esp
  800f8d:	68 00 f0 7f 00       	push   $0x7ff000
  800f92:	6a 00                	push   $0x0
  800f94:	e8 11 fe ff ff       	call   800daa <sys_page_unmap>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 69                	js     801009 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800fa0:	83 ec 08             	sub    $0x8,%esp
  800fa3:	53                   	push   %ebx
  800fa4:	68 a8 27 80 00       	push   $0x8027a8
  800fa9:	e8 5f f3 ff ff       	call   80030d <cprintf>

}
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800fb6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fbc:	8b 4a 48             	mov    0x48(%edx),%ecx
  800fbf:	89 da                	mov    %ebx,%edx
  800fc1:	c1 ea 0c             	shr    $0xc,%edx
  800fc4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcb:	51                   	push   %ecx
  800fcc:	53                   	push   %ebx
  800fcd:	68 00 00 40 ef       	push   $0xef400000
  800fd2:	52                   	push   %edx
  800fd3:	50                   	push   %eax
  800fd4:	68 4c 27 80 00       	push   $0x80274c
  800fd9:	6a 1e                	push   $0x1e
  800fdb:	68 c9 27 80 00       	push   $0x8027c9
  800fe0:	e8 4d f2 ff ff       	call   800232 <_panic>
        panic("sys_page_alloc error %e", r);
  800fe5:	50                   	push   %eax
  800fe6:	68 d4 27 80 00       	push   $0x8027d4
  800feb:	6a 28                	push   $0x28
  800fed:	68 c9 27 80 00       	push   $0x8027c9
  800ff2:	e8 3b f2 ff ff       	call   800232 <_panic>
        panic("sys_page_map error %e", r);
  800ff7:	50                   	push   %eax
  800ff8:	68 ec 27 80 00       	push   $0x8027ec
  800ffd:	6a 2b                	push   $0x2b
  800fff:	68 c9 27 80 00       	push   $0x8027c9
  801004:	e8 29 f2 ff ff       	call   800232 <_panic>
        panic("sys_page_unmap error %e", r);
  801009:	50                   	push   %eax
  80100a:	68 02 28 80 00       	push   $0x802802
  80100f:	6a 2d                	push   $0x2d
  801011:	68 c9 27 80 00       	push   $0x8027c9
  801016:	e8 17 f2 ff ff       	call   800232 <_panic>

0080101b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801021:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801028:	74 23                	je     80104d <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
  80102d:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801032:	a1 04 40 80 00       	mov    0x804004,%eax
  801037:	8b 40 48             	mov    0x48(%eax),%eax
  80103a:	83 ec 08             	sub    $0x8,%esp
  80103d:	68 7a 1f 80 00       	push   $0x801f7a
  801042:	50                   	push   %eax
  801043:	e8 28 fe ff ff       	call   800e70 <sys_env_set_pgfault_upcall>
}
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 48             	mov    0x48(%eax),%eax
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	6a 07                	push   $0x7
  80105a:	68 00 f0 bf ee       	push   $0xeebff000
  80105f:	50                   	push   %eax
  801060:	e8 c0 fc ff ff       	call   800d25 <sys_page_alloc>
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	79 be                	jns    80102a <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  80106c:	50                   	push   %eax
  80106d:	68 1a 28 80 00       	push   $0x80281a
  801072:	6a 21                	push   $0x21
  801074:	68 2d 28 80 00       	push   $0x80282d
  801079:	e8 b4 f1 ff ff       	call   800232 <_panic>

0080107e <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	8b 75 08             	mov    0x8(%ebp),%esi
  801086:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	6a 07                	push   $0x7
  80108e:	53                   	push   %ebx
  80108f:	56                   	push   %esi
  801090:	e8 90 fc ff ff       	call   800d25 <sys_page_alloc>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 4a                	js     8010e6 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	6a 07                	push   $0x7
  8010a1:	68 00 00 40 00       	push   $0x400000
  8010a6:	6a 00                	push   $0x0
  8010a8:	53                   	push   %ebx
  8010a9:	56                   	push   %esi
  8010aa:	e8 b9 fc ff ff       	call   800d68 <sys_page_map>
  8010af:	83 c4 20             	add    $0x20,%esp
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	78 42                	js     8010f8 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	68 00 10 00 00       	push   $0x1000
  8010be:	53                   	push   %ebx
  8010bf:	68 00 00 40 00       	push   $0x400000
  8010c4:	e8 f1 f9 ff ff       	call   800aba <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	68 00 00 40 00       	push   $0x400000
  8010d1:	6a 00                	push   $0x0
  8010d3:	e8 d2 fc ff ff       	call   800daa <sys_page_unmap>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 2b                	js     80110a <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  8010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 1a 28 80 00       	push   $0x80281a
  8010ec:	6a 63                	push   $0x63
  8010ee:	68 c9 27 80 00       	push   $0x8027c9
  8010f3:	e8 3a f1 ff ff       	call   800232 <_panic>
        panic("sys_page_map: %e", r);
  8010f8:	50                   	push   %eax
  8010f9:	68 3d 28 80 00       	push   $0x80283d
  8010fe:	6a 65                	push   $0x65
  801100:	68 c9 27 80 00       	push   $0x8027c9
  801105:	e8 28 f1 ff ff       	call   800232 <_panic>
        panic("sys_page_unmap: %e", r);
  80110a:	50                   	push   %eax
  80110b:	68 4e 28 80 00       	push   $0x80284e
  801110:	6a 68                	push   $0x68
  801112:	68 c9 27 80 00       	push   $0x8027c9
  801117:	e8 16 f1 ff ff       	call   800232 <_panic>

0080111c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801125:	a1 04 40 80 00       	mov    0x804004,%eax
  80112a:	8b 40 64             	mov    0x64(%eax),%eax
  80112d:	85 c0                	test   %eax,%eax
  80112f:	74 1f                	je     801150 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801131:	b8 07 00 00 00       	mov    $0x7,%eax
  801136:	cd 30                	int    $0x30
  801138:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  80113a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80113d:	85 c0                	test   %eax,%eax
  80113f:	74 21                	je     801162 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801141:	be 08 40 80 00       	mov    $0x804008,%esi
  801146:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114e:	eb 7b                	jmp    8011cb <fork+0xaf>
        set_pgfault_handler(pgfault);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	68 16 0f 80 00       	push   $0x800f16
  801158:	e8 be fe ff ff       	call   80101b <set_pgfault_handler>
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	eb cf                	jmp    801131 <fork+0x15>
        set_pgfault_handler(pgfault);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	68 16 0f 80 00       	push   $0x800f16
  80116a:	e8 ac fe ff ff       	call   80101b <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  80116f:	e8 73 fb ff ff       	call   800ce7 <sys_getenvid>
  801174:	25 ff 03 00 00       	and    $0x3ff,%eax
  801179:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80117c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801181:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	e9 ca 00 00 00       	jmp    801258 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  80118e:	89 d1                	mov    %edx,%ecx
  801190:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801196:	81 e2 02 08 00 00    	and    $0x802,%edx
  80119c:	89 cf                	mov    %ecx,%edi
  80119e:	81 cf 00 08 00 00    	or     $0x800,%edi
  8011a4:	85 d2                	test   %edx,%edx
  8011a6:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	51                   	push   %ecx
  8011ad:	50                   	push   %eax
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	50                   	push   %eax
  8011b2:	6a 00                	push   $0x0
  8011b4:	e8 af fb ff ff       	call   800d68 <sys_page_map>
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	78 45                	js     801205 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8011c0:	83 c3 01             	add    $0x1,%ebx
  8011c3:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8011c9:	74 4c                	je     801217 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8011cb:	39 de                	cmp    %ebx,%esi
  8011cd:	74 f1                	je     8011c0 <fork+0xa4>
  8011cf:	89 d8                	mov    %ebx,%eax
  8011d1:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	c1 ea 16             	shr    $0x16,%edx
  8011d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8011e0:	f6 c2 05             	test   $0x5,%dl
  8011e3:	74 db                	je     8011c0 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 ea 0c             	shr    $0xc,%edx
  8011ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8011f1:	f6 c2 04             	test   $0x4,%dl
  8011f4:	74 ca                	je     8011c0 <fork+0xa4>
    if (perm & PTE_SHARE) {
  8011f6:	f6 c6 04             	test   $0x4,%dh
  8011f9:	74 93                	je     80118e <fork+0x72>
        perm &= ~PTE_COW;
  8011fb:	89 d1                	mov    %edx,%ecx
  8011fd:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801203:	eb a4                	jmp    8011a9 <fork+0x8d>
        panic("sys_page_map error %e", r);
  801205:	50                   	push   %eax
  801206:	68 ec 27 80 00       	push   $0x8027ec
  80120b:	6a 57                	push   $0x57
  80120d:	68 c9 27 80 00       	push   $0x8027c9
  801212:	e8 1b f0 ff ff       	call   800232 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	b8 08 40 80 00       	mov    $0x804008,%eax
  80121f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801224:	50                   	push   %eax
  801225:	ff 75 e4             	pushl  -0x1c(%ebp)
  801228:	e8 51 fe ff ff       	call   80107e <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801233:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801238:	50                   	push   %eax
  801239:	ff 75 e4             	pushl  -0x1c(%ebp)
  80123c:	e8 3d fe ff ff       	call   80107e <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	6a 02                	push   $0x2
  801246:	ff 75 e4             	pushl  -0x1c(%ebp)
  801249:	e8 9e fb ff ff       	call   800dec <sys_env_set_status>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 0d                	js     801262 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801255:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801258:	89 d8                	mov    %ebx,%eax
  80125a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801262:	50                   	push   %eax
  801263:	68 61 28 80 00       	push   $0x802861
  801268:	68 a0 00 00 00       	push   $0xa0
  80126d:	68 c9 27 80 00       	push   $0x8027c9
  801272:	e8 bb ef ff ff       	call   800232 <_panic>

00801277 <sfork>:

// Challenge!
int
sfork(void)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80127d:	68 78 28 80 00       	push   $0x802878
  801282:	68 a9 00 00 00       	push   $0xa9
  801287:	68 c9 27 80 00       	push   $0x8027c9
  80128c:	e8 a1 ef ff ff       	call   800232 <_panic>

00801291 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801294:	8b 45 08             	mov    0x8(%ebp),%eax
  801297:	05 00 00 00 30       	add    $0x30000000,%eax
  80129c:	c1 e8 0c             	shr    $0xc,%eax
}
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a7:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	c1 ea 16             	shr    $0x16,%edx
  8012c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012cf:	f6 c2 01             	test   $0x1,%dl
  8012d2:	74 2a                	je     8012fe <fd_alloc+0x46>
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	c1 ea 0c             	shr    $0xc,%edx
  8012d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e0:	f6 c2 01             	test   $0x1,%dl
  8012e3:	74 19                	je     8012fe <fd_alloc+0x46>
  8012e5:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ef:	75 d2                	jne    8012c3 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012f1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012fc:	eb 07                	jmp    801305 <fd_alloc+0x4d>
			*fd_store = fd;
  8012fe:	89 01                	mov    %eax,(%ecx)
			return 0;
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80130d:	83 f8 1f             	cmp    $0x1f,%eax
  801310:	77 36                	ja     801348 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801312:	c1 e0 0c             	shl    $0xc,%eax
  801315:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	c1 ea 16             	shr    $0x16,%edx
  80131f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801326:	f6 c2 01             	test   $0x1,%dl
  801329:	74 24                	je     80134f <fd_lookup+0x48>
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	c1 ea 0c             	shr    $0xc,%edx
  801330:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 1a                	je     801356 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80133c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133f:	89 02                	mov    %eax,(%edx)
	return 0;
  801341:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    
		return -E_INVAL;
  801348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134d:	eb f7                	jmp    801346 <fd_lookup+0x3f>
		return -E_INVAL;
  80134f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801354:	eb f0                	jmp    801346 <fd_lookup+0x3f>
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135b:	eb e9                	jmp    801346 <fd_lookup+0x3f>

0080135d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801366:	ba 0c 29 80 00       	mov    $0x80290c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80136b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801370:	39 08                	cmp    %ecx,(%eax)
  801372:	74 33                	je     8013a7 <dev_lookup+0x4a>
  801374:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801377:	8b 02                	mov    (%edx),%eax
  801379:	85 c0                	test   %eax,%eax
  80137b:	75 f3                	jne    801370 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80137d:	a1 04 40 80 00       	mov    0x804004,%eax
  801382:	8b 40 48             	mov    0x48(%eax),%eax
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	51                   	push   %ecx
  801389:	50                   	push   %eax
  80138a:	68 90 28 80 00       	push   $0x802890
  80138f:	e8 79 ef ff ff       	call   80030d <cprintf>
	*dev = 0;
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    
			*dev = devtab[i];
  8013a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b1:	eb f2                	jmp    8013a5 <dev_lookup+0x48>

008013b3 <fd_close>:
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	57                   	push   %edi
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 1c             	sub    $0x1c,%esp
  8013bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8013bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013cc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013cf:	50                   	push   %eax
  8013d0:	e8 32 ff ff ff       	call   801307 <fd_lookup>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 05                	js     8013e3 <fd_close+0x30>
	    || fd != fd2)
  8013de:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013e1:	74 16                	je     8013f9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013e3:	89 f8                	mov    %edi,%eax
  8013e5:	84 c0                	test   %al,%al
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	0f 44 d8             	cmove  %eax,%ebx
}
  8013ef:	89 d8                	mov    %ebx,%eax
  8013f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f4:	5b                   	pop    %ebx
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	ff 36                	pushl  (%esi)
  801402:	e8 56 ff ff ff       	call   80135d <dev_lookup>
  801407:	89 c3                	mov    %eax,%ebx
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 15                	js     801425 <fd_close+0x72>
		if (dev->dev_close)
  801410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801413:	8b 40 10             	mov    0x10(%eax),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	74 1b                	je     801435 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	56                   	push   %esi
  80141e:	ff d0                	call   *%eax
  801420:	89 c3                	mov    %eax,%ebx
  801422:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	56                   	push   %esi
  801429:	6a 00                	push   $0x0
  80142b:	e8 7a f9 ff ff       	call   800daa <sys_page_unmap>
	return r;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	eb ba                	jmp    8013ef <fd_close+0x3c>
			r = 0;
  801435:	bb 00 00 00 00       	mov    $0x0,%ebx
  80143a:	eb e9                	jmp    801425 <fd_close+0x72>

0080143c <close>:

int
close(int fdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 b9 fe ff ff       	call   801307 <fd_lookup>
  80144e:	83 c4 08             	add    $0x8,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 10                	js     801465 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	6a 01                	push   $0x1
  80145a:	ff 75 f4             	pushl  -0xc(%ebp)
  80145d:	e8 51 ff ff ff       	call   8013b3 <fd_close>
  801462:	83 c4 10             	add    $0x10,%esp
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <close_all>:

void
close_all(void)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	53                   	push   %ebx
  80146b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80146e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	53                   	push   %ebx
  801477:	e8 c0 ff ff ff       	call   80143c <close>
	for (i = 0; i < MAXFD; i++)
  80147c:	83 c3 01             	add    $0x1,%ebx
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	83 fb 20             	cmp    $0x20,%ebx
  801485:	75 ec                	jne    801473 <close_all+0xc>
}
  801487:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148a:	c9                   	leave  
  80148b:	c3                   	ret    

0080148c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	57                   	push   %edi
  801490:	56                   	push   %esi
  801491:	53                   	push   %ebx
  801492:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801495:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 66 fe ff ff       	call   801307 <fd_lookup>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	0f 88 81 00 00 00    	js     80152f <dup+0xa3>
		return r;
	close(newfdnum);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	ff 75 0c             	pushl  0xc(%ebp)
  8014b4:	e8 83 ff ff ff       	call   80143c <close>

	newfd = INDEX2FD(newfdnum);
  8014b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014bc:	c1 e6 0c             	shl    $0xc,%esi
  8014bf:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014c5:	83 c4 04             	add    $0x4,%esp
  8014c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014cb:	e8 d1 fd ff ff       	call   8012a1 <fd2data>
  8014d0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014d2:	89 34 24             	mov    %esi,(%esp)
  8014d5:	e8 c7 fd ff ff       	call   8012a1 <fd2data>
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	c1 e8 16             	shr    $0x16,%eax
  8014e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014eb:	a8 01                	test   $0x1,%al
  8014ed:	74 11                	je     801500 <dup+0x74>
  8014ef:	89 d8                	mov    %ebx,%eax
  8014f1:	c1 e8 0c             	shr    $0xc,%eax
  8014f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014fb:	f6 c2 01             	test   $0x1,%dl
  8014fe:	75 39                	jne    801539 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801503:	89 d0                	mov    %edx,%eax
  801505:	c1 e8 0c             	shr    $0xc,%eax
  801508:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150f:	83 ec 0c             	sub    $0xc,%esp
  801512:	25 07 0e 00 00       	and    $0xe07,%eax
  801517:	50                   	push   %eax
  801518:	56                   	push   %esi
  801519:	6a 00                	push   $0x0
  80151b:	52                   	push   %edx
  80151c:	6a 00                	push   $0x0
  80151e:	e8 45 f8 ff ff       	call   800d68 <sys_page_map>
  801523:	89 c3                	mov    %eax,%ebx
  801525:	83 c4 20             	add    $0x20,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 31                	js     80155d <dup+0xd1>
		goto err;

	return newfdnum;
  80152c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801534:	5b                   	pop    %ebx
  801535:	5e                   	pop    %esi
  801536:	5f                   	pop    %edi
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801539:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	25 07 0e 00 00       	and    $0xe07,%eax
  801548:	50                   	push   %eax
  801549:	57                   	push   %edi
  80154a:	6a 00                	push   $0x0
  80154c:	53                   	push   %ebx
  80154d:	6a 00                	push   $0x0
  80154f:	e8 14 f8 ff ff       	call   800d68 <sys_page_map>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	83 c4 20             	add    $0x20,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	79 a3                	jns    801500 <dup+0x74>
	sys_page_unmap(0, newfd);
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	56                   	push   %esi
  801561:	6a 00                	push   $0x0
  801563:	e8 42 f8 ff ff       	call   800daa <sys_page_unmap>
	sys_page_unmap(0, nva);
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	57                   	push   %edi
  80156c:	6a 00                	push   $0x0
  80156e:	e8 37 f8 ff ff       	call   800daa <sys_page_unmap>
	return r;
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	eb b7                	jmp    80152f <dup+0xa3>

00801578 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	53                   	push   %ebx
  801587:	e8 7b fd ff ff       	call   801307 <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 3f                	js     8015d2 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159d:	ff 30                	pushl  (%eax)
  80159f:	e8 b9 fd ff ff       	call   80135d <dev_lookup>
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 27                	js     8015d2 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ae:	8b 42 08             	mov    0x8(%edx),%eax
  8015b1:	83 e0 03             	and    $0x3,%eax
  8015b4:	83 f8 01             	cmp    $0x1,%eax
  8015b7:	74 1e                	je     8015d7 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bc:	8b 40 08             	mov    0x8(%eax),%eax
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	74 35                	je     8015f8 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c3:	83 ec 04             	sub    $0x4,%esp
  8015c6:	ff 75 10             	pushl  0x10(%ebp)
  8015c9:	ff 75 0c             	pushl  0xc(%ebp)
  8015cc:	52                   	push   %edx
  8015cd:	ff d0                	call   *%eax
  8015cf:	83 c4 10             	add    $0x10,%esp
}
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8015dc:	8b 40 48             	mov    0x48(%eax),%eax
  8015df:	83 ec 04             	sub    $0x4,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	50                   	push   %eax
  8015e4:	68 d1 28 80 00       	push   $0x8028d1
  8015e9:	e8 1f ed ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015f6:	eb da                	jmp    8015d2 <read+0x5a>
		return -E_NOT_SUPP;
  8015f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015fd:	eb d3                	jmp    8015d2 <read+0x5a>

008015ff <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	8b 7d 08             	mov    0x8(%ebp),%edi
  80160b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801613:	39 f3                	cmp    %esi,%ebx
  801615:	73 25                	jae    80163c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	89 f0                	mov    %esi,%eax
  80161c:	29 d8                	sub    %ebx,%eax
  80161e:	50                   	push   %eax
  80161f:	89 d8                	mov    %ebx,%eax
  801621:	03 45 0c             	add    0xc(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	57                   	push   %edi
  801626:	e8 4d ff ff ff       	call   801578 <read>
		if (m < 0)
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 08                	js     80163a <readn+0x3b>
			return m;
		if (m == 0)
  801632:	85 c0                	test   %eax,%eax
  801634:	74 06                	je     80163c <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801636:	01 c3                	add    %eax,%ebx
  801638:	eb d9                	jmp    801613 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	53                   	push   %ebx
  80164a:	83 ec 14             	sub    $0x14,%esp
  80164d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	53                   	push   %ebx
  801655:	e8 ad fc ff ff       	call   801307 <fd_lookup>
  80165a:	83 c4 08             	add    $0x8,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 3a                	js     80169b <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166b:	ff 30                	pushl  (%eax)
  80166d:	e8 eb fc ff ff       	call   80135d <dev_lookup>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 22                	js     80169b <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801680:	74 1e                	je     8016a0 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801682:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801685:	8b 52 0c             	mov    0xc(%edx),%edx
  801688:	85 d2                	test   %edx,%edx
  80168a:	74 35                	je     8016c1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168c:	83 ec 04             	sub    $0x4,%esp
  80168f:	ff 75 10             	pushl  0x10(%ebp)
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	50                   	push   %eax
  801696:	ff d2                	call   *%edx
  801698:	83 c4 10             	add    $0x10,%esp
}
  80169b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a5:	8b 40 48             	mov    0x48(%eax),%eax
  8016a8:	83 ec 04             	sub    $0x4,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	50                   	push   %eax
  8016ad:	68 ed 28 80 00       	push   $0x8028ed
  8016b2:	e8 56 ec ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016bf:	eb da                	jmp    80169b <write+0x55>
		return -E_NOT_SUPP;
  8016c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c6:	eb d3                	jmp    80169b <write+0x55>

008016c8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	ff 75 08             	pushl  0x8(%ebp)
  8016d5:	e8 2d fc ff ff       	call   801307 <fd_lookup>
  8016da:	83 c4 08             	add    $0x8,%esp
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 0e                	js     8016ef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 14             	sub    $0x14,%esp
  8016f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	53                   	push   %ebx
  801700:	e8 02 fc ff ff       	call   801307 <fd_lookup>
  801705:	83 c4 08             	add    $0x8,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 37                	js     801743 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	50                   	push   %eax
  801713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801716:	ff 30                	pushl  (%eax)
  801718:	e8 40 fc ff ff       	call   80135d <dev_lookup>
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	78 1f                	js     801743 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801727:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80172b:	74 1b                	je     801748 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80172d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801730:	8b 52 18             	mov    0x18(%edx),%edx
  801733:	85 d2                	test   %edx,%edx
  801735:	74 32                	je     801769 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	ff d2                	call   *%edx
  801740:	83 c4 10             	add    $0x10,%esp
}
  801743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801746:	c9                   	leave  
  801747:	c3                   	ret    
			thisenv->env_id, fdnum);
  801748:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80174d:	8b 40 48             	mov    0x48(%eax),%eax
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	53                   	push   %ebx
  801754:	50                   	push   %eax
  801755:	68 b0 28 80 00       	push   $0x8028b0
  80175a:	e8 ae eb ff ff       	call   80030d <cprintf>
		return -E_INVAL;
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801767:	eb da                	jmp    801743 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801769:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176e:	eb d3                	jmp    801743 <ftruncate+0x52>

00801770 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	83 ec 14             	sub    $0x14,%esp
  801777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80177a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177d:	50                   	push   %eax
  80177e:	ff 75 08             	pushl  0x8(%ebp)
  801781:	e8 81 fb ff ff       	call   801307 <fd_lookup>
  801786:	83 c4 08             	add    $0x8,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 4b                	js     8017d8 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801797:	ff 30                	pushl  (%eax)
  801799:	e8 bf fb ff ff       	call   80135d <dev_lookup>
  80179e:	83 c4 10             	add    $0x10,%esp
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	78 33                	js     8017d8 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ac:	74 2f                	je     8017dd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b8:	00 00 00 
	stat->st_isdir = 0;
  8017bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c2:	00 00 00 
	stat->st_dev = dev;
  8017c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	53                   	push   %ebx
  8017cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d2:	ff 50 14             	call   *0x14(%eax)
  8017d5:	83 c4 10             	add    $0x10,%esp
}
  8017d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017db:	c9                   	leave  
  8017dc:	c3                   	ret    
		return -E_NOT_SUPP;
  8017dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017e2:	eb f4                	jmp    8017d8 <fstat+0x68>

008017e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	56                   	push   %esi
  8017e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e9:	83 ec 08             	sub    $0x8,%esp
  8017ec:	6a 00                	push   $0x0
  8017ee:	ff 75 08             	pushl  0x8(%ebp)
  8017f1:	e8 e7 01 00 00       	call   8019dd <open>
  8017f6:	89 c3                	mov    %eax,%ebx
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 1b                	js     80181a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	ff 75 0c             	pushl  0xc(%ebp)
  801805:	50                   	push   %eax
  801806:	e8 65 ff ff ff       	call   801770 <fstat>
  80180b:	89 c6                	mov    %eax,%esi
	close(fd);
  80180d:	89 1c 24             	mov    %ebx,(%esp)
  801810:	e8 27 fc ff ff       	call   80143c <close>
	return r;
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	89 f3                	mov    %esi,%ebx
}
  80181a:	89 d8                	mov    %ebx,%eax
  80181c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181f:	5b                   	pop    %ebx
  801820:	5e                   	pop    %esi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	56                   	push   %esi
  801827:	53                   	push   %ebx
  801828:	89 c6                	mov    %eax,%esi
  80182a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80182c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801833:	74 27                	je     80185c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801835:	6a 07                	push   $0x7
  801837:	68 00 50 80 00       	push   $0x805000
  80183c:	56                   	push   %esi
  80183d:	ff 35 00 40 80 00    	pushl  0x804000
  801843:	e8 b9 07 00 00       	call   802001 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801848:	83 c4 0c             	add    $0xc,%esp
  80184b:	6a 00                	push   $0x0
  80184d:	53                   	push   %ebx
  80184e:	6a 00                	push   $0x0
  801850:	e8 4b 07 00 00       	call   801fa0 <ipc_recv>
}
  801855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	6a 01                	push   $0x1
  801861:	e8 e8 07 00 00       	call   80204e <ipc_find_env>
  801866:	a3 00 40 80 00       	mov    %eax,0x804000
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	eb c5                	jmp    801835 <fsipc+0x12>

00801870 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 40 0c             	mov    0xc(%eax),%eax
  80187c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 02 00 00 00       	mov    $0x2,%eax
  801893:	e8 8b ff ff ff       	call   801823 <fsipc>
}
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devfile_flush>:
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8018b5:	e8 69 ff ff ff       	call   801823 <fsipc>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_stat>:
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8018db:	e8 43 ff ff ff       	call   801823 <fsipc>
  8018e0:	85 c0                	test   %eax,%eax
  8018e2:	78 2c                	js     801910 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	68 00 50 80 00       	push   $0x805000
  8018ec:	53                   	push   %ebx
  8018ed:	e8 3a f0 ff ff       	call   80092c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8018f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801902:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devfile_write>:
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  80191e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801923:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801928:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80192b:	8b 55 08             	mov    0x8(%ebp),%edx
  80192e:	8b 52 0c             	mov    0xc(%edx),%edx
  801931:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801937:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  80193c:	50                   	push   %eax
  80193d:	ff 75 0c             	pushl  0xc(%ebp)
  801940:	68 08 50 80 00       	push   $0x805008
  801945:	e8 70 f1 ff ff       	call   800aba <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	b8 04 00 00 00       	mov    $0x4,%eax
  801954:	e8 ca fe ff ff       	call   801823 <fsipc>
}
  801959:	c9                   	leave  
  80195a:	c3                   	ret    

0080195b <devfile_read>:
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	8b 40 0c             	mov    0xc(%eax),%eax
  801969:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80196e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	b8 03 00 00 00       	mov    $0x3,%eax
  80197e:	e8 a0 fe ff ff       	call   801823 <fsipc>
  801983:	89 c3                	mov    %eax,%ebx
  801985:	85 c0                	test   %eax,%eax
  801987:	78 1f                	js     8019a8 <devfile_read+0x4d>
	assert(r <= n);
  801989:	39 f0                	cmp    %esi,%eax
  80198b:	77 24                	ja     8019b1 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80198d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801992:	7f 33                	jg     8019c7 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801994:	83 ec 04             	sub    $0x4,%esp
  801997:	50                   	push   %eax
  801998:	68 00 50 80 00       	push   $0x805000
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	e8 15 f1 ff ff       	call   800aba <memmove>
	return r;
  8019a5:	83 c4 10             	add    $0x10,%esp
}
  8019a8:	89 d8                	mov    %ebx,%eax
  8019aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ad:	5b                   	pop    %ebx
  8019ae:	5e                   	pop    %esi
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    
	assert(r <= n);
  8019b1:	68 1c 29 80 00       	push   $0x80291c
  8019b6:	68 23 29 80 00       	push   $0x802923
  8019bb:	6a 7d                	push   $0x7d
  8019bd:	68 38 29 80 00       	push   $0x802938
  8019c2:	e8 6b e8 ff ff       	call   800232 <_panic>
	assert(r <= PGSIZE);
  8019c7:	68 43 29 80 00       	push   $0x802943
  8019cc:	68 23 29 80 00       	push   $0x802923
  8019d1:	6a 7e                	push   $0x7e
  8019d3:	68 38 29 80 00       	push   $0x802938
  8019d8:	e8 55 e8 ff ff       	call   800232 <_panic>

008019dd <open>:
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 1c             	sub    $0x1c,%esp
  8019e5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019e8:	56                   	push   %esi
  8019e9:	e8 07 ef ff ff       	call   8008f5 <strlen>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f6:	0f 8f 96 00 00 00    	jg     801a92 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a02:	50                   	push   %eax
  801a03:	e8 b0 f8 ff ff       	call   8012b8 <fd_alloc>
  801a08:	89 c3                	mov    %eax,%ebx
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 66                	js     801a77 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	56                   	push   %esi
  801a15:	68 00 50 80 00       	push   $0x805000
  801a1a:	e8 0d ef ff ff       	call   80092c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2f:	e8 ef fd ff ff       	call   801823 <fsipc>
  801a34:	89 c3                	mov    %eax,%ebx
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 43                	js     801a80 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	ff 75 f4             	pushl  -0xc(%ebp)
  801a43:	e8 49 f8 ff ff       	call   801291 <fd2num>
  801a48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a4b:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a51:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	50                   	push   %eax
  801a58:	52                   	push   %edx
  801a59:	ff 32                	pushl  (%edx)
  801a5b:	56                   	push   %esi
  801a5c:	51                   	push   %ecx
  801a5d:	68 50 29 80 00       	push   $0x802950
  801a62:	e8 a6 e8 ff ff       	call   80030d <cprintf>
	return fd2num(fd);
  801a67:	83 c4 14             	add    $0x14,%esp
  801a6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a6d:	e8 1f f8 ff ff       	call   801291 <fd2num>
  801a72:	89 c3                	mov    %eax,%ebx
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	89 d8                	mov    %ebx,%eax
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    
		fd_close(fd, 0);
  801a80:	83 ec 08             	sub    $0x8,%esp
  801a83:	6a 00                	push   $0x0
  801a85:	ff 75 f4             	pushl  -0xc(%ebp)
  801a88:	e8 26 f9 ff ff       	call   8013b3 <fd_close>
		return r;
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb e5                	jmp    801a77 <open+0x9a>
		return -E_BAD_PATH;
  801a92:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a97:	eb de                	jmp    801a77 <open+0x9a>

00801a99 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa4:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa9:	e8 75 fd ff ff       	call   801823 <fsipc>
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	ff 75 08             	pushl  0x8(%ebp)
  801abe:	e8 de f7 ff ff       	call   8012a1 <fd2data>
  801ac3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ac5:	83 c4 08             	add    $0x8,%esp
  801ac8:	68 90 29 80 00       	push   $0x802990
  801acd:	53                   	push   %ebx
  801ace:	e8 59 ee ff ff       	call   80092c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ad3:	8b 46 04             	mov    0x4(%esi),%eax
  801ad6:	2b 06                	sub    (%esi),%eax
  801ad8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ade:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ae5:	00 00 00 
	stat->st_dev = &devpipe;
  801ae8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aef:	30 80 00 
	return 0;
}
  801af2:	b8 00 00 00 00       	mov    $0x0,%eax
  801af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	53                   	push   %ebx
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b08:	53                   	push   %ebx
  801b09:	6a 00                	push   $0x0
  801b0b:	e8 9a f2 ff ff       	call   800daa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b10:	89 1c 24             	mov    %ebx,(%esp)
  801b13:	e8 89 f7 ff ff       	call   8012a1 <fd2data>
  801b18:	83 c4 08             	add    $0x8,%esp
  801b1b:	50                   	push   %eax
  801b1c:	6a 00                	push   $0x0
  801b1e:	e8 87 f2 ff ff       	call   800daa <sys_page_unmap>
}
  801b23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <_pipeisclosed>:
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	57                   	push   %edi
  801b2c:	56                   	push   %esi
  801b2d:	53                   	push   %ebx
  801b2e:	83 ec 1c             	sub    $0x1c,%esp
  801b31:	89 c7                	mov    %eax,%edi
  801b33:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b35:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	57                   	push   %edi
  801b41:	e8 41 05 00 00       	call   802087 <pageref>
  801b46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b49:	89 34 24             	mov    %esi,(%esp)
  801b4c:	e8 36 05 00 00       	call   802087 <pageref>
		nn = thisenv->env_runs;
  801b51:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b57:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	39 cb                	cmp    %ecx,%ebx
  801b5f:	74 1b                	je     801b7c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b61:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b64:	75 cf                	jne    801b35 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b66:	8b 42 58             	mov    0x58(%edx),%eax
  801b69:	6a 01                	push   $0x1
  801b6b:	50                   	push   %eax
  801b6c:	53                   	push   %ebx
  801b6d:	68 97 29 80 00       	push   $0x802997
  801b72:	e8 96 e7 ff ff       	call   80030d <cprintf>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb b9                	jmp    801b35 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b7c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b7f:	0f 94 c0             	sete   %al
  801b82:	0f b6 c0             	movzbl %al,%eax
}
  801b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5f                   	pop    %edi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <devpipe_write>:
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 28             	sub    $0x28,%esp
  801b96:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b99:	56                   	push   %esi
  801b9a:	e8 02 f7 ff ff       	call   8012a1 <fd2data>
  801b9f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bac:	74 4f                	je     801bfd <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bae:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb1:	8b 0b                	mov    (%ebx),%ecx
  801bb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb6:	39 d0                	cmp    %edx,%eax
  801bb8:	72 14                	jb     801bce <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801bba:	89 da                	mov    %ebx,%edx
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	e8 65 ff ff ff       	call   801b28 <_pipeisclosed>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 3a                	jne    801c01 <devpipe_write+0x74>
			sys_yield();
  801bc7:	e8 3a f1 ff ff       	call   800d06 <sys_yield>
  801bcc:	eb e0                	jmp    801bae <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd8:	89 c2                	mov    %eax,%edx
  801bda:	c1 fa 1f             	sar    $0x1f,%edx
  801bdd:	89 d1                	mov    %edx,%ecx
  801bdf:	c1 e9 1b             	shr    $0x1b,%ecx
  801be2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be5:	83 e2 1f             	and    $0x1f,%edx
  801be8:	29 ca                	sub    %ecx,%edx
  801bea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf2:	83 c0 01             	add    $0x1,%eax
  801bf5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bf8:	83 c7 01             	add    $0x1,%edi
  801bfb:	eb ac                	jmp    801ba9 <devpipe_write+0x1c>
	return i;
  801bfd:	89 f8                	mov    %edi,%eax
  801bff:	eb 05                	jmp    801c06 <devpipe_write+0x79>
				return 0;
  801c01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c09:	5b                   	pop    %ebx
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <devpipe_read>:
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 18             	sub    $0x18,%esp
  801c17:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c1a:	57                   	push   %edi
  801c1b:	e8 81 f6 ff ff       	call   8012a1 <fd2data>
  801c20:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	be 00 00 00 00       	mov    $0x0,%esi
  801c2a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c2d:	74 47                	je     801c76 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c2f:	8b 03                	mov    (%ebx),%eax
  801c31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c34:	75 22                	jne    801c58 <devpipe_read+0x4a>
			if (i > 0)
  801c36:	85 f6                	test   %esi,%esi
  801c38:	75 14                	jne    801c4e <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c3a:	89 da                	mov    %ebx,%edx
  801c3c:	89 f8                	mov    %edi,%eax
  801c3e:	e8 e5 fe ff ff       	call   801b28 <_pipeisclosed>
  801c43:	85 c0                	test   %eax,%eax
  801c45:	75 33                	jne    801c7a <devpipe_read+0x6c>
			sys_yield();
  801c47:	e8 ba f0 ff ff       	call   800d06 <sys_yield>
  801c4c:	eb e1                	jmp    801c2f <devpipe_read+0x21>
				return i;
  801c4e:	89 f0                	mov    %esi,%eax
}
  801c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c58:	99                   	cltd   
  801c59:	c1 ea 1b             	shr    $0x1b,%edx
  801c5c:	01 d0                	add    %edx,%eax
  801c5e:	83 e0 1f             	and    $0x1f,%eax
  801c61:	29 d0                	sub    %edx,%eax
  801c63:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c6e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c71:	83 c6 01             	add    $0x1,%esi
  801c74:	eb b4                	jmp    801c2a <devpipe_read+0x1c>
	return i;
  801c76:	89 f0                	mov    %esi,%eax
  801c78:	eb d6                	jmp    801c50 <devpipe_read+0x42>
				return 0;
  801c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7f:	eb cf                	jmp    801c50 <devpipe_read+0x42>

00801c81 <pipe>:
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	56                   	push   %esi
  801c85:	53                   	push   %ebx
  801c86:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	e8 26 f6 ff ff       	call   8012b8 <fd_alloc>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 5b                	js     801cf6 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 78 f0 ff ff       	call   800d25 <sys_page_alloc>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 40                	js     801cf6 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 f6 f5 ff ff       	call   8012b8 <fd_alloc>
  801cc2:	89 c3                	mov    %eax,%ebx
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 1b                	js     801ce6 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccb:	83 ec 04             	sub    $0x4,%esp
  801cce:	68 07 04 00 00       	push   $0x407
  801cd3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd6:	6a 00                	push   $0x0
  801cd8:	e8 48 f0 ff ff       	call   800d25 <sys_page_alloc>
  801cdd:	89 c3                	mov    %eax,%ebx
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	85 c0                	test   %eax,%eax
  801ce4:	79 19                	jns    801cff <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801ce6:	83 ec 08             	sub    $0x8,%esp
  801ce9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cec:	6a 00                	push   $0x0
  801cee:	e8 b7 f0 ff ff       	call   800daa <sys_page_unmap>
  801cf3:	83 c4 10             	add    $0x10,%esp
}
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5e                   	pop    %esi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    
	va = fd2data(fd0);
  801cff:	83 ec 0c             	sub    $0xc,%esp
  801d02:	ff 75 f4             	pushl  -0xc(%ebp)
  801d05:	e8 97 f5 ff ff       	call   8012a1 <fd2data>
  801d0a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0c:	83 c4 0c             	add    $0xc,%esp
  801d0f:	68 07 04 00 00       	push   $0x407
  801d14:	50                   	push   %eax
  801d15:	6a 00                	push   $0x0
  801d17:	e8 09 f0 ff ff       	call   800d25 <sys_page_alloc>
  801d1c:	89 c3                	mov    %eax,%ebx
  801d1e:	83 c4 10             	add    $0x10,%esp
  801d21:	85 c0                	test   %eax,%eax
  801d23:	0f 88 8c 00 00 00    	js     801db5 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d29:	83 ec 0c             	sub    $0xc,%esp
  801d2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2f:	e8 6d f5 ff ff       	call   8012a1 <fd2data>
  801d34:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d3b:	50                   	push   %eax
  801d3c:	6a 00                	push   $0x0
  801d3e:	56                   	push   %esi
  801d3f:	6a 00                	push   $0x0
  801d41:	e8 22 f0 ff ff       	call   800d68 <sys_page_map>
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	83 c4 20             	add    $0x20,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	78 58                	js     801da7 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d58:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d67:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d6d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d72:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d79:	83 ec 0c             	sub    $0xc,%esp
  801d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7f:	e8 0d f5 ff ff       	call   801291 <fd2num>
  801d84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d87:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d89:	83 c4 04             	add    $0x4,%esp
  801d8c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8f:	e8 fd f4 ff ff       	call   801291 <fd2num>
  801d94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d97:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da2:	e9 4f ff ff ff       	jmp    801cf6 <pipe+0x75>
	sys_page_unmap(0, va);
  801da7:	83 ec 08             	sub    $0x8,%esp
  801daa:	56                   	push   %esi
  801dab:	6a 00                	push   $0x0
  801dad:	e8 f8 ef ff ff       	call   800daa <sys_page_unmap>
  801db2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801db5:	83 ec 08             	sub    $0x8,%esp
  801db8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbb:	6a 00                	push   $0x0
  801dbd:	e8 e8 ef ff ff       	call   800daa <sys_page_unmap>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	e9 1c ff ff ff       	jmp    801ce6 <pipe+0x65>

00801dca <pipeisclosed>:
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd3:	50                   	push   %eax
  801dd4:	ff 75 08             	pushl  0x8(%ebp)
  801dd7:	e8 2b f5 ff ff       	call   801307 <fd_lookup>
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 18                	js     801dfb <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	ff 75 f4             	pushl  -0xc(%ebp)
  801de9:	e8 b3 f4 ff ff       	call   8012a1 <fd2data>
	return _pipeisclosed(fd, p);
  801dee:	89 c2                	mov    %eax,%edx
  801df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df3:	e8 30 fd ff ff       	call   801b28 <_pipeisclosed>
  801df8:	83 c4 10             	add    $0x10,%esp
}
  801dfb:	c9                   	leave  
  801dfc:	c3                   	ret    

00801dfd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e0d:	68 af 29 80 00       	push   $0x8029af
  801e12:	ff 75 0c             	pushl  0xc(%ebp)
  801e15:	e8 12 eb ff ff       	call   80092c <strcpy>
	return 0;
}
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <devcons_write>:
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	57                   	push   %edi
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e2d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e32:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e38:	eb 2f                	jmp    801e69 <devcons_write+0x48>
		m = n - tot;
  801e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e3d:	29 f3                	sub    %esi,%ebx
  801e3f:	83 fb 7f             	cmp    $0x7f,%ebx
  801e42:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e47:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e4a:	83 ec 04             	sub    $0x4,%esp
  801e4d:	53                   	push   %ebx
  801e4e:	89 f0                	mov    %esi,%eax
  801e50:	03 45 0c             	add    0xc(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	57                   	push   %edi
  801e55:	e8 60 ec ff ff       	call   800aba <memmove>
		sys_cputs(buf, m);
  801e5a:	83 c4 08             	add    $0x8,%esp
  801e5d:	53                   	push   %ebx
  801e5e:	57                   	push   %edi
  801e5f:	e8 05 ee ff ff       	call   800c69 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e64:	01 de                	add    %ebx,%esi
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e6c:	72 cc                	jb     801e3a <devcons_write+0x19>
}
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devcons_read>:
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 08             	sub    $0x8,%esp
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e87:	75 07                	jne    801e90 <devcons_read+0x18>
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    
		sys_yield();
  801e8b:	e8 76 ee ff ff       	call   800d06 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e90:	e8 f2 ed ff ff       	call   800c87 <sys_cgetc>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 f2                	je     801e8b <devcons_read+0x13>
	if (c < 0)
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 ec                	js     801e89 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e9d:	83 f8 04             	cmp    $0x4,%eax
  801ea0:	74 0c                	je     801eae <devcons_read+0x36>
	*(char*)vbuf = c;
  801ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea5:	88 02                	mov    %al,(%edx)
	return 1;
  801ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eac:	eb db                	jmp    801e89 <devcons_read+0x11>
		return 0;
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb3:	eb d4                	jmp    801e89 <devcons_read+0x11>

00801eb5 <cputchar>:
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ec1:	6a 01                	push   $0x1
  801ec3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	e8 9d ed ff ff       	call   800c69 <sys_cputs>
}
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <getchar>:
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ed7:	6a 01                	push   $0x1
  801ed9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 94 f6 ff ff       	call   801578 <read>
	if (r < 0)
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 08                	js     801ef3 <getchar+0x22>
	if (r < 1)
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	7e 06                	jle    801ef5 <getchar+0x24>
	return c;
  801eef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    
		return -E_EOF;
  801ef5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801efa:	eb f7                	jmp    801ef3 <getchar+0x22>

00801efc <iscons>:
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	ff 75 08             	pushl  0x8(%ebp)
  801f09:	e8 f9 f3 ff ff       	call   801307 <fd_lookup>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 11                	js     801f26 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f18:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f1e:	39 10                	cmp    %edx,(%eax)
  801f20:	0f 94 c0             	sete   %al
  801f23:	0f b6 c0             	movzbl %al,%eax
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <opencons>:
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	e8 81 f3 ff ff       	call   8012b8 <fd_alloc>
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 3a                	js     801f78 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f3e:	83 ec 04             	sub    $0x4,%esp
  801f41:	68 07 04 00 00       	push   $0x407
  801f46:	ff 75 f4             	pushl  -0xc(%ebp)
  801f49:	6a 00                	push   $0x0
  801f4b:	e8 d5 ed ff ff       	call   800d25 <sys_page_alloc>
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	85 c0                	test   %eax,%eax
  801f55:	78 21                	js     801f78 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f60:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f6c:	83 ec 0c             	sub    $0xc,%esp
  801f6f:	50                   	push   %eax
  801f70:	e8 1c f3 ff ff       	call   801291 <fd2num>
  801f75:	83 c4 10             	add    $0x10,%esp
}
  801f78:	c9                   	leave  
  801f79:	c3                   	ret    

00801f7a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f7a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f7b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801f80:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f82:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801f85:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801f88:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801f8c:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801f90:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801f93:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801f97:	89 18                	mov    %ebx,(%eax)

    popal
  801f99:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801f9a:	83 c4 04             	add    $0x4,%esp
    popfl
  801f9d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801f9e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801f9f:	c3                   	ret    

00801fa0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb5:	0f 44 c2             	cmove  %edx,%eax
  801fb8:	83 ec 0c             	sub    $0xc,%esp
  801fbb:	50                   	push   %eax
  801fbc:	e8 14 ef ff ff       	call   800ed5 <sys_ipc_recv>
  801fc1:	83 c4 10             	add    $0x10,%esp
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 2b                	js     801ff3 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801fc8:	85 f6                	test   %esi,%esi
  801fca:	74 0a                	je     801fd6 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801fcc:	a1 04 40 80 00       	mov    0x804004,%eax
  801fd1:	8b 40 74             	mov    0x74(%eax),%eax
  801fd4:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801fd6:	85 db                	test   %ebx,%ebx
  801fd8:	74 0a                	je     801fe4 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801fda:	a1 04 40 80 00       	mov    0x804004,%eax
  801fdf:	8b 40 78             	mov    0x78(%eax),%eax
  801fe2:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801fe4:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fef:	5b                   	pop    %ebx
  801ff0:	5e                   	pop    %esi
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    
        *from_env_store = 0;
  801ff3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801ff9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801fff:	eb eb                	jmp    801fec <ipc_recv+0x4c>

00802001 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	57                   	push   %edi
  802005:	56                   	push   %esi
  802006:	53                   	push   %ebx
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80200d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802010:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  802013:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  802015:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80201a:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  80201d:	ff 75 14             	pushl  0x14(%ebp)
  802020:	53                   	push   %ebx
  802021:	56                   	push   %esi
  802022:	57                   	push   %edi
  802023:	e8 8a ee ff ff       	call   800eb2 <sys_ipc_try_send>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	74 17                	je     802046 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  80202f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802032:	74 e9                	je     80201d <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  802034:	50                   	push   %eax
  802035:	68 bb 29 80 00       	push   $0x8029bb
  80203a:	6a 3e                	push   $0x3e
  80203c:	68 cd 29 80 00       	push   $0x8029cd
  802041:	e8 ec e1 ff ff       	call   800232 <_panic>
        }
    }
}
  802046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802059:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80205c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802062:	8b 52 50             	mov    0x50(%edx),%edx
  802065:	39 ca                	cmp    %ecx,%edx
  802067:	74 11                	je     80207a <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802069:	83 c0 01             	add    $0x1,%eax
  80206c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802071:	75 e6                	jne    802059 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	eb 0b                	jmp    802085 <ipc_find_env+0x37>
			return envs[i].env_id;
  80207a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80207d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802082:	8b 40 48             	mov    0x48(%eax),%eax
}
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    

00802087 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80208d:	89 d0                	mov    %edx,%eax
  80208f:	c1 e8 16             	shr    $0x16,%eax
  802092:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802099:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80209e:	f6 c1 01             	test   $0x1,%cl
  8020a1:	74 1d                	je     8020c0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020a3:	c1 ea 0c             	shr    $0xc,%edx
  8020a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ad:	f6 c2 01             	test   $0x1,%dl
  8020b0:	74 0e                	je     8020c0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b2:	c1 ea 0c             	shr    $0xc,%edx
  8020b5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020bc:	ef 
  8020bd:	0f b7 c0             	movzwl %ax,%eax
}
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	75 35                	jne    802120 <__udivdi3+0x50>
  8020eb:	39 f3                	cmp    %esi,%ebx
  8020ed:	0f 87 bd 00 00 00    	ja     8021b0 <__udivdi3+0xe0>
  8020f3:	85 db                	test   %ebx,%ebx
  8020f5:	89 d9                	mov    %ebx,%ecx
  8020f7:	75 0b                	jne    802104 <__udivdi3+0x34>
  8020f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fe:	31 d2                	xor    %edx,%edx
  802100:	f7 f3                	div    %ebx
  802102:	89 c1                	mov    %eax,%ecx
  802104:	31 d2                	xor    %edx,%edx
  802106:	89 f0                	mov    %esi,%eax
  802108:	f7 f1                	div    %ecx
  80210a:	89 c6                	mov    %eax,%esi
  80210c:	89 e8                	mov    %ebp,%eax
  80210e:	89 f7                	mov    %esi,%edi
  802110:	f7 f1                	div    %ecx
  802112:	89 fa                	mov    %edi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	39 f2                	cmp    %esi,%edx
  802122:	77 7c                	ja     8021a0 <__udivdi3+0xd0>
  802124:	0f bd fa             	bsr    %edx,%edi
  802127:	83 f7 1f             	xor    $0x1f,%edi
  80212a:	0f 84 98 00 00 00    	je     8021c8 <__udivdi3+0xf8>
  802130:	89 f9                	mov    %edi,%ecx
  802132:	b8 20 00 00 00       	mov    $0x20,%eax
  802137:	29 f8                	sub    %edi,%eax
  802139:	d3 e2                	shl    %cl,%edx
  80213b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80213f:	89 c1                	mov    %eax,%ecx
  802141:	89 da                	mov    %ebx,%edx
  802143:	d3 ea                	shr    %cl,%edx
  802145:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802149:	09 d1                	or     %edx,%ecx
  80214b:	89 f2                	mov    %esi,%edx
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e3                	shl    %cl,%ebx
  802155:	89 c1                	mov    %eax,%ecx
  802157:	d3 ea                	shr    %cl,%edx
  802159:	89 f9                	mov    %edi,%ecx
  80215b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80215f:	d3 e6                	shl    %cl,%esi
  802161:	89 eb                	mov    %ebp,%ebx
  802163:	89 c1                	mov    %eax,%ecx
  802165:	d3 eb                	shr    %cl,%ebx
  802167:	09 de                	or     %ebx,%esi
  802169:	89 f0                	mov    %esi,%eax
  80216b:	f7 74 24 08          	divl   0x8(%esp)
  80216f:	89 d6                	mov    %edx,%esi
  802171:	89 c3                	mov    %eax,%ebx
  802173:	f7 64 24 0c          	mull   0xc(%esp)
  802177:	39 d6                	cmp    %edx,%esi
  802179:	72 0c                	jb     802187 <__udivdi3+0xb7>
  80217b:	89 f9                	mov    %edi,%ecx
  80217d:	d3 e5                	shl    %cl,%ebp
  80217f:	39 c5                	cmp    %eax,%ebp
  802181:	73 5d                	jae    8021e0 <__udivdi3+0x110>
  802183:	39 d6                	cmp    %edx,%esi
  802185:	75 59                	jne    8021e0 <__udivdi3+0x110>
  802187:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80218a:	31 ff                	xor    %edi,%edi
  80218c:	89 fa                	mov    %edi,%edx
  80218e:	83 c4 1c             	add    $0x1c,%esp
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    
  802196:	8d 76 00             	lea    0x0(%esi),%esi
  802199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021a0:	31 ff                	xor    %edi,%edi
  8021a2:	31 c0                	xor    %eax,%eax
  8021a4:	89 fa                	mov    %edi,%edx
  8021a6:	83 c4 1c             	add    $0x1c,%esp
  8021a9:	5b                   	pop    %ebx
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    
  8021ae:	66 90                	xchg   %ax,%ax
  8021b0:	31 ff                	xor    %edi,%edi
  8021b2:	89 e8                	mov    %ebp,%eax
  8021b4:	89 f2                	mov    %esi,%edx
  8021b6:	f7 f3                	div    %ebx
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	72 06                	jb     8021d2 <__udivdi3+0x102>
  8021cc:	31 c0                	xor    %eax,%eax
  8021ce:	39 eb                	cmp    %ebp,%ebx
  8021d0:	77 d2                	ja     8021a4 <__udivdi3+0xd4>
  8021d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d7:	eb cb                	jmp    8021a4 <__udivdi3+0xd4>
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	31 ff                	xor    %edi,%edi
  8021e4:	eb be                	jmp    8021a4 <__udivdi3+0xd4>
  8021e6:	66 90                	xchg   %ax,%ax
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__umoddi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 ed                	test   %ebp,%ebp
  802209:	89 f0                	mov    %esi,%eax
  80220b:	89 da                	mov    %ebx,%edx
  80220d:	75 19                	jne    802228 <__umoddi3+0x38>
  80220f:	39 df                	cmp    %ebx,%edi
  802211:	0f 86 b1 00 00 00    	jbe    8022c8 <__umoddi3+0xd8>
  802217:	f7 f7                	div    %edi
  802219:	89 d0                	mov    %edx,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	39 dd                	cmp    %ebx,%ebp
  80222a:	77 f1                	ja     80221d <__umoddi3+0x2d>
  80222c:	0f bd cd             	bsr    %ebp,%ecx
  80222f:	83 f1 1f             	xor    $0x1f,%ecx
  802232:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802236:	0f 84 b4 00 00 00    	je     8022f0 <__umoddi3+0x100>
  80223c:	b8 20 00 00 00       	mov    $0x20,%eax
  802241:	89 c2                	mov    %eax,%edx
  802243:	8b 44 24 04          	mov    0x4(%esp),%eax
  802247:	29 c2                	sub    %eax,%edx
  802249:	89 c1                	mov    %eax,%ecx
  80224b:	89 f8                	mov    %edi,%eax
  80224d:	d3 e5                	shl    %cl,%ebp
  80224f:	89 d1                	mov    %edx,%ecx
  802251:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802255:	d3 e8                	shr    %cl,%eax
  802257:	09 c5                	or     %eax,%ebp
  802259:	8b 44 24 04          	mov    0x4(%esp),%eax
  80225d:	89 c1                	mov    %eax,%ecx
  80225f:	d3 e7                	shl    %cl,%edi
  802261:	89 d1                	mov    %edx,%ecx
  802263:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802267:	89 df                	mov    %ebx,%edi
  802269:	d3 ef                	shr    %cl,%edi
  80226b:	89 c1                	mov    %eax,%ecx
  80226d:	89 f0                	mov    %esi,%eax
  80226f:	d3 e3                	shl    %cl,%ebx
  802271:	89 d1                	mov    %edx,%ecx
  802273:	89 fa                	mov    %edi,%edx
  802275:	d3 e8                	shr    %cl,%eax
  802277:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80227c:	09 d8                	or     %ebx,%eax
  80227e:	f7 f5                	div    %ebp
  802280:	d3 e6                	shl    %cl,%esi
  802282:	89 d1                	mov    %edx,%ecx
  802284:	f7 64 24 08          	mull   0x8(%esp)
  802288:	39 d1                	cmp    %edx,%ecx
  80228a:	89 c3                	mov    %eax,%ebx
  80228c:	89 d7                	mov    %edx,%edi
  80228e:	72 06                	jb     802296 <__umoddi3+0xa6>
  802290:	75 0e                	jne    8022a0 <__umoddi3+0xb0>
  802292:	39 c6                	cmp    %eax,%esi
  802294:	73 0a                	jae    8022a0 <__umoddi3+0xb0>
  802296:	2b 44 24 08          	sub    0x8(%esp),%eax
  80229a:	19 ea                	sbb    %ebp,%edx
  80229c:	89 d7                	mov    %edx,%edi
  80229e:	89 c3                	mov    %eax,%ebx
  8022a0:	89 ca                	mov    %ecx,%edx
  8022a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022a7:	29 de                	sub    %ebx,%esi
  8022a9:	19 fa                	sbb    %edi,%edx
  8022ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	d3 e0                	shl    %cl,%eax
  8022b3:	89 d9                	mov    %ebx,%ecx
  8022b5:	d3 ee                	shr    %cl,%esi
  8022b7:	d3 ea                	shr    %cl,%edx
  8022b9:	09 f0                	or     %esi,%eax
  8022bb:	83 c4 1c             	add    $0x1c,%esp
  8022be:	5b                   	pop    %ebx
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	85 ff                	test   %edi,%edi
  8022ca:	89 f9                	mov    %edi,%ecx
  8022cc:	75 0b                	jne    8022d9 <__umoddi3+0xe9>
  8022ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f7                	div    %edi
  8022d7:	89 c1                	mov    %eax,%ecx
  8022d9:	89 d8                	mov    %ebx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f1                	div    %ecx
  8022df:	89 f0                	mov    %esi,%eax
  8022e1:	f7 f1                	div    %ecx
  8022e3:	e9 31 ff ff ff       	jmp    802219 <__umoddi3+0x29>
  8022e8:	90                   	nop
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	39 dd                	cmp    %ebx,%ebp
  8022f2:	72 08                	jb     8022fc <__umoddi3+0x10c>
  8022f4:	39 f7                	cmp    %esi,%edi
  8022f6:	0f 87 21 ff ff ff    	ja     80221d <__umoddi3+0x2d>
  8022fc:	89 da                	mov    %ebx,%edx
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	29 f8                	sub    %edi,%eax
  802302:	19 ea                	sbb    %ebp,%edx
  802304:	e9 14 ff ff ff       	jmp    80221d <__umoddi3+0x2d>
