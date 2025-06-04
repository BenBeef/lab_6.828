
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 6e 01 00 00       	call   80019f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 65 10 00 00       	call   8010a3 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9e 00 00 00    	jne    8000e7 <umain+0xb4>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 bc 11 00 00       	call   801218 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 e0 22 80 00       	push   $0x8022e0
  80006c:	e8 23 02 00 00       	call   800294 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 fd 07 00 00       	call   80087c <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 ec 08 00 00       	call   80097f <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	74 3b                	je     8000d5 <umain+0xa2>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 35 00 30 80 00    	pushl  0x803000
  8000a3:	e8 d4 07 00 00       	call   80087c <strlen>
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	83 c0 01             	add    $0x1,%eax
  8000ae:	50                   	push   %eax
  8000af:	ff 35 00 30 80 00    	pushl  0x803000
  8000b5:	68 00 00 b0 00       	push   $0xb00000
  8000ba:	e8 ea 09 00 00       	call   800aa9 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000bf:	6a 07                	push   $0x7
  8000c1:	68 00 00 b0 00       	push   $0xb00000
  8000c6:	6a 00                	push   $0x0
  8000c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000cb:	e8 a9 11 00 00       	call   801279 <ipc_send>
		return;
  8000d0:	83 c4 20             	add    $0x20,%esp
	ipc_recv(&who, TEMP_ADDR, 0);
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
			cprintf("child received correct message\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 f4 22 80 00       	push   $0x8022f4
  8000dd:	e8 b2 01 00 00       	call   800294 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb b3                	jmp    80009a <umain+0x67>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 ad 0b 00 00       	call   800cac <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 04 30 80 00    	pushl  0x803004
  800108:	e8 6f 07 00 00       	call   80087c <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	83 c0 01             	add    $0x1,%eax
  800113:	50                   	push   %eax
  800114:	ff 35 04 30 80 00    	pushl  0x803004
  80011a:	68 00 00 a0 00       	push   $0xa00000
  80011f:	e8 85 09 00 00       	call   800aa9 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800124:	6a 07                	push   $0x7
  800126:	68 00 00 a0 00       	push   $0xa00000
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 f4             	pushl  -0xc(%ebp)
  800130:	e8 44 11 00 00       	call   801279 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  800135:	83 c4 1c             	add    $0x1c,%esp
  800138:	6a 00                	push   $0x0
  80013a:	68 00 00 a0 00       	push   $0xa00000
  80013f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 d0 10 00 00       	call   801218 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	68 00 00 a0 00       	push   $0xa00000
  800150:	ff 75 f4             	pushl  -0xc(%ebp)
  800153:	68 e0 22 80 00       	push   $0x8022e0
  800158:	e8 37 01 00 00       	call   800294 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 35 00 30 80 00    	pushl  0x803000
  800166:	e8 11 07 00 00       	call   80087c <strlen>
  80016b:	83 c4 0c             	add    $0xc,%esp
  80016e:	50                   	push   %eax
  80016f:	ff 35 00 30 80 00    	pushl  0x803000
  800175:	68 00 00 a0 00       	push   $0xa00000
  80017a:	e8 00 08 00 00       	call   80097f <strncmp>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	0f 85 49 ff ff ff    	jne    8000d3 <umain+0xa0>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 14 23 80 00       	push   $0x802314
  800192:	e8 fd 00 00 00       	call   800294 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	e9 34 ff ff ff       	jmp    8000d3 <umain+0xa0>

0080019f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8001aa:	e8 bf 0a 00 00       	call   800c6e <sys_getenvid>
  8001af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7e 07                	jle    8001cc <libmain+0x2d>
		binaryname = argv[0];
  8001c5:	8b 06                	mov    (%esi),%eax
  8001c7:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 5d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d6:	e8 0a 00 00 00       	call   8001e5 <exit>
}
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001eb:	e8 e5 12 00 00       	call   8014d5 <close_all>
	sys_env_destroy(0);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 33 0a 00 00       	call   800c2d <sys_env_destroy>
}
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	74 09                	je     800227 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800225:	c9                   	leave  
  800226:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	68 ff 00 00 00       	push   $0xff
  80022f:	8d 43 08             	lea    0x8(%ebx),%eax
  800232:	50                   	push   %eax
  800233:	e8 b8 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  800238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	eb db                	jmp    80021e <putch+0x1f>

00800243 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	68 ff 01 80 00       	push   $0x8001ff
  800272:	e8 1a 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800280:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800286:	50                   	push   %eax
  800287:	e8 64 09 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  80028c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 9d ff ff ff       	call   800243 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 1c             	sub    $0x1c,%esp
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 05                	jb     8002d8 <printnum+0x30>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	77 7a                	ja     800352 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f7:	e8 94 1d 00 00       	call   802090 <__udivdi3>
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	52                   	push   %edx
  800300:	50                   	push   %eax
  800301:	89 f2                	mov    %esi,%edx
  800303:	89 f8                	mov    %edi,%eax
  800305:	e8 9e ff ff ff       	call   8002a8 <printnum>
  80030a:	83 c4 20             	add    $0x20,%esp
  80030d:	eb 13                	jmp    800322 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	56                   	push   %esi
  800313:	ff 75 18             	pushl  0x18(%ebp)
  800316:	ff d7                	call   *%edi
  800318:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	85 db                	test   %ebx,%ebx
  800320:	7f ed                	jg     80030f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	56                   	push   %esi
  800326:	83 ec 04             	sub    $0x4,%esp
  800329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032c:	ff 75 e0             	pushl  -0x20(%ebp)
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	e8 76 1e 00 00       	call   8021b0 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 8c 23 80 00 	movsbl 0x80238c(%eax),%eax
  800344:	50                   	push   %eax
  800345:	ff d7                	call   *%edi
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    
  800352:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800355:	eb c4                	jmp    80031b <printnum+0x73>

00800357 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 0a                	jae    800372 <sprintputch+0x1b>
		*b->buf++ = ch;
  800368:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036b:	89 08                	mov    %ecx,(%eax)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	88 02                	mov    %al,(%edx)
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <printfmt>:
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	e8 05 00 00 00       	call   800391 <vprintfmt>
}
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 2c             	sub    $0x2c,%esp
  80039a:	8b 75 08             	mov    0x8(%ebp),%esi
  80039d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a3:	e9 c1 03 00 00       	jmp    800769 <vprintfmt+0x3d8>
		padc = ' ';
  8003a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003c1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 47 01             	lea    0x1(%edi),%eax
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	0f b6 17             	movzbl (%edi),%edx
  8003cf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 12 04 00 00    	ja     8007ec <vprintfmt+0x45b>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003eb:	eb d9                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f4:	eb d0                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	0f b6 d2             	movzbl %dl,%edx
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800401:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800404:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800407:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80040b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800411:	83 f9 09             	cmp    $0x9,%ecx
  800414:	77 55                	ja     80046b <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800416:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800419:	eb e9                	jmp    800404 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 40 04             	lea    0x4(%eax),%eax
  800429:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	79 91                	jns    8003c6 <vprintfmt+0x35>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	eb 82                	jmp    8003c6 <vprintfmt+0x35>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	e9 6a ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800466:	e9 5b ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80046b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800471:	eb bc                	jmp    80042f <vprintfmt+0x9e>
			lflag++;
  800473:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800479:	e9 48 ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 78 04             	lea    0x4(%eax),%edi
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 30                	pushl  (%eax)
  80048a:	ff d6                	call   *%esi
			break;
  80048c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800492:	e9 cf 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 78 04             	lea    0x4(%eax),%edi
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 0f             	cmp    $0xf,%eax
  8004a7:	7f 23                	jg     8004cc <vprintfmt+0x13b>
  8004a9:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 18                	je     8004cc <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004b4:	52                   	push   %edx
  8004b5:	68 b1 28 80 00       	push   $0x8028b1
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 b3 fe ff ff       	call   800374 <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c7:	e9 9a 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004cc:	50                   	push   %eax
  8004cd:	68 a4 23 80 00       	push   $0x8023a4
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 9b fe ff ff       	call   800374 <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 82 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	b8 9d 23 80 00       	mov    $0x80239d,%eax
  8004f9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	0f 8e bd 00 00 00    	jle    8005c3 <vprintfmt+0x232>
  800506:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050a:	75 0e                	jne    80051a <vprintfmt+0x189>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	eb 6d                	jmp    800587 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 6e 03 00 00       	call   800894 <strnlen>
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ed                	jg     80053f <vprintfmt+0x1ae>
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	0f 49 c1             	cmovns %ecx,%eax
  800562:	29 c1                	sub    %eax,%ecx
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	eb 16                	jmp    800587 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800575:	75 31                	jne    8005a8 <vprintfmt+0x217>
					putch(ch, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 0c             	pushl  0xc(%ebp)
  80057d:	50                   	push   %eax
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80058e:	0f be c2             	movsbl %dl,%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	74 59                	je     8005ee <vprintfmt+0x25d>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 d8                	js     800571 <vprintfmt+0x1e0>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 d3                	jns    800571 <vprintfmt+0x1e0>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 37                	jmp    8005df <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a8:	0f be d2             	movsbl %dl,%edx
  8005ab:	83 ea 20             	sub    $0x20,%edx
  8005ae:	83 fa 5e             	cmp    $0x5e,%edx
  8005b1:	76 c4                	jbe    800577 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 0c             	pushl  0xc(%ebp)
  8005b9:	6a 3f                	push   $0x3f
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb c1                	jmp    800584 <vprintfmt+0x1f3>
  8005c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cf:	eb b6                	jmp    800587 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d9:	83 ef 01             	sub    $0x1,%edi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 ff                	test   %edi,%edi
  8005e1:	7f ee                	jg     8005d1 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	e9 78 01 00 00       	jmp    800766 <vprintfmt+0x3d5>
  8005ee:	89 df                	mov    %ebx,%edi
  8005f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	eb e7                	jmp    8005df <vprintfmt+0x24e>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7e 3f                	jle    80063c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 50 04             	mov    0x4(%eax),%edx
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 08             	lea    0x8(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800614:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800618:	79 5c                	jns    800676 <vprintfmt+0x2e5>
				putch('-', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 2d                	push   $0x2d
  800620:	ff d6                	call   *%esi
				num = -(long long) num;
  800622:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800625:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800628:	f7 da                	neg    %edx
  80062a:	83 d1 00             	adc    $0x0,%ecx
  80062d:	f7 d9                	neg    %ecx
  80062f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 10 01 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	75 1b                	jne    80065b <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	eb b9                	jmp    800614 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	89 c1                	mov    %eax,%ecx
  800665:	c1 f9 1f             	sar    $0x1f,%ecx
  800668:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	eb 9e                	jmp    800614 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	e9 c6 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  800686:	83 f9 01             	cmp    $0x1,%ecx
  800689:	7e 18                	jle    8006a3 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8b 48 04             	mov    0x4(%eax),%ecx
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800699:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069e:	e9 a9 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	75 1a                	jne    8006c1 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	e9 8b 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d6:	eb 74                	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	7e 15                	jle    8006f2 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8006eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f0:	eb 5a                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	75 17                	jne    80070d <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800706:	b8 08 00 00 00       	mov    $0x8,%eax
  80070b:	eb 3f                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
  800722:	eb 28                	jmp    80074c <vprintfmt+0x3bb>
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800753:	57                   	push   %edi
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	50                   	push   %eax
  800758:	51                   	push   %ecx
  800759:	52                   	push   %edx
  80075a:	89 da                	mov    %ebx,%edx
  80075c:	89 f0                	mov    %esi,%eax
  80075e:	e8 45 fb ff ff       	call   8002a8 <printnum>
			break;
  800763:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800769:	83 c7 01             	add    $0x1,%edi
  80076c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800770:	83 f8 25             	cmp    $0x25,%eax
  800773:	0f 84 2f fc ff ff    	je     8003a8 <vprintfmt+0x17>
			if (ch == '\0')
  800779:	85 c0                	test   %eax,%eax
  80077b:	0f 84 8b 00 00 00    	je     80080c <vprintfmt+0x47b>
			putch(ch, putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	ff d6                	call   *%esi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb dc                	jmp    800769 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80078d:	83 f9 01             	cmp    $0x1,%ecx
  800790:	7e 15                	jle    8007a7 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8b 48 04             	mov    0x4(%eax),%ecx
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a5:	eb a5                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	75 17                	jne    8007c2 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb 8a                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d7:	e9 70 ff ff ff       	jmp    80074c <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			break;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	e9 7a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
			putch('%', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	6a 25                	push   $0x25
  8007f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	eb 03                	jmp    8007fe <vprintfmt+0x46d>
  8007fb:	83 e8 01             	sub    $0x1,%eax
  8007fe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800802:	75 f7                	jne    8007fb <vprintfmt+0x46a>
  800804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800807:	e9 5a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 57 03 80 00       	push   $0x800357
  800848:	e8 44 fb ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800860:	eb f7                	jmp    800859 <vsnprintf+0x45>

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	74 06                	je     8008b1 <strnlen+0x1d>
  8008ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
	return n;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	75 ef                	jne    8008bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 9c ff ff ff       	call   80087c <strlen>
  8008e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	01 d8                	add    %ebx,%eax
  8008e8:	50                   	push   %eax
  8008e9:	e8 c5 ff ff ff       	call   8008b3 <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	89 f3                	mov    %esi,%ebx
  800902:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	89 f2                	mov    %esi,%edx
  800907:	eb 0f                	jmp    800918 <strncpy+0x23>
		*dst++ = *src;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	0f b6 01             	movzbl (%ecx),%eax
  80090f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 39 01             	cmpb   $0x1,(%ecx)
  800915:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800918:	39 da                	cmp    %ebx,%edx
  80091a:	75 ed                	jne    800909 <strncpy+0x14>
	}
	return ret;
}
  80091c:	89 f0                	mov    %esi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800930:	89 f0                	mov    %esi,%eax
  800932:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 c9                	test   %ecx,%ecx
  800938:	75 0b                	jne    800945 <strlcpy+0x23>
  80093a:	eb 17                	jmp    800953 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800945:	39 d8                	cmp    %ebx,%eax
  800947:	74 07                	je     800950 <strlcpy+0x2e>
  800949:	0f b6 0a             	movzbl (%edx),%ecx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 ec                	jne    80093c <strlcpy+0x1a>
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800953:	29 f0                	sub    %esi,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	eb 06                	jmp    80096a <strcmp+0x11>
		p++, q++;
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1c>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 ef                	je     800964 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c3                	mov    %eax,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098e:	eb 06                	jmp    800996 <strncmp+0x17>
		n--, p++, q++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800996:	39 d8                	cmp    %ebx,%eax
  800998:	74 16                	je     8009b0 <strncmp+0x31>
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	74 04                	je     8009a5 <strncmp+0x26>
  8009a1:	3a 0a                	cmp    (%edx),%cl
  8009a3:	74 eb                	je     800990 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb f6                	jmp    8009ad <strncmp+0x2e>

008009b7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	0f b6 10             	movzbl (%eax),%edx
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	74 09                	je     8009d1 <strchr+0x1a>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0a                	je     8009d6 <strchr+0x1f>
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f0                	jmp    8009c1 <strchr+0xa>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	eb 03                	jmp    8009e7 <strfind+0xf>
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 04                	je     8009f2 <strfind+0x1a>
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	75 f2                	jne    8009e4 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 13                	je     800a17 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 05                	jne    800a11 <memset+0x1d>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	74 0d                	je     800a1e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	fc                   	cld    
  800a15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
		c &= 0xFF;
  800a1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a22:	89 d3                	mov    %edx,%ebx
  800a24:	c1 e3 08             	shl    $0x8,%ebx
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 18             	shl    $0x18,%eax
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	c1 e6 10             	shl    $0x10,%esi
  800a31:	09 f0                	or     %esi,%eax
  800a33:	09 c2                	or     %eax,%edx
  800a35:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3a:	89 d0                	mov    %edx,%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3f:	eb d6                	jmp    800a17 <memset+0x23>

00800a41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4f:	39 c6                	cmp    %eax,%esi
  800a51:	73 35                	jae    800a88 <memmove+0x47>
  800a53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a56:	39 c2                	cmp    %eax,%edx
  800a58:	76 2e                	jbe    800a88 <memmove+0x47>
		s += n;
		d += n;
  800a5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	09 fe                	or     %edi,%esi
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	74 0c                	je     800a75 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6f:	fd                   	std    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a72:	fc                   	cld    
  800a73:	eb 21                	jmp    800a96 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 ef                	jne    800a69 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb ea                	jmp    800a72 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	09 c2                	or     %eax,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	74 09                	je     800a9a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 f2                	jne    800a91 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb ed                	jmp    800a96 <memmove+0x55>

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	ff 75 08             	pushl  0x8(%ebp)
  800ab5:	e8 87 ff ff ff       	call   800a41 <memmove>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 f0                	cmp    %esi,%eax
  800ace:	74 1c                	je     800aec <memcmp+0x30>
		if (*s1 != *s2)
  800ad0:	0f b6 08             	movzbl (%eax),%ecx
  800ad3:	0f b6 1a             	movzbl (%edx),%ebx
  800ad6:	38 d9                	cmp    %bl,%cl
  800ad8:	75 08                	jne    800ae2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	83 c2 01             	add    $0x1,%edx
  800ae0:	eb ea                	jmp    800acc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ae2:	0f b6 c1             	movzbl %cl,%eax
  800ae5:	0f b6 db             	movzbl %bl,%ebx
  800ae8:	29 d8                	sub    %ebx,%eax
  800aea:	eb 05                	jmp    800af1 <memcmp+0x35>
	}

	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b03:	39 d0                	cmp    %edx,%eax
  800b05:	73 09                	jae    800b10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	38 08                	cmp    %cl,(%eax)
  800b09:	74 05                	je     800b10 <memfind+0x1b>
	for (; s < ends; s++)
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	eb f3                	jmp    800b03 <memfind+0xe>
			break;
	return (void *) s;
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1e:	eb 03                	jmp    800b23 <strtol+0x11>
		s++;
  800b20:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b23:	0f b6 01             	movzbl (%ecx),%eax
  800b26:	3c 20                	cmp    $0x20,%al
  800b28:	74 f6                	je     800b20 <strtol+0xe>
  800b2a:	3c 09                	cmp    $0x9,%al
  800b2c:	74 f2                	je     800b20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2e:	3c 2b                	cmp    $0x2b,%al
  800b30:	74 2e                	je     800b60 <strtol+0x4e>
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b37:	3c 2d                	cmp    $0x2d,%al
  800b39:	74 2f                	je     800b6a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b41:	75 05                	jne    800b48 <strtol+0x36>
  800b43:	80 39 30             	cmpb   $0x30,(%ecx)
  800b46:	74 2c                	je     800b74 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	75 0a                	jne    800b56 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b51:	80 39 30             	cmpb   $0x30,(%ecx)
  800b54:	74 28                	je     800b7e <strtol+0x6c>
		base = 10;
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5e:	eb 50                	jmp    800bb0 <strtol+0x9e>
		s++;
  800b60:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
  800b68:	eb d1                	jmp    800b3b <strtol+0x29>
		s++, neg = 1;
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b72:	eb c7                	jmp    800b3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b78:	74 0e                	je     800b88 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	75 d8                	jne    800b56 <strtol+0x44>
		s++, base = 8;
  800b7e:	83 c1 01             	add    $0x1,%ecx
  800b81:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b86:	eb ce                	jmp    800b56 <strtol+0x44>
		s += 2, base = 16;
  800b88:	83 c1 02             	add    $0x2,%ecx
  800b8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b90:	eb c4                	jmp    800b56 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 29                	ja     800bc5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 30                	jge    800bd7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bae:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb0:	0f b6 11             	movzbl (%ecx),%edx
  800bb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 09             	cmp    $0x9,%bl
  800bbb:	77 d5                	ja     800b92 <strtol+0x80>
			dig = *s - '0';
  800bbd:	0f be d2             	movsbl %dl,%edx
  800bc0:	83 ea 30             	sub    $0x30,%edx
  800bc3:	eb dd                	jmp    800ba2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bc5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc8:	89 f3                	mov    %esi,%ebx
  800bca:	80 fb 19             	cmp    $0x19,%bl
  800bcd:	77 08                	ja     800bd7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bcf:	0f be d2             	movsbl %dl,%edx
  800bd2:	83 ea 37             	sub    $0x37,%edx
  800bd5:	eb cb                	jmp    800ba2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdb:	74 05                	je     800be2 <strtol+0xd0>
		*endptr = (char *) s;
  800bdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be2:	89 c2                	mov    %eax,%edx
  800be4:	f7 da                	neg    %edx
  800be6:	85 ff                	test   %edi,%edi
  800be8:	0f 45 c2             	cmovne %edx,%eax
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	89 c6                	mov    %eax,%esi
  800c07:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 03                	push   $0x3
  800c5d:	68 7f 26 80 00       	push   $0x80267f
  800c62:	6a 23                	push   $0x23
  800c64:	68 9c 26 80 00       	push   $0x80269c
  800c69:	e8 7a 13 00 00       	call   801fe8 <_panic>

00800c6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_yield>:

void
sys_yield(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	89 d3                	mov    %edx,%ebx
  800ca1:	89 d7                	mov    %edx,%edi
  800ca3:	89 d6                	mov    %edx,%esi
  800ca5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	be 00 00 00 00       	mov    $0x0,%esi
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	89 f7                	mov    %esi,%edi
  800cca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7f 08                	jg     800cd8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 04                	push   $0x4
  800cde:	68 7f 26 80 00       	push   $0x80267f
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 9c 26 80 00       	push   $0x80269c
  800cea:	e8 f9 12 00 00       	call   801fe8 <_panic>

00800cef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7f 08                	jg     800d1a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 05                	push   $0x5
  800d20:	68 7f 26 80 00       	push   $0x80267f
  800d25:	6a 23                	push   $0x23
  800d27:	68 9c 26 80 00       	push   $0x80269c
  800d2c:	e8 b7 12 00 00       	call   801fe8 <_panic>

00800d31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 06                	push   $0x6
  800d62:	68 7f 26 80 00       	push   $0x80267f
  800d67:	6a 23                	push   $0x23
  800d69:	68 9c 26 80 00       	push   $0x80269c
  800d6e:	e8 75 12 00 00       	call   801fe8 <_panic>

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 08                	push   $0x8
  800da4:	68 7f 26 80 00       	push   $0x80267f
  800da9:	6a 23                	push   $0x23
  800dab:	68 9c 26 80 00       	push   $0x80269c
  800db0:	e8 33 12 00 00       	call   801fe8 <_panic>

00800db5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7f 08                	jg     800de0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 09                	push   $0x9
  800de6:	68 7f 26 80 00       	push   $0x80267f
  800deb:	6a 23                	push   $0x23
  800ded:	68 9c 26 80 00       	push   $0x80269c
  800df2:	e8 f1 11 00 00       	call   801fe8 <_panic>

00800df7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 0a                	push   $0xa
  800e28:	68 7f 26 80 00       	push   $0x80267f
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 9c 26 80 00       	push   $0x80269c
  800e34:	e8 af 11 00 00       	call   801fe8 <_panic>

00800e39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4a:	be 00 00 00 00       	mov    $0x0,%esi
  800e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e72:	89 cb                	mov    %ecx,%ebx
  800e74:	89 cf                	mov    %ecx,%edi
  800e76:	89 ce                	mov    %ecx,%esi
  800e78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7f 08                	jg     800e86 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 0d                	push   $0xd
  800e8c:	68 7f 26 80 00       	push   $0x80267f
  800e91:	6a 23                	push   $0x23
  800e93:	68 9c 26 80 00       	push   $0x80269c
  800e98:	e8 4b 11 00 00       	call   801fe8 <_panic>

00800e9d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea7:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800ea9:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800eac:	a8 02                	test   $0x2,%al
  800eae:	0f 84 89 00 00 00    	je     800f3d <pgfault+0xa0>
  800eb4:	89 da                	mov    %ebx,%edx
  800eb6:	c1 ea 0c             	shr    $0xc,%edx
  800eb9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec0:	f6 c6 08             	test   $0x8,%dh
  800ec3:	74 78                	je     800f3d <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	6a 07                	push   $0x7
  800eca:	68 00 f0 7f 00       	push   $0x7ff000
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 d6 fd ff ff       	call   800cac <sys_page_alloc>
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	0f 88 8b 00 00 00    	js     800f6c <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	68 00 10 00 00       	push   $0x1000
  800ee9:	53                   	push   %ebx
  800eea:	68 00 f0 7f 00       	push   $0x7ff000
  800eef:	e8 4d fb ff ff       	call   800a41 <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ef4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800efb:	53                   	push   %ebx
  800efc:	6a 00                	push   $0x0
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	6a 00                	push   $0x0
  800f05:	e8 e5 fd ff ff       	call   800cef <sys_page_map>
  800f0a:	83 c4 20             	add    $0x20,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 6d                	js     800f7e <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	68 00 f0 7f 00       	push   $0x7ff000
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 11 fe ff ff       	call   800d31 <sys_page_unmap>
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	78 69                	js     800f90 <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  800f27:	83 ec 08             	sub    $0x8,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	68 08 27 80 00       	push   $0x802708
  800f30:	e8 5f f3 ff ff       	call   800294 <cprintf>

}
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  800f3d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f43:	8b 4a 48             	mov    0x48(%edx),%ecx
  800f46:	89 da                	mov    %ebx,%edx
  800f48:	c1 ea 0c             	shr    $0xc,%edx
  800f4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f52:	51                   	push   %ecx
  800f53:	53                   	push   %ebx
  800f54:	68 00 00 40 ef       	push   $0xef400000
  800f59:	52                   	push   %edx
  800f5a:	50                   	push   %eax
  800f5b:	68 ac 26 80 00       	push   $0x8026ac
  800f60:	6a 1e                	push   $0x1e
  800f62:	68 29 27 80 00       	push   $0x802729
  800f67:	e8 7c 10 00 00       	call   801fe8 <_panic>
        panic("sys_page_alloc error %e", r);
  800f6c:	50                   	push   %eax
  800f6d:	68 34 27 80 00       	push   $0x802734
  800f72:	6a 28                	push   $0x28
  800f74:	68 29 27 80 00       	push   $0x802729
  800f79:	e8 6a 10 00 00       	call   801fe8 <_panic>
        panic("sys_page_map error %e", r);
  800f7e:	50                   	push   %eax
  800f7f:	68 4c 27 80 00       	push   $0x80274c
  800f84:	6a 2b                	push   $0x2b
  800f86:	68 29 27 80 00       	push   $0x802729
  800f8b:	e8 58 10 00 00       	call   801fe8 <_panic>
        panic("sys_page_unmap error %e", r);
  800f90:	50                   	push   %eax
  800f91:	68 62 27 80 00       	push   $0x802762
  800f96:	6a 2d                	push   $0x2d
  800f98:	68 29 27 80 00       	push   $0x802729
  800f9d:	e8 46 10 00 00       	call   801fe8 <_panic>

00800fa2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fa8:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800faf:	74 23                	je     800fd4 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb4:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800fb9:	a1 04 40 80 00       	mov    0x804004,%eax
  800fbe:	8b 40 48             	mov    0x48(%eax),%eax
  800fc1:	83 ec 08             	sub    $0x8,%esp
  800fc4:	68 2e 20 80 00       	push   $0x80202e
  800fc9:	50                   	push   %eax
  800fca:	e8 28 fe ff ff       	call   800df7 <sys_env_set_pgfault_upcall>
}
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800fd4:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd9:	8b 40 48             	mov    0x48(%eax),%eax
  800fdc:	83 ec 04             	sub    $0x4,%esp
  800fdf:	6a 07                	push   $0x7
  800fe1:	68 00 f0 bf ee       	push   $0xeebff000
  800fe6:	50                   	push   %eax
  800fe7:	e8 c0 fc ff ff       	call   800cac <sys_page_alloc>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	79 be                	jns    800fb1 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800ff3:	50                   	push   %eax
  800ff4:	68 7a 27 80 00       	push   $0x80277a
  800ff9:	6a 21                	push   $0x21
  800ffb:	68 8d 27 80 00       	push   $0x80278d
  801000:	e8 e3 0f 00 00       	call   801fe8 <_panic>

00801005 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	8b 75 08             	mov    0x8(%ebp),%esi
  80100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	6a 07                	push   $0x7
  801015:	53                   	push   %ebx
  801016:	56                   	push   %esi
  801017:	e8 90 fc ff ff       	call   800cac <sys_page_alloc>
  80101c:	83 c4 10             	add    $0x10,%esp
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 4a                	js     80106d <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	6a 07                	push   $0x7
  801028:	68 00 00 40 00       	push   $0x400000
  80102d:	6a 00                	push   $0x0
  80102f:	53                   	push   %ebx
  801030:	56                   	push   %esi
  801031:	e8 b9 fc ff ff       	call   800cef <sys_page_map>
  801036:	83 c4 20             	add    $0x20,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 42                	js     80107f <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	68 00 10 00 00       	push   $0x1000
  801045:	53                   	push   %ebx
  801046:	68 00 00 40 00       	push   $0x400000
  80104b:	e8 f1 f9 ff ff       	call   800a41 <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	68 00 00 40 00       	push   $0x400000
  801058:	6a 00                	push   $0x0
  80105a:	e8 d2 fc ff ff       	call   800d31 <sys_page_unmap>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	85 c0                	test   %eax,%eax
  801064:	78 2b                	js     801091 <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  801066:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  80106d:	50                   	push   %eax
  80106e:	68 7a 27 80 00       	push   $0x80277a
  801073:	6a 63                	push   $0x63
  801075:	68 29 27 80 00       	push   $0x802729
  80107a:	e8 69 0f 00 00       	call   801fe8 <_panic>
        panic("sys_page_map: %e", r);
  80107f:	50                   	push   %eax
  801080:	68 9d 27 80 00       	push   $0x80279d
  801085:	6a 65                	push   $0x65
  801087:	68 29 27 80 00       	push   $0x802729
  80108c:	e8 57 0f 00 00       	call   801fe8 <_panic>
        panic("sys_page_unmap: %e", r);
  801091:	50                   	push   %eax
  801092:	68 ae 27 80 00       	push   $0x8027ae
  801097:	6a 68                	push   $0x68
  801099:	68 29 27 80 00       	push   $0x802729
  80109e:	e8 45 0f 00 00       	call   801fe8 <_panic>

008010a3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  8010ac:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b1:	8b 40 64             	mov    0x64(%eax),%eax
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 1f                	je     8010d7 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010b8:	b8 07 00 00 00       	mov    $0x7,%eax
  8010bd:	cd 30                	int    $0x30
  8010bf:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  8010c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	74 21                	je     8010e9 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  8010c8:	be 08 40 80 00       	mov    $0x804008,%esi
  8010cd:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8010d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d5:	eb 7b                	jmp    801152 <fork+0xaf>
        set_pgfault_handler(pgfault);
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	68 9d 0e 80 00       	push   $0x800e9d
  8010df:	e8 be fe ff ff       	call   800fa2 <set_pgfault_handler>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	eb cf                	jmp    8010b8 <fork+0x15>
        set_pgfault_handler(pgfault);
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	68 9d 0e 80 00       	push   $0x800e9d
  8010f1:	e8 ac fe ff ff       	call   800fa2 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  8010f6:	e8 73 fb ff ff       	call   800c6e <sys_getenvid>
  8010fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801108:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	e9 ca 00 00 00       	jmp    8011df <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801115:	89 d1                	mov    %edx,%ecx
  801117:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  80111d:	81 e2 02 08 00 00    	and    $0x802,%edx
  801123:	89 cf                	mov    %ecx,%edi
  801125:	81 cf 00 08 00 00    	or     $0x800,%edi
  80112b:	85 d2                	test   %edx,%edx
  80112d:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	51                   	push   %ecx
  801134:	50                   	push   %eax
  801135:	ff 75 e4             	pushl  -0x1c(%ebp)
  801138:	50                   	push   %eax
  801139:	6a 00                	push   $0x0
  80113b:	e8 af fb ff ff       	call   800cef <sys_page_map>
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 45                	js     80118c <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801147:	83 c3 01             	add    $0x1,%ebx
  80114a:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  801150:	74 4c                	je     80119e <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801152:	39 de                	cmp    %ebx,%esi
  801154:	74 f1                	je     801147 <fork+0xa4>
  801156:	89 d8                	mov    %ebx,%eax
  801158:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	c1 ea 16             	shr    $0x16,%edx
  801160:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801167:	f6 c2 05             	test   $0x5,%dl
  80116a:	74 db                	je     801147 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	c1 ea 0c             	shr    $0xc,%edx
  801171:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801178:	f6 c2 04             	test   $0x4,%dl
  80117b:	74 ca                	je     801147 <fork+0xa4>
    if (perm & PTE_SHARE) {
  80117d:	f6 c6 04             	test   $0x4,%dh
  801180:	74 93                	je     801115 <fork+0x72>
        perm &= ~PTE_COW;
  801182:	89 d1                	mov    %edx,%ecx
  801184:	81 e1 07 06 00 00    	and    $0x607,%ecx
  80118a:	eb a4                	jmp    801130 <fork+0x8d>
        panic("sys_page_map error %e", r);
  80118c:	50                   	push   %eax
  80118d:	68 4c 27 80 00       	push   $0x80274c
  801192:	6a 57                	push   $0x57
  801194:	68 29 27 80 00       	push   $0x802729
  801199:	e8 4a 0e 00 00       	call   801fe8 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	b8 08 40 80 00       	mov    $0x804008,%eax
  8011a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ab:	50                   	push   %eax
  8011ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011af:	e8 51 fe ff ff       	call   801005 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c3:	e8 3d fe ff ff       	call   801005 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8011c8:	83 c4 08             	add    $0x8,%esp
  8011cb:	6a 02                	push   $0x2
  8011cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d0:	e8 9e fb ff ff       	call   800d73 <sys_env_set_status>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 0d                	js     8011e9 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8011dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  8011df:	89 d8                	mov    %ebx,%eax
  8011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5f                   	pop    %edi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  8011e9:	50                   	push   %eax
  8011ea:	68 c1 27 80 00       	push   $0x8027c1
  8011ef:	68 a0 00 00 00       	push   $0xa0
  8011f4:	68 29 27 80 00       	push   $0x802729
  8011f9:	e8 ea 0d 00 00       	call   801fe8 <_panic>

008011fe <sfork>:

// Challenge!
int
sfork(void)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801204:	68 d8 27 80 00       	push   $0x8027d8
  801209:	68 a9 00 00 00       	push   $0xa9
  80120e:	68 29 27 80 00       	push   $0x802729
  801213:	e8 d0 0d 00 00       	call   801fe8 <_panic>

00801218 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	8b 75 08             	mov    0x8(%ebp),%esi
  801220:	8b 45 0c             	mov    0xc(%ebp),%eax
  801223:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801226:	85 c0                	test   %eax,%eax
  801228:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80122d:	0f 44 c2             	cmove  %edx,%eax
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	50                   	push   %eax
  801234:	e8 23 fc ff ff       	call   800e5c <sys_ipc_recv>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 2b                	js     80126b <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801240:	85 f6                	test   %esi,%esi
  801242:	74 0a                	je     80124e <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801244:	a1 04 40 80 00       	mov    0x804004,%eax
  801249:	8b 40 74             	mov    0x74(%eax),%eax
  80124c:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  80124e:	85 db                	test   %ebx,%ebx
  801250:	74 0a                	je     80125c <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801252:	a1 04 40 80 00       	mov    0x804004,%eax
  801257:	8b 40 78             	mov    0x78(%eax),%eax
  80125a:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  80125c:	a1 04 40 80 00       	mov    0x804004,%eax
  801261:	8b 40 70             	mov    0x70(%eax),%eax
}
  801264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
        *from_env_store = 0;
  80126b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801271:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801277:	eb eb                	jmp    801264 <ipc_recv+0x4c>

00801279 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	8b 7d 08             	mov    0x8(%ebp),%edi
  801285:	8b 75 0c             	mov    0xc(%ebp),%esi
  801288:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  80128b:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80128d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801292:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801295:	ff 75 14             	pushl  0x14(%ebp)
  801298:	53                   	push   %ebx
  801299:	56                   	push   %esi
  80129a:	57                   	push   %edi
  80129b:	e8 99 fb ff ff       	call   800e39 <sys_ipc_try_send>
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 17                	je     8012be <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  8012a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012aa:	74 e9                	je     801295 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  8012ac:	50                   	push   %eax
  8012ad:	68 ee 27 80 00       	push   $0x8027ee
  8012b2:	6a 3e                	push   $0x3e
  8012b4:	68 00 28 80 00       	push   $0x802800
  8012b9:	e8 2a 0d 00 00       	call   801fe8 <_panic>
        }
    }
}
  8012be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012da:	8b 52 50             	mov    0x50(%edx),%edx
  8012dd:	39 ca                	cmp    %ecx,%edx
  8012df:	74 11                	je     8012f2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8012e1:	83 c0 01             	add    $0x1,%eax
  8012e4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012e9:	75 e6                	jne    8012d1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f0:	eb 0b                	jmp    8012fd <ipc_find_env+0x37>
			return envs[i].env_id;
  8012f2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012f5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012fa:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	05 00 00 00 30       	add    $0x30000000,%eax
  80130a:	c1 e8 0c             	shr    $0xc,%eax
}
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80131a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80131f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 16             	shr    $0x16,%edx
  801336:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 2a                	je     80136c <fd_alloc+0x46>
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 0c             	shr    $0xc,%edx
  801347:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	74 19                	je     80136c <fd_alloc+0x46>
  801353:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801358:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80135d:	75 d2                	jne    801331 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80135f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801365:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80136a:	eb 07                	jmp    801373 <fd_alloc+0x4d>
			*fd_store = fd;
  80136c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80137b:	83 f8 1f             	cmp    $0x1f,%eax
  80137e:	77 36                	ja     8013b6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801380:	c1 e0 0c             	shl    $0xc,%eax
  801383:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801388:	89 c2                	mov    %eax,%edx
  80138a:	c1 ea 16             	shr    $0x16,%edx
  80138d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801394:	f6 c2 01             	test   $0x1,%dl
  801397:	74 24                	je     8013bd <fd_lookup+0x48>
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 0c             	shr    $0xc,%edx
  80139e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 1a                	je     8013c4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
		return -E_INVAL;
  8013b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bb:	eb f7                	jmp    8013b4 <fd_lookup+0x3f>
		return -E_INVAL;
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c2:	eb f0                	jmp    8013b4 <fd_lookup+0x3f>
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c9:	eb e9                	jmp    8013b4 <fd_lookup+0x3f>

008013cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	ba 88 28 80 00       	mov    $0x802888,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013d9:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013de:	39 08                	cmp    %ecx,(%eax)
  8013e0:	74 33                	je     801415 <dev_lookup+0x4a>
  8013e2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013e5:	8b 02                	mov    (%edx),%eax
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	75 f3                	jne    8013de <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f0:	8b 40 48             	mov    0x48(%eax),%eax
  8013f3:	83 ec 04             	sub    $0x4,%esp
  8013f6:	51                   	push   %ecx
  8013f7:	50                   	push   %eax
  8013f8:	68 0c 28 80 00       	push   $0x80280c
  8013fd:	e8 92 ee ff ff       	call   800294 <cprintf>
	*dev = 0;
  801402:	8b 45 0c             	mov    0xc(%ebp),%eax
  801405:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801413:	c9                   	leave  
  801414:	c3                   	ret    
			*dev = devtab[i];
  801415:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801418:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	eb f2                	jmp    801413 <dev_lookup+0x48>

00801421 <fd_close>:
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	57                   	push   %edi
  801425:	56                   	push   %esi
  801426:	53                   	push   %ebx
  801427:	83 ec 1c             	sub    $0x1c,%esp
  80142a:	8b 75 08             	mov    0x8(%ebp),%esi
  80142d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801430:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801433:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801434:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80143a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143d:	50                   	push   %eax
  80143e:	e8 32 ff ff ff       	call   801375 <fd_lookup>
  801443:	89 c3                	mov    %eax,%ebx
  801445:	83 c4 08             	add    $0x8,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 05                	js     801451 <fd_close+0x30>
	    || fd != fd2)
  80144c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80144f:	74 16                	je     801467 <fd_close+0x46>
		return (must_exist ? r : 0);
  801451:	89 f8                	mov    %edi,%eax
  801453:	84 c0                	test   %al,%al
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	0f 44 d8             	cmove  %eax,%ebx
}
  80145d:	89 d8                	mov    %ebx,%eax
  80145f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801462:	5b                   	pop    %ebx
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	ff 36                	pushl  (%esi)
  801470:	e8 56 ff ff ff       	call   8013cb <dev_lookup>
  801475:	89 c3                	mov    %eax,%ebx
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 15                	js     801493 <fd_close+0x72>
		if (dev->dev_close)
  80147e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801481:	8b 40 10             	mov    0x10(%eax),%eax
  801484:	85 c0                	test   %eax,%eax
  801486:	74 1b                	je     8014a3 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	56                   	push   %esi
  80148c:	ff d0                	call   *%eax
  80148e:	89 c3                	mov    %eax,%ebx
  801490:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	56                   	push   %esi
  801497:	6a 00                	push   $0x0
  801499:	e8 93 f8 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	eb ba                	jmp    80145d <fd_close+0x3c>
			r = 0;
  8014a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a8:	eb e9                	jmp    801493 <fd_close+0x72>

008014aa <close>:

int
close(int fdnum)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 08             	pushl  0x8(%ebp)
  8014b7:	e8 b9 fe ff ff       	call   801375 <fd_lookup>
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 10                	js     8014d3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	6a 01                	push   $0x1
  8014c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cb:	e8 51 ff ff ff       	call   801421 <fd_close>
  8014d0:	83 c4 10             	add    $0x10,%esp
}
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <close_all>:

void
close_all(void)
{
  8014d5:	55                   	push   %ebp
  8014d6:	89 e5                	mov    %esp,%ebp
  8014d8:	53                   	push   %ebx
  8014d9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014dc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	e8 c0 ff ff ff       	call   8014aa <close>
	for (i = 0; i < MAXFD; i++)
  8014ea:	83 c3 01             	add    $0x1,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	83 fb 20             	cmp    $0x20,%ebx
  8014f3:	75 ec                	jne    8014e1 <close_all+0xc>
}
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801503:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	ff 75 08             	pushl  0x8(%ebp)
  80150a:	e8 66 fe ff ff       	call   801375 <fd_lookup>
  80150f:	89 c3                	mov    %eax,%ebx
  801511:	83 c4 08             	add    $0x8,%esp
  801514:	85 c0                	test   %eax,%eax
  801516:	0f 88 81 00 00 00    	js     80159d <dup+0xa3>
		return r;
	close(newfdnum);
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	ff 75 0c             	pushl  0xc(%ebp)
  801522:	e8 83 ff ff ff       	call   8014aa <close>

	newfd = INDEX2FD(newfdnum);
  801527:	8b 75 0c             	mov    0xc(%ebp),%esi
  80152a:	c1 e6 0c             	shl    $0xc,%esi
  80152d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801533:	83 c4 04             	add    $0x4,%esp
  801536:	ff 75 e4             	pushl  -0x1c(%ebp)
  801539:	e8 d1 fd ff ff       	call   80130f <fd2data>
  80153e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801540:	89 34 24             	mov    %esi,(%esp)
  801543:	e8 c7 fd ff ff       	call   80130f <fd2data>
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	c1 e8 16             	shr    $0x16,%eax
  801552:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801559:	a8 01                	test   $0x1,%al
  80155b:	74 11                	je     80156e <dup+0x74>
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	c1 e8 0c             	shr    $0xc,%eax
  801562:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801569:	f6 c2 01             	test   $0x1,%dl
  80156c:	75 39                	jne    8015a7 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80156e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801571:	89 d0                	mov    %edx,%eax
  801573:	c1 e8 0c             	shr    $0xc,%eax
  801576:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80157d:	83 ec 0c             	sub    $0xc,%esp
  801580:	25 07 0e 00 00       	and    $0xe07,%eax
  801585:	50                   	push   %eax
  801586:	56                   	push   %esi
  801587:	6a 00                	push   $0x0
  801589:	52                   	push   %edx
  80158a:	6a 00                	push   $0x0
  80158c:	e8 5e f7 ff ff       	call   800cef <sys_page_map>
  801591:	89 c3                	mov    %eax,%ebx
  801593:	83 c4 20             	add    $0x20,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	78 31                	js     8015cb <dup+0xd1>
		goto err;

	return newfdnum;
  80159a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a2:	5b                   	pop    %ebx
  8015a3:	5e                   	pop    %esi
  8015a4:	5f                   	pop    %edi
  8015a5:	5d                   	pop    %ebp
  8015a6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8015b6:	50                   	push   %eax
  8015b7:	57                   	push   %edi
  8015b8:	6a 00                	push   $0x0
  8015ba:	53                   	push   %ebx
  8015bb:	6a 00                	push   $0x0
  8015bd:	e8 2d f7 ff ff       	call   800cef <sys_page_map>
  8015c2:	89 c3                	mov    %eax,%ebx
  8015c4:	83 c4 20             	add    $0x20,%esp
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	79 a3                	jns    80156e <dup+0x74>
	sys_page_unmap(0, newfd);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	56                   	push   %esi
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 5b f7 ff ff       	call   800d31 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015d6:	83 c4 08             	add    $0x8,%esp
  8015d9:	57                   	push   %edi
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 50 f7 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb b7                	jmp    80159d <dup+0xa3>

008015e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 14             	sub    $0x14,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	53                   	push   %ebx
  8015f5:	e8 7b fd ff ff       	call   801375 <fd_lookup>
  8015fa:	83 c4 08             	add    $0x8,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 3f                	js     801640 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801607:	50                   	push   %eax
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	ff 30                	pushl  (%eax)
  80160d:	e8 b9 fd ff ff       	call   8013cb <dev_lookup>
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 27                	js     801640 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801619:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161c:	8b 42 08             	mov    0x8(%edx),%eax
  80161f:	83 e0 03             	and    $0x3,%eax
  801622:	83 f8 01             	cmp    $0x1,%eax
  801625:	74 1e                	je     801645 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801627:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162a:	8b 40 08             	mov    0x8(%eax),%eax
  80162d:	85 c0                	test   %eax,%eax
  80162f:	74 35                	je     801666 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801631:	83 ec 04             	sub    $0x4,%esp
  801634:	ff 75 10             	pushl  0x10(%ebp)
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	52                   	push   %edx
  80163b:	ff d0                	call   *%eax
  80163d:	83 c4 10             	add    $0x10,%esp
}
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801645:	a1 04 40 80 00       	mov    0x804004,%eax
  80164a:	8b 40 48             	mov    0x48(%eax),%eax
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	68 4d 28 80 00       	push   $0x80284d
  801657:	e8 38 ec ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801664:	eb da                	jmp    801640 <read+0x5a>
		return -E_NOT_SUPP;
  801666:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80166b:	eb d3                	jmp    801640 <read+0x5a>

0080166d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	57                   	push   %edi
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	8b 7d 08             	mov    0x8(%ebp),%edi
  801679:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801681:	39 f3                	cmp    %esi,%ebx
  801683:	73 25                	jae    8016aa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	89 f0                	mov    %esi,%eax
  80168a:	29 d8                	sub    %ebx,%eax
  80168c:	50                   	push   %eax
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	03 45 0c             	add    0xc(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	57                   	push   %edi
  801694:	e8 4d ff ff ff       	call   8015e6 <read>
		if (m < 0)
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 08                	js     8016a8 <readn+0x3b>
			return m;
		if (m == 0)
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	74 06                	je     8016aa <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8016a4:	01 c3                	add    %eax,%ebx
  8016a6:	eb d9                	jmp    801681 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016aa:	89 d8                	mov    %ebx,%eax
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 14             	sub    $0x14,%esp
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	53                   	push   %ebx
  8016c3:	e8 ad fc ff ff       	call   801375 <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 3a                	js     801709 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d9:	ff 30                	pushl  (%eax)
  8016db:	e8 eb fc ff ff       	call   8013cb <dev_lookup>
  8016e0:	83 c4 10             	add    $0x10,%esp
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 22                	js     801709 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ee:	74 1e                	je     80170e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f6:	85 d2                	test   %edx,%edx
  8016f8:	74 35                	je     80172f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	ff 75 10             	pushl  0x10(%ebp)
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	50                   	push   %eax
  801704:	ff d2                	call   *%edx
  801706:	83 c4 10             	add    $0x10,%esp
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80170e:	a1 04 40 80 00       	mov    0x804004,%eax
  801713:	8b 40 48             	mov    0x48(%eax),%eax
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	53                   	push   %ebx
  80171a:	50                   	push   %eax
  80171b:	68 69 28 80 00       	push   $0x802869
  801720:	e8 6f eb ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172d:	eb da                	jmp    801709 <write+0x55>
		return -E_NOT_SUPP;
  80172f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801734:	eb d3                	jmp    801709 <write+0x55>

00801736 <seek>:

int
seek(int fdnum, off_t offset)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173f:	50                   	push   %eax
  801740:	ff 75 08             	pushl  0x8(%ebp)
  801743:	e8 2d fc ff ff       	call   801375 <fd_lookup>
  801748:	83 c4 08             	add    $0x8,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 0e                	js     80175d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80174f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801752:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801755:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801758:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 14             	sub    $0x14,%esp
  801766:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801769:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176c:	50                   	push   %eax
  80176d:	53                   	push   %ebx
  80176e:	e8 02 fc ff ff       	call   801375 <fd_lookup>
  801773:	83 c4 08             	add    $0x8,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	78 37                	js     8017b1 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801784:	ff 30                	pushl  (%eax)
  801786:	e8 40 fc ff ff       	call   8013cb <dev_lookup>
  80178b:	83 c4 10             	add    $0x10,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 1f                	js     8017b1 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801795:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801799:	74 1b                	je     8017b6 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80179b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179e:	8b 52 18             	mov    0x18(%edx),%edx
  8017a1:	85 d2                	test   %edx,%edx
  8017a3:	74 32                	je     8017d7 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	ff 75 0c             	pushl  0xc(%ebp)
  8017ab:	50                   	push   %eax
  8017ac:	ff d2                	call   *%edx
  8017ae:	83 c4 10             	add    $0x10,%esp
}
  8017b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b4:	c9                   	leave  
  8017b5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017b6:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017bb:	8b 40 48             	mov    0x48(%eax),%eax
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	53                   	push   %ebx
  8017c2:	50                   	push   %eax
  8017c3:	68 2c 28 80 00       	push   $0x80282c
  8017c8:	e8 c7 ea ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d5:	eb da                	jmp    8017b1 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8017d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017dc:	eb d3                	jmp    8017b1 <ftruncate+0x52>

008017de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 14             	sub    $0x14,%esp
  8017e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	ff 75 08             	pushl  0x8(%ebp)
  8017ef:	e8 81 fb ff ff       	call   801375 <fd_lookup>
  8017f4:	83 c4 08             	add    $0x8,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 4b                	js     801846 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801805:	ff 30                	pushl  (%eax)
  801807:	e8 bf fb ff ff       	call   8013cb <dev_lookup>
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	85 c0                	test   %eax,%eax
  801811:	78 33                	js     801846 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801813:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801816:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80181a:	74 2f                	je     80184b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80181c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801826:	00 00 00 
	stat->st_isdir = 0;
  801829:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801830:	00 00 00 
	stat->st_dev = dev;
  801833:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	53                   	push   %ebx
  80183d:	ff 75 f0             	pushl  -0x10(%ebp)
  801840:	ff 50 14             	call   *0x14(%eax)
  801843:	83 c4 10             	add    $0x10,%esp
}
  801846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801849:	c9                   	leave  
  80184a:	c3                   	ret    
		return -E_NOT_SUPP;
  80184b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801850:	eb f4                	jmp    801846 <fstat+0x68>

00801852 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	6a 00                	push   $0x0
  80185c:	ff 75 08             	pushl  0x8(%ebp)
  80185f:	e8 e7 01 00 00       	call   801a4b <open>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 1b                	js     801888 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	50                   	push   %eax
  801874:	e8 65 ff ff ff       	call   8017de <fstat>
  801879:	89 c6                	mov    %eax,%esi
	close(fd);
  80187b:	89 1c 24             	mov    %ebx,(%esp)
  80187e:	e8 27 fc ff ff       	call   8014aa <close>
	return r;
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	89 f3                	mov    %esi,%ebx
}
  801888:	89 d8                	mov    %ebx,%eax
  80188a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188d:	5b                   	pop    %ebx
  80188e:	5e                   	pop    %esi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	89 c6                	mov    %eax,%esi
  801898:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80189a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a1:	74 27                	je     8018ca <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a3:	6a 07                	push   $0x7
  8018a5:	68 00 50 80 00       	push   $0x805000
  8018aa:	56                   	push   %esi
  8018ab:	ff 35 00 40 80 00    	pushl  0x804000
  8018b1:	e8 c3 f9 ff ff       	call   801279 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b6:	83 c4 0c             	add    $0xc,%esp
  8018b9:	6a 00                	push   $0x0
  8018bb:	53                   	push   %ebx
  8018bc:	6a 00                	push   $0x0
  8018be:	e8 55 f9 ff ff       	call   801218 <ipc_recv>
}
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018ca:	83 ec 0c             	sub    $0xc,%esp
  8018cd:	6a 01                	push   $0x1
  8018cf:	e8 f2 f9 ff ff       	call   8012c6 <ipc_find_env>
  8018d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	eb c5                	jmp    8018a3 <fsipc+0x12>

008018de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801901:	e8 8b ff ff ff       	call   801891 <fsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_flush>:
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	8b 40 0c             	mov    0xc(%eax),%eax
  801914:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
  80191e:	b8 06 00 00 00       	mov    $0x6,%eax
  801923:	e8 69 ff ff ff       	call   801891 <fsipc>
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <devfile_stat>:
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	83 ec 04             	sub    $0x4,%esp
  801931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8b 40 0c             	mov    0xc(%eax),%eax
  80193a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 05 00 00 00       	mov    $0x5,%eax
  801949:	e8 43 ff ff ff       	call   801891 <fsipc>
  80194e:	85 c0                	test   %eax,%eax
  801950:	78 2c                	js     80197e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801952:	83 ec 08             	sub    $0x8,%esp
  801955:	68 00 50 80 00       	push   $0x805000
  80195a:	53                   	push   %ebx
  80195b:	e8 53 ef ff ff       	call   8008b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801960:	a1 80 50 80 00       	mov    0x805080,%eax
  801965:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80196b:	a1 84 50 80 00       	mov    0x805084,%eax
  801970:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <devfile_write>:
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  80198c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801991:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801996:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801999:	8b 55 08             	mov    0x8(%ebp),%edx
  80199c:	8b 52 0c             	mov    0xc(%edx),%edx
  80199f:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8019a5:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	68 08 50 80 00       	push   $0x805008
  8019b3:	e8 89 f0 ff ff       	call   800a41 <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c2:	e8 ca fe ff ff       	call   801891 <fsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devfile_read>:
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019dc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ec:	e8 a0 fe ff ff       	call   801891 <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 1f                	js     801a16 <devfile_read+0x4d>
	assert(r <= n);
  8019f7:	39 f0                	cmp    %esi,%eax
  8019f9:	77 24                	ja     801a1f <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a00:	7f 33                	jg     801a35 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a02:	83 ec 04             	sub    $0x4,%esp
  801a05:	50                   	push   %eax
  801a06:	68 00 50 80 00       	push   $0x805000
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	e8 2e f0 ff ff       	call   800a41 <memmove>
	return r;
  801a13:	83 c4 10             	add    $0x10,%esp
}
  801a16:	89 d8                	mov    %ebx,%eax
  801a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5e                   	pop    %esi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    
	assert(r <= n);
  801a1f:	68 98 28 80 00       	push   $0x802898
  801a24:	68 9f 28 80 00       	push   $0x80289f
  801a29:	6a 7d                	push   $0x7d
  801a2b:	68 b4 28 80 00       	push   $0x8028b4
  801a30:	e8 b3 05 00 00       	call   801fe8 <_panic>
	assert(r <= PGSIZE);
  801a35:	68 bf 28 80 00       	push   $0x8028bf
  801a3a:	68 9f 28 80 00       	push   $0x80289f
  801a3f:	6a 7e                	push   $0x7e
  801a41:	68 b4 28 80 00       	push   $0x8028b4
  801a46:	e8 9d 05 00 00       	call   801fe8 <_panic>

00801a4b <open>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a56:	56                   	push   %esi
  801a57:	e8 20 ee ff ff       	call   80087c <strlen>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a64:	0f 8f 96 00 00 00    	jg     801b00 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a70:	50                   	push   %eax
  801a71:	e8 b0 f8 ff ff       	call   801326 <fd_alloc>
  801a76:	89 c3                	mov    %eax,%ebx
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 66                	js     801ae5 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801a7f:	83 ec 08             	sub    $0x8,%esp
  801a82:	56                   	push   %esi
  801a83:	68 00 50 80 00       	push   $0x805000
  801a88:	e8 26 ee ff ff       	call   8008b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a90:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a95:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a98:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9d:	e8 ef fd ff ff       	call   801891 <fsipc>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	78 43                	js     801aee <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab1:	e8 49 f8 ff ff       	call   8012ff <fd2num>
  801ab6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab9:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801abf:	8b 49 48             	mov    0x48(%ecx),%ecx
  801ac2:	83 c4 08             	add    $0x8,%esp
  801ac5:	50                   	push   %eax
  801ac6:	52                   	push   %edx
  801ac7:	ff 32                	pushl  (%edx)
  801ac9:	56                   	push   %esi
  801aca:	51                   	push   %ecx
  801acb:	68 cc 28 80 00       	push   $0x8028cc
  801ad0:	e8 bf e7 ff ff       	call   800294 <cprintf>
	return fd2num(fd);
  801ad5:	83 c4 14             	add    $0x14,%esp
  801ad8:	ff 75 f4             	pushl  -0xc(%ebp)
  801adb:	e8 1f f8 ff ff       	call   8012ff <fd2num>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
}
  801ae5:	89 d8                	mov    %ebx,%eax
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    
		fd_close(fd, 0);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	6a 00                	push   $0x0
  801af3:	ff 75 f4             	pushl  -0xc(%ebp)
  801af6:	e8 26 f9 ff ff       	call   801421 <fd_close>
		return r;
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb e5                	jmp    801ae5 <open+0x9a>
		return -E_BAD_PATH;
  801b00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b05:	eb de                	jmp    801ae5 <open+0x9a>

00801b07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 08 00 00 00       	mov    $0x8,%eax
  801b17:	e8 75 fd ff ff       	call   801891 <fsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    

00801b1e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b1e:	55                   	push   %ebp
  801b1f:	89 e5                	mov    %esp,%ebp
  801b21:	56                   	push   %esi
  801b22:	53                   	push   %ebx
  801b23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	ff 75 08             	pushl  0x8(%ebp)
  801b2c:	e8 de f7 ff ff       	call   80130f <fd2data>
  801b31:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b33:	83 c4 08             	add    $0x8,%esp
  801b36:	68 0b 29 80 00       	push   $0x80290b
  801b3b:	53                   	push   %ebx
  801b3c:	e8 72 ed ff ff       	call   8008b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b41:	8b 46 04             	mov    0x4(%esi),%eax
  801b44:	2b 06                	sub    (%esi),%eax
  801b46:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b4c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b53:	00 00 00 
	stat->st_dev = &devpipe;
  801b56:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801b5d:	30 80 00 
	return 0;
}
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
  801b65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	53                   	push   %ebx
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b76:	53                   	push   %ebx
  801b77:	6a 00                	push   $0x0
  801b79:	e8 b3 f1 ff ff       	call   800d31 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b7e:	89 1c 24             	mov    %ebx,(%esp)
  801b81:	e8 89 f7 ff ff       	call   80130f <fd2data>
  801b86:	83 c4 08             	add    $0x8,%esp
  801b89:	50                   	push   %eax
  801b8a:	6a 00                	push   $0x0
  801b8c:	e8 a0 f1 ff ff       	call   800d31 <sys_page_unmap>
}
  801b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <_pipeisclosed>:
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	57                   	push   %edi
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
  801b9f:	89 c7                	mov    %eax,%edi
  801ba1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ba3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	57                   	push   %edi
  801baf:	e8 a0 04 00 00       	call   802054 <pageref>
  801bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bb7:	89 34 24             	mov    %esi,(%esp)
  801bba:	e8 95 04 00 00       	call   802054 <pageref>
		nn = thisenv->env_runs;
  801bbf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bc5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	39 cb                	cmp    %ecx,%ebx
  801bcd:	74 1b                	je     801bea <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bcf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd2:	75 cf                	jne    801ba3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bd4:	8b 42 58             	mov    0x58(%edx),%eax
  801bd7:	6a 01                	push   $0x1
  801bd9:	50                   	push   %eax
  801bda:	53                   	push   %ebx
  801bdb:	68 12 29 80 00       	push   $0x802912
  801be0:	e8 af e6 ff ff       	call   800294 <cprintf>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	eb b9                	jmp    801ba3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bed:	0f 94 c0             	sete   %al
  801bf0:	0f b6 c0             	movzbl %al,%eax
}
  801bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devpipe_write>:
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	57                   	push   %edi
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 28             	sub    $0x28,%esp
  801c04:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c07:	56                   	push   %esi
  801c08:	e8 02 f7 ff ff       	call   80130f <fd2data>
  801c0d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	bf 00 00 00 00       	mov    $0x0,%edi
  801c17:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c1a:	74 4f                	je     801c6b <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c1c:	8b 43 04             	mov    0x4(%ebx),%eax
  801c1f:	8b 0b                	mov    (%ebx),%ecx
  801c21:	8d 51 20             	lea    0x20(%ecx),%edx
  801c24:	39 d0                	cmp    %edx,%eax
  801c26:	72 14                	jb     801c3c <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c28:	89 da                	mov    %ebx,%edx
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	e8 65 ff ff ff       	call   801b96 <_pipeisclosed>
  801c31:	85 c0                	test   %eax,%eax
  801c33:	75 3a                	jne    801c6f <devpipe_write+0x74>
			sys_yield();
  801c35:	e8 53 f0 ff ff       	call   800c8d <sys_yield>
  801c3a:	eb e0                	jmp    801c1c <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c43:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	c1 fa 1f             	sar    $0x1f,%edx
  801c4b:	89 d1                	mov    %edx,%ecx
  801c4d:	c1 e9 1b             	shr    $0x1b,%ecx
  801c50:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c53:	83 e2 1f             	and    $0x1f,%edx
  801c56:	29 ca                	sub    %ecx,%edx
  801c58:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c5c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c60:	83 c0 01             	add    $0x1,%eax
  801c63:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c66:	83 c7 01             	add    $0x1,%edi
  801c69:	eb ac                	jmp    801c17 <devpipe_write+0x1c>
	return i;
  801c6b:	89 f8                	mov    %edi,%eax
  801c6d:	eb 05                	jmp    801c74 <devpipe_write+0x79>
				return 0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5f                   	pop    %edi
  801c7a:	5d                   	pop    %ebp
  801c7b:	c3                   	ret    

00801c7c <devpipe_read>:
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	57                   	push   %edi
  801c80:	56                   	push   %esi
  801c81:	53                   	push   %ebx
  801c82:	83 ec 18             	sub    $0x18,%esp
  801c85:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c88:	57                   	push   %edi
  801c89:	e8 81 f6 ff ff       	call   80130f <fd2data>
  801c8e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	be 00 00 00 00       	mov    $0x0,%esi
  801c98:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c9b:	74 47                	je     801ce4 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c9d:	8b 03                	mov    (%ebx),%eax
  801c9f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ca2:	75 22                	jne    801cc6 <devpipe_read+0x4a>
			if (i > 0)
  801ca4:	85 f6                	test   %esi,%esi
  801ca6:	75 14                	jne    801cbc <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801ca8:	89 da                	mov    %ebx,%edx
  801caa:	89 f8                	mov    %edi,%eax
  801cac:	e8 e5 fe ff ff       	call   801b96 <_pipeisclosed>
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	75 33                	jne    801ce8 <devpipe_read+0x6c>
			sys_yield();
  801cb5:	e8 d3 ef ff ff       	call   800c8d <sys_yield>
  801cba:	eb e1                	jmp    801c9d <devpipe_read+0x21>
				return i;
  801cbc:	89 f0                	mov    %esi,%eax
}
  801cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5f                   	pop    %edi
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cc6:	99                   	cltd   
  801cc7:	c1 ea 1b             	shr    $0x1b,%edx
  801cca:	01 d0                	add    %edx,%eax
  801ccc:	83 e0 1f             	and    $0x1f,%eax
  801ccf:	29 d0                	sub    %edx,%eax
  801cd1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cdc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cdf:	83 c6 01             	add    $0x1,%esi
  801ce2:	eb b4                	jmp    801c98 <devpipe_read+0x1c>
	return i;
  801ce4:	89 f0                	mov    %esi,%eax
  801ce6:	eb d6                	jmp    801cbe <devpipe_read+0x42>
				return 0;
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ced:	eb cf                	jmp    801cbe <devpipe_read+0x42>

00801cef <pipe>:
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cf7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	e8 26 f6 ff ff       	call   801326 <fd_alloc>
  801d00:	89 c3                	mov    %eax,%ebx
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 5b                	js     801d64 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d09:	83 ec 04             	sub    $0x4,%esp
  801d0c:	68 07 04 00 00       	push   $0x407
  801d11:	ff 75 f4             	pushl  -0xc(%ebp)
  801d14:	6a 00                	push   $0x0
  801d16:	e8 91 ef ff ff       	call   800cac <sys_page_alloc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 40                	js     801d64 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d24:	83 ec 0c             	sub    $0xc,%esp
  801d27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d2a:	50                   	push   %eax
  801d2b:	e8 f6 f5 ff ff       	call   801326 <fd_alloc>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 1b                	js     801d54 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	68 07 04 00 00       	push   $0x407
  801d41:	ff 75 f0             	pushl  -0x10(%ebp)
  801d44:	6a 00                	push   $0x0
  801d46:	e8 61 ef ff ff       	call   800cac <sys_page_alloc>
  801d4b:	89 c3                	mov    %eax,%ebx
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	79 19                	jns    801d6d <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 d0 ef ff ff       	call   800d31 <sys_page_unmap>
  801d61:	83 c4 10             	add    $0x10,%esp
}
  801d64:	89 d8                	mov    %ebx,%eax
  801d66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    
	va = fd2data(fd0);
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	ff 75 f4             	pushl  -0xc(%ebp)
  801d73:	e8 97 f5 ff ff       	call   80130f <fd2data>
  801d78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7a:	83 c4 0c             	add    $0xc,%esp
  801d7d:	68 07 04 00 00       	push   $0x407
  801d82:	50                   	push   %eax
  801d83:	6a 00                	push   $0x0
  801d85:	e8 22 ef ff ff       	call   800cac <sys_page_alloc>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	83 c4 10             	add    $0x10,%esp
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	0f 88 8c 00 00 00    	js     801e23 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d97:	83 ec 0c             	sub    $0xc,%esp
  801d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9d:	e8 6d f5 ff ff       	call   80130f <fd2data>
  801da2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801da9:	50                   	push   %eax
  801daa:	6a 00                	push   $0x0
  801dac:	56                   	push   %esi
  801dad:	6a 00                	push   $0x0
  801daf:	e8 3b ef ff ff       	call   800cef <sys_page_map>
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	83 c4 20             	add    $0x20,%esp
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	78 58                	js     801e15 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc0:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801dc6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd5:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801ddb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801de7:	83 ec 0c             	sub    $0xc,%esp
  801dea:	ff 75 f4             	pushl  -0xc(%ebp)
  801ded:	e8 0d f5 ff ff       	call   8012ff <fd2num>
  801df2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801df5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801df7:	83 c4 04             	add    $0x4,%esp
  801dfa:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfd:	e8 fd f4 ff ff       	call   8012ff <fd2num>
  801e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e05:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e10:	e9 4f ff ff ff       	jmp    801d64 <pipe+0x75>
	sys_page_unmap(0, va);
  801e15:	83 ec 08             	sub    $0x8,%esp
  801e18:	56                   	push   %esi
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 11 ef ff ff       	call   800d31 <sys_page_unmap>
  801e20:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	ff 75 f0             	pushl  -0x10(%ebp)
  801e29:	6a 00                	push   $0x0
  801e2b:	e8 01 ef ff ff       	call   800d31 <sys_page_unmap>
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	e9 1c ff ff ff       	jmp    801d54 <pipe+0x65>

00801e38 <pipeisclosed>:
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e41:	50                   	push   %eax
  801e42:	ff 75 08             	pushl  0x8(%ebp)
  801e45:	e8 2b f5 ff ff       	call   801375 <fd_lookup>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 18                	js     801e69 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	ff 75 f4             	pushl  -0xc(%ebp)
  801e57:	e8 b3 f4 ff ff       	call   80130f <fd2data>
	return _pipeisclosed(fd, p);
  801e5c:	89 c2                	mov    %eax,%edx
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	e8 30 fd ff ff       	call   801b96 <_pipeisclosed>
  801e66:	83 c4 10             	add    $0x10,%esp
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e73:	5d                   	pop    %ebp
  801e74:	c3                   	ret    

00801e75 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e7b:	68 2a 29 80 00       	push   $0x80292a
  801e80:	ff 75 0c             	pushl  0xc(%ebp)
  801e83:	e8 2b ea ff ff       	call   8008b3 <strcpy>
	return 0;
}
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <devcons_write>:
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	57                   	push   %edi
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e9b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ea0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ea6:	eb 2f                	jmp    801ed7 <devcons_write+0x48>
		m = n - tot;
  801ea8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eab:	29 f3                	sub    %esi,%ebx
  801ead:	83 fb 7f             	cmp    $0x7f,%ebx
  801eb0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eb5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eb8:	83 ec 04             	sub    $0x4,%esp
  801ebb:	53                   	push   %ebx
  801ebc:	89 f0                	mov    %esi,%eax
  801ebe:	03 45 0c             	add    0xc(%ebp),%eax
  801ec1:	50                   	push   %eax
  801ec2:	57                   	push   %edi
  801ec3:	e8 79 eb ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  801ec8:	83 c4 08             	add    $0x8,%esp
  801ecb:	53                   	push   %ebx
  801ecc:	57                   	push   %edi
  801ecd:	e8 1e ed ff ff       	call   800bf0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ed2:	01 de                	add    %ebx,%esi
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eda:	72 cc                	jb     801ea8 <devcons_write+0x19>
}
  801edc:	89 f0                	mov    %esi,%eax
  801ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <devcons_read>:
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 08             	sub    $0x8,%esp
  801eec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ef1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ef5:	75 07                	jne    801efe <devcons_read+0x18>
}
  801ef7:	c9                   	leave  
  801ef8:	c3                   	ret    
		sys_yield();
  801ef9:	e8 8f ed ff ff       	call   800c8d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801efe:	e8 0b ed ff ff       	call   800c0e <sys_cgetc>
  801f03:	85 c0                	test   %eax,%eax
  801f05:	74 f2                	je     801ef9 <devcons_read+0x13>
	if (c < 0)
  801f07:	85 c0                	test   %eax,%eax
  801f09:	78 ec                	js     801ef7 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f0b:	83 f8 04             	cmp    $0x4,%eax
  801f0e:	74 0c                	je     801f1c <devcons_read+0x36>
	*(char*)vbuf = c;
  801f10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f13:	88 02                	mov    %al,(%edx)
	return 1;
  801f15:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1a:	eb db                	jmp    801ef7 <devcons_read+0x11>
		return 0;
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f21:	eb d4                	jmp    801ef7 <devcons_read+0x11>

00801f23 <cputchar>:
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f29:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f2f:	6a 01                	push   $0x1
  801f31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f34:	50                   	push   %eax
  801f35:	e8 b6 ec ff ff       	call   800bf0 <sys_cputs>
}
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <getchar>:
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f45:	6a 01                	push   $0x1
  801f47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f4a:	50                   	push   %eax
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 94 f6 ff ff       	call   8015e6 <read>
	if (r < 0)
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 08                	js     801f61 <getchar+0x22>
	if (r < 1)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	7e 06                	jle    801f63 <getchar+0x24>
	return c;
  801f5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    
		return -E_EOF;
  801f63:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f68:	eb f7                	jmp    801f61 <getchar+0x22>

00801f6a <iscons>:
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f73:	50                   	push   %eax
  801f74:	ff 75 08             	pushl  0x8(%ebp)
  801f77:	e8 f9 f3 ff ff       	call   801375 <fd_lookup>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 11                	js     801f94 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f86:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f8c:	39 10                	cmp    %edx,(%eax)
  801f8e:	0f 94 c0             	sete   %al
  801f91:	0f b6 c0             	movzbl %al,%eax
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <opencons>:
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9f:	50                   	push   %eax
  801fa0:	e8 81 f3 ff ff       	call   801326 <fd_alloc>
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 3a                	js     801fe6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fac:	83 ec 04             	sub    $0x4,%esp
  801faf:	68 07 04 00 00       	push   $0x407
  801fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb7:	6a 00                	push   $0x0
  801fb9:	e8 ee ec ff ff       	call   800cac <sys_page_alloc>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 21                	js     801fe6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801fce:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	50                   	push   %eax
  801fde:	e8 1c f3 ff ff       	call   8012ff <fd2num>
  801fe3:	83 c4 10             	add    $0x10,%esp
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	56                   	push   %esi
  801fec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ff0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801ff6:	e8 73 ec ff ff       	call   800c6e <sys_getenvid>
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	ff 75 0c             	pushl  0xc(%ebp)
  802001:	ff 75 08             	pushl  0x8(%ebp)
  802004:	56                   	push   %esi
  802005:	50                   	push   %eax
  802006:	68 38 29 80 00       	push   $0x802938
  80200b:	e8 84 e2 ff ff       	call   800294 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802010:	83 c4 18             	add    $0x18,%esp
  802013:	53                   	push   %ebx
  802014:	ff 75 10             	pushl  0x10(%ebp)
  802017:	e8 27 e2 ff ff       	call   800243 <vcprintf>
	cprintf("\n");
  80201c:	c7 04 24 23 29 80 00 	movl   $0x802923,(%esp)
  802023:	e8 6c e2 ff ff       	call   800294 <cprintf>
  802028:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80202b:	cc                   	int3   
  80202c:	eb fd                	jmp    80202b <_panic+0x43>

0080202e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80202e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80202f:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  802034:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802036:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  802039:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  80203c:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  802040:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  802044:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  802047:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  80204b:	89 18                	mov    %ebx,(%eax)

    popal
  80204d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  80204e:	83 c4 04             	add    $0x4,%esp
    popfl
  802051:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  802052:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  802053:	c3                   	ret    

00802054 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	c1 e8 16             	shr    $0x16,%eax
  80205f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80206b:	f6 c1 01             	test   $0x1,%cl
  80206e:	74 1d                	je     80208d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802070:	c1 ea 0c             	shr    $0xc,%edx
  802073:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207a:	f6 c2 01             	test   $0x1,%dl
  80207d:	74 0e                	je     80208d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207f:	c1 ea 0c             	shr    $0xc,%edx
  802082:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802089:	ef 
  80208a:	0f b7 c0             	movzwl %ax,%eax
}
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	57                   	push   %edi
  802092:	56                   	push   %esi
  802093:	53                   	push   %ebx
  802094:	83 ec 1c             	sub    $0x1c,%esp
  802097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80209b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80209f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020a7:	85 d2                	test   %edx,%edx
  8020a9:	75 35                	jne    8020e0 <__udivdi3+0x50>
  8020ab:	39 f3                	cmp    %esi,%ebx
  8020ad:	0f 87 bd 00 00 00    	ja     802170 <__udivdi3+0xe0>
  8020b3:	85 db                	test   %ebx,%ebx
  8020b5:	89 d9                	mov    %ebx,%ecx
  8020b7:	75 0b                	jne    8020c4 <__udivdi3+0x34>
  8020b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f3                	div    %ebx
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	31 d2                	xor    %edx,%edx
  8020c6:	89 f0                	mov    %esi,%eax
  8020c8:	f7 f1                	div    %ecx
  8020ca:	89 c6                	mov    %eax,%esi
  8020cc:	89 e8                	mov    %ebp,%eax
  8020ce:	89 f7                	mov    %esi,%edi
  8020d0:	f7 f1                	div    %ecx
  8020d2:	89 fa                	mov    %edi,%edx
  8020d4:	83 c4 1c             	add    $0x1c,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 f2                	cmp    %esi,%edx
  8020e2:	77 7c                	ja     802160 <__udivdi3+0xd0>
  8020e4:	0f bd fa             	bsr    %edx,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0xf8>
  8020f0:	89 f9                	mov    %edi,%ecx
  8020f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020f7:	29 f8                	sub    %edi,%eax
  8020f9:	d3 e2                	shl    %cl,%edx
  8020fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020ff:	89 c1                	mov    %eax,%ecx
  802101:	89 da                	mov    %ebx,%edx
  802103:	d3 ea                	shr    %cl,%edx
  802105:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802109:	09 d1                	or     %edx,%ecx
  80210b:	89 f2                	mov    %esi,%edx
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f9                	mov    %edi,%ecx
  802113:	d3 e3                	shl    %cl,%ebx
  802115:	89 c1                	mov    %eax,%ecx
  802117:	d3 ea                	shr    %cl,%edx
  802119:	89 f9                	mov    %edi,%ecx
  80211b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80211f:	d3 e6                	shl    %cl,%esi
  802121:	89 eb                	mov    %ebp,%ebx
  802123:	89 c1                	mov    %eax,%ecx
  802125:	d3 eb                	shr    %cl,%ebx
  802127:	09 de                	or     %ebx,%esi
  802129:	89 f0                	mov    %esi,%eax
  80212b:	f7 74 24 08          	divl   0x8(%esp)
  80212f:	89 d6                	mov    %edx,%esi
  802131:	89 c3                	mov    %eax,%ebx
  802133:	f7 64 24 0c          	mull   0xc(%esp)
  802137:	39 d6                	cmp    %edx,%esi
  802139:	72 0c                	jb     802147 <__udivdi3+0xb7>
  80213b:	89 f9                	mov    %edi,%ecx
  80213d:	d3 e5                	shl    %cl,%ebp
  80213f:	39 c5                	cmp    %eax,%ebp
  802141:	73 5d                	jae    8021a0 <__udivdi3+0x110>
  802143:	39 d6                	cmp    %edx,%esi
  802145:	75 59                	jne    8021a0 <__udivdi3+0x110>
  802147:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80214a:	31 ff                	xor    %edi,%edi
  80214c:	89 fa                	mov    %edi,%edx
  80214e:	83 c4 1c             	add    $0x1c,%esp
  802151:	5b                   	pop    %ebx
  802152:	5e                   	pop    %esi
  802153:	5f                   	pop    %edi
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    
  802156:	8d 76 00             	lea    0x0(%esi),%esi
  802159:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802160:	31 ff                	xor    %edi,%edi
  802162:	31 c0                	xor    %eax,%eax
  802164:	89 fa                	mov    %edi,%edx
  802166:	83 c4 1c             	add    $0x1c,%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5f                   	pop    %edi
  80216c:	5d                   	pop    %ebp
  80216d:	c3                   	ret    
  80216e:	66 90                	xchg   %ax,%ax
  802170:	31 ff                	xor    %edi,%edi
  802172:	89 e8                	mov    %ebp,%eax
  802174:	89 f2                	mov    %esi,%edx
  802176:	f7 f3                	div    %ebx
  802178:	89 fa                	mov    %edi,%edx
  80217a:	83 c4 1c             	add    $0x1c,%esp
  80217d:	5b                   	pop    %ebx
  80217e:	5e                   	pop    %esi
  80217f:	5f                   	pop    %edi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    
  802182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	72 06                	jb     802192 <__udivdi3+0x102>
  80218c:	31 c0                	xor    %eax,%eax
  80218e:	39 eb                	cmp    %ebp,%ebx
  802190:	77 d2                	ja     802164 <__udivdi3+0xd4>
  802192:	b8 01 00 00 00       	mov    $0x1,%eax
  802197:	eb cb                	jmp    802164 <__udivdi3+0xd4>
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 d8                	mov    %ebx,%eax
  8021a2:	31 ff                	xor    %edi,%edi
  8021a4:	eb be                	jmp    802164 <__udivdi3+0xd4>
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 ed                	test   %ebp,%ebp
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	89 da                	mov    %ebx,%edx
  8021cd:	75 19                	jne    8021e8 <__umoddi3+0x38>
  8021cf:	39 df                	cmp    %ebx,%edi
  8021d1:	0f 86 b1 00 00 00    	jbe    802288 <__umoddi3+0xd8>
  8021d7:	f7 f7                	div    %edi
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 dd                	cmp    %ebx,%ebp
  8021ea:	77 f1                	ja     8021dd <__umoddi3+0x2d>
  8021ec:	0f bd cd             	bsr    %ebp,%ecx
  8021ef:	83 f1 1f             	xor    $0x1f,%ecx
  8021f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021f6:	0f 84 b4 00 00 00    	je     8022b0 <__umoddi3+0x100>
  8021fc:	b8 20 00 00 00       	mov    $0x20,%eax
  802201:	89 c2                	mov    %eax,%edx
  802203:	8b 44 24 04          	mov    0x4(%esp),%eax
  802207:	29 c2                	sub    %eax,%edx
  802209:	89 c1                	mov    %eax,%ecx
  80220b:	89 f8                	mov    %edi,%eax
  80220d:	d3 e5                	shl    %cl,%ebp
  80220f:	89 d1                	mov    %edx,%ecx
  802211:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802215:	d3 e8                	shr    %cl,%eax
  802217:	09 c5                	or     %eax,%ebp
  802219:	8b 44 24 04          	mov    0x4(%esp),%eax
  80221d:	89 c1                	mov    %eax,%ecx
  80221f:	d3 e7                	shl    %cl,%edi
  802221:	89 d1                	mov    %edx,%ecx
  802223:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802227:	89 df                	mov    %ebx,%edi
  802229:	d3 ef                	shr    %cl,%edi
  80222b:	89 c1                	mov    %eax,%ecx
  80222d:	89 f0                	mov    %esi,%eax
  80222f:	d3 e3                	shl    %cl,%ebx
  802231:	89 d1                	mov    %edx,%ecx
  802233:	89 fa                	mov    %edi,%edx
  802235:	d3 e8                	shr    %cl,%eax
  802237:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80223c:	09 d8                	or     %ebx,%eax
  80223e:	f7 f5                	div    %ebp
  802240:	d3 e6                	shl    %cl,%esi
  802242:	89 d1                	mov    %edx,%ecx
  802244:	f7 64 24 08          	mull   0x8(%esp)
  802248:	39 d1                	cmp    %edx,%ecx
  80224a:	89 c3                	mov    %eax,%ebx
  80224c:	89 d7                	mov    %edx,%edi
  80224e:	72 06                	jb     802256 <__umoddi3+0xa6>
  802250:	75 0e                	jne    802260 <__umoddi3+0xb0>
  802252:	39 c6                	cmp    %eax,%esi
  802254:	73 0a                	jae    802260 <__umoddi3+0xb0>
  802256:	2b 44 24 08          	sub    0x8(%esp),%eax
  80225a:	19 ea                	sbb    %ebp,%edx
  80225c:	89 d7                	mov    %edx,%edi
  80225e:	89 c3                	mov    %eax,%ebx
  802260:	89 ca                	mov    %ecx,%edx
  802262:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802267:	29 de                	sub    %ebx,%esi
  802269:	19 fa                	sbb    %edi,%edx
  80226b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	d3 e0                	shl    %cl,%eax
  802273:	89 d9                	mov    %ebx,%ecx
  802275:	d3 ee                	shr    %cl,%esi
  802277:	d3 ea                	shr    %cl,%edx
  802279:	09 f0                	or     %esi,%eax
  80227b:	83 c4 1c             	add    $0x1c,%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5f                   	pop    %edi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    
  802283:	90                   	nop
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	85 ff                	test   %edi,%edi
  80228a:	89 f9                	mov    %edi,%ecx
  80228c:	75 0b                	jne    802299 <__umoddi3+0xe9>
  80228e:	b8 01 00 00 00       	mov    $0x1,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f7                	div    %edi
  802297:	89 c1                	mov    %eax,%ecx
  802299:	89 d8                	mov    %ebx,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f1                	div    %ecx
  80229f:	89 f0                	mov    %esi,%eax
  8022a1:	f7 f1                	div    %ecx
  8022a3:	e9 31 ff ff ff       	jmp    8021d9 <__umoddi3+0x29>
  8022a8:	90                   	nop
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	39 dd                	cmp    %ebx,%ebp
  8022b2:	72 08                	jb     8022bc <__umoddi3+0x10c>
  8022b4:	39 f7                	cmp    %esi,%edi
  8022b6:	0f 87 21 ff ff ff    	ja     8021dd <__umoddi3+0x2d>
  8022bc:	89 da                	mov    %ebx,%edx
  8022be:	89 f0                	mov    %esi,%eax
  8022c0:	29 f8                	sub    %edi,%eax
  8022c2:	19 ea                	sbb    %ebp,%edx
  8022c4:	e9 14 ff ff ff       	jmp    8021dd <__umoddi3+0x2d>
