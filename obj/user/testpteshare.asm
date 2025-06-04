
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 65 01 00 00       	call   800196 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 a7 08 00 00       	call   8008f0 <strcpy>
	exit();
  800049:	e8 8e 01 00 00       	call   8001dc <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	0f 85 d2 00 00 00    	jne    800136 <umain+0xe3>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800064:	83 ec 04             	sub    $0x4,%esp
  800067:	68 07 04 00 00       	push   $0x407
  80006c:	68 00 00 00 a0       	push   $0xa0000000
  800071:	6a 00                	push   $0x0
  800073:	e8 71 0c 00 00       	call   800ce9 <sys_page_alloc>
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	85 c0                	test   %eax,%eax
  80007d:	0f 88 bd 00 00 00    	js     800140 <umain+0xed>
	if ((r = fork()) < 0)
  800083:	e8 58 10 00 00       	call   8010e0 <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 c0 00 00 00    	js     800152 <umain+0xff>
	if (r == 0) {
  800092:	85 c0                	test   %eax,%eax
  800094:	0f 84 ca 00 00 00    	je     800164 <umain+0x111>
	wait(r);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	53                   	push   %ebx
  80009e:	e8 75 23 00 00       	call   802418 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	ff 35 04 40 80 00    	pushl  0x804004
  8000ac:	68 00 00 00 a0       	push   $0xa0000000
  8000b1:	e8 e0 08 00 00       	call   800996 <strcmp>
  8000b6:	83 c4 08             	add    $0x8,%esp
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	b8 80 29 80 00       	mov    $0x802980,%eax
  8000c0:	ba 86 29 80 00       	mov    $0x802986,%edx
  8000c5:	0f 45 c2             	cmovne %edx,%eax
  8000c8:	50                   	push   %eax
  8000c9:	68 bc 29 80 00       	push   $0x8029bc
  8000ce:	e8 fe 01 00 00       	call   8002d1 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d3:	6a 00                	push   $0x0
  8000d5:	68 d7 29 80 00       	push   $0x8029d7
  8000da:	68 dc 29 80 00       	push   $0x8029dc
  8000df:	68 db 29 80 00       	push   $0x8029db
  8000e4:	e8 1c 1f 00 00       	call   802005 <spawnl>
  8000e9:	83 c4 20             	add    $0x20,%esp
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	0f 88 90 00 00 00    	js     800184 <umain+0x131>
	wait(r);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	e8 1b 23 00 00       	call   802418 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	ff 35 00 40 80 00    	pushl  0x804000
  800106:	68 00 00 00 a0       	push   $0xa0000000
  80010b:	e8 86 08 00 00       	call   800996 <strcmp>
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	b8 80 29 80 00       	mov    $0x802980,%eax
  80011a:	ba 86 29 80 00       	mov    $0x802986,%edx
  80011f:	0f 45 c2             	cmovne %edx,%eax
  800122:	50                   	push   %eax
  800123:	68 f3 29 80 00       	push   $0x8029f3
  800128:	e8 a4 01 00 00       	call   8002d1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80012d:	cc                   	int3   
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800134:	c9                   	leave  
  800135:	c3                   	ret    
		childofspawn();
  800136:	e8 f8 fe ff ff       	call   800033 <childofspawn>
  80013b:	e9 24 ff ff ff       	jmp    800064 <umain+0x11>
		panic("sys_page_alloc: %e", r);
  800140:	50                   	push   %eax
  800141:	68 8c 29 80 00       	push   $0x80298c
  800146:	6a 13                	push   $0x13
  800148:	68 9f 29 80 00       	push   $0x80299f
  80014d:	e8 a4 00 00 00       	call   8001f6 <_panic>
		panic("fork: %e", r);
  800152:	50                   	push   %eax
  800153:	68 b3 29 80 00       	push   $0x8029b3
  800158:	6a 17                	push   $0x17
  80015a:	68 9f 29 80 00       	push   $0x80299f
  80015f:	e8 92 00 00 00       	call   8001f6 <_panic>
		strcpy(VA, msg);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	ff 35 04 40 80 00    	pushl  0x804004
  80016d:	68 00 00 00 a0       	push   $0xa0000000
  800172:	e8 79 07 00 00       	call   8008f0 <strcpy>
		exit();
  800177:	e8 60 00 00 00       	call   8001dc <exit>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	e9 16 ff ff ff       	jmp    80009a <umain+0x47>
		panic("spawn: %e", r);
  800184:	50                   	push   %eax
  800185:	68 e9 29 80 00       	push   $0x8029e9
  80018a:	6a 21                	push   $0x21
  80018c:	68 9f 29 80 00       	push   $0x80299f
  800191:	e8 60 00 00 00       	call   8001f6 <_panic>

00800196 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80019e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001a1:	e8 05 0b 00 00       	call   800cab <sys_getenvid>
  8001a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b3:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7e 07                	jle    8001c3 <libmain+0x2d>
		binaryname = argv[0];
  8001bc:	8b 06                	mov    (%esi),%eax
  8001be:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	e8 86 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001cd:	e8 0a 00 00 00       	call   8001dc <exit>
}
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e2:	e8 44 12 00 00       	call   80142b <close_all>
	sys_env_destroy(0);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	6a 00                	push   $0x0
  8001ec:	e8 79 0a 00 00       	call   800c6a <sys_env_destroy>
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fe:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800204:	e8 a2 0a 00 00       	call   800cab <sys_getenvid>
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	ff 75 0c             	pushl  0xc(%ebp)
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	56                   	push   %esi
  800213:	50                   	push   %eax
  800214:	68 38 2a 80 00       	push   $0x802a38
  800219:	e8 b3 00 00 00       	call   8002d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	53                   	push   %ebx
  800222:	ff 75 10             	pushl  0x10(%ebp)
  800225:	e8 56 00 00 00       	call   800280 <vcprintf>
	cprintf("\n");
  80022a:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  800231:	e8 9b 00 00 00       	call   8002d1 <cprintf>
  800236:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800239:	cc                   	int3   
  80023a:	eb fd                	jmp    800239 <_panic+0x43>

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 13                	mov    (%ebx),%edx
  800248:	8d 42 01             	lea    0x1(%edx),%eax
  80024b:	89 03                	mov    %eax,(%ebx)
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800254:	3d ff 00 00 00       	cmp    $0xff,%eax
  800259:	74 09                	je     800264 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800262:	c9                   	leave  
  800263:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	68 ff 00 00 00       	push   $0xff
  80026c:	8d 43 08             	lea    0x8(%ebx),%eax
  80026f:	50                   	push   %eax
  800270:	e8 b8 09 00 00       	call   800c2d <sys_cputs>
		b->idx = 0;
  800275:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	eb db                	jmp    80025b <putch+0x1f>

00800280 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800289:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800290:	00 00 00 
	b.cnt = 0;
  800293:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a9:	50                   	push   %eax
  8002aa:	68 3c 02 80 00       	push   $0x80023c
  8002af:	e8 1a 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b4:	83 c4 08             	add    $0x8,%esp
  8002b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 64 09 00 00       	call   800c2d <sys_cputs>

	return b.cnt;
}
  8002c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 9d ff ff ff       	call   800280 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 1c             	sub    $0x1c,%esp
  8002ee:	89 c7                	mov    %eax,%edi
  8002f0:	89 d6                	mov    %edx,%esi
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800301:	bb 00 00 00 00       	mov    $0x0,%ebx
  800306:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80030c:	39 d3                	cmp    %edx,%ebx
  80030e:	72 05                	jb     800315 <printnum+0x30>
  800310:	39 45 10             	cmp    %eax,0x10(%ebp)
  800313:	77 7a                	ja     80038f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	ff 75 18             	pushl  0x18(%ebp)
  80031b:	8b 45 14             	mov    0x14(%ebp),%eax
  80031e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800321:	53                   	push   %ebx
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032b:	ff 75 e0             	pushl  -0x20(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 f7 23 00 00       	call   802730 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	89 f8                	mov    %edi,%eax
  800342:	e8 9e ff ff ff       	call   8002e5 <printnum>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	eb 13                	jmp    80035f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	ff 75 18             	pushl  0x18(%ebp)
  800353:	ff d7                	call   *%edi
  800355:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	7f ed                	jg     80034c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	83 ec 04             	sub    $0x4,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 d9 24 00 00       	call   802850 <__umoddi3>
  800377:	83 c4 14             	add    $0x14,%esp
  80037a:	0f be 80 5b 2a 80 00 	movsbl 0x802a5b(%eax),%eax
  800381:	50                   	push   %eax
  800382:	ff d7                	call   *%edi
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    
  80038f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800392:	eb c4                	jmp    800358 <printnum+0x73>

00800394 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a3:	73 0a                	jae    8003af <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	88 02                	mov    %al,(%edx)
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <printfmt>:
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ba:	50                   	push   %eax
  8003bb:	ff 75 10             	pushl  0x10(%ebp)
  8003be:	ff 75 0c             	pushl  0xc(%ebp)
  8003c1:	ff 75 08             	pushl  0x8(%ebp)
  8003c4:	e8 05 00 00 00       	call   8003ce <vprintfmt>
}
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 2c             	sub    $0x2c,%esp
  8003d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e0:	e9 c1 03 00 00       	jmp    8007a6 <vprintfmt+0x3d8>
		padc = ' ';
  8003e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8d 47 01             	lea    0x1(%edi),%eax
  800406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800409:	0f b6 17             	movzbl (%edi),%edx
  80040c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040f:	3c 55                	cmp    $0x55,%al
  800411:	0f 87 12 04 00 00    	ja     800829 <vprintfmt+0x45b>
  800417:	0f b6 c0             	movzbl %al,%eax
  80041a:	ff 24 85 a0 2b 80 00 	jmp    *0x802ba0(,%eax,4)
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800424:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800428:	eb d9                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80042d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800431:	eb d0                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800433:	0f b6 d2             	movzbl %dl,%edx
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800441:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800444:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800448:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80044b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044e:	83 f9 09             	cmp    $0x9,%ecx
  800451:	77 55                	ja     8004a8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800453:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800456:	eb e9                	jmp    800441 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 40 04             	lea    0x4(%eax),%eax
  800466:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	79 91                	jns    800403 <vprintfmt+0x35>
				width = precision, precision = -1;
  800472:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047f:	eb 82                	jmp    800403 <vprintfmt+0x35>
  800481:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	ba 00 00 00 00       	mov    $0x0,%edx
  80048b:	0f 49 d0             	cmovns %eax,%edx
  80048e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	e9 6a ff ff ff       	jmp    800403 <vprintfmt+0x35>
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80049c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a3:	e9 5b ff ff ff       	jmp    800403 <vprintfmt+0x35>
  8004a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ae:	eb bc                	jmp    80046c <vprintfmt+0x9e>
			lflag++;
  8004b0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b6:	e9 48 ff ff ff       	jmp    800403 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 78 04             	lea    0x4(%eax),%edi
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	ff 30                	pushl  (%eax)
  8004c7:	ff d6                	call   *%esi
			break;
  8004c9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004cc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004cf:	e9 cf 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 78 04             	lea    0x4(%eax),%edi
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	99                   	cltd   
  8004dd:	31 d0                	xor    %edx,%eax
  8004df:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e1:	83 f8 0f             	cmp    $0xf,%eax
  8004e4:	7f 23                	jg     800509 <vprintfmt+0x13b>
  8004e6:	8b 14 85 00 2d 80 00 	mov    0x802d00(,%eax,4),%edx
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 18                	je     800509 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004f1:	52                   	push   %edx
  8004f2:	68 61 2f 80 00       	push   $0x802f61
  8004f7:	53                   	push   %ebx
  8004f8:	56                   	push   %esi
  8004f9:	e8 b3 fe ff ff       	call   8003b1 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800501:	89 7d 14             	mov    %edi,0x14(%ebp)
  800504:	e9 9a 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 73 2a 80 00       	push   $0x802a73
  80050f:	53                   	push   %ebx
  800510:	56                   	push   %esi
  800511:	e8 9b fe ff ff       	call   8003b1 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800519:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 82 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	83 c0 04             	add    $0x4,%eax
  800527:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052f:	85 ff                	test   %edi,%edi
  800531:	b8 6c 2a 80 00       	mov    $0x802a6c,%eax
  800536:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800539:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053d:	0f 8e bd 00 00 00    	jle    800600 <vprintfmt+0x232>
  800543:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800547:	75 0e                	jne    800557 <vprintfmt+0x189>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 6d                	jmp    8005c4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 d0             	pushl  -0x30(%ebp)
  80055d:	57                   	push   %edi
  80055e:	e8 6e 03 00 00       	call   8008d1 <strnlen>
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800572:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800575:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800578:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80057a:	eb 0f                	jmp    80058b <vprintfmt+0x1bd>
					putch(padc, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	83 ef 01             	sub    $0x1,%edi
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	85 ff                	test   %edi,%edi
  80058d:	7f ed                	jg     80057c <vprintfmt+0x1ae>
  80058f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800592:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800595:	85 c9                	test   %ecx,%ecx
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	0f 49 c1             	cmovns %ecx,%eax
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005aa:	89 cb                	mov    %ecx,%ebx
  8005ac:	eb 16                	jmp    8005c4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b2:	75 31                	jne    8005e5 <vprintfmt+0x217>
					putch(ch, putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ba:	50                   	push   %eax
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 59                	je     80062b <vprintfmt+0x25d>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 d8                	js     8005ae <vprintfmt+0x1e0>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 d3                	jns    8005ae <vprintfmt+0x1e0>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	eb 37                	jmp    80061c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	0f be d2             	movsbl %dl,%edx
  8005e8:	83 ea 20             	sub    $0x20,%edx
  8005eb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ee:	76 c4                	jbe    8005b4 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	6a 3f                	push   $0x3f
  8005f8:	ff 55 08             	call   *0x8(%ebp)
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	eb c1                	jmp    8005c1 <vprintfmt+0x1f3>
  800600:	89 75 08             	mov    %esi,0x8(%ebp)
  800603:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800606:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800609:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060c:	eb b6                	jmp    8005c4 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 20                	push   $0x20
  800614:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f ee                	jg     80060e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800620:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
  800626:	e9 78 01 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	eb e7                	jmp    80061c <vprintfmt+0x24e>
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 3f                	jle    800679 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800651:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800655:	79 5c                	jns    8006b3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 2d                	push   $0x2d
  80065d:	ff d6                	call   *%esi
				num = -(long long) num;
  80065f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800662:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800665:	f7 da                	neg    %edx
  800667:	83 d1 00             	adc    $0x0,%ecx
  80066a:	f7 d9                	neg    %ecx
  80066c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 10 01 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	75 1b                	jne    800698 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 c1                	mov    %eax,%ecx
  800687:	c1 f9 1f             	sar    $0x1f,%ecx
  80068a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb b9                	jmp    800651 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 c1                	mov    %eax,%ecx
  8006a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b1:	eb 9e                	jmp    800651 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 c6 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7e 18                	jle    8006e0 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	8d 40 08             	lea    0x8(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006db:	e9 a9 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	75 1a                	jne    8006fe <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f9:	e9 8b 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	eb 74                	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800715:	83 f9 01             	cmp    $0x1,%ecx
  800718:	7e 15                	jle    80072f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
  80072d:	eb 5a                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	75 17                	jne    80074a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800743:	b8 08 00 00 00       	mov    $0x8,%eax
  800748:	eb 3f                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80075a:	b8 08 00 00 00       	mov    $0x8,%eax
  80075f:	eb 28                	jmp    800789 <vprintfmt+0x3bb>
			putch('0', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 30                	push   $0x30
  800767:	ff d6                	call   *%esi
			putch('x', putdat);
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 78                	push   $0x78
  80076f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8b 10                	mov    (%eax),%edx
  800776:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800784:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800789:	83 ec 0c             	sub    $0xc,%esp
  80078c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800790:	57                   	push   %edi
  800791:	ff 75 e0             	pushl  -0x20(%ebp)
  800794:	50                   	push   %eax
  800795:	51                   	push   %ecx
  800796:	52                   	push   %edx
  800797:	89 da                	mov    %ebx,%edx
  800799:	89 f0                	mov    %esi,%eax
  80079b:	e8 45 fb ff ff       	call   8002e5 <printnum>
			break;
  8007a0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a6:	83 c7 01             	add    $0x1,%edi
  8007a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007ad:	83 f8 25             	cmp    $0x25,%eax
  8007b0:	0f 84 2f fc ff ff    	je     8003e5 <vprintfmt+0x17>
			if (ch == '\0')
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	0f 84 8b 00 00 00    	je     800849 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	50                   	push   %eax
  8007c3:	ff d6                	call   *%esi
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	eb dc                	jmp    8007a6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 15                	jle    8007e4 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e2:	eb a5                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	75 17                	jne    8007ff <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fd:	eb 8a                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
  800814:	e9 70 ff ff ff       	jmp    800789 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			break;
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	e9 7a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	53                   	push   %ebx
  80082d:	6a 25                	push   $0x25
  80082f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	89 f8                	mov    %edi,%eax
  800836:	eb 03                	jmp    80083b <vprintfmt+0x46d>
  800838:	83 e8 01             	sub    $0x1,%eax
  80083b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083f:	75 f7                	jne    800838 <vprintfmt+0x46a>
  800841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800844:	e9 5a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
}
  800849:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 18             	sub    $0x18,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 26                	je     800898 <vsnprintf+0x47>
  800872:	85 d2                	test   %edx,%edx
  800874:	7e 22                	jle    800898 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	ff 75 14             	pushl  0x14(%ebp)
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	68 94 03 80 00       	push   $0x800394
  800885:	e8 44 fb ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 c4 10             	add    $0x10,%esp
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		return -E_INVAL;
  800898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089d:	eb f7                	jmp    800896 <vsnprintf+0x45>

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 9a ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 03                	jmp    8008c9 <strlen+0x10>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cd:	75 f7                	jne    8008c6 <strlen+0xd>
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
  8008df:	eb 03                	jmp    8008e4 <strnlen+0x13>
		n++;
  8008e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	74 06                	je     8008ee <strnlen+0x1d>
  8008e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ec:	75 f3                	jne    8008e1 <strnlen+0x10>
	return n;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	83 c2 01             	add    $0x1,%edx
  800902:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800906:	88 5a ff             	mov    %bl,-0x1(%edx)
  800909:	84 db                	test   %bl,%bl
  80090b:	75 ef                	jne    8008fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800917:	53                   	push   %ebx
  800918:	e8 9c ff ff ff       	call   8008b9 <strlen>
  80091d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	01 d8                	add    %ebx,%eax
  800925:	50                   	push   %eax
  800926:	e8 c5 ff ff ff       	call   8008f0 <strcpy>
	return dst;
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 17                	jmp    800990 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 07                	je     80098d <strlcpy+0x2e>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
		*dst = '\0';
  80098d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strcmp+0x11>
		p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x1c>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 ef                	je     8009a1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	29 d0                	sub    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strncmp+0x17>
		n--, p++, q++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 16                	je     8009ed <strncmp+0x31>
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	84 c9                	test   %cl,%cl
  8009dc:	74 04                	je     8009e2 <strncmp+0x26>
  8009de:	3a 0a                	cmp    (%edx),%cl
  8009e0:	74 eb                	je     8009cd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
		return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	eb f6                	jmp    8009ea <strncmp+0x2e>

008009f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	84 d2                	test   %dl,%dl
  800a03:	74 09                	je     800a0e <strchr+0x1a>
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 0a                	je     800a13 <strchr+0x1f>
	for (; *s; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f0                	jmp    8009fe <strchr+0xa>
			return (char *) s;
	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1f:	eb 03                	jmp    800a24 <strfind+0xf>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 04                	je     800a2f <strfind+0x1a>
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0xc>
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3d:	85 c9                	test   %ecx,%ecx
  800a3f:	74 13                	je     800a54 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a47:	75 05                	jne    800a4e <memset+0x1d>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	74 0d                	je     800a5b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    
		c &= 0xFF;
  800a5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	c1 e0 18             	shl    $0x18,%eax
  800a69:	89 d6                	mov    %edx,%esi
  800a6b:	c1 e6 10             	shl    $0x10,%esi
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb d6                	jmp    800a54 <memset+0x23>

00800a7e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8c:	39 c6                	cmp    %eax,%esi
  800a8e:	73 35                	jae    800ac5 <memmove+0x47>
  800a90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a93:	39 c2                	cmp    %eax,%edx
  800a95:	76 2e                	jbe    800ac5 <memmove+0x47>
		s += n;
		d += n;
  800a97:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	09 fe                	or     %edi,%esi
  800a9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa4:	74 0c                	je     800ab2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 21                	jmp    800ad3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 ef                	jne    800aa6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab7:	83 ef 04             	sub    $0x4,%edi
  800aba:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac0:	fd                   	std    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb ea                	jmp    800aaf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 f2                	mov    %esi,%edx
  800ac7:	09 c2                	or     %eax,%edx
  800ac9:	f6 c2 03             	test   $0x3,%dl
  800acc:	74 09                	je     800ad7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 f2                	jne    800ace <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb ed                	jmp    800ad3 <memmove+0x55>

00800ae6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	e8 87 ff ff ff       	call   800a7e <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 f0                	cmp    %esi,%eax
  800b0b:	74 1c                	je     800b29 <memcmp+0x30>
		if (*s1 != *s2)
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	0f b6 1a             	movzbl (%edx),%ebx
  800b13:	38 d9                	cmp    %bl,%cl
  800b15:	75 08                	jne    800b1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	83 c2 01             	add    $0x1,%edx
  800b1d:	eb ea                	jmp    800b09 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 05                	jmp    800b2e <memcmp+0x35>
	}

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 09                	jae    800b4d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	38 08                	cmp    %cl,(%eax)
  800b46:	74 05                	je     800b4d <memfind+0x1b>
	for (; s < ends; s++)
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	eb f3                	jmp    800b40 <memfind+0xe>
			break;
	return (void *) s;
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	eb 03                	jmp    800b60 <strtol+0x11>
		s++;
  800b5d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b60:	0f b6 01             	movzbl (%ecx),%eax
  800b63:	3c 20                	cmp    $0x20,%al
  800b65:	74 f6                	je     800b5d <strtol+0xe>
  800b67:	3c 09                	cmp    $0x9,%al
  800b69:	74 f2                	je     800b5d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6b:	3c 2b                	cmp    $0x2b,%al
  800b6d:	74 2e                	je     800b9d <strtol+0x4e>
	int neg = 0;
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b74:	3c 2d                	cmp    $0x2d,%al
  800b76:	74 2f                	je     800ba7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7e:	75 05                	jne    800b85 <strtol+0x36>
  800b80:	80 39 30             	cmpb   $0x30,(%ecx)
  800b83:	74 2c                	je     800bb1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	75 0a                	jne    800b93 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b89:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b91:	74 28                	je     800bbb <strtol+0x6c>
		base = 10;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9b:	eb 50                	jmp    800bed <strtol+0x9e>
		s++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb d1                	jmp    800b78 <strtol+0x29>
		s++, neg = 1;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	bf 01 00 00 00       	mov    $0x1,%edi
  800baf:	eb c7                	jmp    800b78 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb5:	74 0e                	je     800bc5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 d8                	jne    800b93 <strtol+0x44>
		s++, base = 8;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc3:	eb ce                	jmp    800b93 <strtol+0x44>
		s += 2, base = 16;
  800bc5:	83 c1 02             	add    $0x2,%ecx
  800bc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcd:	eb c4                	jmp    800b93 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bcf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 29                	ja     800c02 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be2:	7d 30                	jge    800c14 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800beb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bed:	0f b6 11             	movzbl (%ecx),%edx
  800bf0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	80 fb 09             	cmp    $0x9,%bl
  800bf8:	77 d5                	ja     800bcf <strtol+0x80>
			dig = *s - '0';
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	83 ea 30             	sub    $0x30,%edx
  800c00:	eb dd                	jmp    800bdf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c05:	89 f3                	mov    %esi,%ebx
  800c07:	80 fb 19             	cmp    $0x19,%bl
  800c0a:	77 08                	ja     800c14 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0c:	0f be d2             	movsbl %dl,%edx
  800c0f:	83 ea 37             	sub    $0x37,%edx
  800c12:	eb cb                	jmp    800bdf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 05                	je     800c1f <strtol+0xd0>
		*endptr = (char *) s;
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	f7 da                	neg    %edx
  800c23:	85 ff                	test   %edi,%edi
  800c25:	0f 45 c2             	cmovne %edx,%eax
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	89 c3                	mov    %eax,%ebx
  800c40:	89 c7                	mov    %eax,%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	89 d1                	mov    %edx,%ecx
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	89 d7                	mov    %edx,%edi
  800c61:	89 d6                	mov    %edx,%esi
  800c63:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c80:	89 cb                	mov    %ecx,%ebx
  800c82:	89 cf                	mov    %ecx,%edi
  800c84:	89 ce                	mov    %ecx,%esi
  800c86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7f 08                	jg     800c94 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 03                	push   $0x3
  800c9a:	68 5f 2d 80 00       	push   $0x802d5f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 7c 2d 80 00       	push   $0x802d7c
  800ca6:	e8 4b f5 ff ff       	call   8001f6 <_panic>

00800cab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	89 d3                	mov    %edx,%ebx
  800cbf:	89 d7                	mov    %edx,%edi
  800cc1:	89 d6                	mov    %edx,%esi
  800cc3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_yield>:

void
sys_yield(void)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf2:	be 00 00 00 00       	mov    $0x0,%esi
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	89 f7                	mov    %esi,%edi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 04                	push   $0x4
  800d1b:	68 5f 2d 80 00       	push   $0x802d5f
  800d20:	6a 23                	push   $0x23
  800d22:	68 7c 2d 80 00       	push   $0x802d7c
  800d27:	e8 ca f4 ff ff       	call   8001f6 <_panic>

00800d2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	8b 75 18             	mov    0x18(%ebp),%esi
  800d49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7f 08                	jg     800d57 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 05                	push   $0x5
  800d5d:	68 5f 2d 80 00       	push   $0x802d5f
  800d62:	6a 23                	push   $0x23
  800d64:	68 7c 2d 80 00       	push   $0x802d7c
  800d69:	e8 88 f4 ff ff       	call   8001f6 <_panic>

00800d6e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	b8 06 00 00 00       	mov    $0x6,%eax
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7f 08                	jg     800d99 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 06                	push   $0x6
  800d9f:	68 5f 2d 80 00       	push   $0x802d5f
  800da4:	6a 23                	push   $0x23
  800da6:	68 7c 2d 80 00       	push   $0x802d7c
  800dab:	e8 46 f4 ff ff       	call   8001f6 <_panic>

00800db0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 de                	mov    %ebx,%esi
  800dcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7f 08                	jg     800ddb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	50                   	push   %eax
  800ddf:	6a 08                	push   $0x8
  800de1:	68 5f 2d 80 00       	push   $0x802d5f
  800de6:	6a 23                	push   $0x23
  800de8:	68 7c 2d 80 00       	push   $0x802d7c
  800ded:	e8 04 f4 ff ff       	call   8001f6 <_panic>

00800df2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7f 08                	jg     800e1d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 09                	push   $0x9
  800e23:	68 5f 2d 80 00       	push   $0x802d5f
  800e28:	6a 23                	push   $0x23
  800e2a:	68 7c 2d 80 00       	push   $0x802d7c
  800e2f:	e8 c2 f3 ff ff       	call   8001f6 <_panic>

00800e34 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4d:	89 df                	mov    %ebx,%edi
  800e4f:	89 de                	mov    %ebx,%esi
  800e51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7f 08                	jg     800e5f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0a                	push   $0xa
  800e65:	68 5f 2d 80 00       	push   $0x802d5f
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 7c 2d 80 00       	push   $0x802d7c
  800e71:	e8 80 f3 ff ff       	call   8001f6 <_panic>

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e87:	be 00 00 00 00       	mov    $0x0,%esi
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7f 08                	jg     800ec3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 0d                	push   $0xd
  800ec9:	68 5f 2d 80 00       	push   $0x802d5f
  800ece:	6a 23                	push   $0x23
  800ed0:	68 7c 2d 80 00       	push   $0x802d7c
  800ed5:	e8 1c f3 ff ff       	call   8001f6 <_panic>

00800eda <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	53                   	push   %ebx
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ee4:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800ee6:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800ee9:	a8 02                	test   $0x2,%al
  800eeb:	0f 84 89 00 00 00    	je     800f7a <pgfault+0xa0>
  800ef1:	89 da                	mov    %ebx,%edx
  800ef3:	c1 ea 0c             	shr    $0xc,%edx
  800ef6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800efd:	f6 c6 08             	test   $0x8,%dh
  800f00:	74 78                	je     800f7a <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	6a 07                	push   $0x7
  800f07:	68 00 f0 7f 00       	push   $0x7ff000
  800f0c:	6a 00                	push   $0x0
  800f0e:	e8 d6 fd ff ff       	call   800ce9 <sys_page_alloc>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	0f 88 8b 00 00 00    	js     800fa9 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	68 00 10 00 00       	push   $0x1000
  800f26:	53                   	push   %ebx
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	e8 4d fb ff ff       	call   800a7e <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f31:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f38:	53                   	push   %ebx
  800f39:	6a 00                	push   $0x0
  800f3b:	68 00 f0 7f 00       	push   $0x7ff000
  800f40:	6a 00                	push   $0x0
  800f42:	e8 e5 fd ff ff       	call   800d2c <sys_page_map>
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 6d                	js     800fbb <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	68 00 f0 7f 00       	push   $0x7ff000
  800f56:	6a 00                	push   $0x0
  800f58:	e8 11 fe ff ff       	call   800d6e <sys_page_unmap>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	78 69                	js     800fcd <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	53                   	push   %ebx
  800f68:	68 e8 2d 80 00       	push   $0x802de8
  800f6d:	e8 5f f3 ff ff       	call   8002d1 <cprintf>

}
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800f7a:	8b 15 04 50 80 00    	mov    0x805004,%edx
  800f80:	8b 4a 48             	mov    0x48(%edx),%ecx
  800f83:	89 da                	mov    %ebx,%edx
  800f85:	c1 ea 0c             	shr    $0xc,%edx
  800f88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8f:	51                   	push   %ecx
  800f90:	53                   	push   %ebx
  800f91:	68 00 00 40 ef       	push   $0xef400000
  800f96:	52                   	push   %edx
  800f97:	50                   	push   %eax
  800f98:	68 8c 2d 80 00       	push   $0x802d8c
  800f9d:	6a 1e                	push   $0x1e
  800f9f:	68 09 2e 80 00       	push   $0x802e09
  800fa4:	e8 4d f2 ff ff       	call   8001f6 <_panic>
        panic("sys_page_alloc error %e", r);
  800fa9:	50                   	push   %eax
  800faa:	68 14 2e 80 00       	push   $0x802e14
  800faf:	6a 28                	push   $0x28
  800fb1:	68 09 2e 80 00       	push   $0x802e09
  800fb6:	e8 3b f2 ff ff       	call   8001f6 <_panic>
        panic("sys_page_map error %e", r);
  800fbb:	50                   	push   %eax
  800fbc:	68 2c 2e 80 00       	push   $0x802e2c
  800fc1:	6a 2b                	push   $0x2b
  800fc3:	68 09 2e 80 00       	push   $0x802e09
  800fc8:	e8 29 f2 ff ff       	call   8001f6 <_panic>
        panic("sys_page_unmap error %e", r);
  800fcd:	50                   	push   %eax
  800fce:	68 42 2e 80 00       	push   $0x802e42
  800fd3:	6a 2d                	push   $0x2d
  800fd5:	68 09 2e 80 00       	push   $0x802e09
  800fda:	e8 17 f2 ff ff       	call   8001f6 <_panic>

00800fdf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fe5:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  800fec:	74 23                	je     801011 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	a3 08 50 80 00       	mov    %eax,0x805008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800ff6:	a1 04 50 80 00       	mov    0x805004,%eax
  800ffb:	8b 40 48             	mov    0x48(%eax),%eax
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	68 e4 25 80 00       	push   $0x8025e4
  801006:	50                   	push   %eax
  801007:	e8 28 fe ff ff       	call   800e34 <sys_env_set_pgfault_upcall>
}
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	c9                   	leave  
  801010:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801011:	a1 04 50 80 00       	mov    0x805004,%eax
  801016:	8b 40 48             	mov    0x48(%eax),%eax
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	6a 07                	push   $0x7
  80101e:	68 00 f0 bf ee       	push   $0xeebff000
  801023:	50                   	push   %eax
  801024:	e8 c0 fc ff ff       	call   800ce9 <sys_page_alloc>
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	79 be                	jns    800fee <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  801030:	50                   	push   %eax
  801031:	68 8c 29 80 00       	push   $0x80298c
  801036:	6a 21                	push   $0x21
  801038:	68 5a 2e 80 00       	push   $0x802e5a
  80103d:	e8 b4 f1 ff ff       	call   8001f6 <_panic>

00801042 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	8b 75 08             	mov    0x8(%ebp),%esi
  80104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80104d:	83 ec 04             	sub    $0x4,%esp
  801050:	6a 07                	push   $0x7
  801052:	53                   	push   %ebx
  801053:	56                   	push   %esi
  801054:	e8 90 fc ff ff       	call   800ce9 <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	78 4a                	js     8010aa <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	6a 07                	push   $0x7
  801065:	68 00 00 40 00       	push   $0x400000
  80106a:	6a 00                	push   $0x0
  80106c:	53                   	push   %ebx
  80106d:	56                   	push   %esi
  80106e:	e8 b9 fc ff ff       	call   800d2c <sys_page_map>
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 42                	js     8010bc <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  80107a:	83 ec 04             	sub    $0x4,%esp
  80107d:	68 00 10 00 00       	push   $0x1000
  801082:	53                   	push   %ebx
  801083:	68 00 00 40 00       	push   $0x400000
  801088:	e8 f1 f9 ff ff       	call   800a7e <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	68 00 00 40 00       	push   $0x400000
  801095:	6a 00                	push   $0x0
  801097:	e8 d2 fc ff ff       	call   800d6e <sys_page_unmap>
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 2b                	js     8010ce <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  8010a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  8010aa:	50                   	push   %eax
  8010ab:	68 8c 29 80 00       	push   $0x80298c
  8010b0:	6a 63                	push   $0x63
  8010b2:	68 09 2e 80 00       	push   $0x802e09
  8010b7:	e8 3a f1 ff ff       	call   8001f6 <_panic>
        panic("sys_page_map: %e", r);
  8010bc:	50                   	push   %eax
  8010bd:	68 6a 2e 80 00       	push   $0x802e6a
  8010c2:	6a 65                	push   $0x65
  8010c4:	68 09 2e 80 00       	push   $0x802e09
  8010c9:	e8 28 f1 ff ff       	call   8001f6 <_panic>
        panic("sys_page_unmap: %e", r);
  8010ce:	50                   	push   %eax
  8010cf:	68 7b 2e 80 00       	push   $0x802e7b
  8010d4:	6a 68                	push   $0x68
  8010d6:	68 09 2e 80 00       	push   $0x802e09
  8010db:	e8 16 f1 ff ff       	call   8001f6 <_panic>

008010e0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  8010e9:	a1 04 50 80 00       	mov    0x805004,%eax
  8010ee:	8b 40 64             	mov    0x64(%eax),%eax
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	74 1f                	je     801114 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010f5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010fa:	cd 30                	int    $0x30
  8010fc:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  8010fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801101:	85 c0                	test   %eax,%eax
  801103:	74 21                	je     801126 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801105:	be 08 50 80 00       	mov    $0x805008,%esi
  80110a:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	eb 7b                	jmp    80118f <fork+0xaf>
        set_pgfault_handler(pgfault);
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	68 da 0e 80 00       	push   $0x800eda
  80111c:	e8 be fe ff ff       	call   800fdf <set_pgfault_handler>
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	eb cf                	jmp    8010f5 <fork+0x15>
        set_pgfault_handler(pgfault);
  801126:	83 ec 0c             	sub    $0xc,%esp
  801129:	68 da 0e 80 00       	push   $0x800eda
  80112e:	e8 ac fe ff ff       	call   800fdf <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801133:	e8 73 fb ff ff       	call   800cab <sys_getenvid>
  801138:	25 ff 03 00 00       	and    $0x3ff,%eax
  80113d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801140:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801145:	a3 04 50 80 00       	mov    %eax,0x805004
        return 0;
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	e9 ca 00 00 00       	jmp    80121c <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801152:	89 d1                	mov    %edx,%ecx
  801154:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  80115a:	81 e2 02 08 00 00    	and    $0x802,%edx
  801160:	89 cf                	mov    %ecx,%edi
  801162:	81 cf 00 08 00 00    	or     $0x800,%edi
  801168:	85 d2                	test   %edx,%edx
  80116a:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	51                   	push   %ecx
  801171:	50                   	push   %eax
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	50                   	push   %eax
  801176:	6a 00                	push   $0x0
  801178:	e8 af fb ff ff       	call   800d2c <sys_page_map>
  80117d:	83 c4 20             	add    $0x20,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 45                	js     8011c9 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801184:	83 c3 01             	add    $0x1,%ebx
  801187:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  80118d:	74 4c                	je     8011db <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  80118f:	39 de                	cmp    %ebx,%esi
  801191:	74 f1                	je     801184 <fork+0xa4>
  801193:	89 d8                	mov    %ebx,%eax
  801195:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  801198:	89 c2                	mov    %eax,%edx
  80119a:	c1 ea 16             	shr    $0x16,%edx
  80119d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8011a4:	f6 c2 05             	test   $0x5,%dl
  8011a7:	74 db                	je     801184 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	c1 ea 0c             	shr    $0xc,%edx
  8011ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8011b5:	f6 c2 04             	test   $0x4,%dl
  8011b8:	74 ca                	je     801184 <fork+0xa4>
    if (perm & PTE_SHARE) {
  8011ba:	f6 c6 04             	test   $0x4,%dh
  8011bd:	74 93                	je     801152 <fork+0x72>
        perm &= ~PTE_COW;
  8011bf:	89 d1                	mov    %edx,%ecx
  8011c1:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8011c7:	eb a4                	jmp    80116d <fork+0x8d>
        panic("sys_page_map error %e", r);
  8011c9:	50                   	push   %eax
  8011ca:	68 2c 2e 80 00       	push   $0x802e2c
  8011cf:	6a 57                	push   $0x57
  8011d1:	68 09 2e 80 00       	push   $0x802e09
  8011d6:	e8 1b f0 ff ff       	call   8001f6 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	b8 08 50 80 00       	mov    $0x805008,%eax
  8011e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ec:	e8 51 fe ff ff       	call   801042 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8011f1:	83 c4 08             	add    $0x8,%esp
  8011f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fc:	50                   	push   %eax
  8011fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801200:	e8 3d fe ff ff       	call   801042 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801205:	83 c4 08             	add    $0x8,%esp
  801208:	6a 02                	push   $0x2
  80120a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80120d:	e8 9e fb ff ff       	call   800db0 <sys_env_set_status>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	85 c0                	test   %eax,%eax
  801217:	78 0d                	js     801226 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801219:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801226:	50                   	push   %eax
  801227:	68 8e 2e 80 00       	push   $0x802e8e
  80122c:	68 a0 00 00 00       	push   $0xa0
  801231:	68 09 2e 80 00       	push   $0x802e09
  801236:	e8 bb ef ff ff       	call   8001f6 <_panic>

0080123b <sfork>:

// Challenge!
int
sfork(void)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801241:	68 a5 2e 80 00       	push   $0x802ea5
  801246:	68 a9 00 00 00       	push   $0xa9
  80124b:	68 09 2e 80 00       	push   $0x802e09
  801250:	e8 a1 ef ff ff       	call   8001f6 <_panic>

00801255 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801258:	8b 45 08             	mov    0x8(%ebp),%eax
  80125b:	05 00 00 00 30       	add    $0x30000000,%eax
  801260:	c1 e8 0c             	shr    $0xc,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801270:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801275:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801282:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801293:	f6 c2 01             	test   $0x1,%dl
  801296:	74 2a                	je     8012c2 <fd_alloc+0x46>
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 ea 0c             	shr    $0xc,%edx
  80129d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a4:	f6 c2 01             	test   $0x1,%dl
  8012a7:	74 19                	je     8012c2 <fd_alloc+0x46>
  8012a9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012ae:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012b3:	75 d2                	jne    801287 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012b5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012c0:	eb 07                	jmp    8012c9 <fd_alloc+0x4d>
			*fd_store = fd;
  8012c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d1:	83 f8 1f             	cmp    $0x1f,%eax
  8012d4:	77 36                	ja     80130c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d6:	c1 e0 0c             	shl    $0xc,%eax
  8012d9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012de:	89 c2                	mov    %eax,%edx
  8012e0:	c1 ea 16             	shr    $0x16,%edx
  8012e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	74 24                	je     801313 <fd_lookup+0x48>
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	c1 ea 0c             	shr    $0xc,%edx
  8012f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 1a                	je     80131a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801300:	8b 55 0c             	mov    0xc(%ebp),%edx
  801303:	89 02                	mov    %eax,(%edx)
	return 0;
  801305:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
		return -E_INVAL;
  80130c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801311:	eb f7                	jmp    80130a <fd_lookup+0x3f>
		return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801318:	eb f0                	jmp    80130a <fd_lookup+0x3f>
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131f:	eb e9                	jmp    80130a <fd_lookup+0x3f>

00801321 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132a:	ba 38 2f 80 00       	mov    $0x802f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80132f:	b8 0c 40 80 00       	mov    $0x80400c,%eax
		if (devtab[i]->dev_id == dev_id) {
  801334:	39 08                	cmp    %ecx,(%eax)
  801336:	74 33                	je     80136b <dev_lookup+0x4a>
  801338:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80133b:	8b 02                	mov    (%edx),%eax
  80133d:	85 c0                	test   %eax,%eax
  80133f:	75 f3                	jne    801334 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801341:	a1 04 50 80 00       	mov    0x805004,%eax
  801346:	8b 40 48             	mov    0x48(%eax),%eax
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	51                   	push   %ecx
  80134d:	50                   	push   %eax
  80134e:	68 bc 2e 80 00       	push   $0x802ebc
  801353:	e8 79 ef ff ff       	call   8002d1 <cprintf>
	*dev = 0;
  801358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801369:	c9                   	leave  
  80136a:	c3                   	ret    
			*dev = devtab[i];
  80136b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	eb f2                	jmp    801369 <dev_lookup+0x48>

00801377 <fd_close>:
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	83 ec 1c             	sub    $0x1c,%esp
  801380:	8b 75 08             	mov    0x8(%ebp),%esi
  801383:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801386:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801389:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80138a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801393:	50                   	push   %eax
  801394:	e8 32 ff ff ff       	call   8012cb <fd_lookup>
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 05                	js     8013a7 <fd_close+0x30>
	    || fd != fd2)
  8013a2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013a5:	74 16                	je     8013bd <fd_close+0x46>
		return (must_exist ? r : 0);
  8013a7:	89 f8                	mov    %edi,%eax
  8013a9:	84 c0                	test   %al,%al
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	0f 44 d8             	cmove  %eax,%ebx
}
  8013b3:	89 d8                	mov    %ebx,%eax
  8013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013c3:	50                   	push   %eax
  8013c4:	ff 36                	pushl  (%esi)
  8013c6:	e8 56 ff ff ff       	call   801321 <dev_lookup>
  8013cb:	89 c3                	mov    %eax,%ebx
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 15                	js     8013e9 <fd_close+0x72>
		if (dev->dev_close)
  8013d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d7:	8b 40 10             	mov    0x10(%eax),%eax
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	74 1b                	je     8013f9 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013de:	83 ec 0c             	sub    $0xc,%esp
  8013e1:	56                   	push   %esi
  8013e2:	ff d0                	call   *%eax
  8013e4:	89 c3                	mov    %eax,%ebx
  8013e6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	56                   	push   %esi
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 7a f9 ff ff       	call   800d6e <sys_page_unmap>
	return r;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	eb ba                	jmp    8013b3 <fd_close+0x3c>
			r = 0;
  8013f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fe:	eb e9                	jmp    8013e9 <fd_close+0x72>

00801400 <close>:

int
close(int fdnum)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801406:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801409:	50                   	push   %eax
  80140a:	ff 75 08             	pushl  0x8(%ebp)
  80140d:	e8 b9 fe ff ff       	call   8012cb <fd_lookup>
  801412:	83 c4 08             	add    $0x8,%esp
  801415:	85 c0                	test   %eax,%eax
  801417:	78 10                	js     801429 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801419:	83 ec 08             	sub    $0x8,%esp
  80141c:	6a 01                	push   $0x1
  80141e:	ff 75 f4             	pushl  -0xc(%ebp)
  801421:	e8 51 ff ff ff       	call   801377 <fd_close>
  801426:	83 c4 10             	add    $0x10,%esp
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <close_all>:

void
close_all(void)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	53                   	push   %ebx
  80142f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801432:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	53                   	push   %ebx
  80143b:	e8 c0 ff ff ff       	call   801400 <close>
	for (i = 0; i < MAXFD; i++)
  801440:	83 c3 01             	add    $0x1,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	83 fb 20             	cmp    $0x20,%ebx
  801449:	75 ec                	jne    801437 <close_all+0xc>
}
  80144b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	57                   	push   %edi
  801454:	56                   	push   %esi
  801455:	53                   	push   %ebx
  801456:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801459:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 66 fe ff ff       	call   8012cb <fd_lookup>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	0f 88 81 00 00 00    	js     8014f3 <dup+0xa3>
		return r;
	close(newfdnum);
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	ff 75 0c             	pushl  0xc(%ebp)
  801478:	e8 83 ff ff ff       	call   801400 <close>

	newfd = INDEX2FD(newfdnum);
  80147d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801480:	c1 e6 0c             	shl    $0xc,%esi
  801483:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801489:	83 c4 04             	add    $0x4,%esp
  80148c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148f:	e8 d1 fd ff ff       	call   801265 <fd2data>
  801494:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801496:	89 34 24             	mov    %esi,(%esp)
  801499:	e8 c7 fd ff ff       	call   801265 <fd2data>
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	c1 e8 16             	shr    $0x16,%eax
  8014a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014af:	a8 01                	test   $0x1,%al
  8014b1:	74 11                	je     8014c4 <dup+0x74>
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	75 39                	jne    8014fd <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c7:	89 d0                	mov    %edx,%eax
  8014c9:	c1 e8 0c             	shr    $0xc,%eax
  8014cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014db:	50                   	push   %eax
  8014dc:	56                   	push   %esi
  8014dd:	6a 00                	push   $0x0
  8014df:	52                   	push   %edx
  8014e0:	6a 00                	push   $0x0
  8014e2:	e8 45 f8 ff ff       	call   800d2c <sys_page_map>
  8014e7:	89 c3                	mov    %eax,%ebx
  8014e9:	83 c4 20             	add    $0x20,%esp
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 31                	js     801521 <dup+0xd1>
		goto err;

	return newfdnum;
  8014f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	25 07 0e 00 00       	and    $0xe07,%eax
  80150c:	50                   	push   %eax
  80150d:	57                   	push   %edi
  80150e:	6a 00                	push   $0x0
  801510:	53                   	push   %ebx
  801511:	6a 00                	push   $0x0
  801513:	e8 14 f8 ff ff       	call   800d2c <sys_page_map>
  801518:	89 c3                	mov    %eax,%ebx
  80151a:	83 c4 20             	add    $0x20,%esp
  80151d:	85 c0                	test   %eax,%eax
  80151f:	79 a3                	jns    8014c4 <dup+0x74>
	sys_page_unmap(0, newfd);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	56                   	push   %esi
  801525:	6a 00                	push   $0x0
  801527:	e8 42 f8 ff ff       	call   800d6e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	57                   	push   %edi
  801530:	6a 00                	push   $0x0
  801532:	e8 37 f8 ff ff       	call   800d6e <sys_page_unmap>
	return r;
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	eb b7                	jmp    8014f3 <dup+0xa3>

0080153c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 14             	sub    $0x14,%esp
  801543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801546:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	53                   	push   %ebx
  80154b:	e8 7b fd ff ff       	call   8012cb <fd_lookup>
  801550:	83 c4 08             	add    $0x8,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 3f                	js     801596 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801561:	ff 30                	pushl  (%eax)
  801563:	e8 b9 fd ff ff       	call   801321 <dev_lookup>
  801568:	83 c4 10             	add    $0x10,%esp
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 27                	js     801596 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80156f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801572:	8b 42 08             	mov    0x8(%edx),%eax
  801575:	83 e0 03             	and    $0x3,%eax
  801578:	83 f8 01             	cmp    $0x1,%eax
  80157b:	74 1e                	je     80159b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80157d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801580:	8b 40 08             	mov    0x8(%eax),%eax
  801583:	85 c0                	test   %eax,%eax
  801585:	74 35                	je     8015bc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801587:	83 ec 04             	sub    $0x4,%esp
  80158a:	ff 75 10             	pushl  0x10(%ebp)
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	52                   	push   %edx
  801591:	ff d0                	call   *%eax
  801593:	83 c4 10             	add    $0x10,%esp
}
  801596:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801599:	c9                   	leave  
  80159a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159b:	a1 04 50 80 00       	mov    0x805004,%eax
  8015a0:	8b 40 48             	mov    0x48(%eax),%eax
  8015a3:	83 ec 04             	sub    $0x4,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	50                   	push   %eax
  8015a8:	68 fd 2e 80 00       	push   $0x802efd
  8015ad:	e8 1f ed ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ba:	eb da                	jmp    801596 <read+0x5a>
		return -E_NOT_SUPP;
  8015bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c1:	eb d3                	jmp    801596 <read+0x5a>

008015c3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d7:	39 f3                	cmp    %esi,%ebx
  8015d9:	73 25                	jae    801600 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015db:	83 ec 04             	sub    $0x4,%esp
  8015de:	89 f0                	mov    %esi,%eax
  8015e0:	29 d8                	sub    %ebx,%eax
  8015e2:	50                   	push   %eax
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	03 45 0c             	add    0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	57                   	push   %edi
  8015ea:	e8 4d ff ff ff       	call   80153c <read>
		if (m < 0)
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 08                	js     8015fe <readn+0x3b>
			return m;
		if (m == 0)
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	74 06                	je     801600 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015fa:	01 c3                	add    %eax,%ebx
  8015fc:	eb d9                	jmp    8015d7 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015fe:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801600:	89 d8                	mov    %ebx,%eax
  801602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801605:	5b                   	pop    %ebx
  801606:	5e                   	pop    %esi
  801607:	5f                   	pop    %edi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	83 ec 14             	sub    $0x14,%esp
  801611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801614:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801617:	50                   	push   %eax
  801618:	53                   	push   %ebx
  801619:	e8 ad fc ff ff       	call   8012cb <fd_lookup>
  80161e:	83 c4 08             	add    $0x8,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 3a                	js     80165f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162f:	ff 30                	pushl  (%eax)
  801631:	e8 eb fc ff ff       	call   801321 <dev_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 22                	js     80165f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801640:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801644:	74 1e                	je     801664 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801646:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801649:	8b 52 0c             	mov    0xc(%edx),%edx
  80164c:	85 d2                	test   %edx,%edx
  80164e:	74 35                	je     801685 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	ff 75 10             	pushl  0x10(%ebp)
  801656:	ff 75 0c             	pushl  0xc(%ebp)
  801659:	50                   	push   %eax
  80165a:	ff d2                	call   *%edx
  80165c:	83 c4 10             	add    $0x10,%esp
}
  80165f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801662:	c9                   	leave  
  801663:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801664:	a1 04 50 80 00       	mov    0x805004,%eax
  801669:	8b 40 48             	mov    0x48(%eax),%eax
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	53                   	push   %ebx
  801670:	50                   	push   %eax
  801671:	68 19 2f 80 00       	push   $0x802f19
  801676:	e8 56 ec ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801683:	eb da                	jmp    80165f <write+0x55>
		return -E_NOT_SUPP;
  801685:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80168a:	eb d3                	jmp    80165f <write+0x55>

0080168c <seek>:

int
seek(int fdnum, off_t offset)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801692:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	e8 2d fc ff ff       	call   8012cb <fd_lookup>
  80169e:	83 c4 08             	add    $0x8,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 0e                	js     8016b3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 14             	sub    $0x14,%esp
  8016bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	53                   	push   %ebx
  8016c4:	e8 02 fc ff ff       	call   8012cb <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 37                	js     801707 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	83 ec 08             	sub    $0x8,%esp
  8016d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	ff 30                	pushl  (%eax)
  8016dc:	e8 40 fc ff ff       	call   801321 <dev_lookup>
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 1f                	js     801707 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016eb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ef:	74 1b                	je     80170c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f4:	8b 52 18             	mov    0x18(%edx),%edx
  8016f7:	85 d2                	test   %edx,%edx
  8016f9:	74 32                	je     80172d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fb:	83 ec 08             	sub    $0x8,%esp
  8016fe:	ff 75 0c             	pushl  0xc(%ebp)
  801701:	50                   	push   %eax
  801702:	ff d2                	call   *%edx
  801704:	83 c4 10             	add    $0x10,%esp
}
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80170c:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801711:	8b 40 48             	mov    0x48(%eax),%eax
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	68 dc 2e 80 00       	push   $0x802edc
  80171e:	e8 ae eb ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172b:	eb da                	jmp    801707 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80172d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801732:	eb d3                	jmp    801707 <ftruncate+0x52>

00801734 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	53                   	push   %ebx
  801738:	83 ec 14             	sub    $0x14,%esp
  80173b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801741:	50                   	push   %eax
  801742:	ff 75 08             	pushl  0x8(%ebp)
  801745:	e8 81 fb ff ff       	call   8012cb <fd_lookup>
  80174a:	83 c4 08             	add    $0x8,%esp
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 4b                	js     80179c <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175b:	ff 30                	pushl  (%eax)
  80175d:	e8 bf fb ff ff       	call   801321 <dev_lookup>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 33                	js     80179c <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801770:	74 2f                	je     8017a1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801772:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801775:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177c:	00 00 00 
	stat->st_isdir = 0;
  80177f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801786:	00 00 00 
	stat->st_dev = dev;
  801789:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	53                   	push   %ebx
  801793:	ff 75 f0             	pushl  -0x10(%ebp)
  801796:	ff 50 14             	call   *0x14(%eax)
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    
		return -E_NOT_SUPP;
  8017a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017a6:	eb f4                	jmp    80179c <fstat+0x68>

008017a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	6a 00                	push   $0x0
  8017b2:	ff 75 08             	pushl  0x8(%ebp)
  8017b5:	e8 e7 01 00 00       	call   8019a1 <open>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 1b                	js     8017de <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	ff 75 0c             	pushl  0xc(%ebp)
  8017c9:	50                   	push   %eax
  8017ca:	e8 65 ff ff ff       	call   801734 <fstat>
  8017cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d1:	89 1c 24             	mov    %ebx,(%esp)
  8017d4:	e8 27 fc ff ff       	call   801400 <close>
	return r;
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	89 f3                	mov    %esi,%ebx
}
  8017de:	89 d8                	mov    %ebx,%eax
  8017e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5e                   	pop    %esi
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	89 c6                	mov    %eax,%esi
  8017ee:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017f7:	74 27                	je     801820 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017f9:	6a 07                	push   $0x7
  8017fb:	68 00 60 80 00       	push   $0x806000
  801800:	56                   	push   %esi
  801801:	ff 35 00 50 80 00    	pushl  0x805000
  801807:	e8 5f 0e 00 00       	call   80266b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80180c:	83 c4 0c             	add    $0xc,%esp
  80180f:	6a 00                	push   $0x0
  801811:	53                   	push   %ebx
  801812:	6a 00                	push   $0x0
  801814:	e8 f1 0d 00 00       	call   80260a <ipc_recv>
}
  801819:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	6a 01                	push   $0x1
  801825:	e8 8e 0e 00 00       	call   8026b8 <ipc_find_env>
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	eb c5                	jmp    8017f9 <fsipc+0x12>

00801834 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 02 00 00 00       	mov    $0x2,%eax
  801857:	e8 8b ff ff ff       	call   8017e7 <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_flush>:
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 40 0c             	mov    0xc(%eax),%eax
  80186a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 06 00 00 00       	mov    $0x6,%eax
  801879:	e8 69 ff ff ff       	call   8017e7 <fsipc>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_stat>:
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 40 0c             	mov    0xc(%eax),%eax
  801890:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 05 00 00 00       	mov    $0x5,%eax
  80189f:	e8 43 ff ff ff       	call   8017e7 <fsipc>
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 2c                	js     8018d4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	68 00 60 80 00       	push   $0x806000
  8018b0:	53                   	push   %ebx
  8018b1:	e8 3a f0 ff ff       	call   8008f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b6:	a1 80 60 80 00       	mov    0x806080,%eax
  8018bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c1:	a1 84 60 80 00       	mov    0x806084,%eax
  8018c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <devfile_write>:
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8018e2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ec:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f2:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f5:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  8018fb:	a3 04 60 80 00       	mov    %eax,0x806004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801900:	50                   	push   %eax
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	68 08 60 80 00       	push   $0x806008
  801909:	e8 70 f1 ff ff       	call   800a7e <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80190e:	ba 00 00 00 00       	mov    $0x0,%edx
  801913:	b8 04 00 00 00       	mov    $0x4,%eax
  801918:	e8 ca fe ff ff       	call   8017e7 <fsipc>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <devfile_read>:
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	56                   	push   %esi
  801923:	53                   	push   %ebx
  801924:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	8b 40 0c             	mov    0xc(%eax),%eax
  80192d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801932:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801938:	ba 00 00 00 00       	mov    $0x0,%edx
  80193d:	b8 03 00 00 00       	mov    $0x3,%eax
  801942:	e8 a0 fe ff ff       	call   8017e7 <fsipc>
  801947:	89 c3                	mov    %eax,%ebx
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 1f                	js     80196c <devfile_read+0x4d>
	assert(r <= n);
  80194d:	39 f0                	cmp    %esi,%eax
  80194f:	77 24                	ja     801975 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801951:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801956:	7f 33                	jg     80198b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801958:	83 ec 04             	sub    $0x4,%esp
  80195b:	50                   	push   %eax
  80195c:	68 00 60 80 00       	push   $0x806000
  801961:	ff 75 0c             	pushl  0xc(%ebp)
  801964:	e8 15 f1 ff ff       	call   800a7e <memmove>
	return r;
  801969:	83 c4 10             	add    $0x10,%esp
}
  80196c:	89 d8                	mov    %ebx,%eax
  80196e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801971:	5b                   	pop    %ebx
  801972:	5e                   	pop    %esi
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    
	assert(r <= n);
  801975:	68 48 2f 80 00       	push   $0x802f48
  80197a:	68 4f 2f 80 00       	push   $0x802f4f
  80197f:	6a 7d                	push   $0x7d
  801981:	68 64 2f 80 00       	push   $0x802f64
  801986:	e8 6b e8 ff ff       	call   8001f6 <_panic>
	assert(r <= PGSIZE);
  80198b:	68 6f 2f 80 00       	push   $0x802f6f
  801990:	68 4f 2f 80 00       	push   $0x802f4f
  801995:	6a 7e                	push   $0x7e
  801997:	68 64 2f 80 00       	push   $0x802f64
  80199c:	e8 55 e8 ff ff       	call   8001f6 <_panic>

008019a1 <open>:
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 1c             	sub    $0x1c,%esp
  8019a9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019ac:	56                   	push   %esi
  8019ad:	e8 07 ef ff ff       	call   8008b9 <strlen>
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ba:	0f 8f 96 00 00 00    	jg     801a56 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	50                   	push   %eax
  8019c7:	e8 b0 f8 ff ff       	call   80127c <fd_alloc>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 66                	js     801a3b <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	56                   	push   %esi
  8019d9:	68 00 60 80 00       	push   $0x806000
  8019de:	e8 0d ef ff ff       	call   8008f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e6:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f3:	e8 ef fd ff ff       	call   8017e7 <fsipc>
  8019f8:	89 c3                	mov    %eax,%ebx
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 43                	js     801a44 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	ff 75 f4             	pushl  -0xc(%ebp)
  801a07:	e8 49 f8 ff ff       	call   801255 <fd2num>
  801a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0f:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  801a15:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a18:	83 c4 08             	add    $0x8,%esp
  801a1b:	50                   	push   %eax
  801a1c:	52                   	push   %edx
  801a1d:	ff 32                	pushl  (%edx)
  801a1f:	56                   	push   %esi
  801a20:	51                   	push   %ecx
  801a21:	68 7c 2f 80 00       	push   $0x802f7c
  801a26:	e8 a6 e8 ff ff       	call   8002d1 <cprintf>
	return fd2num(fd);
  801a2b:	83 c4 14             	add    $0x14,%esp
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	e8 1f f8 ff ff       	call   801255 <fd2num>
  801a36:	89 c3                	mov    %eax,%ebx
  801a38:	83 c4 10             	add    $0x10,%esp
}
  801a3b:	89 d8                	mov    %ebx,%eax
  801a3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5e                   	pop    %esi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    
		fd_close(fd, 0);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	6a 00                	push   $0x0
  801a49:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4c:	e8 26 f9 ff ff       	call   801377 <fd_close>
		return r;
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb e5                	jmp    801a3b <open+0x9a>
		return -E_BAD_PATH;
  801a56:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a5b:	eb de                	jmp    801a3b <open+0x9a>

00801a5d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a63:	ba 00 00 00 00       	mov    $0x0,%edx
  801a68:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6d:	e8 75 fd ff ff       	call   8017e7 <fsipc>
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a80:	6a 00                	push   $0x0
  801a82:	ff 75 08             	pushl  0x8(%ebp)
  801a85:	e8 17 ff ff ff       	call   8019a1 <open>
  801a8a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	85 c0                	test   %eax,%eax
  801a95:	0f 88 40 03 00 00    	js     801ddb <spawn+0x367>
  801a9b:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	68 00 02 00 00       	push   $0x200
  801aa5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801aab:	50                   	push   %eax
  801aac:	51                   	push   %ecx
  801aad:	e8 11 fb ff ff       	call   8015c3 <readn>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	3d 00 02 00 00       	cmp    $0x200,%eax
  801aba:	75 5d                	jne    801b19 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  801abc:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ac3:	45 4c 46 
  801ac6:	75 51                	jne    801b19 <spawn+0xa5>
  801ac8:	b8 07 00 00 00       	mov    $0x7,%eax
  801acd:	cd 30                	int    $0x30
  801acf:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ad5:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801adb:	85 c0                	test   %eax,%eax
  801add:	0f 88 79 04 00 00    	js     801f5c <spawn+0x4e8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801ae3:	25 ff 03 00 00       	and    $0x3ff,%eax
  801ae8:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801aeb:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801af1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801af7:	b9 11 00 00 00       	mov    $0x11,%ecx
  801afc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801afe:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b04:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b0a:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801b0f:	be 00 00 00 00       	mov    $0x0,%esi
  801b14:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b17:	eb 4b                	jmp    801b64 <spawn+0xf0>
		close(fd);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801b22:	e8 d9 f8 ff ff       	call   801400 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b27:	83 c4 0c             	add    $0xc,%esp
  801b2a:	68 7f 45 4c 46       	push   $0x464c457f
  801b2f:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801b35:	68 bb 2f 80 00       	push   $0x802fbb
  801b3a:	e8 92 e7 ff ff       	call   8002d1 <cprintf>
		return -E_NOT_EXEC;
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801b49:	ff ff ff 
  801b4c:	e9 8a 02 00 00       	jmp    801ddb <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801b51:	83 ec 0c             	sub    $0xc,%esp
  801b54:	50                   	push   %eax
  801b55:	e8 5f ed ff ff       	call   8008b9 <strlen>
  801b5a:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801b5e:	83 c3 01             	add    $0x1,%ebx
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801b6b:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	75 df                	jne    801b51 <spawn+0xdd>
  801b72:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801b78:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b7e:	bf 00 10 40 00       	mov    $0x401000,%edi
  801b83:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b85:	89 fa                	mov    %edi,%edx
  801b87:	83 e2 fc             	and    $0xfffffffc,%edx
  801b8a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801b91:	29 c2                	sub    %eax,%edx
  801b93:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b99:	8d 42 f8             	lea    -0x8(%edx),%eax
  801b9c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ba1:	0f 86 c6 03 00 00    	jbe    801f6d <spawn+0x4f9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ba7:	83 ec 04             	sub    $0x4,%esp
  801baa:	6a 07                	push   $0x7
  801bac:	68 00 00 40 00       	push   $0x400000
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 31 f1 ff ff       	call   800ce9 <sys_page_alloc>
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 af 03 00 00    	js     801f72 <spawn+0x4fe>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bc3:	be 00 00 00 00       	mov    $0x0,%esi
  801bc8:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801bce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bd1:	eb 30                	jmp    801c03 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801bd3:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bd9:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801bdf:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801be2:	83 ec 08             	sub    $0x8,%esp
  801be5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801be8:	57                   	push   %edi
  801be9:	e8 02 ed ff ff       	call   8008f0 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801bee:	83 c4 04             	add    $0x4,%esp
  801bf1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801bf4:	e8 c0 ec ff ff       	call   8008b9 <strlen>
  801bf9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801bfd:	83 c6 01             	add    $0x1,%esi
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801c09:	7f c8                	jg     801bd3 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801c0b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c11:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801c17:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c1e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c24:	0f 85 8c 00 00 00    	jne    801cb6 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c2a:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801c30:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c36:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801c39:	89 f8                	mov    %edi,%eax
  801c3b:	8b 8d 88 fd ff ff    	mov    -0x278(%ebp),%ecx
  801c41:	89 4f f8             	mov    %ecx,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c44:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c49:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	6a 07                	push   $0x7
  801c54:	68 00 d0 bf ee       	push   $0xeebfd000
  801c59:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801c5f:	68 00 00 40 00       	push   $0x400000
  801c64:	6a 00                	push   $0x0
  801c66:	e8 c1 f0 ff ff       	call   800d2c <sys_page_map>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	83 c4 20             	add    $0x20,%esp
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 70 03 00 00    	js     801fe8 <spawn+0x574>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	68 00 00 40 00       	push   $0x400000
  801c80:	6a 00                	push   $0x0
  801c82:	e8 e7 f0 ff ff       	call   800d6e <sys_page_unmap>
  801c87:	89 c3                	mov    %eax,%ebx
  801c89:	83 c4 10             	add    $0x10,%esp
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	0f 88 54 03 00 00    	js     801fe8 <spawn+0x574>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801c94:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c9a:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ca1:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ca7:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801cae:	00 00 00 
  801cb1:	e9 56 01 00 00       	jmp    801e0c <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801cb6:	68 30 30 80 00       	push   $0x803030
  801cbb:	68 4f 2f 80 00       	push   $0x802f4f
  801cc0:	68 f6 00 00 00       	push   $0xf6
  801cc5:	68 d5 2f 80 00       	push   $0x802fd5
  801cca:	e8 27 e5 ff ff       	call   8001f6 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ccf:	83 ec 04             	sub    $0x4,%esp
  801cd2:	6a 07                	push   $0x7
  801cd4:	68 00 00 40 00       	push   $0x400000
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 09 f0 ff ff       	call   800ce9 <sys_page_alloc>
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	0f 88 92 02 00 00    	js     801f7d <spawn+0x509>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cf4:	01 f0                	add    %esi,%eax
  801cf6:	50                   	push   %eax
  801cf7:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801cfd:	e8 8a f9 ff ff       	call   80168c <seek>
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	0f 88 77 02 00 00    	js     801f84 <spawn+0x510>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801d0d:	83 ec 04             	sub    $0x4,%esp
  801d10:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801d16:	29 f0                	sub    %esi,%eax
  801d18:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d1d:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801d22:	0f 47 c1             	cmova  %ecx,%eax
  801d25:	50                   	push   %eax
  801d26:	68 00 00 40 00       	push   $0x400000
  801d2b:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d31:	e8 8d f8 ff ff       	call   8015c3 <readn>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 4a 02 00 00    	js     801f8b <spawn+0x517>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d41:	83 ec 0c             	sub    $0xc,%esp
  801d44:	57                   	push   %edi
  801d45:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801d4b:	56                   	push   %esi
  801d4c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d52:	68 00 00 40 00       	push   $0x400000
  801d57:	6a 00                	push   $0x0
  801d59:	e8 ce ef ff ff       	call   800d2c <sys_page_map>
  801d5e:	83 c4 20             	add    $0x20,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 80 00 00 00    	js     801de9 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801d69:	83 ec 08             	sub    $0x8,%esp
  801d6c:	68 00 00 40 00       	push   $0x400000
  801d71:	6a 00                	push   $0x0
  801d73:	e8 f6 ef ff ff       	call   800d6e <sys_page_unmap>
  801d78:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801d7b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d81:	89 de                	mov    %ebx,%esi
  801d83:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801d89:	76 73                	jbe    801dfe <spawn+0x38a>
		if (i >= filesz) {
  801d8b:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801d91:	0f 87 38 ff ff ff    	ja     801ccf <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d97:	83 ec 04             	sub    $0x4,%esp
  801d9a:	57                   	push   %edi
  801d9b:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801da1:	56                   	push   %esi
  801da2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801da8:	e8 3c ef ff ff       	call   800ce9 <sys_page_alloc>
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	79 c7                	jns    801d7b <spawn+0x307>
  801db4:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801db6:	83 ec 0c             	sub    $0xc,%esp
  801db9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dbf:	e8 a6 ee ff ff       	call   800c6a <sys_env_destroy>
	close(fd);
  801dc4:	83 c4 04             	add    $0x4,%esp
  801dc7:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801dcd:	e8 2e f6 ff ff       	call   801400 <close>
	return r;
  801dd2:	83 c4 10             	add    $0x10,%esp
  801dd5:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  801ddb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801de9:	50                   	push   %eax
  801dea:	68 e1 2f 80 00       	push   $0x802fe1
  801def:	68 29 01 00 00       	push   $0x129
  801df4:	68 d5 2f 80 00       	push   $0x802fd5
  801df9:	e8 f8 e3 ff ff       	call   8001f6 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801dfe:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801e05:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801e0c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801e13:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801e19:	7e 71                	jle    801e8c <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801e1b:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801e21:	83 3a 01             	cmpl   $0x1,(%edx)
  801e24:	75 d8                	jne    801dfe <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801e26:	8b 42 18             	mov    0x18(%edx),%eax
  801e29:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801e2c:	83 f8 01             	cmp    $0x1,%eax
  801e2f:	19 ff                	sbb    %edi,%edi
  801e31:	83 e7 fe             	and    $0xfffffffe,%edi
  801e34:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801e37:	8b 72 04             	mov    0x4(%edx),%esi
  801e3a:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801e40:	8b 5a 10             	mov    0x10(%edx),%ebx
  801e43:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801e49:	8b 42 14             	mov    0x14(%edx),%eax
  801e4c:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801e52:	8b 4a 08             	mov    0x8(%edx),%ecx
  801e55:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801e5b:	89 c8                	mov    %ecx,%eax
  801e5d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801e62:	74 1e                	je     801e82 <spawn+0x40e>
		va -= i;
  801e64:	29 c1                	sub    %eax,%ecx
  801e66:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
		memsz += i;
  801e6c:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801e72:	01 c3                	add    %eax,%ebx
  801e74:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  801e7a:	29 c6                	sub    %eax,%esi
  801e7c:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e87:	e9 f5 fe ff ff       	jmp    801d81 <spawn+0x30d>
	close(fd);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801e95:	e8 66 f5 ff ff       	call   801400 <close>
  801e9a:	83 c4 10             	add    $0x10,%esp
  801e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea2:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801ea8:	eb 12                	jmp    801ebc <spawn+0x448>
  801eaa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// LAB 5: Your code here.
    uint32_t *va;
    pte_t pte;
    int perm, r;
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801eb0:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  801eb6:	0f 84 d6 00 00 00    	je     801f92 <spawn+0x51e>
        va = (void *)(i*PGSIZE);
        if (!(uvpd[PDX(va)] & PTE_P) || !(uvpt[PGNUM(va)] & PTE_P))
  801ebc:	89 d8                	mov    %ebx,%eax
  801ebe:	c1 e8 16             	shr    $0x16,%eax
  801ec1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ec8:	a8 01                	test   $0x1,%al
  801eca:	74 de                	je     801eaa <spawn+0x436>
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	c1 e8 0c             	shr    $0xc,%eax
  801ed1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801ed8:	f6 c2 01             	test   $0x1,%dl
  801edb:	74 cd                	je     801eaa <spawn+0x436>
            continue;
        pte = (pte_t)uvpt[PGNUM(va)];
  801edd:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
        if (!(pte & PTE_SHARE))
  801ee4:	f7 c7 00 04 00 00    	test   $0x400,%edi
  801eea:	74 be                	je     801eaa <spawn+0x436>
            continue;
        cprintf("[%08x] -------- shared --------- va=%x \n", thisenv->env_id, va);
  801eec:	a1 04 50 80 00       	mov    0x805004,%eax
  801ef1:	8b 40 48             	mov    0x48(%eax),%eax
  801ef4:	83 ec 04             	sub    $0x4,%esp
  801ef7:	53                   	push   %ebx
  801ef8:	50                   	push   %eax
  801ef9:	68 58 30 80 00       	push   $0x803058
  801efe:	e8 ce e3 ff ff       	call   8002d1 <cprintf>
        perm = pte & PTE_SYSCALL;
  801f03:	81 e7 07 0e 00 00    	and    $0xe07,%edi
        if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  801f09:	89 3c 24             	mov    %edi,(%esp)
  801f0c:	53                   	push   %ebx
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 16 ee ff ff       	call   800d2c <sys_page_map>
  801f16:	83 c4 20             	add    $0x20,%esp
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	79 8d                	jns    801eaa <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  801f1d:	50                   	push   %eax
  801f1e:	68 18 30 80 00       	push   $0x803018
  801f23:	68 82 00 00 00       	push   $0x82
  801f28:	68 d5 2f 80 00       	push   $0x802fd5
  801f2d:	e8 c4 e2 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801f32:	50                   	push   %eax
  801f33:	68 fe 2f 80 00       	push   $0x802ffe
  801f38:	68 86 00 00 00       	push   $0x86
  801f3d:	68 d5 2f 80 00       	push   $0x802fd5
  801f42:	e8 af e2 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_status: %e", r);
  801f47:	50                   	push   %eax
  801f48:	68 8e 2e 80 00       	push   $0x802e8e
  801f4d:	68 89 00 00 00       	push   $0x89
  801f52:	68 d5 2f 80 00       	push   $0x802fd5
  801f57:	e8 9a e2 ff ff       	call   8001f6 <_panic>
		return r;
  801f5c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801f62:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801f68:	e9 6e fe ff ff       	jmp    801ddb <spawn+0x367>
		return -E_NO_MEM;
  801f6d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801f72:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801f78:	e9 5e fe ff ff       	jmp    801ddb <spawn+0x367>
  801f7d:	89 c7                	mov    %eax,%edi
  801f7f:	e9 32 fe ff ff       	jmp    801db6 <spawn+0x342>
  801f84:	89 c7                	mov    %eax,%edi
  801f86:	e9 2b fe ff ff       	jmp    801db6 <spawn+0x342>
  801f8b:	89 c7                	mov    %eax,%edi
  801f8d:	e9 24 fe ff ff       	jmp    801db6 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801f92:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801f99:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f9c:	83 ec 08             	sub    $0x8,%esp
  801f9f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801fa5:	50                   	push   %eax
  801fa6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fac:	e8 41 ee ff ff       	call   800df2 <sys_env_set_trapframe>
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	0f 88 76 ff ff ff    	js     801f32 <spawn+0x4be>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801fbc:	83 ec 08             	sub    $0x8,%esp
  801fbf:	6a 02                	push   $0x2
  801fc1:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801fc7:	e8 e4 ed ff ff       	call   800db0 <sys_env_set_status>
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	0f 88 70 ff ff ff    	js     801f47 <spawn+0x4d3>
	return child;
  801fd7:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801fdd:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801fe3:	e9 f3 fd ff ff       	jmp    801ddb <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  801fe8:	83 ec 08             	sub    $0x8,%esp
  801feb:	68 00 00 40 00       	push   $0x400000
  801ff0:	6a 00                	push   $0x0
  801ff2:	e8 77 ed ff ff       	call   800d6e <sys_page_unmap>
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802000:	e9 d6 fd ff ff       	jmp    801ddb <spawn+0x367>

00802005 <spawnl>:
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	57                   	push   %edi
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	83 ec 1c             	sub    $0x1c,%esp
	va_start(vl, arg0);
  80200e:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  802011:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(va_arg(vl, void *) != NULL)
  802016:	eb 05                	jmp    80201d <spawnl+0x18>
		argc++;
  802018:	83 c3 01             	add    $0x1,%ebx
	while(va_arg(vl, void *) != NULL)
  80201b:	89 d0                	mov    %edx,%eax
  80201d:	8d 50 04             	lea    0x4(%eax),%edx
  802020:	83 38 00             	cmpl   $0x0,(%eax)
  802023:	75 f3                	jne    802018 <spawnl+0x13>
	const char *argv[argc+2];
  802025:	8d 04 9d 1a 00 00 00 	lea    0x1a(,%ebx,4),%eax
  80202c:	83 e0 f0             	and    $0xfffffff0,%eax
  80202f:	29 c4                	sub    %eax,%esp
  802031:	8d 44 24 03          	lea    0x3(%esp),%eax
  802035:	c1 e8 02             	shr    $0x2,%eax
  802038:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80203f:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802042:	89 f7                	mov    %esi,%edi
	argv[0] = arg0;
  802044:	8b 55 0c             	mov    0xc(%ebp),%edx
  802047:	89 14 85 00 00 00 00 	mov    %edx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80204e:	c7 44 9e 04 00 00 00 	movl   $0x0,0x4(%esi,%ebx,4)
  802055:	00 
	va_start(vl, arg0);
  802056:	8d 75 10             	lea    0x10(%ebp),%esi
    cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[0]);
  802059:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80205f:	8b 52 48             	mov    0x48(%edx),%edx
  802062:	83 ec 04             	sub    $0x4,%esp
  802065:	ff 34 85 00 00 00 00 	pushl  0x0(,%eax,4)
  80206c:	52                   	push   %edx
  80206d:	68 84 30 80 00       	push   $0x803084
  802072:	e8 5a e2 ff ff       	call   8002d1 <cprintf>
  802077:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<argc;i++) {
  80207a:	83 c4 10             	add    $0x10,%esp
  80207d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802082:	89 f0                	mov    %esi,%eax
  802084:	89 fe                	mov    %edi,%esi
  802086:	eb 28                	jmp    8020b0 <spawnl+0xab>
        argv[i+1] = va_arg(vl, const char *);
  802088:	83 c3 01             	add    $0x1,%ebx
  80208b:	8d 78 04             	lea    0x4(%eax),%edi
  80208e:	8b 00                	mov    (%eax),%eax
  802090:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
        cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[i+1]);
  802093:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802099:	8b 52 48             	mov    0x48(%edx),%edx
  80209c:	83 ec 04             	sub    $0x4,%esp
  80209f:	50                   	push   %eax
  8020a0:	52                   	push   %edx
  8020a1:	68 84 30 80 00       	push   $0x803084
  8020a6:	e8 26 e2 ff ff       	call   8002d1 <cprintf>
	for(i=0;i<argc;i++) {
  8020ab:	83 c4 10             	add    $0x10,%esp
        argv[i+1] = va_arg(vl, const char *);
  8020ae:	89 f8                	mov    %edi,%eax
	for(i=0;i<argc;i++) {
  8020b0:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  8020b3:	75 d3                	jne    802088 <spawnl+0x83>
	return spawn(prog, argv);
  8020b5:	83 ec 08             	sub    $0x8,%esp
  8020b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8020bb:	ff 75 08             	pushl  0x8(%ebp)
  8020be:	e8 b1 f9 ff ff       	call   801a74 <spawn>
}
  8020c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c6:	5b                   	pop    %ebx
  8020c7:	5e                   	pop    %esi
  8020c8:	5f                   	pop    %edi
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	56                   	push   %esi
  8020cf:	53                   	push   %ebx
  8020d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	ff 75 08             	pushl  0x8(%ebp)
  8020d9:	e8 87 f1 ff ff       	call   801265 <fd2data>
  8020de:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8020e0:	83 c4 08             	add    $0x8,%esp
  8020e3:	68 ac 30 80 00       	push   $0x8030ac
  8020e8:	53                   	push   %ebx
  8020e9:	e8 02 e8 ff ff       	call   8008f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8020ee:	8b 46 04             	mov    0x4(%esi),%eax
  8020f1:	2b 06                	sub    (%esi),%eax
  8020f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8020f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802100:	00 00 00 
	stat->st_dev = &devpipe;
  802103:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  80210a:	40 80 00 
	return 0;
}
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
  802112:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802115:	5b                   	pop    %ebx
  802116:	5e                   	pop    %esi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    

00802119 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	53                   	push   %ebx
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802123:	53                   	push   %ebx
  802124:	6a 00                	push   $0x0
  802126:	e8 43 ec ff ff       	call   800d6e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80212b:	89 1c 24             	mov    %ebx,(%esp)
  80212e:	e8 32 f1 ff ff       	call   801265 <fd2data>
  802133:	83 c4 08             	add    $0x8,%esp
  802136:	50                   	push   %eax
  802137:	6a 00                	push   $0x0
  802139:	e8 30 ec ff ff       	call   800d6e <sys_page_unmap>
}
  80213e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <_pipeisclosed>:
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 1c             	sub    $0x1c,%esp
  80214c:	89 c7                	mov    %eax,%edi
  80214e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802150:	a1 04 50 80 00       	mov    0x805004,%eax
  802155:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802158:	83 ec 0c             	sub    $0xc,%esp
  80215b:	57                   	push   %edi
  80215c:	e8 90 05 00 00       	call   8026f1 <pageref>
  802161:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802164:	89 34 24             	mov    %esi,(%esp)
  802167:	e8 85 05 00 00       	call   8026f1 <pageref>
		nn = thisenv->env_runs;
  80216c:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802172:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	39 cb                	cmp    %ecx,%ebx
  80217a:	74 1b                	je     802197 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80217c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80217f:	75 cf                	jne    802150 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802181:	8b 42 58             	mov    0x58(%edx),%eax
  802184:	6a 01                	push   $0x1
  802186:	50                   	push   %eax
  802187:	53                   	push   %ebx
  802188:	68 b3 30 80 00       	push   $0x8030b3
  80218d:	e8 3f e1 ff ff       	call   8002d1 <cprintf>
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	eb b9                	jmp    802150 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802197:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80219a:	0f 94 c0             	sete   %al
  80219d:	0f b6 c0             	movzbl %al,%eax
}
  8021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <devpipe_write>:
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	57                   	push   %edi
  8021ac:	56                   	push   %esi
  8021ad:	53                   	push   %ebx
  8021ae:	83 ec 28             	sub    $0x28,%esp
  8021b1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8021b4:	56                   	push   %esi
  8021b5:	e8 ab f0 ff ff       	call   801265 <fd2data>
  8021ba:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021bc:	83 c4 10             	add    $0x10,%esp
  8021bf:	bf 00 00 00 00       	mov    $0x0,%edi
  8021c4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8021c7:	74 4f                	je     802218 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8021c9:	8b 43 04             	mov    0x4(%ebx),%eax
  8021cc:	8b 0b                	mov    (%ebx),%ecx
  8021ce:	8d 51 20             	lea    0x20(%ecx),%edx
  8021d1:	39 d0                	cmp    %edx,%eax
  8021d3:	72 14                	jb     8021e9 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8021d5:	89 da                	mov    %ebx,%edx
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	e8 65 ff ff ff       	call   802143 <_pipeisclosed>
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	75 3a                	jne    80221c <devpipe_write+0x74>
			sys_yield();
  8021e2:	e8 e3 ea ff ff       	call   800cca <sys_yield>
  8021e7:	eb e0                	jmp    8021c9 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8021e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ec:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8021f0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8021f3:	89 c2                	mov    %eax,%edx
  8021f5:	c1 fa 1f             	sar    $0x1f,%edx
  8021f8:	89 d1                	mov    %edx,%ecx
  8021fa:	c1 e9 1b             	shr    $0x1b,%ecx
  8021fd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802200:	83 e2 1f             	and    $0x1f,%edx
  802203:	29 ca                	sub    %ecx,%edx
  802205:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802209:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80220d:	83 c0 01             	add    $0x1,%eax
  802210:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802213:	83 c7 01             	add    $0x1,%edi
  802216:	eb ac                	jmp    8021c4 <devpipe_write+0x1c>
	return i;
  802218:	89 f8                	mov    %edi,%eax
  80221a:	eb 05                	jmp    802221 <devpipe_write+0x79>
				return 0;
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    

00802229 <devpipe_read>:
{
  802229:	55                   	push   %ebp
  80222a:	89 e5                	mov    %esp,%ebp
  80222c:	57                   	push   %edi
  80222d:	56                   	push   %esi
  80222e:	53                   	push   %ebx
  80222f:	83 ec 18             	sub    $0x18,%esp
  802232:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802235:	57                   	push   %edi
  802236:	e8 2a f0 ff ff       	call   801265 <fd2data>
  80223b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80223d:	83 c4 10             	add    $0x10,%esp
  802240:	be 00 00 00 00       	mov    $0x0,%esi
  802245:	3b 75 10             	cmp    0x10(%ebp),%esi
  802248:	74 47                	je     802291 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80224a:	8b 03                	mov    (%ebx),%eax
  80224c:	3b 43 04             	cmp    0x4(%ebx),%eax
  80224f:	75 22                	jne    802273 <devpipe_read+0x4a>
			if (i > 0)
  802251:	85 f6                	test   %esi,%esi
  802253:	75 14                	jne    802269 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802255:	89 da                	mov    %ebx,%edx
  802257:	89 f8                	mov    %edi,%eax
  802259:	e8 e5 fe ff ff       	call   802143 <_pipeisclosed>
  80225e:	85 c0                	test   %eax,%eax
  802260:	75 33                	jne    802295 <devpipe_read+0x6c>
			sys_yield();
  802262:	e8 63 ea ff ff       	call   800cca <sys_yield>
  802267:	eb e1                	jmp    80224a <devpipe_read+0x21>
				return i;
  802269:	89 f0                	mov    %esi,%eax
}
  80226b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80226e:	5b                   	pop    %ebx
  80226f:	5e                   	pop    %esi
  802270:	5f                   	pop    %edi
  802271:	5d                   	pop    %ebp
  802272:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802273:	99                   	cltd   
  802274:	c1 ea 1b             	shr    $0x1b,%edx
  802277:	01 d0                	add    %edx,%eax
  802279:	83 e0 1f             	and    $0x1f,%eax
  80227c:	29 d0                	sub    %edx,%eax
  80227e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802283:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802286:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802289:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80228c:	83 c6 01             	add    $0x1,%esi
  80228f:	eb b4                	jmp    802245 <devpipe_read+0x1c>
	return i;
  802291:	89 f0                	mov    %esi,%eax
  802293:	eb d6                	jmp    80226b <devpipe_read+0x42>
				return 0;
  802295:	b8 00 00 00 00       	mov    $0x0,%eax
  80229a:	eb cf                	jmp    80226b <devpipe_read+0x42>

0080229c <pipe>:
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8022a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a7:	50                   	push   %eax
  8022a8:	e8 cf ef ff ff       	call   80127c <fd_alloc>
  8022ad:	89 c3                	mov    %eax,%ebx
  8022af:	83 c4 10             	add    $0x10,%esp
  8022b2:	85 c0                	test   %eax,%eax
  8022b4:	78 5b                	js     802311 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b6:	83 ec 04             	sub    $0x4,%esp
  8022b9:	68 07 04 00 00       	push   $0x407
  8022be:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c1:	6a 00                	push   $0x0
  8022c3:	e8 21 ea ff ff       	call   800ce9 <sys_page_alloc>
  8022c8:	89 c3                	mov    %eax,%ebx
  8022ca:	83 c4 10             	add    $0x10,%esp
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 40                	js     802311 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8022d1:	83 ec 0c             	sub    $0xc,%esp
  8022d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022d7:	50                   	push   %eax
  8022d8:	e8 9f ef ff ff       	call   80127c <fd_alloc>
  8022dd:	89 c3                	mov    %eax,%ebx
  8022df:	83 c4 10             	add    $0x10,%esp
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	78 1b                	js     802301 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022e6:	83 ec 04             	sub    $0x4,%esp
  8022e9:	68 07 04 00 00       	push   $0x407
  8022ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8022f1:	6a 00                	push   $0x0
  8022f3:	e8 f1 e9 ff ff       	call   800ce9 <sys_page_alloc>
  8022f8:	89 c3                	mov    %eax,%ebx
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	85 c0                	test   %eax,%eax
  8022ff:	79 19                	jns    80231a <pipe+0x7e>
	sys_page_unmap(0, fd0);
  802301:	83 ec 08             	sub    $0x8,%esp
  802304:	ff 75 f4             	pushl  -0xc(%ebp)
  802307:	6a 00                	push   $0x0
  802309:	e8 60 ea ff ff       	call   800d6e <sys_page_unmap>
  80230e:	83 c4 10             	add    $0x10,%esp
}
  802311:	89 d8                	mov    %ebx,%eax
  802313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802316:	5b                   	pop    %ebx
  802317:	5e                   	pop    %esi
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    
	va = fd2data(fd0);
  80231a:	83 ec 0c             	sub    $0xc,%esp
  80231d:	ff 75 f4             	pushl  -0xc(%ebp)
  802320:	e8 40 ef ff ff       	call   801265 <fd2data>
  802325:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802327:	83 c4 0c             	add    $0xc,%esp
  80232a:	68 07 04 00 00       	push   $0x407
  80232f:	50                   	push   %eax
  802330:	6a 00                	push   $0x0
  802332:	e8 b2 e9 ff ff       	call   800ce9 <sys_page_alloc>
  802337:	89 c3                	mov    %eax,%ebx
  802339:	83 c4 10             	add    $0x10,%esp
  80233c:	85 c0                	test   %eax,%eax
  80233e:	0f 88 8c 00 00 00    	js     8023d0 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802344:	83 ec 0c             	sub    $0xc,%esp
  802347:	ff 75 f0             	pushl  -0x10(%ebp)
  80234a:	e8 16 ef ff ff       	call   801265 <fd2data>
  80234f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802356:	50                   	push   %eax
  802357:	6a 00                	push   $0x0
  802359:	56                   	push   %esi
  80235a:	6a 00                	push   $0x0
  80235c:	e8 cb e9 ff ff       	call   800d2c <sys_page_map>
  802361:	89 c3                	mov    %eax,%ebx
  802363:	83 c4 20             	add    $0x20,%esp
  802366:	85 c0                	test   %eax,%eax
  802368:	78 58                	js     8023c2 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80236a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236d:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802373:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802378:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80237f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802382:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802388:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80238a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80238d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802394:	83 ec 0c             	sub    $0xc,%esp
  802397:	ff 75 f4             	pushl  -0xc(%ebp)
  80239a:	e8 b6 ee ff ff       	call   801255 <fd2num>
  80239f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023a2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023a4:	83 c4 04             	add    $0x4,%esp
  8023a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8023aa:	e8 a6 ee ff ff       	call   801255 <fd2num>
  8023af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023b2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023b5:	83 c4 10             	add    $0x10,%esp
  8023b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8023bd:	e9 4f ff ff ff       	jmp    802311 <pipe+0x75>
	sys_page_unmap(0, va);
  8023c2:	83 ec 08             	sub    $0x8,%esp
  8023c5:	56                   	push   %esi
  8023c6:	6a 00                	push   $0x0
  8023c8:	e8 a1 e9 ff ff       	call   800d6e <sys_page_unmap>
  8023cd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8023d0:	83 ec 08             	sub    $0x8,%esp
  8023d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8023d6:	6a 00                	push   $0x0
  8023d8:	e8 91 e9 ff ff       	call   800d6e <sys_page_unmap>
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	e9 1c ff ff ff       	jmp    802301 <pipe+0x65>

008023e5 <pipeisclosed>:
{
  8023e5:	55                   	push   %ebp
  8023e6:	89 e5                	mov    %esp,%ebp
  8023e8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023ee:	50                   	push   %eax
  8023ef:	ff 75 08             	pushl  0x8(%ebp)
  8023f2:	e8 d4 ee ff ff       	call   8012cb <fd_lookup>
  8023f7:	83 c4 10             	add    $0x10,%esp
  8023fa:	85 c0                	test   %eax,%eax
  8023fc:	78 18                	js     802416 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8023fe:	83 ec 0c             	sub    $0xc,%esp
  802401:	ff 75 f4             	pushl  -0xc(%ebp)
  802404:	e8 5c ee ff ff       	call   801265 <fd2data>
	return _pipeisclosed(fd, p);
  802409:	89 c2                	mov    %eax,%edx
  80240b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80240e:	e8 30 fd ff ff       	call   802143 <_pipeisclosed>
  802413:	83 c4 10             	add    $0x10,%esp
}
  802416:	c9                   	leave  
  802417:	c3                   	ret    

00802418 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	56                   	push   %esi
  80241c:	53                   	push   %ebx
  80241d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802420:	85 f6                	test   %esi,%esi
  802422:	74 13                	je     802437 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802424:	89 f3                	mov    %esi,%ebx
  802426:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80242c:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80242f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802435:	eb 1b                	jmp    802452 <wait+0x3a>
	assert(envid != 0);
  802437:	68 cb 30 80 00       	push   $0x8030cb
  80243c:	68 4f 2f 80 00       	push   $0x802f4f
  802441:	6a 09                	push   $0x9
  802443:	68 d6 30 80 00       	push   $0x8030d6
  802448:	e8 a9 dd ff ff       	call   8001f6 <_panic>
		sys_yield();
  80244d:	e8 78 e8 ff ff       	call   800cca <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802452:	8b 43 48             	mov    0x48(%ebx),%eax
  802455:	39 f0                	cmp    %esi,%eax
  802457:	75 07                	jne    802460 <wait+0x48>
  802459:	8b 43 54             	mov    0x54(%ebx),%eax
  80245c:	85 c0                	test   %eax,%eax
  80245e:	75 ed                	jne    80244d <wait+0x35>
}
  802460:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    

00802467 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802467:	55                   	push   %ebp
  802468:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80246a:	b8 00 00 00 00       	mov    $0x0,%eax
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    

00802471 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802477:	68 e1 30 80 00       	push   $0x8030e1
  80247c:	ff 75 0c             	pushl  0xc(%ebp)
  80247f:	e8 6c e4 ff ff       	call   8008f0 <strcpy>
	return 0;
}
  802484:	b8 00 00 00 00       	mov    $0x0,%eax
  802489:	c9                   	leave  
  80248a:	c3                   	ret    

0080248b <devcons_write>:
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	57                   	push   %edi
  80248f:	56                   	push   %esi
  802490:	53                   	push   %ebx
  802491:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802497:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80249c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8024a2:	eb 2f                	jmp    8024d3 <devcons_write+0x48>
		m = n - tot;
  8024a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024a7:	29 f3                	sub    %esi,%ebx
  8024a9:	83 fb 7f             	cmp    $0x7f,%ebx
  8024ac:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8024b1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8024b4:	83 ec 04             	sub    $0x4,%esp
  8024b7:	53                   	push   %ebx
  8024b8:	89 f0                	mov    %esi,%eax
  8024ba:	03 45 0c             	add    0xc(%ebp),%eax
  8024bd:	50                   	push   %eax
  8024be:	57                   	push   %edi
  8024bf:	e8 ba e5 ff ff       	call   800a7e <memmove>
		sys_cputs(buf, m);
  8024c4:	83 c4 08             	add    $0x8,%esp
  8024c7:	53                   	push   %ebx
  8024c8:	57                   	push   %edi
  8024c9:	e8 5f e7 ff ff       	call   800c2d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8024ce:	01 de                	add    %ebx,%esi
  8024d0:	83 c4 10             	add    $0x10,%esp
  8024d3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024d6:	72 cc                	jb     8024a4 <devcons_write+0x19>
}
  8024d8:	89 f0                	mov    %esi,%eax
  8024da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    

008024e2 <devcons_read>:
{
  8024e2:	55                   	push   %ebp
  8024e3:	89 e5                	mov    %esp,%ebp
  8024e5:	83 ec 08             	sub    $0x8,%esp
  8024e8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8024ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024f1:	75 07                	jne    8024fa <devcons_read+0x18>
}
  8024f3:	c9                   	leave  
  8024f4:	c3                   	ret    
		sys_yield();
  8024f5:	e8 d0 e7 ff ff       	call   800cca <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8024fa:	e8 4c e7 ff ff       	call   800c4b <sys_cgetc>
  8024ff:	85 c0                	test   %eax,%eax
  802501:	74 f2                	je     8024f5 <devcons_read+0x13>
	if (c < 0)
  802503:	85 c0                	test   %eax,%eax
  802505:	78 ec                	js     8024f3 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  802507:	83 f8 04             	cmp    $0x4,%eax
  80250a:	74 0c                	je     802518 <devcons_read+0x36>
	*(char*)vbuf = c;
  80250c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80250f:	88 02                	mov    %al,(%edx)
	return 1;
  802511:	b8 01 00 00 00       	mov    $0x1,%eax
  802516:	eb db                	jmp    8024f3 <devcons_read+0x11>
		return 0;
  802518:	b8 00 00 00 00       	mov    $0x0,%eax
  80251d:	eb d4                	jmp    8024f3 <devcons_read+0x11>

0080251f <cputchar>:
{
  80251f:	55                   	push   %ebp
  802520:	89 e5                	mov    %esp,%ebp
  802522:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802525:	8b 45 08             	mov    0x8(%ebp),%eax
  802528:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80252b:	6a 01                	push   $0x1
  80252d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802530:	50                   	push   %eax
  802531:	e8 f7 e6 ff ff       	call   800c2d <sys_cputs>
}
  802536:	83 c4 10             	add    $0x10,%esp
  802539:	c9                   	leave  
  80253a:	c3                   	ret    

0080253b <getchar>:
{
  80253b:	55                   	push   %ebp
  80253c:	89 e5                	mov    %esp,%ebp
  80253e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802541:	6a 01                	push   $0x1
  802543:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802546:	50                   	push   %eax
  802547:	6a 00                	push   $0x0
  802549:	e8 ee ef ff ff       	call   80153c <read>
	if (r < 0)
  80254e:	83 c4 10             	add    $0x10,%esp
  802551:	85 c0                	test   %eax,%eax
  802553:	78 08                	js     80255d <getchar+0x22>
	if (r < 1)
  802555:	85 c0                	test   %eax,%eax
  802557:	7e 06                	jle    80255f <getchar+0x24>
	return c;
  802559:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80255d:	c9                   	leave  
  80255e:	c3                   	ret    
		return -E_EOF;
  80255f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802564:	eb f7                	jmp    80255d <getchar+0x22>

00802566 <iscons>:
{
  802566:	55                   	push   %ebp
  802567:	89 e5                	mov    %esp,%ebp
  802569:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80256c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80256f:	50                   	push   %eax
  802570:	ff 75 08             	pushl  0x8(%ebp)
  802573:	e8 53 ed ff ff       	call   8012cb <fd_lookup>
  802578:	83 c4 10             	add    $0x10,%esp
  80257b:	85 c0                	test   %eax,%eax
  80257d:	78 11                	js     802590 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80257f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802582:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802588:	39 10                	cmp    %edx,(%eax)
  80258a:	0f 94 c0             	sete   %al
  80258d:	0f b6 c0             	movzbl %al,%eax
}
  802590:	c9                   	leave  
  802591:	c3                   	ret    

00802592 <opencons>:
{
  802592:	55                   	push   %ebp
  802593:	89 e5                	mov    %esp,%ebp
  802595:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80259b:	50                   	push   %eax
  80259c:	e8 db ec ff ff       	call   80127c <fd_alloc>
  8025a1:	83 c4 10             	add    $0x10,%esp
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	78 3a                	js     8025e2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025a8:	83 ec 04             	sub    $0x4,%esp
  8025ab:	68 07 04 00 00       	push   $0x407
  8025b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8025b3:	6a 00                	push   $0x0
  8025b5:	e8 2f e7 ff ff       	call   800ce9 <sys_page_alloc>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 21                	js     8025e2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8025c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c4:	8b 15 44 40 80 00    	mov    0x804044,%edx
  8025ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025d6:	83 ec 0c             	sub    $0xc,%esp
  8025d9:	50                   	push   %eax
  8025da:	e8 76 ec ff ff       	call   801255 <fd2num>
  8025df:	83 c4 10             	add    $0x10,%esp
}
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025e5:	a1 08 50 80 00       	mov    0x805008,%eax
	call *%eax
  8025ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025ec:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  8025ef:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  8025f2:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  8025f6:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  8025fa:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  8025fd:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  802601:	89 18                	mov    %ebx,(%eax)

    popal
  802603:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  802604:	83 c4 04             	add    $0x4,%esp
    popfl
  802607:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  802608:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  802609:	c3                   	ret    

0080260a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80260a:	55                   	push   %ebp
  80260b:	89 e5                	mov    %esp,%ebp
  80260d:	56                   	push   %esi
  80260e:	53                   	push   %ebx
  80260f:	8b 75 08             	mov    0x8(%ebp),%esi
  802612:	8b 45 0c             	mov    0xc(%ebp),%eax
  802615:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  802618:	85 c0                	test   %eax,%eax
  80261a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80261f:	0f 44 c2             	cmove  %edx,%eax
  802622:	83 ec 0c             	sub    $0xc,%esp
  802625:	50                   	push   %eax
  802626:	e8 6e e8 ff ff       	call   800e99 <sys_ipc_recv>
  80262b:	83 c4 10             	add    $0x10,%esp
  80262e:	85 c0                	test   %eax,%eax
  802630:	78 2b                	js     80265d <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  802632:	85 f6                	test   %esi,%esi
  802634:	74 0a                	je     802640 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  802636:	a1 04 50 80 00       	mov    0x805004,%eax
  80263b:	8b 40 74             	mov    0x74(%eax),%eax
  80263e:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  802640:	85 db                	test   %ebx,%ebx
  802642:	74 0a                	je     80264e <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  802644:	a1 04 50 80 00       	mov    0x805004,%eax
  802649:	8b 40 78             	mov    0x78(%eax),%eax
  80264c:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  80264e:	a1 04 50 80 00       	mov    0x805004,%eax
  802653:	8b 40 70             	mov    0x70(%eax),%eax
}
  802656:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802659:	5b                   	pop    %ebx
  80265a:	5e                   	pop    %esi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    
        *from_env_store = 0;
  80265d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  802663:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802669:	eb eb                	jmp    802656 <ipc_recv+0x4c>

0080266b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80266b:	55                   	push   %ebp
  80266c:	89 e5                	mov    %esp,%ebp
  80266e:	57                   	push   %edi
  80266f:	56                   	push   %esi
  802670:	53                   	push   %ebx
  802671:	83 ec 0c             	sub    $0xc,%esp
  802674:	8b 7d 08             	mov    0x8(%ebp),%edi
  802677:	8b 75 0c             	mov    0xc(%ebp),%esi
  80267a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  80267d:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80267f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802684:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802687:	ff 75 14             	pushl  0x14(%ebp)
  80268a:	53                   	push   %ebx
  80268b:	56                   	push   %esi
  80268c:	57                   	push   %edi
  80268d:	e8 e4 e7 ff ff       	call   800e76 <sys_ipc_try_send>
  802692:	83 c4 10             	add    $0x10,%esp
  802695:	85 c0                	test   %eax,%eax
  802697:	74 17                	je     8026b0 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802699:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80269c:	74 e9                	je     802687 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  80269e:	50                   	push   %eax
  80269f:	68 ed 30 80 00       	push   $0x8030ed
  8026a4:	6a 3e                	push   $0x3e
  8026a6:	68 ff 30 80 00       	push   $0x8030ff
  8026ab:	e8 46 db ff ff       	call   8001f6 <_panic>
        }
    }
}
  8026b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026b3:	5b                   	pop    %ebx
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    

008026b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026c3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8026c6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026cc:	8b 52 50             	mov    0x50(%edx),%edx
  8026cf:	39 ca                	cmp    %ecx,%edx
  8026d1:	74 11                	je     8026e4 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8026d3:	83 c0 01             	add    $0x1,%eax
  8026d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026db:	75 e6                	jne    8026c3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8026dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e2:	eb 0b                	jmp    8026ef <ipc_find_env+0x37>
			return envs[i].env_id;
  8026e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8026e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026ec:	8b 40 48             	mov    0x48(%eax),%eax
}
  8026ef:	5d                   	pop    %ebp
  8026f0:	c3                   	ret    

008026f1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026f1:	55                   	push   %ebp
  8026f2:	89 e5                	mov    %esp,%ebp
  8026f4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026f7:	89 d0                	mov    %edx,%eax
  8026f9:	c1 e8 16             	shr    $0x16,%eax
  8026fc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802703:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802708:	f6 c1 01             	test   $0x1,%cl
  80270b:	74 1d                	je     80272a <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  80270d:	c1 ea 0c             	shr    $0xc,%edx
  802710:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802717:	f6 c2 01             	test   $0x1,%dl
  80271a:	74 0e                	je     80272a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80271c:	c1 ea 0c             	shr    $0xc,%edx
  80271f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802726:	ef 
  802727:	0f b7 c0             	movzwl %ax,%eax
}
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	66 90                	xchg   %ax,%ax
  80272e:	66 90                	xchg   %ax,%ax

00802730 <__udivdi3>:
  802730:	55                   	push   %ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 1c             	sub    $0x1c,%esp
  802737:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80273b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80273f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802743:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802747:	85 d2                	test   %edx,%edx
  802749:	75 35                	jne    802780 <__udivdi3+0x50>
  80274b:	39 f3                	cmp    %esi,%ebx
  80274d:	0f 87 bd 00 00 00    	ja     802810 <__udivdi3+0xe0>
  802753:	85 db                	test   %ebx,%ebx
  802755:	89 d9                	mov    %ebx,%ecx
  802757:	75 0b                	jne    802764 <__udivdi3+0x34>
  802759:	b8 01 00 00 00       	mov    $0x1,%eax
  80275e:	31 d2                	xor    %edx,%edx
  802760:	f7 f3                	div    %ebx
  802762:	89 c1                	mov    %eax,%ecx
  802764:	31 d2                	xor    %edx,%edx
  802766:	89 f0                	mov    %esi,%eax
  802768:	f7 f1                	div    %ecx
  80276a:	89 c6                	mov    %eax,%esi
  80276c:	89 e8                	mov    %ebp,%eax
  80276e:	89 f7                	mov    %esi,%edi
  802770:	f7 f1                	div    %ecx
  802772:	89 fa                	mov    %edi,%edx
  802774:	83 c4 1c             	add    $0x1c,%esp
  802777:	5b                   	pop    %ebx
  802778:	5e                   	pop    %esi
  802779:	5f                   	pop    %edi
  80277a:	5d                   	pop    %ebp
  80277b:	c3                   	ret    
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	39 f2                	cmp    %esi,%edx
  802782:	77 7c                	ja     802800 <__udivdi3+0xd0>
  802784:	0f bd fa             	bsr    %edx,%edi
  802787:	83 f7 1f             	xor    $0x1f,%edi
  80278a:	0f 84 98 00 00 00    	je     802828 <__udivdi3+0xf8>
  802790:	89 f9                	mov    %edi,%ecx
  802792:	b8 20 00 00 00       	mov    $0x20,%eax
  802797:	29 f8                	sub    %edi,%eax
  802799:	d3 e2                	shl    %cl,%edx
  80279b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80279f:	89 c1                	mov    %eax,%ecx
  8027a1:	89 da                	mov    %ebx,%edx
  8027a3:	d3 ea                	shr    %cl,%edx
  8027a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8027a9:	09 d1                	or     %edx,%ecx
  8027ab:	89 f2                	mov    %esi,%edx
  8027ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027b1:	89 f9                	mov    %edi,%ecx
  8027b3:	d3 e3                	shl    %cl,%ebx
  8027b5:	89 c1                	mov    %eax,%ecx
  8027b7:	d3 ea                	shr    %cl,%edx
  8027b9:	89 f9                	mov    %edi,%ecx
  8027bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8027bf:	d3 e6                	shl    %cl,%esi
  8027c1:	89 eb                	mov    %ebp,%ebx
  8027c3:	89 c1                	mov    %eax,%ecx
  8027c5:	d3 eb                	shr    %cl,%ebx
  8027c7:	09 de                	or     %ebx,%esi
  8027c9:	89 f0                	mov    %esi,%eax
  8027cb:	f7 74 24 08          	divl   0x8(%esp)
  8027cf:	89 d6                	mov    %edx,%esi
  8027d1:	89 c3                	mov    %eax,%ebx
  8027d3:	f7 64 24 0c          	mull   0xc(%esp)
  8027d7:	39 d6                	cmp    %edx,%esi
  8027d9:	72 0c                	jb     8027e7 <__udivdi3+0xb7>
  8027db:	89 f9                	mov    %edi,%ecx
  8027dd:	d3 e5                	shl    %cl,%ebp
  8027df:	39 c5                	cmp    %eax,%ebp
  8027e1:	73 5d                	jae    802840 <__udivdi3+0x110>
  8027e3:	39 d6                	cmp    %edx,%esi
  8027e5:	75 59                	jne    802840 <__udivdi3+0x110>
  8027e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8027ea:	31 ff                	xor    %edi,%edi
  8027ec:	89 fa                	mov    %edi,%edx
  8027ee:	83 c4 1c             	add    $0x1c,%esp
  8027f1:	5b                   	pop    %ebx
  8027f2:	5e                   	pop    %esi
  8027f3:	5f                   	pop    %edi
  8027f4:	5d                   	pop    %ebp
  8027f5:	c3                   	ret    
  8027f6:	8d 76 00             	lea    0x0(%esi),%esi
  8027f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802800:	31 ff                	xor    %edi,%edi
  802802:	31 c0                	xor    %eax,%eax
  802804:	89 fa                	mov    %edi,%edx
  802806:	83 c4 1c             	add    $0x1c,%esp
  802809:	5b                   	pop    %ebx
  80280a:	5e                   	pop    %esi
  80280b:	5f                   	pop    %edi
  80280c:	5d                   	pop    %ebp
  80280d:	c3                   	ret    
  80280e:	66 90                	xchg   %ax,%ax
  802810:	31 ff                	xor    %edi,%edi
  802812:	89 e8                	mov    %ebp,%eax
  802814:	89 f2                	mov    %esi,%edx
  802816:	f7 f3                	div    %ebx
  802818:	89 fa                	mov    %edi,%edx
  80281a:	83 c4 1c             	add    $0x1c,%esp
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    
  802822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802828:	39 f2                	cmp    %esi,%edx
  80282a:	72 06                	jb     802832 <__udivdi3+0x102>
  80282c:	31 c0                	xor    %eax,%eax
  80282e:	39 eb                	cmp    %ebp,%ebx
  802830:	77 d2                	ja     802804 <__udivdi3+0xd4>
  802832:	b8 01 00 00 00       	mov    $0x1,%eax
  802837:	eb cb                	jmp    802804 <__udivdi3+0xd4>
  802839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802840:	89 d8                	mov    %ebx,%eax
  802842:	31 ff                	xor    %edi,%edi
  802844:	eb be                	jmp    802804 <__udivdi3+0xd4>
  802846:	66 90                	xchg   %ax,%ax
  802848:	66 90                	xchg   %ax,%ax
  80284a:	66 90                	xchg   %ax,%ax
  80284c:	66 90                	xchg   %ax,%ax
  80284e:	66 90                	xchg   %ax,%ax

00802850 <__umoddi3>:
  802850:	55                   	push   %ebp
  802851:	57                   	push   %edi
  802852:	56                   	push   %esi
  802853:	53                   	push   %ebx
  802854:	83 ec 1c             	sub    $0x1c,%esp
  802857:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80285b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80285f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802863:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802867:	85 ed                	test   %ebp,%ebp
  802869:	89 f0                	mov    %esi,%eax
  80286b:	89 da                	mov    %ebx,%edx
  80286d:	75 19                	jne    802888 <__umoddi3+0x38>
  80286f:	39 df                	cmp    %ebx,%edi
  802871:	0f 86 b1 00 00 00    	jbe    802928 <__umoddi3+0xd8>
  802877:	f7 f7                	div    %edi
  802879:	89 d0                	mov    %edx,%eax
  80287b:	31 d2                	xor    %edx,%edx
  80287d:	83 c4 1c             	add    $0x1c,%esp
  802880:	5b                   	pop    %ebx
  802881:	5e                   	pop    %esi
  802882:	5f                   	pop    %edi
  802883:	5d                   	pop    %ebp
  802884:	c3                   	ret    
  802885:	8d 76 00             	lea    0x0(%esi),%esi
  802888:	39 dd                	cmp    %ebx,%ebp
  80288a:	77 f1                	ja     80287d <__umoddi3+0x2d>
  80288c:	0f bd cd             	bsr    %ebp,%ecx
  80288f:	83 f1 1f             	xor    $0x1f,%ecx
  802892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802896:	0f 84 b4 00 00 00    	je     802950 <__umoddi3+0x100>
  80289c:	b8 20 00 00 00       	mov    $0x20,%eax
  8028a1:	89 c2                	mov    %eax,%edx
  8028a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028a7:	29 c2                	sub    %eax,%edx
  8028a9:	89 c1                	mov    %eax,%ecx
  8028ab:	89 f8                	mov    %edi,%eax
  8028ad:	d3 e5                	shl    %cl,%ebp
  8028af:	89 d1                	mov    %edx,%ecx
  8028b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8028b5:	d3 e8                	shr    %cl,%eax
  8028b7:	09 c5                	or     %eax,%ebp
  8028b9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8028bd:	89 c1                	mov    %eax,%ecx
  8028bf:	d3 e7                	shl    %cl,%edi
  8028c1:	89 d1                	mov    %edx,%ecx
  8028c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8028c7:	89 df                	mov    %ebx,%edi
  8028c9:	d3 ef                	shr    %cl,%edi
  8028cb:	89 c1                	mov    %eax,%ecx
  8028cd:	89 f0                	mov    %esi,%eax
  8028cf:	d3 e3                	shl    %cl,%ebx
  8028d1:	89 d1                	mov    %edx,%ecx
  8028d3:	89 fa                	mov    %edi,%edx
  8028d5:	d3 e8                	shr    %cl,%eax
  8028d7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8028dc:	09 d8                	or     %ebx,%eax
  8028de:	f7 f5                	div    %ebp
  8028e0:	d3 e6                	shl    %cl,%esi
  8028e2:	89 d1                	mov    %edx,%ecx
  8028e4:	f7 64 24 08          	mull   0x8(%esp)
  8028e8:	39 d1                	cmp    %edx,%ecx
  8028ea:	89 c3                	mov    %eax,%ebx
  8028ec:	89 d7                	mov    %edx,%edi
  8028ee:	72 06                	jb     8028f6 <__umoddi3+0xa6>
  8028f0:	75 0e                	jne    802900 <__umoddi3+0xb0>
  8028f2:	39 c6                	cmp    %eax,%esi
  8028f4:	73 0a                	jae    802900 <__umoddi3+0xb0>
  8028f6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8028fa:	19 ea                	sbb    %ebp,%edx
  8028fc:	89 d7                	mov    %edx,%edi
  8028fe:	89 c3                	mov    %eax,%ebx
  802900:	89 ca                	mov    %ecx,%edx
  802902:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802907:	29 de                	sub    %ebx,%esi
  802909:	19 fa                	sbb    %edi,%edx
  80290b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80290f:	89 d0                	mov    %edx,%eax
  802911:	d3 e0                	shl    %cl,%eax
  802913:	89 d9                	mov    %ebx,%ecx
  802915:	d3 ee                	shr    %cl,%esi
  802917:	d3 ea                	shr    %cl,%edx
  802919:	09 f0                	or     %esi,%eax
  80291b:	83 c4 1c             	add    $0x1c,%esp
  80291e:	5b                   	pop    %ebx
  80291f:	5e                   	pop    %esi
  802920:	5f                   	pop    %edi
  802921:	5d                   	pop    %ebp
  802922:	c3                   	ret    
  802923:	90                   	nop
  802924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802928:	85 ff                	test   %edi,%edi
  80292a:	89 f9                	mov    %edi,%ecx
  80292c:	75 0b                	jne    802939 <__umoddi3+0xe9>
  80292e:	b8 01 00 00 00       	mov    $0x1,%eax
  802933:	31 d2                	xor    %edx,%edx
  802935:	f7 f7                	div    %edi
  802937:	89 c1                	mov    %eax,%ecx
  802939:	89 d8                	mov    %ebx,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	f7 f1                	div    %ecx
  80293f:	89 f0                	mov    %esi,%eax
  802941:	f7 f1                	div    %ecx
  802943:	e9 31 ff ff ff       	jmp    802879 <__umoddi3+0x29>
  802948:	90                   	nop
  802949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802950:	39 dd                	cmp    %ebx,%ebp
  802952:	72 08                	jb     80295c <__umoddi3+0x10c>
  802954:	39 f7                	cmp    %esi,%edi
  802956:	0f 87 21 ff ff ff    	ja     80287d <__umoddi3+0x2d>
  80295c:	89 da                	mov    %ebx,%edx
  80295e:	89 f0                	mov    %esi,%eax
  802960:	29 f8                	sub    %edi,%eax
  802962:	19 ea                	sbb    %ebp,%edx
  802964:	e9 14 ff ff ff       	jmp    80287d <__umoddi3+0x2d>
