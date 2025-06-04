
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 bf 01 00 00       	call   8001f0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 20 23 80 00       	push   $0x802320
  800040:	e8 e6 02 00 00       	call   80032b <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 71 1d 00 00       	call   801dc1 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 5b                	js     8000b2 <umain+0x7f>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 de 10 00 00       	call   80113a <fork>
  80005c:	89 c6                	mov    %eax,%esi
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 62                	js     8000c4 <umain+0x91>
		panic("fork: %e", r);
	if (r == 0) {
  800062:	85 c0                	test   %eax,%eax
  800064:	74 70                	je     8000d6 <umain+0xa3>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	68 7a 23 80 00       	push   $0x80237a
  80006f:	e8 b7 02 00 00       	call   80032b <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800074:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007a:	83 c4 08             	add    $0x8,%esp
  80007d:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800080:	c1 f8 02             	sar    $0x2,%eax
  800083:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800089:	50                   	push   %eax
  80008a:	68 85 23 80 00       	push   $0x802385
  80008f:	e8 97 02 00 00       	call   80032b <cprintf>
	dup(p[0], 10);
  800094:	83 c4 08             	add    $0x8,%esp
  800097:	6a 0a                	push   $0xa
  800099:	ff 75 f0             	pushl  -0x10(%ebp)
  80009c:	e8 f0 14 00 00       	call   801591 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000ad:	e9 92 00 00 00       	jmp    800144 <umain+0x111>
		panic("pipe: %e", r);
  8000b2:	50                   	push   %eax
  8000b3:	68 39 23 80 00       	push   $0x802339
  8000b8:	6a 0d                	push   $0xd
  8000ba:	68 42 23 80 00       	push   $0x802342
  8000bf:	e8 8c 01 00 00       	call   800250 <_panic>
		panic("fork: %e", r);
  8000c4:	50                   	push   %eax
  8000c5:	68 56 23 80 00       	push   $0x802356
  8000ca:	6a 10                	push   $0x10
  8000cc:	68 42 23 80 00       	push   $0x802342
  8000d1:	e8 7a 01 00 00       	call   800250 <_panic>
		close(p[1]);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8000dc:	e8 60 14 00 00       	call   801541 <close>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000e9:	eb 0a                	jmp    8000f5 <umain+0xc2>
			sys_yield();
  8000eb:	e8 34 0c 00 00       	call   800d24 <sys_yield>
		for (i=0; i<max; i++) {
  8000f0:	83 eb 01             	sub    $0x1,%ebx
  8000f3:	74 29                	je     80011e <umain+0xeb>
			if(pipeisclosed(p[0])){
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8000fb:	e8 0a 1e 00 00       	call   801f0a <pipeisclosed>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 e4                	je     8000eb <umain+0xb8>
				cprintf("RACE: pipe appears closed\n");
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	68 5f 23 80 00       	push   $0x80235f
  80010f:	e8 17 02 00 00       	call   80032b <cprintf>
				exit();
  800114:	e8 1d 01 00 00       	call   800236 <exit>
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	eb cd                	jmp    8000eb <umain+0xb8>
		ipc_recv(0,0,0);
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	e8 83 11 00 00       	call   8012af <ipc_recv>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	e9 32 ff ff ff       	jmp    800066 <umain+0x33>
		dup(p[0], 10);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	6a 0a                	push   $0xa
  800139:	ff 75 f0             	pushl  -0x10(%ebp)
  80013c:	e8 50 14 00 00       	call   801591 <dup>
  800141:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800144:	8b 53 54             	mov    0x54(%ebx),%edx
  800147:	83 fa 02             	cmp    $0x2,%edx
  80014a:	74 e8                	je     800134 <umain+0x101>

	cprintf("child done with loop\n");
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	68 90 23 80 00       	push   $0x802390
  800154:	e8 d2 01 00 00       	call   80032b <cprintf>
	if (pipeisclosed(p[0]))
  800159:	83 c4 04             	add    $0x4,%esp
  80015c:	ff 75 f0             	pushl  -0x10(%ebp)
  80015f:	e8 a6 1d 00 00       	call   801f0a <pipeisclosed>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	85 c0                	test   %eax,%eax
  800169:	75 48                	jne    8001b3 <umain+0x180>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	ff 75 f0             	pushl  -0x10(%ebp)
  800175:	e8 92 12 00 00       	call   80140c <fd_lookup>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	78 46                	js     8001c7 <umain+0x194>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 ec             	pushl  -0x14(%ebp)
  800187:	e8 1a 12 00 00       	call   8013a6 <fd2data>
	if (pageref(va) != 3+1)
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 21 1a 00 00       	call   801bb5 <pageref>
  800194:	83 c4 10             	add    $0x10,%esp
  800197:	83 f8 04             	cmp    $0x4,%eax
  80019a:	74 3d                	je     8001d9 <umain+0x1a6>
		cprintf("\nchild detected race\n");
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	68 be 23 80 00       	push   $0x8023be
  8001a4:	e8 82 01 00 00       	call   80032b <cprintf>
  8001a9:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	68 ec 23 80 00       	push   $0x8023ec
  8001bb:	6a 3a                	push   $0x3a
  8001bd:	68 42 23 80 00       	push   $0x802342
  8001c2:	e8 89 00 00 00       	call   800250 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c7:	50                   	push   %eax
  8001c8:	68 a6 23 80 00       	push   $0x8023a6
  8001cd:	6a 3c                	push   $0x3c
  8001cf:	68 42 23 80 00       	push   $0x802342
  8001d4:	e8 77 00 00 00       	call   800250 <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	68 c8 00 00 00       	push   $0xc8
  8001e1:	68 d4 23 80 00       	push   $0x8023d4
  8001e6:	e8 40 01 00 00       	call   80032b <cprintf>
  8001eb:	83 c4 10             	add    $0x10,%esp
}
  8001ee:	eb bc                	jmp    8001ac <umain+0x179>

008001f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001fb:	e8 05 0b 00 00       	call   800d05 <sys_getenvid>
  800200:	25 ff 03 00 00       	and    $0x3ff,%eax
  800205:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	85 db                	test   %ebx,%ebx
  800214:	7e 07                	jle    80021d <libmain+0x2d>
		binaryname = argv[0];
  800216:	8b 06                	mov    (%esi),%eax
  800218:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	e8 0c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800227:	e8 0a 00 00 00       	call   800236 <exit>
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023c:	e8 2b 13 00 00       	call   80156c <close_all>
	sys_env_destroy(0);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	6a 00                	push   $0x0
  800246:	e8 79 0a 00 00       	call   800cc4 <sys_env_destroy>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800255:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800258:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025e:	e8 a2 0a 00 00       	call   800d05 <sys_getenvid>
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	56                   	push   %esi
  80026d:	50                   	push   %eax
  80026e:	68 20 24 80 00       	push   $0x802420
  800273:	e8 b3 00 00 00       	call   80032b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	53                   	push   %ebx
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 56 00 00 00       	call   8002da <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 37 23 80 00 	movl   $0x802337,(%esp)
  80028b:	e8 9b 00 00 00       	call   80032b <cprintf>
  800290:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800293:	cc                   	int3   
  800294:	eb fd                	jmp    800293 <_panic+0x43>

00800296 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	53                   	push   %ebx
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a0:	8b 13                	mov    (%ebx),%edx
  8002a2:	8d 42 01             	lea    0x1(%edx),%eax
  8002a5:	89 03                	mov    %eax,(%ebx)
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	74 09                	je     8002be <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	68 ff 00 00 00       	push   $0xff
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 b8 09 00 00       	call   800c87 <sys_cputs>
		b->idx = 0;
  8002cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	eb db                	jmp    8002b5 <putch+0x1f>

008002da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ea:	00 00 00 
	b.cnt = 0;
  8002ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	68 96 02 80 00       	push   $0x800296
  800309:	e8 1a 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030e:	83 c4 08             	add    $0x8,%esp
  800311:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800317:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	e8 64 09 00 00       	call   800c87 <sys_cputs>

	return b.cnt;
}
  800323:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800331:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 9d ff ff ff       	call   8002da <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 1c             	sub    $0x1c,%esp
  800348:	89 c7                	mov    %eax,%edi
  80034a:	89 d6                	mov    %edx,%esi
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800358:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80035b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800360:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800363:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800366:	39 d3                	cmp    %edx,%ebx
  800368:	72 05                	jb     80036f <printnum+0x30>
  80036a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036d:	77 7a                	ja     8003e9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	ff 75 18             	pushl  0x18(%ebp)
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80037b:	53                   	push   %ebx
  80037c:	ff 75 10             	pushl  0x10(%ebp)
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 e4             	pushl  -0x1c(%ebp)
  800385:	ff 75 e0             	pushl  -0x20(%ebp)
  800388:	ff 75 dc             	pushl  -0x24(%ebp)
  80038b:	ff 75 d8             	pushl  -0x28(%ebp)
  80038e:	e8 4d 1d 00 00       	call   8020e0 <__udivdi3>
  800393:	83 c4 18             	add    $0x18,%esp
  800396:	52                   	push   %edx
  800397:	50                   	push   %eax
  800398:	89 f2                	mov    %esi,%edx
  80039a:	89 f8                	mov    %edi,%eax
  80039c:	e8 9e ff ff ff       	call   80033f <printnum>
  8003a1:	83 c4 20             	add    $0x20,%esp
  8003a4:	eb 13                	jmp    8003b9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	56                   	push   %esi
  8003aa:	ff 75 18             	pushl  0x18(%ebp)
  8003ad:	ff d7                	call   *%edi
  8003af:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b2:	83 eb 01             	sub    $0x1,%ebx
  8003b5:	85 db                	test   %ebx,%ebx
  8003b7:	7f ed                	jg     8003a6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	56                   	push   %esi
  8003bd:	83 ec 04             	sub    $0x4,%esp
  8003c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cc:	e8 2f 1e 00 00       	call   802200 <__umoddi3>
  8003d1:	83 c4 14             	add    $0x14,%esp
  8003d4:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  8003db:	50                   	push   %eax
  8003dc:	ff d7                	call   *%edi
}
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ec:	eb c4                	jmp    8003b2 <printnum+0x73>

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	e9 c1 03 00 00       	jmp    800800 <vprintfmt+0x3d8>
		padc = ' ';
  80043f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800443:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800451:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800458:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8d 47 01             	lea    0x1(%edi),%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	0f b6 17             	movzbl (%edi),%edx
  800466:	8d 42 dd             	lea    -0x23(%edx),%eax
  800469:	3c 55                	cmp    $0x55,%al
  80046b:	0f 87 12 04 00 00    	ja     800883 <vprintfmt+0x45b>
  800471:	0f b6 c0             	movzbl %al,%eax
  800474:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800482:	eb d9                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800487:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048b:	eb d0                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	0f b6 d2             	movzbl %dl,%edx
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80049b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a8:	83 f9 09             	cmp    $0x9,%ecx
  8004ab:	77 55                	ja     800502 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b0:	eb e9                	jmp    80049b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 40 04             	lea    0x4(%eax),%eax
  8004c0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	79 91                	jns    80045d <vprintfmt+0x35>
				width = precision, precision = -1;
  8004cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x35>
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	0f 49 d0             	cmovns %eax,%edx
  8004e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	e9 6a ff ff ff       	jmp    80045d <vprintfmt+0x35>
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fd:	e9 5b ff ff ff       	jmp    80045d <vprintfmt+0x35>
  800502:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	eb bc                	jmp    8004c6 <vprintfmt+0x9e>
			lflag++;
  80050a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800510:	e9 48 ff ff ff       	jmp    80045d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 78 04             	lea    0x4(%eax),%edi
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	ff 30                	pushl  (%eax)
  800521:	ff d6                	call   *%esi
			break;
  800523:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800526:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800529:	e9 cf 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 78 04             	lea    0x4(%eax),%edi
  800534:	8b 00                	mov    (%eax),%eax
  800536:	99                   	cltd   
  800537:	31 d0                	xor    %edx,%eax
  800539:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053b:	83 f8 0f             	cmp    $0xf,%eax
  80053e:	7f 23                	jg     800563 <vprintfmt+0x13b>
  800540:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	74 18                	je     800563 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80054b:	52                   	push   %edx
  80054c:	68 71 29 80 00       	push   $0x802971
  800551:	53                   	push   %ebx
  800552:	56                   	push   %esi
  800553:	e8 b3 fe ff ff       	call   80040b <printfmt>
  800558:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055e:	e9 9a 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800563:	50                   	push   %eax
  800564:	68 5b 24 80 00       	push   $0x80245b
  800569:	53                   	push   %ebx
  80056a:	56                   	push   %esi
  80056b:	e8 9b fe ff ff       	call   80040b <printfmt>
  800570:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800573:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800576:	e9 82 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	83 c0 04             	add    $0x4,%eax
  800581:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800589:	85 ff                	test   %edi,%edi
  80058b:	b8 54 24 80 00       	mov    $0x802454,%eax
  800590:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	0f 8e bd 00 00 00    	jle    80065a <vprintfmt+0x232>
  80059d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a1:	75 0e                	jne    8005b1 <vprintfmt+0x189>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005af:	eb 6d                	jmp    80061e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b7:	57                   	push   %edi
  8005b8:	e8 6e 03 00 00       	call   80092b <strnlen>
  8005bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c0:	29 c1                	sub    %eax,%ecx
  8005c2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005c8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	eb 0f                	jmp    8005e5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	ff 75 e0             	pushl  -0x20(%ebp)
  8005dd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 ef 01             	sub    $0x1,%edi
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	7f ed                	jg     8005d6 <vprintfmt+0x1ae>
  8005e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f6:	0f 49 c1             	cmovns %ecx,%eax
  8005f9:	29 c1                	sub    %eax,%ecx
  8005fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800601:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800604:	89 cb                	mov    %ecx,%ebx
  800606:	eb 16                	jmp    80061e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800608:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060c:	75 31                	jne    80063f <vprintfmt+0x217>
					putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	50                   	push   %eax
  800615:	ff 55 08             	call   *0x8(%ebp)
  800618:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	83 c7 01             	add    $0x1,%edi
  800621:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800625:	0f be c2             	movsbl %dl,%eax
  800628:	85 c0                	test   %eax,%eax
  80062a:	74 59                	je     800685 <vprintfmt+0x25d>
  80062c:	85 f6                	test   %esi,%esi
  80062e:	78 d8                	js     800608 <vprintfmt+0x1e0>
  800630:	83 ee 01             	sub    $0x1,%esi
  800633:	79 d3                	jns    800608 <vprintfmt+0x1e0>
  800635:	89 df                	mov    %ebx,%edi
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063d:	eb 37                	jmp    800676 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	0f be d2             	movsbl %dl,%edx
  800642:	83 ea 20             	sub    $0x20,%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 c4                	jbe    80060e <vprintfmt+0x1e6>
					putch('?', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	6a 3f                	push   $0x3f
  800652:	ff 55 08             	call   *0x8(%ebp)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb c1                	jmp    80061b <vprintfmt+0x1f3>
  80065a:	89 75 08             	mov    %esi,0x8(%ebp)
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800666:	eb b6                	jmp    80061e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 20                	push   $0x20
  80066e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	85 ff                	test   %edi,%edi
  800678:	7f ee                	jg     800668 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	e9 78 01 00 00       	jmp    8007fd <vprintfmt+0x3d5>
  800685:	89 df                	mov    %ebx,%edi
  800687:	8b 75 08             	mov    0x8(%ebp),%esi
  80068a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80068d:	eb e7                	jmp    800676 <vprintfmt+0x24e>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 3f                	jle    8006d3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 50 04             	mov    0x4(%eax),%edx
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 40 08             	lea    0x8(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006af:	79 5c                	jns    80070d <vprintfmt+0x2e5>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bf:	f7 da                	neg    %edx
  8006c1:	83 d1 00             	adc    $0x0,%ecx
  8006c4:	f7 d9                	neg    %ecx
  8006c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	e9 10 01 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	75 1b                	jne    8006f2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 c1                	mov    %eax,%ecx
  8006e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f0:	eb b9                	jmp    8006ab <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 c1                	mov    %eax,%ecx
  8006fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
  80070b:	eb 9e                	jmp    8006ab <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80070d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800710:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800713:	b8 0a 00 00 00       	mov    $0xa,%eax
  800718:	e9 c6 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80071d:	83 f9 01             	cmp    $0x1,%ecx
  800720:	7e 18                	jle    80073a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	8b 48 04             	mov    0x4(%eax),%ecx
  80072a:	8d 40 08             	lea    0x8(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 a9 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80073a:	85 c9                	test   %ecx,%ecx
  80073c:	75 1a                	jne    800758 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8b 10                	mov    (%eax),%edx
  800743:	b9 00 00 00 00       	mov    $0x0,%ecx
  800748:	8d 40 04             	lea    0x4(%eax),%eax
  80074b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800753:	e9 8b 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800768:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076d:	eb 74                	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7e 15                	jle    800789 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800782:	b8 08 00 00 00       	mov    $0x8,%eax
  800787:	eb 5a                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 17                	jne    8007a4 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80079d:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a2:	eb 3f                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8007b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b9:	eb 28                	jmp    8007e3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	6a 30                	push   $0x30
  8007c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 78                	push   $0x78
  8007c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007de:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007e3:	83 ec 0c             	sub    $0xc,%esp
  8007e6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ea:	57                   	push   %edi
  8007eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ee:	50                   	push   %eax
  8007ef:	51                   	push   %ecx
  8007f0:	52                   	push   %edx
  8007f1:	89 da                	mov    %ebx,%edx
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	e8 45 fb ff ff       	call   80033f <printnum>
			break;
  8007fa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800800:	83 c7 01             	add    $0x1,%edi
  800803:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800807:	83 f8 25             	cmp    $0x25,%eax
  80080a:	0f 84 2f fc ff ff    	je     80043f <vprintfmt+0x17>
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 8b 00 00 00    	je     8008a3 <vprintfmt+0x47b>
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb dc                	jmp    800800 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800824:	83 f9 01             	cmp    $0x1,%ecx
  800827:	7e 15                	jle    80083e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8b 48 04             	mov    0x4(%eax),%ecx
  800831:	8d 40 08             	lea    0x8(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
  80083c:	eb a5                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	75 17                	jne    800859 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800852:	b8 10 00 00 00       	mov    $0x10,%eax
  800857:	eb 8a                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800863:	8d 40 04             	lea    0x4(%eax),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800869:	b8 10 00 00 00       	mov    $0x10,%eax
  80086e:	e9 70 ff ff ff       	jmp    8007e3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 25                	push   $0x25
  800879:	ff d6                	call   *%esi
			break;
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	e9 7a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
			putch('%', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 25                	push   $0x25
  800889:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	89 f8                	mov    %edi,%eax
  800890:	eb 03                	jmp    800895 <vprintfmt+0x46d>
  800892:	83 e8 01             	sub    $0x1,%eax
  800895:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800899:	75 f7                	jne    800892 <vprintfmt+0x46a>
  80089b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80089e:	e9 5a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 18             	sub    $0x18,%esp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 26                	je     8008f2 <vsnprintf+0x47>
  8008cc:	85 d2                	test   %edx,%edx
  8008ce:	7e 22                	jle    8008f2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d0:	ff 75 14             	pushl  0x14(%ebp)
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d9:	50                   	push   %eax
  8008da:	68 ee 03 80 00       	push   $0x8003ee
  8008df:	e8 44 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ed:	83 c4 10             	add    $0x10,%esp
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
		return -E_INVAL;
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f7:	eb f7                	jmp    8008f0 <vsnprintf+0x45>

008008f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800902:	50                   	push   %eax
  800903:	ff 75 10             	pushl  0x10(%ebp)
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	ff 75 08             	pushl  0x8(%ebp)
  80090c:	e8 9a ff ff ff       	call   8008ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 03                	jmp    800923 <strlen+0x10>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0xd>
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb 03                	jmp    80093e <strnlen+0x13>
		n++;
  80093b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	74 06                	je     800948 <strnlen+0x1d>
  800942:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800946:	75 f3                	jne    80093b <strnlen+0x10>
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	89 c2                	mov    %eax,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800960:	88 5a ff             	mov    %bl,-0x1(%edx)
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	53                   	push   %ebx
  800972:	e8 9c ff ff ff       	call   800913 <strlen>
  800977:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	01 d8                	add    %ebx,%eax
  80097f:	50                   	push   %eax
  800980:	e8 c5 ff ff ff       	call   80094a <strcpy>
	return dst;
}
  800985:	89 d8                	mov    %ebx,%eax
  800987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	89 f3                	mov    %esi,%ebx
  800999:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	eb 0f                	jmp    8009af <strncpy+0x23>
		*dst++ = *src;
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ac:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 ed                	jne    8009a0 <strncpy+0x14>
	}
	return ret;
}
  8009b3:	89 f0                	mov    %esi,%eax
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c7:	89 f0                	mov    %esi,%eax
  8009c9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	75 0b                	jne    8009dc <strlcpy+0x23>
  8009d1:	eb 17                	jmp    8009ea <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 07                	je     8009e7 <strlcpy+0x2e>
  8009e0:	0f b6 0a             	movzbl (%edx),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	75 ec                	jne    8009d3 <strlcpy+0x1a>
		*dst = '\0';
  8009e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ea:	29 f0                	sub    %esi,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f9:	eb 06                	jmp    800a01 <strcmp+0x11>
		p++, q++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 04                	je     800a0c <strcmp+0x1c>
  800a08:	3a 02                	cmp    (%edx),%al
  800a0a:	74 ef                	je     8009fb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strncmp+0x17>
		n--, p++, q++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2d:	39 d8                	cmp    %ebx,%eax
  800a2f:	74 16                	je     800a47 <strncmp+0x31>
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	84 c9                	test   %cl,%cl
  800a36:	74 04                	je     800a3c <strncmp+0x26>
  800a38:	3a 0a                	cmp    (%edx),%cl
  800a3a:	74 eb                	je     800a27 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3c:	0f b6 00             	movzbl (%eax),%eax
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	29 d0                	sub    %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb f6                	jmp    800a44 <strncmp+0x2e>

00800a4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	74 09                	je     800a68 <strchr+0x1a>
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	74 0a                	je     800a6d <strchr+0x1f>
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	eb f0                	jmp    800a58 <strchr+0xa>
			return (char *) s;
	return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a79:	eb 03                	jmp    800a7e <strfind+0xf>
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 04                	je     800a89 <strfind+0x1a>
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f2                	jne    800a7b <strfind+0xc>
			break;
	return (char *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a97:	85 c9                	test   %ecx,%ecx
  800a99:	74 13                	je     800aae <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa1:	75 05                	jne    800aa8 <memset+0x1d>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	74 0d                	je     800ab5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	fc                   	cld    
  800aac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aae:	89 f8                	mov    %edi,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    
		c &= 0xFF;
  800ab5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	c1 e3 08             	shl    $0x8,%ebx
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	c1 e0 18             	shl    $0x18,%eax
  800ac3:	89 d6                	mov    %edx,%esi
  800ac5:	c1 e6 10             	shl    $0x10,%esi
  800ac8:	09 f0                	or     %esi,%eax
  800aca:	09 c2                	or     %eax,%edx
  800acc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ace:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	fc                   	cld    
  800ad4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad6:	eb d6                	jmp    800aae <memset+0x23>

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 35                	jae    800b1f <memmove+0x47>
  800aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aed:	39 c2                	cmp    %eax,%edx
  800aef:	76 2e                	jbe    800b1f <memmove+0x47>
		s += n;
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	09 fe                	or     %edi,%esi
  800af8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afe:	74 0c                	je     800b0c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b06:	fd                   	std    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b09:	fc                   	cld    
  800b0a:	eb 21                	jmp    800b2d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 ef                	jne    800b00 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb ea                	jmp    800b09 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	89 f2                	mov    %esi,%edx
  800b21:	09 c2                	or     %eax,%edx
  800b23:	f6 c2 03             	test   $0x3,%dl
  800b26:	74 09                	je     800b31 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	f6 c1 03             	test   $0x3,%cl
  800b34:	75 f2                	jne    800b28 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3e:	eb ed                	jmp    800b2d <memmove+0x55>

00800b40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 87 ff ff ff       	call   800ad8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 f0                	cmp    %esi,%eax
  800b65:	74 1c                	je     800b83 <memcmp+0x30>
		if (*s1 != *s2)
  800b67:	0f b6 08             	movzbl (%eax),%ecx
  800b6a:	0f b6 1a             	movzbl (%edx),%ebx
  800b6d:	38 d9                	cmp    %bl,%cl
  800b6f:	75 08                	jne    800b79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	eb ea                	jmp    800b63 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c1             	movzbl %cl,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 05                	jmp    800b88 <memcmp+0x35>
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 09                	jae    800ba7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 05                	je     800ba7 <memfind+0x1b>
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	eb f3                	jmp    800b9a <memfind+0xe>
			break;
	return (void *) s;
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	74 2e                	je     800bf7 <strtol+0x4e>
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bce:	3c 2d                	cmp    $0x2d,%al
  800bd0:	74 2f                	je     800c01 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd8:	75 05                	jne    800bdf <strtol+0x36>
  800bda:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdd:	74 2c                	je     800c0b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0a                	jne    800bed <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be8:	80 39 30             	cmpb   $0x30,(%ecx)
  800beb:	74 28                	je     800c15 <strtol+0x6c>
		base = 10;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf5:	eb 50                	jmp    800c47 <strtol+0x9e>
		s++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb d1                	jmp    800bd2 <strtol+0x29>
		s++, neg = 1;
  800c01:	83 c1 01             	add    $0x1,%ecx
  800c04:	bf 01 00 00 00       	mov    $0x1,%edi
  800c09:	eb c7                	jmp    800bd2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	74 0e                	je     800c1f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	75 d8                	jne    800bed <strtol+0x44>
		s++, base = 8;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c1d:	eb ce                	jmp    800bed <strtol+0x44>
		s += 2, base = 16;
  800c1f:	83 c1 02             	add    $0x2,%ecx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb c4                	jmp    800bed <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c2c:	89 f3                	mov    %esi,%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 29                	ja     800c5c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c33:	0f be d2             	movsbl %dl,%edx
  800c36:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3c:	7d 30                	jge    800c6e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 09             	cmp    $0x9,%bl
  800c52:	77 d5                	ja     800c29 <strtol+0x80>
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
  800c5a:	eb dd                	jmp    800c39 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 37             	sub    $0x37,%edx
  800c6c:	eb cb                	jmp    800c39 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 c6                	mov    %eax,%esi
  800c9e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 03                	push   $0x3
  800cf4:	68 3f 27 80 00       	push   $0x80273f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 5c 27 80 00       	push   $0x80275c
  800d00:	e8 4b f5 ff ff       	call   800250 <_panic>

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 04                	push   $0x4
  800d75:	68 3f 27 80 00       	push   $0x80273f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 5c 27 80 00       	push   $0x80275c
  800d81:	e8 ca f4 ff ff       	call   800250 <_panic>

00800d86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 75 18             	mov    0x18(%ebp),%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 05                	push   $0x5
  800db7:	68 3f 27 80 00       	push   $0x80273f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 5c 27 80 00       	push   $0x80275c
  800dc3:	e8 88 f4 ff ff       	call   800250 <_panic>

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	b8 06 00 00 00       	mov    $0x6,%eax
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7f 08                	jg     800df3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 06                	push   $0x6
  800df9:	68 3f 27 80 00       	push   $0x80273f
  800dfe:	6a 23                	push   $0x23
  800e00:	68 5c 27 80 00       	push   $0x80275c
  800e05:	e8 46 f4 ff ff       	call   800250 <_panic>

00800e0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7f 08                	jg     800e35 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 08                	push   $0x8
  800e3b:	68 3f 27 80 00       	push   $0x80273f
  800e40:	6a 23                	push   $0x23
  800e42:	68 5c 27 80 00       	push   $0x80275c
  800e47:	e8 04 f4 ff ff       	call   800250 <_panic>

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	b8 09 00 00 00       	mov    $0x9,%eax
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7f 08                	jg     800e77 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 09                	push   $0x9
  800e7d:	68 3f 27 80 00       	push   $0x80273f
  800e82:	6a 23                	push   $0x23
  800e84:	68 5c 27 80 00       	push   $0x80275c
  800e89:	e8 c2 f3 ff ff       	call   800250 <_panic>

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7f 08                	jg     800eb9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 0a                	push   $0xa
  800ebf:	68 3f 27 80 00       	push   $0x80273f
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 5c 27 80 00       	push   $0x80275c
  800ecb:	e8 80 f3 ff ff       	call   800250 <_panic>

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7f 08                	jg     800f1d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 0d                	push   $0xd
  800f23:	68 3f 27 80 00       	push   $0x80273f
  800f28:	6a 23                	push   $0x23
  800f2a:	68 5c 27 80 00       	push   $0x80275c
  800f2f:	e8 1c f3 ff ff       	call   800250 <_panic>

00800f34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3e:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f40:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f43:	a8 02                	test   $0x2,%al
  800f45:	0f 84 89 00 00 00    	je     800fd4 <pgfault+0xa0>
  800f4b:	89 da                	mov    %ebx,%edx
  800f4d:	c1 ea 0c             	shr    $0xc,%edx
  800f50:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f57:	f6 c6 08             	test   $0x8,%dh
  800f5a:	74 78                	je     800fd4 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	6a 07                	push   $0x7
  800f61:	68 00 f0 7f 00       	push   $0x7ff000
  800f66:	6a 00                	push   $0x0
  800f68:	e8 d6 fd ff ff       	call   800d43 <sys_page_alloc>
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	0f 88 8b 00 00 00    	js     801003 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800f78:	83 ec 04             	sub    $0x4,%esp
  800f7b:	68 00 10 00 00       	push   $0x1000
  800f80:	53                   	push   %ebx
  800f81:	68 00 f0 7f 00       	push   $0x7ff000
  800f86:	e8 4d fb ff ff       	call   800ad8 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f8b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f92:	53                   	push   %ebx
  800f93:	6a 00                	push   $0x0
  800f95:	68 00 f0 7f 00       	push   $0x7ff000
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 e5 fd ff ff       	call   800d86 <sys_page_map>
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 6d                	js     801015 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	68 00 f0 7f 00       	push   $0x7ff000
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 11 fe ff ff       	call   800dc8 <sys_page_unmap>
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 69                	js     801027 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	53                   	push   %ebx
  800fc2:	68 c8 27 80 00       	push   $0x8027c8
  800fc7:	e8 5f f3 ff ff       	call   80032b <cprintf>

}
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800fd4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fda:	8b 4a 48             	mov    0x48(%edx),%ecx
  800fdd:	89 da                	mov    %ebx,%edx
  800fdf:	c1 ea 0c             	shr    $0xc,%edx
  800fe2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe9:	51                   	push   %ecx
  800fea:	53                   	push   %ebx
  800feb:	68 00 00 40 ef       	push   $0xef400000
  800ff0:	52                   	push   %edx
  800ff1:	50                   	push   %eax
  800ff2:	68 6c 27 80 00       	push   $0x80276c
  800ff7:	6a 1e                	push   $0x1e
  800ff9:	68 e9 27 80 00       	push   $0x8027e9
  800ffe:	e8 4d f2 ff ff       	call   800250 <_panic>
        panic("sys_page_alloc error %e", r);
  801003:	50                   	push   %eax
  801004:	68 f4 27 80 00       	push   $0x8027f4
  801009:	6a 28                	push   $0x28
  80100b:	68 e9 27 80 00       	push   $0x8027e9
  801010:	e8 3b f2 ff ff       	call   800250 <_panic>
        panic("sys_page_map error %e", r);
  801015:	50                   	push   %eax
  801016:	68 0c 28 80 00       	push   $0x80280c
  80101b:	6a 2b                	push   $0x2b
  80101d:	68 e9 27 80 00       	push   $0x8027e9
  801022:	e8 29 f2 ff ff       	call   800250 <_panic>
        panic("sys_page_unmap error %e", r);
  801027:	50                   	push   %eax
  801028:	68 22 28 80 00       	push   $0x802822
  80102d:	6a 2d                	push   $0x2d
  80102f:	68 e9 27 80 00       	push   $0x8027e9
  801034:	e8 17 f2 ff ff       	call   800250 <_panic>

00801039 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80103f:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801046:	74 23                	je     80106b <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801048:	8b 45 08             	mov    0x8(%ebp),%eax
  80104b:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801050:	a1 04 40 80 00       	mov    0x804004,%eax
  801055:	8b 40 48             	mov    0x48(%eax),%eax
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	68 ba 20 80 00       	push   $0x8020ba
  801060:	50                   	push   %eax
  801061:	e8 28 fe ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
}
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	c9                   	leave  
  80106a:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  80106b:	a1 04 40 80 00       	mov    0x804004,%eax
  801070:	8b 40 48             	mov    0x48(%eax),%eax
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	6a 07                	push   $0x7
  801078:	68 00 f0 bf ee       	push   $0xeebff000
  80107d:	50                   	push   %eax
  80107e:	e8 c0 fc ff ff       	call   800d43 <sys_page_alloc>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 be                	jns    801048 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 3a 28 80 00       	push   $0x80283a
  801090:	6a 21                	push   $0x21
  801092:	68 4d 28 80 00       	push   $0x80284d
  801097:	e8 b4 f1 ff ff       	call   800250 <_panic>

0080109c <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	6a 07                	push   $0x7
  8010ac:	53                   	push   %ebx
  8010ad:	56                   	push   %esi
  8010ae:	e8 90 fc ff ff       	call   800d43 <sys_page_alloc>
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 4a                	js     801104 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	6a 07                	push   $0x7
  8010bf:	68 00 00 40 00       	push   $0x400000
  8010c4:	6a 00                	push   $0x0
  8010c6:	53                   	push   %ebx
  8010c7:	56                   	push   %esi
  8010c8:	e8 b9 fc ff ff       	call   800d86 <sys_page_map>
  8010cd:	83 c4 20             	add    $0x20,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	78 42                	js     801116 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	68 00 10 00 00       	push   $0x1000
  8010dc:	53                   	push   %ebx
  8010dd:	68 00 00 40 00       	push   $0x400000
  8010e2:	e8 f1 f9 ff ff       	call   800ad8 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8010e7:	83 c4 08             	add    $0x8,%esp
  8010ea:	68 00 00 40 00       	push   $0x400000
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 d2 fc ff ff       	call   800dc8 <sys_page_unmap>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 2b                	js     801128 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  8010fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  801104:	50                   	push   %eax
  801105:	68 3a 28 80 00       	push   $0x80283a
  80110a:	6a 63                	push   $0x63
  80110c:	68 e9 27 80 00       	push   $0x8027e9
  801111:	e8 3a f1 ff ff       	call   800250 <_panic>
        panic("sys_page_map: %e", r);
  801116:	50                   	push   %eax
  801117:	68 5d 28 80 00       	push   $0x80285d
  80111c:	6a 65                	push   $0x65
  80111e:	68 e9 27 80 00       	push   $0x8027e9
  801123:	e8 28 f1 ff ff       	call   800250 <_panic>
        panic("sys_page_unmap: %e", r);
  801128:	50                   	push   %eax
  801129:	68 6e 28 80 00       	push   $0x80286e
  80112e:	6a 68                	push   $0x68
  801130:	68 e9 27 80 00       	push   $0x8027e9
  801135:	e8 16 f1 ff ff       	call   800250 <_panic>

0080113a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801143:	a1 04 40 80 00       	mov    0x804004,%eax
  801148:	8b 40 64             	mov    0x64(%eax),%eax
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 1f                	je     80116e <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80114f:	b8 07 00 00 00       	mov    $0x7,%eax
  801154:	cd 30                	int    $0x30
  801156:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801158:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80115b:	85 c0                	test   %eax,%eax
  80115d:	74 21                	je     801180 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  80115f:	be 08 40 80 00       	mov    $0x804008,%esi
  801164:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801167:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116c:	eb 7b                	jmp    8011e9 <fork+0xaf>
        set_pgfault_handler(pgfault);
  80116e:	83 ec 0c             	sub    $0xc,%esp
  801171:	68 34 0f 80 00       	push   $0x800f34
  801176:	e8 be fe ff ff       	call   801039 <set_pgfault_handler>
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	eb cf                	jmp    80114f <fork+0x15>
        set_pgfault_handler(pgfault);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	68 34 0f 80 00       	push   $0x800f34
  801188:	e8 ac fe ff ff       	call   801039 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  80118d:	e8 73 fb ff ff       	call   800d05 <sys_getenvid>
  801192:	25 ff 03 00 00       	and    $0x3ff,%eax
  801197:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80119f:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	e9 ca 00 00 00       	jmp    801276 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  8011ac:	89 d1                	mov    %edx,%ecx
  8011ae:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  8011b4:	81 e2 02 08 00 00    	and    $0x802,%edx
  8011ba:	89 cf                	mov    %ecx,%edi
  8011bc:	81 cf 00 08 00 00    	or     $0x800,%edi
  8011c2:	85 d2                	test   %edx,%edx
  8011c4:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	51                   	push   %ecx
  8011cb:	50                   	push   %eax
  8011cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cf:	50                   	push   %eax
  8011d0:	6a 00                	push   $0x0
  8011d2:	e8 af fb ff ff       	call   800d86 <sys_page_map>
  8011d7:	83 c4 20             	add    $0x20,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 45                	js     801223 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8011de:	83 c3 01             	add    $0x1,%ebx
  8011e1:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8011e7:	74 4c                	je     801235 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8011e9:	39 de                	cmp    %ebx,%esi
  8011eb:	74 f1                	je     8011de <fork+0xa4>
  8011ed:	89 d8                	mov    %ebx,%eax
  8011ef:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	c1 ea 16             	shr    $0x16,%edx
  8011f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8011fe:	f6 c2 05             	test   $0x5,%dl
  801201:	74 db                	je     8011de <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  801203:	89 c2                	mov    %eax,%edx
  801205:	c1 ea 0c             	shr    $0xc,%edx
  801208:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  80120f:	f6 c2 04             	test   $0x4,%dl
  801212:	74 ca                	je     8011de <fork+0xa4>
    if (perm & PTE_SHARE) {
  801214:	f6 c6 04             	test   $0x4,%dh
  801217:	74 93                	je     8011ac <fork+0x72>
        perm &= ~PTE_COW;
  801219:	89 d1                	mov    %edx,%ecx
  80121b:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801221:	eb a4                	jmp    8011c7 <fork+0x8d>
        panic("sys_page_map error %e", r);
  801223:	50                   	push   %eax
  801224:	68 0c 28 80 00       	push   $0x80280c
  801229:	6a 57                	push   $0x57
  80122b:	68 e9 27 80 00       	push   $0x8027e9
  801230:	e8 1b f0 ff ff       	call   800250 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	b8 08 40 80 00       	mov    $0x804008,%eax
  80123d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801242:	50                   	push   %eax
  801243:	ff 75 e4             	pushl  -0x1c(%ebp)
  801246:	e8 51 fe ff ff       	call   80109c <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801251:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801256:	50                   	push   %eax
  801257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80125a:	e8 3d fe ff ff       	call   80109c <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80125f:	83 c4 08             	add    $0x8,%esp
  801262:	6a 02                	push   $0x2
  801264:	ff 75 e4             	pushl  -0x1c(%ebp)
  801267:	e8 9e fb ff ff       	call   800e0a <sys_env_set_status>
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 0d                	js     801280 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801273:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801276:	89 d8                	mov    %ebx,%eax
  801278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5f                   	pop    %edi
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801280:	50                   	push   %eax
  801281:	68 81 28 80 00       	push   $0x802881
  801286:	68 a0 00 00 00       	push   $0xa0
  80128b:	68 e9 27 80 00       	push   $0x8027e9
  801290:	e8 bb ef ff ff       	call   800250 <_panic>

00801295 <sfork>:

// Challenge!
int
sfork(void)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80129b:	68 98 28 80 00       	push   $0x802898
  8012a0:	68 a9 00 00 00       	push   $0xa9
  8012a5:	68 e9 27 80 00       	push   $0x8027e9
  8012aa:	e8 a1 ef ff ff       	call   800250 <_panic>

008012af <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8012c4:	0f 44 c2             	cmove  %edx,%eax
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	50                   	push   %eax
  8012cb:	e8 23 fc ff ff       	call   800ef3 <sys_ipc_recv>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 2b                	js     801302 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  8012d7:	85 f6                	test   %esi,%esi
  8012d9:	74 0a                	je     8012e5 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  8012db:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e0:	8b 40 74             	mov    0x74(%eax),%eax
  8012e3:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  8012e5:	85 db                	test   %ebx,%ebx
  8012e7:	74 0a                	je     8012f3 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  8012e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ee:	8b 40 78             	mov    0x78(%eax),%eax
  8012f1:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  8012f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
        *from_env_store = 0;
  801302:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801308:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  80130e:	eb eb                	jmp    8012fb <ipc_recv+0x4c>

00801310 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	8b 7d 08             	mov    0x8(%ebp),%edi
  80131c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80131f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801322:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801324:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801329:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  80132c:	ff 75 14             	pushl  0x14(%ebp)
  80132f:	53                   	push   %ebx
  801330:	56                   	push   %esi
  801331:	57                   	push   %edi
  801332:	e8 99 fb ff ff       	call   800ed0 <sys_ipc_try_send>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	74 17                	je     801355 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  80133e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801341:	74 e9                	je     80132c <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801343:	50                   	push   %eax
  801344:	68 ae 28 80 00       	push   $0x8028ae
  801349:	6a 3e                	push   $0x3e
  80134b:	68 c0 28 80 00       	push   $0x8028c0
  801350:	e8 fb ee ff ff       	call   800250 <_panic>
        }
    }
}
  801355:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801358:	5b                   	pop    %ebx
  801359:	5e                   	pop    %esi
  80135a:	5f                   	pop    %edi
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801368:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80136b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801371:	8b 52 50             	mov    0x50(%edx),%edx
  801374:	39 ca                	cmp    %ecx,%edx
  801376:	74 11                	je     801389 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801378:	83 c0 01             	add    $0x1,%eax
  80137b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801380:	75 e6                	jne    801368 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	eb 0b                	jmp    801394 <ipc_find_env+0x37>
			return envs[i].env_id;
  801389:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801391:	8b 40 48             	mov    0x48(%eax),%eax
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	c1 ea 16             	shr    $0x16,%edx
  8013cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d4:	f6 c2 01             	test   $0x1,%dl
  8013d7:	74 2a                	je     801403 <fd_alloc+0x46>
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	c1 ea 0c             	shr    $0xc,%edx
  8013de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e5:	f6 c2 01             	test   $0x1,%dl
  8013e8:	74 19                	je     801403 <fd_alloc+0x46>
  8013ea:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013ef:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f4:	75 d2                	jne    8013c8 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013fc:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801401:	eb 07                	jmp    80140a <fd_alloc+0x4d>
			*fd_store = fd;
  801403:	89 01                	mov    %eax,(%ecx)
			return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801412:	83 f8 1f             	cmp    $0x1f,%eax
  801415:	77 36                	ja     80144d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801417:	c1 e0 0c             	shl    $0xc,%eax
  80141a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80141f:	89 c2                	mov    %eax,%edx
  801421:	c1 ea 16             	shr    $0x16,%edx
  801424:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142b:	f6 c2 01             	test   $0x1,%dl
  80142e:	74 24                	je     801454 <fd_lookup+0x48>
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 0c             	shr    $0xc,%edx
  801435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	74 1a                	je     80145b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801441:	8b 55 0c             	mov    0xc(%ebp),%edx
  801444:	89 02                	mov    %eax,(%edx)
	return 0;
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
		return -E_INVAL;
  80144d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801452:	eb f7                	jmp    80144b <fd_lookup+0x3f>
		return -E_INVAL;
  801454:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801459:	eb f0                	jmp    80144b <fd_lookup+0x3f>
  80145b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801460:	eb e9                	jmp    80144b <fd_lookup+0x3f>

00801462 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146b:	ba 48 29 80 00       	mov    $0x802948,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801470:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801475:	39 08                	cmp    %ecx,(%eax)
  801477:	74 33                	je     8014ac <dev_lookup+0x4a>
  801479:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80147c:	8b 02                	mov    (%edx),%eax
  80147e:	85 c0                	test   %eax,%eax
  801480:	75 f3                	jne    801475 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801482:	a1 04 40 80 00       	mov    0x804004,%eax
  801487:	8b 40 48             	mov    0x48(%eax),%eax
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	51                   	push   %ecx
  80148e:	50                   	push   %eax
  80148f:	68 cc 28 80 00       	push   $0x8028cc
  801494:	e8 92 ee ff ff       	call   80032b <cprintf>
	*dev = 0;
  801499:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    
			*dev = devtab[i];
  8014ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b6:	eb f2                	jmp    8014aa <dev_lookup+0x48>

008014b8 <fd_close>:
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	57                   	push   %edi
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
  8014be:	83 ec 1c             	sub    $0x1c,%esp
  8014c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ca:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014d1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d4:	50                   	push   %eax
  8014d5:	e8 32 ff ff ff       	call   80140c <fd_lookup>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 05                	js     8014e8 <fd_close+0x30>
	    || fd != fd2)
  8014e3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014e6:	74 16                	je     8014fe <fd_close+0x46>
		return (must_exist ? r : 0);
  8014e8:	89 f8                	mov    %edi,%eax
  8014ea:	84 c0                	test   %al,%al
  8014ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f1:	0f 44 d8             	cmove  %eax,%ebx
}
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	ff 36                	pushl  (%esi)
  801507:	e8 56 ff ff ff       	call   801462 <dev_lookup>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	85 c0                	test   %eax,%eax
  801513:	78 15                	js     80152a <fd_close+0x72>
		if (dev->dev_close)
  801515:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801518:	8b 40 10             	mov    0x10(%eax),%eax
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 1b                	je     80153a <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	56                   	push   %esi
  801523:	ff d0                	call   *%eax
  801525:	89 c3                	mov    %eax,%ebx
  801527:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	56                   	push   %esi
  80152e:	6a 00                	push   $0x0
  801530:	e8 93 f8 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	eb ba                	jmp    8014f4 <fd_close+0x3c>
			r = 0;
  80153a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153f:	eb e9                	jmp    80152a <fd_close+0x72>

00801541 <close>:

int
close(int fdnum)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 b9 fe ff ff       	call   80140c <fd_lookup>
  801553:	83 c4 08             	add    $0x8,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 10                	js     80156a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	6a 01                	push   $0x1
  80155f:	ff 75 f4             	pushl  -0xc(%ebp)
  801562:	e8 51 ff ff ff       	call   8014b8 <fd_close>
  801567:	83 c4 10             	add    $0x10,%esp
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <close_all>:

void
close_all(void)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801573:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	53                   	push   %ebx
  80157c:	e8 c0 ff ff ff       	call   801541 <close>
	for (i = 0; i < MAXFD; i++)
  801581:	83 c3 01             	add    $0x1,%ebx
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	83 fb 20             	cmp    $0x20,%ebx
  80158a:	75 ec                	jne    801578 <close_all+0xc>
}
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	57                   	push   %edi
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
  801597:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80159a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	e8 66 fe ff ff       	call   80140c <fd_lookup>
  8015a6:	89 c3                	mov    %eax,%ebx
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	0f 88 81 00 00 00    	js     801634 <dup+0xa3>
		return r;
	close(newfdnum);
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	ff 75 0c             	pushl  0xc(%ebp)
  8015b9:	e8 83 ff ff ff       	call   801541 <close>

	newfd = INDEX2FD(newfdnum);
  8015be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015c1:	c1 e6 0c             	shl    $0xc,%esi
  8015c4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015ca:	83 c4 04             	add    $0x4,%esp
  8015cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d0:	e8 d1 fd ff ff       	call   8013a6 <fd2data>
  8015d5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015d7:	89 34 24             	mov    %esi,(%esp)
  8015da:	e8 c7 fd ff ff       	call   8013a6 <fd2data>
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	c1 e8 16             	shr    $0x16,%eax
  8015e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f0:	a8 01                	test   $0x1,%al
  8015f2:	74 11                	je     801605 <dup+0x74>
  8015f4:	89 d8                	mov    %ebx,%eax
  8015f6:	c1 e8 0c             	shr    $0xc,%eax
  8015f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801600:	f6 c2 01             	test   $0x1,%dl
  801603:	75 39                	jne    80163e <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801605:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801608:	89 d0                	mov    %edx,%eax
  80160a:	c1 e8 0c             	shr    $0xc,%eax
  80160d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801614:	83 ec 0c             	sub    $0xc,%esp
  801617:	25 07 0e 00 00       	and    $0xe07,%eax
  80161c:	50                   	push   %eax
  80161d:	56                   	push   %esi
  80161e:	6a 00                	push   $0x0
  801620:	52                   	push   %edx
  801621:	6a 00                	push   $0x0
  801623:	e8 5e f7 ff ff       	call   800d86 <sys_page_map>
  801628:	89 c3                	mov    %eax,%ebx
  80162a:	83 c4 20             	add    $0x20,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 31                	js     801662 <dup+0xd1>
		goto err;

	return newfdnum;
  801631:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801634:	89 d8                	mov    %ebx,%eax
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801645:	83 ec 0c             	sub    $0xc,%esp
  801648:	25 07 0e 00 00       	and    $0xe07,%eax
  80164d:	50                   	push   %eax
  80164e:	57                   	push   %edi
  80164f:	6a 00                	push   $0x0
  801651:	53                   	push   %ebx
  801652:	6a 00                	push   $0x0
  801654:	e8 2d f7 ff ff       	call   800d86 <sys_page_map>
  801659:	89 c3                	mov    %eax,%ebx
  80165b:	83 c4 20             	add    $0x20,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	79 a3                	jns    801605 <dup+0x74>
	sys_page_unmap(0, newfd);
  801662:	83 ec 08             	sub    $0x8,%esp
  801665:	56                   	push   %esi
  801666:	6a 00                	push   $0x0
  801668:	e8 5b f7 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166d:	83 c4 08             	add    $0x8,%esp
  801670:	57                   	push   %edi
  801671:	6a 00                	push   $0x0
  801673:	e8 50 f7 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb b7                	jmp    801634 <dup+0xa3>

0080167d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	53                   	push   %ebx
  801681:	83 ec 14             	sub    $0x14,%esp
  801684:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801687:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	53                   	push   %ebx
  80168c:	e8 7b fd ff ff       	call   80140c <fd_lookup>
  801691:	83 c4 08             	add    $0x8,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 3f                	js     8016d7 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169e:	50                   	push   %eax
  80169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a2:	ff 30                	pushl  (%eax)
  8016a4:	e8 b9 fd ff ff       	call   801462 <dev_lookup>
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 27                	js     8016d7 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016b3:	8b 42 08             	mov    0x8(%edx),%eax
  8016b6:	83 e0 03             	and    $0x3,%eax
  8016b9:	83 f8 01             	cmp    $0x1,%eax
  8016bc:	74 1e                	je     8016dc <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c1:	8b 40 08             	mov    0x8(%eax),%eax
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	74 35                	je     8016fd <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	ff 75 10             	pushl  0x10(%ebp)
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	52                   	push   %edx
  8016d2:	ff d0                	call   *%eax
  8016d4:	83 c4 10             	add    $0x10,%esp
}
  8016d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e1:	8b 40 48             	mov    0x48(%eax),%eax
  8016e4:	83 ec 04             	sub    $0x4,%esp
  8016e7:	53                   	push   %ebx
  8016e8:	50                   	push   %eax
  8016e9:	68 0d 29 80 00       	push   $0x80290d
  8016ee:	e8 38 ec ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fb:	eb da                	jmp    8016d7 <read+0x5a>
		return -E_NOT_SUPP;
  8016fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801702:	eb d3                	jmp    8016d7 <read+0x5a>

00801704 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	57                   	push   %edi
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801710:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801713:	bb 00 00 00 00       	mov    $0x0,%ebx
  801718:	39 f3                	cmp    %esi,%ebx
  80171a:	73 25                	jae    801741 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	89 f0                	mov    %esi,%eax
  801721:	29 d8                	sub    %ebx,%eax
  801723:	50                   	push   %eax
  801724:	89 d8                	mov    %ebx,%eax
  801726:	03 45 0c             	add    0xc(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	57                   	push   %edi
  80172b:	e8 4d ff ff ff       	call   80167d <read>
		if (m < 0)
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 08                	js     80173f <readn+0x3b>
			return m;
		if (m == 0)
  801737:	85 c0                	test   %eax,%eax
  801739:	74 06                	je     801741 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80173b:	01 c3                	add    %eax,%ebx
  80173d:	eb d9                	jmp    801718 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801741:	89 d8                	mov    %ebx,%eax
  801743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5f                   	pop    %edi
  801749:	5d                   	pop    %ebp
  80174a:	c3                   	ret    

0080174b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	53                   	push   %ebx
  80174f:	83 ec 14             	sub    $0x14,%esp
  801752:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801755:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801758:	50                   	push   %eax
  801759:	53                   	push   %ebx
  80175a:	e8 ad fc ff ff       	call   80140c <fd_lookup>
  80175f:	83 c4 08             	add    $0x8,%esp
  801762:	85 c0                	test   %eax,%eax
  801764:	78 3a                	js     8017a0 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801770:	ff 30                	pushl  (%eax)
  801772:	e8 eb fc ff ff       	call   801462 <dev_lookup>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 22                	js     8017a0 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801785:	74 1e                	je     8017a5 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	8b 52 0c             	mov    0xc(%edx),%edx
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 35                	je     8017c6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	ff 75 10             	pushl  0x10(%ebp)
  801797:	ff 75 0c             	pushl  0xc(%ebp)
  80179a:	50                   	push   %eax
  80179b:	ff d2                	call   *%edx
  80179d:	83 c4 10             	add    $0x10,%esp
}
  8017a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a3:	c9                   	leave  
  8017a4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8017aa:	8b 40 48             	mov    0x48(%eax),%eax
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	53                   	push   %ebx
  8017b1:	50                   	push   %eax
  8017b2:	68 29 29 80 00       	push   $0x802929
  8017b7:	e8 6f eb ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c4:	eb da                	jmp    8017a0 <write+0x55>
		return -E_NOT_SUPP;
  8017c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cb:	eb d3                	jmp    8017a0 <write+0x55>

008017cd <seek>:

int
seek(int fdnum, off_t offset)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	ff 75 08             	pushl  0x8(%ebp)
  8017da:	e8 2d fc ff ff       	call   80140c <fd_lookup>
  8017df:	83 c4 08             	add    $0x8,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 0e                	js     8017f4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 14             	sub    $0x14,%esp
  8017fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	53                   	push   %ebx
  801805:	e8 02 fc ff ff       	call   80140c <fd_lookup>
  80180a:	83 c4 08             	add    $0x8,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 37                	js     801848 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181b:	ff 30                	pushl  (%eax)
  80181d:	e8 40 fc ff ff       	call   801462 <dev_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 1f                	js     801848 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801830:	74 1b                	je     80184d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801832:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801835:	8b 52 18             	mov    0x18(%edx),%edx
  801838:	85 d2                	test   %edx,%edx
  80183a:	74 32                	je     80186e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	ff 75 0c             	pushl  0xc(%ebp)
  801842:	50                   	push   %eax
  801843:	ff d2                	call   *%edx
  801845:	83 c4 10             	add    $0x10,%esp
}
  801848:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80184d:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801852:	8b 40 48             	mov    0x48(%eax),%eax
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	53                   	push   %ebx
  801859:	50                   	push   %eax
  80185a:	68 ec 28 80 00       	push   $0x8028ec
  80185f:	e8 c7 ea ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80186c:	eb da                	jmp    801848 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80186e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801873:	eb d3                	jmp    801848 <ftruncate+0x52>

00801875 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	53                   	push   %ebx
  801879:	83 ec 14             	sub    $0x14,%esp
  80187c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801882:	50                   	push   %eax
  801883:	ff 75 08             	pushl  0x8(%ebp)
  801886:	e8 81 fb ff ff       	call   80140c <fd_lookup>
  80188b:	83 c4 08             	add    $0x8,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 4b                	js     8018dd <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801898:	50                   	push   %eax
  801899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189c:	ff 30                	pushl  (%eax)
  80189e:	e8 bf fb ff ff       	call   801462 <dev_lookup>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 33                	js     8018dd <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b1:	74 2f                	je     8018e2 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018bd:	00 00 00 
	stat->st_isdir = 0;
  8018c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c7:	00 00 00 
	stat->st_dev = dev;
  8018ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d7:	ff 50 14             	call   *0x14(%eax)
  8018da:	83 c4 10             	add    $0x10,%esp
}
  8018dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    
		return -E_NOT_SUPP;
  8018e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018e7:	eb f4                	jmp    8018dd <fstat+0x68>

008018e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	6a 00                	push   $0x0
  8018f3:	ff 75 08             	pushl  0x8(%ebp)
  8018f6:	e8 e7 01 00 00       	call   801ae2 <open>
  8018fb:	89 c3                	mov    %eax,%ebx
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	85 c0                	test   %eax,%eax
  801902:	78 1b                	js     80191f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801904:	83 ec 08             	sub    $0x8,%esp
  801907:	ff 75 0c             	pushl  0xc(%ebp)
  80190a:	50                   	push   %eax
  80190b:	e8 65 ff ff ff       	call   801875 <fstat>
  801910:	89 c6                	mov    %eax,%esi
	close(fd);
  801912:	89 1c 24             	mov    %ebx,(%esp)
  801915:	e8 27 fc ff ff       	call   801541 <close>
	return r;
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	89 f3                	mov    %esi,%ebx
}
  80191f:	89 d8                	mov    %ebx,%eax
  801921:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	89 c6                	mov    %eax,%esi
  80192f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801931:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801938:	74 27                	je     801961 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80193a:	6a 07                	push   $0x7
  80193c:	68 00 50 80 00       	push   $0x805000
  801941:	56                   	push   %esi
  801942:	ff 35 00 40 80 00    	pushl  0x804000
  801948:	e8 c3 f9 ff ff       	call   801310 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80194d:	83 c4 0c             	add    $0xc,%esp
  801950:	6a 00                	push   $0x0
  801952:	53                   	push   %ebx
  801953:	6a 00                	push   $0x0
  801955:	e8 55 f9 ff ff       	call   8012af <ipc_recv>
}
  80195a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	6a 01                	push   $0x1
  801966:	e8 f2 f9 ff ff       	call   80135d <ipc_find_env>
  80196b:	a3 00 40 80 00       	mov    %eax,0x804000
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	eb c5                	jmp    80193a <fsipc+0x12>

00801975 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	8b 40 0c             	mov    0xc(%eax),%eax
  801981:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801986:	8b 45 0c             	mov    0xc(%ebp),%eax
  801989:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 02 00 00 00       	mov    $0x2,%eax
  801998:	e8 8b ff ff ff       	call   801928 <fsipc>
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_flush>:
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ba:	e8 69 ff ff ff       	call   801928 <fsipc>
}
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <devfile_stat>:
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e0:	e8 43 ff ff ff       	call   801928 <fsipc>
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 2c                	js     801a15 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	68 00 50 80 00       	push   $0x805000
  8019f1:	53                   	push   %ebx
  8019f2:	e8 53 ef ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8019fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a02:	a1 84 50 80 00       	mov    0x805084,%eax
  801a07:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devfile_write>:
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801a23:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a28:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a2d:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a30:	8b 55 08             	mov    0x8(%ebp),%edx
  801a33:	8b 52 0c             	mov    0xc(%edx),%edx
  801a36:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801a3c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801a41:	50                   	push   %eax
  801a42:	ff 75 0c             	pushl  0xc(%ebp)
  801a45:	68 08 50 80 00       	push   $0x805008
  801a4a:	e8 89 f0 ff ff       	call   800ad8 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a54:	b8 04 00 00 00       	mov    $0x4,%eax
  801a59:	e8 ca fe ff ff       	call   801928 <fsipc>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devfile_read>:
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a68:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a73:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a79:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a83:	e8 a0 fe ff ff       	call   801928 <fsipc>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 1f                	js     801aad <devfile_read+0x4d>
	assert(r <= n);
  801a8e:	39 f0                	cmp    %esi,%eax
  801a90:	77 24                	ja     801ab6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a92:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a97:	7f 33                	jg     801acc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a99:	83 ec 04             	sub    $0x4,%esp
  801a9c:	50                   	push   %eax
  801a9d:	68 00 50 80 00       	push   $0x805000
  801aa2:	ff 75 0c             	pushl  0xc(%ebp)
  801aa5:	e8 2e f0 ff ff       	call   800ad8 <memmove>
	return r;
  801aaa:	83 c4 10             	add    $0x10,%esp
}
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab2:	5b                   	pop    %ebx
  801ab3:	5e                   	pop    %esi
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    
	assert(r <= n);
  801ab6:	68 58 29 80 00       	push   $0x802958
  801abb:	68 5f 29 80 00       	push   $0x80295f
  801ac0:	6a 7d                	push   $0x7d
  801ac2:	68 74 29 80 00       	push   $0x802974
  801ac7:	e8 84 e7 ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  801acc:	68 7f 29 80 00       	push   $0x80297f
  801ad1:	68 5f 29 80 00       	push   $0x80295f
  801ad6:	6a 7e                	push   $0x7e
  801ad8:	68 74 29 80 00       	push   $0x802974
  801add:	e8 6e e7 ff ff       	call   800250 <_panic>

00801ae2 <open>:
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 1c             	sub    $0x1c,%esp
  801aea:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801aed:	56                   	push   %esi
  801aee:	e8 20 ee ff ff       	call   800913 <strlen>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801afb:	0f 8f 96 00 00 00    	jg     801b97 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801b01:	83 ec 0c             	sub    $0xc,%esp
  801b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b07:	50                   	push   %eax
  801b08:	e8 b0 f8 ff ff       	call   8013bd <fd_alloc>
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 66                	js     801b7c <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801b16:	83 ec 08             	sub    $0x8,%esp
  801b19:	56                   	push   %esi
  801b1a:	68 00 50 80 00       	push   $0x805000
  801b1f:	e8 26 ee ff ff       	call   80094a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b27:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b34:	e8 ef fd ff ff       	call   801928 <fsipc>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 43                	js     801b85 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	ff 75 f4             	pushl  -0xc(%ebp)
  801b48:	e8 49 f8 ff ff       	call   801396 <fd2num>
  801b4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b50:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801b56:	8b 49 48             	mov    0x48(%ecx),%ecx
  801b59:	83 c4 08             	add    $0x8,%esp
  801b5c:	50                   	push   %eax
  801b5d:	52                   	push   %edx
  801b5e:	ff 32                	pushl  (%edx)
  801b60:	56                   	push   %esi
  801b61:	51                   	push   %ecx
  801b62:	68 8c 29 80 00       	push   $0x80298c
  801b67:	e8 bf e7 ff ff       	call   80032b <cprintf>
	return fd2num(fd);
  801b6c:	83 c4 14             	add    $0x14,%esp
  801b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b72:	e8 1f f8 ff ff       	call   801396 <fd2num>
  801b77:	89 c3                	mov    %eax,%ebx
  801b79:	83 c4 10             	add    $0x10,%esp
}
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b81:	5b                   	pop    %ebx
  801b82:	5e                   	pop    %esi
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    
		fd_close(fd, 0);
  801b85:	83 ec 08             	sub    $0x8,%esp
  801b88:	6a 00                	push   $0x0
  801b8a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8d:	e8 26 f9 ff ff       	call   8014b8 <fd_close>
		return r;
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	eb e5                	jmp    801b7c <open+0x9a>
		return -E_BAD_PATH;
  801b97:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b9c:	eb de                	jmp    801b7c <open+0x9a>

00801b9e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	b8 08 00 00 00       	mov    $0x8,%eax
  801bae:	e8 75 fd ff ff       	call   801928 <fsipc>
}
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bbb:	89 d0                	mov    %edx,%eax
  801bbd:	c1 e8 16             	shr    $0x16,%eax
  801bc0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801bcc:	f6 c1 01             	test   $0x1,%cl
  801bcf:	74 1d                	je     801bee <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801bd1:	c1 ea 0c             	shr    $0xc,%edx
  801bd4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bdb:	f6 c2 01             	test   $0x1,%dl
  801bde:	74 0e                	je     801bee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801be0:	c1 ea 0c             	shr    $0xc,%edx
  801be3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bea:	ef 
  801beb:	0f b7 c0             	movzwl %ax,%eax
}
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bf8:	83 ec 0c             	sub    $0xc,%esp
  801bfb:	ff 75 08             	pushl  0x8(%ebp)
  801bfe:	e8 a3 f7 ff ff       	call   8013a6 <fd2data>
  801c03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c05:	83 c4 08             	add    $0x8,%esp
  801c08:	68 cc 29 80 00       	push   $0x8029cc
  801c0d:	53                   	push   %ebx
  801c0e:	e8 37 ed ff ff       	call   80094a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c13:	8b 46 04             	mov    0x4(%esi),%eax
  801c16:	2b 06                	sub    (%esi),%eax
  801c18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c25:	00 00 00 
	stat->st_dev = &devpipe;
  801c28:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c2f:	30 80 00 
	return 0;
}
  801c32:	b8 00 00 00 00       	mov    $0x0,%eax
  801c37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c48:	53                   	push   %ebx
  801c49:	6a 00                	push   $0x0
  801c4b:	e8 78 f1 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c50:	89 1c 24             	mov    %ebx,(%esp)
  801c53:	e8 4e f7 ff ff       	call   8013a6 <fd2data>
  801c58:	83 c4 08             	add    $0x8,%esp
  801c5b:	50                   	push   %eax
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 65 f1 ff ff       	call   800dc8 <sys_page_unmap>
}
  801c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <_pipeisclosed>:
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	57                   	push   %edi
  801c6c:	56                   	push   %esi
  801c6d:	53                   	push   %ebx
  801c6e:	83 ec 1c             	sub    $0x1c,%esp
  801c71:	89 c7                	mov    %eax,%edi
  801c73:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c75:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	57                   	push   %edi
  801c81:	e8 2f ff ff ff       	call   801bb5 <pageref>
  801c86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c89:	89 34 24             	mov    %esi,(%esp)
  801c8c:	e8 24 ff ff ff       	call   801bb5 <pageref>
		nn = thisenv->env_runs;
  801c91:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c97:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	39 cb                	cmp    %ecx,%ebx
  801c9f:	74 1b                	je     801cbc <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ca1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ca4:	75 cf                	jne    801c75 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ca6:	8b 42 58             	mov    0x58(%edx),%eax
  801ca9:	6a 01                	push   $0x1
  801cab:	50                   	push   %eax
  801cac:	53                   	push   %ebx
  801cad:	68 d3 29 80 00       	push   $0x8029d3
  801cb2:	e8 74 e6 ff ff       	call   80032b <cprintf>
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	eb b9                	jmp    801c75 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cbf:	0f 94 c0             	sete   %al
  801cc2:	0f b6 c0             	movzbl %al,%eax
}
  801cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5e                   	pop    %esi
  801cca:	5f                   	pop    %edi
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <devpipe_write>:
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	57                   	push   %edi
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	83 ec 28             	sub    $0x28,%esp
  801cd6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cd9:	56                   	push   %esi
  801cda:	e8 c7 f6 ff ff       	call   8013a6 <fd2data>
  801cdf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cec:	74 4f                	je     801d3d <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cee:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf1:	8b 0b                	mov    (%ebx),%ecx
  801cf3:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf6:	39 d0                	cmp    %edx,%eax
  801cf8:	72 14                	jb     801d0e <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801cfa:	89 da                	mov    %ebx,%edx
  801cfc:	89 f0                	mov    %esi,%eax
  801cfe:	e8 65 ff ff ff       	call   801c68 <_pipeisclosed>
  801d03:	85 c0                	test   %eax,%eax
  801d05:	75 3a                	jne    801d41 <devpipe_write+0x74>
			sys_yield();
  801d07:	e8 18 f0 ff ff       	call   800d24 <sys_yield>
  801d0c:	eb e0                	jmp    801cee <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d18:	89 c2                	mov    %eax,%edx
  801d1a:	c1 fa 1f             	sar    $0x1f,%edx
  801d1d:	89 d1                	mov    %edx,%ecx
  801d1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801d22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d25:	83 e2 1f             	and    $0x1f,%edx
  801d28:	29 ca                	sub    %ecx,%edx
  801d2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d32:	83 c0 01             	add    $0x1,%eax
  801d35:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d38:	83 c7 01             	add    $0x1,%edi
  801d3b:	eb ac                	jmp    801ce9 <devpipe_write+0x1c>
	return i;
  801d3d:	89 f8                	mov    %edi,%eax
  801d3f:	eb 05                	jmp    801d46 <devpipe_write+0x79>
				return 0;
  801d41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <devpipe_read>:
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 18             	sub    $0x18,%esp
  801d57:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d5a:	57                   	push   %edi
  801d5b:	e8 46 f6 ff ff       	call   8013a6 <fd2data>
  801d60:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	be 00 00 00 00       	mov    $0x0,%esi
  801d6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6d:	74 47                	je     801db6 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801d6f:	8b 03                	mov    (%ebx),%eax
  801d71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d74:	75 22                	jne    801d98 <devpipe_read+0x4a>
			if (i > 0)
  801d76:	85 f6                	test   %esi,%esi
  801d78:	75 14                	jne    801d8e <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801d7a:	89 da                	mov    %ebx,%edx
  801d7c:	89 f8                	mov    %edi,%eax
  801d7e:	e8 e5 fe ff ff       	call   801c68 <_pipeisclosed>
  801d83:	85 c0                	test   %eax,%eax
  801d85:	75 33                	jne    801dba <devpipe_read+0x6c>
			sys_yield();
  801d87:	e8 98 ef ff ff       	call   800d24 <sys_yield>
  801d8c:	eb e1                	jmp    801d6f <devpipe_read+0x21>
				return i;
  801d8e:	89 f0                	mov    %esi,%eax
}
  801d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d98:	99                   	cltd   
  801d99:	c1 ea 1b             	shr    $0x1b,%edx
  801d9c:	01 d0                	add    %edx,%eax
  801d9e:	83 e0 1f             	and    $0x1f,%eax
  801da1:	29 d0                	sub    %edx,%eax
  801da3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dab:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dae:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801db1:	83 c6 01             	add    $0x1,%esi
  801db4:	eb b4                	jmp    801d6a <devpipe_read+0x1c>
	return i;
  801db6:	89 f0                	mov    %esi,%eax
  801db8:	eb d6                	jmp    801d90 <devpipe_read+0x42>
				return 0;
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbf:	eb cf                	jmp    801d90 <devpipe_read+0x42>

00801dc1 <pipe>:
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcc:	50                   	push   %eax
  801dcd:	e8 eb f5 ff ff       	call   8013bd <fd_alloc>
  801dd2:	89 c3                	mov    %eax,%ebx
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 5b                	js     801e36 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	68 07 04 00 00       	push   $0x407
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	6a 00                	push   $0x0
  801de8:	e8 56 ef ff ff       	call   800d43 <sys_page_alloc>
  801ded:	89 c3                	mov    %eax,%ebx
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 40                	js     801e36 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801df6:	83 ec 0c             	sub    $0xc,%esp
  801df9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	e8 bb f5 ff ff       	call   8013bd <fd_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 1b                	js     801e26 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0b:	83 ec 04             	sub    $0x4,%esp
  801e0e:	68 07 04 00 00       	push   $0x407
  801e13:	ff 75 f0             	pushl  -0x10(%ebp)
  801e16:	6a 00                	push   $0x0
  801e18:	e8 26 ef ff ff       	call   800d43 <sys_page_alloc>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	85 c0                	test   %eax,%eax
  801e24:	79 19                	jns    801e3f <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801e26:	83 ec 08             	sub    $0x8,%esp
  801e29:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2c:	6a 00                	push   $0x0
  801e2e:	e8 95 ef ff ff       	call   800dc8 <sys_page_unmap>
  801e33:	83 c4 10             	add    $0x10,%esp
}
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5e                   	pop    %esi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    
	va = fd2data(fd0);
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	ff 75 f4             	pushl  -0xc(%ebp)
  801e45:	e8 5c f5 ff ff       	call   8013a6 <fd2data>
  801e4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4c:	83 c4 0c             	add    $0xc,%esp
  801e4f:	68 07 04 00 00       	push   $0x407
  801e54:	50                   	push   %eax
  801e55:	6a 00                	push   $0x0
  801e57:	e8 e7 ee ff ff       	call   800d43 <sys_page_alloc>
  801e5c:	89 c3                	mov    %eax,%ebx
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	0f 88 8c 00 00 00    	js     801ef5 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e69:	83 ec 0c             	sub    $0xc,%esp
  801e6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6f:	e8 32 f5 ff ff       	call   8013a6 <fd2data>
  801e74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e7b:	50                   	push   %eax
  801e7c:	6a 00                	push   $0x0
  801e7e:	56                   	push   %esi
  801e7f:	6a 00                	push   $0x0
  801e81:	e8 00 ef ff ff       	call   800d86 <sys_page_map>
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	83 c4 20             	add    $0x20,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 58                	js     801ee7 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ead:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eb2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801eb9:	83 ec 0c             	sub    $0xc,%esp
  801ebc:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebf:	e8 d2 f4 ff ff       	call   801396 <fd2num>
  801ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ec9:	83 c4 04             	add    $0x4,%esp
  801ecc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecf:	e8 c2 f4 ff ff       	call   801396 <fd2num>
  801ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eda:	83 c4 10             	add    $0x10,%esp
  801edd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ee2:	e9 4f ff ff ff       	jmp    801e36 <pipe+0x75>
	sys_page_unmap(0, va);
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	56                   	push   %esi
  801eeb:	6a 00                	push   $0x0
  801eed:	e8 d6 ee ff ff       	call   800dc8 <sys_page_unmap>
  801ef2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ef5:	83 ec 08             	sub    $0x8,%esp
  801ef8:	ff 75 f0             	pushl  -0x10(%ebp)
  801efb:	6a 00                	push   $0x0
  801efd:	e8 c6 ee ff ff       	call   800dc8 <sys_page_unmap>
  801f02:	83 c4 10             	add    $0x10,%esp
  801f05:	e9 1c ff ff ff       	jmp    801e26 <pipe+0x65>

00801f0a <pipeisclosed>:
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	ff 75 08             	pushl  0x8(%ebp)
  801f17:	e8 f0 f4 ff ff       	call   80140c <fd_lookup>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 18                	js     801f3b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	ff 75 f4             	pushl  -0xc(%ebp)
  801f29:	e8 78 f4 ff ff       	call   8013a6 <fd2data>
	return _pipeisclosed(fd, p);
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f33:	e8 30 fd ff ff       	call   801c68 <_pipeisclosed>
  801f38:	83 c4 10             	add    $0x10,%esp
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f40:	b8 00 00 00 00       	mov    $0x0,%eax
  801f45:	5d                   	pop    %ebp
  801f46:	c3                   	ret    

00801f47 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f4d:	68 eb 29 80 00       	push   $0x8029eb
  801f52:	ff 75 0c             	pushl  0xc(%ebp)
  801f55:	e8 f0 e9 ff ff       	call   80094a <strcpy>
	return 0;
}
  801f5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <devcons_write>:
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	57                   	push   %edi
  801f65:	56                   	push   %esi
  801f66:	53                   	push   %ebx
  801f67:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f6d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f72:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f78:	eb 2f                	jmp    801fa9 <devcons_write+0x48>
		m = n - tot;
  801f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f7d:	29 f3                	sub    %esi,%ebx
  801f7f:	83 fb 7f             	cmp    $0x7f,%ebx
  801f82:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f87:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f8a:	83 ec 04             	sub    $0x4,%esp
  801f8d:	53                   	push   %ebx
  801f8e:	89 f0                	mov    %esi,%eax
  801f90:	03 45 0c             	add    0xc(%ebp),%eax
  801f93:	50                   	push   %eax
  801f94:	57                   	push   %edi
  801f95:	e8 3e eb ff ff       	call   800ad8 <memmove>
		sys_cputs(buf, m);
  801f9a:	83 c4 08             	add    $0x8,%esp
  801f9d:	53                   	push   %ebx
  801f9e:	57                   	push   %edi
  801f9f:	e8 e3 ec ff ff       	call   800c87 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fa4:	01 de                	add    %ebx,%esi
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fac:	72 cc                	jb     801f7a <devcons_write+0x19>
}
  801fae:	89 f0                	mov    %esi,%eax
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <devcons_read>:
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 08             	sub    $0x8,%esp
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fc3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fc7:	75 07                	jne    801fd0 <devcons_read+0x18>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    
		sys_yield();
  801fcb:	e8 54 ed ff ff       	call   800d24 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fd0:	e8 d0 ec ff ff       	call   800ca5 <sys_cgetc>
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	74 f2                	je     801fcb <devcons_read+0x13>
	if (c < 0)
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 ec                	js     801fc9 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801fdd:	83 f8 04             	cmp    $0x4,%eax
  801fe0:	74 0c                	je     801fee <devcons_read+0x36>
	*(char*)vbuf = c;
  801fe2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe5:	88 02                	mov    %al,(%edx)
	return 1;
  801fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fec:	eb db                	jmp    801fc9 <devcons_read+0x11>
		return 0;
  801fee:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff3:	eb d4                	jmp    801fc9 <devcons_read+0x11>

00801ff5 <cputchar>:
{
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802001:	6a 01                	push   $0x1
  802003:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802006:	50                   	push   %eax
  802007:	e8 7b ec ff ff       	call   800c87 <sys_cputs>
}
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	c9                   	leave  
  802010:	c3                   	ret    

00802011 <getchar>:
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802017:	6a 01                	push   $0x1
  802019:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201c:	50                   	push   %eax
  80201d:	6a 00                	push   $0x0
  80201f:	e8 59 f6 ff ff       	call   80167d <read>
	if (r < 0)
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	78 08                	js     802033 <getchar+0x22>
	if (r < 1)
  80202b:	85 c0                	test   %eax,%eax
  80202d:	7e 06                	jle    802035 <getchar+0x24>
	return c;
  80202f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802033:	c9                   	leave  
  802034:	c3                   	ret    
		return -E_EOF;
  802035:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80203a:	eb f7                	jmp    802033 <getchar+0x22>

0080203c <iscons>:
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802042:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802045:	50                   	push   %eax
  802046:	ff 75 08             	pushl  0x8(%ebp)
  802049:	e8 be f3 ff ff       	call   80140c <fd_lookup>
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	78 11                	js     802066 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802058:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80205e:	39 10                	cmp    %edx,(%eax)
  802060:	0f 94 c0             	sete   %al
  802063:	0f b6 c0             	movzbl %al,%eax
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <opencons>:
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80206e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802071:	50                   	push   %eax
  802072:	e8 46 f3 ff ff       	call   8013bd <fd_alloc>
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	85 c0                	test   %eax,%eax
  80207c:	78 3a                	js     8020b8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80207e:	83 ec 04             	sub    $0x4,%esp
  802081:	68 07 04 00 00       	push   $0x407
  802086:	ff 75 f4             	pushl  -0xc(%ebp)
  802089:	6a 00                	push   $0x0
  80208b:	e8 b3 ec ff ff       	call   800d43 <sys_page_alloc>
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	78 21                	js     8020b8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802097:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020ac:	83 ec 0c             	sub    $0xc,%esp
  8020af:	50                   	push   %eax
  8020b0:	e8 e1 f2 ff ff       	call   801396 <fd2num>
  8020b5:	83 c4 10             	add    $0x10,%esp
}
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020bb:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8020c0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020c2:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  8020c5:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  8020c8:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  8020cc:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  8020d0:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  8020d3:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  8020d7:	89 18                	mov    %ebx,(%eax)

    popal
  8020d9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  8020da:	83 c4 04             	add    $0x4,%esp
    popfl
  8020dd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  8020de:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8020df:	c3                   	ret    

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	75 35                	jne    802130 <__udivdi3+0x50>
  8020fb:	39 f3                	cmp    %esi,%ebx
  8020fd:	0f 87 bd 00 00 00    	ja     8021c0 <__udivdi3+0xe0>
  802103:	85 db                	test   %ebx,%ebx
  802105:	89 d9                	mov    %ebx,%ecx
  802107:	75 0b                	jne    802114 <__udivdi3+0x34>
  802109:	b8 01 00 00 00       	mov    $0x1,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f3                	div    %ebx
  802112:	89 c1                	mov    %eax,%ecx
  802114:	31 d2                	xor    %edx,%edx
  802116:	89 f0                	mov    %esi,%eax
  802118:	f7 f1                	div    %ecx
  80211a:	89 c6                	mov    %eax,%esi
  80211c:	89 e8                	mov    %ebp,%eax
  80211e:	89 f7                	mov    %esi,%edi
  802120:	f7 f1                	div    %ecx
  802122:	89 fa                	mov    %edi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 f2                	cmp    %esi,%edx
  802132:	77 7c                	ja     8021b0 <__udivdi3+0xd0>
  802134:	0f bd fa             	bsr    %edx,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0xf8>
  802140:	89 f9                	mov    %edi,%ecx
  802142:	b8 20 00 00 00       	mov    $0x20,%eax
  802147:	29 f8                	sub    %edi,%eax
  802149:	d3 e2                	shl    %cl,%edx
  80214b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80214f:	89 c1                	mov    %eax,%ecx
  802151:	89 da                	mov    %ebx,%edx
  802153:	d3 ea                	shr    %cl,%edx
  802155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802159:	09 d1                	or     %edx,%ecx
  80215b:	89 f2                	mov    %esi,%edx
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e3                	shl    %cl,%ebx
  802165:	89 c1                	mov    %eax,%ecx
  802167:	d3 ea                	shr    %cl,%edx
  802169:	89 f9                	mov    %edi,%ecx
  80216b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216f:	d3 e6                	shl    %cl,%esi
  802171:	89 eb                	mov    %ebp,%ebx
  802173:	89 c1                	mov    %eax,%ecx
  802175:	d3 eb                	shr    %cl,%ebx
  802177:	09 de                	or     %ebx,%esi
  802179:	89 f0                	mov    %esi,%eax
  80217b:	f7 74 24 08          	divl   0x8(%esp)
  80217f:	89 d6                	mov    %edx,%esi
  802181:	89 c3                	mov    %eax,%ebx
  802183:	f7 64 24 0c          	mull   0xc(%esp)
  802187:	39 d6                	cmp    %edx,%esi
  802189:	72 0c                	jb     802197 <__udivdi3+0xb7>
  80218b:	89 f9                	mov    %edi,%ecx
  80218d:	d3 e5                	shl    %cl,%ebp
  80218f:	39 c5                	cmp    %eax,%ebp
  802191:	73 5d                	jae    8021f0 <__udivdi3+0x110>
  802193:	39 d6                	cmp    %edx,%esi
  802195:	75 59                	jne    8021f0 <__udivdi3+0x110>
  802197:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80219a:	31 ff                	xor    %edi,%edi
  80219c:	89 fa                	mov    %edi,%edx
  80219e:	83 c4 1c             	add    $0x1c,%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5f                   	pop    %edi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    
  8021a6:	8d 76 00             	lea    0x0(%esi),%esi
  8021a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021b0:	31 ff                	xor    %edi,%edi
  8021b2:	31 c0                	xor    %eax,%eax
  8021b4:	89 fa                	mov    %edi,%edx
  8021b6:	83 c4 1c             	add    $0x1c,%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    
  8021be:	66 90                	xchg   %ax,%ax
  8021c0:	31 ff                	xor    %edi,%edi
  8021c2:	89 e8                	mov    %ebp,%eax
  8021c4:	89 f2                	mov    %esi,%edx
  8021c6:	f7 f3                	div    %ebx
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	72 06                	jb     8021e2 <__udivdi3+0x102>
  8021dc:	31 c0                	xor    %eax,%eax
  8021de:	39 eb                	cmp    %ebp,%ebx
  8021e0:	77 d2                	ja     8021b4 <__udivdi3+0xd4>
  8021e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e7:	eb cb                	jmp    8021b4 <__udivdi3+0xd4>
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	31 ff                	xor    %edi,%edi
  8021f4:	eb be                	jmp    8021b4 <__udivdi3+0xd4>
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80220b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80220f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 ed                	test   %ebp,%ebp
  802219:	89 f0                	mov    %esi,%eax
  80221b:	89 da                	mov    %ebx,%edx
  80221d:	75 19                	jne    802238 <__umoddi3+0x38>
  80221f:	39 df                	cmp    %ebx,%edi
  802221:	0f 86 b1 00 00 00    	jbe    8022d8 <__umoddi3+0xd8>
  802227:	f7 f7                	div    %edi
  802229:	89 d0                	mov    %edx,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	39 dd                	cmp    %ebx,%ebp
  80223a:	77 f1                	ja     80222d <__umoddi3+0x2d>
  80223c:	0f bd cd             	bsr    %ebp,%ecx
  80223f:	83 f1 1f             	xor    $0x1f,%ecx
  802242:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802246:	0f 84 b4 00 00 00    	je     802300 <__umoddi3+0x100>
  80224c:	b8 20 00 00 00       	mov    $0x20,%eax
  802251:	89 c2                	mov    %eax,%edx
  802253:	8b 44 24 04          	mov    0x4(%esp),%eax
  802257:	29 c2                	sub    %eax,%edx
  802259:	89 c1                	mov    %eax,%ecx
  80225b:	89 f8                	mov    %edi,%eax
  80225d:	d3 e5                	shl    %cl,%ebp
  80225f:	89 d1                	mov    %edx,%ecx
  802261:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802265:	d3 e8                	shr    %cl,%eax
  802267:	09 c5                	or     %eax,%ebp
  802269:	8b 44 24 04          	mov    0x4(%esp),%eax
  80226d:	89 c1                	mov    %eax,%ecx
  80226f:	d3 e7                	shl    %cl,%edi
  802271:	89 d1                	mov    %edx,%ecx
  802273:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802277:	89 df                	mov    %ebx,%edi
  802279:	d3 ef                	shr    %cl,%edi
  80227b:	89 c1                	mov    %eax,%ecx
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	d3 e3                	shl    %cl,%ebx
  802281:	89 d1                	mov    %edx,%ecx
  802283:	89 fa                	mov    %edi,%edx
  802285:	d3 e8                	shr    %cl,%eax
  802287:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228c:	09 d8                	or     %ebx,%eax
  80228e:	f7 f5                	div    %ebp
  802290:	d3 e6                	shl    %cl,%esi
  802292:	89 d1                	mov    %edx,%ecx
  802294:	f7 64 24 08          	mull   0x8(%esp)
  802298:	39 d1                	cmp    %edx,%ecx
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d7                	mov    %edx,%edi
  80229e:	72 06                	jb     8022a6 <__umoddi3+0xa6>
  8022a0:	75 0e                	jne    8022b0 <__umoddi3+0xb0>
  8022a2:	39 c6                	cmp    %eax,%esi
  8022a4:	73 0a                	jae    8022b0 <__umoddi3+0xb0>
  8022a6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022aa:	19 ea                	sbb    %ebp,%edx
  8022ac:	89 d7                	mov    %edx,%edi
  8022ae:	89 c3                	mov    %eax,%ebx
  8022b0:	89 ca                	mov    %ecx,%edx
  8022b2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022b7:	29 de                	sub    %ebx,%esi
  8022b9:	19 fa                	sbb    %edi,%edx
  8022bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	d3 e0                	shl    %cl,%eax
  8022c3:	89 d9                	mov    %ebx,%ecx
  8022c5:	d3 ee                	shr    %cl,%esi
  8022c7:	d3 ea                	shr    %cl,%edx
  8022c9:	09 f0                	or     %esi,%eax
  8022cb:	83 c4 1c             	add    $0x1c,%esp
  8022ce:	5b                   	pop    %ebx
  8022cf:	5e                   	pop    %esi
  8022d0:	5f                   	pop    %edi
  8022d1:	5d                   	pop    %ebp
  8022d2:	c3                   	ret    
  8022d3:	90                   	nop
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	85 ff                	test   %edi,%edi
  8022da:	89 f9                	mov    %edi,%ecx
  8022dc:	75 0b                	jne    8022e9 <__umoddi3+0xe9>
  8022de:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f7                	div    %edi
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 d8                	mov    %ebx,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f1                	div    %ecx
  8022ef:	89 f0                	mov    %esi,%eax
  8022f1:	f7 f1                	div    %ecx
  8022f3:	e9 31 ff ff ff       	jmp    802229 <__umoddi3+0x29>
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	39 dd                	cmp    %ebx,%ebp
  802302:	72 08                	jb     80230c <__umoddi3+0x10c>
  802304:	39 f7                	cmp    %esi,%edi
  802306:	0f 87 21 ff ff ff    	ja     80222d <__umoddi3+0x2d>
  80230c:	89 da                	mov    %ebx,%edx
  80230e:	89 f0                	mov    %esi,%eax
  802310:	29 f8                	sub    %edi,%eax
  802312:	19 ea                	sbb    %ebp,%edx
  802314:	e9 14 ff ff ff       	jmp    80222d <__umoddi3+0x2d>
