
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 6b 11 00 00       	call   8011b7 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 40 22 80 00       	push   $0x802240
  800060:	e8 ce 01 00 00       	call   800233 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 d8 0f 00 00       	call   801042 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 30                	js     8000a3 <primeproc+0x70>
		panic("fork: %e", id);
	if (id == 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	74 c8                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800077:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	6a 00                	push   $0x0
  80007f:	6a 00                	push   $0x0
  800081:	56                   	push   %esi
  800082:	e8 30 11 00 00       	call   8011b7 <ipc_recv>
  800087:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800089:	99                   	cltd   
  80008a:	f7 fb                	idiv   %ebx
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	85 d2                	test   %edx,%edx
  800091:	74 e7                	je     80007a <primeproc+0x47>
			ipc_send(id, i, 0, 0);
  800093:	6a 00                	push   $0x0
  800095:	6a 00                	push   $0x0
  800097:	51                   	push   %ecx
  800098:	57                   	push   %edi
  800099:	e8 7a 11 00 00       	call   801218 <ipc_send>
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	eb d7                	jmp    80007a <primeproc+0x47>
		panic("fork: %e", id);
  8000a3:	50                   	push   %eax
  8000a4:	68 4c 22 80 00       	push   $0x80224c
  8000a9:	6a 1a                	push   $0x1a
  8000ab:	68 55 22 80 00       	push   $0x802255
  8000b0:	e8 a3 00 00 00       	call   800158 <_panic>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 83 0f 00 00       	call   801042 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1c                	js     8000e1 <umain+0x2c>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	74 25                	je     8000f3 <umain+0x3e>
		ipc_send(id, i, 0, 0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	6a 00                	push   $0x0
  8000d2:	53                   	push   %ebx
  8000d3:	56                   	push   %esi
  8000d4:	e8 3f 11 00 00       	call   801218 <ipc_send>
	for (i = 2; ; i++)
  8000d9:	83 c3 01             	add    $0x1,%ebx
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	eb ed                	jmp    8000ce <umain+0x19>
		panic("fork: %e", id);
  8000e1:	50                   	push   %eax
  8000e2:	68 4c 22 80 00       	push   $0x80224c
  8000e7:	6a 2d                	push   $0x2d
  8000e9:	68 55 22 80 00       	push   $0x802255
  8000ee:	e8 65 00 00 00       	call   800158 <_panic>
		primeproc();
  8000f3:	e8 3b ff ff ff       	call   800033 <primeproc>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 05 0b 00 00       	call   800c0d <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 2b 13 00 00       	call   801474 <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 79 0a 00 00       	call   800bcc <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 a2 0a 00 00       	call   800c0d <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 70 22 80 00       	push   $0x802270
  80017b:	e8 b3 00 00 00       	call   800233 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 56 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 44 28 80 00 	movl   $0x802844,(%esp)
  800193:	e8 9b 00 00 00       	call   800233 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	74 09                	je     8001c6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	68 ff 00 00 00       	push   $0xff
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	e8 b8 09 00 00       	call   800b8f <sys_cputs>
		b->idx = 0;
  8001d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001dd:	83 c4 10             	add    $0x10,%esp
  8001e0:	eb db                	jmp    8001bd <putch+0x1f>

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	68 9e 01 80 00       	push   $0x80019e
  800211:	e8 1a 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	83 c4 08             	add    $0x8,%esp
  800219:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	e8 64 09 00 00       	call   800b8f <sys_cputs>

	return b.cnt;
}
  80022b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 9d ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 1c             	sub    $0x1c,%esp
  800250:	89 c7                	mov    %eax,%edi
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026e:	39 d3                	cmp    %edx,%ebx
  800270:	72 05                	jb     800277 <printnum+0x30>
  800272:	39 45 10             	cmp    %eax,0x10(%ebp)
  800275:	77 7a                	ja     8002f1 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	8b 45 14             	mov    0x14(%ebp),%eax
  800280:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800283:	53                   	push   %ebx
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 55 1d 00 00       	call   801ff0 <__udivdi3>
  80029b:	83 c4 18             	add    $0x18,%esp
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	89 f2                	mov    %esi,%edx
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	e8 9e ff ff ff       	call   800247 <printnum>
  8002a9:	83 c4 20             	add    $0x20,%esp
  8002ac:	eb 13                	jmp    8002c1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f ed                	jg     8002ae <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d4:	e8 37 1e 00 00       	call   802110 <__umoddi3>
  8002d9:	83 c4 14             	add    $0x14,%esp
  8002dc:	0f be 80 93 22 80 00 	movsbl 0x802293(%eax),%eax
  8002e3:	50                   	push   %eax
  8002e4:	ff d7                	call   *%edi
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    
  8002f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f4:	eb c4                	jmp    8002ba <printnum+0x73>

008002f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1b>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	57                   	push   %edi
  800334:	56                   	push   %esi
  800335:	53                   	push   %ebx
  800336:	83 ec 2c             	sub    $0x2c,%esp
  800339:	8b 75 08             	mov    0x8(%ebp),%esi
  80033c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800342:	e9 c1 03 00 00       	jmp    800708 <vprintfmt+0x3d8>
		padc = ' ';
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8d 47 01             	lea    0x1(%edi),%eax
  800368:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036b:	0f b6 17             	movzbl (%edi),%edx
  80036e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800371:	3c 55                	cmp    $0x55,%al
  800373:	0f 87 12 04 00 00    	ja     80078b <vprintfmt+0x45b>
  800379:	0f b6 c0             	movzbl %al,%eax
  80037c:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800386:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80038a:	eb d9                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80038f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800393:	eb d0                	jmp    800365 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	77 55                	ja     80040a <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 40 04             	lea    0x4(%eax),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d2:	79 91                	jns    800365 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	eb 82                	jmp    800365 <vprintfmt+0x35>
  8003e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ed:	0f 49 d0             	cmovns %eax,%edx
  8003f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f6:	e9 6a ff ff ff       	jmp    800365 <vprintfmt+0x35>
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800405:	e9 5b ff ff ff       	jmp    800365 <vprintfmt+0x35>
  80040a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800410:	eb bc                	jmp    8003ce <vprintfmt+0x9e>
			lflag++;
  800412:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800418:	e9 48 ff ff ff       	jmp    800365 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 78 04             	lea    0x4(%eax),%edi
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	53                   	push   %ebx
  800427:	ff 30                	pushl  (%eax)
  800429:	ff d6                	call   *%esi
			break;
  80042b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80042e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800431:	e9 cf 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 78 04             	lea    0x4(%eax),%edi
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	99                   	cltd   
  80043f:	31 d0                	xor    %edx,%eax
  800441:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800443:	83 f8 0f             	cmp    $0xf,%eax
  800446:	7f 23                	jg     80046b <vprintfmt+0x13b>
  800448:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  80044f:	85 d2                	test   %edx,%edx
  800451:	74 18                	je     80046b <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800453:	52                   	push   %edx
  800454:	68 d1 27 80 00       	push   $0x8027d1
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	e8 b3 fe ff ff       	call   800313 <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800463:	89 7d 14             	mov    %edi,0x14(%ebp)
  800466:	e9 9a 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80046b:	50                   	push   %eax
  80046c:	68 ab 22 80 00       	push   $0x8022ab
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 9b fe ff ff       	call   800313 <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 82 02 00 00       	jmp    800705 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	83 c0 04             	add    $0x4,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800491:	85 ff                	test   %edi,%edi
  800493:	b8 a4 22 80 00       	mov    $0x8022a4,%eax
  800498:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e bd 00 00 00    	jle    800562 <vprintfmt+0x232>
  8004a5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a9:	75 0e                	jne    8004b9 <vprintfmt+0x189>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	eb 6d                	jmp    800526 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004bf:	57                   	push   %edi
  8004c0:	e8 6e 03 00 00       	call   800833 <strnlen>
  8004c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c8:	29 c1                	sub    %eax,%ecx
  8004ca:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004da:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dc:	eb 0f                	jmp    8004ed <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ef 01             	sub    $0x1,%edi
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 ff                	test   %edi,%edi
  8004ef:	7f ed                	jg     8004de <vprintfmt+0x1ae>
  8004f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004f7:	85 c9                	test   %ecx,%ecx
  8004f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fe:	0f 49 c1             	cmovns %ecx,%eax
  800501:	29 c1                	sub    %eax,%ecx
  800503:	89 75 08             	mov    %esi,0x8(%ebp)
  800506:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800509:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050c:	89 cb                	mov    %ecx,%ebx
  80050e:	eb 16                	jmp    800526 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	75 31                	jne    800547 <vprintfmt+0x217>
					putch(ch, putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 0c             	pushl  0xc(%ebp)
  80051c:	50                   	push   %eax
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800523:	83 eb 01             	sub    $0x1,%ebx
  800526:	83 c7 01             	add    $0x1,%edi
  800529:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80052d:	0f be c2             	movsbl %dl,%eax
  800530:	85 c0                	test   %eax,%eax
  800532:	74 59                	je     80058d <vprintfmt+0x25d>
  800534:	85 f6                	test   %esi,%esi
  800536:	78 d8                	js     800510 <vprintfmt+0x1e0>
  800538:	83 ee 01             	sub    $0x1,%esi
  80053b:	79 d3                	jns    800510 <vprintfmt+0x1e0>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	eb 37                	jmp    80057e <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	0f be d2             	movsbl %dl,%edx
  80054a:	83 ea 20             	sub    $0x20,%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 c4                	jbe    800516 <vprintfmt+0x1e6>
					putch('?', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	6a 3f                	push   $0x3f
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb c1                	jmp    800523 <vprintfmt+0x1f3>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	eb b6                	jmp    800526 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 20                	push   $0x20
  800576:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ee                	jg     800570 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800582:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
  800588:	e9 78 01 00 00       	jmp    800705 <vprintfmt+0x3d5>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb e7                	jmp    80057e <vprintfmt+0x24e>
	if (lflag >= 2)
  800597:	83 f9 01             	cmp    $0x1,%ecx
  80059a:	7e 3f                	jle    8005db <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 40 08             	lea    0x8(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b7:	79 5c                	jns    800615 <vprintfmt+0x2e5>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c7:	f7 da                	neg    %edx
  8005c9:	83 d1 00             	adc    $0x0,%ecx
  8005cc:	f7 d9                	neg    %ecx
  8005ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d6:	e9 10 01 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  8005db:	85 c9                	test   %ecx,%ecx
  8005dd:	75 1b                	jne    8005fa <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 c1                	mov    %eax,%ecx
  8005e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f8:	eb b9                	jmp    8005b3 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
  800613:	eb 9e                	jmp    8005b3 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800615:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800618:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 c6 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800625:	83 f9 01             	cmp    $0x1,%ecx
  800628:	7e 18                	jle    800642 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	8b 48 04             	mov    0x4(%eax),%ecx
  800632:	8d 40 08             	lea    0x8(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 a9 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800642:	85 c9                	test   %ecx,%ecx
  800644:	75 1a                	jne    800660 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800650:	8d 40 04             	lea    0x4(%eax),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 8b 00 00 00       	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 10                	mov    (%eax),%edx
  800665:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066a:	8d 40 04             	lea    0x4(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
  800675:	eb 74                	jmp    8006eb <vprintfmt+0x3bb>
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 15                	jle    800691 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
  80068f:	eb 5a                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800691:	85 c9                	test   %ecx,%ecx
  800693:	75 17                	jne    8006ac <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069f:	8d 40 04             	lea    0x4(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006aa:	eb 3f                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006bc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c1:	eb 28                	jmp    8006eb <vprintfmt+0x3bb>
			putch('0', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 30                	push   $0x30
  8006c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006cb:	83 c4 08             	add    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 78                	push   $0x78
  8006d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006dd:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006eb:	83 ec 0c             	sub    $0xc,%esp
  8006ee:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006f2:	57                   	push   %edi
  8006f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f6:	50                   	push   %eax
  8006f7:	51                   	push   %ecx
  8006f8:	52                   	push   %edx
  8006f9:	89 da                	mov    %ebx,%edx
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	e8 45 fb ff ff       	call   800247 <printnum>
			break;
  800702:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800708:	83 c7 01             	add    $0x1,%edi
  80070b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070f:	83 f8 25             	cmp    $0x25,%eax
  800712:	0f 84 2f fc ff ff    	je     800347 <vprintfmt+0x17>
			if (ch == '\0')
  800718:	85 c0                	test   %eax,%eax
  80071a:	0f 84 8b 00 00 00    	je     8007ab <vprintfmt+0x47b>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	50                   	push   %eax
  800725:	ff d6                	call   *%esi
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb dc                	jmp    800708 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80072c:	83 f9 01             	cmp    $0x1,%ecx
  80072f:	7e 15                	jle    800746 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	8b 48 04             	mov    0x4(%eax),%ecx
  800739:	8d 40 08             	lea    0x8(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
  800744:	eb a5                	jmp    8006eb <vprintfmt+0x3bb>
	else if (lflag)
  800746:	85 c9                	test   %ecx,%ecx
  800748:	75 17                	jne    800761 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
  80075f:	eb 8a                	jmp    8006eb <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 10                	mov    (%eax),%edx
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	b8 10 00 00 00       	mov    $0x10,%eax
  800776:	e9 70 ff ff ff       	jmp    8006eb <vprintfmt+0x3bb>
			putch(ch, putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 25                	push   $0x25
  800781:	ff d6                	call   *%esi
			break;
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	e9 7a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
			putch('%', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 25                	push   $0x25
  800791:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	89 f8                	mov    %edi,%eax
  800798:	eb 03                	jmp    80079d <vprintfmt+0x46d>
  80079a:	83 e8 01             	sub    $0x1,%eax
  80079d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a1:	75 f7                	jne    80079a <vprintfmt+0x46a>
  8007a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a6:	e9 5a ff ff ff       	jmp    800705 <vprintfmt+0x3d5>
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	83 ec 18             	sub    $0x18,%esp
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	74 26                	je     8007fa <vsnprintf+0x47>
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	7e 22                	jle    8007fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d8:	ff 75 14             	pushl  0x14(%ebp)
  8007db:	ff 75 10             	pushl  0x10(%ebp)
  8007de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	68 f6 02 80 00       	push   $0x8002f6
  8007e7:	e8 44 fb ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    
		return -E_INVAL;
  8007fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ff:	eb f7                	jmp    8007f8 <vsnprintf+0x45>

00800801 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800807:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080a:	50                   	push   %eax
  80080b:	ff 75 10             	pushl  0x10(%ebp)
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	ff 75 08             	pushl  0x8(%ebp)
  800814:	e8 9a ff ff ff       	call   8007b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
  800826:	eb 03                	jmp    80082b <strlen+0x10>
		n++;
  800828:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	75 f7                	jne    800828 <strlen+0xd>
	return n;
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
  800841:	eb 03                	jmp    800846 <strnlen+0x13>
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 d0                	cmp    %edx,%eax
  800848:	74 06                	je     800850 <strnlen+0x1d>
  80084a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x10>
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	53                   	push   %ebx
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	83 c1 01             	add    $0x1,%ecx
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086b:	84 db                	test   %bl,%bl
  80086d:	75 ef                	jne    80085e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800879:	53                   	push   %ebx
  80087a:	e8 9c ff ff ff       	call   80081b <strlen>
  80087f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	01 d8                	add    %ebx,%eax
  800887:	50                   	push   %eax
  800888:	e8 c5 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80088d:	89 d8                	mov    %ebx,%eax
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089f:	89 f3                	mov    %esi,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	89 f2                	mov    %esi,%edx
  8008a6:	eb 0f                	jmp    8008b7 <strncpy+0x23>
		*dst++ = *src;
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b1:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b7:	39 da                	cmp    %ebx,%edx
  8008b9:	75 ed                	jne    8008a8 <strncpy+0x14>
	}
	return ret;
}
  8008bb:	89 f0                	mov    %esi,%eax
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	75 0b                	jne    8008e4 <strlcpy+0x23>
  8008d9:	eb 17                	jmp    8008f2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008db:	83 c2 01             	add    $0x1,%edx
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e4:	39 d8                	cmp    %ebx,%eax
  8008e6:	74 07                	je     8008ef <strlcpy+0x2e>
  8008e8:	0f b6 0a             	movzbl (%edx),%ecx
  8008eb:	84 c9                	test   %cl,%cl
  8008ed:	75 ec                	jne    8008db <strlcpy+0x1a>
		*dst = '\0';
  8008ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f2:	29 f0                	sub    %esi,%eax
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800901:	eb 06                	jmp    800909 <strcmp+0x11>
		p++, q++;
  800903:	83 c1 01             	add    $0x1,%ecx
  800906:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	84 c0                	test   %al,%al
  80090e:	74 04                	je     800914 <strcmp+0x1c>
  800910:	3a 02                	cmp    (%edx),%al
  800912:	74 ef                	je     800903 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800914:	0f b6 c0             	movzbl %al,%eax
  800917:	0f b6 12             	movzbl (%edx),%edx
  80091a:	29 d0                	sub    %edx,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	89 c3                	mov    %eax,%ebx
  80092a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strncmp+0x17>
		n--, p++, q++;
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800935:	39 d8                	cmp    %ebx,%eax
  800937:	74 16                	je     80094f <strncmp+0x31>
  800939:	0f b6 08             	movzbl (%eax),%ecx
  80093c:	84 c9                	test   %cl,%cl
  80093e:	74 04                	je     800944 <strncmp+0x26>
  800940:	3a 0a                	cmp    (%edx),%cl
  800942:	74 eb                	je     80092f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	0f b6 00             	movzbl (%eax),%eax
  800947:	0f b6 12             	movzbl (%edx),%edx
  80094a:	29 d0                	sub    %edx,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb f6                	jmp    80094c <strncmp+0x2e>

00800956 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	84 d2                	test   %dl,%dl
  800965:	74 09                	je     800970 <strchr+0x1a>
		if (*s == c)
  800967:	38 ca                	cmp    %cl,%dl
  800969:	74 0a                	je     800975 <strchr+0x1f>
	for (; *s; s++)
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	eb f0                	jmp    800960 <strchr+0xa>
			return (char *) s;
	return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800981:	eb 03                	jmp    800986 <strfind+0xf>
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 04                	je     800991 <strfind+0x1a>
  80098d:	84 d2                	test   %dl,%dl
  80098f:	75 f2                	jne    800983 <strfind+0xc>
			break;
	return (char *) s;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	57                   	push   %edi
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099f:	85 c9                	test   %ecx,%ecx
  8009a1:	74 13                	je     8009b6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a9:	75 05                	jne    8009b0 <memset+0x1d>
  8009ab:	f6 c1 03             	test   $0x3,%cl
  8009ae:	74 0d                	je     8009bd <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    
		c &= 0xFF;
  8009bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d0                	mov    %edx,%eax
  8009c8:	c1 e0 18             	shl    $0x18,%eax
  8009cb:	89 d6                	mov    %edx,%esi
  8009cd:	c1 e6 10             	shl    $0x10,%esi
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
  8009d4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb d6                	jmp    8009b6 <memset+0x23>

008009e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ee:	39 c6                	cmp    %eax,%esi
  8009f0:	73 35                	jae    800a27 <memmove+0x47>
  8009f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f5:	39 c2                	cmp    %eax,%edx
  8009f7:	76 2e                	jbe    800a27 <memmove+0x47>
		s += n;
		d += n;
  8009f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	89 d6                	mov    %edx,%esi
  8009fe:	09 fe                	or     %edi,%esi
  800a00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a06:	74 0c                	je     800a14 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a08:	83 ef 01             	sub    $0x1,%edi
  800a0b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0e:	fd                   	std    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a11:	fc                   	cld    
  800a12:	eb 21                	jmp    800a35 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	f6 c1 03             	test   $0x3,%cl
  800a17:	75 ef                	jne    800a08 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a19:	83 ef 04             	sub    $0x4,%edi
  800a1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a22:	fd                   	std    
  800a23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a25:	eb ea                	jmp    800a11 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	89 f2                	mov    %esi,%edx
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	f6 c2 03             	test   $0x3,%dl
  800a2e:	74 09                	je     800a39 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a30:	89 c7                	mov    %eax,%edi
  800a32:	fc                   	cld    
  800a33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a39:	f6 c1 03             	test   $0x3,%cl
  800a3c:	75 f2                	jne    800a30 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	fc                   	cld    
  800a44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a46:	eb ed                	jmp    800a35 <memmove+0x55>

00800a48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4b:	ff 75 10             	pushl  0x10(%ebp)
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	ff 75 08             	pushl  0x8(%ebp)
  800a54:	e8 87 ff ff ff       	call   8009e0 <memmove>
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a66:	89 c6                	mov    %eax,%esi
  800a68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6b:	39 f0                	cmp    %esi,%eax
  800a6d:	74 1c                	je     800a8b <memcmp+0x30>
		if (*s1 != *s2)
  800a6f:	0f b6 08             	movzbl (%eax),%ecx
  800a72:	0f b6 1a             	movzbl (%edx),%ebx
  800a75:	38 d9                	cmp    %bl,%cl
  800a77:	75 08                	jne    800a81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a79:	83 c0 01             	add    $0x1,%eax
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	eb ea                	jmp    800a6b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c1             	movzbl %cl,%eax
  800a84:	0f b6 db             	movzbl %bl,%ebx
  800a87:	29 d8                	sub    %ebx,%eax
  800a89:	eb 05                	jmp    800a90 <memcmp+0x35>
	}

	return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa2:	39 d0                	cmp    %edx,%eax
  800aa4:	73 09                	jae    800aaf <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa6:	38 08                	cmp    %cl,(%eax)
  800aa8:	74 05                	je     800aaf <memfind+0x1b>
	for (; s < ends; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	eb f3                	jmp    800aa2 <memfind+0xe>
			break;
	return (void *) s;
}
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	57                   	push   %edi
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abd:	eb 03                	jmp    800ac2 <strtol+0x11>
		s++;
  800abf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac2:	0f b6 01             	movzbl (%ecx),%eax
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f6                	je     800abf <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f2                	je     800abf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	74 2e                	je     800aff <strtol+0x4e>
	int neg = 0;
  800ad1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad6:	3c 2d                	cmp    $0x2d,%al
  800ad8:	74 2f                	je     800b09 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ada:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae0:	75 05                	jne    800ae7 <strtol+0x36>
  800ae2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae5:	74 2c                	je     800b13 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae7:	85 db                	test   %ebx,%ebx
  800ae9:	75 0a                	jne    800af5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aeb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800af0:	80 39 30             	cmpb   $0x30,(%ecx)
  800af3:	74 28                	je     800b1d <strtol+0x6c>
		base = 10;
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afd:	eb 50                	jmp    800b4f <strtol+0x9e>
		s++;
  800aff:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b02:	bf 00 00 00 00       	mov    $0x0,%edi
  800b07:	eb d1                	jmp    800ada <strtol+0x29>
		s++, neg = 1;
  800b09:	83 c1 01             	add    $0x1,%ecx
  800b0c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b11:	eb c7                	jmp    800ada <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b13:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b17:	74 0e                	je     800b27 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	75 d8                	jne    800af5 <strtol+0x44>
		s++, base = 8;
  800b1d:	83 c1 01             	add    $0x1,%ecx
  800b20:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b25:	eb ce                	jmp    800af5 <strtol+0x44>
		s += 2, base = 16;
  800b27:	83 c1 02             	add    $0x2,%ecx
  800b2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2f:	eb c4                	jmp    800af5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b31:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b34:	89 f3                	mov    %esi,%ebx
  800b36:	80 fb 19             	cmp    $0x19,%bl
  800b39:	77 29                	ja     800b64 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3b:	0f be d2             	movsbl %dl,%edx
  800b3e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b41:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b44:	7d 30                	jge    800b76 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b46:	83 c1 01             	add    $0x1,%ecx
  800b49:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4f:	0f b6 11             	movzbl (%ecx),%edx
  800b52:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b55:	89 f3                	mov    %esi,%ebx
  800b57:	80 fb 09             	cmp    $0x9,%bl
  800b5a:	77 d5                	ja     800b31 <strtol+0x80>
			dig = *s - '0';
  800b5c:	0f be d2             	movsbl %dl,%edx
  800b5f:	83 ea 30             	sub    $0x30,%edx
  800b62:	eb dd                	jmp    800b41 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b64:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b67:	89 f3                	mov    %esi,%ebx
  800b69:	80 fb 19             	cmp    $0x19,%bl
  800b6c:	77 08                	ja     800b76 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6e:	0f be d2             	movsbl %dl,%edx
  800b71:	83 ea 37             	sub    $0x37,%edx
  800b74:	eb cb                	jmp    800b41 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7a:	74 05                	je     800b81 <strtol+0xd0>
		*endptr = (char *) s;
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	f7 da                	neg    %edx
  800b85:	85 ff                	test   %edi,%edi
  800b87:	0f 45 c2             	cmovne %edx,%eax
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba0:	89 c3                	mov    %eax,%ebx
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_cgetc>:

int
sys_cgetc(void)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbd:	89 d1                	mov    %edx,%ecx
  800bbf:	89 d3                	mov    %edx,%ebx
  800bc1:	89 d7                	mov    %edx,%edi
  800bc3:	89 d6                	mov    %edx,%esi
  800bc5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	89 cb                	mov    %ecx,%ebx
  800be4:	89 cf                	mov    %ecx,%edi
  800be6:	89 ce                	mov    %ecx,%esi
  800be8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7f 08                	jg     800bf6 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 03                	push   $0x3
  800bfc:	68 9f 25 80 00       	push   $0x80259f
  800c01:	6a 23                	push   $0x23
  800c03:	68 bc 25 80 00       	push   $0x8025bc
  800c08:	e8 4b f5 ff ff       	call   800158 <_panic>

00800c0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
  800c18:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1d:	89 d1                	mov    %edx,%ecx
  800c1f:	89 d3                	mov    %edx,%ebx
  800c21:	89 d7                	mov    %edx,%edi
  800c23:	89 d6                	mov    %edx,%esi
  800c25:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_yield>:

void
sys_yield(void)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3c:	89 d1                	mov    %edx,%ecx
  800c3e:	89 d3                	mov    %edx,%ebx
  800c40:	89 d7                	mov    %edx,%edi
  800c42:	89 d6                	mov    %edx,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	be 00 00 00 00       	mov    $0x0,%esi
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c67:	89 f7                	mov    %esi,%edi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 04                	push   $0x4
  800c7d:	68 9f 25 80 00       	push   $0x80259f
  800c82:	6a 23                	push   $0x23
  800c84:	68 bc 25 80 00       	push   $0x8025bc
  800c89:	e8 ca f4 ff ff       	call   800158 <_panic>

00800c8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 05                	push   $0x5
  800cbf:	68 9f 25 80 00       	push   $0x80259f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 bc 25 80 00       	push   $0x8025bc
  800ccb:	e8 88 f4 ff ff       	call   800158 <_panic>

00800cd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce9:	89 df                	mov    %ebx,%edi
  800ceb:	89 de                	mov    %ebx,%esi
  800ced:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7f 08                	jg     800cfb <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 06                	push   $0x6
  800d01:	68 9f 25 80 00       	push   $0x80259f
  800d06:	6a 23                	push   $0x23
  800d08:	68 bc 25 80 00       	push   $0x8025bc
  800d0d:	e8 46 f4 ff ff       	call   800158 <_panic>

00800d12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7f 08                	jg     800d3d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 08                	push   $0x8
  800d43:	68 9f 25 80 00       	push   $0x80259f
  800d48:	6a 23                	push   $0x23
  800d4a:	68 bc 25 80 00       	push   $0x8025bc
  800d4f:	e8 04 f4 ff ff       	call   800158 <_panic>

00800d54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7f 08                	jg     800d7f <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	50                   	push   %eax
  800d83:	6a 09                	push   $0x9
  800d85:	68 9f 25 80 00       	push   $0x80259f
  800d8a:	6a 23                	push   $0x23
  800d8c:	68 bc 25 80 00       	push   $0x8025bc
  800d91:	e8 c2 f3 ff ff       	call   800158 <_panic>

00800d96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daf:	89 df                	mov    %ebx,%edi
  800db1:	89 de                	mov    %ebx,%esi
  800db3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7f 08                	jg     800dc1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	50                   	push   %eax
  800dc5:	6a 0a                	push   $0xa
  800dc7:	68 9f 25 80 00       	push   $0x80259f
  800dcc:	6a 23                	push   $0x23
  800dce:	68 bc 25 80 00       	push   $0x8025bc
  800dd3:	e8 80 f3 ff ff       	call   800158 <_panic>

00800dd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de9:	be 00 00 00 00       	mov    $0x0,%esi
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e09:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e11:	89 cb                	mov    %ecx,%ebx
  800e13:	89 cf                	mov    %ecx,%edi
  800e15:	89 ce                	mov    %ecx,%esi
  800e17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7f 08                	jg     800e25 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 0d                	push   $0xd
  800e2b:	68 9f 25 80 00       	push   $0x80259f
  800e30:	6a 23                	push   $0x23
  800e32:	68 bc 25 80 00       	push   $0x8025bc
  800e37:	e8 1c f3 ff ff       	call   800158 <_panic>

00800e3c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 04             	sub    $0x4,%esp
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e46:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800e48:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e4b:	a8 02                	test   $0x2,%al
  800e4d:	0f 84 89 00 00 00    	je     800edc <pgfault+0xa0>
  800e53:	89 da                	mov    %ebx,%edx
  800e55:	c1 ea 0c             	shr    $0xc,%edx
  800e58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e5f:	f6 c6 08             	test   $0x8,%dh
  800e62:	74 78                	je     800edc <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e64:	83 ec 04             	sub    $0x4,%esp
  800e67:	6a 07                	push   $0x7
  800e69:	68 00 f0 7f 00       	push   $0x7ff000
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 d6 fd ff ff       	call   800c4b <sys_page_alloc>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	0f 88 8b 00 00 00    	js     800f0b <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800e80:	83 ec 04             	sub    $0x4,%esp
  800e83:	68 00 10 00 00       	push   $0x1000
  800e88:	53                   	push   %ebx
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	e8 4d fb ff ff       	call   8009e0 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e93:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e9a:	53                   	push   %ebx
  800e9b:	6a 00                	push   $0x0
  800e9d:	68 00 f0 7f 00       	push   $0x7ff000
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 e5 fd ff ff       	call   800c8e <sys_page_map>
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	85 c0                	test   %eax,%eax
  800eae:	78 6d                	js     800f1d <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 11 fe ff ff       	call   800cd0 <sys_page_unmap>
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 69                	js     800f2f <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	53                   	push   %ebx
  800eca:	68 28 26 80 00       	push   $0x802628
  800ecf:	e8 5f f3 ff ff       	call   800233 <cprintf>

}
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800edc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ee2:	8b 4a 48             	mov    0x48(%edx),%ecx
  800ee5:	89 da                	mov    %ebx,%edx
  800ee7:	c1 ea 0c             	shr    $0xc,%edx
  800eea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef1:	51                   	push   %ecx
  800ef2:	53                   	push   %ebx
  800ef3:	68 00 00 40 ef       	push   $0xef400000
  800ef8:	52                   	push   %edx
  800ef9:	50                   	push   %eax
  800efa:	68 cc 25 80 00       	push   $0x8025cc
  800eff:	6a 1e                	push   $0x1e
  800f01:	68 49 26 80 00       	push   $0x802649
  800f06:	e8 4d f2 ff ff       	call   800158 <_panic>
        panic("sys_page_alloc error %e", r);
  800f0b:	50                   	push   %eax
  800f0c:	68 54 26 80 00       	push   $0x802654
  800f11:	6a 28                	push   $0x28
  800f13:	68 49 26 80 00       	push   $0x802649
  800f18:	e8 3b f2 ff ff       	call   800158 <_panic>
        panic("sys_page_map error %e", r);
  800f1d:	50                   	push   %eax
  800f1e:	68 6c 26 80 00       	push   $0x80266c
  800f23:	6a 2b                	push   $0x2b
  800f25:	68 49 26 80 00       	push   $0x802649
  800f2a:	e8 29 f2 ff ff       	call   800158 <_panic>
        panic("sys_page_unmap error %e", r);
  800f2f:	50                   	push   %eax
  800f30:	68 82 26 80 00       	push   $0x802682
  800f35:	6a 2d                	push   $0x2d
  800f37:	68 49 26 80 00       	push   $0x802649
  800f3c:	e8 17 f2 ff ff       	call   800158 <_panic>

00800f41 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f47:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800f4e:	74 23                	je     800f73 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f50:	8b 45 08             	mov    0x8(%ebp),%eax
  800f53:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800f58:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5d:	8b 40 48             	mov    0x48(%eax),%eax
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	68 87 1f 80 00       	push   $0x801f87
  800f68:	50                   	push   %eax
  800f69:	e8 28 fe ff ff       	call   800d96 <sys_env_set_pgfault_upcall>
}
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f73:	a1 04 40 80 00       	mov    0x804004,%eax
  800f78:	8b 40 48             	mov    0x48(%eax),%eax
  800f7b:	83 ec 04             	sub    $0x4,%esp
  800f7e:	6a 07                	push   $0x7
  800f80:	68 00 f0 bf ee       	push   $0xeebff000
  800f85:	50                   	push   %eax
  800f86:	e8 c0 fc ff ff       	call   800c4b <sys_page_alloc>
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 be                	jns    800f50 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f92:	50                   	push   %eax
  800f93:	68 9a 26 80 00       	push   $0x80269a
  800f98:	6a 21                	push   $0x21
  800f9a:	68 ad 26 80 00       	push   $0x8026ad
  800f9f:	e8 b4 f1 ff ff       	call   800158 <_panic>

00800fa4 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800faf:	83 ec 04             	sub    $0x4,%esp
  800fb2:	6a 07                	push   $0x7
  800fb4:	53                   	push   %ebx
  800fb5:	56                   	push   %esi
  800fb6:	e8 90 fc ff ff       	call   800c4b <sys_page_alloc>
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 4a                	js     80100c <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	6a 07                	push   $0x7
  800fc7:	68 00 00 40 00       	push   $0x400000
  800fcc:	6a 00                	push   $0x0
  800fce:	53                   	push   %ebx
  800fcf:	56                   	push   %esi
  800fd0:	e8 b9 fc ff ff       	call   800c8e <sys_page_map>
  800fd5:	83 c4 20             	add    $0x20,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 42                	js     80101e <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	68 00 10 00 00       	push   $0x1000
  800fe4:	53                   	push   %ebx
  800fe5:	68 00 00 40 00       	push   $0x400000
  800fea:	e8 f1 f9 ff ff       	call   8009e0 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800fef:	83 c4 08             	add    $0x8,%esp
  800ff2:	68 00 00 40 00       	push   $0x400000
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 d2 fc ff ff       	call   800cd0 <sys_page_unmap>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 2b                	js     801030 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  801005:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  80100c:	50                   	push   %eax
  80100d:	68 9a 26 80 00       	push   $0x80269a
  801012:	6a 63                	push   $0x63
  801014:	68 49 26 80 00       	push   $0x802649
  801019:	e8 3a f1 ff ff       	call   800158 <_panic>
        panic("sys_page_map: %e", r);
  80101e:	50                   	push   %eax
  80101f:	68 bd 26 80 00       	push   $0x8026bd
  801024:	6a 65                	push   $0x65
  801026:	68 49 26 80 00       	push   $0x802649
  80102b:	e8 28 f1 ff ff       	call   800158 <_panic>
        panic("sys_page_unmap: %e", r);
  801030:	50                   	push   %eax
  801031:	68 ce 26 80 00       	push   $0x8026ce
  801036:	6a 68                	push   $0x68
  801038:	68 49 26 80 00       	push   $0x802649
  80103d:	e8 16 f1 ff ff       	call   800158 <_panic>

00801042 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  80104b:	a1 04 40 80 00       	mov    0x804004,%eax
  801050:	8b 40 64             	mov    0x64(%eax),%eax
  801053:	85 c0                	test   %eax,%eax
  801055:	74 1f                	je     801076 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801057:	b8 07 00 00 00       	mov    $0x7,%eax
  80105c:	cd 30                	int    $0x30
  80105e:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801060:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801063:	85 c0                	test   %eax,%eax
  801065:	74 21                	je     801088 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801067:	be 08 40 80 00       	mov    $0x804008,%esi
  80106c:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80106f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801074:	eb 7b                	jmp    8010f1 <fork+0xaf>
        set_pgfault_handler(pgfault);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	68 3c 0e 80 00       	push   $0x800e3c
  80107e:	e8 be fe ff ff       	call   800f41 <set_pgfault_handler>
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	eb cf                	jmp    801057 <fork+0x15>
        set_pgfault_handler(pgfault);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	68 3c 0e 80 00       	push   $0x800e3c
  801090:	e8 ac fe ff ff       	call   800f41 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801095:	e8 73 fb ff ff       	call   800c0d <sys_getenvid>
  80109a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a7:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	e9 ca 00 00 00       	jmp    80117e <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  8010b4:	89 d1                	mov    %edx,%ecx
  8010b6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  8010bc:	81 e2 02 08 00 00    	and    $0x802,%edx
  8010c2:	89 cf                	mov    %ecx,%edi
  8010c4:	81 cf 00 08 00 00    	or     $0x800,%edi
  8010ca:	85 d2                	test   %edx,%edx
  8010cc:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	51                   	push   %ecx
  8010d3:	50                   	push   %eax
  8010d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d7:	50                   	push   %eax
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 af fb ff ff       	call   800c8e <sys_page_map>
  8010df:	83 c4 20             	add    $0x20,%esp
  8010e2:	85 c0                	test   %eax,%eax
  8010e4:	78 45                	js     80112b <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8010e6:	83 c3 01             	add    $0x1,%ebx
  8010e9:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8010ef:	74 4c                	je     80113d <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8010f1:	39 de                	cmp    %ebx,%esi
  8010f3:	74 f1                	je     8010e6 <fork+0xa4>
  8010f5:	89 d8                	mov    %ebx,%eax
  8010f7:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8010fa:	89 c2                	mov    %eax,%edx
  8010fc:	c1 ea 16             	shr    $0x16,%edx
  8010ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801106:	f6 c2 05             	test   $0x5,%dl
  801109:	74 db                	je     8010e6 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  80110b:	89 c2                	mov    %eax,%edx
  80110d:	c1 ea 0c             	shr    $0xc,%edx
  801110:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801117:	f6 c2 04             	test   $0x4,%dl
  80111a:	74 ca                	je     8010e6 <fork+0xa4>
    if (perm & PTE_SHARE) {
  80111c:	f6 c6 04             	test   $0x4,%dh
  80111f:	74 93                	je     8010b4 <fork+0x72>
        perm &= ~PTE_COW;
  801121:	89 d1                	mov    %edx,%ecx
  801123:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801129:	eb a4                	jmp    8010cf <fork+0x8d>
        panic("sys_page_map error %e", r);
  80112b:	50                   	push   %eax
  80112c:	68 6c 26 80 00       	push   $0x80266c
  801131:	6a 57                	push   $0x57
  801133:	68 49 26 80 00       	push   $0x802649
  801138:	e8 1b f0 ff ff       	call   800158 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	b8 08 40 80 00       	mov    $0x804008,%eax
  801145:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114a:	50                   	push   %eax
  80114b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80114e:	e8 51 fe ff ff       	call   800fa4 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801153:	83 c4 08             	add    $0x8,%esp
  801156:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80115e:	50                   	push   %eax
  80115f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801162:	e8 3d fe ff ff       	call   800fa4 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801167:	83 c4 08             	add    $0x8,%esp
  80116a:	6a 02                	push   $0x2
  80116c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116f:	e8 9e fb ff ff       	call   800d12 <sys_env_set_status>
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	85 c0                	test   %eax,%eax
  801179:	78 0d                	js     801188 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  80117b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801183:	5b                   	pop    %ebx
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801188:	50                   	push   %eax
  801189:	68 e1 26 80 00       	push   $0x8026e1
  80118e:	68 a0 00 00 00       	push   $0xa0
  801193:	68 49 26 80 00       	push   $0x802649
  801198:	e8 bb ef ff ff       	call   800158 <_panic>

0080119d <sfork>:

// Challenge!
int
sfork(void)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a3:	68 f8 26 80 00       	push   $0x8026f8
  8011a8:	68 a9 00 00 00       	push   $0xa9
  8011ad:	68 49 26 80 00       	push   $0x802649
  8011b2:	e8 a1 ef ff ff       	call   800158 <_panic>

008011b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8011bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011cc:	0f 44 c2             	cmove  %edx,%eax
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	50                   	push   %eax
  8011d3:	e8 23 fc ff ff       	call   800dfb <sys_ipc_recv>
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 2b                	js     80120a <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  8011df:	85 f6                	test   %esi,%esi
  8011e1:	74 0a                	je     8011ed <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  8011e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e8:	8b 40 74             	mov    0x74(%eax),%eax
  8011eb:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  8011ed:	85 db                	test   %ebx,%ebx
  8011ef:	74 0a                	je     8011fb <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  8011f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f6:	8b 40 78             	mov    0x78(%eax),%eax
  8011f9:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  8011fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801200:	8b 40 70             	mov    0x70(%eax),%eax
}
  801203:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    
        *from_env_store = 0;
  80120a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801210:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801216:	eb eb                	jmp    801203 <ipc_recv+0x4c>

00801218 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	8b 7d 08             	mov    0x8(%ebp),%edi
  801224:	8b 75 0c             	mov    0xc(%ebp),%esi
  801227:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  80122a:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80122c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801231:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801234:	ff 75 14             	pushl  0x14(%ebp)
  801237:	53                   	push   %ebx
  801238:	56                   	push   %esi
  801239:	57                   	push   %edi
  80123a:	e8 99 fb ff ff       	call   800dd8 <sys_ipc_try_send>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	74 17                	je     80125d <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801246:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801249:	74 e9                	je     801234 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  80124b:	50                   	push   %eax
  80124c:	68 0e 27 80 00       	push   $0x80270e
  801251:	6a 3e                	push   $0x3e
  801253:	68 20 27 80 00       	push   $0x802720
  801258:	e8 fb ee ff ff       	call   800158 <_panic>
        }
    }
}
  80125d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801260:	5b                   	pop    %ebx
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801270:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801273:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801279:	8b 52 50             	mov    0x50(%edx),%edx
  80127c:	39 ca                	cmp    %ecx,%edx
  80127e:	74 11                	je     801291 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801280:	83 c0 01             	add    $0x1,%eax
  801283:	3d 00 04 00 00       	cmp    $0x400,%eax
  801288:	75 e6                	jne    801270 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
  80128f:	eb 0b                	jmp    80129c <ipc_find_env+0x37>
			return envs[i].env_id;
  801291:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801294:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801299:	8b 40 48             	mov    0x48(%eax),%eax
}
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012a9:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    

008012ae <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ae:	55                   	push   %ebp
  8012af:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012be:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	c1 ea 16             	shr    $0x16,%edx
  8012d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012dc:	f6 c2 01             	test   $0x1,%dl
  8012df:	74 2a                	je     80130b <fd_alloc+0x46>
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 0c             	shr    $0xc,%edx
  8012e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 19                	je     80130b <fd_alloc+0x46>
  8012f2:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012f7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012fc:	75 d2                	jne    8012d0 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801304:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801309:	eb 07                	jmp    801312 <fd_alloc+0x4d>
			*fd_store = fd;
  80130b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    

00801314 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80131a:	83 f8 1f             	cmp    $0x1f,%eax
  80131d:	77 36                	ja     801355 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80131f:	c1 e0 0c             	shl    $0xc,%eax
  801322:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801327:	89 c2                	mov    %eax,%edx
  801329:	c1 ea 16             	shr    $0x16,%edx
  80132c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801333:	f6 c2 01             	test   $0x1,%dl
  801336:	74 24                	je     80135c <fd_lookup+0x48>
  801338:	89 c2                	mov    %eax,%edx
  80133a:	c1 ea 0c             	shr    $0xc,%edx
  80133d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801344:	f6 c2 01             	test   $0x1,%dl
  801347:	74 1a                	je     801363 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801349:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134c:	89 02                	mov    %eax,(%edx)
	return 0;
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
		return -E_INVAL;
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135a:	eb f7                	jmp    801353 <fd_lookup+0x3f>
		return -E_INVAL;
  80135c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801361:	eb f0                	jmp    801353 <fd_lookup+0x3f>
  801363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801368:	eb e9                	jmp    801353 <fd_lookup+0x3f>

0080136a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801373:	ba a8 27 80 00       	mov    $0x8027a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801378:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80137d:	39 08                	cmp    %ecx,(%eax)
  80137f:	74 33                	je     8013b4 <dev_lookup+0x4a>
  801381:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801384:	8b 02                	mov    (%edx),%eax
  801386:	85 c0                	test   %eax,%eax
  801388:	75 f3                	jne    80137d <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80138a:	a1 04 40 80 00       	mov    0x804004,%eax
  80138f:	8b 40 48             	mov    0x48(%eax),%eax
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	51                   	push   %ecx
  801396:	50                   	push   %eax
  801397:	68 2c 27 80 00       	push   $0x80272c
  80139c:	e8 92 ee ff ff       	call   800233 <cprintf>
	*dev = 0;
  8013a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    
			*dev = devtab[i];
  8013b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013be:	eb f2                	jmp    8013b2 <dev_lookup+0x48>

008013c0 <fd_close>:
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	57                   	push   %edi
  8013c4:	56                   	push   %esi
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 1c             	sub    $0x1c,%esp
  8013c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013d3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013d9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013dc:	50                   	push   %eax
  8013dd:	e8 32 ff ff ff       	call   801314 <fd_lookup>
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	78 05                	js     8013f0 <fd_close+0x30>
	    || fd != fd2)
  8013eb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013ee:	74 16                	je     801406 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013f0:	89 f8                	mov    %edi,%eax
  8013f2:	84 c0                	test   %al,%al
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	0f 44 d8             	cmove  %eax,%ebx
}
  8013fc:	89 d8                	mov    %ebx,%eax
  8013fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	ff 36                	pushl  (%esi)
  80140f:	e8 56 ff ff ff       	call   80136a <dev_lookup>
  801414:	89 c3                	mov    %eax,%ebx
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 15                	js     801432 <fd_close+0x72>
		if (dev->dev_close)
  80141d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801420:	8b 40 10             	mov    0x10(%eax),%eax
  801423:	85 c0                	test   %eax,%eax
  801425:	74 1b                	je     801442 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	56                   	push   %esi
  80142b:	ff d0                	call   *%eax
  80142d:	89 c3                	mov    %eax,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	56                   	push   %esi
  801436:	6a 00                	push   $0x0
  801438:	e8 93 f8 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	eb ba                	jmp    8013fc <fd_close+0x3c>
			r = 0;
  801442:	bb 00 00 00 00       	mov    $0x0,%ebx
  801447:	eb e9                	jmp    801432 <fd_close+0x72>

00801449 <close>:

int
close(int fdnum)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	ff 75 08             	pushl  0x8(%ebp)
  801456:	e8 b9 fe ff ff       	call   801314 <fd_lookup>
  80145b:	83 c4 08             	add    $0x8,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 10                	js     801472 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	6a 01                	push   $0x1
  801467:	ff 75 f4             	pushl  -0xc(%ebp)
  80146a:	e8 51 ff ff ff       	call   8013c0 <fd_close>
  80146f:	83 c4 10             	add    $0x10,%esp
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <close_all>:

void
close_all(void)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80147b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	53                   	push   %ebx
  801484:	e8 c0 ff ff ff       	call   801449 <close>
	for (i = 0; i < MAXFD; i++)
  801489:	83 c3 01             	add    $0x1,%ebx
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	83 fb 20             	cmp    $0x20,%ebx
  801492:	75 ec                	jne    801480 <close_all+0xc>
}
  801494:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801497:	c9                   	leave  
  801498:	c3                   	ret    

00801499 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801499:	55                   	push   %ebp
  80149a:	89 e5                	mov    %esp,%ebp
  80149c:	57                   	push   %edi
  80149d:	56                   	push   %esi
  80149e:	53                   	push   %ebx
  80149f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 75 08             	pushl  0x8(%ebp)
  8014a9:	e8 66 fe ff ff       	call   801314 <fd_lookup>
  8014ae:	89 c3                	mov    %eax,%ebx
  8014b0:	83 c4 08             	add    $0x8,%esp
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	0f 88 81 00 00 00    	js     80153c <dup+0xa3>
		return r;
	close(newfdnum);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	ff 75 0c             	pushl  0xc(%ebp)
  8014c1:	e8 83 ff ff ff       	call   801449 <close>

	newfd = INDEX2FD(newfdnum);
  8014c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014c9:	c1 e6 0c             	shl    $0xc,%esi
  8014cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014d2:	83 c4 04             	add    $0x4,%esp
  8014d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d8:	e8 d1 fd ff ff       	call   8012ae <fd2data>
  8014dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014df:	89 34 24             	mov    %esi,(%esp)
  8014e2:	e8 c7 fd ff ff       	call   8012ae <fd2data>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	c1 e8 16             	shr    $0x16,%eax
  8014f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f8:	a8 01                	test   $0x1,%al
  8014fa:	74 11                	je     80150d <dup+0x74>
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	c1 e8 0c             	shr    $0xc,%eax
  801501:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801508:	f6 c2 01             	test   $0x1,%dl
  80150b:	75 39                	jne    801546 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801510:	89 d0                	mov    %edx,%eax
  801512:	c1 e8 0c             	shr    $0xc,%eax
  801515:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	25 07 0e 00 00       	and    $0xe07,%eax
  801524:	50                   	push   %eax
  801525:	56                   	push   %esi
  801526:	6a 00                	push   $0x0
  801528:	52                   	push   %edx
  801529:	6a 00                	push   $0x0
  80152b:	e8 5e f7 ff ff       	call   800c8e <sys_page_map>
  801530:	89 c3                	mov    %eax,%ebx
  801532:	83 c4 20             	add    $0x20,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 31                	js     80156a <dup+0xd1>
		goto err;

	return newfdnum;
  801539:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80153c:	89 d8                	mov    %ebx,%eax
  80153e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801546:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154d:	83 ec 0c             	sub    $0xc,%esp
  801550:	25 07 0e 00 00       	and    $0xe07,%eax
  801555:	50                   	push   %eax
  801556:	57                   	push   %edi
  801557:	6a 00                	push   $0x0
  801559:	53                   	push   %ebx
  80155a:	6a 00                	push   $0x0
  80155c:	e8 2d f7 ff ff       	call   800c8e <sys_page_map>
  801561:	89 c3                	mov    %eax,%ebx
  801563:	83 c4 20             	add    $0x20,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	79 a3                	jns    80150d <dup+0x74>
	sys_page_unmap(0, newfd);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	56                   	push   %esi
  80156e:	6a 00                	push   $0x0
  801570:	e8 5b f7 ff ff       	call   800cd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	57                   	push   %edi
  801579:	6a 00                	push   $0x0
  80157b:	e8 50 f7 ff ff       	call   800cd0 <sys_page_unmap>
	return r;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb b7                	jmp    80153c <dup+0xa3>

00801585 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	53                   	push   %ebx
  801589:	83 ec 14             	sub    $0x14,%esp
  80158c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801592:	50                   	push   %eax
  801593:	53                   	push   %ebx
  801594:	e8 7b fd ff ff       	call   801314 <fd_lookup>
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 3f                	js     8015df <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015aa:	ff 30                	pushl  (%eax)
  8015ac:	e8 b9 fd ff ff       	call   80136a <dev_lookup>
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 27                	js     8015df <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015bb:	8b 42 08             	mov    0x8(%edx),%eax
  8015be:	83 e0 03             	and    $0x3,%eax
  8015c1:	83 f8 01             	cmp    $0x1,%eax
  8015c4:	74 1e                	je     8015e4 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c9:	8b 40 08             	mov    0x8(%eax),%eax
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	74 35                	je     801605 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	ff 75 10             	pushl  0x10(%ebp)
  8015d6:	ff 75 0c             	pushl  0xc(%ebp)
  8015d9:	52                   	push   %edx
  8015da:	ff d0                	call   *%eax
  8015dc:	83 c4 10             	add    $0x10,%esp
}
  8015df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ec:	83 ec 04             	sub    $0x4,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	50                   	push   %eax
  8015f1:	68 6d 27 80 00       	push   $0x80276d
  8015f6:	e8 38 ec ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801603:	eb da                	jmp    8015df <read+0x5a>
		return -E_NOT_SUPP;
  801605:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160a:	eb d3                	jmp    8015df <read+0x5a>

0080160c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	57                   	push   %edi
  801610:	56                   	push   %esi
  801611:	53                   	push   %ebx
  801612:	83 ec 0c             	sub    $0xc,%esp
  801615:	8b 7d 08             	mov    0x8(%ebp),%edi
  801618:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801620:	39 f3                	cmp    %esi,%ebx
  801622:	73 25                	jae    801649 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801624:	83 ec 04             	sub    $0x4,%esp
  801627:	89 f0                	mov    %esi,%eax
  801629:	29 d8                	sub    %ebx,%eax
  80162b:	50                   	push   %eax
  80162c:	89 d8                	mov    %ebx,%eax
  80162e:	03 45 0c             	add    0xc(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	57                   	push   %edi
  801633:	e8 4d ff ff ff       	call   801585 <read>
		if (m < 0)
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 08                	js     801647 <readn+0x3b>
			return m;
		if (m == 0)
  80163f:	85 c0                	test   %eax,%eax
  801641:	74 06                	je     801649 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801643:	01 c3                	add    %eax,%ebx
  801645:	eb d9                	jmp    801620 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801647:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801649:	89 d8                	mov    %ebx,%eax
  80164b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164e:	5b                   	pop    %ebx
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    

00801653 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	53                   	push   %ebx
  801657:	83 ec 14             	sub    $0x14,%esp
  80165a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	53                   	push   %ebx
  801662:	e8 ad fc ff ff       	call   801314 <fd_lookup>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 3a                	js     8016a8 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	ff 30                	pushl  (%eax)
  80167a:	e8 eb fc ff ff       	call   80136a <dev_lookup>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 22                	js     8016a8 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801689:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168d:	74 1e                	je     8016ad <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801692:	8b 52 0c             	mov    0xc(%edx),%edx
  801695:	85 d2                	test   %edx,%edx
  801697:	74 35                	je     8016ce <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801699:	83 ec 04             	sub    $0x4,%esp
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	50                   	push   %eax
  8016a3:	ff d2                	call   *%edx
  8016a5:	83 c4 10             	add    $0x10,%esp
}
  8016a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b2:	8b 40 48             	mov    0x48(%eax),%eax
  8016b5:	83 ec 04             	sub    $0x4,%esp
  8016b8:	53                   	push   %ebx
  8016b9:	50                   	push   %eax
  8016ba:	68 89 27 80 00       	push   $0x802789
  8016bf:	e8 6f eb ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cc:	eb da                	jmp    8016a8 <write+0x55>
		return -E_NOT_SUPP;
  8016ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016d3:	eb d3                	jmp    8016a8 <write+0x55>

008016d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016de:	50                   	push   %eax
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 2d fc ff ff       	call   801314 <fd_lookup>
  8016e7:	83 c4 08             	add    $0x8,%esp
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 0e                	js     8016fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 14             	sub    $0x14,%esp
  801705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	53                   	push   %ebx
  80170d:	e8 02 fc ff ff       	call   801314 <fd_lookup>
  801712:	83 c4 08             	add    $0x8,%esp
  801715:	85 c0                	test   %eax,%eax
  801717:	78 37                	js     801750 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171f:	50                   	push   %eax
  801720:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801723:	ff 30                	pushl  (%eax)
  801725:	e8 40 fc ff ff       	call   80136a <dev_lookup>
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 1f                	js     801750 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801734:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801738:	74 1b                	je     801755 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80173a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173d:	8b 52 18             	mov    0x18(%edx),%edx
  801740:	85 d2                	test   %edx,%edx
  801742:	74 32                	je     801776 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	ff 75 0c             	pushl  0xc(%ebp)
  80174a:	50                   	push   %eax
  80174b:	ff d2                	call   *%edx
  80174d:	83 c4 10             	add    $0x10,%esp
}
  801750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801753:	c9                   	leave  
  801754:	c3                   	ret    
			thisenv->env_id, fdnum);
  801755:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175a:	8b 40 48             	mov    0x48(%eax),%eax
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	53                   	push   %ebx
  801761:	50                   	push   %eax
  801762:	68 4c 27 80 00       	push   $0x80274c
  801767:	e8 c7 ea ff ff       	call   800233 <cprintf>
		return -E_INVAL;
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801774:	eb da                	jmp    801750 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801776:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80177b:	eb d3                	jmp    801750 <ftruncate+0x52>

0080177d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	53                   	push   %ebx
  801781:	83 ec 14             	sub    $0x14,%esp
  801784:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801787:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	ff 75 08             	pushl  0x8(%ebp)
  80178e:	e8 81 fb ff ff       	call   801314 <fd_lookup>
  801793:	83 c4 08             	add    $0x8,%esp
  801796:	85 c0                	test   %eax,%eax
  801798:	78 4b                	js     8017e5 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a0:	50                   	push   %eax
  8017a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a4:	ff 30                	pushl  (%eax)
  8017a6:	e8 bf fb ff ff       	call   80136a <dev_lookup>
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 33                	js     8017e5 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8017b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017b9:	74 2f                	je     8017ea <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c5:	00 00 00 
	stat->st_isdir = 0;
  8017c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017cf:	00 00 00 
	stat->st_dev = dev;
  8017d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	53                   	push   %ebx
  8017dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017df:	ff 50 14             	call   *0x14(%eax)
  8017e2:	83 c4 10             	add    $0x10,%esp
}
  8017e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e8:	c9                   	leave  
  8017e9:	c3                   	ret    
		return -E_NOT_SUPP;
  8017ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ef:	eb f4                	jmp    8017e5 <fstat+0x68>

008017f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	6a 00                	push   $0x0
  8017fb:	ff 75 08             	pushl  0x8(%ebp)
  8017fe:	e8 e7 01 00 00       	call   8019ea <open>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	78 1b                	js     801827 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	ff 75 0c             	pushl  0xc(%ebp)
  801812:	50                   	push   %eax
  801813:	e8 65 ff ff ff       	call   80177d <fstat>
  801818:	89 c6                	mov    %eax,%esi
	close(fd);
  80181a:	89 1c 24             	mov    %ebx,(%esp)
  80181d:	e8 27 fc ff ff       	call   801449 <close>
	return r;
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	89 f3                	mov    %esi,%ebx
}
  801827:	89 d8                	mov    %ebx,%eax
  801829:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182c:	5b                   	pop    %ebx
  80182d:	5e                   	pop    %esi
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	89 c6                	mov    %eax,%esi
  801837:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801839:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801840:	74 27                	je     801869 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801842:	6a 07                	push   $0x7
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	56                   	push   %esi
  80184a:	ff 35 00 40 80 00    	pushl  0x804000
  801850:	e8 c3 f9 ff ff       	call   801218 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801855:	83 c4 0c             	add    $0xc,%esp
  801858:	6a 00                	push   $0x0
  80185a:	53                   	push   %ebx
  80185b:	6a 00                	push   $0x0
  80185d:	e8 55 f9 ff ff       	call   8011b7 <ipc_recv>
}
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801869:	83 ec 0c             	sub    $0xc,%esp
  80186c:	6a 01                	push   $0x1
  80186e:	e8 f2 f9 ff ff       	call   801265 <ipc_find_env>
  801873:	a3 00 40 80 00       	mov    %eax,0x804000
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	eb c5                	jmp    801842 <fsipc+0x12>

0080187d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	8b 40 0c             	mov    0xc(%eax),%eax
  801889:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801891:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a0:	e8 8b ff ff ff       	call   801830 <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_flush>:
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c2:	e8 69 ff ff ff       	call   801830 <fsipc>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <devfile_stat>:
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	53                   	push   %ebx
  8018cd:	83 ec 04             	sub    $0x4,%esp
  8018d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e8:	e8 43 ff ff ff       	call   801830 <fsipc>
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 2c                	js     80191d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	68 00 50 80 00       	push   $0x805000
  8018f9:	53                   	push   %ebx
  8018fa:	e8 53 ef ff ff       	call   800852 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ff:	a1 80 50 80 00       	mov    0x805080,%eax
  801904:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80190a:	a1 84 50 80 00       	mov    0x805084,%eax
  80190f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devfile_write>:
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 0c             	sub    $0xc,%esp
  801928:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  80192b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801930:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801935:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801938:	8b 55 08             	mov    0x8(%ebp),%edx
  80193b:	8b 52 0c             	mov    0xc(%edx),%edx
  80193e:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801944:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801949:	50                   	push   %eax
  80194a:	ff 75 0c             	pushl  0xc(%ebp)
  80194d:	68 08 50 80 00       	push   $0x805008
  801952:	e8 89 f0 ff ff       	call   8009e0 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801957:	ba 00 00 00 00       	mov    $0x0,%edx
  80195c:	b8 04 00 00 00       	mov    $0x4,%eax
  801961:	e8 ca fe ff ff       	call   801830 <fsipc>
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <devfile_read>:
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	8b 40 0c             	mov    0xc(%eax),%eax
  801976:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80197b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	b8 03 00 00 00       	mov    $0x3,%eax
  80198b:	e8 a0 fe ff ff       	call   801830 <fsipc>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	85 c0                	test   %eax,%eax
  801994:	78 1f                	js     8019b5 <devfile_read+0x4d>
	assert(r <= n);
  801996:	39 f0                	cmp    %esi,%eax
  801998:	77 24                	ja     8019be <devfile_read+0x56>
	assert(r <= PGSIZE);
  80199a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80199f:	7f 33                	jg     8019d4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a1:	83 ec 04             	sub    $0x4,%esp
  8019a4:	50                   	push   %eax
  8019a5:	68 00 50 80 00       	push   $0x805000
  8019aa:	ff 75 0c             	pushl  0xc(%ebp)
  8019ad:	e8 2e f0 ff ff       	call   8009e0 <memmove>
	return r;
  8019b2:	83 c4 10             	add    $0x10,%esp
}
  8019b5:	89 d8                	mov    %ebx,%eax
  8019b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ba:	5b                   	pop    %ebx
  8019bb:	5e                   	pop    %esi
  8019bc:	5d                   	pop    %ebp
  8019bd:	c3                   	ret    
	assert(r <= n);
  8019be:	68 b8 27 80 00       	push   $0x8027b8
  8019c3:	68 bf 27 80 00       	push   $0x8027bf
  8019c8:	6a 7d                	push   $0x7d
  8019ca:	68 d4 27 80 00       	push   $0x8027d4
  8019cf:	e8 84 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  8019d4:	68 df 27 80 00       	push   $0x8027df
  8019d9:	68 bf 27 80 00       	push   $0x8027bf
  8019de:	6a 7e                	push   $0x7e
  8019e0:	68 d4 27 80 00       	push   $0x8027d4
  8019e5:	e8 6e e7 ff ff       	call   800158 <_panic>

008019ea <open>:
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 1c             	sub    $0x1c,%esp
  8019f2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019f5:	56                   	push   %esi
  8019f6:	e8 20 ee ff ff       	call   80081b <strlen>
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a03:	0f 8f 96 00 00 00    	jg     801a9f <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0f:	50                   	push   %eax
  801a10:	e8 b0 f8 ff ff       	call   8012c5 <fd_alloc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 66                	js     801a84 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	56                   	push   %esi
  801a22:	68 00 50 80 00       	push   $0x805000
  801a27:	e8 26 ee ff ff       	call   800852 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	e8 ef fd ff ff       	call   801830 <fsipc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 43                	js     801a8d <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801a50:	e8 49 f8 ff ff       	call   80129e <fd2num>
  801a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a58:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801a5e:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a61:	83 c4 08             	add    $0x8,%esp
  801a64:	50                   	push   %eax
  801a65:	52                   	push   %edx
  801a66:	ff 32                	pushl  (%edx)
  801a68:	56                   	push   %esi
  801a69:	51                   	push   %ecx
  801a6a:	68 ec 27 80 00       	push   $0x8027ec
  801a6f:	e8 bf e7 ff ff       	call   800233 <cprintf>
	return fd2num(fd);
  801a74:	83 c4 14             	add    $0x14,%esp
  801a77:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7a:	e8 1f f8 ff ff       	call   80129e <fd2num>
  801a7f:	89 c3                	mov    %eax,%ebx
  801a81:	83 c4 10             	add    $0x10,%esp
}
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    
		fd_close(fd, 0);
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	6a 00                	push   $0x0
  801a92:	ff 75 f4             	pushl  -0xc(%ebp)
  801a95:	e8 26 f9 ff ff       	call   8013c0 <fd_close>
		return r;
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	eb e5                	jmp    801a84 <open+0x9a>
		return -E_BAD_PATH;
  801a9f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801aa4:	eb de                	jmp    801a84 <open+0x9a>

00801aa6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aac:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab6:	e8 75 fd ff ff       	call   801830 <fsipc>
}
  801abb:	c9                   	leave  
  801abc:	c3                   	ret    

00801abd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ac5:	83 ec 0c             	sub    $0xc,%esp
  801ac8:	ff 75 08             	pushl  0x8(%ebp)
  801acb:	e8 de f7 ff ff       	call   8012ae <fd2data>
  801ad0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ad2:	83 c4 08             	add    $0x8,%esp
  801ad5:	68 2c 28 80 00       	push   $0x80282c
  801ada:	53                   	push   %ebx
  801adb:	e8 72 ed ff ff       	call   800852 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ae0:	8b 46 04             	mov    0x4(%esi),%eax
  801ae3:	2b 06                	sub    (%esi),%eax
  801ae5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aeb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af2:	00 00 00 
	stat->st_dev = &devpipe;
  801af5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801afc:	30 80 00 
	return 0;
}
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
  801b04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5e                   	pop    %esi
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b15:	53                   	push   %ebx
  801b16:	6a 00                	push   $0x0
  801b18:	e8 b3 f1 ff ff       	call   800cd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b1d:	89 1c 24             	mov    %ebx,(%esp)
  801b20:	e8 89 f7 ff ff       	call   8012ae <fd2data>
  801b25:	83 c4 08             	add    $0x8,%esp
  801b28:	50                   	push   %eax
  801b29:	6a 00                	push   $0x0
  801b2b:	e8 a0 f1 ff ff       	call   800cd0 <sys_page_unmap>
}
  801b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <_pipeisclosed>:
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	57                   	push   %edi
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	83 ec 1c             	sub    $0x1c,%esp
  801b3e:	89 c7                	mov    %eax,%edi
  801b40:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b42:	a1 04 40 80 00       	mov    0x804004,%eax
  801b47:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	57                   	push   %edi
  801b4e:	e8 5a 04 00 00       	call   801fad <pageref>
  801b53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b56:	89 34 24             	mov    %esi,(%esp)
  801b59:	e8 4f 04 00 00       	call   801fad <pageref>
		nn = thisenv->env_runs;
  801b5e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b64:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	39 cb                	cmp    %ecx,%ebx
  801b6c:	74 1b                	je     801b89 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b6e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b71:	75 cf                	jne    801b42 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b73:	8b 42 58             	mov    0x58(%edx),%eax
  801b76:	6a 01                	push   $0x1
  801b78:	50                   	push   %eax
  801b79:	53                   	push   %ebx
  801b7a:	68 33 28 80 00       	push   $0x802833
  801b7f:	e8 af e6 ff ff       	call   800233 <cprintf>
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	eb b9                	jmp    801b42 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b89:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b8c:	0f 94 c0             	sete   %al
  801b8f:	0f b6 c0             	movzbl %al,%eax
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <devpipe_write>:
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 28             	sub    $0x28,%esp
  801ba3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ba6:	56                   	push   %esi
  801ba7:	e8 02 f7 ff ff       	call   8012ae <fd2data>
  801bac:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	bf 00 00 00 00       	mov    $0x0,%edi
  801bb6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb9:	74 4f                	je     801c0a <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bbb:	8b 43 04             	mov    0x4(%ebx),%eax
  801bbe:	8b 0b                	mov    (%ebx),%ecx
  801bc0:	8d 51 20             	lea    0x20(%ecx),%edx
  801bc3:	39 d0                	cmp    %edx,%eax
  801bc5:	72 14                	jb     801bdb <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801bc7:	89 da                	mov    %ebx,%edx
  801bc9:	89 f0                	mov    %esi,%eax
  801bcb:	e8 65 ff ff ff       	call   801b35 <_pipeisclosed>
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	75 3a                	jne    801c0e <devpipe_write+0x74>
			sys_yield();
  801bd4:	e8 53 f0 ff ff       	call   800c2c <sys_yield>
  801bd9:	eb e0                	jmp    801bbb <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bde:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801be2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801be5:	89 c2                	mov    %eax,%edx
  801be7:	c1 fa 1f             	sar    $0x1f,%edx
  801bea:	89 d1                	mov    %edx,%ecx
  801bec:	c1 e9 1b             	shr    $0x1b,%ecx
  801bef:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bf2:	83 e2 1f             	and    $0x1f,%edx
  801bf5:	29 ca                	sub    %ecx,%edx
  801bf7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bfb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bff:	83 c0 01             	add    $0x1,%eax
  801c02:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c05:	83 c7 01             	add    $0x1,%edi
  801c08:	eb ac                	jmp    801bb6 <devpipe_write+0x1c>
	return i;
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	eb 05                	jmp    801c13 <devpipe_write+0x79>
				return 0;
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <devpipe_read>:
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	57                   	push   %edi
  801c1f:	56                   	push   %esi
  801c20:	53                   	push   %ebx
  801c21:	83 ec 18             	sub    $0x18,%esp
  801c24:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c27:	57                   	push   %edi
  801c28:	e8 81 f6 ff ff       	call   8012ae <fd2data>
  801c2d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c2f:	83 c4 10             	add    $0x10,%esp
  801c32:	be 00 00 00 00       	mov    $0x0,%esi
  801c37:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c3a:	74 47                	je     801c83 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c3c:	8b 03                	mov    (%ebx),%eax
  801c3e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c41:	75 22                	jne    801c65 <devpipe_read+0x4a>
			if (i > 0)
  801c43:	85 f6                	test   %esi,%esi
  801c45:	75 14                	jne    801c5b <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c47:	89 da                	mov    %ebx,%edx
  801c49:	89 f8                	mov    %edi,%eax
  801c4b:	e8 e5 fe ff ff       	call   801b35 <_pipeisclosed>
  801c50:	85 c0                	test   %eax,%eax
  801c52:	75 33                	jne    801c87 <devpipe_read+0x6c>
			sys_yield();
  801c54:	e8 d3 ef ff ff       	call   800c2c <sys_yield>
  801c59:	eb e1                	jmp    801c3c <devpipe_read+0x21>
				return i;
  801c5b:	89 f0                	mov    %esi,%eax
}
  801c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c65:	99                   	cltd   
  801c66:	c1 ea 1b             	shr    $0x1b,%edx
  801c69:	01 d0                	add    %edx,%eax
  801c6b:	83 e0 1f             	and    $0x1f,%eax
  801c6e:	29 d0                	sub    %edx,%eax
  801c70:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c78:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c7b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c7e:	83 c6 01             	add    $0x1,%esi
  801c81:	eb b4                	jmp    801c37 <devpipe_read+0x1c>
	return i;
  801c83:	89 f0                	mov    %esi,%eax
  801c85:	eb d6                	jmp    801c5d <devpipe_read+0x42>
				return 0;
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8c:	eb cf                	jmp    801c5d <devpipe_read+0x42>

00801c8e <pipe>:
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c99:	50                   	push   %eax
  801c9a:	e8 26 f6 ff ff       	call   8012c5 <fd_alloc>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	83 c4 10             	add    $0x10,%esp
  801ca4:	85 c0                	test   %eax,%eax
  801ca6:	78 5b                	js     801d03 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca8:	83 ec 04             	sub    $0x4,%esp
  801cab:	68 07 04 00 00       	push   $0x407
  801cb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb3:	6a 00                	push   $0x0
  801cb5:	e8 91 ef ff ff       	call   800c4b <sys_page_alloc>
  801cba:	89 c3                	mov    %eax,%ebx
  801cbc:	83 c4 10             	add    $0x10,%esp
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 40                	js     801d03 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cc9:	50                   	push   %eax
  801cca:	e8 f6 f5 ff ff       	call   8012c5 <fd_alloc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	85 c0                	test   %eax,%eax
  801cd6:	78 1b                	js     801cf3 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd8:	83 ec 04             	sub    $0x4,%esp
  801cdb:	68 07 04 00 00       	push   $0x407
  801ce0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 61 ef ff ff       	call   800c4b <sys_page_alloc>
  801cea:	89 c3                	mov    %eax,%ebx
  801cec:	83 c4 10             	add    $0x10,%esp
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	79 19                	jns    801d0c <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801cf3:	83 ec 08             	sub    $0x8,%esp
  801cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 d0 ef ff ff       	call   800cd0 <sys_page_unmap>
  801d00:	83 c4 10             	add    $0x10,%esp
}
  801d03:	89 d8                	mov    %ebx,%eax
  801d05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5e                   	pop    %esi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
	va = fd2data(fd0);
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d12:	e8 97 f5 ff ff       	call   8012ae <fd2data>
  801d17:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d19:	83 c4 0c             	add    $0xc,%esp
  801d1c:	68 07 04 00 00       	push   $0x407
  801d21:	50                   	push   %eax
  801d22:	6a 00                	push   $0x0
  801d24:	e8 22 ef ff ff       	call   800c4b <sys_page_alloc>
  801d29:	89 c3                	mov    %eax,%ebx
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	0f 88 8c 00 00 00    	js     801dc2 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f0             	pushl  -0x10(%ebp)
  801d3c:	e8 6d f5 ff ff       	call   8012ae <fd2data>
  801d41:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d48:	50                   	push   %eax
  801d49:	6a 00                	push   $0x0
  801d4b:	56                   	push   %esi
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 3b ef ff ff       	call   800c8e <sys_page_map>
  801d53:	89 c3                	mov    %eax,%ebx
  801d55:	83 c4 20             	add    $0x20,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	78 58                	js     801db4 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d65:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d74:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d7a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d86:	83 ec 0c             	sub    $0xc,%esp
  801d89:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8c:	e8 0d f5 ff ff       	call   80129e <fd2num>
  801d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d96:	83 c4 04             	add    $0x4,%esp
  801d99:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9c:	e8 fd f4 ff ff       	call   80129e <fd2num>
  801da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801da4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801daf:	e9 4f ff ff ff       	jmp    801d03 <pipe+0x75>
	sys_page_unmap(0, va);
  801db4:	83 ec 08             	sub    $0x8,%esp
  801db7:	56                   	push   %esi
  801db8:	6a 00                	push   $0x0
  801dba:	e8 11 ef ff ff       	call   800cd0 <sys_page_unmap>
  801dbf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 01 ef ff ff       	call   800cd0 <sys_page_unmap>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	e9 1c ff ff ff       	jmp    801cf3 <pipe+0x65>

00801dd7 <pipeisclosed>:
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	ff 75 08             	pushl  0x8(%ebp)
  801de4:	e8 2b f5 ff ff       	call   801314 <fd_lookup>
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 18                	js     801e08 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	ff 75 f4             	pushl  -0xc(%ebp)
  801df6:	e8 b3 f4 ff ff       	call   8012ae <fd2data>
	return _pipeisclosed(fd, p);
  801dfb:	89 c2                	mov    %eax,%edx
  801dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e00:	e8 30 fd ff ff       	call   801b35 <_pipeisclosed>
  801e05:	83 c4 10             	add    $0x10,%esp
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e1a:	68 4b 28 80 00       	push   $0x80284b
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	e8 2b ea ff ff       	call   800852 <strcpy>
	return 0;
}
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <devcons_write>:
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	53                   	push   %ebx
  801e34:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e3a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e45:	eb 2f                	jmp    801e76 <devcons_write+0x48>
		m = n - tot;
  801e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e4a:	29 f3                	sub    %esi,%ebx
  801e4c:	83 fb 7f             	cmp    $0x7f,%ebx
  801e4f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e54:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	53                   	push   %ebx
  801e5b:	89 f0                	mov    %esi,%eax
  801e5d:	03 45 0c             	add    0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	57                   	push   %edi
  801e62:	e8 79 eb ff ff       	call   8009e0 <memmove>
		sys_cputs(buf, m);
  801e67:	83 c4 08             	add    $0x8,%esp
  801e6a:	53                   	push   %ebx
  801e6b:	57                   	push   %edi
  801e6c:	e8 1e ed ff ff       	call   800b8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e71:	01 de                	add    %ebx,%esi
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e79:	72 cc                	jb     801e47 <devcons_write+0x19>
}
  801e7b:	89 f0                	mov    %esi,%eax
  801e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <devcons_read>:
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	83 ec 08             	sub    $0x8,%esp
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e94:	75 07                	jne    801e9d <devcons_read+0x18>
}
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    
		sys_yield();
  801e98:	e8 8f ed ff ff       	call   800c2c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e9d:	e8 0b ed ff ff       	call   800bad <sys_cgetc>
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	74 f2                	je     801e98 <devcons_read+0x13>
	if (c < 0)
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 ec                	js     801e96 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801eaa:	83 f8 04             	cmp    $0x4,%eax
  801ead:	74 0c                	je     801ebb <devcons_read+0x36>
	*(char*)vbuf = c;
  801eaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb2:	88 02                	mov    %al,(%edx)
	return 1;
  801eb4:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb9:	eb db                	jmp    801e96 <devcons_read+0x11>
		return 0;
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec0:	eb d4                	jmp    801e96 <devcons_read+0x11>

00801ec2 <cputchar>:
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ece:	6a 01                	push   $0x1
  801ed0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed3:	50                   	push   %eax
  801ed4:	e8 b6 ec ff ff       	call   800b8f <sys_cputs>
}
  801ed9:	83 c4 10             	add    $0x10,%esp
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <getchar>:
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ee4:	6a 01                	push   $0x1
  801ee6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee9:	50                   	push   %eax
  801eea:	6a 00                	push   $0x0
  801eec:	e8 94 f6 ff ff       	call   801585 <read>
	if (r < 0)
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	78 08                	js     801f00 <getchar+0x22>
	if (r < 1)
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	7e 06                	jle    801f02 <getchar+0x24>
	return c;
  801efc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    
		return -E_EOF;
  801f02:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f07:	eb f7                	jmp    801f00 <getchar+0x22>

00801f09 <iscons>:
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f12:	50                   	push   %eax
  801f13:	ff 75 08             	pushl  0x8(%ebp)
  801f16:	e8 f9 f3 ff ff       	call   801314 <fd_lookup>
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 11                	js     801f33 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2b:	39 10                	cmp    %edx,(%eax)
  801f2d:	0f 94 c0             	sete   %al
  801f30:	0f b6 c0             	movzbl %al,%eax
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <opencons>:
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	e8 81 f3 ff ff       	call   8012c5 <fd_alloc>
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	78 3a                	js     801f85 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4b:	83 ec 04             	sub    $0x4,%esp
  801f4e:	68 07 04 00 00       	push   $0x407
  801f53:	ff 75 f4             	pushl  -0xc(%ebp)
  801f56:	6a 00                	push   $0x0
  801f58:	e8 ee ec ff ff       	call   800c4b <sys_page_alloc>
  801f5d:	83 c4 10             	add    $0x10,%esp
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 21                	js     801f85 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f67:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f6d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f72:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 1c f3 ff ff       	call   80129e <fd2num>
  801f82:	83 c4 10             	add    $0x10,%esp
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f87:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f88:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801f8d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f8f:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801f92:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801f95:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801f99:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801f9d:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801fa0:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801fa4:	89 18                	mov    %ebx,(%eax)

    popal
  801fa6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801fa7:	83 c4 04             	add    $0x4,%esp
    popfl
  801faa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801fab:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801fac:	c3                   	ret    

00801fad <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb3:	89 d0                	mov    %edx,%eax
  801fb5:	c1 e8 16             	shr    $0x16,%eax
  801fb8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc4:	f6 c1 01             	test   $0x1,%cl
  801fc7:	74 1d                	je     801fe6 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fc9:	c1 ea 0c             	shr    $0xc,%edx
  801fcc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd3:	f6 c2 01             	test   $0x1,%dl
  801fd6:	74 0e                	je     801fe6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd8:	c1 ea 0c             	shr    $0xc,%edx
  801fdb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe2:	ef 
  801fe3:	0f b7 c0             	movzwl %ax,%eax
}
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ffb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802003:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802007:	85 d2                	test   %edx,%edx
  802009:	75 35                	jne    802040 <__udivdi3+0x50>
  80200b:	39 f3                	cmp    %esi,%ebx
  80200d:	0f 87 bd 00 00 00    	ja     8020d0 <__udivdi3+0xe0>
  802013:	85 db                	test   %ebx,%ebx
  802015:	89 d9                	mov    %ebx,%ecx
  802017:	75 0b                	jne    802024 <__udivdi3+0x34>
  802019:	b8 01 00 00 00       	mov    $0x1,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f3                	div    %ebx
  802022:	89 c1                	mov    %eax,%ecx
  802024:	31 d2                	xor    %edx,%edx
  802026:	89 f0                	mov    %esi,%eax
  802028:	f7 f1                	div    %ecx
  80202a:	89 c6                	mov    %eax,%esi
  80202c:	89 e8                	mov    %ebp,%eax
  80202e:	89 f7                	mov    %esi,%edi
  802030:	f7 f1                	div    %ecx
  802032:	89 fa                	mov    %edi,%edx
  802034:	83 c4 1c             	add    $0x1c,%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 f2                	cmp    %esi,%edx
  802042:	77 7c                	ja     8020c0 <__udivdi3+0xd0>
  802044:	0f bd fa             	bsr    %edx,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0xf8>
  802050:	89 f9                	mov    %edi,%ecx
  802052:	b8 20 00 00 00       	mov    $0x20,%eax
  802057:	29 f8                	sub    %edi,%eax
  802059:	d3 e2                	shl    %cl,%edx
  80205b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	89 da                	mov    %ebx,%edx
  802063:	d3 ea                	shr    %cl,%edx
  802065:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802069:	09 d1                	or     %edx,%ecx
  80206b:	89 f2                	mov    %esi,%edx
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e3                	shl    %cl,%ebx
  802075:	89 c1                	mov    %eax,%ecx
  802077:	d3 ea                	shr    %cl,%edx
  802079:	89 f9                	mov    %edi,%ecx
  80207b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80207f:	d3 e6                	shl    %cl,%esi
  802081:	89 eb                	mov    %ebp,%ebx
  802083:	89 c1                	mov    %eax,%ecx
  802085:	d3 eb                	shr    %cl,%ebx
  802087:	09 de                	or     %ebx,%esi
  802089:	89 f0                	mov    %esi,%eax
  80208b:	f7 74 24 08          	divl   0x8(%esp)
  80208f:	89 d6                	mov    %edx,%esi
  802091:	89 c3                	mov    %eax,%ebx
  802093:	f7 64 24 0c          	mull   0xc(%esp)
  802097:	39 d6                	cmp    %edx,%esi
  802099:	72 0c                	jb     8020a7 <__udivdi3+0xb7>
  80209b:	89 f9                	mov    %edi,%ecx
  80209d:	d3 e5                	shl    %cl,%ebp
  80209f:	39 c5                	cmp    %eax,%ebp
  8020a1:	73 5d                	jae    802100 <__udivdi3+0x110>
  8020a3:	39 d6                	cmp    %edx,%esi
  8020a5:	75 59                	jne    802100 <__udivdi3+0x110>
  8020a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020aa:	31 ff                	xor    %edi,%edi
  8020ac:	89 fa                	mov    %edi,%edx
  8020ae:	83 c4 1c             	add    $0x1c,%esp
  8020b1:	5b                   	pop    %ebx
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    
  8020b6:	8d 76 00             	lea    0x0(%esi),%esi
  8020b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020c0:	31 ff                	xor    %edi,%edi
  8020c2:	31 c0                	xor    %eax,%eax
  8020c4:	89 fa                	mov    %edi,%edx
  8020c6:	83 c4 1c             	add    $0x1c,%esp
  8020c9:	5b                   	pop    %ebx
  8020ca:	5e                   	pop    %esi
  8020cb:	5f                   	pop    %edi
  8020cc:	5d                   	pop    %ebp
  8020cd:	c3                   	ret    
  8020ce:	66 90                	xchg   %ax,%ax
  8020d0:	31 ff                	xor    %edi,%edi
  8020d2:	89 e8                	mov    %ebp,%eax
  8020d4:	89 f2                	mov    %esi,%edx
  8020d6:	f7 f3                	div    %ebx
  8020d8:	89 fa                	mov    %edi,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	72 06                	jb     8020f2 <__udivdi3+0x102>
  8020ec:	31 c0                	xor    %eax,%eax
  8020ee:	39 eb                	cmp    %ebp,%ebx
  8020f0:	77 d2                	ja     8020c4 <__udivdi3+0xd4>
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	eb cb                	jmp    8020c4 <__udivdi3+0xd4>
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d8                	mov    %ebx,%eax
  802102:	31 ff                	xor    %edi,%edi
  802104:	eb be                	jmp    8020c4 <__udivdi3+0xd4>
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80211b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80211f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 ed                	test   %ebp,%ebp
  802129:	89 f0                	mov    %esi,%eax
  80212b:	89 da                	mov    %ebx,%edx
  80212d:	75 19                	jne    802148 <__umoddi3+0x38>
  80212f:	39 df                	cmp    %ebx,%edi
  802131:	0f 86 b1 00 00 00    	jbe    8021e8 <__umoddi3+0xd8>
  802137:	f7 f7                	div    %edi
  802139:	89 d0                	mov    %edx,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 dd                	cmp    %ebx,%ebp
  80214a:	77 f1                	ja     80213d <__umoddi3+0x2d>
  80214c:	0f bd cd             	bsr    %ebp,%ecx
  80214f:	83 f1 1f             	xor    $0x1f,%ecx
  802152:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802156:	0f 84 b4 00 00 00    	je     802210 <__umoddi3+0x100>
  80215c:	b8 20 00 00 00       	mov    $0x20,%eax
  802161:	89 c2                	mov    %eax,%edx
  802163:	8b 44 24 04          	mov    0x4(%esp),%eax
  802167:	29 c2                	sub    %eax,%edx
  802169:	89 c1                	mov    %eax,%ecx
  80216b:	89 f8                	mov    %edi,%eax
  80216d:	d3 e5                	shl    %cl,%ebp
  80216f:	89 d1                	mov    %edx,%ecx
  802171:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802175:	d3 e8                	shr    %cl,%eax
  802177:	09 c5                	or     %eax,%ebp
  802179:	8b 44 24 04          	mov    0x4(%esp),%eax
  80217d:	89 c1                	mov    %eax,%ecx
  80217f:	d3 e7                	shl    %cl,%edi
  802181:	89 d1                	mov    %edx,%ecx
  802183:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802187:	89 df                	mov    %ebx,%edi
  802189:	d3 ef                	shr    %cl,%edi
  80218b:	89 c1                	mov    %eax,%ecx
  80218d:	89 f0                	mov    %esi,%eax
  80218f:	d3 e3                	shl    %cl,%ebx
  802191:	89 d1                	mov    %edx,%ecx
  802193:	89 fa                	mov    %edi,%edx
  802195:	d3 e8                	shr    %cl,%eax
  802197:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80219c:	09 d8                	or     %ebx,%eax
  80219e:	f7 f5                	div    %ebp
  8021a0:	d3 e6                	shl    %cl,%esi
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	f7 64 24 08          	mull   0x8(%esp)
  8021a8:	39 d1                	cmp    %edx,%ecx
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d7                	mov    %edx,%edi
  8021ae:	72 06                	jb     8021b6 <__umoddi3+0xa6>
  8021b0:	75 0e                	jne    8021c0 <__umoddi3+0xb0>
  8021b2:	39 c6                	cmp    %eax,%esi
  8021b4:	73 0a                	jae    8021c0 <__umoddi3+0xb0>
  8021b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8021ba:	19 ea                	sbb    %ebp,%edx
  8021bc:	89 d7                	mov    %edx,%edi
  8021be:	89 c3                	mov    %eax,%ebx
  8021c0:	89 ca                	mov    %ecx,%edx
  8021c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021c7:	29 de                	sub    %ebx,%esi
  8021c9:	19 fa                	sbb    %edi,%edx
  8021cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	d3 e0                	shl    %cl,%eax
  8021d3:	89 d9                	mov    %ebx,%ecx
  8021d5:	d3 ee                	shr    %cl,%esi
  8021d7:	d3 ea                	shr    %cl,%edx
  8021d9:	09 f0                	or     %esi,%eax
  8021db:	83 c4 1c             	add    $0x1c,%esp
  8021de:	5b                   	pop    %ebx
  8021df:	5e                   	pop    %esi
  8021e0:	5f                   	pop    %edi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
  8021e3:	90                   	nop
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	85 ff                	test   %edi,%edi
  8021ea:	89 f9                	mov    %edi,%ecx
  8021ec:	75 0b                	jne    8021f9 <__umoddi3+0xe9>
  8021ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f7                	div    %edi
  8021f7:	89 c1                	mov    %eax,%ecx
  8021f9:	89 d8                	mov    %ebx,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f1                	div    %ecx
  8021ff:	89 f0                	mov    %esi,%eax
  802201:	f7 f1                	div    %ecx
  802203:	e9 31 ff ff ff       	jmp    802139 <__umoddi3+0x29>
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	39 dd                	cmp    %ebx,%ebp
  802212:	72 08                	jb     80221c <__umoddi3+0x10c>
  802214:	39 f7                	cmp    %esi,%edi
  802216:	0f 87 21 ff ff ff    	ja     80213d <__umoddi3+0x2d>
  80221c:	89 da                	mov    %ebx,%edx
  80221e:	89 f0                	mov    %esi,%eax
  802220:	29 f8                	sub    %edi,%eax
  802222:	19 ea                	sbb    %ebp,%edx
  802224:	e9 14 ff ff ff       	jmp    80213d <__umoddi3+0x2d>
