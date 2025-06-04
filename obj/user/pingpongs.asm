
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 21 11 00 00       	call   801162 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 24 11 00 00       	call   80117c <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 40 80 00       	mov    0x804004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 61 0b 00 00       	call   800bd2 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 70 22 80 00       	push   $0x802270
  800080:	e8 73 01 00 00       	call   8001f8 <cprintf>
		if (val == 10)
  800085:	a1 04 40 80 00       	mov    0x804004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a3:	e8 35 11 00 00       	call   8011dd <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c2:	e8 0b 0b 00 00       	call   800bd2 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 40 22 80 00       	push   $0x802240
  8000d1:	e8 22 01 00 00       	call   8001f8 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 f4 0a 00 00       	call   800bd2 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 5a 22 80 00       	push   $0x80225a
  8000e8:	e8 0b 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	e8 e2 10 00 00       	call   8011dd <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 bf 0a 00 00       	call   800bd2 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014f:	e8 e5 12 00 00       	call   801439 <close_all>
	sys_env_destroy(0);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	6a 00                	push   $0x0
  800159:	e8 33 0a 00 00       	call   800b91 <sys_env_destroy>
}
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016d:	8b 13                	mov    (%ebx),%edx
  80016f:	8d 42 01             	lea    0x1(%edx),%eax
  800172:	89 03                	mov    %eax,(%ebx)
  800174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800177:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800180:	74 09                	je     80018b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	68 ff 00 00 00       	push   $0xff
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	e8 b8 09 00 00       	call   800b54 <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb db                	jmp    800182 <putch+0x1f>

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 63 01 80 00       	push   $0x800163
  8001d6:	e8 1a 01 00 00       	call   8002f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 64 09 00 00       	call   800b54 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800222:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800225:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800230:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800233:	39 d3                	cmp    %edx,%ebx
  800235:	72 05                	jb     80023c <printnum+0x30>
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 7a                	ja     8002b6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 45 14             	mov    0x14(%ebp),%eax
  800245:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800252:	ff 75 e0             	pushl  -0x20(%ebp)
  800255:	ff 75 dc             	pushl  -0x24(%ebp)
  800258:	ff 75 d8             	pushl  -0x28(%ebp)
  80025b:	e8 a0 1d 00 00       	call   802000 <__udivdi3>
  800260:	83 c4 18             	add    $0x18,%esp
  800263:	52                   	push   %edx
  800264:	50                   	push   %eax
  800265:	89 f2                	mov    %esi,%edx
  800267:	89 f8                	mov    %edi,%eax
  800269:	e8 9e ff ff ff       	call   80020c <printnum>
  80026e:	83 c4 20             	add    $0x20,%esp
  800271:	eb 13                	jmp    800286 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	56                   	push   %esi
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	ff d7                	call   *%edi
  80027c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027f:	83 eb 01             	sub    $0x1,%ebx
  800282:	85 db                	test   %ebx,%ebx
  800284:	7f ed                	jg     800273 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 82 1e 00 00       	call   802120 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 a0 22 80 00 	movsbl 0x8022a0(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff d7                	call   *%edi
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    
  8002b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b9:	eb c4                	jmp    80027f <printnum+0x73>

008002bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 0a                	jae    8002d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cf:	89 08                	mov    %ecx,(%eax)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	88 02                	mov    %al,(%edx)
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <printfmt>:
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e1:	50                   	push   %eax
  8002e2:	ff 75 10             	pushl  0x10(%ebp)
  8002e5:	ff 75 0c             	pushl  0xc(%ebp)
  8002e8:	ff 75 08             	pushl  0x8(%ebp)
  8002eb:	e8 05 00 00 00       	call   8002f5 <vprintfmt>
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <vprintfmt>:
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
  8002fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800301:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800304:	8b 7d 10             	mov    0x10(%ebp),%edi
  800307:	e9 c1 03 00 00       	jmp    8006cd <vprintfmt+0x3d8>
		padc = ' ';
  80030c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800310:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800317:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 17             	movzbl (%edi),%edx
  800333:	8d 42 dd             	lea    -0x23(%edx),%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 12 04 00 00    	ja     800750 <vprintfmt+0x45b>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80034f:	eb d9                	jmp    80032a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800354:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800358:	eb d0                	jmp    80032a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	0f b6 d2             	movzbl %dl,%edx
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800360:	b8 00 00 00 00       	mov    $0x0,%eax
  800365:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800368:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800372:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800375:	83 f9 09             	cmp    $0x9,%ecx
  800378:	77 55                	ja     8003cf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80037a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037d:	eb e9                	jmp    800368 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 40 04             	lea    0x4(%eax),%eax
  80038d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	79 91                	jns    80032a <vprintfmt+0x35>
				width = precision, precision = -1;
  800399:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a6:	eb 82                	jmp    80032a <vprintfmt+0x35>
  8003a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	0f 49 d0             	cmovns %eax,%edx
  8003b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bb:	e9 6a ff ff ff       	jmp    80032a <vprintfmt+0x35>
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ca:	e9 5b ff ff ff       	jmp    80032a <vprintfmt+0x35>
  8003cf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d5:	eb bc                	jmp    800393 <vprintfmt+0x9e>
			lflag++;
  8003d7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003dd:	e9 48 ff ff ff       	jmp    80032a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 78 04             	lea    0x4(%eax),%edi
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	53                   	push   %ebx
  8003ec:	ff 30                	pushl  (%eax)
  8003ee:	ff d6                	call   *%esi
			break;
  8003f0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f6:	e9 cf 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 78 04             	lea    0x4(%eax),%edi
  800401:	8b 00                	mov    (%eax),%eax
  800403:	99                   	cltd   
  800404:	31 d0                	xor    %edx,%eax
  800406:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800408:	83 f8 0f             	cmp    $0xf,%eax
  80040b:	7f 23                	jg     800430 <vprintfmt+0x13b>
  80040d:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  800414:	85 d2                	test   %edx,%edx
  800416:	74 18                	je     800430 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800418:	52                   	push   %edx
  800419:	68 d1 27 80 00       	push   $0x8027d1
  80041e:	53                   	push   %ebx
  80041f:	56                   	push   %esi
  800420:	e8 b3 fe ff ff       	call   8002d8 <printfmt>
  800425:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800428:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042b:	e9 9a 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 b8 22 80 00       	push   $0x8022b8
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 9b fe ff ff       	call   8002d8 <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800443:	e9 82 02 00 00       	jmp    8006ca <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	83 c0 04             	add    $0x4,%eax
  80044e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800456:	85 ff                	test   %edi,%edi
  800458:	b8 b1 22 80 00       	mov    $0x8022b1,%eax
  80045d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800460:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800464:	0f 8e bd 00 00 00    	jle    800527 <vprintfmt+0x232>
  80046a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046e:	75 0e                	jne    80047e <vprintfmt+0x189>
  800470:	89 75 08             	mov    %esi,0x8(%ebp)
  800473:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800476:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800479:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047c:	eb 6d                	jmp    8004eb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 d0             	pushl  -0x30(%ebp)
  800484:	57                   	push   %edi
  800485:	e8 6e 03 00 00       	call   8007f8 <strnlen>
  80048a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800492:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800495:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	eb 0f                	jmp    8004b2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004aa:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	83 ef 01             	sub    $0x1,%edi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 ff                	test   %edi,%edi
  8004b4:	7f ed                	jg     8004a3 <vprintfmt+0x1ae>
  8004b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bc:	85 c9                	test   %ecx,%ecx
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	0f 49 c1             	cmovns %ecx,%eax
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d1:	89 cb                	mov    %ecx,%ebx
  8004d3:	eb 16                	jmp    8004eb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d9:	75 31                	jne    80050c <vprintfmt+0x217>
					putch(ch, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	ff 75 0c             	pushl  0xc(%ebp)
  8004e1:	50                   	push   %eax
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e8:	83 eb 01             	sub    $0x1,%ebx
  8004eb:	83 c7 01             	add    $0x1,%edi
  8004ee:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004f2:	0f be c2             	movsbl %dl,%eax
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	74 59                	je     800552 <vprintfmt+0x25d>
  8004f9:	85 f6                	test   %esi,%esi
  8004fb:	78 d8                	js     8004d5 <vprintfmt+0x1e0>
  8004fd:	83 ee 01             	sub    $0x1,%esi
  800500:	79 d3                	jns    8004d5 <vprintfmt+0x1e0>
  800502:	89 df                	mov    %ebx,%edi
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	eb 37                	jmp    800543 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80050c:	0f be d2             	movsbl %dl,%edx
  80050f:	83 ea 20             	sub    $0x20,%edx
  800512:	83 fa 5e             	cmp    $0x5e,%edx
  800515:	76 c4                	jbe    8004db <vprintfmt+0x1e6>
					putch('?', putdat);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	6a 3f                	push   $0x3f
  80051f:	ff 55 08             	call   *0x8(%ebp)
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb c1                	jmp    8004e8 <vprintfmt+0x1f3>
  800527:	89 75 08             	mov    %esi,0x8(%ebp)
  80052a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800530:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800533:	eb b6                	jmp    8004eb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 20                	push   $0x20
  80053b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80053d:	83 ef 01             	sub    $0x1,%edi
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	85 ff                	test   %edi,%edi
  800545:	7f ee                	jg     800535 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800547:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	e9 78 01 00 00       	jmp    8006ca <vprintfmt+0x3d5>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	eb e7                	jmp    800543 <vprintfmt+0x24e>
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7e 3f                	jle    8005a0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 50 04             	mov    0x4(%eax),%edx
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 08             	lea    0x8(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057c:	79 5c                	jns    8005da <vprintfmt+0x2e5>
				putch('-', putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	53                   	push   %ebx
  800582:	6a 2d                	push   $0x2d
  800584:	ff d6                	call   *%esi
				num = -(long long) num;
  800586:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800589:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058c:	f7 da                	neg    %edx
  80058e:	83 d1 00             	adc    $0x0,%ecx
  800591:	f7 d9                	neg    %ecx
  800593:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059b:	e9 10 01 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  8005a0:	85 c9                	test   %ecx,%ecx
  8005a2:	75 1b                	jne    8005bf <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bd:	eb b9                	jmp    800578 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 c1                	mov    %eax,%ecx
  8005c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d8:	eb 9e                	jmp    800578 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e5:	e9 c6 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ea:	83 f9 01             	cmp    $0x1,%ecx
  8005ed:	7e 18                	jle    800607 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f7:	8d 40 08             	lea    0x8(%eax),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800602:	e9 a9 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  800607:	85 c9                	test   %ecx,%ecx
  800609:	75 1a                	jne    800625 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800620:	e9 8b 00 00 00       	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062f:	8d 40 04             	lea    0x4(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800635:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063a:	eb 74                	jmp    8006b0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80063c:	83 f9 01             	cmp    $0x1,%ecx
  80063f:	7e 15                	jle    800656 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	8b 48 04             	mov    0x4(%eax),%ecx
  800649:	8d 40 08             	lea    0x8(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	eb 5a                	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	75 17                	jne    800671 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
  80066f:	eb 3f                	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
  800686:	eb 28                	jmp    8006b0 <vprintfmt+0x3bb>
			putch('0', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 30                	push   $0x30
  80068e:	ff d6                	call   *%esi
			putch('x', putdat);
  800690:	83 c4 08             	add    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 78                	push   $0x78
  800696:	ff d6                	call   *%esi
			num = (unsigned long long)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b7:	57                   	push   %edi
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	50                   	push   %eax
  8006bc:	51                   	push   %ecx
  8006bd:	52                   	push   %edx
  8006be:	89 da                	mov    %ebx,%edx
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	e8 45 fb ff ff       	call   80020c <printnum>
			break;
  8006c7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006cd:	83 c7 01             	add    $0x1,%edi
  8006d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d4:	83 f8 25             	cmp    $0x25,%eax
  8006d7:	0f 84 2f fc ff ff    	je     80030c <vprintfmt+0x17>
			if (ch == '\0')
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	0f 84 8b 00 00 00    	je     800770 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	50                   	push   %eax
  8006ea:	ff d6                	call   *%esi
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb dc                	jmp    8006cd <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006f1:	83 f9 01             	cmp    $0x1,%ecx
  8006f4:	7e 15                	jle    80070b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fe:	8d 40 08             	lea    0x8(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800704:	b8 10 00 00 00       	mov    $0x10,%eax
  800709:	eb a5                	jmp    8006b0 <vprintfmt+0x3bb>
	else if (lflag)
  80070b:	85 c9                	test   %ecx,%ecx
  80070d:	75 17                	jne    800726 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8b 10                	mov    (%eax),%edx
  800714:	b9 00 00 00 00       	mov    $0x0,%ecx
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
  800724:	eb 8a                	jmp    8006b0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
  80073b:	e9 70 ff ff ff       	jmp    8006b0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 25                	push   $0x25
  800746:	ff d6                	call   *%esi
			break;
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	e9 7a ff ff ff       	jmp    8006ca <vprintfmt+0x3d5>
			putch('%', putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	53                   	push   %ebx
  800754:	6a 25                	push   $0x25
  800756:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	89 f8                	mov    %edi,%eax
  80075d:	eb 03                	jmp    800762 <vprintfmt+0x46d>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800766:	75 f7                	jne    80075f <vprintfmt+0x46a>
  800768:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80076b:	e9 5a ff ff ff       	jmp    8006ca <vprintfmt+0x3d5>
}
  800770:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x47>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 22                	jle    8007bf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 bb 02 80 00       	push   $0x8002bb
  8007ac:	e8 44 fb ff ff       	call   8002f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb f7                	jmp    8007bd <vsnprintf+0x45>

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007cf:	50                   	push   %eax
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	ff 75 08             	pushl  0x8(%ebp)
  8007d9:	e8 9a ff ff ff       	call   800778 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007eb:	eb 03                	jmp    8007f0 <strlen+0x10>
		n++;
  8007ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f4:	75 f7                	jne    8007ed <strlen+0xd>
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800801:	b8 00 00 00 00       	mov    $0x0,%eax
  800806:	eb 03                	jmp    80080b <strnlen+0x13>
		n++;
  800808:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080b:	39 d0                	cmp    %edx,%eax
  80080d:	74 06                	je     800815 <strnlen+0x1d>
  80080f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800813:	75 f3                	jne    800808 <strnlen+0x10>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800821:	89 c2                	mov    %eax,%edx
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80082d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800830:	84 db                	test   %bl,%bl
  800832:	75 ef                	jne    800823 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80083e:	53                   	push   %ebx
  80083f:	e8 9c ff ff ff       	call   8007e0 <strlen>
  800844:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800847:	ff 75 0c             	pushl  0xc(%ebp)
  80084a:	01 d8                	add    %ebx,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 c5 ff ff ff       	call   800817 <strcpy>
	return dst;
}
  800852:	89 d8                	mov    %ebx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	89 f3                	mov    %esi,%ebx
  800866:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800869:	89 f2                	mov    %esi,%edx
  80086b:	eb 0f                	jmp    80087c <strncpy+0x23>
		*dst++ = *src;
  80086d:	83 c2 01             	add    $0x1,%edx
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800876:	80 39 01             	cmpb   $0x1,(%ecx)
  800879:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80087c:	39 da                	cmp    %ebx,%edx
  80087e:	75 ed                	jne    80086d <strncpy+0x14>
	}
	return ret;
}
  800880:	89 f0                	mov    %esi,%eax
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	56                   	push   %esi
  80088a:	53                   	push   %ebx
  80088b:	8b 75 08             	mov    0x8(%ebp),%esi
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800894:	89 f0                	mov    %esi,%eax
  800896:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089a:	85 c9                	test   %ecx,%ecx
  80089c:	75 0b                	jne    8008a9 <strlcpy+0x23>
  80089e:	eb 17                	jmp    8008b7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a9:	39 d8                	cmp    %ebx,%eax
  8008ab:	74 07                	je     8008b4 <strlcpy+0x2e>
  8008ad:	0f b6 0a             	movzbl (%edx),%ecx
  8008b0:	84 c9                	test   %cl,%cl
  8008b2:	75 ec                	jne    8008a0 <strlcpy+0x1a>
		*dst = '\0';
  8008b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b7:	29 f0                	sub    %esi,%eax
}
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strcmp+0x11>
		p++, q++;
  8008c8:	83 c1 01             	add    $0x1,%ecx
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 04                	je     8008d9 <strcmp+0x1c>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	74 ef                	je     8008c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d9:	0f b6 c0             	movzbl %al,%eax
  8008dc:	0f b6 12             	movzbl (%edx),%edx
  8008df:	29 d0                	sub    %edx,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f2:	eb 06                	jmp    8008fa <strncmp+0x17>
		n--, p++, q++;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 16                	je     800914 <strncmp+0x31>
  8008fe:	0f b6 08             	movzbl (%eax),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	74 04                	je     800909 <strncmp+0x26>
  800905:	3a 0a                	cmp    (%edx),%cl
  800907:	74 eb                	je     8008f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800909:	0f b6 00             	movzbl (%eax),%eax
  80090c:	0f b6 12             	movzbl (%edx),%edx
  80090f:	29 d0                	sub    %edx,%eax
}
  800911:	5b                   	pop    %ebx
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
		return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
  800919:	eb f6                	jmp    800911 <strncmp+0x2e>

0080091b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 09                	je     800935 <strchr+0x1a>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 0a                	je     80093a <strchr+0x1f>
	for (; *s; s++)
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	eb f0                	jmp    800925 <strchr+0xa>
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800946:	eb 03                	jmp    80094b <strfind+0xf>
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094e:	38 ca                	cmp    %cl,%dl
  800950:	74 04                	je     800956 <strfind+0x1a>
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strfind+0xc>
			break;
	return (char *) s;
}
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	53                   	push   %ebx
  80095e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 13                	je     80097b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800968:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096e:	75 05                	jne    800975 <memset+0x1d>
  800970:	f6 c1 03             	test   $0x3,%cl
  800973:	74 0d                	je     800982 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	fc                   	cld    
  800979:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097b:	89 f8                	mov    %edi,%eax
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    
		c &= 0xFF;
  800982:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800986:	89 d3                	mov    %edx,%ebx
  800988:	c1 e3 08             	shl    $0x8,%ebx
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	c1 e0 18             	shl    $0x18,%eax
  800990:	89 d6                	mov    %edx,%esi
  800992:	c1 e6 10             	shl    $0x10,%esi
  800995:	09 f0                	or     %esi,%eax
  800997:	09 c2                	or     %eax,%edx
  800999:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80099b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	fc                   	cld    
  8009a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a3:	eb d6                	jmp    80097b <memset+0x23>

008009a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	57                   	push   %edi
  8009a9:	56                   	push   %esi
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b3:	39 c6                	cmp    %eax,%esi
  8009b5:	73 35                	jae    8009ec <memmove+0x47>
  8009b7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ba:	39 c2                	cmp    %eax,%edx
  8009bc:	76 2e                	jbe    8009ec <memmove+0x47>
		s += n;
		d += n;
  8009be:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 d6                	mov    %edx,%esi
  8009c3:	09 fe                	or     %edi,%esi
  8009c5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cb:	74 0c                	je     8009d9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cd:	83 ef 01             	sub    $0x1,%edi
  8009d0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d6:	fc                   	cld    
  8009d7:	eb 21                	jmp    8009fa <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 ef                	jne    8009cd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009de:	83 ef 04             	sub    $0x4,%edi
  8009e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e7:	fd                   	std    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb ea                	jmp    8009d6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	89 f2                	mov    %esi,%edx
  8009ee:	09 c2                	or     %eax,%edx
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	74 09                	je     8009fe <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fa:	5e                   	pop    %esi
  8009fb:	5f                   	pop    %edi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 f2                	jne    8009f5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a03:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a06:	89 c7                	mov    %eax,%edi
  800a08:	fc                   	cld    
  800a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0b:	eb ed                	jmp    8009fa <memmove+0x55>

00800a0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a10:	ff 75 10             	pushl  0x10(%ebp)
  800a13:	ff 75 0c             	pushl  0xc(%ebp)
  800a16:	ff 75 08             	pushl  0x8(%ebp)
  800a19:	e8 87 ff ff ff       	call   8009a5 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2b:	89 c6                	mov    %eax,%esi
  800a2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	39 f0                	cmp    %esi,%eax
  800a32:	74 1c                	je     800a50 <memcmp+0x30>
		if (*s1 != *s2)
  800a34:	0f b6 08             	movzbl (%eax),%ecx
  800a37:	0f b6 1a             	movzbl (%edx),%ebx
  800a3a:	38 d9                	cmp    %bl,%cl
  800a3c:	75 08                	jne    800a46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
  800a44:	eb ea                	jmp    800a30 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a46:	0f b6 c1             	movzbl %cl,%eax
  800a49:	0f b6 db             	movzbl %bl,%ebx
  800a4c:	29 d8                	sub    %ebx,%eax
  800a4e:	eb 05                	jmp    800a55 <memcmp+0x35>
	}

	return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a62:	89 c2                	mov    %eax,%edx
  800a64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 09                	jae    800a74 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6b:	38 08                	cmp    %cl,(%eax)
  800a6d:	74 05                	je     800a74 <memfind+0x1b>
	for (; s < ends; s++)
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	eb f3                	jmp    800a67 <memfind+0xe>
			break;
	return (void *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
  800a7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	eb 03                	jmp    800a87 <strtol+0x11>
		s++;
  800a84:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	3c 20                	cmp    $0x20,%al
  800a8c:	74 f6                	je     800a84 <strtol+0xe>
  800a8e:	3c 09                	cmp    $0x9,%al
  800a90:	74 f2                	je     800a84 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a92:	3c 2b                	cmp    $0x2b,%al
  800a94:	74 2e                	je     800ac4 <strtol+0x4e>
	int neg = 0;
  800a96:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a9b:	3c 2d                	cmp    $0x2d,%al
  800a9d:	74 2f                	je     800ace <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa5:	75 05                	jne    800aac <strtol+0x36>
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	74 2c                	je     800ad8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	75 0a                	jne    800aba <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	74 28                	je     800ae2 <strtol+0x6c>
		base = 10;
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac2:	eb 50                	jmp    800b14 <strtol+0x9e>
		s++;
  800ac4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ac7:	bf 00 00 00 00       	mov    $0x0,%edi
  800acc:	eb d1                	jmp    800a9f <strtol+0x29>
		s++, neg = 1;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad6:	eb c7                	jmp    800a9f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adc:	74 0e                	je     800aec <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	75 d8                	jne    800aba <strtol+0x44>
		s++, base = 8;
  800ae2:	83 c1 01             	add    $0x1,%ecx
  800ae5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aea:	eb ce                	jmp    800aba <strtol+0x44>
		s += 2, base = 16;
  800aec:	83 c1 02             	add    $0x2,%ecx
  800aef:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af4:	eb c4                	jmp    800aba <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800af6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 29                	ja     800b29 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b09:	7d 30                	jge    800b3b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b12:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 09             	cmp    $0x9,%bl
  800b1f:	77 d5                	ja     800af6 <strtol+0x80>
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
  800b27:	eb dd                	jmp    800b06 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b29:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 37             	sub    $0x37,%edx
  800b39:	eb cb                	jmp    800b06 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3f:	74 05                	je     800b46 <strtol+0xd0>
		*endptr = (char *) s;
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b44:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	f7 da                	neg    %edx
  800b4a:	85 ff                	test   %edi,%edi
  800b4c:	0f 45 c2             	cmovne %edx,%eax
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b65:	89 c3                	mov    %eax,%ebx
  800b67:	89 c7                	mov    %eax,%edi
  800b69:	89 c6                	mov    %eax,%esi
  800b6b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba7:	89 cb                	mov    %ecx,%ebx
  800ba9:	89 cf                	mov    %ecx,%edi
  800bab:	89 ce                	mov    %ecx,%esi
  800bad:	cd 30                	int    $0x30
	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7f 08                	jg     800bbb <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 03                	push   $0x3
  800bc1:	68 9f 25 80 00       	push   $0x80259f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 bc 25 80 00       	push   $0x8025bc
  800bcd:	e8 7a 13 00 00       	call   801f4c <_panic>

00800bd2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 02 00 00 00       	mov    $0x2,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_yield>:

void
sys_yield(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c19:	be 00 00 00 00       	mov    $0x0,%esi
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c24:	b8 04 00 00 00       	mov    $0x4,%eax
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2c:	89 f7                	mov    %esi,%edi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 04                	push   $0x4
  800c42:	68 9f 25 80 00       	push   $0x80259f
  800c47:	6a 23                	push   $0x23
  800c49:	68 bc 25 80 00       	push   $0x8025bc
  800c4e:	e8 f9 12 00 00       	call   801f4c <_panic>

00800c53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c62:	b8 05 00 00 00       	mov    $0x5,%eax
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 05                	push   $0x5
  800c84:	68 9f 25 80 00       	push   $0x80259f
  800c89:	6a 23                	push   $0x23
  800c8b:	68 bc 25 80 00       	push   $0x8025bc
  800c90:	e8 b7 12 00 00       	call   801f4c <_panic>

00800c95 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 06                	push   $0x6
  800cc6:	68 9f 25 80 00       	push   $0x80259f
  800ccb:	6a 23                	push   $0x23
  800ccd:	68 bc 25 80 00       	push   $0x8025bc
  800cd2:	e8 75 12 00 00       	call   801f4c <_panic>

00800cd7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 08                	push   $0x8
  800d08:	68 9f 25 80 00       	push   $0x80259f
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 bc 25 80 00       	push   $0x8025bc
  800d14:	e8 33 12 00 00       	call   801f4c <_panic>

00800d19 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 09                	push   $0x9
  800d4a:	68 9f 25 80 00       	push   $0x80259f
  800d4f:	6a 23                	push   $0x23
  800d51:	68 bc 25 80 00       	push   $0x8025bc
  800d56:	e8 f1 11 00 00       	call   801f4c <_panic>

00800d5b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7f 08                	jg     800d86 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	83 ec 0c             	sub    $0xc,%esp
  800d89:	50                   	push   %eax
  800d8a:	6a 0a                	push   $0xa
  800d8c:	68 9f 25 80 00       	push   $0x80259f
  800d91:	6a 23                	push   $0x23
  800d93:	68 bc 25 80 00       	push   $0x8025bc
  800d98:	e8 af 11 00 00       	call   801f4c <_panic>

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dae:	be 00 00 00 00       	mov    $0x0,%esi
  800db3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	89 cf                	mov    %ecx,%edi
  800dda:	89 ce                	mov    %ecx,%esi
  800ddc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7f 08                	jg     800dea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	50                   	push   %eax
  800dee:	6a 0d                	push   $0xd
  800df0:	68 9f 25 80 00       	push   $0x80259f
  800df5:	6a 23                	push   $0x23
  800df7:	68 bc 25 80 00       	push   $0x8025bc
  800dfc:	e8 4b 11 00 00       	call   801f4c <_panic>

00800e01 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	53                   	push   %ebx
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e0b:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800e0d:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800e10:	a8 02                	test   $0x2,%al
  800e12:	0f 84 89 00 00 00    	je     800ea1 <pgfault+0xa0>
  800e18:	89 da                	mov    %ebx,%edx
  800e1a:	c1 ea 0c             	shr    $0xc,%edx
  800e1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e24:	f6 c6 08             	test   $0x8,%dh
  800e27:	74 78                	je     800ea1 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	6a 07                	push   $0x7
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	6a 00                	push   $0x0
  800e35:	e8 d6 fd ff ff       	call   800c10 <sys_page_alloc>
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	0f 88 8b 00 00 00    	js     800ed0 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	68 00 10 00 00       	push   $0x1000
  800e4d:	53                   	push   %ebx
  800e4e:	68 00 f0 7f 00       	push   $0x7ff000
  800e53:	e8 4d fb ff ff       	call   8009a5 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e58:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e5f:	53                   	push   %ebx
  800e60:	6a 00                	push   $0x0
  800e62:	68 00 f0 7f 00       	push   $0x7ff000
  800e67:	6a 00                	push   $0x0
  800e69:	e8 e5 fd ff ff       	call   800c53 <sys_page_map>
  800e6e:	83 c4 20             	add    $0x20,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 6d                	js     800ee2 <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 11 fe ff ff       	call   800c95 <sys_page_unmap>
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	78 69                	js     800ef4 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	53                   	push   %ebx
  800e8f:	68 28 26 80 00       	push   $0x802628
  800e94:	e8 5f f3 ff ff       	call   8001f8 <cprintf>

}
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800ea1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  800ea7:	8b 4a 48             	mov    0x48(%edx),%ecx
  800eaa:	89 da                	mov    %ebx,%edx
  800eac:	c1 ea 0c             	shr    $0xc,%edx
  800eaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb6:	51                   	push   %ecx
  800eb7:	53                   	push   %ebx
  800eb8:	68 00 00 40 ef       	push   $0xef400000
  800ebd:	52                   	push   %edx
  800ebe:	50                   	push   %eax
  800ebf:	68 cc 25 80 00       	push   $0x8025cc
  800ec4:	6a 1e                	push   $0x1e
  800ec6:	68 49 26 80 00       	push   $0x802649
  800ecb:	e8 7c 10 00 00       	call   801f4c <_panic>
        panic("sys_page_alloc error %e", r);
  800ed0:	50                   	push   %eax
  800ed1:	68 54 26 80 00       	push   $0x802654
  800ed6:	6a 28                	push   $0x28
  800ed8:	68 49 26 80 00       	push   $0x802649
  800edd:	e8 6a 10 00 00       	call   801f4c <_panic>
        panic("sys_page_map error %e", r);
  800ee2:	50                   	push   %eax
  800ee3:	68 6c 26 80 00       	push   $0x80266c
  800ee8:	6a 2b                	push   $0x2b
  800eea:	68 49 26 80 00       	push   $0x802649
  800eef:	e8 58 10 00 00       	call   801f4c <_panic>
        panic("sys_page_unmap error %e", r);
  800ef4:	50                   	push   %eax
  800ef5:	68 82 26 80 00       	push   $0x802682
  800efa:	6a 2d                	push   $0x2d
  800efc:	68 49 26 80 00       	push   $0x802649
  800f01:	e8 46 10 00 00       	call   801f4c <_panic>

00800f06 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f0c:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800f13:	74 23                	je     800f38 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	a3 0c 40 80 00       	mov    %eax,0x80400c
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800f1d:	a1 08 40 80 00       	mov    0x804008,%eax
  800f22:	8b 40 48             	mov    0x48(%eax),%eax
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	68 92 1f 80 00       	push   $0x801f92
  800f2d:	50                   	push   %eax
  800f2e:	e8 28 fe ff ff       	call   800d5b <sys_env_set_pgfault_upcall>
}
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800f38:	a1 08 40 80 00       	mov    0x804008,%eax
  800f3d:	8b 40 48             	mov    0x48(%eax),%eax
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	6a 07                	push   $0x7
  800f45:	68 00 f0 bf ee       	push   $0xeebff000
  800f4a:	50                   	push   %eax
  800f4b:	e8 c0 fc ff ff       	call   800c10 <sys_page_alloc>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	79 be                	jns    800f15 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800f57:	50                   	push   %eax
  800f58:	68 9a 26 80 00       	push   $0x80269a
  800f5d:	6a 21                	push   $0x21
  800f5f:	68 ad 26 80 00       	push   $0x8026ad
  800f64:	e8 e3 0f 00 00       	call   801f4c <_panic>

00800f69 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	6a 07                	push   $0x7
  800f79:	53                   	push   %ebx
  800f7a:	56                   	push   %esi
  800f7b:	e8 90 fc ff ff       	call   800c10 <sys_page_alloc>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 4a                	js     800fd1 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	6a 07                	push   $0x7
  800f8c:	68 00 00 40 00       	push   $0x400000
  800f91:	6a 00                	push   $0x0
  800f93:	53                   	push   %ebx
  800f94:	56                   	push   %esi
  800f95:	e8 b9 fc ff ff       	call   800c53 <sys_page_map>
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 42                	js     800fe3 <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	68 00 10 00 00       	push   $0x1000
  800fa9:	53                   	push   %ebx
  800faa:	68 00 00 40 00       	push   $0x400000
  800faf:	e8 f1 f9 ff ff       	call   8009a5 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	68 00 00 40 00       	push   $0x400000
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 d2 fc ff ff       	call   800c95 <sys_page_unmap>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 2b                	js     800ff5 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  800fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  800fd1:	50                   	push   %eax
  800fd2:	68 9a 26 80 00       	push   $0x80269a
  800fd7:	6a 63                	push   $0x63
  800fd9:	68 49 26 80 00       	push   $0x802649
  800fde:	e8 69 0f 00 00       	call   801f4c <_panic>
        panic("sys_page_map: %e", r);
  800fe3:	50                   	push   %eax
  800fe4:	68 bd 26 80 00       	push   $0x8026bd
  800fe9:	6a 65                	push   $0x65
  800feb:	68 49 26 80 00       	push   $0x802649
  800ff0:	e8 57 0f 00 00       	call   801f4c <_panic>
        panic("sys_page_unmap: %e", r);
  800ff5:	50                   	push   %eax
  800ff6:	68 ce 26 80 00       	push   $0x8026ce
  800ffb:	6a 68                	push   $0x68
  800ffd:	68 49 26 80 00       	push   $0x802649
  801002:	e8 45 0f 00 00       	call   801f4c <_panic>

00801007 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	57                   	push   %edi
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801010:	a1 08 40 80 00       	mov    0x804008,%eax
  801015:	8b 40 64             	mov    0x64(%eax),%eax
  801018:	85 c0                	test   %eax,%eax
  80101a:	74 1f                	je     80103b <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80101c:	b8 07 00 00 00       	mov    $0x7,%eax
  801021:	cd 30                	int    $0x30
  801023:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  801025:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801028:	85 c0                	test   %eax,%eax
  80102a:	74 21                	je     80104d <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  80102c:	be 0c 40 80 00       	mov    $0x80400c,%esi
  801031:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801034:	bb 00 00 00 00       	mov    $0x0,%ebx
  801039:	eb 7b                	jmp    8010b6 <fork+0xaf>
        set_pgfault_handler(pgfault);
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	68 01 0e 80 00       	push   $0x800e01
  801043:	e8 be fe ff ff       	call   800f06 <set_pgfault_handler>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	eb cf                	jmp    80101c <fork+0x15>
        set_pgfault_handler(pgfault);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	68 01 0e 80 00       	push   $0x800e01
  801055:	e8 ac fe ff ff       	call   800f06 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  80105a:	e8 73 fb ff ff       	call   800bd2 <sys_getenvid>
  80105f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106c:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	e9 ca 00 00 00       	jmp    801143 <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801079:	89 d1                	mov    %edx,%ecx
  80107b:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  801081:	81 e2 02 08 00 00    	and    $0x802,%edx
  801087:	89 cf                	mov    %ecx,%edi
  801089:	81 cf 00 08 00 00    	or     $0x800,%edi
  80108f:	85 d2                	test   %edx,%edx
  801091:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	51                   	push   %ecx
  801098:	50                   	push   %eax
  801099:	ff 75 e4             	pushl  -0x1c(%ebp)
  80109c:	50                   	push   %eax
  80109d:	6a 00                	push   $0x0
  80109f:	e8 af fb ff ff       	call   800c53 <sys_page_map>
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 45                	js     8010f0 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8010ab:	83 c3 01             	add    $0x1,%ebx
  8010ae:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8010b4:	74 4c                	je     801102 <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8010b6:	39 de                	cmp    %ebx,%esi
  8010b8:	74 f1                	je     8010ab <fork+0xa4>
  8010ba:	89 d8                	mov    %ebx,%eax
  8010bc:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	c1 ea 16             	shr    $0x16,%edx
  8010c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8010cb:	f6 c2 05             	test   $0x5,%dl
  8010ce:	74 db                	je     8010ab <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	c1 ea 0c             	shr    $0xc,%edx
  8010d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8010dc:	f6 c2 04             	test   $0x4,%dl
  8010df:	74 ca                	je     8010ab <fork+0xa4>
    if (perm & PTE_SHARE) {
  8010e1:	f6 c6 04             	test   $0x4,%dh
  8010e4:	74 93                	je     801079 <fork+0x72>
        perm &= ~PTE_COW;
  8010e6:	89 d1                	mov    %edx,%ecx
  8010e8:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8010ee:	eb a4                	jmp    801094 <fork+0x8d>
        panic("sys_page_map error %e", r);
  8010f0:	50                   	push   %eax
  8010f1:	68 6c 26 80 00       	push   $0x80266c
  8010f6:	6a 57                	push   $0x57
  8010f8:	68 49 26 80 00       	push   $0x802649
  8010fd:	e8 4a 0e 00 00       	call   801f4c <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	b8 0c 40 80 00       	mov    $0x80400c,%eax
  80110a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110f:	50                   	push   %eax
  801110:	ff 75 e4             	pushl  -0x1c(%ebp)
  801113:	e8 51 fe ff ff       	call   800f69 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80111e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801123:	50                   	push   %eax
  801124:	ff 75 e4             	pushl  -0x1c(%ebp)
  801127:	e8 3d fe ff ff       	call   800f69 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	6a 02                	push   $0x2
  801131:	ff 75 e4             	pushl  -0x1c(%ebp)
  801134:	e8 9e fb ff ff       	call   800cd7 <sys_env_set_status>
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 0d                	js     80114d <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801140:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  801143:	89 d8                	mov    %ebx,%eax
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  80114d:	50                   	push   %eax
  80114e:	68 e1 26 80 00       	push   $0x8026e1
  801153:	68 a0 00 00 00       	push   $0xa0
  801158:	68 49 26 80 00       	push   $0x802649
  80115d:	e8 ea 0d 00 00       	call   801f4c <_panic>

00801162 <sfork>:

// Challenge!
int
sfork(void)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801168:	68 f8 26 80 00       	push   $0x8026f8
  80116d:	68 a9 00 00 00       	push   $0xa9
  801172:	68 49 26 80 00       	push   $0x802649
  801177:	e8 d0 0d 00 00       	call   801f4c <_panic>

0080117c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	8b 75 08             	mov    0x8(%ebp),%esi
  801184:	8b 45 0c             	mov    0xc(%ebp),%eax
  801187:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  80118a:	85 c0                	test   %eax,%eax
  80118c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801191:	0f 44 c2             	cmove  %edx,%eax
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	50                   	push   %eax
  801198:	e8 23 fc ff ff       	call   800dc0 <sys_ipc_recv>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 2b                	js     8011cf <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  8011a4:	85 f6                	test   %esi,%esi
  8011a6:	74 0a                	je     8011b2 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  8011a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ad:	8b 40 74             	mov    0x74(%eax),%eax
  8011b0:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  8011b2:	85 db                	test   %ebx,%ebx
  8011b4:	74 0a                	je     8011c0 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  8011b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8011bb:	8b 40 78             	mov    0x78(%eax),%eax
  8011be:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  8011c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    
        *from_env_store = 0;
  8011cf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  8011d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  8011db:	eb eb                	jmp    8011c8 <ipc_recv+0x4c>

008011dd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  8011ef:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  8011f1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011f6:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  8011f9:	ff 75 14             	pushl  0x14(%ebp)
  8011fc:	53                   	push   %ebx
  8011fd:	56                   	push   %esi
  8011fe:	57                   	push   %edi
  8011ff:	e8 99 fb ff ff       	call   800d9d <sys_ipc_try_send>
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	85 c0                	test   %eax,%eax
  801209:	74 17                	je     801222 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  80120b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80120e:	74 e9                	je     8011f9 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801210:	50                   	push   %eax
  801211:	68 0e 27 80 00       	push   $0x80270e
  801216:	6a 3e                	push   $0x3e
  801218:	68 20 27 80 00       	push   $0x802720
  80121d:	e8 2a 0d 00 00       	call   801f4c <_panic>
        }
    }
}
  801222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5f                   	pop    %edi
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801230:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801235:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801238:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80123e:	8b 52 50             	mov    0x50(%edx),%edx
  801241:	39 ca                	cmp    %ecx,%edx
  801243:	74 11                	je     801256 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801245:	83 c0 01             	add    $0x1,%eax
  801248:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124d:	75 e6                	jne    801235 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
  801254:	eb 0b                	jmp    801261 <ipc_find_env+0x37>
			return envs[i].env_id;
  801256:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801259:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80125e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	05 00 00 00 30       	add    $0x30000000,%eax
  80126e:	c1 e8 0c             	shr    $0xc,%eax
}
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80127e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801283:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    

0080128a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801290:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801295:	89 c2                	mov    %eax,%edx
  801297:	c1 ea 16             	shr    $0x16,%edx
  80129a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a1:	f6 c2 01             	test   $0x1,%dl
  8012a4:	74 2a                	je     8012d0 <fd_alloc+0x46>
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	c1 ea 0c             	shr    $0xc,%edx
  8012ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b2:	f6 c2 01             	test   $0x1,%dl
  8012b5:	74 19                	je     8012d0 <fd_alloc+0x46>
  8012b7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012bc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c1:	75 d2                	jne    801295 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012c9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012ce:	eb 07                	jmp    8012d7 <fd_alloc+0x4d>
			*fd_store = fd;
  8012d0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012df:	83 f8 1f             	cmp    $0x1f,%eax
  8012e2:	77 36                	ja     80131a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e4:	c1 e0 0c             	shl    $0xc,%eax
  8012e7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	c1 ea 16             	shr    $0x16,%edx
  8012f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f8:	f6 c2 01             	test   $0x1,%dl
  8012fb:	74 24                	je     801321 <fd_lookup+0x48>
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	c1 ea 0c             	shr    $0xc,%edx
  801302:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801309:	f6 c2 01             	test   $0x1,%dl
  80130c:	74 1a                	je     801328 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801311:	89 02                	mov    %eax,(%edx)
	return 0;
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    
		return -E_INVAL;
  80131a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131f:	eb f7                	jmp    801318 <fd_lookup+0x3f>
		return -E_INVAL;
  801321:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801326:	eb f0                	jmp    801318 <fd_lookup+0x3f>
  801328:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132d:	eb e9                	jmp    801318 <fd_lookup+0x3f>

0080132f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 08             	sub    $0x8,%esp
  801335:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801338:	ba a8 27 80 00       	mov    $0x8027a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80133d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801342:	39 08                	cmp    %ecx,(%eax)
  801344:	74 33                	je     801379 <dev_lookup+0x4a>
  801346:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801349:	8b 02                	mov    (%edx),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	75 f3                	jne    801342 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134f:	a1 08 40 80 00       	mov    0x804008,%eax
  801354:	8b 40 48             	mov    0x48(%eax),%eax
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	51                   	push   %ecx
  80135b:	50                   	push   %eax
  80135c:	68 2c 27 80 00       	push   $0x80272c
  801361:	e8 92 ee ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  801366:	8b 45 0c             	mov    0xc(%ebp),%eax
  801369:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    
			*dev = devtab[i];
  801379:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	eb f2                	jmp    801377 <dev_lookup+0x48>

00801385 <fd_close>:
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	83 ec 1c             	sub    $0x1c,%esp
  80138e:	8b 75 08             	mov    0x8(%ebp),%esi
  801391:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801394:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801397:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801398:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80139e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a1:	50                   	push   %eax
  8013a2:	e8 32 ff ff ff       	call   8012d9 <fd_lookup>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	83 c4 08             	add    $0x8,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	78 05                	js     8013b5 <fd_close+0x30>
	    || fd != fd2)
  8013b0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013b3:	74 16                	je     8013cb <fd_close+0x46>
		return (must_exist ? r : 0);
  8013b5:	89 f8                	mov    %edi,%eax
  8013b7:	84 c0                	test   %al,%al
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013be:	0f 44 d8             	cmove  %eax,%ebx
}
  8013c1:	89 d8                	mov    %ebx,%eax
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	ff 36                	pushl  (%esi)
  8013d4:	e8 56 ff ff ff       	call   80132f <dev_lookup>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 15                	js     8013f7 <fd_close+0x72>
		if (dev->dev_close)
  8013e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e5:	8b 40 10             	mov    0x10(%eax),%eax
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 1b                	je     801407 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	56                   	push   %esi
  8013f0:	ff d0                	call   *%eax
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	56                   	push   %esi
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 93 f8 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	eb ba                	jmp    8013c1 <fd_close+0x3c>
			r = 0;
  801407:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140c:	eb e9                	jmp    8013f7 <fd_close+0x72>

0080140e <close>:

int
close(int fdnum)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 75 08             	pushl  0x8(%ebp)
  80141b:	e8 b9 fe ff ff       	call   8012d9 <fd_lookup>
  801420:	83 c4 08             	add    $0x8,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 10                	js     801437 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	6a 01                	push   $0x1
  80142c:	ff 75 f4             	pushl  -0xc(%ebp)
  80142f:	e8 51 ff ff ff       	call   801385 <fd_close>
  801434:	83 c4 10             	add    $0x10,%esp
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <close_all>:

void
close_all(void)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	53                   	push   %ebx
  801449:	e8 c0 ff ff ff       	call   80140e <close>
	for (i = 0; i < MAXFD; i++)
  80144e:	83 c3 01             	add    $0x1,%ebx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	83 fb 20             	cmp    $0x20,%ebx
  801457:	75 ec                	jne    801445 <close_all+0xc>
}
  801459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801467:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	ff 75 08             	pushl  0x8(%ebp)
  80146e:	e8 66 fe ff ff       	call   8012d9 <fd_lookup>
  801473:	89 c3                	mov    %eax,%ebx
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	0f 88 81 00 00 00    	js     801501 <dup+0xa3>
		return r;
	close(newfdnum);
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	ff 75 0c             	pushl  0xc(%ebp)
  801486:	e8 83 ff ff ff       	call   80140e <close>

	newfd = INDEX2FD(newfdnum);
  80148b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80148e:	c1 e6 0c             	shl    $0xc,%esi
  801491:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801497:	83 c4 04             	add    $0x4,%esp
  80149a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149d:	e8 d1 fd ff ff       	call   801273 <fd2data>
  8014a2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014a4:	89 34 24             	mov    %esi,(%esp)
  8014a7:	e8 c7 fd ff ff       	call   801273 <fd2data>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b1:	89 d8                	mov    %ebx,%eax
  8014b3:	c1 e8 16             	shr    $0x16,%eax
  8014b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bd:	a8 01                	test   $0x1,%al
  8014bf:	74 11                	je     8014d2 <dup+0x74>
  8014c1:	89 d8                	mov    %ebx,%eax
  8014c3:	c1 e8 0c             	shr    $0xc,%eax
  8014c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	75 39                	jne    80150b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014d5:	89 d0                	mov    %edx,%eax
  8014d7:	c1 e8 0c             	shr    $0xc,%eax
  8014da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e9:	50                   	push   %eax
  8014ea:	56                   	push   %esi
  8014eb:	6a 00                	push   $0x0
  8014ed:	52                   	push   %edx
  8014ee:	6a 00                	push   $0x0
  8014f0:	e8 5e f7 ff ff       	call   800c53 <sys_page_map>
  8014f5:	89 c3                	mov    %eax,%ebx
  8014f7:	83 c4 20             	add    $0x20,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 31                	js     80152f <dup+0xd1>
		goto err;

	return newfdnum;
  8014fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801501:	89 d8                	mov    %ebx,%eax
  801503:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801506:	5b                   	pop    %ebx
  801507:	5e                   	pop    %esi
  801508:	5f                   	pop    %edi
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80150b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	25 07 0e 00 00       	and    $0xe07,%eax
  80151a:	50                   	push   %eax
  80151b:	57                   	push   %edi
  80151c:	6a 00                	push   $0x0
  80151e:	53                   	push   %ebx
  80151f:	6a 00                	push   $0x0
  801521:	e8 2d f7 ff ff       	call   800c53 <sys_page_map>
  801526:	89 c3                	mov    %eax,%ebx
  801528:	83 c4 20             	add    $0x20,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	79 a3                	jns    8014d2 <dup+0x74>
	sys_page_unmap(0, newfd);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	56                   	push   %esi
  801533:	6a 00                	push   $0x0
  801535:	e8 5b f7 ff ff       	call   800c95 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80153a:	83 c4 08             	add    $0x8,%esp
  80153d:	57                   	push   %edi
  80153e:	6a 00                	push   $0x0
  801540:	e8 50 f7 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	eb b7                	jmp    801501 <dup+0xa3>

0080154a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 14             	sub    $0x14,%esp
  801551:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	53                   	push   %ebx
  801559:	e8 7b fd ff ff       	call   8012d9 <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 3f                	js     8015a4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156f:	ff 30                	pushl  (%eax)
  801571:	e8 b9 fd ff ff       	call   80132f <dev_lookup>
  801576:	83 c4 10             	add    $0x10,%esp
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 27                	js     8015a4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801580:	8b 42 08             	mov    0x8(%edx),%eax
  801583:	83 e0 03             	and    $0x3,%eax
  801586:	83 f8 01             	cmp    $0x1,%eax
  801589:	74 1e                	je     8015a9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80158b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158e:	8b 40 08             	mov    0x8(%eax),%eax
  801591:	85 c0                	test   %eax,%eax
  801593:	74 35                	je     8015ca <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	ff 75 10             	pushl  0x10(%ebp)
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	52                   	push   %edx
  80159f:	ff d0                	call   *%eax
  8015a1:	83 c4 10             	add    $0x10,%esp
}
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ae:	8b 40 48             	mov    0x48(%eax),%eax
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	53                   	push   %ebx
  8015b5:	50                   	push   %eax
  8015b6:	68 6d 27 80 00       	push   $0x80276d
  8015bb:	e8 38 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c8:	eb da                	jmp    8015a4 <read+0x5a>
		return -E_NOT_SUPP;
  8015ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015cf:	eb d3                	jmp    8015a4 <read+0x5a>

008015d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	39 f3                	cmp    %esi,%ebx
  8015e7:	73 25                	jae    80160e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e9:	83 ec 04             	sub    $0x4,%esp
  8015ec:	89 f0                	mov    %esi,%eax
  8015ee:	29 d8                	sub    %ebx,%eax
  8015f0:	50                   	push   %eax
  8015f1:	89 d8                	mov    %ebx,%eax
  8015f3:	03 45 0c             	add    0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	57                   	push   %edi
  8015f8:	e8 4d ff ff ff       	call   80154a <read>
		if (m < 0)
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 08                	js     80160c <readn+0x3b>
			return m;
		if (m == 0)
  801604:	85 c0                	test   %eax,%eax
  801606:	74 06                	je     80160e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801608:	01 c3                	add    %eax,%ebx
  80160a:	eb d9                	jmp    8015e5 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80160c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80160e:	89 d8                	mov    %ebx,%eax
  801610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    

00801618 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	53                   	push   %ebx
  80161c:	83 ec 14             	sub    $0x14,%esp
  80161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	53                   	push   %ebx
  801627:	e8 ad fc ff ff       	call   8012d9 <fd_lookup>
  80162c:	83 c4 08             	add    $0x8,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 3a                	js     80166d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163d:	ff 30                	pushl  (%eax)
  80163f:	e8 eb fc ff ff       	call   80132f <dev_lookup>
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	85 c0                	test   %eax,%eax
  801649:	78 22                	js     80166d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801652:	74 1e                	je     801672 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801654:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801657:	8b 52 0c             	mov    0xc(%edx),%edx
  80165a:	85 d2                	test   %edx,%edx
  80165c:	74 35                	je     801693 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165e:	83 ec 04             	sub    $0x4,%esp
  801661:	ff 75 10             	pushl  0x10(%ebp)
  801664:	ff 75 0c             	pushl  0xc(%ebp)
  801667:	50                   	push   %eax
  801668:	ff d2                	call   *%edx
  80166a:	83 c4 10             	add    $0x10,%esp
}
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801672:	a1 08 40 80 00       	mov    0x804008,%eax
  801677:	8b 40 48             	mov    0x48(%eax),%eax
  80167a:	83 ec 04             	sub    $0x4,%esp
  80167d:	53                   	push   %ebx
  80167e:	50                   	push   %eax
  80167f:	68 89 27 80 00       	push   $0x802789
  801684:	e8 6f eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801691:	eb da                	jmp    80166d <write+0x55>
		return -E_NOT_SUPP;
  801693:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801698:	eb d3                	jmp    80166d <write+0x55>

0080169a <seek>:

int
seek(int fdnum, off_t offset)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 2d fc ff ff       	call   8012d9 <fd_lookup>
  8016ac:	83 c4 08             	add    $0x8,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 0e                	js     8016c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 14             	sub    $0x14,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	53                   	push   %ebx
  8016d2:	e8 02 fc ff ff       	call   8012d9 <fd_lookup>
  8016d7:	83 c4 08             	add    $0x8,%esp
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	78 37                	js     801715 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e8:	ff 30                	pushl  (%eax)
  8016ea:	e8 40 fc ff ff       	call   80132f <dev_lookup>
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 1f                	js     801715 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fd:	74 1b                	je     80171a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	8b 52 18             	mov    0x18(%edx),%edx
  801705:	85 d2                	test   %edx,%edx
  801707:	74 32                	je     80173b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801709:	83 ec 08             	sub    $0x8,%esp
  80170c:	ff 75 0c             	pushl  0xc(%ebp)
  80170f:	50                   	push   %eax
  801710:	ff d2                	call   *%edx
  801712:	83 c4 10             	add    $0x10,%esp
}
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    
			thisenv->env_id, fdnum);
  80171a:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80171f:	8b 40 48             	mov    0x48(%eax),%eax
  801722:	83 ec 04             	sub    $0x4,%esp
  801725:	53                   	push   %ebx
  801726:	50                   	push   %eax
  801727:	68 4c 27 80 00       	push   $0x80274c
  80172c:	e8 c7 ea ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801739:	eb da                	jmp    801715 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80173b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801740:	eb d3                	jmp    801715 <ftruncate+0x52>

00801742 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	83 ec 14             	sub    $0x14,%esp
  801749:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174f:	50                   	push   %eax
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 81 fb ff ff       	call   8012d9 <fd_lookup>
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 4b                	js     8017aa <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801765:	50                   	push   %eax
  801766:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801769:	ff 30                	pushl  (%eax)
  80176b:	e8 bf fb ff ff       	call   80132f <dev_lookup>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	85 c0                	test   %eax,%eax
  801775:	78 33                	js     8017aa <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801777:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80177e:	74 2f                	je     8017af <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801780:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801783:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80178a:	00 00 00 
	stat->st_isdir = 0;
  80178d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801794:	00 00 00 
	stat->st_dev = dev;
  801797:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017a4:	ff 50 14             	call   *0x14(%eax)
  8017a7:	83 c4 10             	add    $0x10,%esp
}
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    
		return -E_NOT_SUPP;
  8017af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b4:	eb f4                	jmp    8017aa <fstat+0x68>

008017b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	6a 00                	push   $0x0
  8017c0:	ff 75 08             	pushl  0x8(%ebp)
  8017c3:	e8 e7 01 00 00       	call   8019af <open>
  8017c8:	89 c3                	mov    %eax,%ebx
  8017ca:	83 c4 10             	add    $0x10,%esp
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 1b                	js     8017ec <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	ff 75 0c             	pushl  0xc(%ebp)
  8017d7:	50                   	push   %eax
  8017d8:	e8 65 ff ff ff       	call   801742 <fstat>
  8017dd:	89 c6                	mov    %eax,%esi
	close(fd);
  8017df:	89 1c 24             	mov    %ebx,(%esp)
  8017e2:	e8 27 fc ff ff       	call   80140e <close>
	return r;
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 f3                	mov    %esi,%ebx
}
  8017ec:	89 d8                	mov    %ebx,%eax
  8017ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	56                   	push   %esi
  8017f9:	53                   	push   %ebx
  8017fa:	89 c6                	mov    %eax,%esi
  8017fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801805:	74 27                	je     80182e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801807:	6a 07                	push   $0x7
  801809:	68 00 50 80 00       	push   $0x805000
  80180e:	56                   	push   %esi
  80180f:	ff 35 00 40 80 00    	pushl  0x804000
  801815:	e8 c3 f9 ff ff       	call   8011dd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181a:	83 c4 0c             	add    $0xc,%esp
  80181d:	6a 00                	push   $0x0
  80181f:	53                   	push   %ebx
  801820:	6a 00                	push   $0x0
  801822:	e8 55 f9 ff ff       	call   80117c <ipc_recv>
}
  801827:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182e:	83 ec 0c             	sub    $0xc,%esp
  801831:	6a 01                	push   $0x1
  801833:	e8 f2 f9 ff ff       	call   80122a <ipc_find_env>
  801838:	a3 00 40 80 00       	mov    %eax,0x804000
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	eb c5                	jmp    801807 <fsipc+0x12>

00801842 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 40 0c             	mov    0xc(%eax),%eax
  80184e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801853:	8b 45 0c             	mov    0xc(%ebp),%eax
  801856:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 02 00 00 00       	mov    $0x2,%eax
  801865:	e8 8b ff ff ff       	call   8017f5 <fsipc>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devfile_flush>:
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	8b 40 0c             	mov    0xc(%eax),%eax
  801878:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 06 00 00 00       	mov    $0x6,%eax
  801887:	e8 69 ff ff ff       	call   8017f5 <fsipc>
}
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <devfile_stat>:
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	53                   	push   %ebx
  801892:	83 ec 04             	sub    $0x4,%esp
  801895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ad:	e8 43 ff ff ff       	call   8017f5 <fsipc>
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 2c                	js     8018e2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	68 00 50 80 00       	push   $0x805000
  8018be:	53                   	push   %ebx
  8018bf:	e8 53 ef ff ff       	call   800817 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018c4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018cf:	a1 84 50 80 00       	mov    0x805084,%eax
  8018d4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <devfile_write>:
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	83 ec 0c             	sub    $0xc,%esp
  8018ed:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  8018f0:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018fa:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801900:	8b 52 0c             	mov    0xc(%edx),%edx
  801903:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801909:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  80190e:	50                   	push   %eax
  80190f:	ff 75 0c             	pushl  0xc(%ebp)
  801912:	68 08 50 80 00       	push   $0x805008
  801917:	e8 89 f0 ff ff       	call   8009a5 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80191c:	ba 00 00 00 00       	mov    $0x0,%edx
  801921:	b8 04 00 00 00       	mov    $0x4,%eax
  801926:	e8 ca fe ff ff       	call   8017f5 <fsipc>
}
  80192b:	c9                   	leave  
  80192c:	c3                   	ret    

0080192d <devfile_read>:
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	8b 40 0c             	mov    0xc(%eax),%eax
  80193b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801940:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801946:	ba 00 00 00 00       	mov    $0x0,%edx
  80194b:	b8 03 00 00 00       	mov    $0x3,%eax
  801950:	e8 a0 fe ff ff       	call   8017f5 <fsipc>
  801955:	89 c3                	mov    %eax,%ebx
  801957:	85 c0                	test   %eax,%eax
  801959:	78 1f                	js     80197a <devfile_read+0x4d>
	assert(r <= n);
  80195b:	39 f0                	cmp    %esi,%eax
  80195d:	77 24                	ja     801983 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80195f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801964:	7f 33                	jg     801999 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	50                   	push   %eax
  80196a:	68 00 50 80 00       	push   $0x805000
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	e8 2e f0 ff ff       	call   8009a5 <memmove>
	return r;
  801977:	83 c4 10             	add    $0x10,%esp
}
  80197a:	89 d8                	mov    %ebx,%eax
  80197c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197f:	5b                   	pop    %ebx
  801980:	5e                   	pop    %esi
  801981:	5d                   	pop    %ebp
  801982:	c3                   	ret    
	assert(r <= n);
  801983:	68 b8 27 80 00       	push   $0x8027b8
  801988:	68 bf 27 80 00       	push   $0x8027bf
  80198d:	6a 7d                	push   $0x7d
  80198f:	68 d4 27 80 00       	push   $0x8027d4
  801994:	e8 b3 05 00 00       	call   801f4c <_panic>
	assert(r <= PGSIZE);
  801999:	68 df 27 80 00       	push   $0x8027df
  80199e:	68 bf 27 80 00       	push   $0x8027bf
  8019a3:	6a 7e                	push   $0x7e
  8019a5:	68 d4 27 80 00       	push   $0x8027d4
  8019aa:	e8 9d 05 00 00       	call   801f4c <_panic>

008019af <open>:
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 1c             	sub    $0x1c,%esp
  8019b7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019ba:	56                   	push   %esi
  8019bb:	e8 20 ee ff ff       	call   8007e0 <strlen>
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c8:	0f 8f 96 00 00 00    	jg     801a64 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d4:	50                   	push   %eax
  8019d5:	e8 b0 f8 ff ff       	call   80128a <fd_alloc>
  8019da:	89 c3                	mov    %eax,%ebx
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 66                	js     801a49 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  8019e3:	83 ec 08             	sub    $0x8,%esp
  8019e6:	56                   	push   %esi
  8019e7:	68 00 50 80 00       	push   $0x805000
  8019ec:	e8 26 ee ff ff       	call   800817 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801a01:	e8 ef fd ff ff       	call   8017f5 <fsipc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	78 43                	js     801a52 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801a0f:	83 ec 0c             	sub    $0xc,%esp
  801a12:	ff 75 f4             	pushl  -0xc(%ebp)
  801a15:	e8 49 f8 ff ff       	call   801263 <fd2num>
  801a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1d:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a23:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a26:	83 c4 08             	add    $0x8,%esp
  801a29:	50                   	push   %eax
  801a2a:	52                   	push   %edx
  801a2b:	ff 32                	pushl  (%edx)
  801a2d:	56                   	push   %esi
  801a2e:	51                   	push   %ecx
  801a2f:	68 ec 27 80 00       	push   $0x8027ec
  801a34:	e8 bf e7 ff ff       	call   8001f8 <cprintf>
	return fd2num(fd);
  801a39:	83 c4 14             	add    $0x14,%esp
  801a3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3f:	e8 1f f8 ff ff       	call   801263 <fd2num>
  801a44:	89 c3                	mov    %eax,%ebx
  801a46:	83 c4 10             	add    $0x10,%esp
}
  801a49:	89 d8                	mov    %ebx,%eax
  801a4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4e:	5b                   	pop    %ebx
  801a4f:	5e                   	pop    %esi
  801a50:	5d                   	pop    %ebp
  801a51:	c3                   	ret    
		fd_close(fd, 0);
  801a52:	83 ec 08             	sub    $0x8,%esp
  801a55:	6a 00                	push   $0x0
  801a57:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5a:	e8 26 f9 ff ff       	call   801385 <fd_close>
		return r;
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	eb e5                	jmp    801a49 <open+0x9a>
		return -E_BAD_PATH;
  801a64:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a69:	eb de                	jmp    801a49 <open+0x9a>

00801a6b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a71:	ba 00 00 00 00       	mov    $0x0,%edx
  801a76:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7b:	e8 75 fd ff ff       	call   8017f5 <fsipc>
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 75 08             	pushl  0x8(%ebp)
  801a90:	e8 de f7 ff ff       	call   801273 <fd2data>
  801a95:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a97:	83 c4 08             	add    $0x8,%esp
  801a9a:	68 2b 28 80 00       	push   $0x80282b
  801a9f:	53                   	push   %ebx
  801aa0:	e8 72 ed ff ff       	call   800817 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa5:	8b 46 04             	mov    0x4(%esi),%eax
  801aa8:	2b 06                	sub    (%esi),%eax
  801aaa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab7:	00 00 00 
	stat->st_dev = &devpipe;
  801aba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ac1:	30 80 00 
	return 0;
}
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ada:	53                   	push   %ebx
  801adb:	6a 00                	push   $0x0
  801add:	e8 b3 f1 ff ff       	call   800c95 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae2:	89 1c 24             	mov    %ebx,(%esp)
  801ae5:	e8 89 f7 ff ff       	call   801273 <fd2data>
  801aea:	83 c4 08             	add    $0x8,%esp
  801aed:	50                   	push   %eax
  801aee:	6a 00                	push   $0x0
  801af0:	e8 a0 f1 ff ff       	call   800c95 <sys_page_unmap>
}
  801af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <_pipeisclosed>:
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	57                   	push   %edi
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	83 ec 1c             	sub    $0x1c,%esp
  801b03:	89 c7                	mov    %eax,%edi
  801b05:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b07:	a1 08 40 80 00       	mov    0x804008,%eax
  801b0c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	57                   	push   %edi
  801b13:	e8 a0 04 00 00       	call   801fb8 <pageref>
  801b18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b1b:	89 34 24             	mov    %esi,(%esp)
  801b1e:	e8 95 04 00 00       	call   801fb8 <pageref>
		nn = thisenv->env_runs;
  801b23:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	39 cb                	cmp    %ecx,%ebx
  801b31:	74 1b                	je     801b4e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b33:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b36:	75 cf                	jne    801b07 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b38:	8b 42 58             	mov    0x58(%edx),%eax
  801b3b:	6a 01                	push   $0x1
  801b3d:	50                   	push   %eax
  801b3e:	53                   	push   %ebx
  801b3f:	68 32 28 80 00       	push   $0x802832
  801b44:	e8 af e6 ff ff       	call   8001f8 <cprintf>
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	eb b9                	jmp    801b07 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b4e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b51:	0f 94 c0             	sete   %al
  801b54:	0f b6 c0             	movzbl %al,%eax
}
  801b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5a:	5b                   	pop    %ebx
  801b5b:	5e                   	pop    %esi
  801b5c:	5f                   	pop    %edi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <devpipe_write>:
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	57                   	push   %edi
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	83 ec 28             	sub    $0x28,%esp
  801b68:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b6b:	56                   	push   %esi
  801b6c:	e8 02 f7 ff ff       	call   801273 <fd2data>
  801b71:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	bf 00 00 00 00       	mov    $0x0,%edi
  801b7b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7e:	74 4f                	je     801bcf <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b80:	8b 43 04             	mov    0x4(%ebx),%eax
  801b83:	8b 0b                	mov    (%ebx),%ecx
  801b85:	8d 51 20             	lea    0x20(%ecx),%edx
  801b88:	39 d0                	cmp    %edx,%eax
  801b8a:	72 14                	jb     801ba0 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b8c:	89 da                	mov    %ebx,%edx
  801b8e:	89 f0                	mov    %esi,%eax
  801b90:	e8 65 ff ff ff       	call   801afa <_pipeisclosed>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	75 3a                	jne    801bd3 <devpipe_write+0x74>
			sys_yield();
  801b99:	e8 53 f0 ff ff       	call   800bf1 <sys_yield>
  801b9e:	eb e0                	jmp    801b80 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ba7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801baa:	89 c2                	mov    %eax,%edx
  801bac:	c1 fa 1f             	sar    $0x1f,%edx
  801baf:	89 d1                	mov    %edx,%ecx
  801bb1:	c1 e9 1b             	shr    $0x1b,%ecx
  801bb4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bb7:	83 e2 1f             	and    $0x1f,%edx
  801bba:	29 ca                	sub    %ecx,%edx
  801bbc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bc0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bca:	83 c7 01             	add    $0x1,%edi
  801bcd:	eb ac                	jmp    801b7b <devpipe_write+0x1c>
	return i;
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	eb 05                	jmp    801bd8 <devpipe_write+0x79>
				return 0;
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <devpipe_read>:
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	53                   	push   %ebx
  801be6:	83 ec 18             	sub    $0x18,%esp
  801be9:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bec:	57                   	push   %edi
  801bed:	e8 81 f6 ff ff       	call   801273 <fd2data>
  801bf2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	be 00 00 00 00       	mov    $0x0,%esi
  801bfc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bff:	74 47                	je     801c48 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c01:	8b 03                	mov    (%ebx),%eax
  801c03:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c06:	75 22                	jne    801c2a <devpipe_read+0x4a>
			if (i > 0)
  801c08:	85 f6                	test   %esi,%esi
  801c0a:	75 14                	jne    801c20 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c0c:	89 da                	mov    %ebx,%edx
  801c0e:	89 f8                	mov    %edi,%eax
  801c10:	e8 e5 fe ff ff       	call   801afa <_pipeisclosed>
  801c15:	85 c0                	test   %eax,%eax
  801c17:	75 33                	jne    801c4c <devpipe_read+0x6c>
			sys_yield();
  801c19:	e8 d3 ef ff ff       	call   800bf1 <sys_yield>
  801c1e:	eb e1                	jmp    801c01 <devpipe_read+0x21>
				return i;
  801c20:	89 f0                	mov    %esi,%eax
}
  801c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5f                   	pop    %edi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c2a:	99                   	cltd   
  801c2b:	c1 ea 1b             	shr    $0x1b,%edx
  801c2e:	01 d0                	add    %edx,%eax
  801c30:	83 e0 1f             	and    $0x1f,%eax
  801c33:	29 d0                	sub    %edx,%eax
  801c35:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c40:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c43:	83 c6 01             	add    $0x1,%esi
  801c46:	eb b4                	jmp    801bfc <devpipe_read+0x1c>
	return i;
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	eb d6                	jmp    801c22 <devpipe_read+0x42>
				return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c51:	eb cf                	jmp    801c22 <devpipe_read+0x42>

00801c53 <pipe>:
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5e:	50                   	push   %eax
  801c5f:	e8 26 f6 ff ff       	call   80128a <fd_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 5b                	js     801cc8 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	68 07 04 00 00       	push   $0x407
  801c75:	ff 75 f4             	pushl  -0xc(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 91 ef ff ff       	call   800c10 <sys_page_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	78 40                	js     801cc8 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c88:	83 ec 0c             	sub    $0xc,%esp
  801c8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8e:	50                   	push   %eax
  801c8f:	e8 f6 f5 ff ff       	call   80128a <fd_alloc>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 1b                	js     801cb8 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9d:	83 ec 04             	sub    $0x4,%esp
  801ca0:	68 07 04 00 00       	push   $0x407
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 61 ef ff ff       	call   800c10 <sys_page_alloc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	79 19                	jns    801cd1 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801cb8:	83 ec 08             	sub    $0x8,%esp
  801cbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 d0 ef ff ff       	call   800c95 <sys_page_unmap>
  801cc5:	83 c4 10             	add    $0x10,%esp
}
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    
	va = fd2data(fd0);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd7:	e8 97 f5 ff ff       	call   801273 <fd2data>
  801cdc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cde:	83 c4 0c             	add    $0xc,%esp
  801ce1:	68 07 04 00 00       	push   $0x407
  801ce6:	50                   	push   %eax
  801ce7:	6a 00                	push   $0x0
  801ce9:	e8 22 ef ff ff       	call   800c10 <sys_page_alloc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	0f 88 8c 00 00 00    	js     801d87 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 ec 0c             	sub    $0xc,%esp
  801cfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801d01:	e8 6d f5 ff ff       	call   801273 <fd2data>
  801d06:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d0d:	50                   	push   %eax
  801d0e:	6a 00                	push   $0x0
  801d10:	56                   	push   %esi
  801d11:	6a 00                	push   $0x0
  801d13:	e8 3b ef ff ff       	call   800c53 <sys_page_map>
  801d18:	89 c3                	mov    %eax,%ebx
  801d1a:	83 c4 20             	add    $0x20,%esp
  801d1d:	85 c0                	test   %eax,%eax
  801d1f:	78 58                	js     801d79 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d24:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d2a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d3f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d4b:	83 ec 0c             	sub    $0xc,%esp
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	e8 0d f5 ff ff       	call   801263 <fd2num>
  801d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d59:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d5b:	83 c4 04             	add    $0x4,%esp
  801d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d61:	e8 fd f4 ff ff       	call   801263 <fd2num>
  801d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d69:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d74:	e9 4f ff ff ff       	jmp    801cc8 <pipe+0x75>
	sys_page_unmap(0, va);
  801d79:	83 ec 08             	sub    $0x8,%esp
  801d7c:	56                   	push   %esi
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 11 ef ff ff       	call   800c95 <sys_page_unmap>
  801d84:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d87:	83 ec 08             	sub    $0x8,%esp
  801d8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 01 ef ff ff       	call   800c95 <sys_page_unmap>
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	e9 1c ff ff ff       	jmp    801cb8 <pipe+0x65>

00801d9c <pipeisclosed>:
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801da2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da5:	50                   	push   %eax
  801da6:	ff 75 08             	pushl  0x8(%ebp)
  801da9:	e8 2b f5 ff ff       	call   8012d9 <fd_lookup>
  801dae:	83 c4 10             	add    $0x10,%esp
  801db1:	85 c0                	test   %eax,%eax
  801db3:	78 18                	js     801dcd <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801db5:	83 ec 0c             	sub    $0xc,%esp
  801db8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbb:	e8 b3 f4 ff ff       	call   801273 <fd2data>
	return _pipeisclosed(fd, p);
  801dc0:	89 c2                	mov    %eax,%edx
  801dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc5:	e8 30 fd ff ff       	call   801afa <_pipeisclosed>
  801dca:	83 c4 10             	add    $0x10,%esp
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ddf:	68 4a 28 80 00       	push   $0x80284a
  801de4:	ff 75 0c             	pushl  0xc(%ebp)
  801de7:	e8 2b ea ff ff       	call   800817 <strcpy>
	return 0;
}
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <devcons_write>:
{
  801df3:	55                   	push   %ebp
  801df4:	89 e5                	mov    %esp,%ebp
  801df6:	57                   	push   %edi
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dff:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e0a:	eb 2f                	jmp    801e3b <devcons_write+0x48>
		m = n - tot;
  801e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0f:	29 f3                	sub    %esi,%ebx
  801e11:	83 fb 7f             	cmp    $0x7f,%ebx
  801e14:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e19:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e1c:	83 ec 04             	sub    $0x4,%esp
  801e1f:	53                   	push   %ebx
  801e20:	89 f0                	mov    %esi,%eax
  801e22:	03 45 0c             	add    0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	57                   	push   %edi
  801e27:	e8 79 eb ff ff       	call   8009a5 <memmove>
		sys_cputs(buf, m);
  801e2c:	83 c4 08             	add    $0x8,%esp
  801e2f:	53                   	push   %ebx
  801e30:	57                   	push   %edi
  801e31:	e8 1e ed ff ff       	call   800b54 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e36:	01 de                	add    %ebx,%esi
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e3e:	72 cc                	jb     801e0c <devcons_write+0x19>
}
  801e40:	89 f0                	mov    %esi,%eax
  801e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e45:	5b                   	pop    %ebx
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <devcons_read>:
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 08             	sub    $0x8,%esp
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e59:	75 07                	jne    801e62 <devcons_read+0x18>
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    
		sys_yield();
  801e5d:	e8 8f ed ff ff       	call   800bf1 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e62:	e8 0b ed ff ff       	call   800b72 <sys_cgetc>
  801e67:	85 c0                	test   %eax,%eax
  801e69:	74 f2                	je     801e5d <devcons_read+0x13>
	if (c < 0)
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 ec                	js     801e5b <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e6f:	83 f8 04             	cmp    $0x4,%eax
  801e72:	74 0c                	je     801e80 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	88 02                	mov    %al,(%edx)
	return 1;
  801e79:	b8 01 00 00 00       	mov    $0x1,%eax
  801e7e:	eb db                	jmp    801e5b <devcons_read+0x11>
		return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	eb d4                	jmp    801e5b <devcons_read+0x11>

00801e87 <cputchar>:
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e90:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e93:	6a 01                	push   $0x1
  801e95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e98:	50                   	push   %eax
  801e99:	e8 b6 ec ff ff       	call   800b54 <sys_cputs>
}
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <getchar>:
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ea9:	6a 01                	push   $0x1
  801eab:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 94 f6 ff ff       	call   80154a <read>
	if (r < 0)
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 08                	js     801ec5 <getchar+0x22>
	if (r < 1)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	7e 06                	jle    801ec7 <getchar+0x24>
	return c;
  801ec1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    
		return -E_EOF;
  801ec7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ecc:	eb f7                	jmp    801ec5 <getchar+0x22>

00801ece <iscons>:
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	ff 75 08             	pushl  0x8(%ebp)
  801edb:	e8 f9 f3 ff ff       	call   8012d9 <fd_lookup>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 11                	js     801ef8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ef0:	39 10                	cmp    %edx,(%eax)
  801ef2:	0f 94 c0             	sete   %al
  801ef5:	0f b6 c0             	movzbl %al,%eax
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <opencons>:
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	e8 81 f3 ff ff       	call   80128a <fd_alloc>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 3a                	js     801f4a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 04 00 00       	push   $0x407
  801f18:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1b:	6a 00                	push   $0x0
  801f1d:	e8 ee ec ff ff       	call   800c10 <sys_page_alloc>
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 21                	js     801f4a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	50                   	push   %eax
  801f42:	e8 1c f3 ff ff       	call   801263 <fd2num>
  801f47:	83 c4 10             	add    $0x10,%esp
}
  801f4a:	c9                   	leave  
  801f4b:	c3                   	ret    

00801f4c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	56                   	push   %esi
  801f50:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f51:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f54:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f5a:	e8 73 ec ff ff       	call   800bd2 <sys_getenvid>
  801f5f:	83 ec 0c             	sub    $0xc,%esp
  801f62:	ff 75 0c             	pushl  0xc(%ebp)
  801f65:	ff 75 08             	pushl  0x8(%ebp)
  801f68:	56                   	push   %esi
  801f69:	50                   	push   %eax
  801f6a:	68 58 28 80 00       	push   $0x802858
  801f6f:	e8 84 e2 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f74:	83 c4 18             	add    $0x18,%esp
  801f77:	53                   	push   %ebx
  801f78:	ff 75 10             	pushl  0x10(%ebp)
  801f7b:	e8 27 e2 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801f80:	c7 04 24 43 28 80 00 	movl   $0x802843,(%esp)
  801f87:	e8 6c e2 ff ff       	call   8001f8 <cprintf>
  801f8c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f8f:	cc                   	int3   
  801f90:	eb fd                	jmp    801f8f <_panic+0x43>

00801f92 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f92:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f93:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801f98:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f9a:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801f9d:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801fa0:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801fa4:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801fa8:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801fab:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801faf:	89 18                	mov    %ebx,(%eax)

    popal
  801fb1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801fb2:	83 c4 04             	add    $0x4,%esp
    popfl
  801fb5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  801fb6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  801fb7:	c3                   	ret    

00801fb8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbe:	89 d0                	mov    %edx,%eax
  801fc0:	c1 e8 16             	shr    $0x16,%eax
  801fc3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fca:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801fcf:	f6 c1 01             	test   $0x1,%cl
  801fd2:	74 1d                	je     801ff1 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801fd4:	c1 ea 0c             	shr    $0xc,%edx
  801fd7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fde:	f6 c2 01             	test   $0x1,%dl
  801fe1:	74 0e                	je     801ff1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe3:	c1 ea 0c             	shr    $0xc,%edx
  801fe6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fed:	ef 
  801fee:	0f b7 c0             	movzwl %ax,%eax
}
  801ff1:	5d                   	pop    %ebp
  801ff2:	c3                   	ret    
  801ff3:	66 90                	xchg   %ax,%ax
  801ff5:	66 90                	xchg   %ax,%ax
  801ff7:	66 90                	xchg   %ax,%ax
  801ff9:	66 90                	xchg   %ax,%ax
  801ffb:	66 90                	xchg   %ax,%ax
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80200b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80200f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802013:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802017:	85 d2                	test   %edx,%edx
  802019:	75 35                	jne    802050 <__udivdi3+0x50>
  80201b:	39 f3                	cmp    %esi,%ebx
  80201d:	0f 87 bd 00 00 00    	ja     8020e0 <__udivdi3+0xe0>
  802023:	85 db                	test   %ebx,%ebx
  802025:	89 d9                	mov    %ebx,%ecx
  802027:	75 0b                	jne    802034 <__udivdi3+0x34>
  802029:	b8 01 00 00 00       	mov    $0x1,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f3                	div    %ebx
  802032:	89 c1                	mov    %eax,%ecx
  802034:	31 d2                	xor    %edx,%edx
  802036:	89 f0                	mov    %esi,%eax
  802038:	f7 f1                	div    %ecx
  80203a:	89 c6                	mov    %eax,%esi
  80203c:	89 e8                	mov    %ebp,%eax
  80203e:	89 f7                	mov    %esi,%edi
  802040:	f7 f1                	div    %ecx
  802042:	89 fa                	mov    %edi,%edx
  802044:	83 c4 1c             	add    $0x1c,%esp
  802047:	5b                   	pop    %ebx
  802048:	5e                   	pop    %esi
  802049:	5f                   	pop    %edi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    
  80204c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 f2                	cmp    %esi,%edx
  802052:	77 7c                	ja     8020d0 <__udivdi3+0xd0>
  802054:	0f bd fa             	bsr    %edx,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0xf8>
  802060:	89 f9                	mov    %edi,%ecx
  802062:	b8 20 00 00 00       	mov    $0x20,%eax
  802067:	29 f8                	sub    %edi,%eax
  802069:	d3 e2                	shl    %cl,%edx
  80206b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	89 da                	mov    %ebx,%edx
  802073:	d3 ea                	shr    %cl,%edx
  802075:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802079:	09 d1                	or     %edx,%ecx
  80207b:	89 f2                	mov    %esi,%edx
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e3                	shl    %cl,%ebx
  802085:	89 c1                	mov    %eax,%ecx
  802087:	d3 ea                	shr    %cl,%edx
  802089:	89 f9                	mov    %edi,%ecx
  80208b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80208f:	d3 e6                	shl    %cl,%esi
  802091:	89 eb                	mov    %ebp,%ebx
  802093:	89 c1                	mov    %eax,%ecx
  802095:	d3 eb                	shr    %cl,%ebx
  802097:	09 de                	or     %ebx,%esi
  802099:	89 f0                	mov    %esi,%eax
  80209b:	f7 74 24 08          	divl   0x8(%esp)
  80209f:	89 d6                	mov    %edx,%esi
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	f7 64 24 0c          	mull   0xc(%esp)
  8020a7:	39 d6                	cmp    %edx,%esi
  8020a9:	72 0c                	jb     8020b7 <__udivdi3+0xb7>
  8020ab:	89 f9                	mov    %edi,%ecx
  8020ad:	d3 e5                	shl    %cl,%ebp
  8020af:	39 c5                	cmp    %eax,%ebp
  8020b1:	73 5d                	jae    802110 <__udivdi3+0x110>
  8020b3:	39 d6                	cmp    %edx,%esi
  8020b5:	75 59                	jne    802110 <__udivdi3+0x110>
  8020b7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020ba:	31 ff                	xor    %edi,%edi
  8020bc:	89 fa                	mov    %edi,%edx
  8020be:	83 c4 1c             	add    $0x1c,%esp
  8020c1:	5b                   	pop    %ebx
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    
  8020c6:	8d 76 00             	lea    0x0(%esi),%esi
  8020c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8020d0:	31 ff                	xor    %edi,%edi
  8020d2:	31 c0                	xor    %eax,%eax
  8020d4:	89 fa                	mov    %edi,%edx
  8020d6:	83 c4 1c             	add    $0x1c,%esp
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    
  8020de:	66 90                	xchg   %ax,%ax
  8020e0:	31 ff                	xor    %edi,%edi
  8020e2:	89 e8                	mov    %ebp,%eax
  8020e4:	89 f2                	mov    %esi,%edx
  8020e6:	f7 f3                	div    %ebx
  8020e8:	89 fa                	mov    %edi,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	72 06                	jb     802102 <__udivdi3+0x102>
  8020fc:	31 c0                	xor    %eax,%eax
  8020fe:	39 eb                	cmp    %ebp,%ebx
  802100:	77 d2                	ja     8020d4 <__udivdi3+0xd4>
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	eb cb                	jmp    8020d4 <__udivdi3+0xd4>
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d8                	mov    %ebx,%eax
  802112:	31 ff                	xor    %edi,%edi
  802114:	eb be                	jmp    8020d4 <__udivdi3+0xd4>
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80212b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80212f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 ed                	test   %ebp,%ebp
  802139:	89 f0                	mov    %esi,%eax
  80213b:	89 da                	mov    %ebx,%edx
  80213d:	75 19                	jne    802158 <__umoddi3+0x38>
  80213f:	39 df                	cmp    %ebx,%edi
  802141:	0f 86 b1 00 00 00    	jbe    8021f8 <__umoddi3+0xd8>
  802147:	f7 f7                	div    %edi
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 dd                	cmp    %ebx,%ebp
  80215a:	77 f1                	ja     80214d <__umoddi3+0x2d>
  80215c:	0f bd cd             	bsr    %ebp,%ecx
  80215f:	83 f1 1f             	xor    $0x1f,%ecx
  802162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802166:	0f 84 b4 00 00 00    	je     802220 <__umoddi3+0x100>
  80216c:	b8 20 00 00 00       	mov    $0x20,%eax
  802171:	89 c2                	mov    %eax,%edx
  802173:	8b 44 24 04          	mov    0x4(%esp),%eax
  802177:	29 c2                	sub    %eax,%edx
  802179:	89 c1                	mov    %eax,%ecx
  80217b:	89 f8                	mov    %edi,%eax
  80217d:	d3 e5                	shl    %cl,%ebp
  80217f:	89 d1                	mov    %edx,%ecx
  802181:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802185:	d3 e8                	shr    %cl,%eax
  802187:	09 c5                	or     %eax,%ebp
  802189:	8b 44 24 04          	mov    0x4(%esp),%eax
  80218d:	89 c1                	mov    %eax,%ecx
  80218f:	d3 e7                	shl    %cl,%edi
  802191:	89 d1                	mov    %edx,%ecx
  802193:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802197:	89 df                	mov    %ebx,%edi
  802199:	d3 ef                	shr    %cl,%edi
  80219b:	89 c1                	mov    %eax,%ecx
  80219d:	89 f0                	mov    %esi,%eax
  80219f:	d3 e3                	shl    %cl,%ebx
  8021a1:	89 d1                	mov    %edx,%ecx
  8021a3:	89 fa                	mov    %edi,%edx
  8021a5:	d3 e8                	shr    %cl,%eax
  8021a7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021ac:	09 d8                	or     %ebx,%eax
  8021ae:	f7 f5                	div    %ebp
  8021b0:	d3 e6                	shl    %cl,%esi
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	f7 64 24 08          	mull   0x8(%esp)
  8021b8:	39 d1                	cmp    %edx,%ecx
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d7                	mov    %edx,%edi
  8021be:	72 06                	jb     8021c6 <__umoddi3+0xa6>
  8021c0:	75 0e                	jne    8021d0 <__umoddi3+0xb0>
  8021c2:	39 c6                	cmp    %eax,%esi
  8021c4:	73 0a                	jae    8021d0 <__umoddi3+0xb0>
  8021c6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8021ca:	19 ea                	sbb    %ebp,%edx
  8021cc:	89 d7                	mov    %edx,%edi
  8021ce:	89 c3                	mov    %eax,%ebx
  8021d0:	89 ca                	mov    %ecx,%edx
  8021d2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021d7:	29 de                	sub    %ebx,%esi
  8021d9:	19 fa                	sbb    %edi,%edx
  8021db:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8021df:	89 d0                	mov    %edx,%eax
  8021e1:	d3 e0                	shl    %cl,%eax
  8021e3:	89 d9                	mov    %ebx,%ecx
  8021e5:	d3 ee                	shr    %cl,%esi
  8021e7:	d3 ea                	shr    %cl,%edx
  8021e9:	09 f0                	or     %esi,%eax
  8021eb:	83 c4 1c             	add    $0x1c,%esp
  8021ee:	5b                   	pop    %ebx
  8021ef:	5e                   	pop    %esi
  8021f0:	5f                   	pop    %edi
  8021f1:	5d                   	pop    %ebp
  8021f2:	c3                   	ret    
  8021f3:	90                   	nop
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	85 ff                	test   %edi,%edi
  8021fa:	89 f9                	mov    %edi,%ecx
  8021fc:	75 0b                	jne    802209 <__umoddi3+0xe9>
  8021fe:	b8 01 00 00 00       	mov    $0x1,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f7                	div    %edi
  802207:	89 c1                	mov    %eax,%ecx
  802209:	89 d8                	mov    %ebx,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f1                	div    %ecx
  80220f:	89 f0                	mov    %esi,%eax
  802211:	f7 f1                	div    %ecx
  802213:	e9 31 ff ff ff       	jmp    802149 <__umoddi3+0x29>
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 dd                	cmp    %ebx,%ebp
  802222:	72 08                	jb     80222c <__umoddi3+0x10c>
  802224:	39 f7                	cmp    %esi,%edi
  802226:	0f 87 21 ff ff ff    	ja     80214d <__umoddi3+0x2d>
  80222c:	89 da                	mov    %ebx,%edx
  80222e:	89 f0                	mov    %esi,%eax
  802230:	29 f8                	sub    %edi,%eax
  802232:	19 ea                	sbb    %ebp,%edx
  802234:	e9 14 ff ff ff       	jmp    80214d <__umoddi3+0x2d>
