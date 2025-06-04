
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 70 0b 00 00       	call   800bb2 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 20 22 80 00       	push   $0x802220
  80004c:	e8 87 01 00 00       	call   8001d8 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 3d 07 00 00       	call   8007c0 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 31 22 80 00       	push   $0x802231
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 fa 06 00 00       	call   8007a6 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 33 0f 00 00       	call   800fe7 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 30 22 80 00       	push   $0x802230
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 bf 0a 00 00       	call   800bb2 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 fe 11 00 00       	call   801332 <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 33 0a 00 00       	call   800b71 <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 04             	sub    $0x4,%esp
  80014a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014d:	8b 13                	mov    (%ebx),%edx
  80014f:	8d 42 01             	lea    0x1(%edx),%eax
  800152:	89 03                	mov    %eax,(%ebx)
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800160:	74 09                	je     80016b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800162:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	68 ff 00 00 00       	push   $0xff
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	50                   	push   %eax
  800177:	e8 b8 09 00 00       	call   800b34 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	eb db                	jmp    800162 <putch+0x1f>

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	pushl  0xc(%ebp)
  8001a7:	ff 75 08             	pushl  0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 43 01 80 00       	push   $0x800143
  8001b6:	e8 1a 01 00 00       	call   8002d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 64 09 00 00       	call   800b34 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	pushl  0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800202:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800205:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800210:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800213:	39 d3                	cmp    %edx,%ebx
  800215:	72 05                	jb     80021c <printnum+0x30>
  800217:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021a:	77 7a                	ja     800296 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	8b 45 14             	mov    0x14(%ebp),%eax
  800225:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800228:	53                   	push   %ebx
  800229:	ff 75 10             	pushl  0x10(%ebp)
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800232:	ff 75 e0             	pushl  -0x20(%ebp)
  800235:	ff 75 dc             	pushl  -0x24(%ebp)
  800238:	ff 75 d8             	pushl  -0x28(%ebp)
  80023b:	e8 a0 1d 00 00       	call   801fe0 <__udivdi3>
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	52                   	push   %edx
  800244:	50                   	push   %eax
  800245:	89 f2                	mov    %esi,%edx
  800247:	89 f8                	mov    %edi,%eax
  800249:	e8 9e ff ff ff       	call   8001ec <printnum>
  80024e:	83 c4 20             	add    $0x20,%esp
  800251:	eb 13                	jmp    800266 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	ff d7                	call   *%edi
  80025c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f ed                	jg     800253 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	83 ec 08             	sub    $0x8,%esp
  800269:	56                   	push   %esi
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800270:	ff 75 e0             	pushl  -0x20(%ebp)
  800273:	ff 75 dc             	pushl  -0x24(%ebp)
  800276:	ff 75 d8             	pushl  -0x28(%ebp)
  800279:	e8 82 1e 00 00       	call   802100 <__umoddi3>
  80027e:	83 c4 14             	add    $0x14,%esp
  800281:	0f be 80 40 22 80 00 	movsbl 0x802240(%eax),%eax
  800288:	50                   	push   %eax
  800289:	ff d7                	call   *%edi
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800299:	eb c4                	jmp    80025f <printnum+0x73>

0080029b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002aa:	73 0a                	jae    8002b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002af:	89 08                	mov    %ecx,(%eax)
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	88 02                	mov    %al,(%edx)
}
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <printfmt>:
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c1:	50                   	push   %eax
  8002c2:	ff 75 10             	pushl  0x10(%ebp)
  8002c5:	ff 75 0c             	pushl  0xc(%ebp)
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 05 00 00 00       	call   8002d5 <vprintfmt>
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <vprintfmt>:
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 2c             	sub    $0x2c,%esp
  8002de:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e7:	e9 c1 03 00 00       	jmp    8006ad <vprintfmt+0x3d8>
		padc = ' ';
  8002ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800305:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 17             	movzbl (%edi),%edx
  800313:	8d 42 dd             	lea    -0x23(%edx),%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 12 04 00 00    	ja     800730 <vprintfmt+0x45b>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 80 23 80 00 	jmp    *0x802380(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80032b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032f:	eb d9                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800334:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800338:	eb d0                	jmp    80030a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 d2             	movzbl %dl,%edx
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800348:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800352:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800355:	83 f9 09             	cmp    $0x9,%ecx
  800358:	77 55                	ja     8003af <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80035a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035d:	eb e9                	jmp    800348 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80035f:	8b 45 14             	mov    0x14(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 40 04             	lea    0x4(%eax),%eax
  80036d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800377:	79 91                	jns    80030a <vprintfmt+0x35>
				width = precision, precision = -1;
  800379:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800386:	eb 82                	jmp    80030a <vprintfmt+0x35>
  800388:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038b:	85 c0                	test   %eax,%eax
  80038d:	ba 00 00 00 00       	mov    $0x0,%edx
  800392:	0f 49 d0             	cmovns %eax,%edx
  800395:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	e9 6a ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003aa:	e9 5b ff ff ff       	jmp    80030a <vprintfmt+0x35>
  8003af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003b5:	eb bc                	jmp    800373 <vprintfmt+0x9e>
			lflag++;
  8003b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bd:	e9 48 ff ff ff       	jmp    80030a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 78 04             	lea    0x4(%eax),%edi
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	53                   	push   %ebx
  8003cc:	ff 30                	pushl  (%eax)
  8003ce:	ff d6                	call   *%esi
			break;
  8003d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003d6:	e9 cf 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 78 04             	lea    0x4(%eax),%edi
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	99                   	cltd   
  8003e4:	31 d0                	xor    %edx,%eax
  8003e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e8:	83 f8 0f             	cmp    $0xf,%eax
  8003eb:	7f 23                	jg     800410 <vprintfmt+0x13b>
  8003ed:	8b 14 85 e0 24 80 00 	mov    0x8024e0(,%eax,4),%edx
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	74 18                	je     800410 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003f8:	52                   	push   %edx
  8003f9:	68 55 27 80 00       	push   $0x802755
  8003fe:	53                   	push   %ebx
  8003ff:	56                   	push   %esi
  800400:	e8 b3 fe ff ff       	call   8002b8 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
  80040b:	e9 9a 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 58 22 80 00       	push   $0x802258
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 9b fe ff ff       	call   8002b8 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 82 02 00 00       	jmp    8006aa <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	83 c0 04             	add    $0x4,%eax
  80042e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800436:	85 ff                	test   %edi,%edi
  800438:	b8 51 22 80 00       	mov    $0x802251,%eax
  80043d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	0f 8e bd 00 00 00    	jle    800507 <vprintfmt+0x232>
  80044a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044e:	75 0e                	jne    80045e <vprintfmt+0x189>
  800450:	89 75 08             	mov    %esi,0x8(%ebp)
  800453:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800456:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800459:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80045c:	eb 6d                	jmp    8004cb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 6e 03 00 00       	call   8007d8 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1ae>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 16                	jmp    8004cb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	75 31                	jne    8004ec <vprintfmt+0x217>
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 0c             	pushl  0xc(%ebp)
  8004c1:	50                   	push   %eax
  8004c2:	ff 55 08             	call   *0x8(%ebp)
  8004c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c8:	83 eb 01             	sub    $0x1,%ebx
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004d2:	0f be c2             	movsbl %dl,%eax
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 59                	je     800532 <vprintfmt+0x25d>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 d8                	js     8004b5 <vprintfmt+0x1e0>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 d3                	jns    8004b5 <vprintfmt+0x1e0>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	eb 37                	jmp    800523 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	0f be d2             	movsbl %dl,%edx
  8004ef:	83 ea 20             	sub    $0x20,%edx
  8004f2:	83 fa 5e             	cmp    $0x5e,%edx
  8004f5:	76 c4                	jbe    8004bb <vprintfmt+0x1e6>
					putch('?', putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 0c             	pushl  0xc(%ebp)
  8004fd:	6a 3f                	push   $0x3f
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	eb c1                	jmp    8004c8 <vprintfmt+0x1f3>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb b6                	jmp    8004cb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	6a 20                	push   $0x20
  80051b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 ff                	test   %edi,%edi
  800525:	7f ee                	jg     800515 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800527:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	e9 78 01 00 00       	jmp    8006aa <vprintfmt+0x3d5>
  800532:	89 df                	mov    %ebx,%edi
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	eb e7                	jmp    800523 <vprintfmt+0x24e>
	if (lflag >= 2)
  80053c:	83 f9 01             	cmp    $0x1,%ecx
  80053f:	7e 3f                	jle    800580 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8b 50 04             	mov    0x4(%eax),%edx
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 08             	lea    0x8(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800558:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055c:	79 5c                	jns    8005ba <vprintfmt+0x2e5>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 10 01 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800580:	85 c9                	test   %ecx,%ecx
  800582:	75 1b                	jne    80059f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb b9                	jmp    800558 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 c1                	mov    %eax,%ecx
  8005a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 40 04             	lea    0x4(%eax),%eax
  8005b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b8:	eb 9e                	jmp    800558 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 c6 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ca:	83 f9 01             	cmp    $0x1,%ecx
  8005cd:	7e 18                	jle    8005e7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d7:	8d 40 08             	lea    0x8(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e2:	e9 a9 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	75 1a                	jne    800605 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800600:	e9 8b 00 00 00       	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060f:	8d 40 04             	lea    0x4(%eax),%eax
  800612:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061a:	eb 74                	jmp    800690 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7e 15                	jle    800636 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	8b 48 04             	mov    0x4(%eax),%ecx
  800629:	8d 40 08             	lea    0x8(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
  800634:	eb 5a                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  800636:	85 c9                	test   %ecx,%ecx
  800638:	75 17                	jne    800651 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
  80064f:	eb 3f                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800661:	b8 08 00 00 00       	mov    $0x8,%eax
  800666:	eb 28                	jmp    800690 <vprintfmt+0x3bb>
			putch('0', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 30                	push   $0x30
  80066e:	ff d6                	call   *%esi
			putch('x', putdat);
  800670:	83 c4 08             	add    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	6a 78                	push   $0x78
  800676:	ff d6                	call   *%esi
			num = (unsigned long long)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800690:	83 ec 0c             	sub    $0xc,%esp
  800693:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800697:	57                   	push   %edi
  800698:	ff 75 e0             	pushl  -0x20(%ebp)
  80069b:	50                   	push   %eax
  80069c:	51                   	push   %ecx
  80069d:	52                   	push   %edx
  80069e:	89 da                	mov    %ebx,%edx
  8006a0:	89 f0                	mov    %esi,%eax
  8006a2:	e8 45 fb ff ff       	call   8001ec <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ad:	83 c7 01             	add    $0x1,%edi
  8006b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006b4:	83 f8 25             	cmp    $0x25,%eax
  8006b7:	0f 84 2f fc ff ff    	je     8002ec <vprintfmt+0x17>
			if (ch == '\0')
  8006bd:	85 c0                	test   %eax,%eax
  8006bf:	0f 84 8b 00 00 00    	je     800750 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	50                   	push   %eax
  8006ca:	ff d6                	call   *%esi
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb dc                	jmp    8006ad <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e9:	eb a5                	jmp    800690 <vprintfmt+0x3bb>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	75 17                	jne    800706 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800704:	eb 8a                	jmp    800690 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	e9 70 ff ff ff       	jmp    800690 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			break;
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	e9 7a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	89 f8                	mov    %edi,%eax
  80073d:	eb 03                	jmp    800742 <vprintfmt+0x46d>
  80073f:	83 e8 01             	sub    $0x1,%eax
  800742:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800746:	75 f7                	jne    80073f <vprintfmt+0x46a>
  800748:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80074b:	e9 5a ff ff ff       	jmp    8006aa <vprintfmt+0x3d5>
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	83 ec 18             	sub    $0x18,%esp
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800764:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800767:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800775:	85 c0                	test   %eax,%eax
  800777:	74 26                	je     80079f <vsnprintf+0x47>
  800779:	85 d2                	test   %edx,%edx
  80077b:	7e 22                	jle    80079f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077d:	ff 75 14             	pushl  0x14(%ebp)
  800780:	ff 75 10             	pushl  0x10(%ebp)
  800783:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	68 9b 02 80 00       	push   $0x80029b
  80078c:	e8 44 fb ff ff       	call   8002d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800794:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	83 c4 10             	add    $0x10,%esp
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb f7                	jmp    80079d <vsnprintf+0x45>

008007a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007af:	50                   	push   %eax
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 9a ff ff ff       	call   800758 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e6:	eb 03                	jmp    8007eb <strnlen+0x13>
		n++;
  8007e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1d>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f3                	jne    8007e8 <strnlen+0x10>
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	89 c2                	mov    %eax,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800810:	84 db                	test   %bl,%bl
  800812:	75 ef                	jne    800803 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800814:	5b                   	pop    %ebx
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	53                   	push   %ebx
  80081f:	e8 9c ff ff ff       	call   8007c0 <strlen>
  800824:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800827:	ff 75 0c             	pushl  0xc(%ebp)
  80082a:	01 d8                	add    %ebx,%eax
  80082c:	50                   	push   %eax
  80082d:	e8 c5 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800832:	89 d8                	mov    %ebx,%eax
  800834:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800837:	c9                   	leave  
  800838:	c3                   	ret    

00800839 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	8b 75 08             	mov    0x8(%ebp),%esi
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800844:	89 f3                	mov    %esi,%ebx
  800846:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	89 f2                	mov    %esi,%edx
  80084b:	eb 0f                	jmp    80085c <strncpy+0x23>
		*dst++ = *src;
  80084d:	83 c2 01             	add    $0x1,%edx
  800850:	0f b6 01             	movzbl (%ecx),%eax
  800853:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800856:	80 39 01             	cmpb   $0x1,(%ecx)
  800859:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80085c:	39 da                	cmp    %ebx,%edx
  80085e:	75 ed                	jne    80084d <strncpy+0x14>
	}
	return ret;
}
  800860:	89 f0                	mov    %esi,%eax
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 75 08             	mov    0x8(%ebp),%esi
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800874:	89 f0                	mov    %esi,%eax
  800876:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 c9                	test   %ecx,%ecx
  80087c:	75 0b                	jne    800889 <strlcpy+0x23>
  80087e:	eb 17                	jmp    800897 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 07                	je     800894 <strlcpy+0x2e>
  80088d:	0f b6 0a             	movzbl (%edx),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	75 ec                	jne    800880 <strlcpy+0x1a>
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 16                	je     8008f4 <strncmp+0x31>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f9:	eb f6                	jmp    8008f1 <strncmp+0x2e>

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	74 09                	je     800915 <strchr+0x1a>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0a                	je     80091a <strchr+0x1f>
	for (; *s; s++)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	eb f0                	jmp    800905 <strchr+0xa>
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 13                	je     80095b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 05                	jne    800955 <memset+0x1d>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	74 0d                	je     800962 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	fc                   	cld    
  800959:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095b:	89 f8                	mov    %edi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5f                   	pop    %edi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    
		c &= 0xFF;
  800962:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800966:	89 d3                	mov    %edx,%ebx
  800968:	c1 e3 08             	shl    $0x8,%ebx
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 18             	shl    $0x18,%eax
  800970:	89 d6                	mov    %edx,%esi
  800972:	c1 e6 10             	shl    $0x10,%esi
  800975:	09 f0                	or     %esi,%eax
  800977:	09 c2                	or     %eax,%edx
  800979:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80097b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80097e:	89 d0                	mov    %edx,%eax
  800980:	fc                   	cld    
  800981:	f3 ab                	rep stos %eax,%es:(%edi)
  800983:	eb d6                	jmp    80095b <memset+0x23>

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 c2                	cmp    %eax,%edx
  80099c:	76 2e                	jbe    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	74 0c                	je     8009b9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 21                	jmp    8009da <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 ef                	jne    8009ad <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb ea                	jmp    8009b6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	74 09                	je     8009de <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 f2                	jne    8009d5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009eb:	eb ed                	jmp    8009da <memmove+0x55>

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	74 1c                	je     800a30 <memcmp+0x30>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	75 08                	jne    800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	83 c2 01             	add    $0x1,%edx
  800a24:	eb ea                	jmp    800a10 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c1             	movzbl %cl,%eax
  800a29:	0f b6 db             	movzbl %bl,%ebx
  800a2c:	29 d8                	sub    %ebx,%eax
  800a2e:	eb 05                	jmp    800a35 <memcmp+0x35>
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	39 d0                	cmp    %edx,%eax
  800a49:	73 09                	jae    800a54 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4b:	38 08                	cmp    %cl,(%eax)
  800a4d:	74 05                	je     800a54 <memfind+0x1b>
	for (; s < ends; s++)
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f3                	jmp    800a47 <memfind+0xe>
			break;
	return (void *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a62:	eb 03                	jmp    800a67 <strtol+0x11>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a67:	0f b6 01             	movzbl (%ecx),%eax
  800a6a:	3c 20                	cmp    $0x20,%al
  800a6c:	74 f6                	je     800a64 <strtol+0xe>
  800a6e:	3c 09                	cmp    $0x9,%al
  800a70:	74 f2                	je     800a64 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a72:	3c 2b                	cmp    $0x2b,%al
  800a74:	74 2e                	je     800aa4 <strtol+0x4e>
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7b:	3c 2d                	cmp    $0x2d,%al
  800a7d:	74 2f                	je     800aae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a85:	75 05                	jne    800a8c <strtol+0x36>
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	74 2c                	je     800ab8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	75 0a                	jne    800a9a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a90:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	74 28                	je     800ac2 <strtol+0x6c>
		base = 10;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa2:	eb 50                	jmp    800af4 <strtol+0x9e>
		s++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800aac:	eb d1                	jmp    800a7f <strtol+0x29>
		s++, neg = 1;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab6:	eb c7                	jmp    800a7f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	74 0e                	je     800acc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	75 d8                	jne    800a9a <strtol+0x44>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aca:	eb ce                	jmp    800a9a <strtol+0x44>
		s += 2, base = 16;
  800acc:	83 c1 02             	add    $0x2,%ecx
  800acf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad4:	eb c4                	jmp    800a9a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 29                	ja     800b09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae9:	7d 30                	jge    800b1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af4:	0f b6 11             	movzbl (%ecx),%edx
  800af7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 09             	cmp    $0x9,%bl
  800aff:	77 d5                	ja     800ad6 <strtol+0x80>
			dig = *s - '0';
  800b01:	0f be d2             	movsbl %dl,%edx
  800b04:	83 ea 30             	sub    $0x30,%edx
  800b07:	eb dd                	jmp    800ae6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 08                	ja     800b1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b13:	0f be d2             	movsbl %dl,%edx
  800b16:	83 ea 37             	sub    $0x37,%edx
  800b19:	eb cb                	jmp    800ae6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 05                	je     800b26 <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b26:	89 c2                	mov    %eax,%edx
  800b28:	f7 da                	neg    %edx
  800b2a:	85 ff                	test   %edi,%edi
  800b2c:	0f 45 c2             	cmovne %edx,%eax
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b45:	89 c3                	mov    %eax,%ebx
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b62:	89 d1                	mov    %edx,%ecx
  800b64:	89 d3                	mov    %edx,%ebx
  800b66:	89 d7                	mov    %edx,%edi
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b7a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	b8 03 00 00 00       	mov    $0x3,%eax
  800b87:	89 cb                	mov    %ecx,%ebx
  800b89:	89 cf                	mov    %ecx,%edi
  800b8b:	89 ce                	mov    %ecx,%esi
  800b8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	7f 08                	jg     800b9b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 3f 25 80 00       	push   $0x80253f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 5c 25 80 00       	push   $0x80255c
  800bad:	e8 93 12 00 00       	call   801e45 <_panic>

00800bb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_yield>:

void
sys_yield(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be1:	89 d1                	mov    %edx,%ecx
  800be3:	89 d3                	mov    %edx,%ebx
  800be5:	89 d7                	mov    %edx,%edi
  800be7:	89 d6                	mov    %edx,%esi
  800be9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf9:	be 00 00 00 00       	mov    $0x0,%esi
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	b8 04 00 00 00       	mov    $0x4,%eax
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	89 f7                	mov    %esi,%edi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800c20:	6a 04                	push   $0x4
  800c22:	68 3f 25 80 00       	push   $0x80253f
  800c27:	6a 23                	push   $0x23
  800c29:	68 5c 25 80 00       	push   $0x80255c
  800c2e:	e8 12 12 00 00       	call   801e45 <_panic>

00800c33 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	b8 05 00 00 00       	mov    $0x5,%eax
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800c62:	6a 05                	push   $0x5
  800c64:	68 3f 25 80 00       	push   $0x80253f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 5c 25 80 00       	push   $0x80255c
  800c70:	e8 d0 11 00 00       	call   801e45 <_panic>

00800c75 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800c89:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 3f 25 80 00       	push   $0x80253f
  800cab:	6a 23                	push   $0x23
  800cad:	68 5c 25 80 00       	push   $0x80255c
  800cb2:	e8 8e 11 00 00       	call   801e45 <_panic>

00800cb7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 3f 25 80 00       	push   $0x80253f
  800ced:	6a 23                	push   $0x23
  800cef:	68 5c 25 80 00       	push   $0x80255c
  800cf4:	e8 4c 11 00 00       	call   801e45 <_panic>

00800cf9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800d28:	6a 09                	push   $0x9
  800d2a:	68 3f 25 80 00       	push   $0x80253f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 5c 25 80 00       	push   $0x80255c
  800d36:	e8 0a 11 00 00       	call   801e45 <_panic>

00800d3b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	89 df                	mov    %ebx,%edi
  800d56:	89 de                	mov    %ebx,%esi
  800d58:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7f 08                	jg     800d66 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 3f 25 80 00       	push   $0x80253f
  800d71:	6a 23                	push   $0x23
  800d73:	68 5c 25 80 00       	push   $0x80255c
  800d78:	e8 c8 10 00 00       	call   801e45 <_panic>

00800d7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d83:	8b 55 08             	mov    0x8(%ebp),%edx
  800d86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d99:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7f 08                	jg     800dca <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 3f 25 80 00       	push   $0x80253f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 5c 25 80 00       	push   $0x80255c
  800ddc:	e8 64 10 00 00       	call   801e45 <_panic>

00800de1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	53                   	push   %ebx
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800deb:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800ded:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800df0:	a8 02                	test   $0x2,%al
  800df2:	0f 84 89 00 00 00    	je     800e81 <pgfault+0xa0>
  800df8:	89 da                	mov    %ebx,%edx
  800dfa:	c1 ea 0c             	shr    $0xc,%edx
  800dfd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e04:	f6 c6 08             	test   $0x8,%dh
  800e07:	74 78                	je     800e81 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	6a 07                	push   $0x7
  800e0e:	68 00 f0 7f 00       	push   $0x7ff000
  800e13:	6a 00                	push   $0x0
  800e15:	e8 d6 fd ff ff       	call   800bf0 <sys_page_alloc>
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	0f 88 8b 00 00 00    	js     800eb0 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	68 00 10 00 00       	push   $0x1000
  800e2d:	53                   	push   %ebx
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	e8 4d fb ff ff       	call   800985 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e38:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e3f:	53                   	push   %ebx
  800e40:	6a 00                	push   $0x0
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	6a 00                	push   $0x0
  800e49:	e8 e5 fd ff ff       	call   800c33 <sys_page_map>
  800e4e:	83 c4 20             	add    $0x20,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 6d                	js     800ec2 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	68 00 f0 7f 00       	push   $0x7ff000
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 11 fe ff ff       	call   800c75 <sys_page_unmap>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 69                	js     800ed4 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	53                   	push   %ebx
  800e6f:	68 c8 25 80 00       	push   $0x8025c8
  800e74:	e8 5f f3 ff ff       	call   8001d8 <cprintf>

}
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800e81:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800e87:	8b 4a 48             	mov    0x48(%edx),%ecx
  800e8a:	89 da                	mov    %ebx,%edx
  800e8c:	c1 ea 0c             	shr    $0xc,%edx
  800e8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e96:	51                   	push   %ecx
  800e97:	53                   	push   %ebx
  800e98:	68 00 00 40 ef       	push   $0xef400000
  800e9d:	52                   	push   %edx
  800e9e:	50                   	push   %eax
  800e9f:	68 6c 25 80 00       	push   $0x80256c
  800ea4:	6a 1e                	push   $0x1e
  800ea6:	68 e9 25 80 00       	push   $0x8025e9
  800eab:	e8 95 0f 00 00       	call   801e45 <_panic>
        panic("sys_page_alloc error %e", r);
  800eb0:	50                   	push   %eax
  800eb1:	68 f4 25 80 00       	push   $0x8025f4
  800eb6:	6a 28                	push   $0x28
  800eb8:	68 e9 25 80 00       	push   $0x8025e9
  800ebd:	e8 83 0f 00 00       	call   801e45 <_panic>
        panic("sys_page_map error %e", r);
  800ec2:	50                   	push   %eax
  800ec3:	68 0c 26 80 00       	push   $0x80260c
  800ec8:	6a 2b                	push   $0x2b
  800eca:	68 e9 25 80 00       	push   $0x8025e9
  800ecf:	e8 71 0f 00 00       	call   801e45 <_panic>
        panic("sys_page_unmap error %e", r);
  800ed4:	50                   	push   %eax
  800ed5:	68 22 26 80 00       	push   $0x802622
  800eda:	6a 2d                	push   $0x2d
  800edc:	68 e9 25 80 00       	push   $0x8025e9
  800ee1:	e8 5f 0f 00 00       	call   801e45 <_panic>

00800ee6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eec:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800ef3:	74 23                	je     800f18 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800efd:	a1 04 40 80 00       	mov    0x804004,%eax
  800f02:	8b 40 48             	mov    0x48(%eax),%eax
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	68 8b 1e 80 00       	push   $0x801e8b
  800f0d:	50                   	push   %eax
  800f0e:	e8 28 fe ff ff       	call   800d3b <sys_env_set_pgfault_upcall>
}
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f18:	a1 04 40 80 00       	mov    0x804004,%eax
  800f1d:	8b 40 48             	mov    0x48(%eax),%eax
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	6a 07                	push   $0x7
  800f25:	68 00 f0 bf ee       	push   $0xeebff000
  800f2a:	50                   	push   %eax
  800f2b:	e8 c0 fc ff ff       	call   800bf0 <sys_page_alloc>
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	85 c0                	test   %eax,%eax
  800f35:	79 be                	jns    800ef5 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f37:	50                   	push   %eax
  800f38:	68 3a 26 80 00       	push   $0x80263a
  800f3d:	6a 21                	push   $0x21
  800f3f:	68 4d 26 80 00       	push   $0x80264d
  800f44:	e8 fc 0e 00 00       	call   801e45 <_panic>

00800f49 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	6a 07                	push   $0x7
  800f59:	53                   	push   %ebx
  800f5a:	56                   	push   %esi
  800f5b:	e8 90 fc ff ff       	call   800bf0 <sys_page_alloc>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 4a                	js     800fb1 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	6a 07                	push   $0x7
  800f6c:	68 00 00 40 00       	push   $0x400000
  800f71:	6a 00                	push   $0x0
  800f73:	53                   	push   %ebx
  800f74:	56                   	push   %esi
  800f75:	e8 b9 fc ff ff       	call   800c33 <sys_page_map>
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	78 42                	js     800fc3 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	68 00 10 00 00       	push   $0x1000
  800f89:	53                   	push   %ebx
  800f8a:	68 00 00 40 00       	push   $0x400000
  800f8f:	e8 f1 f9 ff ff       	call   800985 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f94:	83 c4 08             	add    $0x8,%esp
  800f97:	68 00 00 40 00       	push   $0x400000
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 d2 fc ff ff       	call   800c75 <sys_page_unmap>
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 2b                	js     800fd5 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800fb1:	50                   	push   %eax
  800fb2:	68 3a 26 80 00       	push   $0x80263a
  800fb7:	6a 63                	push   $0x63
  800fb9:	68 e9 25 80 00       	push   $0x8025e9
  800fbe:	e8 82 0e 00 00       	call   801e45 <_panic>
        panic("sys_page_map: %e", r);
  800fc3:	50                   	push   %eax
  800fc4:	68 5d 26 80 00       	push   $0x80265d
  800fc9:	6a 65                	push   $0x65
  800fcb:	68 e9 25 80 00       	push   $0x8025e9
  800fd0:	e8 70 0e 00 00       	call   801e45 <_panic>
        panic("sys_page_unmap: %e", r);
  800fd5:	50                   	push   %eax
  800fd6:	68 6e 26 80 00       	push   $0x80266e
  800fdb:	6a 68                	push   $0x68
  800fdd:	68 e9 25 80 00       	push   $0x8025e9
  800fe2:	e8 5e 0e 00 00       	call   801e45 <_panic>

00800fe7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  800ff0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ff5:	8b 40 64             	mov    0x64(%eax),%eax
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	74 1f                	je     80101b <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ffc:	b8 07 00 00 00       	mov    $0x7,%eax
  801001:	cd 30                	int    $0x30
  801003:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801008:	85 c0                	test   %eax,%eax
  80100a:	74 21                	je     80102d <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  80100c:	be 08 40 80 00       	mov    $0x804008,%esi
  801011:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801014:	bb 00 00 00 00       	mov    $0x0,%ebx
  801019:	eb 7b                	jmp    801096 <fork+0xaf>
        set_pgfault_handler(pgfault);
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	68 e1 0d 80 00       	push   $0x800de1
  801023:	e8 be fe ff ff       	call   800ee6 <set_pgfault_handler>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	eb cf                	jmp    800ffc <fork+0x15>
        set_pgfault_handler(pgfault);
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	68 e1 0d 80 00       	push   $0x800de1
  801035:	e8 ac fe ff ff       	call   800ee6 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  80103a:	e8 73 fb ff ff       	call   800bb2 <sys_getenvid>
  80103f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801044:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801047:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80104c:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	e9 ca 00 00 00       	jmp    801123 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801059:	89 d1                	mov    %edx,%ecx
  80105b:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801061:	81 e2 02 08 00 00    	and    $0x802,%edx
  801067:	89 cf                	mov    %ecx,%edi
  801069:	81 cf 00 08 00 00    	or     $0x800,%edi
  80106f:	85 d2                	test   %edx,%edx
  801071:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	51                   	push   %ecx
  801078:	50                   	push   %eax
  801079:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107c:	50                   	push   %eax
  80107d:	6a 00                	push   $0x0
  80107f:	e8 af fb ff ff       	call   800c33 <sys_page_map>
  801084:	83 c4 20             	add    $0x20,%esp
  801087:	85 c0                	test   %eax,%eax
  801089:	78 45                	js     8010d0 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80108b:	83 c3 01             	add    $0x1,%ebx
  80108e:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  801094:	74 4c                	je     8010e2 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801096:	39 de                	cmp    %ebx,%esi
  801098:	74 f1                	je     80108b <fork+0xa4>
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	c1 ea 16             	shr    $0x16,%edx
  8010a4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8010ab:	f6 c2 05             	test   $0x5,%dl
  8010ae:	74 db                	je     80108b <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	c1 ea 0c             	shr    $0xc,%edx
  8010b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8010bc:	f6 c2 04             	test   $0x4,%dl
  8010bf:	74 ca                	je     80108b <fork+0xa4>
    if (perm & PTE_SHARE) {
  8010c1:	f6 c6 04             	test   $0x4,%dh
  8010c4:	74 93                	je     801059 <fork+0x72>
        perm &= ~PTE_COW;
  8010c6:	89 d1                	mov    %edx,%ecx
  8010c8:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8010ce:	eb a4                	jmp    801074 <fork+0x8d>
        panic("sys_page_map error %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 0c 26 80 00       	push   $0x80260c
  8010d6:	6a 57                	push   $0x57
  8010d8:	68 e9 25 80 00       	push   $0x8025e9
  8010dd:	e8 63 0d 00 00       	call   801e45 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	b8 08 40 80 00       	mov    $0x804008,%eax
  8010ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ef:	50                   	push   %eax
  8010f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f3:	e8 51 fe ff ff       	call   800f49 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801103:	50                   	push   %eax
  801104:	ff 75 e4             	pushl  -0x1c(%ebp)
  801107:	e8 3d fe ff ff       	call   800f49 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80110c:	83 c4 08             	add    $0x8,%esp
  80110f:	6a 02                	push   $0x2
  801111:	ff 75 e4             	pushl  -0x1c(%ebp)
  801114:	e8 9e fb ff ff       	call   800cb7 <sys_env_set_status>
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	85 c0                	test   %eax,%eax
  80111e:	78 0d                	js     80112d <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801123:	89 d8                	mov    %ebx,%eax
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  80112d:	50                   	push   %eax
  80112e:	68 81 26 80 00       	push   $0x802681
  801133:	68 a0 00 00 00       	push   $0xa0
  801138:	68 e9 25 80 00       	push   $0x8025e9
  80113d:	e8 03 0d 00 00       	call   801e45 <_panic>

00801142 <sfork>:

// Challenge!
int
sfork(void)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801148:	68 98 26 80 00       	push   $0x802698
  80114d:	68 a9 00 00 00       	push   $0xa9
  801152:	68 e9 25 80 00       	push   $0x8025e9
  801157:	e8 e9 0c 00 00       	call   801e45 <_panic>

0080115c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	05 00 00 00 30       	add    $0x30000000,%eax
  801167:	c1 e8 0c             	shr    $0xc,%eax
}
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801177:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80117c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801189:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80118e:	89 c2                	mov    %eax,%edx
  801190:	c1 ea 16             	shr    $0x16,%edx
  801193:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119a:	f6 c2 01             	test   $0x1,%dl
  80119d:	74 2a                	je     8011c9 <fd_alloc+0x46>
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	c1 ea 0c             	shr    $0xc,%edx
  8011a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ab:	f6 c2 01             	test   $0x1,%dl
  8011ae:	74 19                	je     8011c9 <fd_alloc+0x46>
  8011b0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8011b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ba:	75 d2                	jne    80118e <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8011c7:	eb 07                	jmp    8011d0 <fd_alloc+0x4d>
			*fd_store = fd;
  8011c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d8:	83 f8 1f             	cmp    $0x1f,%eax
  8011db:	77 36                	ja     801213 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011dd:	c1 e0 0c             	shl    $0xc,%eax
  8011e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e5:	89 c2                	mov    %eax,%edx
  8011e7:	c1 ea 16             	shr    $0x16,%edx
  8011ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f1:	f6 c2 01             	test   $0x1,%dl
  8011f4:	74 24                	je     80121a <fd_lookup+0x48>
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	c1 ea 0c             	shr    $0xc,%edx
  8011fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 1a                	je     801221 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120a:	89 02                	mov    %eax,(%edx)
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    
		return -E_INVAL;
  801213:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801218:	eb f7                	jmp    801211 <fd_lookup+0x3f>
		return -E_INVAL;
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121f:	eb f0                	jmp    801211 <fd_lookup+0x3f>
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801226:	eb e9                	jmp    801211 <fd_lookup+0x3f>

00801228 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801231:	ba 2c 27 80 00       	mov    $0x80272c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801236:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80123b:	39 08                	cmp    %ecx,(%eax)
  80123d:	74 33                	je     801272 <dev_lookup+0x4a>
  80123f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801242:	8b 02                	mov    (%edx),%eax
  801244:	85 c0                	test   %eax,%eax
  801246:	75 f3                	jne    80123b <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801248:	a1 04 40 80 00       	mov    0x804004,%eax
  80124d:	8b 40 48             	mov    0x48(%eax),%eax
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	51                   	push   %ecx
  801254:	50                   	push   %eax
  801255:	68 b0 26 80 00       	push   $0x8026b0
  80125a:	e8 79 ef ff ff       	call   8001d8 <cprintf>
	*dev = 0;
  80125f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801262:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    
			*dev = devtab[i];
  801272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801275:	89 01                	mov    %eax,(%ecx)
			return 0;
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	eb f2                	jmp    801270 <dev_lookup+0x48>

0080127e <fd_close>:
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801290:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801291:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801297:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80129a:	50                   	push   %eax
  80129b:	e8 32 ff ff ff       	call   8011d2 <fd_lookup>
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	83 c4 08             	add    $0x8,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 05                	js     8012ae <fd_close+0x30>
	    || fd != fd2)
  8012a9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012ac:	74 16                	je     8012c4 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012ae:	89 f8                	mov    %edi,%eax
  8012b0:	84 c0                	test   %al,%al
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b7:	0f 44 d8             	cmove  %eax,%ebx
}
  8012ba:	89 d8                	mov    %ebx,%eax
  8012bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	ff 36                	pushl  (%esi)
  8012cd:	e8 56 ff ff ff       	call   801228 <dev_lookup>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 15                	js     8012f0 <fd_close+0x72>
		if (dev->dev_close)
  8012db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012de:	8b 40 10             	mov    0x10(%eax),%eax
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	74 1b                	je     801300 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	56                   	push   %esi
  8012e9:	ff d0                	call   *%eax
  8012eb:	89 c3                	mov    %eax,%ebx
  8012ed:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	56                   	push   %esi
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 7a f9 ff ff       	call   800c75 <sys_page_unmap>
	return r;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	eb ba                	jmp    8012ba <fd_close+0x3c>
			r = 0;
  801300:	bb 00 00 00 00       	mov    $0x0,%ebx
  801305:	eb e9                	jmp    8012f0 <fd_close+0x72>

00801307 <close>:

int
close(int fdnum)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 75 08             	pushl  0x8(%ebp)
  801314:	e8 b9 fe ff ff       	call   8011d2 <fd_lookup>
  801319:	83 c4 08             	add    $0x8,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 10                	js     801330 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	6a 01                	push   $0x1
  801325:	ff 75 f4             	pushl  -0xc(%ebp)
  801328:	e8 51 ff ff ff       	call   80127e <fd_close>
  80132d:	83 c4 10             	add    $0x10,%esp
}
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <close_all>:

void
close_all(void)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	53                   	push   %ebx
  801336:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801339:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80133e:	83 ec 0c             	sub    $0xc,%esp
  801341:	53                   	push   %ebx
  801342:	e8 c0 ff ff ff       	call   801307 <close>
	for (i = 0; i < MAXFD; i++)
  801347:	83 c3 01             	add    $0x1,%ebx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	83 fb 20             	cmp    $0x20,%ebx
  801350:	75 ec                	jne    80133e <close_all+0xc>
}
  801352:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	57                   	push   %edi
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801360:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	ff 75 08             	pushl  0x8(%ebp)
  801367:	e8 66 fe ff ff       	call   8011d2 <fd_lookup>
  80136c:	89 c3                	mov    %eax,%ebx
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	0f 88 81 00 00 00    	js     8013fa <dup+0xa3>
		return r;
	close(newfdnum);
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	ff 75 0c             	pushl  0xc(%ebp)
  80137f:	e8 83 ff ff ff       	call   801307 <close>

	newfd = INDEX2FD(newfdnum);
  801384:	8b 75 0c             	mov    0xc(%ebp),%esi
  801387:	c1 e6 0c             	shl    $0xc,%esi
  80138a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801390:	83 c4 04             	add    $0x4,%esp
  801393:	ff 75 e4             	pushl  -0x1c(%ebp)
  801396:	e8 d1 fd ff ff       	call   80116c <fd2data>
  80139b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80139d:	89 34 24             	mov    %esi,(%esp)
  8013a0:	e8 c7 fd ff ff       	call   80116c <fd2data>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013aa:	89 d8                	mov    %ebx,%eax
  8013ac:	c1 e8 16             	shr    $0x16,%eax
  8013af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013b6:	a8 01                	test   $0x1,%al
  8013b8:	74 11                	je     8013cb <dup+0x74>
  8013ba:	89 d8                	mov    %ebx,%eax
  8013bc:	c1 e8 0c             	shr    $0xc,%eax
  8013bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	75 39                	jne    801404 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ce:	89 d0                	mov    %edx,%eax
  8013d0:	c1 e8 0c             	shr    $0xc,%eax
  8013d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e2:	50                   	push   %eax
  8013e3:	56                   	push   %esi
  8013e4:	6a 00                	push   $0x0
  8013e6:	52                   	push   %edx
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 45 f8 ff ff       	call   800c33 <sys_page_map>
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	83 c4 20             	add    $0x20,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 31                	js     801428 <dup+0xd1>
		goto err;

	return newfdnum;
  8013f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013fa:	89 d8                	mov    %ebx,%eax
  8013fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	25 07 0e 00 00       	and    $0xe07,%eax
  801413:	50                   	push   %eax
  801414:	57                   	push   %edi
  801415:	6a 00                	push   $0x0
  801417:	53                   	push   %ebx
  801418:	6a 00                	push   $0x0
  80141a:	e8 14 f8 ff ff       	call   800c33 <sys_page_map>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	83 c4 20             	add    $0x20,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	79 a3                	jns    8013cb <dup+0x74>
	sys_page_unmap(0, newfd);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	56                   	push   %esi
  80142c:	6a 00                	push   $0x0
  80142e:	e8 42 f8 ff ff       	call   800c75 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801433:	83 c4 08             	add    $0x8,%esp
  801436:	57                   	push   %edi
  801437:	6a 00                	push   $0x0
  801439:	e8 37 f8 ff ff       	call   800c75 <sys_page_unmap>
	return r;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	eb b7                	jmp    8013fa <dup+0xa3>

00801443 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 14             	sub    $0x14,%esp
  80144a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	53                   	push   %ebx
  801452:	e8 7b fd ff ff       	call   8011d2 <fd_lookup>
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 3f                	js     80149d <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801468:	ff 30                	pushl  (%eax)
  80146a:	e8 b9 fd ff ff       	call   801228 <dev_lookup>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 27                	js     80149d <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801476:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801479:	8b 42 08             	mov    0x8(%edx),%eax
  80147c:	83 e0 03             	and    $0x3,%eax
  80147f:	83 f8 01             	cmp    $0x1,%eax
  801482:	74 1e                	je     8014a2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801484:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801487:	8b 40 08             	mov    0x8(%eax),%eax
  80148a:	85 c0                	test   %eax,%eax
  80148c:	74 35                	je     8014c3 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	ff 75 10             	pushl  0x10(%ebp)
  801494:	ff 75 0c             	pushl  0xc(%ebp)
  801497:	52                   	push   %edx
  801498:	ff d0                	call   *%eax
  80149a:	83 c4 10             	add    $0x10,%esp
}
  80149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014a7:	8b 40 48             	mov    0x48(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	50                   	push   %eax
  8014af:	68 f1 26 80 00       	push   $0x8026f1
  8014b4:	e8 1f ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c1:	eb da                	jmp    80149d <read+0x5a>
		return -E_NOT_SUPP;
  8014c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c8:	eb d3                	jmp    80149d <read+0x5a>

008014ca <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014de:	39 f3                	cmp    %esi,%ebx
  8014e0:	73 25                	jae    801507 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	89 f0                	mov    %esi,%eax
  8014e7:	29 d8                	sub    %ebx,%eax
  8014e9:	50                   	push   %eax
  8014ea:	89 d8                	mov    %ebx,%eax
  8014ec:	03 45 0c             	add    0xc(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	57                   	push   %edi
  8014f1:	e8 4d ff ff ff       	call   801443 <read>
		if (m < 0)
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 08                	js     801505 <readn+0x3b>
			return m;
		if (m == 0)
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	74 06                	je     801507 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801501:	01 c3                	add    %eax,%ebx
  801503:	eb d9                	jmp    8014de <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801505:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801507:	89 d8                	mov    %ebx,%eax
  801509:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150c:	5b                   	pop    %ebx
  80150d:	5e                   	pop    %esi
  80150e:	5f                   	pop    %edi
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	53                   	push   %ebx
  801515:	83 ec 14             	sub    $0x14,%esp
  801518:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	53                   	push   %ebx
  801520:	e8 ad fc ff ff       	call   8011d2 <fd_lookup>
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 3a                	js     801566 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152c:	83 ec 08             	sub    $0x8,%esp
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801536:	ff 30                	pushl  (%eax)
  801538:	e8 eb fc ff ff       	call   801228 <dev_lookup>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 22                	js     801566 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801547:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80154b:	74 1e                	je     80156b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801550:	8b 52 0c             	mov    0xc(%edx),%edx
  801553:	85 d2                	test   %edx,%edx
  801555:	74 35                	je     80158c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	ff 75 10             	pushl  0x10(%ebp)
  80155d:	ff 75 0c             	pushl  0xc(%ebp)
  801560:	50                   	push   %eax
  801561:	ff d2                	call   *%edx
  801563:	83 c4 10             	add    $0x10,%esp
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80156b:	a1 04 40 80 00       	mov    0x804004,%eax
  801570:	8b 40 48             	mov    0x48(%eax),%eax
  801573:	83 ec 04             	sub    $0x4,%esp
  801576:	53                   	push   %ebx
  801577:	50                   	push   %eax
  801578:	68 0d 27 80 00       	push   $0x80270d
  80157d:	e8 56 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80158a:	eb da                	jmp    801566 <write+0x55>
		return -E_NOT_SUPP;
  80158c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801591:	eb d3                	jmp    801566 <write+0x55>

00801593 <seek>:

int
seek(int fdnum, off_t offset)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801599:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 2d fc ff ff       	call   8011d2 <fd_lookup>
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 0e                	js     8015ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 14             	sub    $0x14,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 02 fc ff ff       	call   8011d2 <fd_lookup>
  8015d0:	83 c4 08             	add    $0x8,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 37                	js     80160e <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 40 fc ff ff       	call   801228 <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 1f                	js     80160e <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f6:	74 1b                	je     801613 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fb:	8b 52 18             	mov    0x18(%edx),%edx
  8015fe:	85 d2                	test   %edx,%edx
  801600:	74 32                	je     801634 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	ff 75 0c             	pushl  0xc(%ebp)
  801608:	50                   	push   %eax
  801609:	ff d2                	call   *%edx
  80160b:	83 c4 10             	add    $0x10,%esp
}
  80160e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801611:	c9                   	leave  
  801612:	c3                   	ret    
			thisenv->env_id, fdnum);
  801613:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801618:	8b 40 48             	mov    0x48(%eax),%eax
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	53                   	push   %ebx
  80161f:	50                   	push   %eax
  801620:	68 d0 26 80 00       	push   $0x8026d0
  801625:	e8 ae eb ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801632:	eb da                	jmp    80160e <ftruncate+0x52>
		return -E_NOT_SUPP;
  801634:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801639:	eb d3                	jmp    80160e <ftruncate+0x52>

0080163b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	53                   	push   %ebx
  80163f:	83 ec 14             	sub    $0x14,%esp
  801642:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	ff 75 08             	pushl  0x8(%ebp)
  80164c:	e8 81 fb ff ff       	call   8011d2 <fd_lookup>
  801651:	83 c4 08             	add    $0x8,%esp
  801654:	85 c0                	test   %eax,%eax
  801656:	78 4b                	js     8016a3 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	ff 30                	pushl  (%eax)
  801664:	e8 bf fb ff ff       	call   801228 <dev_lookup>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 33                	js     8016a3 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801673:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801677:	74 2f                	je     8016a8 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801679:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80167c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801683:	00 00 00 
	stat->st_isdir = 0;
  801686:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80168d:	00 00 00 
	stat->st_dev = dev;
  801690:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	53                   	push   %ebx
  80169a:	ff 75 f0             	pushl  -0x10(%ebp)
  80169d:	ff 50 14             	call   *0x14(%eax)
  8016a0:	83 c4 10             	add    $0x10,%esp
}
  8016a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    
		return -E_NOT_SUPP;
  8016a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016ad:	eb f4                	jmp    8016a3 <fstat+0x68>

008016af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	6a 00                	push   $0x0
  8016b9:	ff 75 08             	pushl  0x8(%ebp)
  8016bc:	e8 e7 01 00 00       	call   8018a8 <open>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 1b                	js     8016e5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	50                   	push   %eax
  8016d1:	e8 65 ff ff ff       	call   80163b <fstat>
  8016d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8016d8:	89 1c 24             	mov    %ebx,(%esp)
  8016db:	e8 27 fc ff ff       	call   801307 <close>
	return r;
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	89 f3                	mov    %esi,%ebx
}
  8016e5:	89 d8                	mov    %ebx,%eax
  8016e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ea:	5b                   	pop    %ebx
  8016eb:	5e                   	pop    %esi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	89 c6                	mov    %eax,%esi
  8016f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016fe:	74 27                	je     801727 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801700:	6a 07                	push   $0x7
  801702:	68 00 50 80 00       	push   $0x805000
  801707:	56                   	push   %esi
  801708:	ff 35 00 40 80 00    	pushl  0x804000
  80170e:	e8 ff 07 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801713:	83 c4 0c             	add    $0xc,%esp
  801716:	6a 00                	push   $0x0
  801718:	53                   	push   %ebx
  801719:	6a 00                	push   $0x0
  80171b:	e8 91 07 00 00       	call   801eb1 <ipc_recv>
}
  801720:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	6a 01                	push   $0x1
  80172c:	e8 2e 08 00 00       	call   801f5f <ipc_find_env>
  801731:	a3 00 40 80 00       	mov    %eax,0x804000
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	eb c5                	jmp    801700 <fsipc+0x12>

0080173b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
  801747:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	b8 02 00 00 00       	mov    $0x2,%eax
  80175e:	e8 8b ff ff ff       	call   8016ee <fsipc>
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <devfile_flush>:
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 06 00 00 00       	mov    $0x6,%eax
  801780:	e8 69 ff ff ff       	call   8016ee <fsipc>
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_stat>:
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a6:	e8 43 ff ff ff       	call   8016ee <fsipc>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 2c                	js     8017db <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	68 00 50 80 00       	push   $0x805000
  8017b7:	53                   	push   %ebx
  8017b8:	e8 3a f0 ff ff       	call   8007f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_write>:
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8017e9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f3:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fc:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801802:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801807:	50                   	push   %eax
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	68 08 50 80 00       	push   $0x805008
  801810:	e8 70 f1 ff ff       	call   800985 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 04 00 00 00       	mov    $0x4,%eax
  80181f:	e8 ca fe ff ff       	call   8016ee <fsipc>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devfile_read>:
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	8b 40 0c             	mov    0xc(%eax),%eax
  801834:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801839:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 03 00 00 00       	mov    $0x3,%eax
  801849:	e8 a0 fe ff ff       	call   8016ee <fsipc>
  80184e:	89 c3                	mov    %eax,%ebx
  801850:	85 c0                	test   %eax,%eax
  801852:	78 1f                	js     801873 <devfile_read+0x4d>
	assert(r <= n);
  801854:	39 f0                	cmp    %esi,%eax
  801856:	77 24                	ja     80187c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801858:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80185d:	7f 33                	jg     801892 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185f:	83 ec 04             	sub    $0x4,%esp
  801862:	50                   	push   %eax
  801863:	68 00 50 80 00       	push   $0x805000
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	e8 15 f1 ff ff       	call   800985 <memmove>
	return r;
  801870:	83 c4 10             	add    $0x10,%esp
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    
	assert(r <= n);
  80187c:	68 3c 27 80 00       	push   $0x80273c
  801881:	68 43 27 80 00       	push   $0x802743
  801886:	6a 7d                	push   $0x7d
  801888:	68 58 27 80 00       	push   $0x802758
  80188d:	e8 b3 05 00 00       	call   801e45 <_panic>
	assert(r <= PGSIZE);
  801892:	68 63 27 80 00       	push   $0x802763
  801897:	68 43 27 80 00       	push   $0x802743
  80189c:	6a 7e                	push   $0x7e
  80189e:	68 58 27 80 00       	push   $0x802758
  8018a3:	e8 9d 05 00 00       	call   801e45 <_panic>

008018a8 <open>:
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	56                   	push   %esi
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 1c             	sub    $0x1c,%esp
  8018b0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018b3:	56                   	push   %esi
  8018b4:	e8 07 ef ff ff       	call   8007c0 <strlen>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c1:	0f 8f 96 00 00 00    	jg     80195d <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	e8 b0 f8 ff ff       	call   801183 <fd_alloc>
  8018d3:	89 c3                	mov    %eax,%ebx
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 66                	js     801942 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	56                   	push   %esi
  8018e0:	68 00 50 80 00       	push   $0x805000
  8018e5:	e8 0d ef ff ff       	call   8007f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ed:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fa:	e8 ef fd ff ff       	call   8016ee <fsipc>
  8018ff:	89 c3                	mov    %eax,%ebx
  801901:	83 c4 10             	add    $0x10,%esp
  801904:	85 c0                	test   %eax,%eax
  801906:	78 43                	js     80194b <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801908:	83 ec 0c             	sub    $0xc,%esp
  80190b:	ff 75 f4             	pushl  -0xc(%ebp)
  80190e:	e8 49 f8 ff ff       	call   80115c <fd2num>
  801913:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801916:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  80191c:	8b 49 48             	mov    0x48(%ecx),%ecx
  80191f:	83 c4 08             	add    $0x8,%esp
  801922:	50                   	push   %eax
  801923:	52                   	push   %edx
  801924:	ff 32                	pushl  (%edx)
  801926:	56                   	push   %esi
  801927:	51                   	push   %ecx
  801928:	68 70 27 80 00       	push   $0x802770
  80192d:	e8 a6 e8 ff ff       	call   8001d8 <cprintf>
	return fd2num(fd);
  801932:	83 c4 14             	add    $0x14,%esp
  801935:	ff 75 f4             	pushl  -0xc(%ebp)
  801938:	e8 1f f8 ff ff       	call   80115c <fd2num>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	83 c4 10             	add    $0x10,%esp
}
  801942:	89 d8                	mov    %ebx,%eax
  801944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    
		fd_close(fd, 0);
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	6a 00                	push   $0x0
  801950:	ff 75 f4             	pushl  -0xc(%ebp)
  801953:	e8 26 f9 ff ff       	call   80127e <fd_close>
		return r;
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	eb e5                	jmp    801942 <open+0x9a>
		return -E_BAD_PATH;
  80195d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801962:	eb de                	jmp    801942 <open+0x9a>

00801964 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	b8 08 00 00 00       	mov    $0x8,%eax
  801974:	e8 75 fd ff ff       	call   8016ee <fsipc>
}
  801979:	c9                   	leave  
  80197a:	c3                   	ret    

0080197b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	56                   	push   %esi
  80197f:	53                   	push   %ebx
  801980:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	ff 75 08             	pushl  0x8(%ebp)
  801989:	e8 de f7 ff ff       	call   80116c <fd2data>
  80198e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	68 af 27 80 00       	push   $0x8027af
  801998:	53                   	push   %ebx
  801999:	e8 59 ee ff ff       	call   8007f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80199e:	8b 46 04             	mov    0x4(%esi),%eax
  8019a1:	2b 06                	sub    (%esi),%eax
  8019a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019b0:	00 00 00 
	stat->st_dev = &devpipe;
  8019b3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019ba:	30 80 00 
	return 0;
}
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c5:	5b                   	pop    %ebx
  8019c6:	5e                   	pop    %esi
  8019c7:	5d                   	pop    %ebp
  8019c8:	c3                   	ret    

008019c9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	53                   	push   %ebx
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019d3:	53                   	push   %ebx
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 9a f2 ff ff       	call   800c75 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019db:	89 1c 24             	mov    %ebx,(%esp)
  8019de:	e8 89 f7 ff ff       	call   80116c <fd2data>
  8019e3:	83 c4 08             	add    $0x8,%esp
  8019e6:	50                   	push   %eax
  8019e7:	6a 00                	push   $0x0
  8019e9:	e8 87 f2 ff ff       	call   800c75 <sys_page_unmap>
}
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <_pipeisclosed>:
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	57                   	push   %edi
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 1c             	sub    $0x1c,%esp
  8019fc:	89 c7                	mov    %eax,%edi
  8019fe:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a00:	a1 04 40 80 00       	mov    0x804004,%eax
  801a05:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a08:	83 ec 0c             	sub    $0xc,%esp
  801a0b:	57                   	push   %edi
  801a0c:	e8 87 05 00 00       	call   801f98 <pageref>
  801a11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a14:	89 34 24             	mov    %esi,(%esp)
  801a17:	e8 7c 05 00 00       	call   801f98 <pageref>
		nn = thisenv->env_runs;
  801a1c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a22:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	39 cb                	cmp    %ecx,%ebx
  801a2a:	74 1b                	je     801a47 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a2c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a2f:	75 cf                	jne    801a00 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a31:	8b 42 58             	mov    0x58(%edx),%eax
  801a34:	6a 01                	push   $0x1
  801a36:	50                   	push   %eax
  801a37:	53                   	push   %ebx
  801a38:	68 b6 27 80 00       	push   $0x8027b6
  801a3d:	e8 96 e7 ff ff       	call   8001d8 <cprintf>
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	eb b9                	jmp    801a00 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a47:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a4a:	0f 94 c0             	sete   %al
  801a4d:	0f b6 c0             	movzbl %al,%eax
}
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <devpipe_write>:
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 28             	sub    $0x28,%esp
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a64:	56                   	push   %esi
  801a65:	e8 02 f7 ff ff       	call   80116c <fd2data>
  801a6a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	bf 00 00 00 00       	mov    $0x0,%edi
  801a74:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a77:	74 4f                	je     801ac8 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a79:	8b 43 04             	mov    0x4(%ebx),%eax
  801a7c:	8b 0b                	mov    (%ebx),%ecx
  801a7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801a81:	39 d0                	cmp    %edx,%eax
  801a83:	72 14                	jb     801a99 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801a85:	89 da                	mov    %ebx,%edx
  801a87:	89 f0                	mov    %esi,%eax
  801a89:	e8 65 ff ff ff       	call   8019f3 <_pipeisclosed>
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	75 3a                	jne    801acc <devpipe_write+0x74>
			sys_yield();
  801a92:	e8 3a f1 ff ff       	call   800bd1 <sys_yield>
  801a97:	eb e0                	jmp    801a79 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a9c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801aa0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aa3:	89 c2                	mov    %eax,%edx
  801aa5:	c1 fa 1f             	sar    $0x1f,%edx
  801aa8:	89 d1                	mov    %edx,%ecx
  801aaa:	c1 e9 1b             	shr    $0x1b,%ecx
  801aad:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ab0:	83 e2 1f             	and    $0x1f,%edx
  801ab3:	29 ca                	sub    %ecx,%edx
  801ab5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801abd:	83 c0 01             	add    $0x1,%eax
  801ac0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ac3:	83 c7 01             	add    $0x1,%edi
  801ac6:	eb ac                	jmp    801a74 <devpipe_write+0x1c>
	return i;
  801ac8:	89 f8                	mov    %edi,%eax
  801aca:	eb 05                	jmp    801ad1 <devpipe_write+0x79>
				return 0;
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5f                   	pop    %edi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <devpipe_read>:
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	57                   	push   %edi
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
  801adf:	83 ec 18             	sub    $0x18,%esp
  801ae2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ae5:	57                   	push   %edi
  801ae6:	e8 81 f6 ff ff       	call   80116c <fd2data>
  801aeb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	be 00 00 00 00       	mov    $0x0,%esi
  801af5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801af8:	74 47                	je     801b41 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801afa:	8b 03                	mov    (%ebx),%eax
  801afc:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aff:	75 22                	jne    801b23 <devpipe_read+0x4a>
			if (i > 0)
  801b01:	85 f6                	test   %esi,%esi
  801b03:	75 14                	jne    801b19 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801b05:	89 da                	mov    %ebx,%edx
  801b07:	89 f8                	mov    %edi,%eax
  801b09:	e8 e5 fe ff ff       	call   8019f3 <_pipeisclosed>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	75 33                	jne    801b45 <devpipe_read+0x6c>
			sys_yield();
  801b12:	e8 ba f0 ff ff       	call   800bd1 <sys_yield>
  801b17:	eb e1                	jmp    801afa <devpipe_read+0x21>
				return i;
  801b19:	89 f0                	mov    %esi,%eax
}
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b23:	99                   	cltd   
  801b24:	c1 ea 1b             	shr    $0x1b,%edx
  801b27:	01 d0                	add    %edx,%eax
  801b29:	83 e0 1f             	and    $0x1f,%eax
  801b2c:	29 d0                	sub    %edx,%eax
  801b2e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b36:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b39:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b3c:	83 c6 01             	add    $0x1,%esi
  801b3f:	eb b4                	jmp    801af5 <devpipe_read+0x1c>
	return i;
  801b41:	89 f0                	mov    %esi,%eax
  801b43:	eb d6                	jmp    801b1b <devpipe_read+0x42>
				return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4a:	eb cf                	jmp    801b1b <devpipe_read+0x42>

00801b4c <pipe>:
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b57:	50                   	push   %eax
  801b58:	e8 26 f6 ff ff       	call   801183 <fd_alloc>
  801b5d:	89 c3                	mov    %eax,%ebx
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 5b                	js     801bc1 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	68 07 04 00 00       	push   $0x407
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	6a 00                	push   $0x0
  801b73:	e8 78 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801b78:	89 c3                	mov    %eax,%ebx
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 40                	js     801bc1 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b87:	50                   	push   %eax
  801b88:	e8 f6 f5 ff ff       	call   801183 <fd_alloc>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 c0                	test   %eax,%eax
  801b94:	78 1b                	js     801bb1 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b96:	83 ec 04             	sub    $0x4,%esp
  801b99:	68 07 04 00 00       	push   $0x407
  801b9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba1:	6a 00                	push   $0x0
  801ba3:	e8 48 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801ba8:	89 c3                	mov    %eax,%ebx
  801baa:	83 c4 10             	add    $0x10,%esp
  801bad:	85 c0                	test   %eax,%eax
  801baf:	79 19                	jns    801bca <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 b7 f0 ff ff       	call   800c75 <sys_page_unmap>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	89 d8                	mov    %ebx,%eax
  801bc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    
	va = fd2data(fd0);
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd0:	e8 97 f5 ff ff       	call   80116c <fd2data>
  801bd5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd7:	83 c4 0c             	add    $0xc,%esp
  801bda:	68 07 04 00 00       	push   $0x407
  801bdf:	50                   	push   %eax
  801be0:	6a 00                	push   $0x0
  801be2:	e8 09 f0 ff ff       	call   800bf0 <sys_page_alloc>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	0f 88 8c 00 00 00    	js     801c80 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf4:	83 ec 0c             	sub    $0xc,%esp
  801bf7:	ff 75 f0             	pushl  -0x10(%ebp)
  801bfa:	e8 6d f5 ff ff       	call   80116c <fd2data>
  801bff:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c06:	50                   	push   %eax
  801c07:	6a 00                	push   $0x0
  801c09:	56                   	push   %esi
  801c0a:	6a 00                	push   $0x0
  801c0c:	e8 22 f0 ff ff       	call   800c33 <sys_page_map>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 20             	add    $0x20,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 58                	js     801c72 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c23:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c38:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c44:	83 ec 0c             	sub    $0xc,%esp
  801c47:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4a:	e8 0d f5 ff ff       	call   80115c <fd2num>
  801c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c52:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c54:	83 c4 04             	add    $0x4,%esp
  801c57:	ff 75 f0             	pushl  -0x10(%ebp)
  801c5a:	e8 fd f4 ff ff       	call   80115c <fd2num>
  801c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c62:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6d:	e9 4f ff ff ff       	jmp    801bc1 <pipe+0x75>
	sys_page_unmap(0, va);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	56                   	push   %esi
  801c76:	6a 00                	push   $0x0
  801c78:	e8 f8 ef ff ff       	call   800c75 <sys_page_unmap>
  801c7d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c80:	83 ec 08             	sub    $0x8,%esp
  801c83:	ff 75 f0             	pushl  -0x10(%ebp)
  801c86:	6a 00                	push   $0x0
  801c88:	e8 e8 ef ff ff       	call   800c75 <sys_page_unmap>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	e9 1c ff ff ff       	jmp    801bb1 <pipe+0x65>

00801c95 <pipeisclosed>:
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	ff 75 08             	pushl  0x8(%ebp)
  801ca2:	e8 2b f5 ff ff       	call   8011d2 <fd_lookup>
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 18                	js     801cc6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cae:	83 ec 0c             	sub    $0xc,%esp
  801cb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb4:	e8 b3 f4 ff ff       	call   80116c <fd2data>
	return _pipeisclosed(fd, p);
  801cb9:	89 c2                	mov    %eax,%edx
  801cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbe:	e8 30 fd ff ff       	call   8019f3 <_pipeisclosed>
  801cc3:	83 c4 10             	add    $0x10,%esp
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd8:	68 ce 27 80 00       	push   $0x8027ce
  801cdd:	ff 75 0c             	pushl  0xc(%ebp)
  801ce0:	e8 12 eb ff ff       	call   8007f7 <strcpy>
	return 0;
}
  801ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <devcons_write>:
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	57                   	push   %edi
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801cf8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801cfd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d03:	eb 2f                	jmp    801d34 <devcons_write+0x48>
		m = n - tot;
  801d05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d08:	29 f3                	sub    %esi,%ebx
  801d0a:	83 fb 7f             	cmp    $0x7f,%ebx
  801d0d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d12:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d15:	83 ec 04             	sub    $0x4,%esp
  801d18:	53                   	push   %ebx
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	03 45 0c             	add    0xc(%ebp),%eax
  801d1e:	50                   	push   %eax
  801d1f:	57                   	push   %edi
  801d20:	e8 60 ec ff ff       	call   800985 <memmove>
		sys_cputs(buf, m);
  801d25:	83 c4 08             	add    $0x8,%esp
  801d28:	53                   	push   %ebx
  801d29:	57                   	push   %edi
  801d2a:	e8 05 ee ff ff       	call   800b34 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d2f:	01 de                	add    %ebx,%esi
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d37:	72 cc                	jb     801d05 <devcons_write+0x19>
}
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <devcons_read>:
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d52:	75 07                	jne    801d5b <devcons_read+0x18>
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    
		sys_yield();
  801d56:	e8 76 ee ff ff       	call   800bd1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d5b:	e8 f2 ed ff ff       	call   800b52 <sys_cgetc>
  801d60:	85 c0                	test   %eax,%eax
  801d62:	74 f2                	je     801d56 <devcons_read+0x13>
	if (c < 0)
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 ec                	js     801d54 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801d68:	83 f8 04             	cmp    $0x4,%eax
  801d6b:	74 0c                	je     801d79 <devcons_read+0x36>
	*(char*)vbuf = c;
  801d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d70:	88 02                	mov    %al,(%edx)
	return 1;
  801d72:	b8 01 00 00 00       	mov    $0x1,%eax
  801d77:	eb db                	jmp    801d54 <devcons_read+0x11>
		return 0;
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	eb d4                	jmp    801d54 <devcons_read+0x11>

00801d80 <cputchar>:
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d86:	8b 45 08             	mov    0x8(%ebp),%eax
  801d89:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d8c:	6a 01                	push   $0x1
  801d8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d91:	50                   	push   %eax
  801d92:	e8 9d ed ff ff       	call   800b34 <sys_cputs>
}
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <getchar>:
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801da2:	6a 01                	push   $0x1
  801da4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da7:	50                   	push   %eax
  801da8:	6a 00                	push   $0x0
  801daa:	e8 94 f6 ff ff       	call   801443 <read>
	if (r < 0)
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 08                	js     801dbe <getchar+0x22>
	if (r < 1)
  801db6:	85 c0                	test   %eax,%eax
  801db8:	7e 06                	jle    801dc0 <getchar+0x24>
	return c;
  801dba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    
		return -E_EOF;
  801dc0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dc5:	eb f7                	jmp    801dbe <getchar+0x22>

00801dc7 <iscons>:
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd0:	50                   	push   %eax
  801dd1:	ff 75 08             	pushl  0x8(%ebp)
  801dd4:	e8 f9 f3 ff ff       	call   8011d2 <fd_lookup>
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 11                	js     801df1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de9:	39 10                	cmp    %edx,(%eax)
  801deb:	0f 94 c0             	sete   %al
  801dee:	0f b6 c0             	movzbl %al,%eax
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <opencons>:
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	e8 81 f3 ff ff       	call   801183 <fd_alloc>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 3a                	js     801e43 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e09:	83 ec 04             	sub    $0x4,%esp
  801e0c:	68 07 04 00 00       	push   $0x407
  801e11:	ff 75 f4             	pushl  -0xc(%ebp)
  801e14:	6a 00                	push   $0x0
  801e16:	e8 d5 ed ff ff       	call   800bf0 <sys_page_alloc>
  801e1b:	83 c4 10             	add    $0x10,%esp
  801e1e:	85 c0                	test   %eax,%eax
  801e20:	78 21                	js     801e43 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e2b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e30:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e37:	83 ec 0c             	sub    $0xc,%esp
  801e3a:	50                   	push   %eax
  801e3b:	e8 1c f3 ff ff       	call   80115c <fd2num>
  801e40:	83 c4 10             	add    $0x10,%esp
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e4a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e4d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e53:	e8 5a ed ff ff       	call   800bb2 <sys_getenvid>
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	ff 75 0c             	pushl  0xc(%ebp)
  801e5e:	ff 75 08             	pushl  0x8(%ebp)
  801e61:	56                   	push   %esi
  801e62:	50                   	push   %eax
  801e63:	68 dc 27 80 00       	push   $0x8027dc
  801e68:	e8 6b e3 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e6d:	83 c4 18             	add    $0x18,%esp
  801e70:	53                   	push   %ebx
  801e71:	ff 75 10             	pushl  0x10(%ebp)
  801e74:	e8 0e e3 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  801e79:	c7 04 24 2f 22 80 00 	movl   $0x80222f,(%esp)
  801e80:	e8 53 e3 ff ff       	call   8001d8 <cprintf>
  801e85:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e88:	cc                   	int3   
  801e89:	eb fd                	jmp    801e88 <_panic+0x43>

00801e8b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e8b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e8c:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801e91:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e93:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801e96:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801e99:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801e9d:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801ea1:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801ea4:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801ea8:	89 18                	mov    %ebx,(%eax)

    popal
  801eaa:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801eab:	83 c4 04             	add    $0x4,%esp
    popfl
  801eae:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801eaf:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801eb0:	c3                   	ret    

00801eb1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ec6:	0f 44 c2             	cmove  %edx,%eax
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	50                   	push   %eax
  801ecd:	e8 ce ee ff ff       	call   800da0 <sys_ipc_recv>
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	85 c0                	test   %eax,%eax
  801ed7:	78 2b                	js     801f04 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801ed9:	85 f6                	test   %esi,%esi
  801edb:	74 0a                	je     801ee7 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801edd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ee2:	8b 40 74             	mov    0x74(%eax),%eax
  801ee5:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801ee7:	85 db                	test   %ebx,%ebx
  801ee9:	74 0a                	je     801ef5 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801eeb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef0:	8b 40 78             	mov    0x78(%eax),%eax
  801ef3:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801ef5:	a1 04 40 80 00       	mov    0x804004,%eax
  801efa:	8b 40 70             	mov    0x70(%eax),%eax
}
  801efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5e                   	pop    %esi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    
        *from_env_store = 0;
  801f04:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801f0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801f10:	eb eb                	jmp    801efd <ipc_recv+0x4c>

00801f12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801f24:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801f26:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f2b:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801f2e:	ff 75 14             	pushl  0x14(%ebp)
  801f31:	53                   	push   %ebx
  801f32:	56                   	push   %esi
  801f33:	57                   	push   %edi
  801f34:	e8 44 ee ff ff       	call   800d7d <sys_ipc_try_send>
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	74 17                	je     801f57 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801f40:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f43:	74 e9                	je     801f2e <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801f45:	50                   	push   %eax
  801f46:	68 00 28 80 00       	push   $0x802800
  801f4b:	6a 3e                	push   $0x3e
  801f4d:	68 12 28 80 00       	push   $0x802812
  801f52:	e8 ee fe ff ff       	call   801e45 <_panic>
        }
    }
}
  801f57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f73:	8b 52 50             	mov    0x50(%edx),%edx
  801f76:	39 ca                	cmp    %ecx,%edx
  801f78:	74 11                	je     801f8b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f7a:	83 c0 01             	add    $0x1,%eax
  801f7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f82:	75 e6                	jne    801f6a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
  801f89:	eb 0b                	jmp    801f96 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f8b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f93:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9e:	89 d0                	mov    %edx,%eax
  801fa0:	c1 e8 16             	shr    $0x16,%eax
  801fa3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801faa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801faf:	f6 c1 01             	test   $0x1,%cl
  801fb2:	74 1d                	je     801fd1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fb4:	c1 ea 0c             	shr    $0xc,%edx
  801fb7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fbe:	f6 c2 01             	test   $0x1,%dl
  801fc1:	74 0e                	je     801fd1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc3:	c1 ea 0c             	shr    $0xc,%edx
  801fc6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fcd:	ef 
  801fce:	0f b7 c0             	movzwl %ax,%eax
}
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    
  801fd3:	66 90                	xchg   %ax,%ax
  801fd5:	66 90                	xchg   %ax,%ax
  801fd7:	66 90                	xchg   %ax,%ax
  801fd9:	66 90                	xchg   %ax,%ax
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

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
