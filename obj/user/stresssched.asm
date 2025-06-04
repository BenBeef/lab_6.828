
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 c0 0b 00 00       	call   800bfd <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 e9 0f 00 00       	call   801032 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 c2 0b 00 00       	call   800c1c <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 97 0b 00 00       	call   800c1c <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 40 80 00       	mov    0x804004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 5b 22 80 00       	push   $0x80225b
  8000c2:	e8 5c 01 00 00       	call   800223 <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 20 22 80 00       	push   $0x802220
  8000dc:	6a 21                	push   $0x21
  8000de:	68 48 22 80 00       	push   $0x802248
  8000e3:	e8 60 00 00 00       	call   800148 <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000f3:	e8 05 0b 00 00       	call   800bfd <sys_getenvid>
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800105:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 db                	test   %ebx,%ebx
  80010c:	7e 07                	jle    800115 <libmain+0x2d>
		binaryname = argv[0];
  80010e:	8b 06                	mov    (%esi),%eax
  800110:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0a 00 00 00       	call   80012e <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800134:	e8 44 12 00 00       	call   80137d <close_all>
	sys_env_destroy(0);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	6a 00                	push   $0x0
  80013e:	e8 79 0a 00 00       	call   800bbc <sys_env_destroy>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800150:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800156:	e8 a2 0a 00 00       	call   800bfd <sys_getenvid>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	ff 75 0c             	pushl  0xc(%ebp)
  800161:	ff 75 08             	pushl  0x8(%ebp)
  800164:	56                   	push   %esi
  800165:	50                   	push   %eax
  800166:	68 84 22 80 00       	push   $0x802284
  80016b:	e8 b3 00 00 00       	call   800223 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	83 c4 18             	add    $0x18,%esp
  800173:	53                   	push   %ebx
  800174:	ff 75 10             	pushl  0x10(%ebp)
  800177:	e8 56 00 00 00       	call   8001d2 <vcprintf>
	cprintf("\n");
  80017c:	c7 04 24 77 22 80 00 	movl   $0x802277,(%esp)
  800183:	e8 9b 00 00 00       	call   800223 <cprintf>
  800188:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x43>

0080018e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800198:	8b 13                	mov    (%ebx),%edx
  80019a:	8d 42 01             	lea    0x1(%edx),%eax
  80019d:	89 03                	mov    %eax,(%ebx)
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	74 09                	je     8001b6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	68 ff 00 00 00       	push   $0xff
  8001be:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c1:	50                   	push   %eax
  8001c2:	e8 b8 09 00 00       	call   800b7f <sys_cputs>
		b->idx = 0;
  8001c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb db                	jmp    8001ad <putch+0x1f>

008001d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e2:	00 00 00 
	b.cnt = 0;
  8001e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	68 8e 01 80 00       	push   $0x80018e
  800201:	e8 1a 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	83 c4 08             	add    $0x8,%esp
  800209:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800215:	50                   	push   %eax
  800216:	e8 64 09 00 00       	call   800b7f <sys_cputs>

	return b.cnt;
}
  80021b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800229:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022c:	50                   	push   %eax
  80022d:	ff 75 08             	pushl  0x8(%ebp)
  800230:	e8 9d ff ff ff       	call   8001d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 1c             	sub    $0x1c,%esp
  800240:	89 c7                	mov    %eax,%edi
  800242:	89 d6                	mov    %edx,%esi
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800250:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025e:	39 d3                	cmp    %edx,%ebx
  800260:	72 05                	jb     800267 <printnum+0x30>
  800262:	39 45 10             	cmp    %eax,0x10(%ebp)
  800265:	77 7a                	ja     8002e1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	ff 75 18             	pushl  0x18(%ebp)
  80026d:	8b 45 14             	mov    0x14(%ebp),%eax
  800270:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800273:	53                   	push   %ebx
  800274:	ff 75 10             	pushl  0x10(%ebp)
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027d:	ff 75 e0             	pushl  -0x20(%ebp)
  800280:	ff 75 dc             	pushl  -0x24(%ebp)
  800283:	ff 75 d8             	pushl  -0x28(%ebp)
  800286:	e8 55 1d 00 00       	call   801fe0 <__udivdi3>
  80028b:	83 c4 18             	add    $0x18,%esp
  80028e:	52                   	push   %edx
  80028f:	50                   	push   %eax
  800290:	89 f2                	mov    %esi,%edx
  800292:	89 f8                	mov    %edi,%eax
  800294:	e8 9e ff ff ff       	call   800237 <printnum>
  800299:	83 c4 20             	add    $0x20,%esp
  80029c:	eb 13                	jmp    8002b1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	56                   	push   %esi
  8002a2:	ff 75 18             	pushl  0x18(%ebp)
  8002a5:	ff d7                	call   *%edi
  8002a7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f ed                	jg     80029e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 37 1e 00 00       	call   802100 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 a7 22 80 00 	movsbl 0x8022a7(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
  8002e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e4:	eb c4                	jmp    8002aa <printnum+0x73>

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	e9 c1 03 00 00       	jmp    8006f8 <vprintfmt+0x3d8>
		padc = ' ';
  800337:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80033b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800342:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800349:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800350:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8d 47 01             	lea    0x1(%edi),%eax
  800358:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035b:	0f b6 17             	movzbl (%edi),%edx
  80035e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800361:	3c 55                	cmp    $0x55,%al
  800363:	0f 87 12 04 00 00    	ja     80077b <vprintfmt+0x45b>
  800369:	0f b6 c0             	movzbl %al,%eax
  80036c:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800376:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80037a:	eb d9                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80037f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800383:	eb d0                	jmp    800355 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038b:	b8 00 00 00 00       	mov    $0x0,%eax
  800390:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800393:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800396:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a0:	83 f9 09             	cmp    $0x9,%ecx
  8003a3:	77 55                	ja     8003fa <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003a5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a8:	eb e9                	jmp    800393 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 40 04             	lea    0x4(%eax),%eax
  8003b8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	79 91                	jns    800355 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d1:	eb 82                	jmp    800355 <vprintfmt+0x35>
  8003d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dd:	0f 49 d0             	cmovns %eax,%edx
  8003e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 6a ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f5:	e9 5b ff ff ff       	jmp    800355 <vprintfmt+0x35>
  8003fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800400:	eb bc                	jmp    8003be <vprintfmt+0x9e>
			lflag++;
  800402:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800408:	e9 48 ff ff ff       	jmp    800355 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 78 04             	lea    0x4(%eax),%edi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	53                   	push   %ebx
  800417:	ff 30                	pushl  (%eax)
  800419:	ff d6                	call   *%esi
			break;
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800421:	e9 cf 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	99                   	cltd   
  80042f:	31 d0                	xor    %edx,%eax
  800431:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 23                	jg     80045b <vprintfmt+0x13b>
  800438:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 b5 27 80 00       	push   $0x8027b5
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 b3 fe ff ff       	call   800303 <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
  800456:	e9 9a 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 bf 22 80 00       	push   $0x8022bf
  800461:	53                   	push   %ebx
  800462:	56                   	push   %esi
  800463:	e8 9b fe ff ff       	call   800303 <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046e:	e9 82 02 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	83 c0 04             	add    $0x4,%eax
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800481:	85 ff                	test   %edi,%edi
  800483:	b8 b8 22 80 00       	mov    $0x8022b8,%eax
  800488:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	0f 8e bd 00 00 00    	jle    800552 <vprintfmt+0x232>
  800495:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800499:	75 0e                	jne    8004a9 <vprintfmt+0x189>
  80049b:	89 75 08             	mov    %esi,0x8(%ebp)
  80049e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a7:	eb 6d                	jmp    800516 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 6e 03 00 00       	call   800823 <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1ae>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 16                	jmp    800516 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	75 31                	jne    800537 <vprintfmt+0x217>
					putch(ch, putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 0c             	pushl  0xc(%ebp)
  80050c:	50                   	push   %eax
  80050d:	ff 55 08             	call   *0x8(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800513:	83 eb 01             	sub    $0x1,%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80051d:	0f be c2             	movsbl %dl,%eax
  800520:	85 c0                	test   %eax,%eax
  800522:	74 59                	je     80057d <vprintfmt+0x25d>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 d8                	js     800500 <vprintfmt+0x1e0>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 d3                	jns    800500 <vprintfmt+0x1e0>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 37                	jmp    80056e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	0f be d2             	movsbl %dl,%edx
  80053a:	83 ea 20             	sub    $0x20,%edx
  80053d:	83 fa 5e             	cmp    $0x5e,%edx
  800540:	76 c4                	jbe    800506 <vprintfmt+0x1e6>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 3f                	push   $0x3f
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb c1                	jmp    800513 <vprintfmt+0x1f3>
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	eb b6                	jmp    800516 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 20                	push   $0x20
  800566:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ee                	jg     800560 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	e9 78 01 00 00       	jmp    8006f5 <vprintfmt+0x3d5>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb e7                	jmp    80056e <vprintfmt+0x24e>
	if (lflag >= 2)
  800587:	83 f9 01             	cmp    $0x1,%ecx
  80058a:	7e 3f                	jle    8005cb <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 50 04             	mov    0x4(%eax),%edx
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 08             	lea    0x8(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a7:	79 5c                	jns    800605 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b7:	f7 da                	neg    %edx
  8005b9:	83 d1 00             	adc    $0x0,%ecx
  8005bc:	f7 d9                	neg    %ecx
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	e9 10 01 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	75 1b                	jne    8005ea <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e8:	eb b9                	jmp    8005a3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 c1                	mov    %eax,%ecx
  8005f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	eb 9e                	jmp    8005a3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800605:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800608:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 c6 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 18                	jle    800632 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 a9 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800632:	85 c9                	test   %ecx,%ecx
  800634:	75 1a                	jne    800650 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8b 00 00 00       	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
  800665:	eb 74                	jmp    8006db <vprintfmt+0x3bb>
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 15                	jle    800681 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	8b 48 04             	mov    0x4(%eax),%ecx
  800674:	8d 40 08             	lea    0x8(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
  80067f:	eb 5a                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800681:	85 c9                	test   %ecx,%ecx
  800683:	75 17                	jne    80069c <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	eb 3f                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 28                	jmp    8006db <vprintfmt+0x3bb>
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 10                	mov    (%eax),%edx
  8006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006cd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e2:	57                   	push   %edi
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	50                   	push   %eax
  8006e7:	51                   	push   %ecx
  8006e8:	52                   	push   %edx
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 45 fb ff ff       	call   800237 <printnum>
			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f8:	83 c7 01             	add    $0x1,%edi
  8006fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ff:	83 f8 25             	cmp    $0x25,%eax
  800702:	0f 84 2f fc ff ff    	je     800337 <vprintfmt+0x17>
			if (ch == '\0')
  800708:	85 c0                	test   %eax,%eax
  80070a:	0f 84 8b 00 00 00    	je     80079b <vprintfmt+0x47b>
			putch(ch, putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	53                   	push   %ebx
  800714:	50                   	push   %eax
  800715:	ff d6                	call   *%esi
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb dc                	jmp    8006f8 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80071c:	83 f9 01             	cmp    $0x1,%ecx
  80071f:	7e 15                	jle    800736 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	8b 48 04             	mov    0x4(%eax),%ecx
  800729:	8d 40 08             	lea    0x8(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
  800734:	eb a5                	jmp    8006db <vprintfmt+0x3bb>
	else if (lflag)
  800736:	85 c9                	test   %ecx,%ecx
  800738:	75 17                	jne    800751 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
  80074f:	eb 8a                	jmp    8006db <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	e9 70 ff ff ff       	jmp    8006db <vprintfmt+0x3bb>
			putch(ch, putdat);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	53                   	push   %ebx
  80076f:	6a 25                	push   $0x25
  800771:	ff d6                	call   *%esi
			break;
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	e9 7a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
			putch('%', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	89 f8                	mov    %edi,%eax
  800788:	eb 03                	jmp    80078d <vprintfmt+0x46d>
  80078a:	83 e8 01             	sub    $0x1,%eax
  80078d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800791:	75 f7                	jne    80078a <vprintfmt+0x46a>
  800793:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800796:	e9 5a ff ff ff       	jmp    8006f5 <vprintfmt+0x3d5>
}
  80079b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 18             	sub    $0x18,%esp
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	74 26                	je     8007ea <vsnprintf+0x47>
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	7e 22                	jle    8007ea <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c8:	ff 75 14             	pushl  0x14(%ebp)
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	68 e6 02 80 00       	push   $0x8002e6
  8007d7:	e8 44 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	83 c4 10             	add    $0x10,%esp
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb f7                	jmp    8007e8 <vsnprintf+0x45>

008007f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fa:	50                   	push   %eax
  8007fb:	ff 75 10             	pushl  0x10(%ebp)
  8007fe:	ff 75 0c             	pushl  0xc(%ebp)
  800801:	ff 75 08             	pushl  0x8(%ebp)
  800804:	e8 9a ff ff ff       	call   8007a3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
  800816:	eb 03                	jmp    80081b <strlen+0x10>
		n++;
  800818:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80081b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80081f:	75 f7                	jne    800818 <strlen+0xd>
	return n;
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
  800831:	eb 03                	jmp    800836 <strnlen+0x13>
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 d0                	cmp    %edx,%eax
  800838:	74 06                	je     800840 <strnlen+0x1d>
  80083a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x10>
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800858:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ef                	jne    80084e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800869:	53                   	push   %ebx
  80086a:	e8 9c ff ff ff       	call   80080b <strlen>
  80086f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800872:	ff 75 0c             	pushl  0xc(%ebp)
  800875:	01 d8                	add    %ebx,%eax
  800877:	50                   	push   %eax
  800878:	e8 c5 ff ff ff       	call   800842 <strcpy>
	return dst;
}
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088f:	89 f3                	mov    %esi,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800894:	89 f2                	mov    %esi,%edx
  800896:	eb 0f                	jmp    8008a7 <strncpy+0x23>
		*dst++ = *src;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008a7:	39 da                	cmp    %ebx,%edx
  8008a9:	75 ed                	jne    800898 <strncpy+0x14>
	}
	return ret;
}
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	75 0b                	jne    8008d4 <strlcpy+0x23>
  8008c9:	eb 17                	jmp    8008e2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008cb:	83 c2 01             	add    $0x1,%edx
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008d4:	39 d8                	cmp    %ebx,%eax
  8008d6:	74 07                	je     8008df <strlcpy+0x2e>
  8008d8:	0f b6 0a             	movzbl (%edx),%ecx
  8008db:	84 c9                	test   %cl,%cl
  8008dd:	75 ec                	jne    8008cb <strlcpy+0x1a>
		*dst = '\0';
  8008df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e2:	29 f0                	sub    %esi,%eax
}
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strcmp+0x11>
		p++, q++;
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008f9:	0f b6 01             	movzbl (%ecx),%eax
  8008fc:	84 c0                	test   %al,%al
  8008fe:	74 04                	je     800904 <strcmp+0x1c>
  800900:	3a 02                	cmp    (%edx),%al
  800902:	74 ef                	je     8008f3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800904:	0f b6 c0             	movzbl %al,%eax
  800907:	0f b6 12             	movzbl (%edx),%edx
  80090a:	29 d0                	sub    %edx,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	89 c3                	mov    %eax,%ebx
  80091a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80091d:	eb 06                	jmp    800925 <strncmp+0x17>
		n--, p++, q++;
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800925:	39 d8                	cmp    %ebx,%eax
  800927:	74 16                	je     80093f <strncmp+0x31>
  800929:	0f b6 08             	movzbl (%eax),%ecx
  80092c:	84 c9                	test   %cl,%cl
  80092e:	74 04                	je     800934 <strncmp+0x26>
  800930:	3a 0a                	cmp    (%edx),%cl
  800932:	74 eb                	je     80091f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800934:	0f b6 00             	movzbl (%eax),%eax
  800937:	0f b6 12             	movzbl (%edx),%edx
  80093a:	29 d0                	sub    %edx,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
  800944:	eb f6                	jmp    80093c <strncmp+0x2e>

00800946 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	74 09                	je     800960 <strchr+0x1a>
		if (*s == c)
  800957:	38 ca                	cmp    %cl,%dl
  800959:	74 0a                	je     800965 <strchr+0x1f>
	for (; *s; s++)
  80095b:	83 c0 01             	add    $0x1,%eax
  80095e:	eb f0                	jmp    800950 <strchr+0xa>
			return (char *) s;
	return 0;
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800971:	eb 03                	jmp    800976 <strfind+0xf>
  800973:	83 c0 01             	add    $0x1,%eax
  800976:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800979:	38 ca                	cmp    %cl,%dl
  80097b:	74 04                	je     800981 <strfind+0x1a>
  80097d:	84 d2                	test   %dl,%dl
  80097f:	75 f2                	jne    800973 <strfind+0xc>
			break;
	return (char *) s;
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098f:	85 c9                	test   %ecx,%ecx
  800991:	74 13                	je     8009a6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800993:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800999:	75 05                	jne    8009a0 <memset+0x1d>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	74 0d                	je     8009ad <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 f8                	mov    %edi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		c &= 0xFF;
  8009ad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d3                	mov    %edx,%ebx
  8009b3:	c1 e3 08             	shl    $0x8,%ebx
  8009b6:	89 d0                	mov    %edx,%eax
  8009b8:	c1 e0 18             	shl    $0x18,%eax
  8009bb:	89 d6                	mov    %edx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f0                	or     %esi,%eax
  8009c2:	09 c2                	or     %eax,%edx
  8009c4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	fc                   	cld    
  8009cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ce:	eb d6                	jmp    8009a6 <memset+0x23>

008009d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009de:	39 c6                	cmp    %eax,%esi
  8009e0:	73 35                	jae    800a17 <memmove+0x47>
  8009e2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e5:	39 c2                	cmp    %eax,%edx
  8009e7:	76 2e                	jbe    800a17 <memmove+0x47>
		s += n;
		d += n;
  8009e9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 d6                	mov    %edx,%esi
  8009ee:	09 fe                	or     %edi,%esi
  8009f0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f6:	74 0c                	je     800a04 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f8:	83 ef 01             	sub    $0x1,%edi
  8009fb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009fe:	fd                   	std    
  8009ff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a01:	fc                   	cld    
  800a02:	eb 21                	jmp    800a25 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c1 03             	test   $0x3,%cl
  800a07:	75 ef                	jne    8009f8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a09:	83 ef 04             	sub    $0x4,%edi
  800a0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a12:	fd                   	std    
  800a13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a15:	eb ea                	jmp    800a01 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a17:	89 f2                	mov    %esi,%edx
  800a19:	09 c2                	or     %eax,%edx
  800a1b:	f6 c2 03             	test   $0x3,%dl
  800a1e:	74 09                	je     800a29 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	fc                   	cld    
  800a23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 f2                	jne    800a20 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a36:	eb ed                	jmp    800a25 <memmove+0x55>

00800a38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a3b:	ff 75 10             	pushl  0x10(%ebp)
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	ff 75 08             	pushl  0x8(%ebp)
  800a44:	e8 87 ff ff ff       	call   8009d0 <memmove>
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a56:	89 c6                	mov    %eax,%esi
  800a58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	74 1c                	je     800a7b <memcmp+0x30>
		if (*s1 != *s2)
  800a5f:	0f b6 08             	movzbl (%eax),%ecx
  800a62:	0f b6 1a             	movzbl (%edx),%ebx
  800a65:	38 d9                	cmp    %bl,%cl
  800a67:	75 08                	jne    800a71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	eb ea                	jmp    800a5b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a71:	0f b6 c1             	movzbl %cl,%eax
  800a74:	0f b6 db             	movzbl %bl,%ebx
  800a77:	29 d8                	sub    %ebx,%eax
  800a79:	eb 05                	jmp    800a80 <memcmp+0x35>
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a92:	39 d0                	cmp    %edx,%eax
  800a94:	73 09                	jae    800a9f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a96:	38 08                	cmp    %cl,(%eax)
  800a98:	74 05                	je     800a9f <memfind+0x1b>
	for (; s < ends; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	eb f3                	jmp    800a92 <memfind+0xe>
			break;
	return (void *) s;
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aad:	eb 03                	jmp    800ab2 <strtol+0x11>
		s++;
  800aaf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ab2:	0f b6 01             	movzbl (%ecx),%eax
  800ab5:	3c 20                	cmp    $0x20,%al
  800ab7:	74 f6                	je     800aaf <strtol+0xe>
  800ab9:	3c 09                	cmp    $0x9,%al
  800abb:	74 f2                	je     800aaf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800abd:	3c 2b                	cmp    $0x2b,%al
  800abf:	74 2e                	je     800aef <strtol+0x4e>
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac6:	3c 2d                	cmp    $0x2d,%al
  800ac8:	74 2f                	je     800af9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad0:	75 05                	jne    800ad7 <strtol+0x36>
  800ad2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad5:	74 2c                	je     800b03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad7:	85 db                	test   %ebx,%ebx
  800ad9:	75 0a                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 28                	je     800b0d <strtol+0x6c>
		base = 10;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aed:	eb 50                	jmp    800b3f <strtol+0x9e>
		s++;
  800aef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af2:	bf 00 00 00 00       	mov    $0x0,%edi
  800af7:	eb d1                	jmp    800aca <strtol+0x29>
		s++, neg = 1;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bf 01 00 00 00       	mov    $0x1,%edi
  800b01:	eb c7                	jmp    800aca <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b07:	74 0e                	je     800b17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	75 d8                	jne    800ae5 <strtol+0x44>
		s++, base = 8;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b15:	eb ce                	jmp    800ae5 <strtol+0x44>
		s += 2, base = 16;
  800b17:	83 c1 02             	add    $0x2,%ecx
  800b1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1f:	eb c4                	jmp    800ae5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 29                	ja     800b54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b34:	7d 30                	jge    800b66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b36:	83 c1 01             	add    $0x1,%ecx
  800b39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b3f:	0f b6 11             	movzbl (%ecx),%edx
  800b42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b45:	89 f3                	mov    %esi,%ebx
  800b47:	80 fb 09             	cmp    $0x9,%bl
  800b4a:	77 d5                	ja     800b21 <strtol+0x80>
			dig = *s - '0';
  800b4c:	0f be d2             	movsbl %dl,%edx
  800b4f:	83 ea 30             	sub    $0x30,%edx
  800b52:	eb dd                	jmp    800b31 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 19             	cmp    $0x19,%bl
  800b5c:	77 08                	ja     800b66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b5e:	0f be d2             	movsbl %dl,%edx
  800b61:	83 ea 37             	sub    $0x37,%edx
  800b64:	eb cb                	jmp    800b31 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xd0>
		*endptr = (char *) s;
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	f7 da                	neg    %edx
  800b75:	85 ff                	test   %edi,%edi
  800b77:	0f 45 c2             	cmovne %edx,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	89 c3                	mov    %eax,%ebx
  800b92:	89 c7                	mov    %eax,%edi
  800b94:	89 c6                	mov    %eax,%esi
  800b96:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	89 cb                	mov    %ecx,%ebx
  800bd4:	89 cf                	mov    %ecx,%edi
  800bd6:	89 ce                	mov    %ecx,%esi
  800bd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7f 08                	jg     800be6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 03                	push   $0x3
  800bec:	68 9f 25 80 00       	push   $0x80259f
  800bf1:	6a 23                	push   $0x23
  800bf3:	68 bc 25 80 00       	push   $0x8025bc
  800bf8:	e8 4b f5 ff ff       	call   800148 <_panic>

00800bfd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0d:	89 d1                	mov    %edx,%ecx
  800c0f:	89 d3                	mov    %edx,%ebx
  800c11:	89 d7                	mov    %edx,%edi
  800c13:	89 d6                	mov    %edx,%esi
  800c15:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_yield>:

void
sys_yield(void)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	89 f7                	mov    %esi,%edi
  800c59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7f 08                	jg     800c67 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 04                	push   $0x4
  800c6d:	68 9f 25 80 00       	push   $0x80259f
  800c72:	6a 23                	push   $0x23
  800c74:	68 bc 25 80 00       	push   $0x8025bc
  800c79:	e8 ca f4 ff ff       	call   800148 <_panic>

00800c7e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c98:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	7f 08                	jg     800ca9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 05                	push   $0x5
  800caf:	68 9f 25 80 00       	push   $0x80259f
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 bc 25 80 00       	push   $0x8025bc
  800cbb:	e8 88 f4 ff ff       	call   800148 <_panic>

00800cc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd9:	89 df                	mov    %ebx,%edi
  800cdb:	89 de                	mov    %ebx,%esi
  800cdd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7f 08                	jg     800ceb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 06                	push   $0x6
  800cf1:	68 9f 25 80 00       	push   $0x80259f
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 bc 25 80 00       	push   $0x8025bc
  800cfd:	e8 46 f4 ff ff       	call   800148 <_panic>

00800d02 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1b:	89 df                	mov    %ebx,%edi
  800d1d:	89 de                	mov    %ebx,%esi
  800d1f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d21:	85 c0                	test   %eax,%eax
  800d23:	7f 08                	jg     800d2d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 08                	push   $0x8
  800d33:	68 9f 25 80 00       	push   $0x80259f
  800d38:	6a 23                	push   $0x23
  800d3a:	68 bc 25 80 00       	push   $0x8025bc
  800d3f:	e8 04 f4 ff ff       	call   800148 <_panic>

00800d44 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5d:	89 df                	mov    %ebx,%edi
  800d5f:	89 de                	mov    %ebx,%esi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d73:	6a 09                	push   $0x9
  800d75:	68 9f 25 80 00       	push   $0x80259f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 bc 25 80 00       	push   $0x8025bc
  800d81:	e8 c2 f3 ff ff       	call   800148 <_panic>

00800d86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800db5:	6a 0a                	push   $0xa
  800db7:	68 9f 25 80 00       	push   $0x80259f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 bc 25 80 00       	push   $0x8025bc
  800dc3:	e8 80 f3 ff ff       	call   800148 <_panic>

00800dc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	be 00 00 00 00       	mov    $0x0,%esi
  800dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e01:	89 cb                	mov    %ecx,%ebx
  800e03:	89 cf                	mov    %ecx,%edi
  800e05:	89 ce                	mov    %ecx,%esi
  800e07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7f 08                	jg     800e15 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	83 ec 0c             	sub    $0xc,%esp
  800e18:	50                   	push   %eax
  800e19:	6a 0d                	push   $0xd
  800e1b:	68 9f 25 80 00       	push   $0x80259f
  800e20:	6a 23                	push   $0x23
  800e22:	68 bc 25 80 00       	push   $0x8025bc
  800e27:	e8 1c f3 ff ff       	call   800148 <_panic>

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e36:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800e38:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e3b:	a8 02                	test   $0x2,%al
  800e3d:	0f 84 89 00 00 00    	je     800ecc <pgfault+0xa0>
  800e43:	89 da                	mov    %ebx,%edx
  800e45:	c1 ea 0c             	shr    $0xc,%edx
  800e48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4f:	f6 c6 08             	test   $0x8,%dh
  800e52:	74 78                	je     800ecc <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	6a 07                	push   $0x7
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 d6 fd ff ff       	call   800c3b <sys_page_alloc>
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	0f 88 8b 00 00 00    	js     800efb <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 00 10 00 00       	push   $0x1000
  800e78:	53                   	push   %ebx
  800e79:	68 00 f0 7f 00       	push   $0x7ff000
  800e7e:	e8 4d fb ff ff       	call   8009d0 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e83:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8a:	53                   	push   %ebx
  800e8b:	6a 00                	push   $0x0
  800e8d:	68 00 f0 7f 00       	push   $0x7ff000
  800e92:	6a 00                	push   $0x0
  800e94:	e8 e5 fd ff ff       	call   800c7e <sys_page_map>
  800e99:	83 c4 20             	add    $0x20,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	78 6d                	js     800f0d <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	68 00 f0 7f 00       	push   $0x7ff000
  800ea8:	6a 00                	push   $0x0
  800eaa:	e8 11 fe ff ff       	call   800cc0 <sys_page_unmap>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	78 69                	js     800f1f <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	53                   	push   %ebx
  800eba:	68 28 26 80 00       	push   $0x802628
  800ebf:	e8 5f f3 ff ff       	call   800223 <cprintf>

}
  800ec4:	83 c4 10             	add    $0x10,%esp
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800ecc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800ed2:	8b 4a 48             	mov    0x48(%edx),%ecx
  800ed5:	89 da                	mov    %ebx,%edx
  800ed7:	c1 ea 0c             	shr    $0xc,%edx
  800eda:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee1:	51                   	push   %ecx
  800ee2:	53                   	push   %ebx
  800ee3:	68 00 00 40 ef       	push   $0xef400000
  800ee8:	52                   	push   %edx
  800ee9:	50                   	push   %eax
  800eea:	68 cc 25 80 00       	push   $0x8025cc
  800eef:	6a 1e                	push   $0x1e
  800ef1:	68 49 26 80 00       	push   $0x802649
  800ef6:	e8 4d f2 ff ff       	call   800148 <_panic>
        panic("sys_page_alloc error %e", r);
  800efb:	50                   	push   %eax
  800efc:	68 54 26 80 00       	push   $0x802654
  800f01:	6a 28                	push   $0x28
  800f03:	68 49 26 80 00       	push   $0x802649
  800f08:	e8 3b f2 ff ff       	call   800148 <_panic>
        panic("sys_page_map error %e", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 6c 26 80 00       	push   $0x80266c
  800f13:	6a 2b                	push   $0x2b
  800f15:	68 49 26 80 00       	push   $0x802649
  800f1a:	e8 29 f2 ff ff       	call   800148 <_panic>
        panic("sys_page_unmap error %e", r);
  800f1f:	50                   	push   %eax
  800f20:	68 82 26 80 00       	push   $0x802682
  800f25:	6a 2d                	push   $0x2d
  800f27:	68 49 26 80 00       	push   $0x802649
  800f2c:	e8 17 f2 ff ff       	call   800148 <_panic>

00800f31 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f37:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800f3e:	74 23                	je     800f63 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	a3 0c 40 80 00       	mov    %eax,0x80400c
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800f48:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4d:	8b 40 48             	mov    0x48(%eax),%eax
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	68 90 1e 80 00       	push   $0x801e90
  800f58:	50                   	push   %eax
  800f59:	e8 28 fe ff ff       	call   800d86 <sys_env_set_pgfault_upcall>
}
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f63:	a1 08 40 80 00       	mov    0x804008,%eax
  800f68:	8b 40 48             	mov    0x48(%eax),%eax
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	6a 07                	push   $0x7
  800f70:	68 00 f0 bf ee       	push   $0xeebff000
  800f75:	50                   	push   %eax
  800f76:	e8 c0 fc ff ff       	call   800c3b <sys_page_alloc>
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	79 be                	jns    800f40 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f82:	50                   	push   %eax
  800f83:	68 9a 26 80 00       	push   $0x80269a
  800f88:	6a 21                	push   $0x21
  800f8a:	68 ad 26 80 00       	push   $0x8026ad
  800f8f:	e8 b4 f1 ff ff       	call   800148 <_panic>

00800f94 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	8b 75 08             	mov    0x8(%ebp),%esi
  800f9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	6a 07                	push   $0x7
  800fa4:	53                   	push   %ebx
  800fa5:	56                   	push   %esi
  800fa6:	e8 90 fc ff ff       	call   800c3b <sys_page_alloc>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 4a                	js     800ffc <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fb2:	83 ec 0c             	sub    $0xc,%esp
  800fb5:	6a 07                	push   $0x7
  800fb7:	68 00 00 40 00       	push   $0x400000
  800fbc:	6a 00                	push   $0x0
  800fbe:	53                   	push   %ebx
  800fbf:	56                   	push   %esi
  800fc0:	e8 b9 fc ff ff       	call   800c7e <sys_page_map>
  800fc5:	83 c4 20             	add    $0x20,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 42                	js     80100e <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 00 10 00 00       	push   $0x1000
  800fd4:	53                   	push   %ebx
  800fd5:	68 00 00 40 00       	push   $0x400000
  800fda:	e8 f1 f9 ff ff       	call   8009d0 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800fdf:	83 c4 08             	add    $0x8,%esp
  800fe2:	68 00 00 40 00       	push   $0x400000
  800fe7:	6a 00                	push   $0x0
  800fe9:	e8 d2 fc ff ff       	call   800cc0 <sys_page_unmap>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 2b                	js     801020 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800ff5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800ffc:	50                   	push   %eax
  800ffd:	68 9a 26 80 00       	push   $0x80269a
  801002:	6a 63                	push   $0x63
  801004:	68 49 26 80 00       	push   $0x802649
  801009:	e8 3a f1 ff ff       	call   800148 <_panic>
        panic("sys_page_map: %e", r);
  80100e:	50                   	push   %eax
  80100f:	68 bd 26 80 00       	push   $0x8026bd
  801014:	6a 65                	push   $0x65
  801016:	68 49 26 80 00       	push   $0x802649
  80101b:	e8 28 f1 ff ff       	call   800148 <_panic>
        panic("sys_page_unmap: %e", r);
  801020:	50                   	push   %eax
  801021:	68 ce 26 80 00       	push   $0x8026ce
  801026:	6a 68                	push   $0x68
  801028:	68 49 26 80 00       	push   $0x802649
  80102d:	e8 16 f1 ff ff       	call   800148 <_panic>

00801032 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  80103b:	a1 08 40 80 00       	mov    0x804008,%eax
  801040:	8b 40 64             	mov    0x64(%eax),%eax
  801043:	85 c0                	test   %eax,%eax
  801045:	74 1f                	je     801066 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801047:	b8 07 00 00 00       	mov    $0x7,%eax
  80104c:	cd 30                	int    $0x30
  80104e:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801050:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801053:	85 c0                	test   %eax,%eax
  801055:	74 21                	je     801078 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801057:	be 0c 40 80 00       	mov    $0x80400c,%esi
  80105c:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801064:	eb 7b                	jmp    8010e1 <fork+0xaf>
        set_pgfault_handler(pgfault);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	68 2c 0e 80 00       	push   $0x800e2c
  80106e:	e8 be fe ff ff       	call   800f31 <set_pgfault_handler>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	eb cf                	jmp    801047 <fork+0x15>
        set_pgfault_handler(pgfault);
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	68 2c 0e 80 00       	push   $0x800e2c
  801080:	e8 ac fe ff ff       	call   800f31 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801085:	e8 73 fb ff ff       	call   800bfd <sys_getenvid>
  80108a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801092:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801097:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	e9 ca 00 00 00       	jmp    80116e <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  8010a4:	89 d1                	mov    %edx,%ecx
  8010a6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  8010ac:	81 e2 02 08 00 00    	and    $0x802,%edx
  8010b2:	89 cf                	mov    %ecx,%edi
  8010b4:	81 cf 00 08 00 00    	or     $0x800,%edi
  8010ba:	85 d2                	test   %edx,%edx
  8010bc:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	51                   	push   %ecx
  8010c3:	50                   	push   %eax
  8010c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c7:	50                   	push   %eax
  8010c8:	6a 00                	push   $0x0
  8010ca:	e8 af fb ff ff       	call   800c7e <sys_page_map>
  8010cf:	83 c4 20             	add    $0x20,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 45                	js     80111b <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8010d6:	83 c3 01             	add    $0x1,%ebx
  8010d9:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8010df:	74 4c                	je     80112d <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8010e1:	39 de                	cmp    %ebx,%esi
  8010e3:	74 f1                	je     8010d6 <fork+0xa4>
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 16             	shr    $0x16,%edx
  8010ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8010f6:	f6 c2 05             	test   $0x5,%dl
  8010f9:	74 db                	je     8010d6 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 0c             	shr    $0xc,%edx
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801107:	f6 c2 04             	test   $0x4,%dl
  80110a:	74 ca                	je     8010d6 <fork+0xa4>
    if (perm & PTE_SHARE) {
  80110c:	f6 c6 04             	test   $0x4,%dh
  80110f:	74 93                	je     8010a4 <fork+0x72>
        perm &= ~PTE_COW;
  801111:	89 d1                	mov    %edx,%ecx
  801113:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801119:	eb a4                	jmp    8010bf <fork+0x8d>
        panic("sys_page_map error %e", r);
  80111b:	50                   	push   %eax
  80111c:	68 6c 26 80 00       	push   $0x80266c
  801121:	6a 57                	push   $0x57
  801123:	68 49 26 80 00       	push   $0x802649
  801128:	e8 1b f0 ff ff       	call   800148 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	b8 0c 40 80 00       	mov    $0x80400c,%eax
  801135:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80113a:	50                   	push   %eax
  80113b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113e:	e8 51 fe ff ff       	call   800f94 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801149:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114e:	50                   	push   %eax
  80114f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801152:	e8 3d fe ff ff       	call   800f94 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801157:	83 c4 08             	add    $0x8,%esp
  80115a:	6a 02                	push   $0x2
  80115c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80115f:	e8 9e fb ff ff       	call   800d02 <sys_env_set_status>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 0d                	js     801178 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  80116b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  80116e:	89 d8                	mov    %ebx,%eax
  801170:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801173:	5b                   	pop    %ebx
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801178:	50                   	push   %eax
  801179:	68 e1 26 80 00       	push   $0x8026e1
  80117e:	68 a0 00 00 00       	push   $0xa0
  801183:	68 49 26 80 00       	push   $0x802649
  801188:	e8 bb ef ff ff       	call   800148 <_panic>

0080118d <sfork>:

// Challenge!
int
sfork(void)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801193:	68 f8 26 80 00       	push   $0x8026f8
  801198:	68 a9 00 00 00       	push   $0xa9
  80119d:	68 49 26 80 00       	push   $0x802649
  8011a2:	e8 a1 ef ff ff       	call   800148 <_panic>

008011a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d9:	89 c2                	mov    %eax,%edx
  8011db:	c1 ea 16             	shr    $0x16,%edx
  8011de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e5:	f6 c2 01             	test   $0x1,%dl
  8011e8:	74 2a                	je     801214 <fd_alloc+0x46>
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 0c             	shr    $0xc,%edx
  8011ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	74 19                	je     801214 <fd_alloc+0x46>
  8011fb:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801200:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801205:	75 d2                	jne    8011d9 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801207:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80120d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801212:	eb 07                	jmp    80121b <fd_alloc+0x4d>
			*fd_store = fd;
  801214:	89 01                	mov    %eax,(%ecx)
			return 0;
  801216:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801223:	83 f8 1f             	cmp    $0x1f,%eax
  801226:	77 36                	ja     80125e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801228:	c1 e0 0c             	shl    $0xc,%eax
  80122b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801230:	89 c2                	mov    %eax,%edx
  801232:	c1 ea 16             	shr    $0x16,%edx
  801235:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123c:	f6 c2 01             	test   $0x1,%dl
  80123f:	74 24                	je     801265 <fd_lookup+0x48>
  801241:	89 c2                	mov    %eax,%edx
  801243:	c1 ea 0c             	shr    $0xc,%edx
  801246:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124d:	f6 c2 01             	test   $0x1,%dl
  801250:	74 1a                	je     80126c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801252:	8b 55 0c             	mov    0xc(%ebp),%edx
  801255:	89 02                	mov    %eax,(%edx)
	return 0;
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    
		return -E_INVAL;
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801263:	eb f7                	jmp    80125c <fd_lookup+0x3f>
		return -E_INVAL;
  801265:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126a:	eb f0                	jmp    80125c <fd_lookup+0x3f>
  80126c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801271:	eb e9                	jmp    80125c <fd_lookup+0x3f>

00801273 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80127c:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801281:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801286:	39 08                	cmp    %ecx,(%eax)
  801288:	74 33                	je     8012bd <dev_lookup+0x4a>
  80128a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80128d:	8b 02                	mov    (%edx),%eax
  80128f:	85 c0                	test   %eax,%eax
  801291:	75 f3                	jne    801286 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801293:	a1 08 40 80 00       	mov    0x804008,%eax
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	51                   	push   %ecx
  80129f:	50                   	push   %eax
  8012a0:	68 10 27 80 00       	push   $0x802710
  8012a5:	e8 79 ef ff ff       	call   800223 <cprintf>
	*dev = 0;
  8012aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    
			*dev = devtab[i];
  8012bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c7:	eb f2                	jmp    8012bb <dev_lookup+0x48>

008012c9 <fd_close>:
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 1c             	sub    $0x1c,%esp
  8012d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012db:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e5:	50                   	push   %eax
  8012e6:	e8 32 ff ff ff       	call   80121d <fd_lookup>
  8012eb:	89 c3                	mov    %eax,%ebx
  8012ed:	83 c4 08             	add    $0x8,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 05                	js     8012f9 <fd_close+0x30>
	    || fd != fd2)
  8012f4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012f7:	74 16                	je     80130f <fd_close+0x46>
		return (must_exist ? r : 0);
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	84 c0                	test   %al,%al
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801302:	0f 44 d8             	cmove  %eax,%ebx
}
  801305:	89 d8                	mov    %ebx,%eax
  801307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	ff 36                	pushl  (%esi)
  801318:	e8 56 ff ff ff       	call   801273 <dev_lookup>
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 15                	js     80133b <fd_close+0x72>
		if (dev->dev_close)
  801326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801329:	8b 40 10             	mov    0x10(%eax),%eax
  80132c:	85 c0                	test   %eax,%eax
  80132e:	74 1b                	je     80134b <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	56                   	push   %esi
  801334:	ff d0                	call   *%eax
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	56                   	push   %esi
  80133f:	6a 00                	push   $0x0
  801341:	e8 7a f9 ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	eb ba                	jmp    801305 <fd_close+0x3c>
			r = 0;
  80134b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801350:	eb e9                	jmp    80133b <fd_close+0x72>

00801352 <close>:

int
close(int fdnum)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 08             	pushl  0x8(%ebp)
  80135f:	e8 b9 fe ff ff       	call   80121d <fd_lookup>
  801364:	83 c4 08             	add    $0x8,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 10                	js     80137b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	6a 01                	push   $0x1
  801370:	ff 75 f4             	pushl  -0xc(%ebp)
  801373:	e8 51 ff ff ff       	call   8012c9 <fd_close>
  801378:	83 c4 10             	add    $0x10,%esp
}
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <close_all>:

void
close_all(void)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	53                   	push   %ebx
  801381:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801384:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	53                   	push   %ebx
  80138d:	e8 c0 ff ff ff       	call   801352 <close>
	for (i = 0; i < MAXFD; i++)
  801392:	83 c3 01             	add    $0x1,%ebx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	83 fb 20             	cmp    $0x20,%ebx
  80139b:	75 ec                	jne    801389 <close_all+0xc>
}
  80139d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	ff 75 08             	pushl  0x8(%ebp)
  8013b2:	e8 66 fe ff ff       	call   80121d <fd_lookup>
  8013b7:	89 c3                	mov    %eax,%ebx
  8013b9:	83 c4 08             	add    $0x8,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	0f 88 81 00 00 00    	js     801445 <dup+0xa3>
		return r;
	close(newfdnum);
  8013c4:	83 ec 0c             	sub    $0xc,%esp
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	e8 83 ff ff ff       	call   801352 <close>

	newfd = INDEX2FD(newfdnum);
  8013cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d2:	c1 e6 0c             	shl    $0xc,%esi
  8013d5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013db:	83 c4 04             	add    $0x4,%esp
  8013de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e1:	e8 d1 fd ff ff       	call   8011b7 <fd2data>
  8013e6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e8:	89 34 24             	mov    %esi,(%esp)
  8013eb:	e8 c7 fd ff ff       	call   8011b7 <fd2data>
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f5:	89 d8                	mov    %ebx,%eax
  8013f7:	c1 e8 16             	shr    $0x16,%eax
  8013fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801401:	a8 01                	test   $0x1,%al
  801403:	74 11                	je     801416 <dup+0x74>
  801405:	89 d8                	mov    %ebx,%eax
  801407:	c1 e8 0c             	shr    $0xc,%eax
  80140a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801411:	f6 c2 01             	test   $0x1,%dl
  801414:	75 39                	jne    80144f <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801419:	89 d0                	mov    %edx,%eax
  80141b:	c1 e8 0c             	shr    $0xc,%eax
  80141e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	25 07 0e 00 00       	and    $0xe07,%eax
  80142d:	50                   	push   %eax
  80142e:	56                   	push   %esi
  80142f:	6a 00                	push   $0x0
  801431:	52                   	push   %edx
  801432:	6a 00                	push   $0x0
  801434:	e8 45 f8 ff ff       	call   800c7e <sys_page_map>
  801439:	89 c3                	mov    %eax,%ebx
  80143b:	83 c4 20             	add    $0x20,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 31                	js     801473 <dup+0xd1>
		goto err;

	return newfdnum;
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801445:	89 d8                	mov    %ebx,%eax
  801447:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	25 07 0e 00 00       	and    $0xe07,%eax
  80145e:	50                   	push   %eax
  80145f:	57                   	push   %edi
  801460:	6a 00                	push   $0x0
  801462:	53                   	push   %ebx
  801463:	6a 00                	push   $0x0
  801465:	e8 14 f8 ff ff       	call   800c7e <sys_page_map>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	83 c4 20             	add    $0x20,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	79 a3                	jns    801416 <dup+0x74>
	sys_page_unmap(0, newfd);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	56                   	push   %esi
  801477:	6a 00                	push   $0x0
  801479:	e8 42 f8 ff ff       	call   800cc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147e:	83 c4 08             	add    $0x8,%esp
  801481:	57                   	push   %edi
  801482:	6a 00                	push   $0x0
  801484:	e8 37 f8 ff ff       	call   800cc0 <sys_page_unmap>
	return r;
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	eb b7                	jmp    801445 <dup+0xa3>

0080148e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	53                   	push   %ebx
  801492:	83 ec 14             	sub    $0x14,%esp
  801495:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801498:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	53                   	push   %ebx
  80149d:	e8 7b fd ff ff       	call   80121d <fd_lookup>
  8014a2:	83 c4 08             	add    $0x8,%esp
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 3f                	js     8014e8 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	ff 30                	pushl  (%eax)
  8014b5:	e8 b9 fd ff ff       	call   801273 <dev_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 27                	js     8014e8 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c4:	8b 42 08             	mov    0x8(%edx),%eax
  8014c7:	83 e0 03             	and    $0x3,%eax
  8014ca:	83 f8 01             	cmp    $0x1,%eax
  8014cd:	74 1e                	je     8014ed <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	8b 40 08             	mov    0x8(%eax),%eax
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 35                	je     80150e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	ff 75 10             	pushl  0x10(%ebp)
  8014df:	ff 75 0c             	pushl  0xc(%ebp)
  8014e2:	52                   	push   %edx
  8014e3:	ff d0                	call   *%eax
  8014e5:	83 c4 10             	add    $0x10,%esp
}
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8014f2:	8b 40 48             	mov    0x48(%eax),%eax
  8014f5:	83 ec 04             	sub    $0x4,%esp
  8014f8:	53                   	push   %ebx
  8014f9:	50                   	push   %eax
  8014fa:	68 51 27 80 00       	push   $0x802751
  8014ff:	e8 1f ed ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150c:	eb da                	jmp    8014e8 <read+0x5a>
		return -E_NOT_SUPP;
  80150e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801513:	eb d3                	jmp    8014e8 <read+0x5a>

00801515 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 0c             	sub    $0xc,%esp
  80151e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801521:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801524:	bb 00 00 00 00       	mov    $0x0,%ebx
  801529:	39 f3                	cmp    %esi,%ebx
  80152b:	73 25                	jae    801552 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152d:	83 ec 04             	sub    $0x4,%esp
  801530:	89 f0                	mov    %esi,%eax
  801532:	29 d8                	sub    %ebx,%eax
  801534:	50                   	push   %eax
  801535:	89 d8                	mov    %ebx,%eax
  801537:	03 45 0c             	add    0xc(%ebp),%eax
  80153a:	50                   	push   %eax
  80153b:	57                   	push   %edi
  80153c:	e8 4d ff ff ff       	call   80148e <read>
		if (m < 0)
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 08                	js     801550 <readn+0x3b>
			return m;
		if (m == 0)
  801548:	85 c0                	test   %eax,%eax
  80154a:	74 06                	je     801552 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80154c:	01 c3                	add    %eax,%ebx
  80154e:	eb d9                	jmp    801529 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801550:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801552:	89 d8                	mov    %ebx,%eax
  801554:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801557:	5b                   	pop    %ebx
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 14             	sub    $0x14,%esp
  801563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	50                   	push   %eax
  80156a:	53                   	push   %ebx
  80156b:	e8 ad fc ff ff       	call   80121d <fd_lookup>
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	85 c0                	test   %eax,%eax
  801575:	78 3a                	js     8015b1 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	ff 30                	pushl  (%eax)
  801583:	e8 eb fc ff ff       	call   801273 <dev_lookup>
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 22                	js     8015b1 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801592:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801596:	74 1e                	je     8015b6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801598:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159b:	8b 52 0c             	mov    0xc(%edx),%edx
  80159e:	85 d2                	test   %edx,%edx
  8015a0:	74 35                	je     8015d7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	ff 75 10             	pushl  0x10(%ebp)
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	50                   	push   %eax
  8015ac:	ff d2                	call   *%edx
  8015ae:	83 c4 10             	add    $0x10,%esp
}
  8015b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015bb:	8b 40 48             	mov    0x48(%eax),%eax
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	50                   	push   %eax
  8015c3:	68 6d 27 80 00       	push   $0x80276d
  8015c8:	e8 56 ec ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d5:	eb da                	jmp    8015b1 <write+0x55>
		return -E_NOT_SUPP;
  8015d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015dc:	eb d3                	jmp    8015b1 <write+0x55>

008015de <seek>:

int
seek(int fdnum, off_t offset)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	e8 2d fc ff ff       	call   80121d <fd_lookup>
  8015f0:	83 c4 08             	add    $0x8,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 0e                	js     801605 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801600:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	53                   	push   %ebx
  80160b:	83 ec 14             	sub    $0x14,%esp
  80160e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	53                   	push   %ebx
  801616:	e8 02 fc ff ff       	call   80121d <fd_lookup>
  80161b:	83 c4 08             	add    $0x8,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 37                	js     801659 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	ff 30                	pushl  (%eax)
  80162e:	e8 40 fc ff ff       	call   801273 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 1f                	js     801659 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801641:	74 1b                	je     80165e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801643:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801646:	8b 52 18             	mov    0x18(%edx),%edx
  801649:	85 d2                	test   %edx,%edx
  80164b:	74 32                	je     80167f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	ff 75 0c             	pushl  0xc(%ebp)
  801653:	50                   	push   %eax
  801654:	ff d2                	call   *%edx
  801656:	83 c4 10             	add    $0x10,%esp
}
  801659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80165e:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801663:	8b 40 48             	mov    0x48(%eax),%eax
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	53                   	push   %ebx
  80166a:	50                   	push   %eax
  80166b:	68 30 27 80 00       	push   $0x802730
  801670:	e8 ae eb ff ff       	call   800223 <cprintf>
		return -E_INVAL;
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167d:	eb da                	jmp    801659 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80167f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801684:	eb d3                	jmp    801659 <ftruncate+0x52>

00801686 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	53                   	push   %ebx
  80168a:	83 ec 14             	sub    $0x14,%esp
  80168d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801690:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 81 fb ff ff       	call   80121d <fd_lookup>
  80169c:	83 c4 08             	add    $0x8,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 4b                	js     8016ee <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 bf fb ff ff       	call   801273 <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 33                	js     8016ee <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c2:	74 2f                	je     8016f3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ce:	00 00 00 
	stat->st_isdir = 0;
  8016d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d8:	00 00 00 
	stat->st_dev = dev;
  8016db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e1:	83 ec 08             	sub    $0x8,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016e8:	ff 50 14             	call   *0x14(%eax)
  8016eb:	83 c4 10             	add    $0x10,%esp
}
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f8:	eb f4                	jmp    8016ee <fstat+0x68>

008016fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	6a 00                	push   $0x0
  801704:	ff 75 08             	pushl  0x8(%ebp)
  801707:	e8 e7 01 00 00       	call   8018f3 <open>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	85 c0                	test   %eax,%eax
  801713:	78 1b                	js     801730 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801715:	83 ec 08             	sub    $0x8,%esp
  801718:	ff 75 0c             	pushl  0xc(%ebp)
  80171b:	50                   	push   %eax
  80171c:	e8 65 ff ff ff       	call   801686 <fstat>
  801721:	89 c6                	mov    %eax,%esi
	close(fd);
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 27 fc ff ff       	call   801352 <close>
	return r;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	89 f3                	mov    %esi,%ebx
}
  801730:	89 d8                	mov    %ebx,%eax
  801732:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801735:	5b                   	pop    %ebx
  801736:	5e                   	pop    %esi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	89 c6                	mov    %eax,%esi
  801740:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801742:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801749:	74 27                	je     801772 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174b:	6a 07                	push   $0x7
  80174d:	68 00 50 80 00       	push   $0x805000
  801752:	56                   	push   %esi
  801753:	ff 35 00 40 80 00    	pushl  0x804000
  801759:	e8 b9 07 00 00       	call   801f17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80175e:	83 c4 0c             	add    $0xc,%esp
  801761:	6a 00                	push   $0x0
  801763:	53                   	push   %ebx
  801764:	6a 00                	push   $0x0
  801766:	e8 4b 07 00 00       	call   801eb6 <ipc_recv>
}
  80176b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801772:	83 ec 0c             	sub    $0xc,%esp
  801775:	6a 01                	push   $0x1
  801777:	e8 e8 07 00 00       	call   801f64 <ipc_find_env>
  80177c:	a3 00 40 80 00       	mov    %eax,0x804000
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	eb c5                	jmp    80174b <fsipc+0x12>

00801786 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 40 0c             	mov    0xc(%eax),%eax
  801792:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a9:	e8 8b ff ff ff       	call   801739 <fsipc>
}
  8017ae:	c9                   	leave  
  8017af:	c3                   	ret    

008017b0 <devfile_flush>:
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017bc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cb:	e8 69 ff ff ff       	call   801739 <fsipc>
}
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <devfile_stat>:
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f1:	e8 43 ff ff ff       	call   801739 <fsipc>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 2c                	js     801826 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	68 00 50 80 00       	push   $0x805000
  801802:	53                   	push   %ebx
  801803:	e8 3a f0 ff ff       	call   800842 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801808:	a1 80 50 80 00       	mov    0x805080,%eax
  80180d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801813:	a1 84 50 80 00       	mov    0x805084,%eax
  801818:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <devfile_write>:
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801834:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801839:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183e:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801841:	8b 55 08             	mov    0x8(%ebp),%edx
  801844:	8b 52 0c             	mov    0xc(%edx),%edx
  801847:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80184d:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801852:	50                   	push   %eax
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	68 08 50 80 00       	push   $0x805008
  80185b:	e8 70 f1 ff ff       	call   8009d0 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	b8 04 00 00 00       	mov    $0x4,%eax
  80186a:	e8 ca fe ff ff       	call   801739 <fsipc>
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devfile_read>:
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	8b 40 0c             	mov    0xc(%eax),%eax
  80187f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801884:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80188a:	ba 00 00 00 00       	mov    $0x0,%edx
  80188f:	b8 03 00 00 00       	mov    $0x3,%eax
  801894:	e8 a0 fe ff ff       	call   801739 <fsipc>
  801899:	89 c3                	mov    %eax,%ebx
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 1f                	js     8018be <devfile_read+0x4d>
	assert(r <= n);
  80189f:	39 f0                	cmp    %esi,%eax
  8018a1:	77 24                	ja     8018c7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018a3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a8:	7f 33                	jg     8018dd <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	50                   	push   %eax
  8018ae:	68 00 50 80 00       	push   $0x805000
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	e8 15 f1 ff ff       	call   8009d0 <memmove>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	89 d8                	mov    %ebx,%eax
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    
	assert(r <= n);
  8018c7:	68 9c 27 80 00       	push   $0x80279c
  8018cc:	68 a3 27 80 00       	push   $0x8027a3
  8018d1:	6a 7d                	push   $0x7d
  8018d3:	68 b8 27 80 00       	push   $0x8027b8
  8018d8:	e8 6b e8 ff ff       	call   800148 <_panic>
	assert(r <= PGSIZE);
  8018dd:	68 c3 27 80 00       	push   $0x8027c3
  8018e2:	68 a3 27 80 00       	push   $0x8027a3
  8018e7:	6a 7e                	push   $0x7e
  8018e9:	68 b8 27 80 00       	push   $0x8027b8
  8018ee:	e8 55 e8 ff ff       	call   800148 <_panic>

008018f3 <open>:
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 1c             	sub    $0x1c,%esp
  8018fb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018fe:	56                   	push   %esi
  8018ff:	e8 07 ef ff ff       	call   80080b <strlen>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190c:	0f 8f 96 00 00 00    	jg     8019a8 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	e8 b0 f8 ff ff       	call   8011ce <fd_alloc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	83 c4 10             	add    $0x10,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	78 66                	js     80198d <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	56                   	push   %esi
  80192b:	68 00 50 80 00       	push   $0x805000
  801930:	e8 0d ef ff ff       	call   800842 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801935:	8b 45 0c             	mov    0xc(%ebp),%eax
  801938:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80193d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801940:	b8 01 00 00 00       	mov    $0x1,%eax
  801945:	e8 ef fd ff ff       	call   801739 <fsipc>
  80194a:	89 c3                	mov    %eax,%ebx
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 43                	js     801996 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	e8 49 f8 ff ff       	call   8011a7 <fd2num>
  80195e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801961:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801967:	8b 49 48             	mov    0x48(%ecx),%ecx
  80196a:	83 c4 08             	add    $0x8,%esp
  80196d:	50                   	push   %eax
  80196e:	52                   	push   %edx
  80196f:	ff 32                	pushl  (%edx)
  801971:	56                   	push   %esi
  801972:	51                   	push   %ecx
  801973:	68 d0 27 80 00       	push   $0x8027d0
  801978:	e8 a6 e8 ff ff       	call   800223 <cprintf>
	return fd2num(fd);
  80197d:	83 c4 14             	add    $0x14,%esp
  801980:	ff 75 f4             	pushl  -0xc(%ebp)
  801983:	e8 1f f8 ff ff       	call   8011a7 <fd2num>
  801988:	89 c3                	mov    %eax,%ebx
  80198a:	83 c4 10             	add    $0x10,%esp
}
  80198d:	89 d8                	mov    %ebx,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
		fd_close(fd, 0);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	6a 00                	push   $0x0
  80199b:	ff 75 f4             	pushl  -0xc(%ebp)
  80199e:	e8 26 f9 ff ff       	call   8012c9 <fd_close>
		return r;
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	eb e5                	jmp    80198d <open+0x9a>
		return -E_BAD_PATH;
  8019a8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ad:	eb de                	jmp    80198d <open+0x9a>

008019af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8019bf:	e8 75 fd ff ff       	call   801739 <fsipc>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	ff 75 08             	pushl  0x8(%ebp)
  8019d4:	e8 de f7 ff ff       	call   8011b7 <fd2data>
  8019d9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019db:	83 c4 08             	add    $0x8,%esp
  8019de:	68 10 28 80 00       	push   $0x802810
  8019e3:	53                   	push   %ebx
  8019e4:	e8 59 ee ff ff       	call   800842 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e9:	8b 46 04             	mov    0x4(%esi),%eax
  8019ec:	2b 06                	sub    (%esi),%eax
  8019ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019f4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019fb:	00 00 00 
	stat->st_dev = &devpipe;
  8019fe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a05:	30 80 00 
	return 0;
}
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	53                   	push   %ebx
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a1e:	53                   	push   %ebx
  801a1f:	6a 00                	push   $0x0
  801a21:	e8 9a f2 ff ff       	call   800cc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a26:	89 1c 24             	mov    %ebx,(%esp)
  801a29:	e8 89 f7 ff ff       	call   8011b7 <fd2data>
  801a2e:	83 c4 08             	add    $0x8,%esp
  801a31:	50                   	push   %eax
  801a32:	6a 00                	push   $0x0
  801a34:	e8 87 f2 ff ff       	call   800cc0 <sys_page_unmap>
}
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <_pipeisclosed>:
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	57                   	push   %edi
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	83 ec 1c             	sub    $0x1c,%esp
  801a47:	89 c7                	mov    %eax,%edi
  801a49:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a4b:	a1 08 40 80 00       	mov    0x804008,%eax
  801a50:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	57                   	push   %edi
  801a57:	e8 41 05 00 00       	call   801f9d <pageref>
  801a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a5f:	89 34 24             	mov    %esi,(%esp)
  801a62:	e8 36 05 00 00       	call   801f9d <pageref>
		nn = thisenv->env_runs;
  801a67:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a6d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	39 cb                	cmp    %ecx,%ebx
  801a75:	74 1b                	je     801a92 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a77:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a7a:	75 cf                	jne    801a4b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a7c:	8b 42 58             	mov    0x58(%edx),%eax
  801a7f:	6a 01                	push   $0x1
  801a81:	50                   	push   %eax
  801a82:	53                   	push   %ebx
  801a83:	68 17 28 80 00       	push   $0x802817
  801a88:	e8 96 e7 ff ff       	call   800223 <cprintf>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	eb b9                	jmp    801a4b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a92:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a95:	0f 94 c0             	sete   %al
  801a98:	0f b6 c0             	movzbl %al,%eax
}
  801a9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5f                   	pop    %edi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <devpipe_write>:
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 28             	sub    $0x28,%esp
  801aac:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801aaf:	56                   	push   %esi
  801ab0:	e8 02 f7 ff ff       	call   8011b7 <fd2data>
  801ab5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	bf 00 00 00 00       	mov    $0x0,%edi
  801abf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ac2:	74 4f                	je     801b13 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ac4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac7:	8b 0b                	mov    (%ebx),%ecx
  801ac9:	8d 51 20             	lea    0x20(%ecx),%edx
  801acc:	39 d0                	cmp    %edx,%eax
  801ace:	72 14                	jb     801ae4 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801ad0:	89 da                	mov    %ebx,%edx
  801ad2:	89 f0                	mov    %esi,%eax
  801ad4:	e8 65 ff ff ff       	call   801a3e <_pipeisclosed>
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	75 3a                	jne    801b17 <devpipe_write+0x74>
			sys_yield();
  801add:	e8 3a f1 ff ff       	call   800c1c <sys_yield>
  801ae2:	eb e0                	jmp    801ac4 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aeb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aee:	89 c2                	mov    %eax,%edx
  801af0:	c1 fa 1f             	sar    $0x1f,%edx
  801af3:	89 d1                	mov    %edx,%ecx
  801af5:	c1 e9 1b             	shr    $0x1b,%ecx
  801af8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801afb:	83 e2 1f             	and    $0x1f,%edx
  801afe:	29 ca                	sub    %ecx,%edx
  801b00:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b04:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b08:	83 c0 01             	add    $0x1,%eax
  801b0b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b0e:	83 c7 01             	add    $0x1,%edi
  801b11:	eb ac                	jmp    801abf <devpipe_write+0x1c>
	return i;
  801b13:	89 f8                	mov    %edi,%eax
  801b15:	eb 05                	jmp    801b1c <devpipe_write+0x79>
				return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <devpipe_read>:
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 18             	sub    $0x18,%esp
  801b2d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b30:	57                   	push   %edi
  801b31:	e8 81 f6 ff ff       	call   8011b7 <fd2data>
  801b36:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	be 00 00 00 00       	mov    $0x0,%esi
  801b40:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b43:	74 47                	je     801b8c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801b45:	8b 03                	mov    (%ebx),%eax
  801b47:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b4a:	75 22                	jne    801b6e <devpipe_read+0x4a>
			if (i > 0)
  801b4c:	85 f6                	test   %esi,%esi
  801b4e:	75 14                	jne    801b64 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b50:	89 da                	mov    %ebx,%edx
  801b52:	89 f8                	mov    %edi,%eax
  801b54:	e8 e5 fe ff ff       	call   801a3e <_pipeisclosed>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	75 33                	jne    801b90 <devpipe_read+0x6c>
			sys_yield();
  801b5d:	e8 ba f0 ff ff       	call   800c1c <sys_yield>
  801b62:	eb e1                	jmp    801b45 <devpipe_read+0x21>
				return i;
  801b64:	89 f0                	mov    %esi,%eax
}
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b6e:	99                   	cltd   
  801b6f:	c1 ea 1b             	shr    $0x1b,%edx
  801b72:	01 d0                	add    %edx,%eax
  801b74:	83 e0 1f             	and    $0x1f,%eax
  801b77:	29 d0                	sub    %edx,%eax
  801b79:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b81:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b84:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b87:	83 c6 01             	add    $0x1,%esi
  801b8a:	eb b4                	jmp    801b40 <devpipe_read+0x1c>
	return i;
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	eb d6                	jmp    801b66 <devpipe_read+0x42>
				return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
  801b95:	eb cf                	jmp    801b66 <devpipe_read+0x42>

00801b97 <pipe>:
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	e8 26 f6 ff ff       	call   8011ce <fd_alloc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 5b                	js     801c0c <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb1:	83 ec 04             	sub    $0x4,%esp
  801bb4:	68 07 04 00 00       	push   $0x407
  801bb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 78 f0 ff ff       	call   800c3b <sys_page_alloc>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	78 40                	js     801c0c <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801bcc:	83 ec 0c             	sub    $0xc,%esp
  801bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd2:	50                   	push   %eax
  801bd3:	e8 f6 f5 ff ff       	call   8011ce <fd_alloc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 1b                	js     801bfc <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	68 07 04 00 00       	push   $0x407
  801be9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bec:	6a 00                	push   $0x0
  801bee:	e8 48 f0 ff ff       	call   800c3b <sys_page_alloc>
  801bf3:	89 c3                	mov    %eax,%ebx
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	79 19                	jns    801c15 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	ff 75 f4             	pushl  -0xc(%ebp)
  801c02:	6a 00                	push   $0x0
  801c04:	e8 b7 f0 ff ff       	call   800cc0 <sys_page_unmap>
  801c09:	83 c4 10             	add    $0x10,%esp
}
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
	va = fd2data(fd0);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1b:	e8 97 f5 ff ff       	call   8011b7 <fd2data>
  801c20:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c22:	83 c4 0c             	add    $0xc,%esp
  801c25:	68 07 04 00 00       	push   $0x407
  801c2a:	50                   	push   %eax
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 09 f0 ff ff       	call   800c3b <sys_page_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 8c 00 00 00    	js     801ccb <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	ff 75 f0             	pushl  -0x10(%ebp)
  801c45:	e8 6d f5 ff ff       	call   8011b7 <fd2data>
  801c4a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c51:	50                   	push   %eax
  801c52:	6a 00                	push   $0x0
  801c54:	56                   	push   %esi
  801c55:	6a 00                	push   $0x0
  801c57:	e8 22 f0 ff ff       	call   800c7e <sys_page_map>
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	83 c4 20             	add    $0x20,%esp
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 58                	js     801cbd <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c83:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c88:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	ff 75 f4             	pushl  -0xc(%ebp)
  801c95:	e8 0d f5 ff ff       	call   8011a7 <fd2num>
  801c9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c9f:	83 c4 04             	add    $0x4,%esp
  801ca2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca5:	e8 fd f4 ff ff       	call   8011a7 <fd2num>
  801caa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cad:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb8:	e9 4f ff ff ff       	jmp    801c0c <pipe+0x75>
	sys_page_unmap(0, va);
  801cbd:	83 ec 08             	sub    $0x8,%esp
  801cc0:	56                   	push   %esi
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 f8 ef ff ff       	call   800cc0 <sys_page_unmap>
  801cc8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ccb:	83 ec 08             	sub    $0x8,%esp
  801cce:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd1:	6a 00                	push   $0x0
  801cd3:	e8 e8 ef ff ff       	call   800cc0 <sys_page_unmap>
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	e9 1c ff ff ff       	jmp    801bfc <pipe+0x65>

00801ce0 <pipeisclosed>:
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce9:	50                   	push   %eax
  801cea:	ff 75 08             	pushl  0x8(%ebp)
  801ced:	e8 2b f5 ff ff       	call   80121d <fd_lookup>
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	78 18                	js     801d11 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	e8 b3 f4 ff ff       	call   8011b7 <fd2data>
	return _pipeisclosed(fd, p);
  801d04:	89 c2                	mov    %eax,%edx
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	e8 30 fd ff ff       	call   801a3e <_pipeisclosed>
  801d0e:	83 c4 10             	add    $0x10,%esp
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d23:	68 2f 28 80 00       	push   $0x80282f
  801d28:	ff 75 0c             	pushl  0xc(%ebp)
  801d2b:	e8 12 eb ff ff       	call   800842 <strcpy>
	return 0;
}
  801d30:	b8 00 00 00 00       	mov    $0x0,%eax
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <devcons_write>:
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	57                   	push   %edi
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d43:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d48:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d4e:	eb 2f                	jmp    801d7f <devcons_write+0x48>
		m = n - tot;
  801d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d53:	29 f3                	sub    %esi,%ebx
  801d55:	83 fb 7f             	cmp    $0x7f,%ebx
  801d58:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d5d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d60:	83 ec 04             	sub    $0x4,%esp
  801d63:	53                   	push   %ebx
  801d64:	89 f0                	mov    %esi,%eax
  801d66:	03 45 0c             	add    0xc(%ebp),%eax
  801d69:	50                   	push   %eax
  801d6a:	57                   	push   %edi
  801d6b:	e8 60 ec ff ff       	call   8009d0 <memmove>
		sys_cputs(buf, m);
  801d70:	83 c4 08             	add    $0x8,%esp
  801d73:	53                   	push   %ebx
  801d74:	57                   	push   %edi
  801d75:	e8 05 ee ff ff       	call   800b7f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d7a:	01 de                	add    %ebx,%esi
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d82:	72 cc                	jb     801d50 <devcons_write+0x19>
}
  801d84:	89 f0                	mov    %esi,%eax
  801d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <devcons_read>:
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d9d:	75 07                	jne    801da6 <devcons_read+0x18>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    
		sys_yield();
  801da1:	e8 76 ee ff ff       	call   800c1c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801da6:	e8 f2 ed ff ff       	call   800b9d <sys_cgetc>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	74 f2                	je     801da1 <devcons_read+0x13>
	if (c < 0)
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 ec                	js     801d9f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801db3:	83 f8 04             	cmp    $0x4,%eax
  801db6:	74 0c                	je     801dc4 <devcons_read+0x36>
	*(char*)vbuf = c;
  801db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbb:	88 02                	mov    %al,(%edx)
	return 1;
  801dbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801dc2:	eb db                	jmp    801d9f <devcons_read+0x11>
		return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	eb d4                	jmp    801d9f <devcons_read+0x11>

00801dcb <cputchar>:
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801dd7:	6a 01                	push   $0x1
  801dd9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ddc:	50                   	push   %eax
  801ddd:	e8 9d ed ff ff       	call   800b7f <sys_cputs>
}
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <getchar>:
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ded:	6a 01                	push   $0x1
  801def:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	6a 00                	push   $0x0
  801df5:	e8 94 f6 ff ff       	call   80148e <read>
	if (r < 0)
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 08                	js     801e09 <getchar+0x22>
	if (r < 1)
  801e01:	85 c0                	test   %eax,%eax
  801e03:	7e 06                	jle    801e0b <getchar+0x24>
	return c;
  801e05:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    
		return -E_EOF;
  801e0b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e10:	eb f7                	jmp    801e09 <getchar+0x22>

00801e12 <iscons>:
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e1b:	50                   	push   %eax
  801e1c:	ff 75 08             	pushl  0x8(%ebp)
  801e1f:	e8 f9 f3 ff ff       	call   80121d <fd_lookup>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	78 11                	js     801e3c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e34:	39 10                	cmp    %edx,(%eax)
  801e36:	0f 94 c0             	sete   %al
  801e39:	0f b6 c0             	movzbl %al,%eax
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <opencons>:
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 81 f3 ff ff       	call   8011ce <fd_alloc>
  801e4d:	83 c4 10             	add    $0x10,%esp
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 3a                	js     801e8e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e54:	83 ec 04             	sub    $0x4,%esp
  801e57:	68 07 04 00 00       	push   $0x407
  801e5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 d5 ed ff ff       	call   800c3b <sys_page_alloc>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 21                	js     801e8e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e76:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	50                   	push   %eax
  801e86:	e8 1c f3 ff ff       	call   8011a7 <fd2num>
  801e8b:	83 c4 10             	add    $0x10,%esp
}
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e90:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e91:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801e96:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e98:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801e9b:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801e9e:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801ea2:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801ea6:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801ea9:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801ead:	89 18                	mov    %ebx,(%eax)

    popal
  801eaf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801eb0:	83 c4 04             	add    $0x4,%esp
    popfl
  801eb3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801eb4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801eb5:	c3                   	ret    

00801eb6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
  801ebb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ecb:	0f 44 c2             	cmove  %edx,%eax
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	50                   	push   %eax
  801ed2:	e8 14 ef ff ff       	call   800deb <sys_ipc_recv>
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 2b                	js     801f09 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801ede:	85 f6                	test   %esi,%esi
  801ee0:	74 0a                	je     801eec <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801ee2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee7:	8b 40 74             	mov    0x74(%eax),%eax
  801eea:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801eec:	85 db                	test   %ebx,%ebx
  801eee:	74 0a                	je     801efa <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801ef0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef5:	8b 40 78             	mov    0x78(%eax),%eax
  801ef8:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801efa:	a1 08 40 80 00       	mov    0x804008,%eax
  801eff:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f05:	5b                   	pop    %ebx
  801f06:	5e                   	pop    %esi
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    
        *from_env_store = 0;
  801f09:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801f0f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801f15:	eb eb                	jmp    801f02 <ipc_recv+0x4c>

00801f17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	57                   	push   %edi
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	83 ec 0c             	sub    $0xc,%esp
  801f20:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801f29:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801f2b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f30:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801f33:	ff 75 14             	pushl  0x14(%ebp)
  801f36:	53                   	push   %ebx
  801f37:	56                   	push   %esi
  801f38:	57                   	push   %edi
  801f39:	e8 8a ee ff ff       	call   800dc8 <sys_ipc_try_send>
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	85 c0                	test   %eax,%eax
  801f43:	74 17                	je     801f5c <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801f45:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f48:	74 e9                	je     801f33 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801f4a:	50                   	push   %eax
  801f4b:	68 3b 28 80 00       	push   $0x80283b
  801f50:	6a 3e                	push   $0x3e
  801f52:	68 4d 28 80 00       	push   $0x80284d
  801f57:	e8 ec e1 ff ff       	call   800148 <_panic>
        }
    }
}
  801f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f6a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f72:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f78:	8b 52 50             	mov    0x50(%edx),%edx
  801f7b:	39 ca                	cmp    %ecx,%edx
  801f7d:	74 11                	je     801f90 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f7f:	83 c0 01             	add    $0x1,%eax
  801f82:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f87:	75 e6                	jne    801f6f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8e:	eb 0b                	jmp    801f9b <ipc_find_env+0x37>
			return envs[i].env_id;
  801f90:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f93:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f98:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa3:	89 d0                	mov    %edx,%eax
  801fa5:	c1 e8 16             	shr    $0x16,%eax
  801fa8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801faf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb4:	f6 c1 01             	test   $0x1,%cl
  801fb7:	74 1d                	je     801fd6 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fb9:	c1 ea 0c             	shr    $0xc,%edx
  801fbc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc3:	f6 c2 01             	test   $0x1,%dl
  801fc6:	74 0e                	je     801fd6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc8:	c1 ea 0c             	shr    $0xc,%edx
  801fcb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fd2:	ef 
  801fd3:	0f b7 c0             	movzwl %ax,%eax
}
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801feb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ff7:	85 d2                	test   %edx,%edx
  801ff9:	75 35                	jne    802030 <__udivdi3+0x50>
  801ffb:	39 f3                	cmp    %esi,%ebx
  801ffd:	0f 87 bd 00 00 00    	ja     8020c0 <__udivdi3+0xe0>
  802003:	85 db                	test   %ebx,%ebx
  802005:	89 d9                	mov    %ebx,%ecx
  802007:	75 0b                	jne    802014 <__udivdi3+0x34>
  802009:	b8 01 00 00 00       	mov    $0x1,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f3                	div    %ebx
  802012:	89 c1                	mov    %eax,%ecx
  802014:	31 d2                	xor    %edx,%edx
  802016:	89 f0                	mov    %esi,%eax
  802018:	f7 f1                	div    %ecx
  80201a:	89 c6                	mov    %eax,%esi
  80201c:	89 e8                	mov    %ebp,%eax
  80201e:	89 f7                	mov    %esi,%edi
  802020:	f7 f1                	div    %ecx
  802022:	89 fa                	mov    %edi,%edx
  802024:	83 c4 1c             	add    $0x1c,%esp
  802027:	5b                   	pop    %ebx
  802028:	5e                   	pop    %esi
  802029:	5f                   	pop    %edi
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    
  80202c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 f2                	cmp    %esi,%edx
  802032:	77 7c                	ja     8020b0 <__udivdi3+0xd0>
  802034:	0f bd fa             	bsr    %edx,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0xf8>
  802040:	89 f9                	mov    %edi,%ecx
  802042:	b8 20 00 00 00       	mov    $0x20,%eax
  802047:	29 f8                	sub    %edi,%eax
  802049:	d3 e2                	shl    %cl,%edx
  80204b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80204f:	89 c1                	mov    %eax,%ecx
  802051:	89 da                	mov    %ebx,%edx
  802053:	d3 ea                	shr    %cl,%edx
  802055:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802059:	09 d1                	or     %edx,%ecx
  80205b:	89 f2                	mov    %esi,%edx
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e3                	shl    %cl,%ebx
  802065:	89 c1                	mov    %eax,%ecx
  802067:	d3 ea                	shr    %cl,%edx
  802069:	89 f9                	mov    %edi,%ecx
  80206b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80206f:	d3 e6                	shl    %cl,%esi
  802071:	89 eb                	mov    %ebp,%ebx
  802073:	89 c1                	mov    %eax,%ecx
  802075:	d3 eb                	shr    %cl,%ebx
  802077:	09 de                	or     %ebx,%esi
  802079:	89 f0                	mov    %esi,%eax
  80207b:	f7 74 24 08          	divl   0x8(%esp)
  80207f:	89 d6                	mov    %edx,%esi
  802081:	89 c3                	mov    %eax,%ebx
  802083:	f7 64 24 0c          	mull   0xc(%esp)
  802087:	39 d6                	cmp    %edx,%esi
  802089:	72 0c                	jb     802097 <__udivdi3+0xb7>
  80208b:	89 f9                	mov    %edi,%ecx
  80208d:	d3 e5                	shl    %cl,%ebp
  80208f:	39 c5                	cmp    %eax,%ebp
  802091:	73 5d                	jae    8020f0 <__udivdi3+0x110>
  802093:	39 d6                	cmp    %edx,%esi
  802095:	75 59                	jne    8020f0 <__udivdi3+0x110>
  802097:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80209a:	31 ff                	xor    %edi,%edi
  80209c:	89 fa                	mov    %edi,%edx
  80209e:	83 c4 1c             	add    $0x1c,%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5f                   	pop    %edi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    
  8020a6:	8d 76 00             	lea    0x0(%esi),%esi
  8020a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020b0:	31 ff                	xor    %edi,%edi
  8020b2:	31 c0                	xor    %eax,%eax
  8020b4:	89 fa                	mov    %edi,%edx
  8020b6:	83 c4 1c             	add    $0x1c,%esp
  8020b9:	5b                   	pop    %ebx
  8020ba:	5e                   	pop    %esi
  8020bb:	5f                   	pop    %edi
  8020bc:	5d                   	pop    %ebp
  8020bd:	c3                   	ret    
  8020be:	66 90                	xchg   %ax,%ax
  8020c0:	31 ff                	xor    %edi,%edi
  8020c2:	89 e8                	mov    %ebp,%eax
  8020c4:	89 f2                	mov    %esi,%edx
  8020c6:	f7 f3                	div    %ebx
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	39 f2                	cmp    %esi,%edx
  8020da:	72 06                	jb     8020e2 <__udivdi3+0x102>
  8020dc:	31 c0                	xor    %eax,%eax
  8020de:	39 eb                	cmp    %ebp,%ebx
  8020e0:	77 d2                	ja     8020b4 <__udivdi3+0xd4>
  8020e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e7:	eb cb                	jmp    8020b4 <__udivdi3+0xd4>
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	31 ff                	xor    %edi,%edi
  8020f4:	eb be                	jmp    8020b4 <__udivdi3+0xd4>
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80210b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80210f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 ed                	test   %ebp,%ebp
  802119:	89 f0                	mov    %esi,%eax
  80211b:	89 da                	mov    %ebx,%edx
  80211d:	75 19                	jne    802138 <__umoddi3+0x38>
  80211f:	39 df                	cmp    %ebx,%edi
  802121:	0f 86 b1 00 00 00    	jbe    8021d8 <__umoddi3+0xd8>
  802127:	f7 f7                	div    %edi
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	39 dd                	cmp    %ebx,%ebp
  80213a:	77 f1                	ja     80212d <__umoddi3+0x2d>
  80213c:	0f bd cd             	bsr    %ebp,%ecx
  80213f:	83 f1 1f             	xor    $0x1f,%ecx
  802142:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802146:	0f 84 b4 00 00 00    	je     802200 <__umoddi3+0x100>
  80214c:	b8 20 00 00 00       	mov    $0x20,%eax
  802151:	89 c2                	mov    %eax,%edx
  802153:	8b 44 24 04          	mov    0x4(%esp),%eax
  802157:	29 c2                	sub    %eax,%edx
  802159:	89 c1                	mov    %eax,%ecx
  80215b:	89 f8                	mov    %edi,%eax
  80215d:	d3 e5                	shl    %cl,%ebp
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802165:	d3 e8                	shr    %cl,%eax
  802167:	09 c5                	or     %eax,%ebp
  802169:	8b 44 24 04          	mov    0x4(%esp),%eax
  80216d:	89 c1                	mov    %eax,%ecx
  80216f:	d3 e7                	shl    %cl,%edi
  802171:	89 d1                	mov    %edx,%ecx
  802173:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802177:	89 df                	mov    %ebx,%edi
  802179:	d3 ef                	shr    %cl,%edi
  80217b:	89 c1                	mov    %eax,%ecx
  80217d:	89 f0                	mov    %esi,%eax
  80217f:	d3 e3                	shl    %cl,%ebx
  802181:	89 d1                	mov    %edx,%ecx
  802183:	89 fa                	mov    %edi,%edx
  802185:	d3 e8                	shr    %cl,%eax
  802187:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80218c:	09 d8                	or     %ebx,%eax
  80218e:	f7 f5                	div    %ebp
  802190:	d3 e6                	shl    %cl,%esi
  802192:	89 d1                	mov    %edx,%ecx
  802194:	f7 64 24 08          	mull   0x8(%esp)
  802198:	39 d1                	cmp    %edx,%ecx
  80219a:	89 c3                	mov    %eax,%ebx
  80219c:	89 d7                	mov    %edx,%edi
  80219e:	72 06                	jb     8021a6 <__umoddi3+0xa6>
  8021a0:	75 0e                	jne    8021b0 <__umoddi3+0xb0>
  8021a2:	39 c6                	cmp    %eax,%esi
  8021a4:	73 0a                	jae    8021b0 <__umoddi3+0xb0>
  8021a6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8021aa:	19 ea                	sbb    %ebp,%edx
  8021ac:	89 d7                	mov    %edx,%edi
  8021ae:	89 c3                	mov    %eax,%ebx
  8021b0:	89 ca                	mov    %ecx,%edx
  8021b2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021b7:	29 de                	sub    %ebx,%esi
  8021b9:	19 fa                	sbb    %edi,%edx
  8021bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	d3 e0                	shl    %cl,%eax
  8021c3:	89 d9                	mov    %ebx,%ecx
  8021c5:	d3 ee                	shr    %cl,%esi
  8021c7:	d3 ea                	shr    %cl,%edx
  8021c9:	09 f0                	or     %esi,%eax
  8021cb:	83 c4 1c             	add    $0x1c,%esp
  8021ce:	5b                   	pop    %ebx
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	90                   	nop
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	85 ff                	test   %edi,%edi
  8021da:	89 f9                	mov    %edi,%ecx
  8021dc:	75 0b                	jne    8021e9 <__umoddi3+0xe9>
  8021de:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f7                	div    %edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 d8                	mov    %ebx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f1                	div    %ecx
  8021ef:	89 f0                	mov    %esi,%eax
  8021f1:	f7 f1                	div    %ecx
  8021f3:	e9 31 ff ff ff       	jmp    802129 <__umoddi3+0x29>
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 dd                	cmp    %ebx,%ebp
  802202:	72 08                	jb     80220c <__umoddi3+0x10c>
  802204:	39 f7                	cmp    %esi,%edi
  802206:	0f 87 21 ff ff ff    	ja     80212d <__umoddi3+0x2d>
  80220c:	89 da                	mov    %ebx,%edx
  80220e:	89 f0                	mov    %esi,%eax
  802210:	29 f8                	sub    %edi,%eax
  802212:	19 ea                	sbb    %ebp,%edx
  802214:	e9 14 ff ff ff       	jmp    80212d <__umoddi3+0x2d>
