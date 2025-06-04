
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
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
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 83 0f 00 00       	call   800fc4 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 e1 10 00 00       	call   801139 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 2d 0b 00 00       	call   800b8f <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 16 22 80 00       	push   $0x802216
  80006a:	e8 46 01 00 00       	call   8001b5 <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 13 11 00 00       	call   80119a <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 f1 0a 00 00       	call   800b8f <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 00 22 80 00       	push   $0x802200
  8000a8:	e8 08 01 00 00       	call   8001b5 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 df 10 00 00       	call   80119a <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000cb:	e8 bf 0a 00 00       	call   800b8f <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010c:	e8 e5 12 00 00       	call   8013f6 <close_all>
	sys_env_destroy(0);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	6a 00                	push   $0x0
  800116:	e8 33 0a 00 00       	call   800b4e <sys_env_destroy>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	74 09                	je     800148 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	68 ff 00 00 00       	push   $0xff
  800150:	8d 43 08             	lea    0x8(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 b8 09 00 00       	call   800b11 <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	eb db                	jmp    80013f <putch+0x1f>

00800164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	68 20 01 80 00       	push   $0x800120
  800193:	e8 1a 01 00 00       	call   8002b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	83 c4 08             	add    $0x8,%esp
  80019b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 64 09 00 00       	call   800b11 <sys_cputs>

	return b.cnt;
}
  8001ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    

008001b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001be:	50                   	push   %eax
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	e8 9d ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 1c             	sub    $0x1c,%esp
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001f0:	39 d3                	cmp    %edx,%ebx
  8001f2:	72 05                	jb     8001f9 <printnum+0x30>
  8001f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f7:	77 7a                	ja     800273 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	ff 75 18             	pushl  0x18(%ebp)
  8001ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800202:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800205:	53                   	push   %ebx
  800206:	ff 75 10             	pushl  0x10(%ebp)
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020f:	ff 75 e0             	pushl  -0x20(%ebp)
  800212:	ff 75 dc             	pushl  -0x24(%ebp)
  800215:	ff 75 d8             	pushl  -0x28(%ebp)
  800218:	e8 93 1d 00 00       	call   801fb0 <__udivdi3>
  80021d:	83 c4 18             	add    $0x18,%esp
  800220:	52                   	push   %edx
  800221:	50                   	push   %eax
  800222:	89 f2                	mov    %esi,%edx
  800224:	89 f8                	mov    %edi,%eax
  800226:	e8 9e ff ff ff       	call   8001c9 <printnum>
  80022b:	83 c4 20             	add    $0x20,%esp
  80022e:	eb 13                	jmp    800243 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800230:	83 ec 08             	sub    $0x8,%esp
  800233:	56                   	push   %esi
  800234:	ff 75 18             	pushl  0x18(%ebp)
  800237:	ff d7                	call   *%edi
  800239:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80023c:	83 eb 01             	sub    $0x1,%ebx
  80023f:	85 db                	test   %ebx,%ebx
  800241:	7f ed                	jg     800230 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	56                   	push   %esi
  800247:	83 ec 04             	sub    $0x4,%esp
  80024a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024d:	ff 75 e0             	pushl  -0x20(%ebp)
  800250:	ff 75 dc             	pushl  -0x24(%ebp)
  800253:	ff 75 d8             	pushl  -0x28(%ebp)
  800256:	e8 75 1e 00 00       	call   8020d0 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 33 22 80 00 	movsbl 0x802233(%eax),%eax
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
}
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
  800273:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800276:	eb c4                	jmp    80023c <printnum+0x73>

00800278 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800282:	8b 10                	mov    (%eax),%edx
  800284:	3b 50 04             	cmp    0x4(%eax),%edx
  800287:	73 0a                	jae    800293 <sprintputch+0x1b>
		*b->buf++ = ch;
  800289:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028c:	89 08                	mov    %ecx,(%eax)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	88 02                	mov    %al,(%edx)
}
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <printfmt>:
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80029b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029e:	50                   	push   %eax
  80029f:	ff 75 10             	pushl  0x10(%ebp)
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	ff 75 08             	pushl  0x8(%ebp)
  8002a8:	e8 05 00 00 00       	call   8002b2 <vprintfmt>
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <vprintfmt>:
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	57                   	push   %edi
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	83 ec 2c             	sub    $0x2c,%esp
  8002bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c4:	e9 c1 03 00 00       	jmp    80068a <vprintfmt+0x3d8>
		padc = ' ';
  8002c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8d 47 01             	lea    0x1(%edi),%eax
  8002ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ed:	0f b6 17             	movzbl (%edi),%edx
  8002f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f3:	3c 55                	cmp    $0x55,%al
  8002f5:	0f 87 12 04 00 00    	ja     80070d <vprintfmt+0x45b>
  8002fb:	0f b6 c0             	movzbl %al,%eax
  8002fe:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800308:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80030c:	eb d9                	jmp    8002e7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800311:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800315:	eb d0                	jmp    8002e7 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800317:	0f b6 d2             	movzbl %dl,%edx
  80031a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80031d:	b8 00 00 00 00       	mov    $0x0,%eax
  800322:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800325:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800328:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800332:	83 f9 09             	cmp    $0x9,%ecx
  800335:	77 55                	ja     80038c <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800337:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033a:	eb e9                	jmp    800325 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80033c:	8b 45 14             	mov    0x14(%ebp),%eax
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	8d 40 04             	lea    0x4(%eax),%eax
  80034a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800350:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800354:	79 91                	jns    8002e7 <vprintfmt+0x35>
				width = precision, precision = -1;
  800356:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800363:	eb 82                	jmp    8002e7 <vprintfmt+0x35>
  800365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800368:	85 c0                	test   %eax,%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	0f 49 d0             	cmovns %eax,%edx
  800372:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800378:	e9 6a ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800380:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800387:	e9 5b ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
  80038c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800392:	eb bc                	jmp    800350 <vprintfmt+0x9e>
			lflag++;
  800394:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039a:	e9 48 ff ff ff       	jmp    8002e7 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 78 04             	lea    0x4(%eax),%edi
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	ff 30                	pushl  (%eax)
  8003ab:	ff d6                	call   *%esi
			break;
  8003ad:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b3:	e9 cf 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 78 04             	lea    0x4(%eax),%edi
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	99                   	cltd   
  8003c1:	31 d0                	xor    %edx,%eax
  8003c3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c5:	83 f8 0f             	cmp    $0xf,%eax
  8003c8:	7f 23                	jg     8003ed <vprintfmt+0x13b>
  8003ca:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	74 18                	je     8003ed <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 71 27 80 00       	push   $0x802771
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 b3 fe ff ff       	call   800295 <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e8:	e9 9a 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003ed:	50                   	push   %eax
  8003ee:	68 4b 22 80 00       	push   $0x80224b
  8003f3:	53                   	push   %ebx
  8003f4:	56                   	push   %esi
  8003f5:	e8 9b fe ff ff       	call   800295 <printfmt>
  8003fa:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 82 02 00 00       	jmp    800687 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	83 c0 04             	add    $0x4,%eax
  80040b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800413:	85 ff                	test   %edi,%edi
  800415:	b8 44 22 80 00       	mov    $0x802244,%eax
  80041a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 8e bd 00 00 00    	jle    8004e4 <vprintfmt+0x232>
  800427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042b:	75 0e                	jne    80043b <vprintfmt+0x189>
  80042d:	89 75 08             	mov    %esi,0x8(%ebp)
  800430:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800433:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800436:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800439:	eb 6d                	jmp    8004a8 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	ff 75 d0             	pushl  -0x30(%ebp)
  800441:	57                   	push   %edi
  800442:	e8 6e 03 00 00       	call   8007b5 <strnlen>
  800447:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044a:	29 c1                	sub    %eax,%ecx
  80044c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800452:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	eb 0f                	jmp    80046f <vprintfmt+0x1bd>
					putch(padc, putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	ff 75 e0             	pushl  -0x20(%ebp)
  800467:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ef 01             	sub    $0x1,%edi
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	85 ff                	test   %edi,%edi
  800471:	7f ed                	jg     800460 <vprintfmt+0x1ae>
  800473:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800476:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800479:	85 c9                	test   %ecx,%ecx
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	0f 49 c1             	cmovns %ecx,%eax
  800483:	29 c1                	sub    %eax,%ecx
  800485:	89 75 08             	mov    %esi,0x8(%ebp)
  800488:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048e:	89 cb                	mov    %ecx,%ebx
  800490:	eb 16                	jmp    8004a8 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800492:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800496:	75 31                	jne    8004c9 <vprintfmt+0x217>
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	50                   	push   %eax
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	83 c7 01             	add    $0x1,%edi
  8004ab:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004af:	0f be c2             	movsbl %dl,%eax
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	74 59                	je     80050f <vprintfmt+0x25d>
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	78 d8                	js     800492 <vprintfmt+0x1e0>
  8004ba:	83 ee 01             	sub    $0x1,%esi
  8004bd:	79 d3                	jns    800492 <vprintfmt+0x1e0>
  8004bf:	89 df                	mov    %ebx,%edi
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 37                	jmp    800500 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	0f be d2             	movsbl %dl,%edx
  8004cc:	83 ea 20             	sub    $0x20,%edx
  8004cf:	83 fa 5e             	cmp    $0x5e,%edx
  8004d2:	76 c4                	jbe    800498 <vprintfmt+0x1e6>
					putch('?', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	ff 75 0c             	pushl  0xc(%ebp)
  8004da:	6a 3f                	push   $0x3f
  8004dc:	ff 55 08             	call   *0x8(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb c1                	jmp    8004a5 <vprintfmt+0x1f3>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	eb b6                	jmp    8004a8 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	6a 20                	push   $0x20
  8004f8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004fa:	83 ef 01             	sub    $0x1,%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 ff                	test   %edi,%edi
  800502:	7f ee                	jg     8004f2 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	e9 78 01 00 00       	jmp    800687 <vprintfmt+0x3d5>
  80050f:	89 df                	mov    %ebx,%edi
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800517:	eb e7                	jmp    800500 <vprintfmt+0x24e>
	if (lflag >= 2)
  800519:	83 f9 01             	cmp    $0x1,%ecx
  80051c:	7e 3f                	jle    80055d <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8b 50 04             	mov    0x4(%eax),%edx
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8d 40 08             	lea    0x8(%eax),%eax
  800532:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800539:	79 5c                	jns    800597 <vprintfmt+0x2e5>
				putch('-', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 2d                	push   $0x2d
  800541:	ff d6                	call   *%esi
				num = -(long long) num;
  800543:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800549:	f7 da                	neg    %edx
  80054b:	83 d1 00             	adc    $0x0,%ecx
  80054e:	f7 d9                	neg    %ecx
  800550:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800553:	b8 0a 00 00 00       	mov    $0xa,%eax
  800558:	e9 10 01 00 00       	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	75 1b                	jne    80057c <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 c1                	mov    %eax,%ecx
  80056b:	c1 f9 1f             	sar    $0x1f,%ecx
  80056e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	eb b9                	jmp    800535 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 c1                	mov    %eax,%ecx
  800586:	c1 f9 1f             	sar    $0x1f,%ecx
  800589:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 40 04             	lea    0x4(%eax),%eax
  800592:	89 45 14             	mov    %eax,0x14(%ebp)
  800595:	eb 9e                	jmp    800535 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800597:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a2:	e9 c6 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005a7:	83 f9 01             	cmp    $0x1,%ecx
  8005aa:	7e 18                	jle    8005c4 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b4:	8d 40 08             	lea    0x8(%eax),%eax
  8005b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bf:	e9 a9 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  8005c4:	85 c9                	test   %ecx,%ecx
  8005c6:	75 1a                	jne    8005e2 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	e9 8b 00 00 00       	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 10                	mov    (%eax),%edx
  8005e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	eb 74                	jmp    80066d <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f9:	83 f9 01             	cmp    $0x1,%ecx
  8005fc:	7e 15                	jle    800613 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	8b 48 04             	mov    0x4(%eax),%ecx
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80060c:	b8 08 00 00 00       	mov    $0x8,%eax
  800611:	eb 5a                	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	75 17                	jne    80062e <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 3f                	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80063e:	b8 08 00 00 00       	mov    $0x8,%eax
  800643:	eb 28                	jmp    80066d <vprintfmt+0x3bb>
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 30                	push   $0x30
  80064b:	ff d6                	call   *%esi
			putch('x', putdat);
  80064d:	83 c4 08             	add    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 78                	push   $0x78
  800653:	ff d6                	call   *%esi
			num = (unsigned long long)
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800674:	57                   	push   %edi
  800675:	ff 75 e0             	pushl  -0x20(%ebp)
  800678:	50                   	push   %eax
  800679:	51                   	push   %ecx
  80067a:	52                   	push   %edx
  80067b:	89 da                	mov    %ebx,%edx
  80067d:	89 f0                	mov    %esi,%eax
  80067f:	e8 45 fb ff ff       	call   8001c9 <printnum>
			break;
  800684:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	83 f8 25             	cmp    $0x25,%eax
  800694:	0f 84 2f fc ff ff    	je     8002c9 <vprintfmt+0x17>
			if (ch == '\0')
  80069a:	85 c0                	test   %eax,%eax
  80069c:	0f 84 8b 00 00 00    	je     80072d <vprintfmt+0x47b>
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	ff d6                	call   *%esi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	eb dc                	jmp    80068a <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006ae:	83 f9 01             	cmp    $0x1,%ecx
  8006b1:	7e 15                	jle    8006c8 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c6:	eb a5                	jmp    80066d <vprintfmt+0x3bb>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 17                	jne    8006e3 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e1:	eb 8a                	jmp    80066d <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	e9 70 ff ff ff       	jmp    80066d <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	e9 7a ff ff ff       	jmp    800687 <vprintfmt+0x3d5>
			putch('%', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 25                	push   $0x25
  800713:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	89 f8                	mov    %edi,%eax
  80071a:	eb 03                	jmp    80071f <vprintfmt+0x46d>
  80071c:	83 e8 01             	sub    $0x1,%eax
  80071f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800723:	75 f7                	jne    80071c <vprintfmt+0x46a>
  800725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800728:	e9 5a ff ff ff       	jmp    800687 <vprintfmt+0x3d5>
}
  80072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 26                	je     80077c <vsnprintf+0x47>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 22                	jle    80077c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	ff 75 14             	pushl  0x14(%ebp)
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	68 78 02 80 00       	push   $0x800278
  800769:	e8 44 fb ff ff       	call   8002b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800781:	eb f7                	jmp    80077a <vsnprintf+0x45>

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078c:	50                   	push   %eax
  80078d:	ff 75 10             	pushl  0x10(%ebp)
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 9a ff ff ff       	call   800735 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 03                	jmp    8007ad <strlen+0x10>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f7                	jne    8007aa <strlen+0xd>
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strnlen+0x13>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	39 d0                	cmp    %edx,%eax
  8007ca:	74 06                	je     8007d2 <strnlen+0x1d>
  8007cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d0:	75 f3                	jne    8007c5 <strnlen+0x10>
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007de:	89 c2                	mov    %eax,%edx
  8007e0:	83 c1 01             	add    $0x1,%ecx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ed:	84 db                	test   %bl,%bl
  8007ef:	75 ef                	jne    8007e0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fb:	53                   	push   %ebx
  8007fc:	e8 9c ff ff ff       	call   80079d <strlen>
  800801:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	01 d8                	add    %ebx,%eax
  800809:	50                   	push   %eax
  80080a:	e8 c5 ff ff ff       	call   8007d4 <strcpy>
	return dst;
}
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f2                	mov    %esi,%edx
  800828:	eb 0f                	jmp    800839 <strncpy+0x23>
		*dst++ = *src;
  80082a:	83 c2 01             	add    $0x1,%edx
  80082d:	0f b6 01             	movzbl (%ecx),%eax
  800830:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800833:	80 39 01             	cmpb   $0x1,(%ecx)
  800836:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800839:	39 da                	cmp    %ebx,%edx
  80083b:	75 ed                	jne    80082a <strncpy+0x14>
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 75 08             	mov    0x8(%ebp),%esi
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800851:	89 f0                	mov    %esi,%eax
  800853:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 c9                	test   %ecx,%ecx
  800859:	75 0b                	jne    800866 <strlcpy+0x23>
  80085b:	eb 17                	jmp    800874 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 07                	je     800871 <strlcpy+0x2e>
  80086a:	0f b6 0a             	movzbl (%edx),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	75 ec                	jne    80085d <strlcpy+0x1a>
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800883:	eb 06                	jmp    80088b <strcmp+0x11>
		p++, q++;
  800885:	83 c1 01             	add    $0x1,%ecx
  800888:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088b:	0f b6 01             	movzbl (%ecx),%eax
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x1c>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 ef                	je     800885 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	0f b6 c0             	movzbl %al,%eax
  800899:	0f b6 12             	movzbl (%edx),%edx
  80089c:	29 d0                	sub    %edx,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008aa:	89 c3                	mov    %eax,%ebx
  8008ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008af:	eb 06                	jmp    8008b7 <strncmp+0x17>
		n--, p++, q++;
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 16                	je     8008d1 <strncmp+0x31>
  8008bb:	0f b6 08             	movzbl (%eax),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	74 04                	je     8008c6 <strncmp+0x26>
  8008c2:	3a 0a                	cmp    (%edx),%cl
  8008c4:	74 eb                	je     8008b1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 00             	movzbl (%eax),%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5b                   	pop    %ebx
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    
		return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d6:	eb f6                	jmp    8008ce <strncmp+0x2e>

008008d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e2:	0f b6 10             	movzbl (%eax),%edx
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 09                	je     8008f2 <strchr+0x1a>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 0a                	je     8008f7 <strchr+0x1f>
	for (; *s; s++)
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	eb f0                	jmp    8008e2 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800903:	eb 03                	jmp    800908 <strfind+0xf>
  800905:	83 c0 01             	add    $0x1,%eax
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 04                	je     800913 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	75 f2                	jne    800905 <strfind+0xc>
			break;
	return (char *) s;
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 13                	je     800938 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 05                	jne    800932 <memset+0x1d>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	74 0d                	je     80093f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800932:	8b 45 0c             	mov    0xc(%ebp),%eax
  800935:	fc                   	cld    
  800936:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800938:	89 f8                	mov    %edi,%eax
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    
		c &= 0xFF;
  80093f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 08             	shl    $0x8,%ebx
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 18             	shl    $0x18,%eax
  80094d:	89 d6                	mov    %edx,%esi
  80094f:	c1 e6 10             	shl    $0x10,%esi
  800952:	09 f0                	or     %esi,%eax
  800954:	09 c2                	or     %eax,%edx
  800956:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb d6                	jmp    800938 <memset+0x23>

00800962 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 35                	jae    8009a9 <memmove+0x47>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 c2                	cmp    %eax,%edx
  800979:	76 2e                	jbe    8009a9 <memmove+0x47>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 d6                	mov    %edx,%esi
  800980:	09 fe                	or     %edi,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	74 0c                	je     800996 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80098a:	83 ef 01             	sub    $0x1,%edi
  80098d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800990:	fd                   	std    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800993:	fc                   	cld    
  800994:	eb 21                	jmp    8009b7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 ef                	jne    80098a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb ea                	jmp    800993 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 f2                	mov    %esi,%edx
  8009ab:	09 c2                	or     %eax,%edx
  8009ad:	f6 c2 03             	test   $0x3,%dl
  8009b0:	74 09                	je     8009bb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	f6 c1 03             	test   $0x3,%cl
  8009be:	75 f2                	jne    8009b2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c3:	89 c7                	mov    %eax,%edi
  8009c5:	fc                   	cld    
  8009c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c8:	eb ed                	jmp    8009b7 <memmove+0x55>

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cd:	ff 75 10             	pushl  0x10(%ebp)
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	ff 75 08             	pushl  0x8(%ebp)
  8009d6:	e8 87 ff ff ff       	call   800962 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e8:	89 c6                	mov    %eax,%esi
  8009ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ed:	39 f0                	cmp    %esi,%eax
  8009ef:	74 1c                	je     800a0d <memcmp+0x30>
		if (*s1 != *s2)
  8009f1:	0f b6 08             	movzbl (%eax),%ecx
  8009f4:	0f b6 1a             	movzbl (%edx),%ebx
  8009f7:	38 d9                	cmp    %bl,%cl
  8009f9:	75 08                	jne    800a03 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	eb ea                	jmp    8009ed <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a03:	0f b6 c1             	movzbl %cl,%eax
  800a06:	0f b6 db             	movzbl %bl,%ebx
  800a09:	29 d8                	sub    %ebx,%eax
  800a0b:	eb 05                	jmp    800a12 <memcmp+0x35>
	}

	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 09                	jae    800a31 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	74 05                	je     800a31 <memfind+0x1b>
	for (; s < ends; s++)
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	eb f3                	jmp    800a24 <memfind+0xe>
			break;
	return (void *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3f:	eb 03                	jmp    800a44 <strtol+0x11>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a44:	0f b6 01             	movzbl (%ecx),%eax
  800a47:	3c 20                	cmp    $0x20,%al
  800a49:	74 f6                	je     800a41 <strtol+0xe>
  800a4b:	3c 09                	cmp    $0x9,%al
  800a4d:	74 f2                	je     800a41 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4f:	3c 2b                	cmp    $0x2b,%al
  800a51:	74 2e                	je     800a81 <strtol+0x4e>
	int neg = 0;
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	74 2f                	je     800a8b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 05                	jne    800a69 <strtol+0x36>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	74 2c                	je     800a95 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	75 0a                	jne    800a77 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	74 28                	je     800a9f <strtol+0x6c>
		base = 10;
  800a77:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7f:	eb 50                	jmp    800ad1 <strtol+0x9e>
		s++;
  800a81:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	eb d1                	jmp    800a5c <strtol+0x29>
		s++, neg = 1;
  800a8b:	83 c1 01             	add    $0x1,%ecx
  800a8e:	bf 01 00 00 00       	mov    $0x1,%edi
  800a93:	eb c7                	jmp    800a5c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a99:	74 0e                	je     800aa9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	75 d8                	jne    800a77 <strtol+0x44>
		s++, base = 8;
  800a9f:	83 c1 01             	add    $0x1,%ecx
  800aa2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa7:	eb ce                	jmp    800a77 <strtol+0x44>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb c4                	jmp    800a77 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ab3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 29                	ja     800ae6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac6:	7d 30                	jge    800af8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac8:	83 c1 01             	add    $0x1,%ecx
  800acb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 d5                	ja     800ab3 <strtol+0x80>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb dd                	jmp    800ac3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 37             	sub    $0x37,%edx
  800af6:	eb cb                	jmp    800ac3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afc:	74 05                	je     800b03 <strtol+0xd0>
		*endptr = (char *) s;
  800afe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b01:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b03:	89 c2                	mov    %eax,%edx
  800b05:	f7 da                	neg    %edx
  800b07:	85 ff                	test   %edi,%edi
  800b09:	0f 45 c2             	cmovne %edx,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	89 c6                	mov    %eax,%esi
  800b28:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	89 cb                	mov    %ecx,%ebx
  800b66:	89 cf                	mov    %ecx,%edi
  800b68:	89 ce                	mov    %ecx,%esi
  800b6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	7f 08                	jg     800b78 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	50                   	push   %eax
  800b7c:	6a 03                	push   $0x3
  800b7e:	68 3f 25 80 00       	push   $0x80253f
  800b83:	6a 23                	push   $0x23
  800b85:	68 5c 25 80 00       	push   $0x80255c
  800b8a:	e8 7a 13 00 00       	call   801f09 <_panic>

00800b8f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_yield>:

void
sys_yield(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd6:	be 00 00 00 00       	mov    $0x0,%esi
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be1:	b8 04 00 00 00       	mov    $0x4,%eax
  800be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be9:	89 f7                	mov    %esi,%edi
  800beb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7f 08                	jg     800bf9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 04                	push   $0x4
  800bff:	68 3f 25 80 00       	push   $0x80253f
  800c04:	6a 23                	push   $0x23
  800c06:	68 5c 25 80 00       	push   $0x80255c
  800c0b:	e8 f9 12 00 00       	call   801f09 <_panic>

00800c10 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7f 08                	jg     800c3b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 05                	push   $0x5
  800c41:	68 3f 25 80 00       	push   $0x80253f
  800c46:	6a 23                	push   $0x23
  800c48:	68 5c 25 80 00       	push   $0x80255c
  800c4d:	e8 b7 12 00 00       	call   801f09 <_panic>

00800c52 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7f 08                	jg     800c7d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 06                	push   $0x6
  800c83:	68 3f 25 80 00       	push   $0x80253f
  800c88:	6a 23                	push   $0x23
  800c8a:	68 5c 25 80 00       	push   $0x80255c
  800c8f:	e8 75 12 00 00       	call   801f09 <_panic>

00800c94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7f 08                	jg     800cbf <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 08                	push   $0x8
  800cc5:	68 3f 25 80 00       	push   $0x80253f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 5c 25 80 00       	push   $0x80255c
  800cd1:	e8 33 12 00 00       	call   801f09 <_panic>

00800cd6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	b8 09 00 00 00       	mov    $0x9,%eax
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 09                	push   $0x9
  800d07:	68 3f 25 80 00       	push   $0x80253f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 5c 25 80 00       	push   $0x80255c
  800d13:	e8 f1 11 00 00       	call   801f09 <_panic>

00800d18 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 0a                	push   $0xa
  800d49:	68 3f 25 80 00       	push   $0x80253f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 5c 25 80 00       	push   $0x80255c
  800d55:	e8 af 11 00 00       	call   801f09 <_panic>

00800d5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6b:	be 00 00 00 00       	mov    $0x0,%esi
  800d70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d76:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d93:	89 cb                	mov    %ecx,%ebx
  800d95:	89 cf                	mov    %ecx,%edi
  800d97:	89 ce                	mov    %ecx,%esi
  800d99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7f 08                	jg     800da7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 0d                	push   $0xd
  800dad:	68 3f 25 80 00       	push   $0x80253f
  800db2:	6a 23                	push   $0x23
  800db4:	68 5c 25 80 00       	push   $0x80255c
  800db9:	e8 4b 11 00 00       	call   801f09 <_panic>

00800dbe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 04             	sub    $0x4,%esp
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc8:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800dca:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800dcd:	a8 02                	test   $0x2,%al
  800dcf:	0f 84 89 00 00 00    	je     800e5e <pgfault+0xa0>
  800dd5:	89 da                	mov    %ebx,%edx
  800dd7:	c1 ea 0c             	shr    $0xc,%edx
  800dda:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de1:	f6 c6 08             	test   $0x8,%dh
  800de4:	74 78                	je     800e5e <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	6a 07                	push   $0x7
  800deb:	68 00 f0 7f 00       	push   $0x7ff000
  800df0:	6a 00                	push   $0x0
  800df2:	e8 d6 fd ff ff       	call   800bcd <sys_page_alloc>
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	0f 88 8b 00 00 00    	js     800e8d <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	68 00 10 00 00       	push   $0x1000
  800e0a:	53                   	push   %ebx
  800e0b:	68 00 f0 7f 00       	push   $0x7ff000
  800e10:	e8 4d fb ff ff       	call   800962 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e15:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e1c:	53                   	push   %ebx
  800e1d:	6a 00                	push   $0x0
  800e1f:	68 00 f0 7f 00       	push   $0x7ff000
  800e24:	6a 00                	push   $0x0
  800e26:	e8 e5 fd ff ff       	call   800c10 <sys_page_map>
  800e2b:	83 c4 20             	add    $0x20,%esp
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	78 6d                	js     800e9f <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	68 00 f0 7f 00       	push   $0x7ff000
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 11 fe ff ff       	call   800c52 <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 69                	js     800eb1 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	68 c8 25 80 00       	push   $0x8025c8
  800e51:	e8 5f f3 ff ff       	call   8001b5 <cprintf>

}
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800e5e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800e64:	8b 4a 48             	mov    0x48(%edx),%ecx
  800e67:	89 da                	mov    %ebx,%edx
  800e69:	c1 ea 0c             	shr    $0xc,%edx
  800e6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e73:	51                   	push   %ecx
  800e74:	53                   	push   %ebx
  800e75:	68 00 00 40 ef       	push   $0xef400000
  800e7a:	52                   	push   %edx
  800e7b:	50                   	push   %eax
  800e7c:	68 6c 25 80 00       	push   $0x80256c
  800e81:	6a 1e                	push   $0x1e
  800e83:	68 e9 25 80 00       	push   $0x8025e9
  800e88:	e8 7c 10 00 00       	call   801f09 <_panic>
        panic("sys_page_alloc error %e", r);
  800e8d:	50                   	push   %eax
  800e8e:	68 f4 25 80 00       	push   $0x8025f4
  800e93:	6a 28                	push   $0x28
  800e95:	68 e9 25 80 00       	push   $0x8025e9
  800e9a:	e8 6a 10 00 00       	call   801f09 <_panic>
        panic("sys_page_map error %e", r);
  800e9f:	50                   	push   %eax
  800ea0:	68 0c 26 80 00       	push   $0x80260c
  800ea5:	6a 2b                	push   $0x2b
  800ea7:	68 e9 25 80 00       	push   $0x8025e9
  800eac:	e8 58 10 00 00       	call   801f09 <_panic>
        panic("sys_page_unmap error %e", r);
  800eb1:	50                   	push   %eax
  800eb2:	68 22 26 80 00       	push   $0x802622
  800eb7:	6a 2d                	push   $0x2d
  800eb9:	68 e9 25 80 00       	push   $0x8025e9
  800ebe:	e8 46 10 00 00       	call   801f09 <_panic>

00800ec3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ec9:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800ed0:	74 23                	je     800ef5 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800eda:	a1 04 40 80 00       	mov    0x804004,%eax
  800edf:	8b 40 48             	mov    0x48(%eax),%eax
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	68 4f 1f 80 00       	push   $0x801f4f
  800eea:	50                   	push   %eax
  800eeb:	e8 28 fe ff ff       	call   800d18 <sys_env_set_pgfault_upcall>
}
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800ef5:	a1 04 40 80 00       	mov    0x804004,%eax
  800efa:	8b 40 48             	mov    0x48(%eax),%eax
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	6a 07                	push   $0x7
  800f02:	68 00 f0 bf ee       	push   $0xeebff000
  800f07:	50                   	push   %eax
  800f08:	e8 c0 fc ff ff       	call   800bcd <sys_page_alloc>
  800f0d:	83 c4 10             	add    $0x10,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	79 be                	jns    800ed2 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f14:	50                   	push   %eax
  800f15:	68 3a 26 80 00       	push   $0x80263a
  800f1a:	6a 21                	push   $0x21
  800f1c:	68 4d 26 80 00       	push   $0x80264d
  800f21:	e8 e3 0f 00 00       	call   801f09 <_panic>

00800f26 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f31:	83 ec 04             	sub    $0x4,%esp
  800f34:	6a 07                	push   $0x7
  800f36:	53                   	push   %ebx
  800f37:	56                   	push   %esi
  800f38:	e8 90 fc ff ff       	call   800bcd <sys_page_alloc>
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 4a                	js     800f8e <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	6a 07                	push   $0x7
  800f49:	68 00 00 40 00       	push   $0x400000
  800f4e:	6a 00                	push   $0x0
  800f50:	53                   	push   %ebx
  800f51:	56                   	push   %esi
  800f52:	e8 b9 fc ff ff       	call   800c10 <sys_page_map>
  800f57:	83 c4 20             	add    $0x20,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	78 42                	js     800fa0 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800f5e:	83 ec 04             	sub    $0x4,%esp
  800f61:	68 00 10 00 00       	push   $0x1000
  800f66:	53                   	push   %ebx
  800f67:	68 00 00 40 00       	push   $0x400000
  800f6c:	e8 f1 f9 ff ff       	call   800962 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f71:	83 c4 08             	add    $0x8,%esp
  800f74:	68 00 00 40 00       	push   $0x400000
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 d2 fc ff ff       	call   800c52 <sys_page_unmap>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 2b                	js     800fb2 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800f8e:	50                   	push   %eax
  800f8f:	68 3a 26 80 00       	push   $0x80263a
  800f94:	6a 63                	push   $0x63
  800f96:	68 e9 25 80 00       	push   $0x8025e9
  800f9b:	e8 69 0f 00 00       	call   801f09 <_panic>
        panic("sys_page_map: %e", r);
  800fa0:	50                   	push   %eax
  800fa1:	68 5d 26 80 00       	push   $0x80265d
  800fa6:	6a 65                	push   $0x65
  800fa8:	68 e9 25 80 00       	push   $0x8025e9
  800fad:	e8 57 0f 00 00       	call   801f09 <_panic>
        panic("sys_page_unmap: %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 6e 26 80 00       	push   $0x80266e
  800fb8:	6a 68                	push   $0x68
  800fba:	68 e9 25 80 00       	push   $0x8025e9
  800fbf:	e8 45 0f 00 00       	call   801f09 <_panic>

00800fc4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
  800fca:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  800fcd:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd2:	8b 40 64             	mov    0x64(%eax),%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	74 1f                	je     800ff8 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd9:	b8 07 00 00 00       	mov    $0x7,%eax
  800fde:	cd 30                	int    $0x30
  800fe0:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  800fe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	74 21                	je     80100a <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  800fe9:	be 08 40 80 00       	mov    $0x804008,%esi
  800fee:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  800ff1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff6:	eb 7b                	jmp    801073 <fork+0xaf>
        set_pgfault_handler(pgfault);
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	68 be 0d 80 00       	push   $0x800dbe
  801000:	e8 be fe ff ff       	call   800ec3 <set_pgfault_handler>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	eb cf                	jmp    800fd9 <fork+0x15>
        set_pgfault_handler(pgfault);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	68 be 0d 80 00       	push   $0x800dbe
  801012:	e8 ac fe ff ff       	call   800ec3 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801017:	e8 73 fb ff ff       	call   800b8f <sys_getenvid>
  80101c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801021:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801024:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801029:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	e9 ca 00 00 00       	jmp    801100 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801036:	89 d1                	mov    %edx,%ecx
  801038:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  80103e:	81 e2 02 08 00 00    	and    $0x802,%edx
  801044:	89 cf                	mov    %ecx,%edi
  801046:	81 cf 00 08 00 00    	or     $0x800,%edi
  80104c:	85 d2                	test   %edx,%edx
  80104e:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	51                   	push   %ecx
  801055:	50                   	push   %eax
  801056:	ff 75 e4             	pushl  -0x1c(%ebp)
  801059:	50                   	push   %eax
  80105a:	6a 00                	push   $0x0
  80105c:	e8 af fb ff ff       	call   800c10 <sys_page_map>
  801061:	83 c4 20             	add    $0x20,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 45                	js     8010ad <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801068:	83 c3 01             	add    $0x1,%ebx
  80106b:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  801071:	74 4c                	je     8010bf <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801073:	39 de                	cmp    %ebx,%esi
  801075:	74 f1                	je     801068 <fork+0xa4>
  801077:	89 d8                	mov    %ebx,%eax
  801079:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  80107c:	89 c2                	mov    %eax,%edx
  80107e:	c1 ea 16             	shr    $0x16,%edx
  801081:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801088:	f6 c2 05             	test   $0x5,%dl
  80108b:	74 db                	je     801068 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  80108d:	89 c2                	mov    %eax,%edx
  80108f:	c1 ea 0c             	shr    $0xc,%edx
  801092:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801099:	f6 c2 04             	test   $0x4,%dl
  80109c:	74 ca                	je     801068 <fork+0xa4>
    if (perm & PTE_SHARE) {
  80109e:	f6 c6 04             	test   $0x4,%dh
  8010a1:	74 93                	je     801036 <fork+0x72>
        perm &= ~PTE_COW;
  8010a3:	89 d1                	mov    %edx,%ecx
  8010a5:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8010ab:	eb a4                	jmp    801051 <fork+0x8d>
        panic("sys_page_map error %e", r);
  8010ad:	50                   	push   %eax
  8010ae:	68 0c 26 80 00       	push   $0x80260c
  8010b3:	6a 57                	push   $0x57
  8010b5:	68 e9 25 80 00       	push   $0x8025e9
  8010ba:	e8 4a 0e 00 00       	call   801f09 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	b8 08 40 80 00       	mov    $0x804008,%eax
  8010c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010cc:	50                   	push   %eax
  8010cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d0:	e8 51 fe ff ff       	call   800f26 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010e0:	50                   	push   %eax
  8010e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e4:	e8 3d fe ff ff       	call   800f26 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	6a 02                	push   $0x2
  8010ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f1:	e8 9e fb ff ff       	call   800c94 <sys_env_set_status>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 0d                	js     80110a <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8010fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801100:	89 d8                	mov    %ebx,%eax
  801102:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801105:	5b                   	pop    %ebx
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  80110a:	50                   	push   %eax
  80110b:	68 81 26 80 00       	push   $0x802681
  801110:	68 a0 00 00 00       	push   $0xa0
  801115:	68 e9 25 80 00       	push   $0x8025e9
  80111a:	e8 ea 0d 00 00       	call   801f09 <_panic>

0080111f <sfork>:

// Challenge!
int
sfork(void)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801125:	68 98 26 80 00       	push   $0x802698
  80112a:	68 a9 00 00 00       	push   $0xa9
  80112f:	68 e9 25 80 00       	push   $0x8025e9
  801134:	e8 d0 0d 00 00       	call   801f09 <_panic>

00801139 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	8b 75 08             	mov    0x8(%ebp),%esi
  801141:	8b 45 0c             	mov    0xc(%ebp),%eax
  801144:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801147:	85 c0                	test   %eax,%eax
  801149:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80114e:	0f 44 c2             	cmove  %edx,%eax
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	50                   	push   %eax
  801155:	e8 23 fc ff ff       	call   800d7d <sys_ipc_recv>
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 2b                	js     80118c <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801161:	85 f6                	test   %esi,%esi
  801163:	74 0a                	je     80116f <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801165:	a1 04 40 80 00       	mov    0x804004,%eax
  80116a:	8b 40 74             	mov    0x74(%eax),%eax
  80116d:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  80116f:	85 db                	test   %ebx,%ebx
  801171:	74 0a                	je     80117d <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801173:	a1 04 40 80 00       	mov    0x804004,%eax
  801178:	8b 40 78             	mov    0x78(%eax),%eax
  80117b:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  80117d:	a1 04 40 80 00       	mov    0x804004,%eax
  801182:	8b 40 70             	mov    0x70(%eax),%eax
}
  801185:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    
        *from_env_store = 0;
  80118c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801192:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801198:	eb eb                	jmp    801185 <ipc_recv+0x4c>

0080119a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	57                   	push   %edi
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011a6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  8011ac:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  8011ae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011b3:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  8011b6:	ff 75 14             	pushl  0x14(%ebp)
  8011b9:	53                   	push   %ebx
  8011ba:	56                   	push   %esi
  8011bb:	57                   	push   %edi
  8011bc:	e8 99 fb ff ff       	call   800d5a <sys_ipc_try_send>
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	74 17                	je     8011df <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  8011c8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011cb:	74 e9                	je     8011b6 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  8011cd:	50                   	push   %eax
  8011ce:	68 ae 26 80 00       	push   $0x8026ae
  8011d3:	6a 3e                	push   $0x3e
  8011d5:	68 c0 26 80 00       	push   $0x8026c0
  8011da:	e8 2a 0d 00 00       	call   801f09 <_panic>
        }
    }
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011f5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011fb:	8b 52 50             	mov    0x50(%edx),%edx
  8011fe:	39 ca                	cmp    %ecx,%edx
  801200:	74 11                	je     801213 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801202:	83 c0 01             	add    $0x1,%eax
  801205:	3d 00 04 00 00       	cmp    $0x400,%eax
  80120a:	75 e6                	jne    8011f2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 0b                	jmp    80121e <ipc_find_env+0x37>
			return envs[i].env_id;
  801213:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801216:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80123b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801240:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801252:	89 c2                	mov    %eax,%edx
  801254:	c1 ea 16             	shr    $0x16,%edx
  801257:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80125e:	f6 c2 01             	test   $0x1,%dl
  801261:	74 2a                	je     80128d <fd_alloc+0x46>
  801263:	89 c2                	mov    %eax,%edx
  801265:	c1 ea 0c             	shr    $0xc,%edx
  801268:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 19                	je     80128d <fd_alloc+0x46>
  801274:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801279:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127e:	75 d2                	jne    801252 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801280:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801286:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80128b:	eb 07                	jmp    801294 <fd_alloc+0x4d>
			*fd_store = fd;
  80128d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80129c:	83 f8 1f             	cmp    $0x1f,%eax
  80129f:	77 36                	ja     8012d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012a1:	c1 e0 0c             	shl    $0xc,%eax
  8012a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a9:	89 c2                	mov    %eax,%edx
  8012ab:	c1 ea 16             	shr    $0x16,%edx
  8012ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b5:	f6 c2 01             	test   $0x1,%dl
  8012b8:	74 24                	je     8012de <fd_lookup+0x48>
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	c1 ea 0c             	shr    $0xc,%edx
  8012bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012c6:	f6 c2 01             	test   $0x1,%dl
  8012c9:	74 1a                	je     8012e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    
		return -E_INVAL;
  8012d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012dc:	eb f7                	jmp    8012d5 <fd_lookup+0x3f>
		return -E_INVAL;
  8012de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e3:	eb f0                	jmp    8012d5 <fd_lookup+0x3f>
  8012e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ea:	eb e9                	jmp    8012d5 <fd_lookup+0x3f>

008012ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ec:	55                   	push   %ebp
  8012ed:	89 e5                	mov    %esp,%ebp
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f5:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012fa:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012ff:	39 08                	cmp    %ecx,(%eax)
  801301:	74 33                	je     801336 <dev_lookup+0x4a>
  801303:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801306:	8b 02                	mov    (%edx),%eax
  801308:	85 c0                	test   %eax,%eax
  80130a:	75 f3                	jne    8012ff <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80130c:	a1 04 40 80 00       	mov    0x804004,%eax
  801311:	8b 40 48             	mov    0x48(%eax),%eax
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	51                   	push   %ecx
  801318:	50                   	push   %eax
  801319:	68 cc 26 80 00       	push   $0x8026cc
  80131e:	e8 92 ee ff ff       	call   8001b5 <cprintf>
	*dev = 0;
  801323:	8b 45 0c             	mov    0xc(%ebp),%eax
  801326:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    
			*dev = devtab[i];
  801336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801339:	89 01                	mov    %eax,(%ecx)
			return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	eb f2                	jmp    801334 <dev_lookup+0x48>

00801342 <fd_close>:
{
  801342:	55                   	push   %ebp
  801343:	89 e5                	mov    %esp,%ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 1c             	sub    $0x1c,%esp
  80134b:	8b 75 08             	mov    0x8(%ebp),%esi
  80134e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801351:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801354:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801355:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80135b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135e:	50                   	push   %eax
  80135f:	e8 32 ff ff ff       	call   801296 <fd_lookup>
  801364:	89 c3                	mov    %eax,%ebx
  801366:	83 c4 08             	add    $0x8,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 05                	js     801372 <fd_close+0x30>
	    || fd != fd2)
  80136d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801370:	74 16                	je     801388 <fd_close+0x46>
		return (must_exist ? r : 0);
  801372:	89 f8                	mov    %edi,%eax
  801374:	84 c0                	test   %al,%al
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	0f 44 d8             	cmove  %eax,%ebx
}
  80137e:	89 d8                	mov    %ebx,%eax
  801380:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 36                	pushl  (%esi)
  801391:	e8 56 ff ff ff       	call   8012ec <dev_lookup>
  801396:	89 c3                	mov    %eax,%ebx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 15                	js     8013b4 <fd_close+0x72>
		if (dev->dev_close)
  80139f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013a2:	8b 40 10             	mov    0x10(%eax),%eax
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	74 1b                	je     8013c4 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	56                   	push   %esi
  8013ad:	ff d0                	call   *%eax
  8013af:	89 c3                	mov    %eax,%ebx
  8013b1:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	56                   	push   %esi
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 93 f8 ff ff       	call   800c52 <sys_page_unmap>
	return r;
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb ba                	jmp    80137e <fd_close+0x3c>
			r = 0;
  8013c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c9:	eb e9                	jmp    8013b4 <fd_close+0x72>

008013cb <close>:

int
close(int fdnum)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	e8 b9 fe ff ff       	call   801296 <fd_lookup>
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 10                	js     8013f4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	6a 01                	push   $0x1
  8013e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ec:	e8 51 ff ff ff       	call   801342 <fd_close>
  8013f1:	83 c4 10             	add    $0x10,%esp
}
  8013f4:	c9                   	leave  
  8013f5:	c3                   	ret    

008013f6 <close_all>:

void
close_all(void)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	53                   	push   %ebx
  8013fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	53                   	push   %ebx
  801406:	e8 c0 ff ff ff       	call   8013cb <close>
	for (i = 0; i < MAXFD; i++)
  80140b:	83 c3 01             	add    $0x1,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	83 fb 20             	cmp    $0x20,%ebx
  801414:	75 ec                	jne    801402 <close_all+0xc>
}
  801416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	57                   	push   %edi
  80141f:	56                   	push   %esi
  801420:	53                   	push   %ebx
  801421:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801424:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	ff 75 08             	pushl  0x8(%ebp)
  80142b:	e8 66 fe ff ff       	call   801296 <fd_lookup>
  801430:	89 c3                	mov    %eax,%ebx
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	0f 88 81 00 00 00    	js     8014be <dup+0xa3>
		return r;
	close(newfdnum);
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	ff 75 0c             	pushl  0xc(%ebp)
  801443:	e8 83 ff ff ff       	call   8013cb <close>

	newfd = INDEX2FD(newfdnum);
  801448:	8b 75 0c             	mov    0xc(%ebp),%esi
  80144b:	c1 e6 0c             	shl    $0xc,%esi
  80144e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801454:	83 c4 04             	add    $0x4,%esp
  801457:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145a:	e8 d1 fd ff ff       	call   801230 <fd2data>
  80145f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801461:	89 34 24             	mov    %esi,(%esp)
  801464:	e8 c7 fd ff ff       	call   801230 <fd2data>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80146e:	89 d8                	mov    %ebx,%eax
  801470:	c1 e8 16             	shr    $0x16,%eax
  801473:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147a:	a8 01                	test   $0x1,%al
  80147c:	74 11                	je     80148f <dup+0x74>
  80147e:	89 d8                	mov    %ebx,%eax
  801480:	c1 e8 0c             	shr    $0xc,%eax
  801483:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	75 39                	jne    8014c8 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801492:	89 d0                	mov    %edx,%eax
  801494:	c1 e8 0c             	shr    $0xc,%eax
  801497:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a6:	50                   	push   %eax
  8014a7:	56                   	push   %esi
  8014a8:	6a 00                	push   $0x0
  8014aa:	52                   	push   %edx
  8014ab:	6a 00                	push   $0x0
  8014ad:	e8 5e f7 ff ff       	call   800c10 <sys_page_map>
  8014b2:	89 c3                	mov    %eax,%ebx
  8014b4:	83 c4 20             	add    $0x20,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 31                	js     8014ec <dup+0xd1>
		goto err;

	return newfdnum;
  8014bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014be:	89 d8                	mov    %ebx,%eax
  8014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d7:	50                   	push   %eax
  8014d8:	57                   	push   %edi
  8014d9:	6a 00                	push   $0x0
  8014db:	53                   	push   %ebx
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 2d f7 ff ff       	call   800c10 <sys_page_map>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	83 c4 20             	add    $0x20,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	79 a3                	jns    80148f <dup+0x74>
	sys_page_unmap(0, newfd);
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	56                   	push   %esi
  8014f0:	6a 00                	push   $0x0
  8014f2:	e8 5b f7 ff ff       	call   800c52 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f7:	83 c4 08             	add    $0x8,%esp
  8014fa:	57                   	push   %edi
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 50 f7 ff ff       	call   800c52 <sys_page_unmap>
	return r;
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb b7                	jmp    8014be <dup+0xa3>

00801507 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 14             	sub    $0x14,%esp
  80150e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801511:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	53                   	push   %ebx
  801516:	e8 7b fd ff ff       	call   801296 <fd_lookup>
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 3f                	js     801561 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801528:	50                   	push   %eax
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	ff 30                	pushl  (%eax)
  80152e:	e8 b9 fd ff ff       	call   8012ec <dev_lookup>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	78 27                	js     801561 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80153a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80153d:	8b 42 08             	mov    0x8(%edx),%eax
  801540:	83 e0 03             	and    $0x3,%eax
  801543:	83 f8 01             	cmp    $0x1,%eax
  801546:	74 1e                	je     801566 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	8b 40 08             	mov    0x8(%eax),%eax
  80154e:	85 c0                	test   %eax,%eax
  801550:	74 35                	je     801587 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801552:	83 ec 04             	sub    $0x4,%esp
  801555:	ff 75 10             	pushl  0x10(%ebp)
  801558:	ff 75 0c             	pushl  0xc(%ebp)
  80155b:	52                   	push   %edx
  80155c:	ff d0                	call   *%eax
  80155e:	83 c4 10             	add    $0x10,%esp
}
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801566:	a1 04 40 80 00       	mov    0x804004,%eax
  80156b:	8b 40 48             	mov    0x48(%eax),%eax
  80156e:	83 ec 04             	sub    $0x4,%esp
  801571:	53                   	push   %ebx
  801572:	50                   	push   %eax
  801573:	68 0d 27 80 00       	push   $0x80270d
  801578:	e8 38 ec ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  80157d:	83 c4 10             	add    $0x10,%esp
  801580:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801585:	eb da                	jmp    801561 <read+0x5a>
		return -E_NOT_SUPP;
  801587:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80158c:	eb d3                	jmp    801561 <read+0x5a>

0080158e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	57                   	push   %edi
  801592:	56                   	push   %esi
  801593:	53                   	push   %ebx
  801594:	83 ec 0c             	sub    $0xc,%esp
  801597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80159a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a2:	39 f3                	cmp    %esi,%ebx
  8015a4:	73 25                	jae    8015cb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	29 d8                	sub    %ebx,%eax
  8015ad:	50                   	push   %eax
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	03 45 0c             	add    0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	57                   	push   %edi
  8015b5:	e8 4d ff ff ff       	call   801507 <read>
		if (m < 0)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 08                	js     8015c9 <readn+0x3b>
			return m;
		if (m == 0)
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 06                	je     8015cb <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8015c5:	01 c3                	add    %eax,%ebx
  8015c7:	eb d9                	jmp    8015a2 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5f                   	pop    %edi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 14             	sub    $0x14,%esp
  8015dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	53                   	push   %ebx
  8015e4:	e8 ad fc ff ff       	call   801296 <fd_lookup>
  8015e9:	83 c4 08             	add    $0x8,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 3a                	js     80162a <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	ff 30                	pushl  (%eax)
  8015fc:	e8 eb fc ff ff       	call   8012ec <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 22                	js     80162a <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160f:	74 1e                	je     80162f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	8b 52 0c             	mov    0xc(%edx),%edx
  801617:	85 d2                	test   %edx,%edx
  801619:	74 35                	je     801650 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	50                   	push   %eax
  801625:	ff d2                	call   *%edx
  801627:	83 c4 10             	add    $0x10,%esp
}
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162f:	a1 04 40 80 00       	mov    0x804004,%eax
  801634:	8b 40 48             	mov    0x48(%eax),%eax
  801637:	83 ec 04             	sub    $0x4,%esp
  80163a:	53                   	push   %ebx
  80163b:	50                   	push   %eax
  80163c:	68 29 27 80 00       	push   $0x802729
  801641:	e8 6f eb ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164e:	eb da                	jmp    80162a <write+0x55>
		return -E_NOT_SUPP;
  801650:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801655:	eb d3                	jmp    80162a <write+0x55>

00801657 <seek>:

int
seek(int fdnum, off_t offset)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	ff 75 08             	pushl  0x8(%ebp)
  801664:	e8 2d fc ff ff       	call   801296 <fd_lookup>
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 0e                	js     80167e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801670:	8b 55 0c             	mov    0xc(%ebp),%edx
  801673:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801676:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	53                   	push   %ebx
  801684:	83 ec 14             	sub    $0x14,%esp
  801687:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	53                   	push   %ebx
  80168f:	e8 02 fc ff ff       	call   801296 <fd_lookup>
  801694:	83 c4 08             	add    $0x8,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 37                	js     8016d2 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 40 fc ff ff       	call   8012ec <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 1f                	js     8016d2 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ba:	74 1b                	je     8016d7 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bf:	8b 52 18             	mov    0x18(%edx),%edx
  8016c2:	85 d2                	test   %edx,%edx
  8016c4:	74 32                	je     8016f8 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	ff 75 0c             	pushl  0xc(%ebp)
  8016cc:	50                   	push   %eax
  8016cd:	ff d2                	call   *%edx
  8016cf:	83 c4 10             	add    $0x10,%esp
}
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016d7:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016dc:	8b 40 48             	mov    0x48(%eax),%eax
  8016df:	83 ec 04             	sub    $0x4,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	50                   	push   %eax
  8016e4:	68 ec 26 80 00       	push   $0x8026ec
  8016e9:	e8 c7 ea ff ff       	call   8001b5 <cprintf>
		return -E_INVAL;
  8016ee:	83 c4 10             	add    $0x10,%esp
  8016f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f6:	eb da                	jmp    8016d2 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fd:	eb d3                	jmp    8016d2 <ftruncate+0x52>

008016ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	83 ec 14             	sub    $0x14,%esp
  801706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801709:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	ff 75 08             	pushl  0x8(%ebp)
  801710:	e8 81 fb ff ff       	call   801296 <fd_lookup>
  801715:	83 c4 08             	add    $0x8,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 4b                	js     801767 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801722:	50                   	push   %eax
  801723:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801726:	ff 30                	pushl  (%eax)
  801728:	e8 bf fb ff ff       	call   8012ec <dev_lookup>
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	85 c0                	test   %eax,%eax
  801732:	78 33                	js     801767 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801737:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80173b:	74 2f                	je     80176c <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80173d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801740:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801747:	00 00 00 
	stat->st_isdir = 0;
  80174a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801751:	00 00 00 
	stat->st_dev = dev;
  801754:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	53                   	push   %ebx
  80175e:	ff 75 f0             	pushl  -0x10(%ebp)
  801761:	ff 50 14             	call   *0x14(%eax)
  801764:	83 c4 10             	add    $0x10,%esp
}
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    
		return -E_NOT_SUPP;
  80176c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801771:	eb f4                	jmp    801767 <fstat+0x68>

00801773 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
  801776:	56                   	push   %esi
  801777:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801778:	83 ec 08             	sub    $0x8,%esp
  80177b:	6a 00                	push   $0x0
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 e7 01 00 00       	call   80196c <open>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 1b                	js     8017a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	ff 75 0c             	pushl  0xc(%ebp)
  801794:	50                   	push   %eax
  801795:	e8 65 ff ff ff       	call   8016ff <fstat>
  80179a:	89 c6                	mov    %eax,%esi
	close(fd);
  80179c:	89 1c 24             	mov    %ebx,(%esp)
  80179f:	e8 27 fc ff ff       	call   8013cb <close>
	return r;
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	89 f3                	mov    %esi,%ebx
}
  8017a9:	89 d8                	mov    %ebx,%eax
  8017ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5e                   	pop    %esi
  8017b0:	5d                   	pop    %ebp
  8017b1:	c3                   	ret    

008017b2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	56                   	push   %esi
  8017b6:	53                   	push   %ebx
  8017b7:	89 c6                	mov    %eax,%esi
  8017b9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017bb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017c2:	74 27                	je     8017eb <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c4:	6a 07                	push   $0x7
  8017c6:	68 00 50 80 00       	push   $0x805000
  8017cb:	56                   	push   %esi
  8017cc:	ff 35 00 40 80 00    	pushl  0x804000
  8017d2:	e8 c3 f9 ff ff       	call   80119a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d7:	83 c4 0c             	add    $0xc,%esp
  8017da:	6a 00                	push   $0x0
  8017dc:	53                   	push   %ebx
  8017dd:	6a 00                	push   $0x0
  8017df:	e8 55 f9 ff ff       	call   801139 <ipc_recv>
}
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	6a 01                	push   $0x1
  8017f0:	e8 f2 f9 ff ff       	call   8011e7 <ipc_find_env>
  8017f5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	eb c5                	jmp    8017c4 <fsipc+0x12>

008017ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801810:	8b 45 0c             	mov    0xc(%ebp),%eax
  801813:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	b8 02 00 00 00       	mov    $0x2,%eax
  801822:	e8 8b ff ff ff       	call   8017b2 <fsipc>
}
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <devfile_flush>:
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	8b 40 0c             	mov    0xc(%eax),%eax
  801835:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80183a:	ba 00 00 00 00       	mov    $0x0,%edx
  80183f:	b8 06 00 00 00       	mov    $0x6,%eax
  801844:	e8 69 ff ff ff       	call   8017b2 <fsipc>
}
  801849:	c9                   	leave  
  80184a:	c3                   	ret    

0080184b <devfile_stat>:
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	8b 40 0c             	mov    0xc(%eax),%eax
  80185b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	b8 05 00 00 00       	mov    $0x5,%eax
  80186a:	e8 43 ff ff ff       	call   8017b2 <fsipc>
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 2c                	js     80189f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	68 00 50 80 00       	push   $0x805000
  80187b:	53                   	push   %ebx
  80187c:	e8 53 ef ff ff       	call   8007d4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801881:	a1 80 50 80 00       	mov    0x805080,%eax
  801886:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80188c:	a1 84 50 80 00       	mov    0x805084,%eax
  801891:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <devfile_write>:
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8018ad:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018b2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018b7:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8018bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c0:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8018c6:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8018cb:	50                   	push   %eax
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	68 08 50 80 00       	push   $0x805008
  8018d4:	e8 89 f0 ff ff       	call   800962 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018de:	b8 04 00 00 00       	mov    $0x4,%eax
  8018e3:	e8 ca fe ff ff       	call   8017b2 <fsipc>
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <devfile_read>:
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801903:	ba 00 00 00 00       	mov    $0x0,%edx
  801908:	b8 03 00 00 00       	mov    $0x3,%eax
  80190d:	e8 a0 fe ff ff       	call   8017b2 <fsipc>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	85 c0                	test   %eax,%eax
  801916:	78 1f                	js     801937 <devfile_read+0x4d>
	assert(r <= n);
  801918:	39 f0                	cmp    %esi,%eax
  80191a:	77 24                	ja     801940 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80191c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801921:	7f 33                	jg     801956 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	50                   	push   %eax
  801927:	68 00 50 80 00       	push   $0x805000
  80192c:	ff 75 0c             	pushl  0xc(%ebp)
  80192f:	e8 2e f0 ff ff       	call   800962 <memmove>
	return r;
  801934:	83 c4 10             	add    $0x10,%esp
}
  801937:	89 d8                	mov    %ebx,%eax
  801939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193c:	5b                   	pop    %ebx
  80193d:	5e                   	pop    %esi
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    
	assert(r <= n);
  801940:	68 58 27 80 00       	push   $0x802758
  801945:	68 5f 27 80 00       	push   $0x80275f
  80194a:	6a 7d                	push   $0x7d
  80194c:	68 74 27 80 00       	push   $0x802774
  801951:	e8 b3 05 00 00       	call   801f09 <_panic>
	assert(r <= PGSIZE);
  801956:	68 7f 27 80 00       	push   $0x80277f
  80195b:	68 5f 27 80 00       	push   $0x80275f
  801960:	6a 7e                	push   $0x7e
  801962:	68 74 27 80 00       	push   $0x802774
  801967:	e8 9d 05 00 00       	call   801f09 <_panic>

0080196c <open>:
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	83 ec 1c             	sub    $0x1c,%esp
  801974:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801977:	56                   	push   %esi
  801978:	e8 20 ee ff ff       	call   80079d <strlen>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801985:	0f 8f 96 00 00 00    	jg     801a21 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	e8 b0 f8 ff ff       	call   801247 <fd_alloc>
  801997:	89 c3                	mov    %eax,%ebx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 66                	js     801a06 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	56                   	push   %esi
  8019a4:	68 00 50 80 00       	push   $0x805000
  8019a9:	e8 26 ee ff ff       	call   8007d4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019be:	e8 ef fd ff ff       	call   8017b2 <fsipc>
  8019c3:	89 c3                	mov    %eax,%ebx
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 43                	js     801a0f <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  8019cc:	83 ec 0c             	sub    $0xc,%esp
  8019cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d2:	e8 49 f8 ff ff       	call   801220 <fd2num>
  8019d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019da:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  8019e0:	8b 49 48             	mov    0x48(%ecx),%ecx
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	50                   	push   %eax
  8019e7:	52                   	push   %edx
  8019e8:	ff 32                	pushl  (%edx)
  8019ea:	56                   	push   %esi
  8019eb:	51                   	push   %ecx
  8019ec:	68 8c 27 80 00       	push   $0x80278c
  8019f1:	e8 bf e7 ff ff       	call   8001b5 <cprintf>
	return fd2num(fd);
  8019f6:	83 c4 14             	add    $0x14,%esp
  8019f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fc:	e8 1f f8 ff ff       	call   801220 <fd2num>
  801a01:	89 c3                	mov    %eax,%ebx
  801a03:	83 c4 10             	add    $0x10,%esp
}
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    
		fd_close(fd, 0);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	6a 00                	push   $0x0
  801a14:	ff 75 f4             	pushl  -0xc(%ebp)
  801a17:	e8 26 f9 ff ff       	call   801342 <fd_close>
		return r;
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	eb e5                	jmp    801a06 <open+0x9a>
		return -E_BAD_PATH;
  801a21:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a26:	eb de                	jmp    801a06 <open+0x9a>

00801a28 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a33:	b8 08 00 00 00       	mov    $0x8,%eax
  801a38:	e8 75 fd ff ff       	call   8017b2 <fsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	ff 75 08             	pushl  0x8(%ebp)
  801a4d:	e8 de f7 ff ff       	call   801230 <fd2data>
  801a52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	68 cb 27 80 00       	push   $0x8027cb
  801a5c:	53                   	push   %ebx
  801a5d:	e8 72 ed ff ff       	call   8007d4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a62:	8b 46 04             	mov    0x4(%esi),%eax
  801a65:	2b 06                	sub    (%esi),%eax
  801a67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a74:	00 00 00 
	stat->st_dev = &devpipe;
  801a77:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a7e:	30 80 00 
	return 0;
}
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
  801a86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5d                   	pop    %ebp
  801a8c:	c3                   	ret    

00801a8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	53                   	push   %ebx
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a97:	53                   	push   %ebx
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 b3 f1 ff ff       	call   800c52 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a9f:	89 1c 24             	mov    %ebx,(%esp)
  801aa2:	e8 89 f7 ff ff       	call   801230 <fd2data>
  801aa7:	83 c4 08             	add    $0x8,%esp
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	e8 a0 f1 ff ff       	call   800c52 <sys_page_unmap>
}
  801ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <_pipeisclosed>:
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	83 ec 1c             	sub    $0x1c,%esp
  801ac0:	89 c7                	mov    %eax,%edi
  801ac2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ac4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	57                   	push   %edi
  801ad0:	e8 a0 04 00 00       	call   801f75 <pageref>
  801ad5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ad8:	89 34 24             	mov    %esi,(%esp)
  801adb:	e8 95 04 00 00       	call   801f75 <pageref>
		nn = thisenv->env_runs;
  801ae0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ae6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	39 cb                	cmp    %ecx,%ebx
  801aee:	74 1b                	je     801b0b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801af0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801af3:	75 cf                	jne    801ac4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801af5:	8b 42 58             	mov    0x58(%edx),%eax
  801af8:	6a 01                	push   $0x1
  801afa:	50                   	push   %eax
  801afb:	53                   	push   %ebx
  801afc:	68 d2 27 80 00       	push   $0x8027d2
  801b01:	e8 af e6 ff ff       	call   8001b5 <cprintf>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	eb b9                	jmp    801ac4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b0b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b0e:	0f 94 c0             	sete   %al
  801b11:	0f b6 c0             	movzbl %al,%eax
}
  801b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <devpipe_write>:
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	57                   	push   %edi
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	83 ec 28             	sub    $0x28,%esp
  801b25:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b28:	56                   	push   %esi
  801b29:	e8 02 f7 ff ff       	call   801230 <fd2data>
  801b2e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	bf 00 00 00 00       	mov    $0x0,%edi
  801b38:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b3b:	74 4f                	je     801b8c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b40:	8b 0b                	mov    (%ebx),%ecx
  801b42:	8d 51 20             	lea    0x20(%ecx),%edx
  801b45:	39 d0                	cmp    %edx,%eax
  801b47:	72 14                	jb     801b5d <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b49:	89 da                	mov    %ebx,%edx
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	e8 65 ff ff ff       	call   801ab7 <_pipeisclosed>
  801b52:	85 c0                	test   %eax,%eax
  801b54:	75 3a                	jne    801b90 <devpipe_write+0x74>
			sys_yield();
  801b56:	e8 53 f0 ff ff       	call   800bae <sys_yield>
  801b5b:	eb e0                	jmp    801b3d <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b60:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b64:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b67:	89 c2                	mov    %eax,%edx
  801b69:	c1 fa 1f             	sar    $0x1f,%edx
  801b6c:	89 d1                	mov    %edx,%ecx
  801b6e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b71:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b74:	83 e2 1f             	and    $0x1f,%edx
  801b77:	29 ca                	sub    %ecx,%edx
  801b79:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b7d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b81:	83 c0 01             	add    $0x1,%eax
  801b84:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b87:	83 c7 01             	add    $0x1,%edi
  801b8a:	eb ac                	jmp    801b38 <devpipe_write+0x1c>
	return i;
  801b8c:	89 f8                	mov    %edi,%eax
  801b8e:	eb 05                	jmp    801b95 <devpipe_write+0x79>
				return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5e                   	pop    %esi
  801b9a:	5f                   	pop    %edi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    

00801b9d <devpipe_read>:
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	57                   	push   %edi
  801ba1:	56                   	push   %esi
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 18             	sub    $0x18,%esp
  801ba6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ba9:	57                   	push   %edi
  801baa:	e8 81 f6 ff ff       	call   801230 <fd2data>
  801baf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	be 00 00 00 00       	mov    $0x0,%esi
  801bb9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bbc:	74 47                	je     801c05 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801bbe:	8b 03                	mov    (%ebx),%eax
  801bc0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bc3:	75 22                	jne    801be7 <devpipe_read+0x4a>
			if (i > 0)
  801bc5:	85 f6                	test   %esi,%esi
  801bc7:	75 14                	jne    801bdd <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bc9:	89 da                	mov    %ebx,%edx
  801bcb:	89 f8                	mov    %edi,%eax
  801bcd:	e8 e5 fe ff ff       	call   801ab7 <_pipeisclosed>
  801bd2:	85 c0                	test   %eax,%eax
  801bd4:	75 33                	jne    801c09 <devpipe_read+0x6c>
			sys_yield();
  801bd6:	e8 d3 ef ff ff       	call   800bae <sys_yield>
  801bdb:	eb e1                	jmp    801bbe <devpipe_read+0x21>
				return i;
  801bdd:	89 f0                	mov    %esi,%eax
}
  801bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be7:	99                   	cltd   
  801be8:	c1 ea 1b             	shr    $0x1b,%edx
  801beb:	01 d0                	add    %edx,%eax
  801bed:	83 e0 1f             	and    $0x1f,%eax
  801bf0:	29 d0                	sub    %edx,%eax
  801bf2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bfd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c00:	83 c6 01             	add    $0x1,%esi
  801c03:	eb b4                	jmp    801bb9 <devpipe_read+0x1c>
	return i;
  801c05:	89 f0                	mov    %esi,%eax
  801c07:	eb d6                	jmp    801bdf <devpipe_read+0x42>
				return 0;
  801c09:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0e:	eb cf                	jmp    801bdf <devpipe_read+0x42>

00801c10 <pipe>:
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1b:	50                   	push   %eax
  801c1c:	e8 26 f6 ff ff       	call   801247 <fd_alloc>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 5b                	js     801c85 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	ff 75 f4             	pushl  -0xc(%ebp)
  801c35:	6a 00                	push   $0x0
  801c37:	e8 91 ef ff ff       	call   800bcd <sys_page_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	78 40                	js     801c85 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4b:	50                   	push   %eax
  801c4c:	e8 f6 f5 ff ff       	call   801247 <fd_alloc>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	85 c0                	test   %eax,%eax
  801c58:	78 1b                	js     801c75 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5a:	83 ec 04             	sub    $0x4,%esp
  801c5d:	68 07 04 00 00       	push   $0x407
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	6a 00                	push   $0x0
  801c67:	e8 61 ef ff ff       	call   800bcd <sys_page_alloc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	79 19                	jns    801c8e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c75:	83 ec 08             	sub    $0x8,%esp
  801c78:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 d0 ef ff ff       	call   800c52 <sys_page_unmap>
  801c82:	83 c4 10             	add    $0x10,%esp
}
  801c85:	89 d8                	mov    %ebx,%eax
  801c87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8a:	5b                   	pop    %ebx
  801c8b:	5e                   	pop    %esi
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    
	va = fd2data(fd0);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	ff 75 f4             	pushl  -0xc(%ebp)
  801c94:	e8 97 f5 ff ff       	call   801230 <fd2data>
  801c99:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9b:	83 c4 0c             	add    $0xc,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	50                   	push   %eax
  801ca4:	6a 00                	push   $0x0
  801ca6:	e8 22 ef ff ff       	call   800bcd <sys_page_alloc>
  801cab:	89 c3                	mov    %eax,%ebx
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	0f 88 8c 00 00 00    	js     801d44 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb8:	83 ec 0c             	sub    $0xc,%esp
  801cbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbe:	e8 6d f5 ff ff       	call   801230 <fd2data>
  801cc3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cca:	50                   	push   %eax
  801ccb:	6a 00                	push   $0x0
  801ccd:	56                   	push   %esi
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 3b ef ff ff       	call   800c10 <sys_page_map>
  801cd5:	89 c3                	mov    %eax,%ebx
  801cd7:	83 c4 20             	add    $0x20,%esp
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 58                	js     801d36 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cfc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d08:	83 ec 0c             	sub    $0xc,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	e8 0d f5 ff ff       	call   801220 <fd2num>
  801d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d16:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d18:	83 c4 04             	add    $0x4,%esp
  801d1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1e:	e8 fd f4 ff ff       	call   801220 <fd2num>
  801d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d26:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d31:	e9 4f ff ff ff       	jmp    801c85 <pipe+0x75>
	sys_page_unmap(0, va);
  801d36:	83 ec 08             	sub    $0x8,%esp
  801d39:	56                   	push   %esi
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 11 ef ff ff       	call   800c52 <sys_page_unmap>
  801d41:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 01 ef ff ff       	call   800c52 <sys_page_unmap>
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	e9 1c ff ff ff       	jmp    801c75 <pipe+0x65>

00801d59 <pipeisclosed>:
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d62:	50                   	push   %eax
  801d63:	ff 75 08             	pushl  0x8(%ebp)
  801d66:	e8 2b f5 ff ff       	call   801296 <fd_lookup>
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	78 18                	js     801d8a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d72:	83 ec 0c             	sub    $0xc,%esp
  801d75:	ff 75 f4             	pushl  -0xc(%ebp)
  801d78:	e8 b3 f4 ff ff       	call   801230 <fd2data>
	return _pipeisclosed(fd, p);
  801d7d:	89 c2                	mov    %eax,%edx
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	e8 30 fd ff ff       	call   801ab7 <_pipeisclosed>
  801d87:	83 c4 10             	add    $0x10,%esp
}
  801d8a:	c9                   	leave  
  801d8b:	c3                   	ret    

00801d8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d9c:	68 ea 27 80 00       	push   $0x8027ea
  801da1:	ff 75 0c             	pushl  0xc(%ebp)
  801da4:	e8 2b ea ff ff       	call   8007d4 <strcpy>
	return 0;
}
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <devcons_write>:
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	57                   	push   %edi
  801db4:	56                   	push   %esi
  801db5:	53                   	push   %ebx
  801db6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dbc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dc7:	eb 2f                	jmp    801df8 <devcons_write+0x48>
		m = n - tot;
  801dc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dcc:	29 f3                	sub    %esi,%ebx
  801dce:	83 fb 7f             	cmp    $0x7f,%ebx
  801dd1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dd6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dd9:	83 ec 04             	sub    $0x4,%esp
  801ddc:	53                   	push   %ebx
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	03 45 0c             	add    0xc(%ebp),%eax
  801de2:	50                   	push   %eax
  801de3:	57                   	push   %edi
  801de4:	e8 79 eb ff ff       	call   800962 <memmove>
		sys_cputs(buf, m);
  801de9:	83 c4 08             	add    $0x8,%esp
  801dec:	53                   	push   %ebx
  801ded:	57                   	push   %edi
  801dee:	e8 1e ed ff ff       	call   800b11 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801df3:	01 de                	add    %ebx,%esi
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dfb:	72 cc                	jb     801dc9 <devcons_write+0x19>
}
  801dfd:	89 f0                	mov    %esi,%eax
  801dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5e                   	pop    %esi
  801e04:	5f                   	pop    %edi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <devcons_read>:
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e16:	75 07                	jne    801e1f <devcons_read+0x18>
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    
		sys_yield();
  801e1a:	e8 8f ed ff ff       	call   800bae <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e1f:	e8 0b ed ff ff       	call   800b2f <sys_cgetc>
  801e24:	85 c0                	test   %eax,%eax
  801e26:	74 f2                	je     801e1a <devcons_read+0x13>
	if (c < 0)
  801e28:	85 c0                	test   %eax,%eax
  801e2a:	78 ec                	js     801e18 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e2c:	83 f8 04             	cmp    $0x4,%eax
  801e2f:	74 0c                	je     801e3d <devcons_read+0x36>
	*(char*)vbuf = c;
  801e31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e34:	88 02                	mov    %al,(%edx)
	return 1;
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	eb db                	jmp    801e18 <devcons_read+0x11>
		return 0;
  801e3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e42:	eb d4                	jmp    801e18 <devcons_read+0x11>

00801e44 <cputchar>:
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e50:	6a 01                	push   $0x1
  801e52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e55:	50                   	push   %eax
  801e56:	e8 b6 ec ff ff       	call   800b11 <sys_cputs>
}
  801e5b:	83 c4 10             	add    $0x10,%esp
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <getchar>:
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e66:	6a 01                	push   $0x1
  801e68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6b:	50                   	push   %eax
  801e6c:	6a 00                	push   $0x0
  801e6e:	e8 94 f6 ff ff       	call   801507 <read>
	if (r < 0)
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 08                	js     801e82 <getchar+0x22>
	if (r < 1)
  801e7a:	85 c0                	test   %eax,%eax
  801e7c:	7e 06                	jle    801e84 <getchar+0x24>
	return c;
  801e7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    
		return -E_EOF;
  801e84:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e89:	eb f7                	jmp    801e82 <getchar+0x22>

00801e8b <iscons>:
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e94:	50                   	push   %eax
  801e95:	ff 75 08             	pushl  0x8(%ebp)
  801e98:	e8 f9 f3 ff ff       	call   801296 <fd_lookup>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 11                	js     801eb5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ead:	39 10                	cmp    %edx,(%eax)
  801eaf:	0f 94 c0             	sete   %al
  801eb2:	0f b6 c0             	movzbl %al,%eax
}
  801eb5:	c9                   	leave  
  801eb6:	c3                   	ret    

00801eb7 <opencons>:
{
  801eb7:	55                   	push   %ebp
  801eb8:	89 e5                	mov    %esp,%ebp
  801eba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ebd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ec0:	50                   	push   %eax
  801ec1:	e8 81 f3 ff ff       	call   801247 <fd_alloc>
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	78 3a                	js     801f07 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ecd:	83 ec 04             	sub    $0x4,%esp
  801ed0:	68 07 04 00 00       	push   $0x407
  801ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed8:	6a 00                	push   $0x0
  801eda:	e8 ee ec ff ff       	call   800bcd <sys_page_alloc>
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 21                	js     801f07 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ee6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	50                   	push   %eax
  801eff:	e8 1c f3 ff ff       	call   801220 <fd2num>
  801f04:	83 c4 10             	add    $0x10,%esp
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f11:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f17:	e8 73 ec ff ff       	call   800b8f <sys_getenvid>
  801f1c:	83 ec 0c             	sub    $0xc,%esp
  801f1f:	ff 75 0c             	pushl  0xc(%ebp)
  801f22:	ff 75 08             	pushl  0x8(%ebp)
  801f25:	56                   	push   %esi
  801f26:	50                   	push   %eax
  801f27:	68 f8 27 80 00       	push   $0x8027f8
  801f2c:	e8 84 e2 ff ff       	call   8001b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f31:	83 c4 18             	add    $0x18,%esp
  801f34:	53                   	push   %ebx
  801f35:	ff 75 10             	pushl  0x10(%ebp)
  801f38:	e8 27 e2 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801f3d:	c7 04 24 e3 27 80 00 	movl   $0x8027e3,(%esp)
  801f44:	e8 6c e2 ff ff       	call   8001b5 <cprintf>
  801f49:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f4c:	cc                   	int3   
  801f4d:	eb fd                	jmp    801f4c <_panic+0x43>

00801f4f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f4f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f50:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801f55:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f57:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801f5a:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801f5d:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801f61:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801f65:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801f68:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801f6c:	89 18                	mov    %ebx,(%eax)

    popal
  801f6e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801f6f:	83 c4 04             	add    $0x4,%esp
    popfl
  801f72:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801f73:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801f74:	c3                   	ret    

00801f75 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7b:	89 d0                	mov    %edx,%eax
  801f7d:	c1 e8 16             	shr    $0x16,%eax
  801f80:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801f8c:	f6 c1 01             	test   $0x1,%cl
  801f8f:	74 1d                	je     801fae <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801f91:	c1 ea 0c             	shr    $0xc,%edx
  801f94:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9b:	f6 c2 01             	test   $0x1,%dl
  801f9e:	74 0e                	je     801fae <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa0:	c1 ea 0c             	shr    $0xc,%edx
  801fa3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801faa:	ef 
  801fab:	0f b7 c0             	movzwl %ax,%eax
}
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

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
