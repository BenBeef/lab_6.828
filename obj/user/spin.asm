
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 00 22 80 00       	push   $0x802200
  80003f:	e8 66 01 00 00       	call   8001aa <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 70 0f 00 00       	call   800fb9 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 78 22 80 00       	push   $0x802278
  800058:	e8 4d 01 00 00       	call   8001aa <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 28 22 80 00       	push   $0x802228
  80006c:	e8 39 01 00 00       	call   8001aa <cprintf>
	sys_yield();
  800071:	e8 2d 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800076:	e8 28 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80007b:	e8 23 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800080:	e8 1e 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800085:	e8 19 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008a:	e8 14 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  80008f:	e8 0f 0b 00 00       	call   800ba3 <sys_yield>
	sys_yield();
  800094:	e8 0a 0b 00 00       	call   800ba3 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 50 22 80 00 	movl   $0x802250,(%esp)
  8000a0:	e8 05 01 00 00       	call   8001aa <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 96 0a 00 00       	call   800b43 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 bf 0a 00 00       	call   800b84 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 fe 11 00 00       	call   801304 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 33 0a 00 00       	call   800b43 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	74 09                	je     80013d <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800134:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 b8 09 00 00       	call   800b06 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	eb db                	jmp    800134 <putch+0x1f>

00800159 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800162:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800169:	00 00 00 
	b.cnt = 0;
  80016c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800173:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800176:	ff 75 0c             	pushl  0xc(%ebp)
  800179:	ff 75 08             	pushl  0x8(%ebp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	68 15 01 80 00       	push   $0x800115
  800188:	e8 1a 01 00 00       	call   8002a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018d:	83 c4 08             	add    $0x8,%esp
  800190:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 64 09 00 00       	call   800b06 <sys_cputs>

	return b.cnt;
}
  8001a2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b3:	50                   	push   %eax
  8001b4:	ff 75 08             	pushl  0x8(%ebp)
  8001b7:	e8 9d ff ff ff       	call   800159 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	83 ec 1c             	sub    $0x1c,%esp
  8001c7:	89 c7                	mov    %eax,%edi
  8001c9:	89 d6                	mov    %edx,%esi
  8001cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e5:	39 d3                	cmp    %edx,%ebx
  8001e7:	72 05                	jb     8001ee <printnum+0x30>
  8001e9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ec:	77 7a                	ja     800268 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ee:	83 ec 0c             	sub    $0xc,%esp
  8001f1:	ff 75 18             	pushl  0x18(%ebp)
  8001f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	ff 75 10             	pushl  0x10(%ebp)
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	ff 75 e4             	pushl  -0x1c(%ebp)
  800204:	ff 75 e0             	pushl  -0x20(%ebp)
  800207:	ff 75 dc             	pushl  -0x24(%ebp)
  80020a:	ff 75 d8             	pushl  -0x28(%ebp)
  80020d:	e8 9e 1d 00 00       	call   801fb0 <__udivdi3>
  800212:	83 c4 18             	add    $0x18,%esp
  800215:	52                   	push   %edx
  800216:	50                   	push   %eax
  800217:	89 f2                	mov    %esi,%edx
  800219:	89 f8                	mov    %edi,%eax
  80021b:	e8 9e ff ff ff       	call   8001be <printnum>
  800220:	83 c4 20             	add    $0x20,%esp
  800223:	eb 13                	jmp    800238 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	83 ec 08             	sub    $0x8,%esp
  800228:	56                   	push   %esi
  800229:	ff 75 18             	pushl  0x18(%ebp)
  80022c:	ff d7                	call   *%edi
  80022e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800231:	83 eb 01             	sub    $0x1,%ebx
  800234:	85 db                	test   %ebx,%ebx
  800236:	7f ed                	jg     800225 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	83 ec 04             	sub    $0x4,%esp
  80023f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800242:	ff 75 e0             	pushl  -0x20(%ebp)
  800245:	ff 75 dc             	pushl  -0x24(%ebp)
  800248:	ff 75 d8             	pushl  -0x28(%ebp)
  80024b:	e8 80 1e 00 00       	call   8020d0 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  80025a:	50                   	push   %eax
  80025b:	ff d7                	call   *%edi
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    
  800268:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026b:	eb c4                	jmp    800231 <printnum+0x73>

0080026d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800273:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800277:	8b 10                	mov    (%eax),%edx
  800279:	3b 50 04             	cmp    0x4(%eax),%edx
  80027c:	73 0a                	jae    800288 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 45 08             	mov    0x8(%ebp),%eax
  800286:	88 02                	mov    %al,(%edx)
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <printfmt>:
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800290:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 10             	pushl  0x10(%ebp)
  800297:	ff 75 0c             	pushl  0xc(%ebp)
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 05 00 00 00       	call   8002a7 <vprintfmt>
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <vprintfmt>:
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b9:	e9 c1 03 00 00       	jmp    80067f <vprintfmt+0x3d8>
		padc = ' ';
  8002be:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002c9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8d 47 01             	lea    0x1(%edi),%eax
  8002df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e2:	0f b6 17             	movzbl (%edi),%edx
  8002e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 12 04 00 00    	ja     800702 <vprintfmt+0x45b>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800301:	eb d9                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030a:	eb d0                	jmp    8002dc <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030c:	0f b6 d2             	movzbl %dl,%edx
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800312:	b8 00 00 00 00       	mov    $0x0,%eax
  800317:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80031a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800321:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800324:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800327:	83 f9 09             	cmp    $0x9,%ecx
  80032a:	77 55                	ja     800381 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80032c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032f:	eb e9                	jmp    80031a <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8b 00                	mov    (%eax),%eax
  800336:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800339:	8b 45 14             	mov    0x14(%ebp),%eax
  80033c:	8d 40 04             	lea    0x4(%eax),%eax
  80033f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800349:	79 91                	jns    8002dc <vprintfmt+0x35>
				width = precision, precision = -1;
  80034b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800351:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800358:	eb 82                	jmp    8002dc <vprintfmt+0x35>
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	85 c0                	test   %eax,%eax
  80035f:	ba 00 00 00 00       	mov    $0x0,%edx
  800364:	0f 49 d0             	cmovns %eax,%edx
  800367:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	e9 6a ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800375:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037c:	e9 5b ff ff ff       	jmp    8002dc <vprintfmt+0x35>
  800381:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	eb bc                	jmp    800345 <vprintfmt+0x9e>
			lflag++;
  800389:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038f:	e9 48 ff ff ff       	jmp    8002dc <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 78 04             	lea    0x4(%eax),%edi
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	53                   	push   %ebx
  80039e:	ff 30                	pushl  (%eax)
  8003a0:	ff d6                	call   *%esi
			break;
  8003a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a8:	e9 cf 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 78 04             	lea    0x4(%eax),%edi
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 23                	jg     8003e2 <vprintfmt+0x13b>
  8003bf:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	74 18                	je     8003e2 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 b5 27 80 00       	push   $0x8027b5
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 b3 fe ff ff       	call   80028a <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dd:	e9 9a 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003e2:	50                   	push   %eax
  8003e3:	68 b8 22 80 00       	push   $0x8022b8
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 9b fe ff ff       	call   80028a <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 82 02 00 00       	jmp    80067c <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800408:	85 ff                	test   %edi,%edi
  80040a:	b8 b1 22 80 00       	mov    $0x8022b1,%eax
  80040f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 8e bd 00 00 00    	jle    8004d9 <vprintfmt+0x232>
  80041c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800420:	75 0e                	jne    800430 <vprintfmt+0x189>
  800422:	89 75 08             	mov    %esi,0x8(%ebp)
  800425:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800428:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80042b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80042e:	eb 6d                	jmp    80049d <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	ff 75 d0             	pushl  -0x30(%ebp)
  800436:	57                   	push   %edi
  800437:	e8 6e 03 00 00       	call   8007aa <strnlen>
  80043c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800444:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800447:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80044b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800451:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	eb 0f                	jmp    800464 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	53                   	push   %ebx
  800459:	ff 75 e0             	pushl  -0x20(%ebp)
  80045c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ef 01             	sub    $0x1,%edi
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 ff                	test   %edi,%edi
  800466:	7f ed                	jg     800455 <vprintfmt+0x1ae>
  800468:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80046b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80046e:	85 c9                	test   %ecx,%ecx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c1             	cmovns %ecx,%eax
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	89 cb                	mov    %ecx,%ebx
  800485:	eb 16                	jmp    80049d <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800487:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80048b:	75 31                	jne    8004be <vprintfmt+0x217>
					putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	50                   	push   %eax
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	83 c7 01             	add    $0x1,%edi
  8004a0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004a4:	0f be c2             	movsbl %dl,%eax
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	74 59                	je     800504 <vprintfmt+0x25d>
  8004ab:	85 f6                	test   %esi,%esi
  8004ad:	78 d8                	js     800487 <vprintfmt+0x1e0>
  8004af:	83 ee 01             	sub    $0x1,%esi
  8004b2:	79 d3                	jns    800487 <vprintfmt+0x1e0>
  8004b4:	89 df                	mov    %ebx,%edi
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bc:	eb 37                	jmp    8004f5 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004be:	0f be d2             	movsbl %dl,%edx
  8004c1:	83 ea 20             	sub    $0x20,%edx
  8004c4:	83 fa 5e             	cmp    $0x5e,%edx
  8004c7:	76 c4                	jbe    80048d <vprintfmt+0x1e6>
					putch('?', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	6a 3f                	push   $0x3f
  8004d1:	ff 55 08             	call   *0x8(%ebp)
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb c1                	jmp    80049a <vprintfmt+0x1f3>
  8004d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e5:	eb b6                	jmp    80049d <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	6a 20                	push   $0x20
  8004ed:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004ef:	83 ef 01             	sub    $0x1,%edi
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	7f ee                	jg     8004e7 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ff:	e9 78 01 00 00       	jmp    80067c <vprintfmt+0x3d5>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb e7                	jmp    8004f5 <vprintfmt+0x24e>
	if (lflag >= 2)
  80050e:	83 f9 01             	cmp    $0x1,%ecx
  800511:	7e 3f                	jle    800552 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 50 04             	mov    0x4(%eax),%edx
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 08             	lea    0x8(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80052a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80052e:	79 5c                	jns    80058c <vprintfmt+0x2e5>
				putch('-', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 2d                	push   $0x2d
  800536:	ff d6                	call   *%esi
				num = -(long long) num;
  800538:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053e:	f7 da                	neg    %edx
  800540:	83 d1 00             	adc    $0x0,%ecx
  800543:	f7 d9                	neg    %ecx
  800545:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054d:	e9 10 01 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	75 1b                	jne    800571 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 c1                	mov    %eax,%ecx
  800560:	c1 f9 1f             	sar    $0x1f,%ecx
  800563:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
  80056f:	eb b9                	jmp    80052a <vprintfmt+0x283>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 c1                	mov    %eax,%ecx
  80057b:	c1 f9 1f             	sar    $0x1f,%ecx
  80057e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb 9e                	jmp    80052a <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80058c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 c6 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7e 18                	jle    8005b9 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a9:	8d 40 08             	lea    0x8(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 a9 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	75 1a                	jne    8005d7 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 8b 00 00 00       	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	eb 74                	jmp    800662 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7e 15                	jle    800608 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800601:	b8 08 00 00 00       	mov    $0x8,%eax
  800606:	eb 5a                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	75 17                	jne    800623 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80061c:	b8 08 00 00 00       	mov    $0x8,%eax
  800621:	eb 3f                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062d:	8d 40 04             	lea    0x4(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800633:	b8 08 00 00 00       	mov    $0x8,%eax
  800638:	eb 28                	jmp    800662 <vprintfmt+0x3bb>
			putch('0', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	6a 30                	push   $0x30
  800640:	ff d6                	call   *%esi
			putch('x', putdat);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	6a 78                	push   $0x78
  800648:	ff d6                	call   *%esi
			num = (unsigned long long)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800662:	83 ec 0c             	sub    $0xc,%esp
  800665:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	ff 75 e0             	pushl  -0x20(%ebp)
  80066d:	50                   	push   %eax
  80066e:	51                   	push   %ecx
  80066f:	52                   	push   %edx
  800670:	89 da                	mov    %ebx,%edx
  800672:	89 f0                	mov    %esi,%eax
  800674:	e8 45 fb ff ff       	call   8001be <printnum>
			break;
  800679:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067f:	83 c7 01             	add    $0x1,%edi
  800682:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800686:	83 f8 25             	cmp    $0x25,%eax
  800689:	0f 84 2f fc ff ff    	je     8002be <vprintfmt+0x17>
			if (ch == '\0')
  80068f:	85 c0                	test   %eax,%eax
  800691:	0f 84 8b 00 00 00    	je     800722 <vprintfmt+0x47b>
			putch(ch, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	50                   	push   %eax
  80069c:	ff d6                	call   *%esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb dc                	jmp    80067f <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7e 15                	jle    8006bd <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b0:	8d 40 08             	lea    0x8(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006bb:	eb a5                	jmp    800662 <vprintfmt+0x3bb>
	else if (lflag)
  8006bd:	85 c9                	test   %ecx,%ecx
  8006bf:	75 17                	jne    8006d8 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d6:	eb 8a                	jmp    800662 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8b 10                	mov    (%eax),%edx
  8006dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e2:	8d 40 04             	lea    0x4(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ed:	e9 70 ff ff ff       	jmp    800662 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			break;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	e9 7a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	89 f8                	mov    %edi,%eax
  80070f:	eb 03                	jmp    800714 <vprintfmt+0x46d>
  800711:	83 e8 01             	sub    $0x1,%eax
  800714:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800718:	75 f7                	jne    800711 <vprintfmt+0x46a>
  80071a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071d:	e9 5a ff ff ff       	jmp    80067c <vprintfmt+0x3d5>
}
  800722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800736:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800739:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800740:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800747:	85 c0                	test   %eax,%eax
  800749:	74 26                	je     800771 <vsnprintf+0x47>
  80074b:	85 d2                	test   %edx,%edx
  80074d:	7e 22                	jle    800771 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074f:	ff 75 14             	pushl  0x14(%ebp)
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	50                   	push   %eax
  800759:	68 6d 02 80 00       	push   $0x80026d
  80075e:	e8 44 fb ff ff       	call   8002a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800763:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800766:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076c:	83 c4 10             	add    $0x10,%esp
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    
		return -E_INVAL;
  800771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800776:	eb f7                	jmp    80076f <vsnprintf+0x45>

00800778 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800781:	50                   	push   %eax
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 9a ff ff ff       	call   80072a <vsnprintf>
	va_end(ap);

	return rc;
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strlen+0x10>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a6:	75 f7                	jne    80079f <strlen+0xd>
	return n;
}
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	eb 03                	jmp    8007bd <strnlen+0x13>
		n++;
  8007ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bd:	39 d0                	cmp    %edx,%eax
  8007bf:	74 06                	je     8007c7 <strnlen+0x1d>
  8007c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c5:	75 f3                	jne    8007ba <strnlen+0x10>
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d3:	89 c2                	mov    %eax,%edx
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e2:	84 db                	test   %bl,%bl
  8007e4:	75 ef                	jne    8007d5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 9c ff ff ff       	call   800792 <strlen>
  8007f6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	pushl  0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 c5 ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f2                	mov    %esi,%edx
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c2 01             	add    $0x1,%edx
  800822:	0f b6 01             	movzbl (%ecx),%eax
  800825:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 39 01             	cmpb   $0x1,(%ecx)
  80082b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80082e:	39 da                	cmp    %ebx,%edx
  800830:	75 ed                	jne    80081f <strncpy+0x14>
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
  800843:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800846:	89 f0                	mov    %esi,%eax
  800848:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	75 0b                	jne    80085b <strlcpy+0x23>
  800850:	eb 17                	jmp    800869 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800852:	83 c2 01             	add    $0x1,%edx
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 07                	je     800866 <strlcpy+0x2e>
  80085f:	0f b6 0a             	movzbl (%edx),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	75 ec                	jne    800852 <strlcpy+0x1a>
		*dst = '\0';
  800866:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800869:	29 f0                	sub    %esi,%eax
}
  80086b:	5b                   	pop    %ebx
  80086c:	5e                   	pop    %esi
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800878:	eb 06                	jmp    800880 <strcmp+0x11>
		p++, q++;
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800880:	0f b6 01             	movzbl (%ecx),%eax
  800883:	84 c0                	test   %al,%al
  800885:	74 04                	je     80088b <strcmp+0x1c>
  800887:	3a 02                	cmp    (%edx),%al
  800889:	74 ef                	je     80087a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 c0             	movzbl %al,%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
}
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 c3                	mov    %eax,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strncmp+0x17>
		n--, p++, q++;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ac:	39 d8                	cmp    %ebx,%eax
  8008ae:	74 16                	je     8008c6 <strncmp+0x31>
  8008b0:	0f b6 08             	movzbl (%eax),%ecx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 04                	je     8008bb <strncmp+0x26>
  8008b7:	3a 0a                	cmp    (%edx),%cl
  8008b9:	74 eb                	je     8008a6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    
		return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb f6                	jmp    8008c3 <strncmp+0x2e>

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 09                	je     8008e7 <strchr+0x1a>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0a                	je     8008ec <strchr+0x1f>
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	eb f0                	jmp    8008d7 <strchr+0xa>
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f8:	eb 03                	jmp    8008fd <strfind+0xf>
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 04                	je     800908 <strfind+0x1a>
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f2                	jne    8008fa <strfind+0xc>
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800916:	85 c9                	test   %ecx,%ecx
  800918:	74 13                	je     80092d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800920:	75 05                	jne    800927 <memset+0x1d>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	74 0d                	je     800934 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	fc                   	cld    
  80092b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	5b                   	pop    %ebx
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    
		c &= 0xFF;
  800934:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800938:	89 d3                	mov    %edx,%ebx
  80093a:	c1 e3 08             	shl    $0x8,%ebx
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e0 18             	shl    $0x18,%eax
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 10             	shl    $0x10,%esi
  800947:	09 f0                	or     %esi,%eax
  800949:	09 c2                	or     %eax,%edx
  80094b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80094d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800950:	89 d0                	mov    %edx,%eax
  800952:	fc                   	cld    
  800953:	f3 ab                	rep stos %eax,%es:(%edi)
  800955:	eb d6                	jmp    80092d <memset+0x23>

00800957 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800962:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800965:	39 c6                	cmp    %eax,%esi
  800967:	73 35                	jae    80099e <memmove+0x47>
  800969:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	76 2e                	jbe    80099e <memmove+0x47>
		s += n;
		d += n;
  800970:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	89 d6                	mov    %edx,%esi
  800975:	09 fe                	or     %edi,%esi
  800977:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097d:	74 0c                	je     80098b <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800985:	fd                   	std    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800988:	fc                   	cld    
  800989:	eb 21                	jmp    8009ac <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098b:	f6 c1 03             	test   $0x3,%cl
  80098e:	75 ef                	jne    80097f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800990:	83 ef 04             	sub    $0x4,%edi
  800993:	8d 72 fc             	lea    -0x4(%edx),%esi
  800996:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800999:	fd                   	std    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099c:	eb ea                	jmp    800988 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 f2                	mov    %esi,%edx
  8009a0:	09 c2                	or     %eax,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	74 09                	je     8009b0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	fc                   	cld    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	f6 c1 03             	test   $0x3,%cl
  8009b3:	75 f2                	jne    8009a7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	fc                   	cld    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb ed                	jmp    8009ac <memmove+0x55>

008009bf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c2:	ff 75 10             	pushl  0x10(%ebp)
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	ff 75 08             	pushl  0x8(%ebp)
  8009cb:	e8 87 ff ff ff       	call   800957 <memmove>
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dd:	89 c6                	mov    %eax,%esi
  8009df:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e2:	39 f0                	cmp    %esi,%eax
  8009e4:	74 1c                	je     800a02 <memcmp+0x30>
		if (*s1 != *s2)
  8009e6:	0f b6 08             	movzbl (%eax),%ecx
  8009e9:	0f b6 1a             	movzbl (%edx),%ebx
  8009ec:	38 d9                	cmp    %bl,%cl
  8009ee:	75 08                	jne    8009f8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	eb ea                	jmp    8009e2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 05                	jmp    800a07 <memcmp+0x35>
	}

	return 0;
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a14:	89 c2                	mov    %eax,%edx
  800a16:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	73 09                	jae    800a26 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	38 08                	cmp    %cl,(%eax)
  800a1f:	74 05                	je     800a26 <memfind+0x1b>
	for (; s < ends; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	eb f3                	jmp    800a19 <memfind+0xe>
			break;
	return (void *) s;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	eb 03                	jmp    800a39 <strtol+0x11>
		s++;
  800a36:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a39:	0f b6 01             	movzbl (%ecx),%eax
  800a3c:	3c 20                	cmp    $0x20,%al
  800a3e:	74 f6                	je     800a36 <strtol+0xe>
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f2                	je     800a36 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a44:	3c 2b                	cmp    $0x2b,%al
  800a46:	74 2e                	je     800a76 <strtol+0x4e>
	int neg = 0;
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	74 2f                	je     800a80 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a51:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a57:	75 05                	jne    800a5e <strtol+0x36>
  800a59:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5c:	74 2c                	je     800a8a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 0a                	jne    800a6c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	74 28                	je     800a94 <strtol+0x6c>
		base = 10;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a74:	eb 50                	jmp    800ac6 <strtol+0x9e>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a79:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7e:	eb d1                	jmp    800a51 <strtol+0x29>
		s++, neg = 1;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi
  800a88:	eb c7                	jmp    800a51 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8e:	74 0e                	je     800a9e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 d8                	jne    800a6c <strtol+0x44>
		s++, base = 8;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9c:	eb ce                	jmp    800a6c <strtol+0x44>
		s += 2, base = 16;
  800a9e:	83 c1 02             	add    $0x2,%ecx
  800aa1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa6:	eb c4                	jmp    800a6c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aa8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aab:	89 f3                	mov    %esi,%ebx
  800aad:	80 fb 19             	cmp    $0x19,%bl
  800ab0:	77 29                	ja     800adb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ab2:	0f be d2             	movsbl %dl,%edx
  800ab5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abb:	7d 30                	jge    800aed <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ac6:	0f b6 11             	movzbl (%ecx),%edx
  800ac9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acc:	89 f3                	mov    %esi,%ebx
  800ace:	80 fb 09             	cmp    $0x9,%bl
  800ad1:	77 d5                	ja     800aa8 <strtol+0x80>
			dig = *s - '0';
  800ad3:	0f be d2             	movsbl %dl,%edx
  800ad6:	83 ea 30             	sub    $0x30,%edx
  800ad9:	eb dd                	jmp    800ab8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800adb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 37             	sub    $0x37,%edx
  800aeb:	eb cb                	jmp    800ab8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af1:	74 05                	je     800af8 <strtol+0xd0>
		*endptr = (char *) s;
  800af3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af8:	89 c2                	mov    %eax,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	85 ff                	test   %edi,%edi
  800afe:	0f 45 c2             	cmovne %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	89 c6                	mov    %eax,%esi
  800b1d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	89 d1                	mov    %edx,%ecx
  800b36:	89 d3                	mov    %edx,%ebx
  800b38:	89 d7                	mov    %edx,%edi
  800b3a:	89 d6                	mov    %edx,%esi
  800b3c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	b8 03 00 00 00       	mov    $0x3,%eax
  800b59:	89 cb                	mov    %ecx,%ebx
  800b5b:	89 cf                	mov    %ecx,%edi
  800b5d:	89 ce                	mov    %ecx,%esi
  800b5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b61:	85 c0                	test   %eax,%eax
  800b63:	7f 08                	jg     800b6d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	50                   	push   %eax
  800b71:	6a 03                	push   $0x3
  800b73:	68 9f 25 80 00       	push   $0x80259f
  800b78:	6a 23                	push   $0x23
  800b7a:	68 bc 25 80 00       	push   $0x8025bc
  800b7f:	e8 93 12 00 00       	call   801e17 <_panic>

00800b84 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b94:	89 d1                	mov    %edx,%ecx
  800b96:	89 d3                	mov    %edx,%ebx
  800b98:	89 d7                	mov    %edx,%edi
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_yield>:

void
sys_yield(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcb:	be 00 00 00 00       	mov    $0x0,%esi
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bde:	89 f7                	mov    %esi,%edi
  800be0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be2:	85 c0                	test   %eax,%eax
  800be4:	7f 08                	jg     800bee <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	83 ec 0c             	sub    $0xc,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 04                	push   $0x4
  800bf4:	68 9f 25 80 00       	push   $0x80259f
  800bf9:	6a 23                	push   $0x23
  800bfb:	68 bc 25 80 00       	push   $0x8025bc
  800c00:	e8 12 12 00 00       	call   801e17 <_panic>

00800c05 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	b8 05 00 00 00       	mov    $0x5,%eax
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c24:	85 c0                	test   %eax,%eax
  800c26:	7f 08                	jg     800c30 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	50                   	push   %eax
  800c34:	6a 05                	push   $0x5
  800c36:	68 9f 25 80 00       	push   $0x80259f
  800c3b:	6a 23                	push   $0x23
  800c3d:	68 bc 25 80 00       	push   $0x8025bc
  800c42:	e8 d0 11 00 00       	call   801e17 <_panic>

00800c47 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c60:	89 df                	mov    %ebx,%edi
  800c62:	89 de                	mov    %ebx,%esi
  800c64:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c66:	85 c0                	test   %eax,%eax
  800c68:	7f 08                	jg     800c72 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	50                   	push   %eax
  800c76:	6a 06                	push   $0x6
  800c78:	68 9f 25 80 00       	push   $0x80259f
  800c7d:	6a 23                	push   $0x23
  800c7f:	68 bc 25 80 00       	push   $0x8025bc
  800c84:	e8 8e 11 00 00       	call   801e17 <_panic>

00800c89 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca2:	89 df                	mov    %ebx,%edi
  800ca4:	89 de                	mov    %ebx,%esi
  800ca6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7f 08                	jg     800cb4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	6a 08                	push   $0x8
  800cba:	68 9f 25 80 00       	push   $0x80259f
  800cbf:	6a 23                	push   $0x23
  800cc1:	68 bc 25 80 00       	push   $0x8025bc
  800cc6:	e8 4c 11 00 00       	call   801e17 <_panic>

00800ccb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 09                	push   $0x9
  800cfc:	68 9f 25 80 00       	push   $0x80259f
  800d01:	6a 23                	push   $0x23
  800d03:	68 bc 25 80 00       	push   $0x8025bc
  800d08:	e8 0a 11 00 00       	call   801e17 <_panic>

00800d0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	89 de                	mov    %ebx,%esi
  800d2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 0a                	push   $0xa
  800d3e:	68 9f 25 80 00       	push   $0x80259f
  800d43:	6a 23                	push   $0x23
  800d45:	68 bc 25 80 00       	push   $0x8025bc
  800d4a:	e8 c8 10 00 00       	call   801e17 <_panic>

00800d4f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	be 00 00 00 00       	mov    $0x0,%esi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d88:	89 cb                	mov    %ecx,%ebx
  800d8a:	89 cf                	mov    %ecx,%edi
  800d8c:	89 ce                	mov    %ecx,%esi
  800d8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7f 08                	jg     800d9c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 0d                	push   $0xd
  800da2:	68 9f 25 80 00       	push   $0x80259f
  800da7:	6a 23                	push   $0x23
  800da9:	68 bc 25 80 00       	push   $0x8025bc
  800dae:	e8 64 10 00 00       	call   801e17 <_panic>

00800db3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	53                   	push   %ebx
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbd:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800dbf:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800dc2:	a8 02                	test   $0x2,%al
  800dc4:	0f 84 89 00 00 00    	je     800e53 <pgfault+0xa0>
  800dca:	89 da                	mov    %ebx,%edx
  800dcc:	c1 ea 0c             	shr    $0xc,%edx
  800dcf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd6:	f6 c6 08             	test   $0x8,%dh
  800dd9:	74 78                	je     800e53 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	6a 07                	push   $0x7
  800de0:	68 00 f0 7f 00       	push   $0x7ff000
  800de5:	6a 00                	push   $0x0
  800de7:	e8 d6 fd ff ff       	call   800bc2 <sys_page_alloc>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	0f 88 8b 00 00 00    	js     800e82 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800df7:	83 ec 04             	sub    $0x4,%esp
  800dfa:	68 00 10 00 00       	push   $0x1000
  800dff:	53                   	push   %ebx
  800e00:	68 00 f0 7f 00       	push   $0x7ff000
  800e05:	e8 4d fb ff ff       	call   800957 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e0a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e11:	53                   	push   %ebx
  800e12:	6a 00                	push   $0x0
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 e5 fd ff ff       	call   800c05 <sys_page_map>
  800e20:	83 c4 20             	add    $0x20,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 6d                	js     800e94 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 11 fe ff ff       	call   800c47 <sys_page_unmap>
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	78 69                	js     800ea6 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	53                   	push   %ebx
  800e41:	68 28 26 80 00       	push   $0x802628
  800e46:	e8 5f f3 ff ff       	call   8001aa <cprintf>

}
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800e53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800e59:	8b 4a 48             	mov    0x48(%edx),%ecx
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	c1 ea 0c             	shr    $0xc,%edx
  800e61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e68:	51                   	push   %ecx
  800e69:	53                   	push   %ebx
  800e6a:	68 00 00 40 ef       	push   $0xef400000
  800e6f:	52                   	push   %edx
  800e70:	50                   	push   %eax
  800e71:	68 cc 25 80 00       	push   $0x8025cc
  800e76:	6a 1e                	push   $0x1e
  800e78:	68 49 26 80 00       	push   $0x802649
  800e7d:	e8 95 0f 00 00       	call   801e17 <_panic>
        panic("sys_page_alloc error %e", r);
  800e82:	50                   	push   %eax
  800e83:	68 54 26 80 00       	push   $0x802654
  800e88:	6a 28                	push   $0x28
  800e8a:	68 49 26 80 00       	push   $0x802649
  800e8f:	e8 83 0f 00 00       	call   801e17 <_panic>
        panic("sys_page_map error %e", r);
  800e94:	50                   	push   %eax
  800e95:	68 6c 26 80 00       	push   $0x80266c
  800e9a:	6a 2b                	push   $0x2b
  800e9c:	68 49 26 80 00       	push   $0x802649
  800ea1:	e8 71 0f 00 00       	call   801e17 <_panic>
        panic("sys_page_unmap error %e", r);
  800ea6:	50                   	push   %eax
  800ea7:	68 82 26 80 00       	push   $0x802682
  800eac:	6a 2d                	push   $0x2d
  800eae:	68 49 26 80 00       	push   $0x802649
  800eb3:	e8 5f 0f 00 00       	call   801e17 <_panic>

00800eb8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ebe:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800ec5:	74 23                	je     800eea <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800ecf:	a1 04 40 80 00       	mov    0x804004,%eax
  800ed4:	8b 40 48             	mov    0x48(%eax),%eax
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	68 5d 1e 80 00       	push   $0x801e5d
  800edf:	50                   	push   %eax
  800ee0:	e8 28 fe ff ff       	call   800d0d <sys_env_set_pgfault_upcall>
}
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800eea:	a1 04 40 80 00       	mov    0x804004,%eax
  800eef:	8b 40 48             	mov    0x48(%eax),%eax
  800ef2:	83 ec 04             	sub    $0x4,%esp
  800ef5:	6a 07                	push   $0x7
  800ef7:	68 00 f0 bf ee       	push   $0xeebff000
  800efc:	50                   	push   %eax
  800efd:	e8 c0 fc ff ff       	call   800bc2 <sys_page_alloc>
  800f02:	83 c4 10             	add    $0x10,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	79 be                	jns    800ec7 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f09:	50                   	push   %eax
  800f0a:	68 9a 26 80 00       	push   $0x80269a
  800f0f:	6a 21                	push   $0x21
  800f11:	68 ad 26 80 00       	push   $0x8026ad
  800f16:	e8 fc 0e 00 00       	call   801e17 <_panic>

00800f1b <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	8b 75 08             	mov    0x8(%ebp),%esi
  800f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	6a 07                	push   $0x7
  800f2b:	53                   	push   %ebx
  800f2c:	56                   	push   %esi
  800f2d:	e8 90 fc ff ff       	call   800bc2 <sys_page_alloc>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 4a                	js     800f83 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 00 40 00       	push   $0x400000
  800f43:	6a 00                	push   $0x0
  800f45:	53                   	push   %ebx
  800f46:	56                   	push   %esi
  800f47:	e8 b9 fc ff ff       	call   800c05 <sys_page_map>
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 42                	js     800f95 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 00 10 00 00       	push   $0x1000
  800f5b:	53                   	push   %ebx
  800f5c:	68 00 00 40 00       	push   $0x400000
  800f61:	e8 f1 f9 ff ff       	call   800957 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f66:	83 c4 08             	add    $0x8,%esp
  800f69:	68 00 00 40 00       	push   $0x400000
  800f6e:	6a 00                	push   $0x0
  800f70:	e8 d2 fc ff ff       	call   800c47 <sys_page_unmap>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 2b                	js     800fa7 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800f7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800f83:	50                   	push   %eax
  800f84:	68 9a 26 80 00       	push   $0x80269a
  800f89:	6a 63                	push   $0x63
  800f8b:	68 49 26 80 00       	push   $0x802649
  800f90:	e8 82 0e 00 00       	call   801e17 <_panic>
        panic("sys_page_map: %e", r);
  800f95:	50                   	push   %eax
  800f96:	68 bd 26 80 00       	push   $0x8026bd
  800f9b:	6a 65                	push   $0x65
  800f9d:	68 49 26 80 00       	push   $0x802649
  800fa2:	e8 70 0e 00 00       	call   801e17 <_panic>
        panic("sys_page_unmap: %e", r);
  800fa7:	50                   	push   %eax
  800fa8:	68 ce 26 80 00       	push   $0x8026ce
  800fad:	6a 68                	push   $0x68
  800faf:	68 49 26 80 00       	push   $0x802649
  800fb4:	e8 5e 0e 00 00       	call   801e17 <_panic>

00800fb9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	57                   	push   %edi
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  800fc2:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc7:	8b 40 64             	mov    0x64(%eax),%eax
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	74 1f                	je     800fed <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fce:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd3:	cd 30                	int    $0x30
  800fd5:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  800fd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	74 21                	je     800fff <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  800fde:	be 08 40 80 00       	mov    $0x804008,%esi
  800fe3:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  800fe6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800feb:	eb 7b                	jmp    801068 <fork+0xaf>
        set_pgfault_handler(pgfault);
  800fed:	83 ec 0c             	sub    $0xc,%esp
  800ff0:	68 b3 0d 80 00       	push   $0x800db3
  800ff5:	e8 be fe ff ff       	call   800eb8 <set_pgfault_handler>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	eb cf                	jmp    800fce <fork+0x15>
        set_pgfault_handler(pgfault);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	68 b3 0d 80 00       	push   $0x800db3
  801007:	e8 ac fe ff ff       	call   800eb8 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  80100c:	e8 73 fb ff ff       	call   800b84 <sys_getenvid>
  801011:	25 ff 03 00 00       	and    $0x3ff,%eax
  801016:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801019:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80101e:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	e9 ca 00 00 00       	jmp    8010f5 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  80102b:	89 d1                	mov    %edx,%ecx
  80102d:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801033:	81 e2 02 08 00 00    	and    $0x802,%edx
  801039:	89 cf                	mov    %ecx,%edi
  80103b:	81 cf 00 08 00 00    	or     $0x800,%edi
  801041:	85 d2                	test   %edx,%edx
  801043:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	51                   	push   %ecx
  80104a:	50                   	push   %eax
  80104b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104e:	50                   	push   %eax
  80104f:	6a 00                	push   $0x0
  801051:	e8 af fb ff ff       	call   800c05 <sys_page_map>
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	78 45                	js     8010a2 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80105d:	83 c3 01             	add    $0x1,%ebx
  801060:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  801066:	74 4c                	je     8010b4 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801068:	39 de                	cmp    %ebx,%esi
  80106a:	74 f1                	je     80105d <fork+0xa4>
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  801071:	89 c2                	mov    %eax,%edx
  801073:	c1 ea 16             	shr    $0x16,%edx
  801076:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  80107d:	f6 c2 05             	test   $0x5,%dl
  801080:	74 db                	je     80105d <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 0c             	shr    $0xc,%edx
  801087:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  80108e:	f6 c2 04             	test   $0x4,%dl
  801091:	74 ca                	je     80105d <fork+0xa4>
    if (perm & PTE_SHARE) {
  801093:	f6 c6 04             	test   $0x4,%dh
  801096:	74 93                	je     80102b <fork+0x72>
        perm &= ~PTE_COW;
  801098:	89 d1                	mov    %edx,%ecx
  80109a:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8010a0:	eb a4                	jmp    801046 <fork+0x8d>
        panic("sys_page_map error %e", r);
  8010a2:	50                   	push   %eax
  8010a3:	68 6c 26 80 00       	push   $0x80266c
  8010a8:	6a 57                	push   $0x57
  8010aa:	68 49 26 80 00       	push   $0x802649
  8010af:	e8 63 0d 00 00       	call   801e17 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	b8 08 40 80 00       	mov    $0x804008,%eax
  8010bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010c1:	50                   	push   %eax
  8010c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c5:	e8 51 fe ff ff       	call   800f1b <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8010ca:	83 c4 08             	add    $0x8,%esp
  8010cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d5:	50                   	push   %eax
  8010d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d9:	e8 3d fe ff ff       	call   800f1b <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010de:	83 c4 08             	add    $0x8,%esp
  8010e1:	6a 02                	push   $0x2
  8010e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e6:	e8 9e fb ff ff       	call   800c89 <sys_env_set_status>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 0d                	js     8010ff <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8010f2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  8010f5:	89 d8                	mov    %ebx,%eax
  8010f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  8010ff:	50                   	push   %eax
  801100:	68 e1 26 80 00       	push   $0x8026e1
  801105:	68 a0 00 00 00       	push   $0xa0
  80110a:	68 49 26 80 00       	push   $0x802649
  80110f:	e8 03 0d 00 00       	call   801e17 <_panic>

00801114 <sfork>:

// Challenge!
int
sfork(void)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80111a:	68 f8 26 80 00       	push   $0x8026f8
  80111f:	68 a9 00 00 00       	push   $0xa9
  801124:	68 49 26 80 00       	push   $0x802649
  801129:	e8 e9 0c 00 00       	call   801e17 <_panic>

0080112e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	05 00 00 00 30       	add    $0x30000000,%eax
  801139:	c1 e8 0c             	shr    $0xc,%eax
}
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801149:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80114e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801160:	89 c2                	mov    %eax,%edx
  801162:	c1 ea 16             	shr    $0x16,%edx
  801165:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116c:	f6 c2 01             	test   $0x1,%dl
  80116f:	74 2a                	je     80119b <fd_alloc+0x46>
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 0c             	shr    $0xc,%edx
  801176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	74 19                	je     80119b <fd_alloc+0x46>
  801182:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801187:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118c:	75 d2                	jne    801160 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801194:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801199:	eb 07                	jmp    8011a2 <fd_alloc+0x4d>
			*fd_store = fd;
  80119b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011aa:	83 f8 1f             	cmp    $0x1f,%eax
  8011ad:	77 36                	ja     8011e5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011af:	c1 e0 0c             	shl    $0xc,%eax
  8011b2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	c1 ea 16             	shr    $0x16,%edx
  8011bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011c3:	f6 c2 01             	test   $0x1,%dl
  8011c6:	74 24                	je     8011ec <fd_lookup+0x48>
  8011c8:	89 c2                	mov    %eax,%edx
  8011ca:	c1 ea 0c             	shr    $0xc,%edx
  8011cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d4:	f6 c2 01             	test   $0x1,%dl
  8011d7:	74 1a                	je     8011f3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011dc:	89 02                	mov    %eax,(%edx)
	return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    
		return -E_INVAL;
  8011e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ea:	eb f7                	jmp    8011e3 <fd_lookup+0x3f>
		return -E_INVAL;
  8011ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f1:	eb f0                	jmp    8011e3 <fd_lookup+0x3f>
  8011f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f8:	eb e9                	jmp    8011e3 <fd_lookup+0x3f>

008011fa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
  801200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801203:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801208:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80120d:	39 08                	cmp    %ecx,(%eax)
  80120f:	74 33                	je     801244 <dev_lookup+0x4a>
  801211:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801214:	8b 02                	mov    (%edx),%eax
  801216:	85 c0                	test   %eax,%eax
  801218:	75 f3                	jne    80120d <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80121a:	a1 04 40 80 00       	mov    0x804004,%eax
  80121f:	8b 40 48             	mov    0x48(%eax),%eax
  801222:	83 ec 04             	sub    $0x4,%esp
  801225:	51                   	push   %ecx
  801226:	50                   	push   %eax
  801227:	68 10 27 80 00       	push   $0x802710
  80122c:	e8 79 ef ff ff       	call   8001aa <cprintf>
	*dev = 0;
  801231:	8b 45 0c             	mov    0xc(%ebp),%eax
  801234:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    
			*dev = devtab[i];
  801244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801247:	89 01                	mov    %eax,(%ecx)
			return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb f2                	jmp    801242 <dev_lookup+0x48>

00801250 <fd_close>:
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 1c             	sub    $0x1c,%esp
  801259:	8b 75 08             	mov    0x8(%ebp),%esi
  80125c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80125f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801262:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801263:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801269:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126c:	50                   	push   %eax
  80126d:	e8 32 ff ff ff       	call   8011a4 <fd_lookup>
  801272:	89 c3                	mov    %eax,%ebx
  801274:	83 c4 08             	add    $0x8,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 05                	js     801280 <fd_close+0x30>
	    || fd != fd2)
  80127b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80127e:	74 16                	je     801296 <fd_close+0x46>
		return (must_exist ? r : 0);
  801280:	89 f8                	mov    %edi,%eax
  801282:	84 c0                	test   %al,%al
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	0f 44 d8             	cmove  %eax,%ebx
}
  80128c:	89 d8                	mov    %ebx,%eax
  80128e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801291:	5b                   	pop    %ebx
  801292:	5e                   	pop    %esi
  801293:	5f                   	pop    %edi
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 36                	pushl  (%esi)
  80129f:	e8 56 ff ff ff       	call   8011fa <dev_lookup>
  8012a4:	89 c3                	mov    %eax,%ebx
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 15                	js     8012c2 <fd_close+0x72>
		if (dev->dev_close)
  8012ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012b0:	8b 40 10             	mov    0x10(%eax),%eax
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	74 1b                	je     8012d2 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	56                   	push   %esi
  8012bb:	ff d0                	call   *%eax
  8012bd:	89 c3                	mov    %eax,%ebx
  8012bf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	56                   	push   %esi
  8012c6:	6a 00                	push   $0x0
  8012c8:	e8 7a f9 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	eb ba                	jmp    80128c <fd_close+0x3c>
			r = 0;
  8012d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d7:	eb e9                	jmp    8012c2 <fd_close+0x72>

008012d9 <close>:

int
close(int fdnum)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	ff 75 08             	pushl  0x8(%ebp)
  8012e6:	e8 b9 fe ff ff       	call   8011a4 <fd_lookup>
  8012eb:	83 c4 08             	add    $0x8,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 10                	js     801302 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	6a 01                	push   $0x1
  8012f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fa:	e8 51 ff ff ff       	call   801250 <fd_close>
  8012ff:	83 c4 10             	add    $0x10,%esp
}
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <close_all>:

void
close_all(void)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	53                   	push   %ebx
  801308:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80130b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801310:	83 ec 0c             	sub    $0xc,%esp
  801313:	53                   	push   %ebx
  801314:	e8 c0 ff ff ff       	call   8012d9 <close>
	for (i = 0; i < MAXFD; i++)
  801319:	83 c3 01             	add    $0x1,%ebx
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	83 fb 20             	cmp    $0x20,%ebx
  801322:	75 ec                	jne    801310 <close_all+0xc>
}
  801324:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	57                   	push   %edi
  80132d:	56                   	push   %esi
  80132e:	53                   	push   %ebx
  80132f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801332:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 66 fe ff ff       	call   8011a4 <fd_lookup>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	0f 88 81 00 00 00    	js     8013cc <dup+0xa3>
		return r;
	close(newfdnum);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	ff 75 0c             	pushl  0xc(%ebp)
  801351:	e8 83 ff ff ff       	call   8012d9 <close>

	newfd = INDEX2FD(newfdnum);
  801356:	8b 75 0c             	mov    0xc(%ebp),%esi
  801359:	c1 e6 0c             	shl    $0xc,%esi
  80135c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801362:	83 c4 04             	add    $0x4,%esp
  801365:	ff 75 e4             	pushl  -0x1c(%ebp)
  801368:	e8 d1 fd ff ff       	call   80113e <fd2data>
  80136d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80136f:	89 34 24             	mov    %esi,(%esp)
  801372:	e8 c7 fd ff ff       	call   80113e <fd2data>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	c1 e8 16             	shr    $0x16,%eax
  801381:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801388:	a8 01                	test   $0x1,%al
  80138a:	74 11                	je     80139d <dup+0x74>
  80138c:	89 d8                	mov    %ebx,%eax
  80138e:	c1 e8 0c             	shr    $0xc,%eax
  801391:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801398:	f6 c2 01             	test   $0x1,%dl
  80139b:	75 39                	jne    8013d6 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a0:	89 d0                	mov    %edx,%eax
  8013a2:	c1 e8 0c             	shr    $0xc,%eax
  8013a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b4:	50                   	push   %eax
  8013b5:	56                   	push   %esi
  8013b6:	6a 00                	push   $0x0
  8013b8:	52                   	push   %edx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 45 f8 ff ff       	call   800c05 <sys_page_map>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 20             	add    $0x20,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 31                	js     8013fa <dup+0xd1>
		goto err;

	return newfdnum;
  8013c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013cc:	89 d8                	mov    %ebx,%eax
  8013ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013dd:	83 ec 0c             	sub    $0xc,%esp
  8013e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e5:	50                   	push   %eax
  8013e6:	57                   	push   %edi
  8013e7:	6a 00                	push   $0x0
  8013e9:	53                   	push   %ebx
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 14 f8 ff ff       	call   800c05 <sys_page_map>
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	83 c4 20             	add    $0x20,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	79 a3                	jns    80139d <dup+0x74>
	sys_page_unmap(0, newfd);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	56                   	push   %esi
  8013fe:	6a 00                	push   $0x0
  801400:	e8 42 f8 ff ff       	call   800c47 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801405:	83 c4 08             	add    $0x8,%esp
  801408:	57                   	push   %edi
  801409:	6a 00                	push   $0x0
  80140b:	e8 37 f8 ff ff       	call   800c47 <sys_page_unmap>
	return r;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb b7                	jmp    8013cc <dup+0xa3>

00801415 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	53                   	push   %ebx
  801419:	83 ec 14             	sub    $0x14,%esp
  80141c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	53                   	push   %ebx
  801424:	e8 7b fd ff ff       	call   8011a4 <fd_lookup>
  801429:	83 c4 08             	add    $0x8,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 3f                	js     80146f <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	ff 30                	pushl  (%eax)
  80143c:	e8 b9 fd ff ff       	call   8011fa <dev_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 27                	js     80146f <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144b:	8b 42 08             	mov    0x8(%edx),%eax
  80144e:	83 e0 03             	and    $0x3,%eax
  801451:	83 f8 01             	cmp    $0x1,%eax
  801454:	74 1e                	je     801474 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801456:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801459:	8b 40 08             	mov    0x8(%eax),%eax
  80145c:	85 c0                	test   %eax,%eax
  80145e:	74 35                	je     801495 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801460:	83 ec 04             	sub    $0x4,%esp
  801463:	ff 75 10             	pushl  0x10(%ebp)
  801466:	ff 75 0c             	pushl  0xc(%ebp)
  801469:	52                   	push   %edx
  80146a:	ff d0                	call   *%eax
  80146c:	83 c4 10             	add    $0x10,%esp
}
  80146f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801472:	c9                   	leave  
  801473:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801474:	a1 04 40 80 00       	mov    0x804004,%eax
  801479:	8b 40 48             	mov    0x48(%eax),%eax
  80147c:	83 ec 04             	sub    $0x4,%esp
  80147f:	53                   	push   %ebx
  801480:	50                   	push   %eax
  801481:	68 51 27 80 00       	push   $0x802751
  801486:	e8 1f ed ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801493:	eb da                	jmp    80146f <read+0x5a>
		return -E_NOT_SUPP;
  801495:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80149a:	eb d3                	jmp    80146f <read+0x5a>

0080149c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	57                   	push   %edi
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 0c             	sub    $0xc,%esp
  8014a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b0:	39 f3                	cmp    %esi,%ebx
  8014b2:	73 25                	jae    8014d9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	89 f0                	mov    %esi,%eax
  8014b9:	29 d8                	sub    %ebx,%eax
  8014bb:	50                   	push   %eax
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	03 45 0c             	add    0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	57                   	push   %edi
  8014c3:	e8 4d ff ff ff       	call   801415 <read>
		if (m < 0)
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 08                	js     8014d7 <readn+0x3b>
			return m;
		if (m == 0)
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	74 06                	je     8014d9 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8014d3:	01 c3                	add    %eax,%ebx
  8014d5:	eb d9                	jmp    8014b0 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014d7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014d9:	89 d8                	mov    %ebx,%eax
  8014db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5e                   	pop    %esi
  8014e0:	5f                   	pop    %edi
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 14             	sub    $0x14,%esp
  8014ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	53                   	push   %ebx
  8014f2:	e8 ad fc ff ff       	call   8011a4 <fd_lookup>
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 3a                	js     801538 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801508:	ff 30                	pushl  (%eax)
  80150a:	e8 eb fc ff ff       	call   8011fa <dev_lookup>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 22                	js     801538 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151d:	74 1e                	je     80153d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80151f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801522:	8b 52 0c             	mov    0xc(%edx),%edx
  801525:	85 d2                	test   %edx,%edx
  801527:	74 35                	je     80155e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	ff 75 10             	pushl  0x10(%ebp)
  80152f:	ff 75 0c             	pushl  0xc(%ebp)
  801532:	50                   	push   %eax
  801533:	ff d2                	call   *%edx
  801535:	83 c4 10             	add    $0x10,%esp
}
  801538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80153d:	a1 04 40 80 00       	mov    0x804004,%eax
  801542:	8b 40 48             	mov    0x48(%eax),%eax
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	53                   	push   %ebx
  801549:	50                   	push   %eax
  80154a:	68 6d 27 80 00       	push   $0x80276d
  80154f:	e8 56 ec ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80155c:	eb da                	jmp    801538 <write+0x55>
		return -E_NOT_SUPP;
  80155e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801563:	eb d3                	jmp    801538 <write+0x55>

00801565 <seek>:

int
seek(int fdnum, off_t offset)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	ff 75 08             	pushl  0x8(%ebp)
  801572:	e8 2d fc ff ff       	call   8011a4 <fd_lookup>
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 0e                	js     80158c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80157e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801581:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801584:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 14             	sub    $0x14,%esp
  801595:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801598:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	53                   	push   %ebx
  80159d:	e8 02 fc ff ff       	call   8011a4 <fd_lookup>
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 37                	js     8015e0 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b3:	ff 30                	pushl  (%eax)
  8015b5:	e8 40 fc ff ff       	call   8011fa <dev_lookup>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 1f                	js     8015e0 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c8:	74 1b                	je     8015e5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	8b 52 18             	mov    0x18(%edx),%edx
  8015d0:	85 d2                	test   %edx,%edx
  8015d2:	74 32                	je     801606 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	50                   	push   %eax
  8015db:	ff d2                	call   *%edx
  8015dd:	83 c4 10             	add    $0x10,%esp
}
  8015e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015e5:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ea:	8b 40 48             	mov    0x48(%eax),%eax
  8015ed:	83 ec 04             	sub    $0x4,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	50                   	push   %eax
  8015f2:	68 30 27 80 00       	push   $0x802730
  8015f7:	e8 ae eb ff ff       	call   8001aa <cprintf>
		return -E_INVAL;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801604:	eb da                	jmp    8015e0 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801606:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80160b:	eb d3                	jmp    8015e0 <ftruncate+0x52>

0080160d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	53                   	push   %ebx
  801611:	83 ec 14             	sub    $0x14,%esp
  801614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801617:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	ff 75 08             	pushl  0x8(%ebp)
  80161e:	e8 81 fb ff ff       	call   8011a4 <fd_lookup>
  801623:	83 c4 08             	add    $0x8,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	78 4b                	js     801675 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801634:	ff 30                	pushl  (%eax)
  801636:	e8 bf fb ff ff       	call   8011fa <dev_lookup>
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 33                	js     801675 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801649:	74 2f                	je     80167a <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80164b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80164e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801655:	00 00 00 
	stat->st_isdir = 0;
  801658:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165f:	00 00 00 
	stat->st_dev = dev;
  801662:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	53                   	push   %ebx
  80166c:	ff 75 f0             	pushl  -0x10(%ebp)
  80166f:	ff 50 14             	call   *0x14(%eax)
  801672:	83 c4 10             	add    $0x10,%esp
}
  801675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801678:	c9                   	leave  
  801679:	c3                   	ret    
		return -E_NOT_SUPP;
  80167a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167f:	eb f4                	jmp    801675 <fstat+0x68>

00801681 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	6a 00                	push   $0x0
  80168b:	ff 75 08             	pushl  0x8(%ebp)
  80168e:	e8 e7 01 00 00       	call   80187a <open>
  801693:	89 c3                	mov    %eax,%ebx
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 1b                	js     8016b7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80169c:	83 ec 08             	sub    $0x8,%esp
  80169f:	ff 75 0c             	pushl  0xc(%ebp)
  8016a2:	50                   	push   %eax
  8016a3:	e8 65 ff ff ff       	call   80160d <fstat>
  8016a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8016aa:	89 1c 24             	mov    %ebx,(%esp)
  8016ad:	e8 27 fc ff ff       	call   8012d9 <close>
	return r;
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	89 f3                	mov    %esi,%ebx
}
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	89 c6                	mov    %eax,%esi
  8016c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016d0:	74 27                	je     8016f9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d2:	6a 07                	push   $0x7
  8016d4:	68 00 50 80 00       	push   $0x805000
  8016d9:	56                   	push   %esi
  8016da:	ff 35 00 40 80 00    	pushl  0x804000
  8016e0:	e8 ff 07 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e5:	83 c4 0c             	add    $0xc,%esp
  8016e8:	6a 00                	push   $0x0
  8016ea:	53                   	push   %ebx
  8016eb:	6a 00                	push   $0x0
  8016ed:	e8 91 07 00 00       	call   801e83 <ipc_recv>
}
  8016f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f9:	83 ec 0c             	sub    $0xc,%esp
  8016fc:	6a 01                	push   $0x1
  8016fe:	e8 2e 08 00 00       	call   801f31 <ipc_find_env>
  801703:	a3 00 40 80 00       	mov    %eax,0x804000
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	eb c5                	jmp    8016d2 <fsipc+0x12>

0080170d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80171e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801721:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 02 00 00 00       	mov    $0x2,%eax
  801730:	e8 8b ff ff ff       	call   8016c0 <fsipc>
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_flush>:
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 06 00 00 00       	mov    $0x6,%eax
  801752:	e8 69 ff ff ff       	call   8016c0 <fsipc>
}
  801757:	c9                   	leave  
  801758:	c3                   	ret    

00801759 <devfile_stat>:
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	83 ec 04             	sub    $0x4,%esp
  801760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801763:	8b 45 08             	mov    0x8(%ebp),%eax
  801766:	8b 40 0c             	mov    0xc(%eax),%eax
  801769:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 05 00 00 00       	mov    $0x5,%eax
  801778:	e8 43 ff ff ff       	call   8016c0 <fsipc>
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 2c                	js     8017ad <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	68 00 50 80 00       	push   $0x805000
  801789:	53                   	push   %ebx
  80178a:	e8 3a f0 ff ff       	call   8007c9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80178f:	a1 80 50 80 00       	mov    0x805080,%eax
  801794:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179a:	a1 84 50 80 00       	mov    0x805084,%eax
  80179f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_write>:
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 0c             	sub    $0xc,%esp
  8017b8:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8017bb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017c5:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ce:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8017d4:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8017d9:	50                   	push   %eax
  8017da:	ff 75 0c             	pushl  0xc(%ebp)
  8017dd:	68 08 50 80 00       	push   $0x805008
  8017e2:	e8 70 f1 ff ff       	call   800957 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f1:	e8 ca fe ff ff       	call   8016c0 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_read>:
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	56                   	push   %esi
  8017fc:	53                   	push   %ebx
  8017fd:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
  801803:	8b 40 0c             	mov    0xc(%eax),%eax
  801806:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 03 00 00 00       	mov    $0x3,%eax
  80181b:	e8 a0 fe ff ff       	call   8016c0 <fsipc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	85 c0                	test   %eax,%eax
  801824:	78 1f                	js     801845 <devfile_read+0x4d>
	assert(r <= n);
  801826:	39 f0                	cmp    %esi,%eax
  801828:	77 24                	ja     80184e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80182a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80182f:	7f 33                	jg     801864 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	50                   	push   %eax
  801835:	68 00 50 80 00       	push   $0x805000
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	e8 15 f1 ff ff       	call   800957 <memmove>
	return r;
  801842:	83 c4 10             	add    $0x10,%esp
}
  801845:	89 d8                	mov    %ebx,%eax
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    
	assert(r <= n);
  80184e:	68 9c 27 80 00       	push   $0x80279c
  801853:	68 a3 27 80 00       	push   $0x8027a3
  801858:	6a 7d                	push   $0x7d
  80185a:	68 b8 27 80 00       	push   $0x8027b8
  80185f:	e8 b3 05 00 00       	call   801e17 <_panic>
	assert(r <= PGSIZE);
  801864:	68 c3 27 80 00       	push   $0x8027c3
  801869:	68 a3 27 80 00       	push   $0x8027a3
  80186e:	6a 7e                	push   $0x7e
  801870:	68 b8 27 80 00       	push   $0x8027b8
  801875:	e8 9d 05 00 00       	call   801e17 <_panic>

0080187a <open>:
{
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	56                   	push   %esi
  80187e:	53                   	push   %ebx
  80187f:	83 ec 1c             	sub    $0x1c,%esp
  801882:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801885:	56                   	push   %esi
  801886:	e8 07 ef ff ff       	call   800792 <strlen>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801893:	0f 8f 96 00 00 00    	jg     80192f <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	e8 b0 f8 ff ff       	call   801155 <fd_alloc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 66                	js     801914 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	56                   	push   %esi
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	e8 0d ef ff ff       	call   8007c9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018cc:	e8 ef fd ff ff       	call   8016c0 <fsipc>
  8018d1:	89 c3                	mov    %eax,%ebx
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	85 c0                	test   %eax,%eax
  8018d8:	78 43                	js     80191d <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e0:	e8 49 f8 ff ff       	call   80112e <fd2num>
  8018e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e8:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8018ee:	8b 49 48             	mov    0x48(%ecx),%ecx
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	50                   	push   %eax
  8018f5:	52                   	push   %edx
  8018f6:	ff 32                	pushl  (%edx)
  8018f8:	56                   	push   %esi
  8018f9:	51                   	push   %ecx
  8018fa:	68 d0 27 80 00       	push   $0x8027d0
  8018ff:	e8 a6 e8 ff ff       	call   8001aa <cprintf>
	return fd2num(fd);
  801904:	83 c4 14             	add    $0x14,%esp
  801907:	ff 75 f4             	pushl  -0xc(%ebp)
  80190a:	e8 1f f8 ff ff       	call   80112e <fd2num>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	83 c4 10             	add    $0x10,%esp
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    
		fd_close(fd, 0);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	6a 00                	push   $0x0
  801922:	ff 75 f4             	pushl  -0xc(%ebp)
  801925:	e8 26 f9 ff ff       	call   801250 <fd_close>
		return r;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	eb e5                	jmp    801914 <open+0x9a>
		return -E_BAD_PATH;
  80192f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801934:	eb de                	jmp    801914 <open+0x9a>

00801936 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193c:	ba 00 00 00 00       	mov    $0x0,%edx
  801941:	b8 08 00 00 00       	mov    $0x8,%eax
  801946:	e8 75 fd ff ff       	call   8016c0 <fsipc>
}
  80194b:	c9                   	leave  
  80194c:	c3                   	ret    

0080194d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	56                   	push   %esi
  801951:	53                   	push   %ebx
  801952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	ff 75 08             	pushl  0x8(%ebp)
  80195b:	e8 de f7 ff ff       	call   80113e <fd2data>
  801960:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801962:	83 c4 08             	add    $0x8,%esp
  801965:	68 0f 28 80 00       	push   $0x80280f
  80196a:	53                   	push   %ebx
  80196b:	e8 59 ee ff ff       	call   8007c9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801970:	8b 46 04             	mov    0x4(%esi),%eax
  801973:	2b 06                	sub    (%esi),%eax
  801975:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80197b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801982:	00 00 00 
	stat->st_dev = &devpipe;
  801985:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80198c:	30 80 00 
	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	53                   	push   %ebx
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a5:	53                   	push   %ebx
  8019a6:	6a 00                	push   $0x0
  8019a8:	e8 9a f2 ff ff       	call   800c47 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ad:	89 1c 24             	mov    %ebx,(%esp)
  8019b0:	e8 89 f7 ff ff       	call   80113e <fd2data>
  8019b5:	83 c4 08             	add    $0x8,%esp
  8019b8:	50                   	push   %eax
  8019b9:	6a 00                	push   $0x0
  8019bb:	e8 87 f2 ff ff       	call   800c47 <sys_page_unmap>
}
  8019c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <_pipeisclosed>:
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 1c             	sub    $0x1c,%esp
  8019ce:	89 c7                	mov    %eax,%edi
  8019d0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8019d7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	57                   	push   %edi
  8019de:	e8 87 05 00 00       	call   801f6a <pageref>
  8019e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019e6:	89 34 24             	mov    %esi,(%esp)
  8019e9:	e8 7c 05 00 00       	call   801f6a <pageref>
		nn = thisenv->env_runs;
  8019ee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	39 cb                	cmp    %ecx,%ebx
  8019fc:	74 1b                	je     801a19 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019fe:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a01:	75 cf                	jne    8019d2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a03:	8b 42 58             	mov    0x58(%edx),%eax
  801a06:	6a 01                	push   $0x1
  801a08:	50                   	push   %eax
  801a09:	53                   	push   %ebx
  801a0a:	68 16 28 80 00       	push   $0x802816
  801a0f:	e8 96 e7 ff ff       	call   8001aa <cprintf>
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	eb b9                	jmp    8019d2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a19:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a1c:	0f 94 c0             	sete   %al
  801a1f:	0f b6 c0             	movzbl %al,%eax
}
  801a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <devpipe_write>:
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	57                   	push   %edi
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	83 ec 28             	sub    $0x28,%esp
  801a33:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a36:	56                   	push   %esi
  801a37:	e8 02 f7 ff ff       	call   80113e <fd2data>
  801a3c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	bf 00 00 00 00       	mov    $0x0,%edi
  801a46:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a49:	74 4f                	je     801a9a <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a4b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a4e:	8b 0b                	mov    (%ebx),%ecx
  801a50:	8d 51 20             	lea    0x20(%ecx),%edx
  801a53:	39 d0                	cmp    %edx,%eax
  801a55:	72 14                	jb     801a6b <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801a57:	89 da                	mov    %ebx,%edx
  801a59:	89 f0                	mov    %esi,%eax
  801a5b:	e8 65 ff ff ff       	call   8019c5 <_pipeisclosed>
  801a60:	85 c0                	test   %eax,%eax
  801a62:	75 3a                	jne    801a9e <devpipe_write+0x74>
			sys_yield();
  801a64:	e8 3a f1 ff ff       	call   800ba3 <sys_yield>
  801a69:	eb e0                	jmp    801a4b <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a75:	89 c2                	mov    %eax,%edx
  801a77:	c1 fa 1f             	sar    $0x1f,%edx
  801a7a:	89 d1                	mov    %edx,%ecx
  801a7c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a82:	83 e2 1f             	and    $0x1f,%edx
  801a85:	29 ca                	sub    %ecx,%edx
  801a87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a8f:	83 c0 01             	add    $0x1,%eax
  801a92:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a95:	83 c7 01             	add    $0x1,%edi
  801a98:	eb ac                	jmp    801a46 <devpipe_write+0x1c>
	return i;
  801a9a:	89 f8                	mov    %edi,%eax
  801a9c:	eb 05                	jmp    801aa3 <devpipe_write+0x79>
				return 0;
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa6:	5b                   	pop    %ebx
  801aa7:	5e                   	pop    %esi
  801aa8:	5f                   	pop    %edi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devpipe_read>:
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	57                   	push   %edi
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 18             	sub    $0x18,%esp
  801ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ab7:	57                   	push   %edi
  801ab8:	e8 81 f6 ff ff       	call   80113e <fd2data>
  801abd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	be 00 00 00 00       	mov    $0x0,%esi
  801ac7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801aca:	74 47                	je     801b13 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801acc:	8b 03                	mov    (%ebx),%eax
  801ace:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ad1:	75 22                	jne    801af5 <devpipe_read+0x4a>
			if (i > 0)
  801ad3:	85 f6                	test   %esi,%esi
  801ad5:	75 14                	jne    801aeb <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801ad7:	89 da                	mov    %ebx,%edx
  801ad9:	89 f8                	mov    %edi,%eax
  801adb:	e8 e5 fe ff ff       	call   8019c5 <_pipeisclosed>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	75 33                	jne    801b17 <devpipe_read+0x6c>
			sys_yield();
  801ae4:	e8 ba f0 ff ff       	call   800ba3 <sys_yield>
  801ae9:	eb e1                	jmp    801acc <devpipe_read+0x21>
				return i;
  801aeb:	89 f0                	mov    %esi,%eax
}
  801aed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5e                   	pop    %esi
  801af2:	5f                   	pop    %edi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af5:	99                   	cltd   
  801af6:	c1 ea 1b             	shr    $0x1b,%edx
  801af9:	01 d0                	add    %edx,%eax
  801afb:	83 e0 1f             	and    $0x1f,%eax
  801afe:	29 d0                	sub    %edx,%eax
  801b00:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b08:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b0b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b0e:	83 c6 01             	add    $0x1,%esi
  801b11:	eb b4                	jmp    801ac7 <devpipe_read+0x1c>
	return i;
  801b13:	89 f0                	mov    %esi,%eax
  801b15:	eb d6                	jmp    801aed <devpipe_read+0x42>
				return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1c:	eb cf                	jmp    801aed <devpipe_read+0x42>

00801b1e <pipe>:
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b29:	50                   	push   %eax
  801b2a:	e8 26 f6 ff ff       	call   801155 <fd_alloc>
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 5b                	js     801b93 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b38:	83 ec 04             	sub    $0x4,%esp
  801b3b:	68 07 04 00 00       	push   $0x407
  801b40:	ff 75 f4             	pushl  -0xc(%ebp)
  801b43:	6a 00                	push   $0x0
  801b45:	e8 78 f0 ff ff       	call   800bc2 <sys_page_alloc>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 40                	js     801b93 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b59:	50                   	push   %eax
  801b5a:	e8 f6 f5 ff ff       	call   801155 <fd_alloc>
  801b5f:	89 c3                	mov    %eax,%ebx
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 1b                	js     801b83 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b68:	83 ec 04             	sub    $0x4,%esp
  801b6b:	68 07 04 00 00       	push   $0x407
  801b70:	ff 75 f0             	pushl  -0x10(%ebp)
  801b73:	6a 00                	push   $0x0
  801b75:	e8 48 f0 ff ff       	call   800bc2 <sys_page_alloc>
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	83 c4 10             	add    $0x10,%esp
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	79 19                	jns    801b9c <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801b83:	83 ec 08             	sub    $0x8,%esp
  801b86:	ff 75 f4             	pushl  -0xc(%ebp)
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 b7 f0 ff ff       	call   800c47 <sys_page_unmap>
  801b90:	83 c4 10             	add    $0x10,%esp
}
  801b93:	89 d8                	mov    %ebx,%eax
  801b95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5d                   	pop    %ebp
  801b9b:	c3                   	ret    
	va = fd2data(fd0);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba2:	e8 97 f5 ff ff       	call   80113e <fd2data>
  801ba7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba9:	83 c4 0c             	add    $0xc,%esp
  801bac:	68 07 04 00 00       	push   $0x407
  801bb1:	50                   	push   %eax
  801bb2:	6a 00                	push   $0x0
  801bb4:	e8 09 f0 ff ff       	call   800bc2 <sys_page_alloc>
  801bb9:	89 c3                	mov    %eax,%ebx
  801bbb:	83 c4 10             	add    $0x10,%esp
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	0f 88 8c 00 00 00    	js     801c52 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bcc:	e8 6d f5 ff ff       	call   80113e <fd2data>
  801bd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd8:	50                   	push   %eax
  801bd9:	6a 00                	push   $0x0
  801bdb:	56                   	push   %esi
  801bdc:	6a 00                	push   $0x0
  801bde:	e8 22 f0 ff ff       	call   800c05 <sys_page_map>
  801be3:	89 c3                	mov    %eax,%ebx
  801be5:	83 c4 20             	add    $0x20,%esp
  801be8:	85 c0                	test   %eax,%eax
  801bea:	78 58                	js     801c44 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bef:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c04:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1c:	e8 0d f5 ff ff       	call   80112e <fd2num>
  801c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c26:	83 c4 04             	add    $0x4,%esp
  801c29:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2c:	e8 fd f4 ff ff       	call   80112e <fd2num>
  801c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3f:	e9 4f ff ff ff       	jmp    801b93 <pipe+0x75>
	sys_page_unmap(0, va);
  801c44:	83 ec 08             	sub    $0x8,%esp
  801c47:	56                   	push   %esi
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 f8 ef ff ff       	call   800c47 <sys_page_unmap>
  801c4f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c52:	83 ec 08             	sub    $0x8,%esp
  801c55:	ff 75 f0             	pushl  -0x10(%ebp)
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 e8 ef ff ff       	call   800c47 <sys_page_unmap>
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	e9 1c ff ff ff       	jmp    801b83 <pipe+0x65>

00801c67 <pipeisclosed>:
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c70:	50                   	push   %eax
  801c71:	ff 75 08             	pushl  0x8(%ebp)
  801c74:	e8 2b f5 ff ff       	call   8011a4 <fd_lookup>
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	78 18                	js     801c98 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c80:	83 ec 0c             	sub    $0xc,%esp
  801c83:	ff 75 f4             	pushl  -0xc(%ebp)
  801c86:	e8 b3 f4 ff ff       	call   80113e <fd2data>
	return _pipeisclosed(fd, p);
  801c8b:	89 c2                	mov    %eax,%edx
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	e8 30 fd ff ff       	call   8019c5 <_pipeisclosed>
  801c95:	83 c4 10             	add    $0x10,%esp
}
  801c98:	c9                   	leave  
  801c99:	c3                   	ret    

00801c9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801caa:	68 2e 28 80 00       	push   $0x80282e
  801caf:	ff 75 0c             	pushl  0xc(%ebp)
  801cb2:	e8 12 eb ff ff       	call   8007c9 <strcpy>
	return 0;
}
  801cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <devcons_write>:
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cca:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ccf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801cd5:	eb 2f                	jmp    801d06 <devcons_write+0x48>
		m = n - tot;
  801cd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cda:	29 f3                	sub    %esi,%ebx
  801cdc:	83 fb 7f             	cmp    $0x7f,%ebx
  801cdf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ce4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	53                   	push   %ebx
  801ceb:	89 f0                	mov    %esi,%eax
  801ced:	03 45 0c             	add    0xc(%ebp),%eax
  801cf0:	50                   	push   %eax
  801cf1:	57                   	push   %edi
  801cf2:	e8 60 ec ff ff       	call   800957 <memmove>
		sys_cputs(buf, m);
  801cf7:	83 c4 08             	add    $0x8,%esp
  801cfa:	53                   	push   %ebx
  801cfb:	57                   	push   %edi
  801cfc:	e8 05 ee ff ff       	call   800b06 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d01:	01 de                	add    %ebx,%esi
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d09:	72 cc                	jb     801cd7 <devcons_write+0x19>
}
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <devcons_read>:
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d24:	75 07                	jne    801d2d <devcons_read+0x18>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    
		sys_yield();
  801d28:	e8 76 ee ff ff       	call   800ba3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d2d:	e8 f2 ed ff ff       	call   800b24 <sys_cgetc>
  801d32:	85 c0                	test   %eax,%eax
  801d34:	74 f2                	je     801d28 <devcons_read+0x13>
	if (c < 0)
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 ec                	js     801d26 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801d3a:	83 f8 04             	cmp    $0x4,%eax
  801d3d:	74 0c                	je     801d4b <devcons_read+0x36>
	*(char*)vbuf = c;
  801d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d42:	88 02                	mov    %al,(%edx)
	return 1;
  801d44:	b8 01 00 00 00       	mov    $0x1,%eax
  801d49:	eb db                	jmp    801d26 <devcons_read+0x11>
		return 0;
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	eb d4                	jmp    801d26 <devcons_read+0x11>

00801d52 <cputchar>:
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d5e:	6a 01                	push   $0x1
  801d60:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d63:	50                   	push   %eax
  801d64:	e8 9d ed ff ff       	call   800b06 <sys_cputs>
}
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <getchar>:
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d74:	6a 01                	push   $0x1
  801d76:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 94 f6 ff ff       	call   801415 <read>
	if (r < 0)
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	78 08                	js     801d90 <getchar+0x22>
	if (r < 1)
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	7e 06                	jle    801d92 <getchar+0x24>
	return c;
  801d8c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    
		return -E_EOF;
  801d92:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d97:	eb f7                	jmp    801d90 <getchar+0x22>

00801d99 <iscons>:
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	ff 75 08             	pushl  0x8(%ebp)
  801da6:	e8 f9 f3 ff ff       	call   8011a4 <fd_lookup>
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 11                	js     801dc3 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dbb:	39 10                	cmp    %edx,(%eax)
  801dbd:	0f 94 c0             	sete   %al
  801dc0:	0f b6 c0             	movzbl %al,%eax
}
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <opencons>:
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801dcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dce:	50                   	push   %eax
  801dcf:	e8 81 f3 ff ff       	call   801155 <fd_alloc>
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 3a                	js     801e15 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddb:	83 ec 04             	sub    $0x4,%esp
  801dde:	68 07 04 00 00       	push   $0x407
  801de3:	ff 75 f4             	pushl  -0xc(%ebp)
  801de6:	6a 00                	push   $0x0
  801de8:	e8 d5 ed ff ff       	call   800bc2 <sys_page_alloc>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 21                	js     801e15 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dfd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e09:	83 ec 0c             	sub    $0xc,%esp
  801e0c:	50                   	push   %eax
  801e0d:	e8 1c f3 ff ff       	call   80112e <fd2num>
  801e12:	83 c4 10             	add    $0x10,%esp
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e1c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e1f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e25:	e8 5a ed ff ff       	call   800b84 <sys_getenvid>
  801e2a:	83 ec 0c             	sub    $0xc,%esp
  801e2d:	ff 75 0c             	pushl  0xc(%ebp)
  801e30:	ff 75 08             	pushl  0x8(%ebp)
  801e33:	56                   	push   %esi
  801e34:	50                   	push   %eax
  801e35:	68 3c 28 80 00       	push   $0x80283c
  801e3a:	e8 6b e3 ff ff       	call   8001aa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e3f:	83 c4 18             	add    $0x18,%esp
  801e42:	53                   	push   %ebx
  801e43:	ff 75 10             	pushl  0x10(%ebp)
  801e46:	e8 0e e3 ff ff       	call   800159 <vcprintf>
	cprintf("\n");
  801e4b:	c7 04 24 94 22 80 00 	movl   $0x802294,(%esp)
  801e52:	e8 53 e3 ff ff       	call   8001aa <cprintf>
  801e57:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e5a:	cc                   	int3   
  801e5b:	eb fd                	jmp    801e5a <_panic+0x43>

00801e5d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e5d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e5e:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801e63:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e65:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801e68:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801e6b:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801e6f:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801e73:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801e76:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801e7a:	89 18                	mov    %ebx,(%eax)

    popal
  801e7c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801e7d:	83 c4 04             	add    $0x4,%esp
    popfl
  801e80:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801e81:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801e82:	c3                   	ret    

00801e83 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	56                   	push   %esi
  801e87:	53                   	push   %ebx
  801e88:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801e91:	85 c0                	test   %eax,%eax
  801e93:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e98:	0f 44 c2             	cmove  %edx,%eax
  801e9b:	83 ec 0c             	sub    $0xc,%esp
  801e9e:	50                   	push   %eax
  801e9f:	e8 ce ee ff ff       	call   800d72 <sys_ipc_recv>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 2b                	js     801ed6 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801eab:	85 f6                	test   %esi,%esi
  801ead:	74 0a                	je     801eb9 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801eaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb4:	8b 40 74             	mov    0x74(%eax),%eax
  801eb7:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801eb9:	85 db                	test   %ebx,%ebx
  801ebb:	74 0a                	je     801ec7 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801ebd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec2:	8b 40 78             	mov    0x78(%eax),%eax
  801ec5:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801ec7:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecc:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ecf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    
        *from_env_store = 0;
  801ed6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801edc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801ee2:	eb eb                	jmp    801ecf <ipc_recv+0x4c>

00801ee4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801ef6:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801ef8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801f00:	ff 75 14             	pushl  0x14(%ebp)
  801f03:	53                   	push   %ebx
  801f04:	56                   	push   %esi
  801f05:	57                   	push   %edi
  801f06:	e8 44 ee ff ff       	call   800d4f <sys_ipc_try_send>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	74 17                	je     801f29 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801f12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f15:	74 e9                	je     801f00 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801f17:	50                   	push   %eax
  801f18:	68 60 28 80 00       	push   $0x802860
  801f1d:	6a 3e                	push   $0x3e
  801f1f:	68 72 28 80 00       	push   $0x802872
  801f24:	e8 ee fe ff ff       	call   801e17 <_panic>
        }
    }
}
  801f29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f2c:	5b                   	pop    %ebx
  801f2d:	5e                   	pop    %esi
  801f2e:	5f                   	pop    %edi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f3c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f3f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f45:	8b 52 50             	mov    0x50(%edx),%edx
  801f48:	39 ca                	cmp    %ecx,%edx
  801f4a:	74 11                	je     801f5d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f4c:	83 c0 01             	add    $0x1,%eax
  801f4f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f54:	75 e6                	jne    801f3c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5b:	eb 0b                	jmp    801f68 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f5d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f65:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f70:	89 d0                	mov    %edx,%eax
  801f72:	c1 e8 16             	shr    $0x16,%eax
  801f75:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f81:	f6 c1 01             	test   $0x1,%cl
  801f84:	74 1d                	je     801fa3 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f86:	c1 ea 0c             	shr    $0xc,%edx
  801f89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f90:	f6 c2 01             	test   $0x1,%dl
  801f93:	74 0e                	je     801fa3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f95:	c1 ea 0c             	shr    $0xc,%edx
  801f98:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f9f:	ef 
  801fa0:	0f b7 c0             	movzwl %ax,%eax
}
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    
  801fa5:	66 90                	xchg   %ax,%ax
  801fa7:	66 90                	xchg   %ax,%ax
  801fa9:	66 90                	xchg   %ax,%ax
  801fab:	66 90                	xchg   %ax,%ax
  801fad:	66 90                	xchg   %ax,%ax
  801faf:	90                   	nop

00801fb0 <__udivdi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
  801fb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801fbb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801fbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fc3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801fc7:	85 d2                	test   %edx,%edx
  801fc9:	75 35                	jne    802000 <__udivdi3+0x50>
  801fcb:	39 f3                	cmp    %esi,%ebx
  801fcd:	0f 87 bd 00 00 00    	ja     802090 <__udivdi3+0xe0>
  801fd3:	85 db                	test   %ebx,%ebx
  801fd5:	89 d9                	mov    %ebx,%ecx
  801fd7:	75 0b                	jne    801fe4 <__udivdi3+0x34>
  801fd9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f3                	div    %ebx
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	31 d2                	xor    %edx,%edx
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	f7 f1                	div    %ecx
  801fea:	89 c6                	mov    %eax,%esi
  801fec:	89 e8                	mov    %ebp,%eax
  801fee:	89 f7                	mov    %esi,%edi
  801ff0:	f7 f1                	div    %ecx
  801ff2:	89 fa                	mov    %edi,%edx
  801ff4:	83 c4 1c             	add    $0x1c,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5e                   	pop    %esi
  801ff9:	5f                   	pop    %edi
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    
  801ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802000:	39 f2                	cmp    %esi,%edx
  802002:	77 7c                	ja     802080 <__udivdi3+0xd0>
  802004:	0f bd fa             	bsr    %edx,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0xf8>
  802010:	89 f9                	mov    %edi,%ecx
  802012:	b8 20 00 00 00       	mov    $0x20,%eax
  802017:	29 f8                	sub    %edi,%eax
  802019:	d3 e2                	shl    %cl,%edx
  80201b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	89 da                	mov    %ebx,%edx
  802023:	d3 ea                	shr    %cl,%edx
  802025:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802029:	09 d1                	or     %edx,%ecx
  80202b:	89 f2                	mov    %esi,%edx
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f9                	mov    %edi,%ecx
  802033:	d3 e3                	shl    %cl,%ebx
  802035:	89 c1                	mov    %eax,%ecx
  802037:	d3 ea                	shr    %cl,%edx
  802039:	89 f9                	mov    %edi,%ecx
  80203b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80203f:	d3 e6                	shl    %cl,%esi
  802041:	89 eb                	mov    %ebp,%ebx
  802043:	89 c1                	mov    %eax,%ecx
  802045:	d3 eb                	shr    %cl,%ebx
  802047:	09 de                	or     %ebx,%esi
  802049:	89 f0                	mov    %esi,%eax
  80204b:	f7 74 24 08          	divl   0x8(%esp)
  80204f:	89 d6                	mov    %edx,%esi
  802051:	89 c3                	mov    %eax,%ebx
  802053:	f7 64 24 0c          	mull   0xc(%esp)
  802057:	39 d6                	cmp    %edx,%esi
  802059:	72 0c                	jb     802067 <__udivdi3+0xb7>
  80205b:	89 f9                	mov    %edi,%ecx
  80205d:	d3 e5                	shl    %cl,%ebp
  80205f:	39 c5                	cmp    %eax,%ebp
  802061:	73 5d                	jae    8020c0 <__udivdi3+0x110>
  802063:	39 d6                	cmp    %edx,%esi
  802065:	75 59                	jne    8020c0 <__udivdi3+0x110>
  802067:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80206a:	31 ff                	xor    %edi,%edi
  80206c:	89 fa                	mov    %edi,%edx
  80206e:	83 c4 1c             	add    $0x1c,%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    
  802076:	8d 76 00             	lea    0x0(%esi),%esi
  802079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802080:	31 ff                	xor    %edi,%edi
  802082:	31 c0                	xor    %eax,%eax
  802084:	89 fa                	mov    %edi,%edx
  802086:	83 c4 1c             	add    $0x1c,%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
  80208e:	66 90                	xchg   %ax,%ax
  802090:	31 ff                	xor    %edi,%edi
  802092:	89 e8                	mov    %ebp,%eax
  802094:	89 f2                	mov    %esi,%edx
  802096:	f7 f3                	div    %ebx
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	72 06                	jb     8020b2 <__udivdi3+0x102>
  8020ac:	31 c0                	xor    %eax,%eax
  8020ae:	39 eb                	cmp    %ebp,%ebx
  8020b0:	77 d2                	ja     802084 <__udivdi3+0xd4>
  8020b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b7:	eb cb                	jmp    802084 <__udivdi3+0xd4>
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	31 ff                	xor    %edi,%edi
  8020c4:	eb be                	jmp    802084 <__udivdi3+0xd4>
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8020db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8020df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 ed                	test   %ebp,%ebp
  8020e9:	89 f0                	mov    %esi,%eax
  8020eb:	89 da                	mov    %ebx,%edx
  8020ed:	75 19                	jne    802108 <__umoddi3+0x38>
  8020ef:	39 df                	cmp    %ebx,%edi
  8020f1:	0f 86 b1 00 00 00    	jbe    8021a8 <__umoddi3+0xd8>
  8020f7:	f7 f7                	div    %edi
  8020f9:	89 d0                	mov    %edx,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	83 c4 1c             	add    $0x1c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	39 dd                	cmp    %ebx,%ebp
  80210a:	77 f1                	ja     8020fd <__umoddi3+0x2d>
  80210c:	0f bd cd             	bsr    %ebp,%ecx
  80210f:	83 f1 1f             	xor    $0x1f,%ecx
  802112:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802116:	0f 84 b4 00 00 00    	je     8021d0 <__umoddi3+0x100>
  80211c:	b8 20 00 00 00       	mov    $0x20,%eax
  802121:	89 c2                	mov    %eax,%edx
  802123:	8b 44 24 04          	mov    0x4(%esp),%eax
  802127:	29 c2                	sub    %eax,%edx
  802129:	89 c1                	mov    %eax,%ecx
  80212b:	89 f8                	mov    %edi,%eax
  80212d:	d3 e5                	shl    %cl,%ebp
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802135:	d3 e8                	shr    %cl,%eax
  802137:	09 c5                	or     %eax,%ebp
  802139:	8b 44 24 04          	mov    0x4(%esp),%eax
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	d3 e7                	shl    %cl,%edi
  802141:	89 d1                	mov    %edx,%ecx
  802143:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802147:	89 df                	mov    %ebx,%edi
  802149:	d3 ef                	shr    %cl,%edi
  80214b:	89 c1                	mov    %eax,%ecx
  80214d:	89 f0                	mov    %esi,%eax
  80214f:	d3 e3                	shl    %cl,%ebx
  802151:	89 d1                	mov    %edx,%ecx
  802153:	89 fa                	mov    %edi,%edx
  802155:	d3 e8                	shr    %cl,%eax
  802157:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80215c:	09 d8                	or     %ebx,%eax
  80215e:	f7 f5                	div    %ebp
  802160:	d3 e6                	shl    %cl,%esi
  802162:	89 d1                	mov    %edx,%ecx
  802164:	f7 64 24 08          	mull   0x8(%esp)
  802168:	39 d1                	cmp    %edx,%ecx
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d7                	mov    %edx,%edi
  80216e:	72 06                	jb     802176 <__umoddi3+0xa6>
  802170:	75 0e                	jne    802180 <__umoddi3+0xb0>
  802172:	39 c6                	cmp    %eax,%esi
  802174:	73 0a                	jae    802180 <__umoddi3+0xb0>
  802176:	2b 44 24 08          	sub    0x8(%esp),%eax
  80217a:	19 ea                	sbb    %ebp,%edx
  80217c:	89 d7                	mov    %edx,%edi
  80217e:	89 c3                	mov    %eax,%ebx
  802180:	89 ca                	mov    %ecx,%edx
  802182:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802187:	29 de                	sub    %ebx,%esi
  802189:	19 fa                	sbb    %edi,%edx
  80218b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	d3 e0                	shl    %cl,%eax
  802193:	89 d9                	mov    %ebx,%ecx
  802195:	d3 ee                	shr    %cl,%esi
  802197:	d3 ea                	shr    %cl,%edx
  802199:	09 f0                	or     %esi,%eax
  80219b:	83 c4 1c             	add    $0x1c,%esp
  80219e:	5b                   	pop    %ebx
  80219f:	5e                   	pop    %esi
  8021a0:	5f                   	pop    %edi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	85 ff                	test   %edi,%edi
  8021aa:	89 f9                	mov    %edi,%ecx
  8021ac:	75 0b                	jne    8021b9 <__umoddi3+0xe9>
  8021ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f7                	div    %edi
  8021b7:	89 c1                	mov    %eax,%ecx
  8021b9:	89 d8                	mov    %ebx,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f1                	div    %ecx
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	f7 f1                	div    %ecx
  8021c3:	e9 31 ff ff ff       	jmp    8020f9 <__umoddi3+0x29>
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 dd                	cmp    %ebx,%ebp
  8021d2:	72 08                	jb     8021dc <__umoddi3+0x10c>
  8021d4:	39 f7                	cmp    %esi,%edi
  8021d6:	0f 87 21 ff ff ff    	ja     8020fd <__umoddi3+0x2d>
  8021dc:	89 da                	mov    %ebx,%edx
  8021de:	89 f0                	mov    %esi,%eax
  8021e0:	29 f8                	sub    %edi,%eax
  8021e2:	19 ea                	sbb    %ebp,%edx
  8021e4:	e9 14 ff ff ff       	jmp    8020fd <__umoddi3+0x2d>
