
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 30 0b 00 00       	call   800b70 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 41 0d 00 00       	call   800d9f <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 40 1e 80 00       	push   $0x801e40
  80006a:	e8 27 01 00 00       	call   800196 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 51 1e 80 00       	push   $0x801e51
  800083:	e8 0e 01 00 00       	call   800196 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 64 0d 00 00       	call   800e00 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 bf 0a 00 00       	call   800b70 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 6a 0f 00 00       	call   80105c <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 33 0a 00 00       	call   800b2f <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	74 09                	je     800129 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800127:	c9                   	leave  
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 b8 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  80013a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb db                	jmp    800120 <putch+0x1f>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 01 01 80 00       	push   $0x800101
  800174:	e8 1a 01 00 00       	call   800293 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 64 09 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d1:	39 d3                	cmp    %edx,%ebx
  8001d3:	72 05                	jb     8001da <printnum+0x30>
  8001d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d8:	77 7a                	ja     800254 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 f2 19 00 00       	call   801bf0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9e ff ff ff       	call   8001aa <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 13                	jmp    800224 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	pushl  0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f ed                	jg     800211 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 d4 1a 00 00       	call   801d10 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 72 1e 80 00 	movsbl 0x801e72(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800257:	eb c4                	jmp    80021d <printnum+0x73>

00800259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800263:	8b 10                	mov    (%eax),%edx
  800265:	3b 50 04             	cmp    0x4(%eax),%edx
  800268:	73 0a                	jae    800274 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026d:	89 08                	mov    %ecx,(%eax)
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	88 02                	mov    %al,(%edx)
}
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <printfmt>:
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 10             	pushl  0x10(%ebp)
  800283:	ff 75 0c             	pushl  0xc(%ebp)
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 05 00 00 00       	call   800293 <vprintfmt>
}
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <vprintfmt>:
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
  80029c:	8b 75 08             	mov    0x8(%ebp),%esi
  80029f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a5:	e9 c1 03 00 00       	jmp    80066b <vprintfmt+0x3d8>
		padc = ' ';
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8d 47 01             	lea    0x1(%edi),%eax
  8002cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ce:	0f b6 17             	movzbl (%edi),%edx
  8002d1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d4:	3c 55                	cmp    $0x55,%al
  8002d6:	0f 87 12 04 00 00    	ja     8006ee <vprintfmt+0x45b>
  8002dc:	0f b6 c0             	movzbl %al,%eax
  8002df:	ff 24 85 c0 1f 80 00 	jmp    *0x801fc0(,%eax,4)
  8002e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002ed:	eb d9                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002f2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f6:	eb d0                	jmp    8002c8 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	0f b6 d2             	movzbl %dl,%edx
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800310:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800313:	83 f9 09             	cmp    $0x9,%ecx
  800316:	77 55                	ja     80036d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8b 00                	mov    (%eax),%eax
  800322:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 40 04             	lea    0x4(%eax),%eax
  80032b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800331:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800335:	79 91                	jns    8002c8 <vprintfmt+0x35>
				width = precision, precision = -1;
  800337:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	eb 82                	jmp    8002c8 <vprintfmt+0x35>
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	85 c0                	test   %eax,%eax
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	0f 49 d0             	cmovns %eax,%edx
  800353:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	e9 6a ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800361:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800368:	e9 5b ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
  80036d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800373:	eb bc                	jmp    800331 <vprintfmt+0x9e>
			lflag++;
  800375:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80037b:	e9 48 ff ff ff       	jmp    8002c8 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 78 04             	lea    0x4(%eax),%edi
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	ff 30                	pushl  (%eax)
  80038c:	ff d6                	call   *%esi
			break;
  80038e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800391:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800394:	e9 cf 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 78 04             	lea    0x4(%eax),%edi
  80039f:	8b 00                	mov    (%eax),%eax
  8003a1:	99                   	cltd   
  8003a2:	31 d0                	xor    %edx,%eax
  8003a4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a6:	83 f8 0f             	cmp    $0xf,%eax
  8003a9:	7f 23                	jg     8003ce <vprintfmt+0x13b>
  8003ab:	8b 14 85 20 21 80 00 	mov    0x802120(,%eax,4),%edx
  8003b2:	85 d2                	test   %edx,%edx
  8003b4:	74 18                	je     8003ce <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003b6:	52                   	push   %edx
  8003b7:	68 6d 22 80 00       	push   $0x80226d
  8003bc:	53                   	push   %ebx
  8003bd:	56                   	push   %esi
  8003be:	e8 b3 fe ff ff       	call   800276 <printfmt>
  8003c3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c9:	e9 9a 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ce:	50                   	push   %eax
  8003cf:	68 8a 1e 80 00       	push   $0x801e8a
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 9b fe ff ff       	call   800276 <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003de:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e1:	e9 82 02 00 00       	jmp    800668 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	83 c0 04             	add    $0x4,%eax
  8003ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f4:	85 ff                	test   %edi,%edi
  8003f6:	b8 83 1e 80 00       	mov    $0x801e83,%eax
  8003fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	0f 8e bd 00 00 00    	jle    8004c5 <vprintfmt+0x232>
  800408:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040c:	75 0e                	jne    80041c <vprintfmt+0x189>
  80040e:	89 75 08             	mov    %esi,0x8(%ebp)
  800411:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800414:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800417:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80041a:	eb 6d                	jmp    800489 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	ff 75 d0             	pushl  -0x30(%ebp)
  800422:	57                   	push   %edi
  800423:	e8 6e 03 00 00       	call   800796 <strnlen>
  800428:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042b:	29 c1                	sub    %eax,%ecx
  80042d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800430:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800433:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043d:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	eb 0f                	jmp    800450 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	83 ef 01             	sub    $0x1,%edi
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 ff                	test   %edi,%edi
  800452:	7f ed                	jg     800441 <vprintfmt+0x1ae>
  800454:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800457:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80045a:	85 c9                	test   %ecx,%ecx
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	0f 49 c1             	cmovns %ecx,%eax
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 75 08             	mov    %esi,0x8(%ebp)
  800469:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046f:	89 cb                	mov    %ecx,%ebx
  800471:	eb 16                	jmp    800489 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800473:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800477:	75 31                	jne    8004aa <vprintfmt+0x217>
					putch(ch, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	ff 75 0c             	pushl  0xc(%ebp)
  80047f:	50                   	push   %eax
  800480:	ff 55 08             	call   *0x8(%ebp)
  800483:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800486:	83 eb 01             	sub    $0x1,%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800490:	0f be c2             	movsbl %dl,%eax
  800493:	85 c0                	test   %eax,%eax
  800495:	74 59                	je     8004f0 <vprintfmt+0x25d>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 d8                	js     800473 <vprintfmt+0x1e0>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 d3                	jns    800473 <vprintfmt+0x1e0>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 37                	jmp    8004e1 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	0f be d2             	movsbl %dl,%edx
  8004ad:	83 ea 20             	sub    $0x20,%edx
  8004b0:	83 fa 5e             	cmp    $0x5e,%edx
  8004b3:	76 c4                	jbe    800479 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	6a 3f                	push   $0x3f
  8004bd:	ff 55 08             	call   *0x8(%ebp)
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	eb c1                	jmp    800486 <vprintfmt+0x1f3>
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d1:	eb b6                	jmp    800489 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	6a 20                	push   $0x20
  8004d9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004db:	83 ef 01             	sub    $0x1,%edi
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f ee                	jg     8004d3 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004eb:	e9 78 01 00 00       	jmp    800668 <vprintfmt+0x3d5>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	eb e7                	jmp    8004e1 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004fa:	83 f9 01             	cmp    $0x1,%ecx
  8004fd:	7e 3f                	jle    80053e <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8b 50 04             	mov    0x4(%eax),%edx
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8d 40 08             	lea    0x8(%eax),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800516:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051a:	79 5c                	jns    800578 <vprintfmt+0x2e5>
				putch('-', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 2d                	push   $0x2d
  800522:	ff d6                	call   *%esi
				num = -(long long) num;
  800524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052a:	f7 da                	neg    %edx
  80052c:	83 d1 00             	adc    $0x0,%ecx
  80052f:	f7 d9                	neg    %ecx
  800531:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800534:	b8 0a 00 00 00       	mov    $0xa,%eax
  800539:	e9 10 01 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	75 1b                	jne    80055d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 c1                	mov    %eax,%ecx
  80054c:	c1 f9 1f             	sar    $0x1f,%ecx
  80054f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	eb b9                	jmp    800516 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 9e                	jmp    800516 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800578:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 c6 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  800588:	83 f9 01             	cmp    $0x1,%ecx
  80058b:	7e 18                	jle    8005a5 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8b 48 04             	mov    0x4(%eax),%ecx
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 a9 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	75 1a                	jne    8005c3 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 8b 00 00 00       	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	eb 74                	jmp    80064e <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005da:	83 f9 01             	cmp    $0x1,%ecx
  8005dd:	7e 15                	jle    8005f4 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f2:	eb 5a                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8005f4:	85 c9                	test   %ecx,%ecx
  8005f6:	75 17                	jne    80060f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 10                	mov    (%eax),%edx
  8005fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
  80060d:	eb 3f                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80061f:	b8 08 00 00 00       	mov    $0x8,%eax
  800624:	eb 28                	jmp    80064e <vprintfmt+0x3bb>
			putch('0', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 30                	push   $0x30
  80062c:	ff d6                	call   *%esi
			putch('x', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 78                	push   $0x78
  800634:	ff d6                	call   *%esi
			num = (unsigned long long)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 10                	mov    (%eax),%edx
  80063b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800640:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800649:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064e:	83 ec 0c             	sub    $0xc,%esp
  800651:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800655:	57                   	push   %edi
  800656:	ff 75 e0             	pushl  -0x20(%ebp)
  800659:	50                   	push   %eax
  80065a:	51                   	push   %ecx
  80065b:	52                   	push   %edx
  80065c:	89 da                	mov    %ebx,%edx
  80065e:	89 f0                	mov    %esi,%eax
  800660:	e8 45 fb ff ff       	call   8001aa <printnum>
			break;
  800665:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066b:	83 c7 01             	add    $0x1,%edi
  80066e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800672:	83 f8 25             	cmp    $0x25,%eax
  800675:	0f 84 2f fc ff ff    	je     8002aa <vprintfmt+0x17>
			if (ch == '\0')
  80067b:	85 c0                	test   %eax,%eax
  80067d:	0f 84 8b 00 00 00    	je     80070e <vprintfmt+0x47b>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	50                   	push   %eax
  800688:	ff d6                	call   *%esi
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb dc                	jmp    80066b <vprintfmt+0x3d8>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 15                	jle    8006a9 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a7:	eb a5                	jmp    80064e <vprintfmt+0x3bb>
	else if (lflag)
  8006a9:	85 c9                	test   %ecx,%ecx
  8006ab:	75 17                	jne    8006c4 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c2:	eb 8a                	jmp    80064e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 10                	mov    (%eax),%edx
  8006c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d9:	e9 70 ff ff ff       	jmp    80064e <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	6a 25                	push   $0x25
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	e9 7a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	6a 25                	push   $0x25
  8006f4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	89 f8                	mov    %edi,%eax
  8006fb:	eb 03                	jmp    800700 <vprintfmt+0x46d>
  8006fd:	83 e8 01             	sub    $0x1,%eax
  800700:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800704:	75 f7                	jne    8006fd <vprintfmt+0x46a>
  800706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800709:	e9 5a ff ff ff       	jmp    800668 <vprintfmt+0x3d5>
}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 59 02 80 00       	push   $0x800259
  80074a:	e8 44 fb ff ff       	call   800293 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb f7                	jmp    80075b <vsnprintf+0x45>

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 d0                	cmp    %edx,%eax
  8007ab:	74 06                	je     8007b3 <strnlen+0x1d>
  8007ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c1 01             	add    $0x1,%ecx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9c ff ff ff       	call   80077e <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800832:	89 f0                	mov    %esi,%eax
  800834:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	75 0b                	jne    800847 <strlcpy+0x23>
  80083c:	eb 17                	jmp    800855 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800847:	39 d8                	cmp    %ebx,%eax
  800849:	74 07                	je     800852 <strlcpy+0x2e>
  80084b:	0f b6 0a             	movzbl (%edx),%ecx
  80084e:	84 c9                	test   %cl,%cl
  800850:	75 ec                	jne    80083e <strlcpy+0x1a>
		*dst = '\0';
  800852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 06                	jmp    80086c <strcmp+0x11>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 04                	je     800877 <strcmp+0x1c>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 ef                	je     800866 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800890:	eb 06                	jmp    800898 <strncmp+0x17>
		n--, p++, q++;
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 16                	je     8008b2 <strncmp+0x31>
  80089c:	0f b6 08             	movzbl (%eax),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 04                	je     8008a7 <strncmp+0x26>
  8008a3:	3a 0a                	cmp    (%edx),%cl
  8008a5:	74 eb                	je     800892 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5b                   	pop    %ebx
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    
		return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b7:	eb f6                	jmp    8008af <strncmp+0x2e>

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	0f b6 10             	movzbl (%eax),%edx
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	74 09                	je     8008d3 <strchr+0x1a>
		if (*s == c)
  8008ca:	38 ca                	cmp    %cl,%dl
  8008cc:	74 0a                	je     8008d8 <strchr+0x1f>
	for (; *s; s++)
  8008ce:	83 c0 01             	add    $0x1,%eax
  8008d1:	eb f0                	jmp    8008c3 <strchr+0xa>
			return (char *) s;
	return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 03                	jmp    8008e9 <strfind+0xf>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 04                	je     8008f4 <strfind+0x1a>
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 13                	je     800919 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 05                	jne    800913 <memset+0x1d>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	74 0d                	je     800920 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	fc                   	cld    
  800917:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800919:	89 f8                	mov    %edi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e0 18             	shl    $0x18,%eax
  80092e:	89 d6                	mov    %edx,%esi
  800930:	c1 e6 10             	shl    $0x10,%esi
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
  800937:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800939:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb d6                	jmp    800919 <memset+0x23>

00800943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800951:	39 c6                	cmp    %eax,%esi
  800953:	73 35                	jae    80098a <memmove+0x47>
  800955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800958:	39 c2                	cmp    %eax,%edx
  80095a:	76 2e                	jbe    80098a <memmove+0x47>
		s += n;
		d += n;
  80095c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	89 d6                	mov    %edx,%esi
  800961:	09 fe                	or     %edi,%esi
  800963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800969:	74 0c                	je     800977 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096b:	83 ef 01             	sub    $0x1,%edi
  80096e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800971:	fd                   	std    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800974:	fc                   	cld    
  800975:	eb 21                	jmp    800998 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 ef                	jne    80096b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80097c:	83 ef 04             	sub    $0x4,%edi
  80097f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800982:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800985:	fd                   	std    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb ea                	jmp    800974 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	74 09                	je     80099c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800993:	89 c7                	mov    %eax,%edi
  800995:	fc                   	cld    
  800996:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800998:	5e                   	pop    %esi
  800999:	5f                   	pop    %edi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 f2                	jne    800993 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb ed                	jmp    800998 <memmove+0x55>

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 87 ff ff ff       	call   800943 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	39 f0                	cmp    %esi,%eax
  8009d0:	74 1c                	je     8009ee <memcmp+0x30>
		if (*s1 != *s2)
  8009d2:	0f b6 08             	movzbl (%eax),%ecx
  8009d5:	0f b6 1a             	movzbl (%edx),%ebx
  8009d8:	38 d9                	cmp    %bl,%cl
  8009da:	75 08                	jne    8009e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	eb ea                	jmp    8009ce <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 05                	jmp    8009f3 <memcmp+0x35>
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a05:	39 d0                	cmp    %edx,%eax
  800a07:	73 09                	jae    800a12 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	38 08                	cmp    %cl,(%eax)
  800a0b:	74 05                	je     800a12 <memfind+0x1b>
	for (; s < ends; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	eb f3                	jmp    800a05 <memfind+0xe>
			break;
	return (void *) s;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2e                	je     800a62 <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2f                	je     800a6c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 05                	jne    800a4a <strtol+0x36>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 2c                	je     800a76 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 0a                	jne    800a58 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a53:	80 39 30             	cmpb   $0x30,(%ecx)
  800a56:	74 28                	je     800a80 <strtol+0x6c>
		base = 10;
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a60:	eb 50                	jmp    800ab2 <strtol+0x9e>
		s++;
  800a62:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a65:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6a:	eb d1                	jmp    800a3d <strtol+0x29>
		s++, neg = 1;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bf 01 00 00 00       	mov    $0x1,%edi
  800a74:	eb c7                	jmp    800a3d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7a:	74 0e                	je     800a8a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a7c:	85 db                	test   %ebx,%ebx
  800a7e:	75 d8                	jne    800a58 <strtol+0x44>
		s++, base = 8;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a88:	eb ce                	jmp    800a58 <strtol+0x44>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb c4                	jmp    800a58 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 29                	ja     800ac7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa7:	7d 30                	jge    800ad9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 d5                	ja     800a94 <strtol+0x80>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb dd                	jmp    800aa4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ac7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 37             	sub    $0x37,%edx
  800ad7:	eb cb                	jmp    800aa4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800add:	74 05                	je     800ae4 <strtol+0xd0>
		*endptr = (char *) s;
  800adf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	f7 da                	neg    %edx
  800ae8:	85 ff                	test   %edi,%edi
  800aea:	0f 45 c2             	cmovne %edx,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7f 08                	jg     800b59 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 7f 21 80 00       	push   $0x80217f
  800b64:	6a 23                	push   $0x23
  800b66:	68 9c 21 80 00       	push   $0x80219c
  800b6b:	e8 ff 0f 00 00       	call   801b6f <_panic>

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 7f 21 80 00       	push   $0x80217f
  800be5:	6a 23                	push   $0x23
  800be7:	68 9c 21 80 00       	push   $0x80219c
  800bec:	e8 7e 0f 00 00       	call   801b6f <_panic>

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 7f 21 80 00       	push   $0x80217f
  800c27:	6a 23                	push   $0x23
  800c29:	68 9c 21 80 00       	push   $0x80219c
  800c2e:	e8 3c 0f 00 00       	call   801b6f <_panic>

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 7f 21 80 00       	push   $0x80217f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 9c 21 80 00       	push   $0x80219c
  800c70:	e8 fa 0e 00 00       	call   801b6f <_panic>

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 7f 21 80 00       	push   $0x80217f
  800cab:	6a 23                	push   $0x23
  800cad:	68 9c 21 80 00       	push   $0x80219c
  800cb2:	e8 b8 0e 00 00       	call   801b6f <_panic>

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 7f 21 80 00       	push   $0x80217f
  800ced:	6a 23                	push   $0x23
  800cef:	68 9c 21 80 00       	push   $0x80219c
  800cf4:	e8 76 0e 00 00       	call   801b6f <_panic>

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 7f 21 80 00       	push   $0x80217f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 9c 21 80 00       	push   $0x80219c
  800d36:	e8 34 0e 00 00       	call   801b6f <_panic>

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 7f 21 80 00       	push   $0x80217f
  800d93:	6a 23                	push   $0x23
  800d95:	68 9c 21 80 00       	push   $0x80219c
  800d9a:	e8 d0 0d 00 00       	call   801b6f <_panic>

00800d9f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  800dad:	85 c0                	test   %eax,%eax
  800daf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800db4:	0f 44 c2             	cmove  %edx,%eax
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	50                   	push   %eax
  800dbb:	e8 9e ff ff ff       	call   800d5e <sys_ipc_recv>
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	78 2b                	js     800df2 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  800dc7:	85 f6                	test   %esi,%esi
  800dc9:	74 0a                	je     800dd5 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  800dcb:	a1 04 40 80 00       	mov    0x804004,%eax
  800dd0:	8b 40 74             	mov    0x74(%eax),%eax
  800dd3:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  800dd5:	85 db                	test   %ebx,%ebx
  800dd7:	74 0a                	je     800de3 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  800dd9:	a1 04 40 80 00       	mov    0x804004,%eax
  800dde:	8b 40 78             	mov    0x78(%eax),%eax
  800de1:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  800de3:	a1 04 40 80 00       	mov    0x804004,%eax
  800de8:	8b 40 70             	mov    0x70(%eax),%eax
}
  800deb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
        *from_env_store = 0;
  800df2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  800df8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  800dfe:	eb eb                	jmp    800deb <ipc_recv+0x4c>

00800e00 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  800e12:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  800e14:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e19:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  800e1c:	ff 75 14             	pushl  0x14(%ebp)
  800e1f:	53                   	push   %ebx
  800e20:	56                   	push   %esi
  800e21:	57                   	push   %edi
  800e22:	e8 14 ff ff ff       	call   800d3b <sys_ipc_try_send>
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	74 17                	je     800e45 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  800e2e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e31:	74 e9                	je     800e1c <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  800e33:	50                   	push   %eax
  800e34:	68 aa 21 80 00       	push   $0x8021aa
  800e39:	6a 3e                	push   $0x3e
  800e3b:	68 bc 21 80 00       	push   $0x8021bc
  800e40:	e8 2a 0d 00 00       	call   801b6f <_panic>
        }
    }
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e53:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e58:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e5b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e61:	8b 52 50             	mov    0x50(%edx),%edx
  800e64:	39 ca                	cmp    %ecx,%edx
  800e66:	74 11                	je     800e79 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  800e68:	83 c0 01             	add    $0x1,%eax
  800e6b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e70:	75 e6                	jne    800e58 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	eb 0b                	jmp    800e84 <ipc_find_env+0x37>
			return envs[i].env_id;
  800e79:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e7c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e81:	8b 40 48             	mov    0x48(%eax),%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e91:	c1 e8 0c             	shr    $0xc,%eax
}
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ea1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	c1 ea 16             	shr    $0x16,%edx
  800ebd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec4:	f6 c2 01             	test   $0x1,%dl
  800ec7:	74 2a                	je     800ef3 <fd_alloc+0x46>
  800ec9:	89 c2                	mov    %eax,%edx
  800ecb:	c1 ea 0c             	shr    $0xc,%edx
  800ece:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed5:	f6 c2 01             	test   $0x1,%dl
  800ed8:	74 19                	je     800ef3 <fd_alloc+0x46>
  800eda:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800edf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee4:	75 d2                	jne    800eb8 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800ef1:	eb 07                	jmp    800efa <fd_alloc+0x4d>
			*fd_store = fd;
  800ef3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f02:	83 f8 1f             	cmp    $0x1f,%eax
  800f05:	77 36                	ja     800f3d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f07:	c1 e0 0c             	shl    $0xc,%eax
  800f0a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	c1 ea 16             	shr    $0x16,%edx
  800f14:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f1b:	f6 c2 01             	test   $0x1,%dl
  800f1e:	74 24                	je     800f44 <fd_lookup+0x48>
  800f20:	89 c2                	mov    %eax,%edx
  800f22:	c1 ea 0c             	shr    $0xc,%edx
  800f25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f2c:	f6 c2 01             	test   $0x1,%dl
  800f2f:	74 1a                	je     800f4b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f34:	89 02                	mov    %eax,(%edx)
	return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
		return -E_INVAL;
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f42:	eb f7                	jmp    800f3b <fd_lookup+0x3f>
		return -E_INVAL;
  800f44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f49:	eb f0                	jmp    800f3b <fd_lookup+0x3f>
  800f4b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f50:	eb e9                	jmp    800f3b <fd_lookup+0x3f>

00800f52 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	ba 44 22 80 00       	mov    $0x802244,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f60:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f65:	39 08                	cmp    %ecx,(%eax)
  800f67:	74 33                	je     800f9c <dev_lookup+0x4a>
  800f69:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f6c:	8b 02                	mov    (%edx),%eax
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	75 f3                	jne    800f65 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f72:	a1 04 40 80 00       	mov    0x804004,%eax
  800f77:	8b 40 48             	mov    0x48(%eax),%eax
  800f7a:	83 ec 04             	sub    $0x4,%esp
  800f7d:	51                   	push   %ecx
  800f7e:	50                   	push   %eax
  800f7f:	68 c8 21 80 00       	push   $0x8021c8
  800f84:	e8 0d f2 ff ff       	call   800196 <cprintf>
	*dev = 0;
  800f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    
			*dev = devtab[i];
  800f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	eb f2                	jmp    800f9a <dev_lookup+0x48>

00800fa8 <fd_close>:
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	57                   	push   %edi
  800fac:	56                   	push   %esi
  800fad:	53                   	push   %ebx
  800fae:	83 ec 1c             	sub    $0x1c,%esp
  800fb1:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fba:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fbb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc4:	50                   	push   %eax
  800fc5:	e8 32 ff ff ff       	call   800efc <fd_lookup>
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	85 c0                	test   %eax,%eax
  800fd1:	78 05                	js     800fd8 <fd_close+0x30>
	    || fd != fd2)
  800fd3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fd6:	74 16                	je     800fee <fd_close+0x46>
		return (must_exist ? r : 0);
  800fd8:	89 f8                	mov    %edi,%eax
  800fda:	84 c0                	test   %al,%al
  800fdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe1:	0f 44 d8             	cmove  %eax,%ebx
}
  800fe4:	89 d8                	mov    %ebx,%eax
  800fe6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fee:	83 ec 08             	sub    $0x8,%esp
  800ff1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	ff 36                	pushl  (%esi)
  800ff7:	e8 56 ff ff ff       	call   800f52 <dev_lookup>
  800ffc:	89 c3                	mov    %eax,%ebx
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 15                	js     80101a <fd_close+0x72>
		if (dev->dev_close)
  801005:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801008:	8b 40 10             	mov    0x10(%eax),%eax
  80100b:	85 c0                	test   %eax,%eax
  80100d:	74 1b                	je     80102a <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	56                   	push   %esi
  801013:	ff d0                	call   *%eax
  801015:	89 c3                	mov    %eax,%ebx
  801017:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80101a:	83 ec 08             	sub    $0x8,%esp
  80101d:	56                   	push   %esi
  80101e:	6a 00                	push   $0x0
  801020:	e8 0e fc ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	eb ba                	jmp    800fe4 <fd_close+0x3c>
			r = 0;
  80102a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102f:	eb e9                	jmp    80101a <fd_close+0x72>

00801031 <close>:

int
close(int fdnum)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801037:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103a:	50                   	push   %eax
  80103b:	ff 75 08             	pushl  0x8(%ebp)
  80103e:	e8 b9 fe ff ff       	call   800efc <fd_lookup>
  801043:	83 c4 08             	add    $0x8,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 10                	js     80105a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	6a 01                	push   $0x1
  80104f:	ff 75 f4             	pushl  -0xc(%ebp)
  801052:	e8 51 ff ff ff       	call   800fa8 <fd_close>
  801057:	83 c4 10             	add    $0x10,%esp
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <close_all>:

void
close_all(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801063:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	53                   	push   %ebx
  80106c:	e8 c0 ff ff ff       	call   801031 <close>
	for (i = 0; i < MAXFD; i++)
  801071:	83 c3 01             	add    $0x1,%ebx
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	83 fb 20             	cmp    $0x20,%ebx
  80107a:	75 ec                	jne    801068 <close_all+0xc>
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80108a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	ff 75 08             	pushl  0x8(%ebp)
  801091:	e8 66 fe ff ff       	call   800efc <fd_lookup>
  801096:	89 c3                	mov    %eax,%ebx
  801098:	83 c4 08             	add    $0x8,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	0f 88 81 00 00 00    	js     801124 <dup+0xa3>
		return r;
	close(newfdnum);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	ff 75 0c             	pushl  0xc(%ebp)
  8010a9:	e8 83 ff ff ff       	call   801031 <close>

	newfd = INDEX2FD(newfdnum);
  8010ae:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b1:	c1 e6 0c             	shl    $0xc,%esi
  8010b4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010ba:	83 c4 04             	add    $0x4,%esp
  8010bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c0:	e8 d1 fd ff ff       	call   800e96 <fd2data>
  8010c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c7:	89 34 24             	mov    %esi,(%esp)
  8010ca:	e8 c7 fd ff ff       	call   800e96 <fd2data>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	c1 e8 16             	shr    $0x16,%eax
  8010d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e0:	a8 01                	test   $0x1,%al
  8010e2:	74 11                	je     8010f5 <dup+0x74>
  8010e4:	89 d8                	mov    %ebx,%eax
  8010e6:	c1 e8 0c             	shr    $0xc,%eax
  8010e9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010f0:	f6 c2 01             	test   $0x1,%dl
  8010f3:	75 39                	jne    80112e <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f8:	89 d0                	mov    %edx,%eax
  8010fa:	c1 e8 0c             	shr    $0xc,%eax
  8010fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801104:	83 ec 0c             	sub    $0xc,%esp
  801107:	25 07 0e 00 00       	and    $0xe07,%eax
  80110c:	50                   	push   %eax
  80110d:	56                   	push   %esi
  80110e:	6a 00                	push   $0x0
  801110:	52                   	push   %edx
  801111:	6a 00                	push   $0x0
  801113:	e8 d9 fa ff ff       	call   800bf1 <sys_page_map>
  801118:	89 c3                	mov    %eax,%ebx
  80111a:	83 c4 20             	add    $0x20,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 31                	js     801152 <dup+0xd1>
		goto err;

	return newfdnum;
  801121:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801124:	89 d8                	mov    %ebx,%eax
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	25 07 0e 00 00       	and    $0xe07,%eax
  80113d:	50                   	push   %eax
  80113e:	57                   	push   %edi
  80113f:	6a 00                	push   $0x0
  801141:	53                   	push   %ebx
  801142:	6a 00                	push   $0x0
  801144:	e8 a8 fa ff ff       	call   800bf1 <sys_page_map>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	83 c4 20             	add    $0x20,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 a3                	jns    8010f5 <dup+0x74>
	sys_page_unmap(0, newfd);
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	56                   	push   %esi
  801156:	6a 00                	push   $0x0
  801158:	e8 d6 fa ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	57                   	push   %edi
  801161:	6a 00                	push   $0x0
  801163:	e8 cb fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	eb b7                	jmp    801124 <dup+0xa3>

0080116d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	53                   	push   %ebx
  801171:	83 ec 14             	sub    $0x14,%esp
  801174:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117a:	50                   	push   %eax
  80117b:	53                   	push   %ebx
  80117c:	e8 7b fd ff ff       	call   800efc <fd_lookup>
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 3f                	js     8011c7 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801192:	ff 30                	pushl  (%eax)
  801194:	e8 b9 fd ff ff       	call   800f52 <dev_lookup>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 27                	js     8011c7 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011a3:	8b 42 08             	mov    0x8(%edx),%eax
  8011a6:	83 e0 03             	and    $0x3,%eax
  8011a9:	83 f8 01             	cmp    $0x1,%eax
  8011ac:	74 1e                	je     8011cc <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b1:	8b 40 08             	mov    0x8(%eax),%eax
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	74 35                	je     8011ed <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b8:	83 ec 04             	sub    $0x4,%esp
  8011bb:	ff 75 10             	pushl  0x10(%ebp)
  8011be:	ff 75 0c             	pushl  0xc(%ebp)
  8011c1:	52                   	push   %edx
  8011c2:	ff d0                	call   *%eax
  8011c4:	83 c4 10             	add    $0x10,%esp
}
  8011c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	50                   	push   %eax
  8011d9:	68 09 22 80 00       	push   $0x802209
  8011de:	e8 b3 ef ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011eb:	eb da                	jmp    8011c7 <read+0x5a>
		return -E_NOT_SUPP;
  8011ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011f2:	eb d3                	jmp    8011c7 <read+0x5a>

008011f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
  8011f7:	57                   	push   %edi
  8011f8:	56                   	push   %esi
  8011f9:	53                   	push   %ebx
  8011fa:	83 ec 0c             	sub    $0xc,%esp
  8011fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801200:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801203:	bb 00 00 00 00       	mov    $0x0,%ebx
  801208:	39 f3                	cmp    %esi,%ebx
  80120a:	73 25                	jae    801231 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	89 f0                	mov    %esi,%eax
  801211:	29 d8                	sub    %ebx,%eax
  801213:	50                   	push   %eax
  801214:	89 d8                	mov    %ebx,%eax
  801216:	03 45 0c             	add    0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	57                   	push   %edi
  80121b:	e8 4d ff ff ff       	call   80116d <read>
		if (m < 0)
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 08                	js     80122f <readn+0x3b>
			return m;
		if (m == 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	74 06                	je     801231 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80122b:	01 c3                	add    %eax,%ebx
  80122d:	eb d9                	jmp    801208 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801231:	89 d8                	mov    %ebx,%eax
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 14             	sub    $0x14,%esp
  801242:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	53                   	push   %ebx
  80124a:	e8 ad fc ff ff       	call   800efc <fd_lookup>
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	85 c0                	test   %eax,%eax
  801254:	78 3a                	js     801290 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801260:	ff 30                	pushl  (%eax)
  801262:	e8 eb fc ff ff       	call   800f52 <dev_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 22                	js     801290 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801271:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801275:	74 1e                	je     801295 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 52 0c             	mov    0xc(%edx),%edx
  80127d:	85 d2                	test   %edx,%edx
  80127f:	74 35                	je     8012b6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801281:	83 ec 04             	sub    $0x4,%esp
  801284:	ff 75 10             	pushl  0x10(%ebp)
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	50                   	push   %eax
  80128b:	ff d2                	call   *%edx
  80128d:	83 c4 10             	add    $0x10,%esp
}
  801290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801293:	c9                   	leave  
  801294:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801295:	a1 04 40 80 00       	mov    0x804004,%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	83 ec 04             	sub    $0x4,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	50                   	push   %eax
  8012a2:	68 25 22 80 00       	push   $0x802225
  8012a7:	e8 ea ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b4:	eb da                	jmp    801290 <write+0x55>
		return -E_NOT_SUPP;
  8012b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012bb:	eb d3                	jmp    801290 <write+0x55>

008012bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 2d fc ff ff       	call   800efc <fd_lookup>
  8012cf:	83 c4 08             	add    $0x8,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 0e                	js     8012e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 14             	sub    $0x14,%esp
  8012ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	53                   	push   %ebx
  8012f5:	e8 02 fc ff ff       	call   800efc <fd_lookup>
  8012fa:	83 c4 08             	add    $0x8,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 37                	js     801338 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130b:	ff 30                	pushl  (%eax)
  80130d:	e8 40 fc ff ff       	call   800f52 <dev_lookup>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 1f                	js     801338 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801320:	74 1b                	je     80133d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801322:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801325:	8b 52 18             	mov    0x18(%edx),%edx
  801328:	85 d2                	test   %edx,%edx
  80132a:	74 32                	je     80135e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	ff 75 0c             	pushl  0xc(%ebp)
  801332:	50                   	push   %eax
  801333:	ff d2                	call   *%edx
  801335:	83 c4 10             	add    $0x10,%esp
}
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80133d:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801342:	8b 40 48             	mov    0x48(%eax),%eax
  801345:	83 ec 04             	sub    $0x4,%esp
  801348:	53                   	push   %ebx
  801349:	50                   	push   %eax
  80134a:	68 e8 21 80 00       	push   $0x8021e8
  80134f:	e8 42 ee ff ff       	call   800196 <cprintf>
		return -E_INVAL;
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135c:	eb da                	jmp    801338 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80135e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801363:	eb d3                	jmp    801338 <ftruncate+0x52>

00801365 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	53                   	push   %ebx
  801369:	83 ec 14             	sub    $0x14,%esp
  80136c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	ff 75 08             	pushl  0x8(%ebp)
  801376:	e8 81 fb ff ff       	call   800efc <fd_lookup>
  80137b:	83 c4 08             	add    $0x8,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 4b                	js     8013cd <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138c:	ff 30                	pushl  (%eax)
  80138e:	e8 bf fb ff ff       	call   800f52 <dev_lookup>
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 33                	js     8013cd <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a1:	74 2f                	je     8013d2 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ad:	00 00 00 
	stat->st_isdir = 0;
  8013b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b7:	00 00 00 
	stat->st_dev = dev;
  8013ba:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c7:	ff 50 14             	call   *0x14(%eax)
  8013ca:	83 c4 10             	add    $0x10,%esp
}
  8013cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d0:	c9                   	leave  
  8013d1:	c3                   	ret    
		return -E_NOT_SUPP;
  8013d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d7:	eb f4                	jmp    8013cd <fstat+0x68>

008013d9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	6a 00                	push   $0x0
  8013e3:	ff 75 08             	pushl  0x8(%ebp)
  8013e6:	e8 e7 01 00 00       	call   8015d2 <open>
  8013eb:	89 c3                	mov    %eax,%ebx
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	78 1b                	js     80140f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	ff 75 0c             	pushl  0xc(%ebp)
  8013fa:	50                   	push   %eax
  8013fb:	e8 65 ff ff ff       	call   801365 <fstat>
  801400:	89 c6                	mov    %eax,%esi
	close(fd);
  801402:	89 1c 24             	mov    %ebx,(%esp)
  801405:	e8 27 fc ff ff       	call   801031 <close>
	return r;
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	89 f3                	mov    %esi,%ebx
}
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801414:	5b                   	pop    %ebx
  801415:	5e                   	pop    %esi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	56                   	push   %esi
  80141c:	53                   	push   %ebx
  80141d:	89 c6                	mov    %eax,%esi
  80141f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801421:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801428:	74 27                	je     801451 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80142a:	6a 07                	push   $0x7
  80142c:	68 00 50 80 00       	push   $0x805000
  801431:	56                   	push   %esi
  801432:	ff 35 00 40 80 00    	pushl  0x804000
  801438:	e8 c3 f9 ff ff       	call   800e00 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80143d:	83 c4 0c             	add    $0xc,%esp
  801440:	6a 00                	push   $0x0
  801442:	53                   	push   %ebx
  801443:	6a 00                	push   $0x0
  801445:	e8 55 f9 ff ff       	call   800d9f <ipc_recv>
}
  80144a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	6a 01                	push   $0x1
  801456:	e8 f2 f9 ff ff       	call   800e4d <ipc_find_env>
  80145b:	a3 00 40 80 00       	mov    %eax,0x804000
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	eb c5                	jmp    80142a <fsipc+0x12>

00801465 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	8b 40 0c             	mov    0xc(%eax),%eax
  801471:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801476:	8b 45 0c             	mov    0xc(%ebp),%eax
  801479:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80147e:	ba 00 00 00 00       	mov    $0x0,%edx
  801483:	b8 02 00 00 00       	mov    $0x2,%eax
  801488:	e8 8b ff ff ff       	call   801418 <fsipc>
}
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devfile_flush>:
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	8b 40 0c             	mov    0xc(%eax),%eax
  80149b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014aa:	e8 69 ff ff ff       	call   801418 <fsipc>
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <devfile_stat>:
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 04             	sub    $0x4,%esp
  8014b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014be:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8014d0:	e8 43 ff ff ff       	call   801418 <fsipc>
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 2c                	js     801505 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	68 00 50 80 00       	push   $0x805000
  8014e1:	53                   	push   %ebx
  8014e2:	e8 ce f2 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e7:	a1 80 50 80 00       	mov    0x805080,%eax
  8014ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014f2:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801505:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <devfile_write>:
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 0c             	sub    $0xc,%esp
  801510:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801513:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801518:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80151d:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801520:	8b 55 08             	mov    0x8(%ebp),%edx
  801523:	8b 52 0c             	mov    0xc(%edx),%edx
  801526:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80152c:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801531:	50                   	push   %eax
  801532:	ff 75 0c             	pushl  0xc(%ebp)
  801535:	68 08 50 80 00       	push   $0x805008
  80153a:	e8 04 f4 ff ff       	call   800943 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80153f:	ba 00 00 00 00       	mov    $0x0,%edx
  801544:	b8 04 00 00 00       	mov    $0x4,%eax
  801549:	e8 ca fe ff ff       	call   801418 <fsipc>
}
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <devfile_read>:
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801558:	8b 45 08             	mov    0x8(%ebp),%eax
  80155b:	8b 40 0c             	mov    0xc(%eax),%eax
  80155e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801563:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	b8 03 00 00 00       	mov    $0x3,%eax
  801573:	e8 a0 fe ff ff       	call   801418 <fsipc>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 1f                	js     80159d <devfile_read+0x4d>
	assert(r <= n);
  80157e:	39 f0                	cmp    %esi,%eax
  801580:	77 24                	ja     8015a6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801582:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801587:	7f 33                	jg     8015bc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	50                   	push   %eax
  80158d:	68 00 50 80 00       	push   $0x805000
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	e8 a9 f3 ff ff       	call   800943 <memmove>
	return r;
  80159a:	83 c4 10             	add    $0x10,%esp
}
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	5d                   	pop    %ebp
  8015a5:	c3                   	ret    
	assert(r <= n);
  8015a6:	68 54 22 80 00       	push   $0x802254
  8015ab:	68 5b 22 80 00       	push   $0x80225b
  8015b0:	6a 7d                	push   $0x7d
  8015b2:	68 70 22 80 00       	push   $0x802270
  8015b7:	e8 b3 05 00 00       	call   801b6f <_panic>
	assert(r <= PGSIZE);
  8015bc:	68 7b 22 80 00       	push   $0x80227b
  8015c1:	68 5b 22 80 00       	push   $0x80225b
  8015c6:	6a 7e                	push   $0x7e
  8015c8:	68 70 22 80 00       	push   $0x802270
  8015cd:	e8 9d 05 00 00       	call   801b6f <_panic>

008015d2 <open>:
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 1c             	sub    $0x1c,%esp
  8015da:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015dd:	56                   	push   %esi
  8015de:	e8 9b f1 ff ff       	call   80077e <strlen>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015eb:	0f 8f 96 00 00 00    	jg     801687 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	50                   	push   %eax
  8015f8:	e8 b0 f8 ff ff       	call   800ead <fd_alloc>
  8015fd:	89 c3                	mov    %eax,%ebx
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	85 c0                	test   %eax,%eax
  801604:	78 66                	js     80166c <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	56                   	push   %esi
  80160a:	68 00 50 80 00       	push   $0x805000
  80160f:	e8 a1 f1 ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801614:	8b 45 0c             	mov    0xc(%ebp),%eax
  801617:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80161c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161f:	b8 01 00 00 00       	mov    $0x1,%eax
  801624:	e8 ef fd ff ff       	call   801418 <fsipc>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 43                	js     801675 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	ff 75 f4             	pushl  -0xc(%ebp)
  801638:	e8 49 f8 ff ff       	call   800e86 <fd2num>
  80163d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801640:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801646:	8b 49 48             	mov    0x48(%ecx),%ecx
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	50                   	push   %eax
  80164d:	52                   	push   %edx
  80164e:	ff 32                	pushl  (%edx)
  801650:	56                   	push   %esi
  801651:	51                   	push   %ecx
  801652:	68 88 22 80 00       	push   $0x802288
  801657:	e8 3a eb ff ff       	call   800196 <cprintf>
	return fd2num(fd);
  80165c:	83 c4 14             	add    $0x14,%esp
  80165f:	ff 75 f4             	pushl  -0xc(%ebp)
  801662:	e8 1f f8 ff ff       	call   800e86 <fd2num>
  801667:	89 c3                	mov    %eax,%ebx
  801669:	83 c4 10             	add    $0x10,%esp
}
  80166c:	89 d8                	mov    %ebx,%eax
  80166e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    
		fd_close(fd, 0);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	6a 00                	push   $0x0
  80167a:	ff 75 f4             	pushl  -0xc(%ebp)
  80167d:	e8 26 f9 ff ff       	call   800fa8 <fd_close>
		return r;
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	eb e5                	jmp    80166c <open+0x9a>
		return -E_BAD_PATH;
  801687:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80168c:	eb de                	jmp    80166c <open+0x9a>

0080168e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801694:	ba 00 00 00 00       	mov    $0x0,%edx
  801699:	b8 08 00 00 00       	mov    $0x8,%eax
  80169e:	e8 75 fd ff ff       	call   801418 <fsipc>
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	56                   	push   %esi
  8016a9:	53                   	push   %ebx
  8016aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016ad:	83 ec 0c             	sub    $0xc,%esp
  8016b0:	ff 75 08             	pushl  0x8(%ebp)
  8016b3:	e8 de f7 ff ff       	call   800e96 <fd2data>
  8016b8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016ba:	83 c4 08             	add    $0x8,%esp
  8016bd:	68 c7 22 80 00       	push   $0x8022c7
  8016c2:	53                   	push   %ebx
  8016c3:	e8 ed f0 ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016c8:	8b 46 04             	mov    0x4(%esi),%eax
  8016cb:	2b 06                	sub    (%esi),%eax
  8016cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016da:	00 00 00 
	stat->st_dev = &devpipe;
  8016dd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016e4:	30 80 00 
	return 0;
}
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ef:	5b                   	pop    %ebx
  8016f0:	5e                   	pop    %esi
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 0c             	sub    $0xc,%esp
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016fd:	53                   	push   %ebx
  8016fe:	6a 00                	push   $0x0
  801700:	e8 2e f5 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801705:	89 1c 24             	mov    %ebx,(%esp)
  801708:	e8 89 f7 ff ff       	call   800e96 <fd2data>
  80170d:	83 c4 08             	add    $0x8,%esp
  801710:	50                   	push   %eax
  801711:	6a 00                	push   $0x0
  801713:	e8 1b f5 ff ff       	call   800c33 <sys_page_unmap>
}
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <_pipeisclosed>:
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	57                   	push   %edi
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	83 ec 1c             	sub    $0x1c,%esp
  801726:	89 c7                	mov    %eax,%edi
  801728:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80172a:	a1 04 40 80 00       	mov    0x804004,%eax
  80172f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801732:	83 ec 0c             	sub    $0xc,%esp
  801735:	57                   	push   %edi
  801736:	e8 7a 04 00 00       	call   801bb5 <pageref>
  80173b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80173e:	89 34 24             	mov    %esi,(%esp)
  801741:	e8 6f 04 00 00       	call   801bb5 <pageref>
		nn = thisenv->env_runs;
  801746:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80174c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	39 cb                	cmp    %ecx,%ebx
  801754:	74 1b                	je     801771 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801756:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801759:	75 cf                	jne    80172a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80175b:	8b 42 58             	mov    0x58(%edx),%eax
  80175e:	6a 01                	push   $0x1
  801760:	50                   	push   %eax
  801761:	53                   	push   %ebx
  801762:	68 ce 22 80 00       	push   $0x8022ce
  801767:	e8 2a ea ff ff       	call   800196 <cprintf>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	eb b9                	jmp    80172a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801771:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801774:	0f 94 c0             	sete   %al
  801777:	0f b6 c0             	movzbl %al,%eax
}
  80177a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5f                   	pop    %edi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <devpipe_write>:
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	57                   	push   %edi
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
  801788:	83 ec 28             	sub    $0x28,%esp
  80178b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80178e:	56                   	push   %esi
  80178f:	e8 02 f7 ff ff       	call   800e96 <fd2data>
  801794:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	bf 00 00 00 00       	mov    $0x0,%edi
  80179e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017a1:	74 4f                	je     8017f2 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8017a6:	8b 0b                	mov    (%ebx),%ecx
  8017a8:	8d 51 20             	lea    0x20(%ecx),%edx
  8017ab:	39 d0                	cmp    %edx,%eax
  8017ad:	72 14                	jb     8017c3 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8017af:	89 da                	mov    %ebx,%edx
  8017b1:	89 f0                	mov    %esi,%eax
  8017b3:	e8 65 ff ff ff       	call   80171d <_pipeisclosed>
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	75 3a                	jne    8017f6 <devpipe_write+0x74>
			sys_yield();
  8017bc:	e8 ce f3 ff ff       	call   800b8f <sys_yield>
  8017c1:	eb e0                	jmp    8017a3 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017ca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017cd:	89 c2                	mov    %eax,%edx
  8017cf:	c1 fa 1f             	sar    $0x1f,%edx
  8017d2:	89 d1                	mov    %edx,%ecx
  8017d4:	c1 e9 1b             	shr    $0x1b,%ecx
  8017d7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017da:	83 e2 1f             	and    $0x1f,%edx
  8017dd:	29 ca                	sub    %ecx,%edx
  8017df:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017e7:	83 c0 01             	add    $0x1,%eax
  8017ea:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017ed:	83 c7 01             	add    $0x1,%edi
  8017f0:	eb ac                	jmp    80179e <devpipe_write+0x1c>
	return i;
  8017f2:	89 f8                	mov    %edi,%eax
  8017f4:	eb 05                	jmp    8017fb <devpipe_write+0x79>
				return 0;
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fe:	5b                   	pop    %ebx
  8017ff:	5e                   	pop    %esi
  801800:	5f                   	pop    %edi
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <devpipe_read>:
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	57                   	push   %edi
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	83 ec 18             	sub    $0x18,%esp
  80180c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80180f:	57                   	push   %edi
  801810:	e8 81 f6 ff ff       	call   800e96 <fd2data>
  801815:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801817:	83 c4 10             	add    $0x10,%esp
  80181a:	be 00 00 00 00       	mov    $0x0,%esi
  80181f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801822:	74 47                	je     80186b <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801824:	8b 03                	mov    (%ebx),%eax
  801826:	3b 43 04             	cmp    0x4(%ebx),%eax
  801829:	75 22                	jne    80184d <devpipe_read+0x4a>
			if (i > 0)
  80182b:	85 f6                	test   %esi,%esi
  80182d:	75 14                	jne    801843 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80182f:	89 da                	mov    %ebx,%edx
  801831:	89 f8                	mov    %edi,%eax
  801833:	e8 e5 fe ff ff       	call   80171d <_pipeisclosed>
  801838:	85 c0                	test   %eax,%eax
  80183a:	75 33                	jne    80186f <devpipe_read+0x6c>
			sys_yield();
  80183c:	e8 4e f3 ff ff       	call   800b8f <sys_yield>
  801841:	eb e1                	jmp    801824 <devpipe_read+0x21>
				return i;
  801843:	89 f0                	mov    %esi,%eax
}
  801845:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801848:	5b                   	pop    %ebx
  801849:	5e                   	pop    %esi
  80184a:	5f                   	pop    %edi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80184d:	99                   	cltd   
  80184e:	c1 ea 1b             	shr    $0x1b,%edx
  801851:	01 d0                	add    %edx,%eax
  801853:	83 e0 1f             	and    $0x1f,%eax
  801856:	29 d0                	sub    %edx,%eax
  801858:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80185d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801860:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801863:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801866:	83 c6 01             	add    $0x1,%esi
  801869:	eb b4                	jmp    80181f <devpipe_read+0x1c>
	return i;
  80186b:	89 f0                	mov    %esi,%eax
  80186d:	eb d6                	jmp    801845 <devpipe_read+0x42>
				return 0;
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	eb cf                	jmp    801845 <devpipe_read+0x42>

00801876 <pipe>:
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	56                   	push   %esi
  80187a:	53                   	push   %ebx
  80187b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80187e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	e8 26 f6 ff ff       	call   800ead <fd_alloc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 5b                	js     8018eb <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801890:	83 ec 04             	sub    $0x4,%esp
  801893:	68 07 04 00 00       	push   $0x407
  801898:	ff 75 f4             	pushl  -0xc(%ebp)
  80189b:	6a 00                	push   $0x0
  80189d:	e8 0c f3 ff ff       	call   800bae <sys_page_alloc>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	83 c4 10             	add    $0x10,%esp
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 40                	js     8018eb <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b1:	50                   	push   %eax
  8018b2:	e8 f6 f5 ff ff       	call   800ead <fd_alloc>
  8018b7:	89 c3                	mov    %eax,%ebx
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	78 1b                	js     8018db <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	68 07 04 00 00       	push   $0x407
  8018c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cb:	6a 00                	push   $0x0
  8018cd:	e8 dc f2 ff ff       	call   800bae <sys_page_alloc>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	79 19                	jns    8018f4 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e1:	6a 00                	push   $0x0
  8018e3:	e8 4b f3 ff ff       	call   800c33 <sys_page_unmap>
  8018e8:	83 c4 10             	add    $0x10,%esp
}
  8018eb:	89 d8                	mov    %ebx,%eax
  8018ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    
	va = fd2data(fd0);
  8018f4:	83 ec 0c             	sub    $0xc,%esp
  8018f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fa:	e8 97 f5 ff ff       	call   800e96 <fd2data>
  8018ff:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801901:	83 c4 0c             	add    $0xc,%esp
  801904:	68 07 04 00 00       	push   $0x407
  801909:	50                   	push   %eax
  80190a:	6a 00                	push   $0x0
  80190c:	e8 9d f2 ff ff       	call   800bae <sys_page_alloc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 8c 00 00 00    	js     8019aa <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff 75 f0             	pushl  -0x10(%ebp)
  801924:	e8 6d f5 ff ff       	call   800e96 <fd2data>
  801929:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801930:	50                   	push   %eax
  801931:	6a 00                	push   $0x0
  801933:	56                   	push   %esi
  801934:	6a 00                	push   $0x0
  801936:	e8 b6 f2 ff ff       	call   800bf1 <sys_page_map>
  80193b:	89 c3                	mov    %eax,%ebx
  80193d:	83 c4 20             	add    $0x20,%esp
  801940:	85 c0                	test   %eax,%eax
  801942:	78 58                	js     80199c <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801947:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801962:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801967:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80196e:	83 ec 0c             	sub    $0xc,%esp
  801971:	ff 75 f4             	pushl  -0xc(%ebp)
  801974:	e8 0d f5 ff ff       	call   800e86 <fd2num>
  801979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80197c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80197e:	83 c4 04             	add    $0x4,%esp
  801981:	ff 75 f0             	pushl  -0x10(%ebp)
  801984:	e8 fd f4 ff ff       	call   800e86 <fd2num>
  801989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	bb 00 00 00 00       	mov    $0x0,%ebx
  801997:	e9 4f ff ff ff       	jmp    8018eb <pipe+0x75>
	sys_page_unmap(0, va);
  80199c:	83 ec 08             	sub    $0x8,%esp
  80199f:	56                   	push   %esi
  8019a0:	6a 00                	push   $0x0
  8019a2:	e8 8c f2 ff ff       	call   800c33 <sys_page_unmap>
  8019a7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 7c f2 ff ff       	call   800c33 <sys_page_unmap>
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	e9 1c ff ff ff       	jmp    8018db <pipe+0x65>

008019bf <pipeisclosed>:
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	e8 2b f5 ff ff       	call   800efc <fd_lookup>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 18                	js     8019f0 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 b3 f4 ff ff       	call   800e96 <fd2data>
	return _pipeisclosed(fd, p);
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e8:	e8 30 fd ff ff       	call   80171d <_pipeisclosed>
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a02:	68 e6 22 80 00       	push   $0x8022e6
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	e8 a6 ed ff ff       	call   8007b5 <strcpy>
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devcons_write>:
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a22:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a2d:	eb 2f                	jmp    801a5e <devcons_write+0x48>
		m = n - tot;
  801a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a32:	29 f3                	sub    %esi,%ebx
  801a34:	83 fb 7f             	cmp    $0x7f,%ebx
  801a37:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a3c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	53                   	push   %ebx
  801a43:	89 f0                	mov    %esi,%eax
  801a45:	03 45 0c             	add    0xc(%ebp),%eax
  801a48:	50                   	push   %eax
  801a49:	57                   	push   %edi
  801a4a:	e8 f4 ee ff ff       	call   800943 <memmove>
		sys_cputs(buf, m);
  801a4f:	83 c4 08             	add    $0x8,%esp
  801a52:	53                   	push   %ebx
  801a53:	57                   	push   %edi
  801a54:	e8 99 f0 ff ff       	call   800af2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a59:	01 de                	add    %ebx,%esi
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a61:	72 cc                	jb     801a2f <devcons_write+0x19>
}
  801a63:	89 f0                	mov    %esi,%eax
  801a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <devcons_read>:
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a78:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7c:	75 07                	jne    801a85 <devcons_read+0x18>
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    
		sys_yield();
  801a80:	e8 0a f1 ff ff       	call   800b8f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a85:	e8 86 f0 ff ff       	call   800b10 <sys_cgetc>
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	74 f2                	je     801a80 <devcons_read+0x13>
	if (c < 0)
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 ec                	js     801a7e <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a92:	83 f8 04             	cmp    $0x4,%eax
  801a95:	74 0c                	je     801aa3 <devcons_read+0x36>
	*(char*)vbuf = c;
  801a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a9a:	88 02                	mov    %al,(%edx)
	return 1;
  801a9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa1:	eb db                	jmp    801a7e <devcons_read+0x11>
		return 0;
  801aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa8:	eb d4                	jmp    801a7e <devcons_read+0x11>

00801aaa <cputchar>:
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ab6:	6a 01                	push   $0x1
  801ab8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abb:	50                   	push   %eax
  801abc:	e8 31 f0 ff ff       	call   800af2 <sys_cputs>
}
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <getchar>:
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801acc:	6a 01                	push   $0x1
  801ace:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad1:	50                   	push   %eax
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 94 f6 ff ff       	call   80116d <read>
	if (r < 0)
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	85 c0                	test   %eax,%eax
  801ade:	78 08                	js     801ae8 <getchar+0x22>
	if (r < 1)
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	7e 06                	jle    801aea <getchar+0x24>
	return c;
  801ae4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    
		return -E_EOF;
  801aea:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801aef:	eb f7                	jmp    801ae8 <getchar+0x22>

00801af1 <iscons>:
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afa:	50                   	push   %eax
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 f9 f3 ff ff       	call   800efc <fd_lookup>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 11                	js     801b1b <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b13:	39 10                	cmp    %edx,(%eax)
  801b15:	0f 94 c0             	sete   %al
  801b18:	0f b6 c0             	movzbl %al,%eax
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <opencons>:
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b26:	50                   	push   %eax
  801b27:	e8 81 f3 ff ff       	call   800ead <fd_alloc>
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 3a                	js     801b6d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	68 07 04 00 00       	push   $0x407
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 69 f0 ff ff       	call   800bae <sys_page_alloc>
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 c0                	test   %eax,%eax
  801b4a:	78 21                	js     801b6d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b55:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	50                   	push   %eax
  801b65:	e8 1c f3 ff ff       	call   800e86 <fd2num>
  801b6a:	83 c4 10             	add    $0x10,%esp
}
  801b6d:	c9                   	leave  
  801b6e:	c3                   	ret    

00801b6f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b74:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b77:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b7d:	e8 ee ef ff ff       	call   800b70 <sys_getenvid>
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	ff 75 0c             	pushl  0xc(%ebp)
  801b88:	ff 75 08             	pushl  0x8(%ebp)
  801b8b:	56                   	push   %esi
  801b8c:	50                   	push   %eax
  801b8d:	68 f4 22 80 00       	push   $0x8022f4
  801b92:	e8 ff e5 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b97:	83 c4 18             	add    $0x18,%esp
  801b9a:	53                   	push   %ebx
  801b9b:	ff 75 10             	pushl  0x10(%ebp)
  801b9e:	e8 a2 e5 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  801ba3:	c7 04 24 df 22 80 00 	movl   $0x8022df,(%esp)
  801baa:	e8 e7 e5 ff ff       	call   800196 <cprintf>
  801baf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bb2:	cc                   	int3   
  801bb3:	eb fd                	jmp    801bb2 <_panic+0x43>

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

00801bf0 <__udivdi3>:
  801bf0:	55                   	push   %ebp
  801bf1:	57                   	push   %edi
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 1c             	sub    $0x1c,%esp
  801bf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801bfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c07:	85 d2                	test   %edx,%edx
  801c09:	75 35                	jne    801c40 <__udivdi3+0x50>
  801c0b:	39 f3                	cmp    %esi,%ebx
  801c0d:	0f 87 bd 00 00 00    	ja     801cd0 <__udivdi3+0xe0>
  801c13:	85 db                	test   %ebx,%ebx
  801c15:	89 d9                	mov    %ebx,%ecx
  801c17:	75 0b                	jne    801c24 <__udivdi3+0x34>
  801c19:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f3                	div    %ebx
  801c22:	89 c1                	mov    %eax,%ecx
  801c24:	31 d2                	xor    %edx,%edx
  801c26:	89 f0                	mov    %esi,%eax
  801c28:	f7 f1                	div    %ecx
  801c2a:	89 c6                	mov    %eax,%esi
  801c2c:	89 e8                	mov    %ebp,%eax
  801c2e:	89 f7                	mov    %esi,%edi
  801c30:	f7 f1                	div    %ecx
  801c32:	89 fa                	mov    %edi,%edx
  801c34:	83 c4 1c             	add    $0x1c,%esp
  801c37:	5b                   	pop    %ebx
  801c38:	5e                   	pop    %esi
  801c39:	5f                   	pop    %edi
  801c3a:	5d                   	pop    %ebp
  801c3b:	c3                   	ret    
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	39 f2                	cmp    %esi,%edx
  801c42:	77 7c                	ja     801cc0 <__udivdi3+0xd0>
  801c44:	0f bd fa             	bsr    %edx,%edi
  801c47:	83 f7 1f             	xor    $0x1f,%edi
  801c4a:	0f 84 98 00 00 00    	je     801ce8 <__udivdi3+0xf8>
  801c50:	89 f9                	mov    %edi,%ecx
  801c52:	b8 20 00 00 00       	mov    $0x20,%eax
  801c57:	29 f8                	sub    %edi,%eax
  801c59:	d3 e2                	shl    %cl,%edx
  801c5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c5f:	89 c1                	mov    %eax,%ecx
  801c61:	89 da                	mov    %ebx,%edx
  801c63:	d3 ea                	shr    %cl,%edx
  801c65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c69:	09 d1                	or     %edx,%ecx
  801c6b:	89 f2                	mov    %esi,%edx
  801c6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c71:	89 f9                	mov    %edi,%ecx
  801c73:	d3 e3                	shl    %cl,%ebx
  801c75:	89 c1                	mov    %eax,%ecx
  801c77:	d3 ea                	shr    %cl,%edx
  801c79:	89 f9                	mov    %edi,%ecx
  801c7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c7f:	d3 e6                	shl    %cl,%esi
  801c81:	89 eb                	mov    %ebp,%ebx
  801c83:	89 c1                	mov    %eax,%ecx
  801c85:	d3 eb                	shr    %cl,%ebx
  801c87:	09 de                	or     %ebx,%esi
  801c89:	89 f0                	mov    %esi,%eax
  801c8b:	f7 74 24 08          	divl   0x8(%esp)
  801c8f:	89 d6                	mov    %edx,%esi
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	f7 64 24 0c          	mull   0xc(%esp)
  801c97:	39 d6                	cmp    %edx,%esi
  801c99:	72 0c                	jb     801ca7 <__udivdi3+0xb7>
  801c9b:	89 f9                	mov    %edi,%ecx
  801c9d:	d3 e5                	shl    %cl,%ebp
  801c9f:	39 c5                	cmp    %eax,%ebp
  801ca1:	73 5d                	jae    801d00 <__udivdi3+0x110>
  801ca3:	39 d6                	cmp    %edx,%esi
  801ca5:	75 59                	jne    801d00 <__udivdi3+0x110>
  801ca7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801caa:	31 ff                	xor    %edi,%edi
  801cac:	89 fa                	mov    %edi,%edx
  801cae:	83 c4 1c             	add    $0x1c,%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5f                   	pop    %edi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    
  801cb6:	8d 76 00             	lea    0x0(%esi),%esi
  801cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cc0:	31 ff                	xor    %edi,%edi
  801cc2:	31 c0                	xor    %eax,%eax
  801cc4:	89 fa                	mov    %edi,%edx
  801cc6:	83 c4 1c             	add    $0x1c,%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	31 ff                	xor    %edi,%edi
  801cd2:	89 e8                	mov    %ebp,%eax
  801cd4:	89 f2                	mov    %esi,%edx
  801cd6:	f7 f3                	div    %ebx
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	72 06                	jb     801cf2 <__udivdi3+0x102>
  801cec:	31 c0                	xor    %eax,%eax
  801cee:	39 eb                	cmp    %ebp,%ebx
  801cf0:	77 d2                	ja     801cc4 <__udivdi3+0xd4>
  801cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf7:	eb cb                	jmp    801cc4 <__udivdi3+0xd4>
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	31 ff                	xor    %edi,%edi
  801d04:	eb be                	jmp    801cc4 <__udivdi3+0xd4>
  801d06:	66 90                	xchg   %ax,%ax
  801d08:	66 90                	xchg   %ax,%ax
  801d0a:	66 90                	xchg   %ax,%ax
  801d0c:	66 90                	xchg   %ax,%ax
  801d0e:	66 90                	xchg   %ax,%ax

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	83 ec 1c             	sub    $0x1c,%esp
  801d17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d27:	85 ed                	test   %ebp,%ebp
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	89 da                	mov    %ebx,%edx
  801d2d:	75 19                	jne    801d48 <__umoddi3+0x38>
  801d2f:	39 df                	cmp    %ebx,%edi
  801d31:	0f 86 b1 00 00 00    	jbe    801de8 <__umoddi3+0xd8>
  801d37:	f7 f7                	div    %edi
  801d39:	89 d0                	mov    %edx,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	83 c4 1c             	add    $0x1c,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	39 dd                	cmp    %ebx,%ebp
  801d4a:	77 f1                	ja     801d3d <__umoddi3+0x2d>
  801d4c:	0f bd cd             	bsr    %ebp,%ecx
  801d4f:	83 f1 1f             	xor    $0x1f,%ecx
  801d52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d56:	0f 84 b4 00 00 00    	je     801e10 <__umoddi3+0x100>
  801d5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d61:	89 c2                	mov    %eax,%edx
  801d63:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d67:	29 c2                	sub    %eax,%edx
  801d69:	89 c1                	mov    %eax,%ecx
  801d6b:	89 f8                	mov    %edi,%eax
  801d6d:	d3 e5                	shl    %cl,%ebp
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d75:	d3 e8                	shr    %cl,%eax
  801d77:	09 c5                	or     %eax,%ebp
  801d79:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d7d:	89 c1                	mov    %eax,%ecx
  801d7f:	d3 e7                	shl    %cl,%edi
  801d81:	89 d1                	mov    %edx,%ecx
  801d83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d87:	89 df                	mov    %ebx,%edi
  801d89:	d3 ef                	shr    %cl,%edi
  801d8b:	89 c1                	mov    %eax,%ecx
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	d3 e3                	shl    %cl,%ebx
  801d91:	89 d1                	mov    %edx,%ecx
  801d93:	89 fa                	mov    %edi,%edx
  801d95:	d3 e8                	shr    %cl,%eax
  801d97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d9c:	09 d8                	or     %ebx,%eax
  801d9e:	f7 f5                	div    %ebp
  801da0:	d3 e6                	shl    %cl,%esi
  801da2:	89 d1                	mov    %edx,%ecx
  801da4:	f7 64 24 08          	mull   0x8(%esp)
  801da8:	39 d1                	cmp    %edx,%ecx
  801daa:	89 c3                	mov    %eax,%ebx
  801dac:	89 d7                	mov    %edx,%edi
  801dae:	72 06                	jb     801db6 <__umoddi3+0xa6>
  801db0:	75 0e                	jne    801dc0 <__umoddi3+0xb0>
  801db2:	39 c6                	cmp    %eax,%esi
  801db4:	73 0a                	jae    801dc0 <__umoddi3+0xb0>
  801db6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801dba:	19 ea                	sbb    %ebp,%edx
  801dbc:	89 d7                	mov    %edx,%edi
  801dbe:	89 c3                	mov    %eax,%ebx
  801dc0:	89 ca                	mov    %ecx,%edx
  801dc2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801dc7:	29 de                	sub    %ebx,%esi
  801dc9:	19 fa                	sbb    %edi,%edx
  801dcb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801dcf:	89 d0                	mov    %edx,%eax
  801dd1:	d3 e0                	shl    %cl,%eax
  801dd3:	89 d9                	mov    %ebx,%ecx
  801dd5:	d3 ee                	shr    %cl,%esi
  801dd7:	d3 ea                	shr    %cl,%edx
  801dd9:	09 f0                	or     %esi,%eax
  801ddb:	83 c4 1c             	add    $0x1c,%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5e                   	pop    %esi
  801de0:	5f                   	pop    %edi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    
  801de3:	90                   	nop
  801de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de8:	85 ff                	test   %edi,%edi
  801dea:	89 f9                	mov    %edi,%ecx
  801dec:	75 0b                	jne    801df9 <__umoddi3+0xe9>
  801dee:	b8 01 00 00 00       	mov    $0x1,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f7                	div    %edi
  801df7:	89 c1                	mov    %eax,%ecx
  801df9:	89 d8                	mov    %ebx,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f1                	div    %ecx
  801dff:	89 f0                	mov    %esi,%eax
  801e01:	f7 f1                	div    %ecx
  801e03:	e9 31 ff ff ff       	jmp    801d39 <__umoddi3+0x29>
  801e08:	90                   	nop
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	39 dd                	cmp    %ebx,%ebp
  801e12:	72 08                	jb     801e1c <__umoddi3+0x10c>
  801e14:	39 f7                	cmp    %esi,%edi
  801e16:	0f 87 21 ff ff ff    	ja     801d3d <__umoddi3+0x2d>
  801e1c:	89 da                	mov    %ebx,%edx
  801e1e:	89 f0                	mov    %esi,%eax
  801e20:	29 f8                	sub    %edi,%eax
  801e22:	19 ea                	sbb    %ebp,%edx
  801e24:	e9 14 ff ff ff       	jmp    801d3d <__umoddi3+0x2d>
