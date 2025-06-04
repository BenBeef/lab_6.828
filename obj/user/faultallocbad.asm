
obj/user/faultallocbad.debug:     file format elf32-i386


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

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 e0 1e 80 00       	push   $0x801ee0
  800045:	e8 a6 01 00 00       	call   8001f0 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 aa 0b 00 00       	call   800c08 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 2c 1f 80 00       	push   $0x801f2c
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 4b 07 00 00       	call   8007be <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 00 1f 80 00       	push   $0x801f00
  800085:	6a 0f                	push   $0xf
  800087:	68 ea 1e 80 00       	push   $0x801eea
  80008c:	e8 84 00 00 00       	call   800115 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 58 0d 00 00       	call   800df9 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 9c 0a 00 00       	call   800b4c <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 05 0b 00 00       	call   800bca <sys_getenvid>
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
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

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
  800101:	e8 52 0f 00 00       	call   801058 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 79 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 a2 0a 00 00       	call   800bca <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 58 1f 80 00       	push   $0x801f58
  800138:	e8 b3 00 00 00       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 56 00 00 00       	call   80019f <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 e4 23 80 00 	movl   $0x8023e4,(%esp)
  800150:	e8 9b 00 00 00       	call   8001f0 <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 b8 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 1a 01 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 64 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800228:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022b:	39 d3                	cmp    %edx,%ebx
  80022d:	72 05                	jb     800234 <printnum+0x30>
  80022f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800232:	77 7a                	ja     8002ae <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	8b 45 14             	mov    0x14(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	53                   	push   %ebx
  800241:	ff 75 10             	pushl  0x10(%ebp)
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 38 1a 00 00       	call   801c90 <__udivdi3>
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	89 f2                	mov    %esi,%edx
  80025f:	89 f8                	mov    %edi,%eax
  800261:	e8 9e ff ff ff       	call   800204 <printnum>
  800266:	83 c4 20             	add    $0x20,%esp
  800269:	eb 13                	jmp    80027e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	ff d7                	call   *%edi
  800274:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800277:	83 eb 01             	sub    $0x1,%ebx
  80027a:	85 db                	test   %ebx,%ebx
  80027c:	7f ed                	jg     80026b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	83 ec 04             	sub    $0x4,%esp
  800285:	ff 75 e4             	pushl  -0x1c(%ebp)
  800288:	ff 75 e0             	pushl  -0x20(%ebp)
  80028b:	ff 75 dc             	pushl  -0x24(%ebp)
  80028e:	ff 75 d8             	pushl  -0x28(%ebp)
  800291:	e8 1a 1b 00 00       	call   801db0 <__umoddi3>
  800296:	83 c4 14             	add    $0x14,%esp
  800299:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002a0:	50                   	push   %eax
  8002a1:	ff d7                	call   *%edi
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    
  8002ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b1:	eb c4                	jmp    800277 <printnum+0x73>

008002b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 0a                	jae    8002ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	88 02                	mov    %al,(%edx)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d9:	50                   	push   %eax
  8002da:	ff 75 10             	pushl  0x10(%ebp)
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	ff 75 08             	pushl  0x8(%ebp)
  8002e3:	e8 05 00 00 00       	call   8002ed <vprintfmt>
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 2c             	sub    $0x2c,%esp
  8002f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ff:	e9 c1 03 00 00       	jmp    8006c5 <vprintfmt+0x3d8>
		padc = ' ';
  800304:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800308:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80030f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800316:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800322:	8d 47 01             	lea    0x1(%edi),%eax
  800325:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800328:	0f b6 17             	movzbl (%edi),%edx
  80032b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032e:	3c 55                	cmp    $0x55,%al
  800330:	0f 87 12 04 00 00    	ja     800748 <vprintfmt+0x45b>
  800336:	0f b6 c0             	movzbl %al,%eax
  800339:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800347:	eb d9                	jmp    800322 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80034c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800350:	eb d0                	jmp    800322 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800358:	b8 00 00 00 00       	mov    $0x0,%eax
  80035d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800360:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800363:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800367:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036d:	83 f9 09             	cmp    $0x9,%ecx
  800370:	77 55                	ja     8003c7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800372:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800375:	eb e9                	jmp    800360 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8b 00                	mov    (%eax),%eax
  80037c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8d 40 04             	lea    0x4(%eax),%eax
  800385:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038f:	79 91                	jns    800322 <vprintfmt+0x35>
				width = precision, precision = -1;
  800391:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800394:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800397:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80039e:	eb 82                	jmp    800322 <vprintfmt+0x35>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	0f 49 d0             	cmovns %eax,%edx
  8003ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	e9 6a ff ff ff       	jmp    800322 <vprintfmt+0x35>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	e9 5b ff ff ff       	jmp    800322 <vprintfmt+0x35>
  8003c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003cd:	eb bc                	jmp    80038b <vprintfmt+0x9e>
			lflag++;
  8003cf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d5:	e9 48 ff ff ff       	jmp    800322 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 78 04             	lea    0x4(%eax),%edi
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	53                   	push   %ebx
  8003e4:	ff 30                	pushl  (%eax)
  8003e6:	ff d6                	call   *%esi
			break;
  8003e8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003eb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ee:	e9 cf 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 0f             	cmp    $0xf,%eax
  800403:	7f 23                	jg     800428 <vprintfmt+0x13b>
  800405:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	74 18                	je     800428 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800410:	52                   	push   %edx
  800411:	68 71 23 80 00       	push   $0x802371
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 b3 fe ff ff       	call   8002d0 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800420:	89 7d 14             	mov    %edi,0x14(%ebp)
  800423:	e9 9a 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800428:	50                   	push   %eax
  800429:	68 93 1f 80 00       	push   $0x801f93
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 9b fe ff ff       	call   8002d0 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043b:	e9 82 02 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	83 c0 04             	add    $0x4,%eax
  800446:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044e:	85 ff                	test   %edi,%edi
  800450:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  800455:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800458:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045c:	0f 8e bd 00 00 00    	jle    80051f <vprintfmt+0x232>
  800462:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800466:	75 0e                	jne    800476 <vprintfmt+0x189>
  800468:	89 75 08             	mov    %esi,0x8(%ebp)
  80046b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800471:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800474:	eb 6d                	jmp    8004e3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 d0             	pushl  -0x30(%ebp)
  80047c:	57                   	push   %edi
  80047d:	e8 6e 03 00 00       	call   8007f0 <strnlen>
  800482:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800497:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	eb 0f                	jmp    8004aa <vprintfmt+0x1bd>
					putch(padc, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ef 01             	sub    $0x1,%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	85 ff                	test   %edi,%edi
  8004ac:	7f ed                	jg     80049b <vprintfmt+0x1ae>
  8004ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b4:	85 c9                	test   %ecx,%ecx
  8004b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bb:	0f 49 c1             	cmovns %ecx,%eax
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	89 cb                	mov    %ecx,%ebx
  8004cb:	eb 16                	jmp    8004e3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d1:	75 31                	jne    800504 <vprintfmt+0x217>
					putch(ch, putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	ff 75 0c             	pushl  0xc(%ebp)
  8004d9:	50                   	push   %eax
  8004da:	ff 55 08             	call   *0x8(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e0:	83 eb 01             	sub    $0x1,%ebx
  8004e3:	83 c7 01             	add    $0x1,%edi
  8004e6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ea:	0f be c2             	movsbl %dl,%eax
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 59                	je     80054a <vprintfmt+0x25d>
  8004f1:	85 f6                	test   %esi,%esi
  8004f3:	78 d8                	js     8004cd <vprintfmt+0x1e0>
  8004f5:	83 ee 01             	sub    $0x1,%esi
  8004f8:	79 d3                	jns    8004cd <vprintfmt+0x1e0>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	eb 37                	jmp    80053b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800504:	0f be d2             	movsbl %dl,%edx
  800507:	83 ea 20             	sub    $0x20,%edx
  80050a:	83 fa 5e             	cmp    $0x5e,%edx
  80050d:	76 c4                	jbe    8004d3 <vprintfmt+0x1e6>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb c1                	jmp    8004e0 <vprintfmt+0x1f3>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb b6                	jmp    8004e3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f ee                	jg     80052d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	e9 78 01 00 00       	jmp    8006c2 <vprintfmt+0x3d5>
  80054a:	89 df                	mov    %ebx,%edi
  80054c:	8b 75 08             	mov    0x8(%ebp),%esi
  80054f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800552:	eb e7                	jmp    80053b <vprintfmt+0x24e>
	if (lflag >= 2)
  800554:	83 f9 01             	cmp    $0x1,%ecx
  800557:	7e 3f                	jle    800598 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8b 50 04             	mov    0x4(%eax),%edx
  80055f:	8b 00                	mov    (%eax),%eax
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 08             	lea    0x8(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800570:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800574:	79 5c                	jns    8005d2 <vprintfmt+0x2e5>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800581:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800584:	f7 da                	neg    %edx
  800586:	83 d1 00             	adc    $0x0,%ecx
  800589:	f7 d9                	neg    %ecx
  80058b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 10 01 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	75 1b                	jne    8005b7 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 00                	mov    (%eax),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 c1                	mov    %eax,%ecx
  8005a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b5:	eb b9                	jmp    800570 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d0:	eb 9e                	jmp    800570 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	e9 c6 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7e 18                	jle    8005ff <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 a9 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  8005ff:	85 c9                	test   %ecx,%ecx
  800601:	75 1a                	jne    80061d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 8b 00 00 00       	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	eb 74                	jmp    8006a8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7e 15                	jle    80064e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800647:	b8 08 00 00 00       	mov    $0x8,%eax
  80064c:	eb 5a                	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	75 17                	jne    800669 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800662:	b8 08 00 00 00       	mov    $0x8,%eax
  800667:	eb 3f                	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800679:	b8 08 00 00 00       	mov    $0x8,%eax
  80067e:	eb 28                	jmp    8006a8 <vprintfmt+0x3bb>
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d6                	call   *%esi
			putch('x', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 78                	push   $0x78
  80068e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006af:	57                   	push   %edi
  8006b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b3:	50                   	push   %eax
  8006b4:	51                   	push   %ecx
  8006b5:	52                   	push   %edx
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	e8 45 fb ff ff       	call   800204 <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c5:	83 c7 01             	add    $0x1,%edi
  8006c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006cc:	83 f8 25             	cmp    $0x25,%eax
  8006cf:	0f 84 2f fc ff ff    	je     800304 <vprintfmt+0x17>
			if (ch == '\0')
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	0f 84 8b 00 00 00    	je     800768 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	50                   	push   %eax
  8006e2:	ff d6                	call   *%esi
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb dc                	jmp    8006c5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006e9:	83 f9 01             	cmp    $0x1,%ecx
  8006ec:	7e 15                	jle    800703 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f6:	8d 40 08             	lea    0x8(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
  800701:	eb a5                	jmp    8006a8 <vprintfmt+0x3bb>
	else if (lflag)
  800703:	85 c9                	test   %ecx,%ecx
  800705:	75 17                	jne    80071e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	8d 40 04             	lea    0x4(%eax),%eax
  800714:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800717:	b8 10 00 00 00       	mov    $0x10,%eax
  80071c:	eb 8a                	jmp    8006a8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 10                	mov    (%eax),%edx
  800723:	b9 00 00 00 00       	mov    $0x0,%ecx
  800728:	8d 40 04             	lea    0x4(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072e:	b8 10 00 00 00       	mov    $0x10,%eax
  800733:	e9 70 ff ff ff       	jmp    8006a8 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 25                	push   $0x25
  80073e:	ff d6                	call   *%esi
			break;
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	e9 7a ff ff ff       	jmp    8006c2 <vprintfmt+0x3d5>
			putch('%', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	6a 25                	push   $0x25
  80074e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	89 f8                	mov    %edi,%eax
  800755:	eb 03                	jmp    80075a <vprintfmt+0x46d>
  800757:	83 e8 01             	sub    $0x1,%eax
  80075a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075e:	75 f7                	jne    800757 <vprintfmt+0x46a>
  800760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800763:	e9 5a ff ff ff       	jmp    8006c2 <vprintfmt+0x3d5>
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 b3 02 80 00       	push   $0x8002b3
  8007a4:	e8 44 fb ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bc:	eb f7                	jmp    8007b5 <vsnprintf+0x45>

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1d>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	83 c1 01             	add    $0x1,%ecx
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800825:	88 5a ff             	mov    %bl,-0x1(%edx)
  800828:	84 db                	test   %bl,%bl
  80082a:	75 ef                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082c:	5b                   	pop    %ebx
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800836:	53                   	push   %ebx
  800837:	e8 9c ff ff ff       	call   8007d8 <strlen>
  80083c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	01 d8                	add    %ebx,%eax
  800844:	50                   	push   %eax
  800845:	e8 c5 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084a:	89 d8                	mov    %ebx,%eax
  80084c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084f:	c9                   	leave  
  800850:	c3                   	ret    

00800851 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 f3                	mov    %esi,%ebx
  80085e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800861:	89 f2                	mov    %esi,%edx
  800863:	eb 0f                	jmp    800874 <strncpy+0x23>
		*dst++ = *src;
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	0f b6 01             	movzbl (%ecx),%eax
  80086b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086e:	80 39 01             	cmpb   $0x1,(%ecx)
  800871:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800874:	39 da                	cmp    %ebx,%edx
  800876:	75 ed                	jne    800865 <strncpy+0x14>
	}
	return ret;
}
  800878:	89 f0                	mov    %esi,%eax
  80087a:	5b                   	pop    %ebx
  80087b:	5e                   	pop    %esi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088c:	89 f0                	mov    %esi,%eax
  80088e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	85 c9                	test   %ecx,%ecx
  800894:	75 0b                	jne    8008a1 <strlcpy+0x23>
  800896:	eb 17                	jmp    8008af <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800898:	83 c2 01             	add    $0x1,%edx
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 07                	je     8008ac <strlcpy+0x2e>
  8008a5:	0f b6 0a             	movzbl (%edx),%ecx
  8008a8:	84 c9                	test   %cl,%cl
  8008aa:	75 ec                	jne    800898 <strlcpy+0x1a>
		*dst = '\0';
  8008ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008af:	29 f0                	sub    %esi,%eax
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5e                   	pop    %esi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	eb 06                	jmp    8008c6 <strcmp+0x11>
		p++, q++;
  8008c0:	83 c1 01             	add    $0x1,%ecx
  8008c3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c6:	0f b6 01             	movzbl (%ecx),%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	74 04                	je     8008d1 <strcmp+0x1c>
  8008cd:	3a 02                	cmp    (%edx),%al
  8008cf:	74 ef                	je     8008c0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 c3                	mov    %eax,%ebx
  8008e7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ea:	eb 06                	jmp    8008f2 <strncmp+0x17>
		n--, p++, q++;
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 16                	je     80090c <strncmp+0x31>
  8008f6:	0f b6 08             	movzbl (%eax),%ecx
  8008f9:	84 c9                	test   %cl,%cl
  8008fb:	74 04                	je     800901 <strncmp+0x26>
  8008fd:	3a 0a                	cmp    (%edx),%cl
  8008ff:	74 eb                	je     8008ec <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800901:	0f b6 00             	movzbl (%eax),%eax
  800904:	0f b6 12             	movzbl (%edx),%edx
  800907:	29 d0                	sub    %edx,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    
		return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb f6                	jmp    800909 <strncmp+0x2e>

00800913 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	0f b6 10             	movzbl (%eax),%edx
  800920:	84 d2                	test   %dl,%dl
  800922:	74 09                	je     80092d <strchr+0x1a>
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 0a                	je     800932 <strchr+0x1f>
	for (; *s; s++)
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	eb f0                	jmp    80091d <strchr+0xa>
			return (char *) s;
	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093e:	eb 03                	jmp    800943 <strfind+0xf>
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 04                	je     80094e <strfind+0x1a>
  80094a:	84 d2                	test   %dl,%dl
  80094c:	75 f2                	jne    800940 <strfind+0xc>
			break;
	return (char *) s;
}
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 7d 08             	mov    0x8(%ebp),%edi
  800959:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095c:	85 c9                	test   %ecx,%ecx
  80095e:	74 13                	je     800973 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800960:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800966:	75 05                	jne    80096d <memset+0x1d>
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	74 0d                	je     80097a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800970:	fc                   	cld    
  800971:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800973:	89 f8                	mov    %edi,%eax
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    
		c &= 0xFF;
  80097a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097e:	89 d3                	mov    %edx,%ebx
  800980:	c1 e3 08             	shl    $0x8,%ebx
  800983:	89 d0                	mov    %edx,%eax
  800985:	c1 e0 18             	shl    $0x18,%eax
  800988:	89 d6                	mov    %edx,%esi
  80098a:	c1 e6 10             	shl    $0x10,%esi
  80098d:	09 f0                	or     %esi,%eax
  80098f:	09 c2                	or     %eax,%edx
  800991:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800993:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800996:	89 d0                	mov    %edx,%eax
  800998:	fc                   	cld    
  800999:	f3 ab                	rep stos %eax,%es:(%edi)
  80099b:	eb d6                	jmp    800973 <memset+0x23>

0080099d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	57                   	push   %edi
  8009a1:	56                   	push   %esi
  8009a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ab:	39 c6                	cmp    %eax,%esi
  8009ad:	73 35                	jae    8009e4 <memmove+0x47>
  8009af:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b2:	39 c2                	cmp    %eax,%edx
  8009b4:	76 2e                	jbe    8009e4 <memmove+0x47>
		s += n;
		d += n;
  8009b6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 d6                	mov    %edx,%esi
  8009bb:	09 fe                	or     %edi,%esi
  8009bd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c3:	74 0c                	je     8009d1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 21                	jmp    8009f2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 ef                	jne    8009c5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d6:	83 ef 04             	sub    $0x4,%edi
  8009d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009df:	fd                   	std    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb ea                	jmp    8009ce <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 f2                	mov    %esi,%edx
  8009e6:	09 c2                	or     %eax,%edx
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	74 09                	je     8009f6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ed:	89 c7                	mov    %eax,%edi
  8009ef:	fc                   	cld    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f2:	5e                   	pop    %esi
  8009f3:	5f                   	pop    %edi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f6:	f6 c1 03             	test   $0x3,%cl
  8009f9:	75 f2                	jne    8009ed <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a03:	eb ed                	jmp    8009f2 <memmove+0x55>

00800a05 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a08:	ff 75 10             	pushl  0x10(%ebp)
  800a0b:	ff 75 0c             	pushl  0xc(%ebp)
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 87 ff ff ff       	call   80099d <memmove>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a23:	89 c6                	mov    %eax,%esi
  800a25:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	39 f0                	cmp    %esi,%eax
  800a2a:	74 1c                	je     800a48 <memcmp+0x30>
		if (*s1 != *s2)
  800a2c:	0f b6 08             	movzbl (%eax),%ecx
  800a2f:	0f b6 1a             	movzbl (%edx),%ebx
  800a32:	38 d9                	cmp    %bl,%cl
  800a34:	75 08                	jne    800a3e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	eb ea                	jmp    800a28 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a3e:	0f b6 c1             	movzbl %cl,%eax
  800a41:	0f b6 db             	movzbl %bl,%ebx
  800a44:	29 d8                	sub    %ebx,%eax
  800a46:	eb 05                	jmp    800a4d <memcmp+0x35>
	}

	return 0;
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a5a:	89 c2                	mov    %eax,%edx
  800a5c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5f:	39 d0                	cmp    %edx,%eax
  800a61:	73 09                	jae    800a6c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	38 08                	cmp    %cl,(%eax)
  800a65:	74 05                	je     800a6c <memfind+0x1b>
	for (; s < ends; s++)
  800a67:	83 c0 01             	add    $0x1,%eax
  800a6a:	eb f3                	jmp    800a5f <memfind+0xe>
			break;
	return (void *) s;
}
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 03                	jmp    800a7f <strtol+0x11>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a7f:	0f b6 01             	movzbl (%ecx),%eax
  800a82:	3c 20                	cmp    $0x20,%al
  800a84:	74 f6                	je     800a7c <strtol+0xe>
  800a86:	3c 09                	cmp    $0x9,%al
  800a88:	74 f2                	je     800a7c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a8a:	3c 2b                	cmp    $0x2b,%al
  800a8c:	74 2e                	je     800abc <strtol+0x4e>
	int neg = 0;
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	74 2f                	je     800ac6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9d:	75 05                	jne    800aa4 <strtol+0x36>
  800a9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa2:	74 2c                	je     800ad0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	75 0a                	jne    800ab2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aad:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab0:	74 28                	je     800ada <strtol+0x6c>
		base = 10;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aba:	eb 50                	jmp    800b0c <strtol+0x9e>
		s++;
  800abc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800abf:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac4:	eb d1                	jmp    800a97 <strtol+0x29>
		s++, neg = 1;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	bf 01 00 00 00       	mov    $0x1,%edi
  800ace:	eb c7                	jmp    800a97 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ad4:	74 0e                	je     800ae4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	75 d8                	jne    800ab2 <strtol+0x44>
		s++, base = 8;
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ae2:	eb ce                	jmp    800ab2 <strtol+0x44>
		s += 2, base = 16;
  800ae4:	83 c1 02             	add    $0x2,%ecx
  800ae7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aec:	eb c4                	jmp    800ab2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 29                	ja     800b21 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b01:	7d 30                	jge    800b33 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b03:	83 c1 01             	add    $0x1,%ecx
  800b06:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b0c:	0f b6 11             	movzbl (%ecx),%edx
  800b0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	80 fb 09             	cmp    $0x9,%bl
  800b17:	77 d5                	ja     800aee <strtol+0x80>
			dig = *s - '0';
  800b19:	0f be d2             	movsbl %dl,%edx
  800b1c:	83 ea 30             	sub    $0x30,%edx
  800b1f:	eb dd                	jmp    800afe <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b21:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b24:	89 f3                	mov    %esi,%ebx
  800b26:	80 fb 19             	cmp    $0x19,%bl
  800b29:	77 08                	ja     800b33 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b2b:	0f be d2             	movsbl %dl,%edx
  800b2e:	83 ea 37             	sub    $0x37,%edx
  800b31:	eb cb                	jmp    800afe <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b37:	74 05                	je     800b3e <strtol+0xd0>
		*endptr = (char *) s;
  800b39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	f7 da                	neg    %edx
  800b42:	85 ff                	test   %edi,%edi
  800b44:	0f 45 c2             	cmovne %edx,%eax
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 7f 22 80 00       	push   $0x80227f
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 9c 22 80 00       	push   $0x80229c
  800bc5:	e8 4b f5 ff ff       	call   800115 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c11:	be 00 00 00 00       	mov    $0x0,%esi
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	89 f7                	mov    %esi,%edi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 04                	push   $0x4
  800c3a:	68 7f 22 80 00       	push   $0x80227f
  800c3f:	6a 23                	push   $0x23
  800c41:	68 9c 22 80 00       	push   $0x80229c
  800c46:	e8 ca f4 ff ff       	call   800115 <_panic>

00800c4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 75 18             	mov    0x18(%ebp),%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 05                	push   $0x5
  800c7c:	68 7f 22 80 00       	push   $0x80227f
  800c81:	6a 23                	push   $0x23
  800c83:	68 9c 22 80 00       	push   $0x80229c
  800c88:	e8 88 f4 ff ff       	call   800115 <_panic>

00800c8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 06                	push   $0x6
  800cbe:	68 7f 22 80 00       	push   $0x80227f
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 9c 22 80 00       	push   $0x80229c
  800cca:	e8 46 f4 ff ff       	call   800115 <_panic>

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 08                	push   $0x8
  800d00:	68 7f 22 80 00       	push   $0x80227f
  800d05:	6a 23                	push   $0x23
  800d07:	68 9c 22 80 00       	push   $0x80229c
  800d0c:	e8 04 f4 ff ff       	call   800115 <_panic>

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 09 00 00 00       	mov    $0x9,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 09                	push   $0x9
  800d42:	68 7f 22 80 00       	push   $0x80227f
  800d47:	6a 23                	push   $0x23
  800d49:	68 9c 22 80 00       	push   $0x80229c
  800d4e:	e8 c2 f3 ff ff       	call   800115 <_panic>

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7f 08                	jg     800d7e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 0a                	push   $0xa
  800d84:	68 7f 22 80 00       	push   $0x80227f
  800d89:	6a 23                	push   $0x23
  800d8b:	68 9c 22 80 00       	push   $0x80229c
  800d90:	e8 80 f3 ff ff       	call   800115 <_panic>

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da6:	be 00 00 00 00       	mov    $0x0,%esi
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7f 08                	jg     800de2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 0d                	push   $0xd
  800de8:	68 7f 22 80 00       	push   $0x80227f
  800ded:	6a 23                	push   $0x23
  800def:	68 9c 22 80 00       	push   $0x80229c
  800df4:	e8 1c f3 ff ff       	call   800115 <_panic>

00800df9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dff:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e06:	74 23                	je     800e2b <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e10:	a1 04 40 80 00       	mov    0x804004,%eax
  800e15:	8b 40 48             	mov    0x48(%eax),%eax
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	68 5c 0e 80 00       	push   $0x800e5c
  800e20:	50                   	push   %eax
  800e21:	e8 2d ff ff ff       	call   800d53 <sys_env_set_pgfault_upcall>
}
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  800e2b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e30:	8b 40 48             	mov    0x48(%eax),%eax
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	6a 07                	push   $0x7
  800e38:	68 00 f0 bf ee       	push   $0xeebff000
  800e3d:	50                   	push   %eax
  800e3e:	e8 c5 fd ff ff       	call   800c08 <sys_page_alloc>
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 be                	jns    800e08 <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  800e4a:	50                   	push   %eax
  800e4b:	68 aa 22 80 00       	push   $0x8022aa
  800e50:	6a 21                	push   $0x21
  800e52:	68 bd 22 80 00       	push   $0x8022bd
  800e57:	e8 b9 f2 ff ff       	call   800115 <_panic>

00800e5c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e5c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e5d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e62:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e64:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  800e67:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  800e6a:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  800e6e:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  800e72:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  800e75:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  800e79:	89 18                	mov    %ebx,(%eax)

    popal
  800e7b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  800e7c:	83 c4 04             	add    $0x4,%esp
    popfl
  800e7f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  800e80:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  800e81:	c3                   	ret    

00800e82 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	c1 ea 16             	shr    $0x16,%edx
  800eb9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec0:	f6 c2 01             	test   $0x1,%dl
  800ec3:	74 2a                	je     800eef <fd_alloc+0x46>
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 0c             	shr    $0xc,%edx
  800eca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	74 19                	je     800eef <fd_alloc+0x46>
  800ed6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800edb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee0:	75 d2                	jne    800eb4 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ee2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ee8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800eed:	eb 07                	jmp    800ef6 <fd_alloc+0x4d>
			*fd_store = fd;
  800eef:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efe:	83 f8 1f             	cmp    $0x1f,%eax
  800f01:	77 36                	ja     800f39 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f03:	c1 e0 0c             	shl    $0xc,%eax
  800f06:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0b:	89 c2                	mov    %eax,%edx
  800f0d:	c1 ea 16             	shr    $0x16,%edx
  800f10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 24                	je     800f40 <fd_lookup+0x48>
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	c1 ea 0c             	shr    $0xc,%edx
  800f21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 1a                	je     800f47 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	89 02                	mov    %eax,(%edx)
	return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
		return -E_INVAL;
  800f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3e:	eb f7                	jmp    800f37 <fd_lookup+0x3f>
		return -E_INVAL;
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f45:	eb f0                	jmp    800f37 <fd_lookup+0x3f>
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4c:	eb e9                	jmp    800f37 <fd_lookup+0x3f>

00800f4e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	ba 48 23 80 00       	mov    $0x802348,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f5c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800f61:	39 08                	cmp    %ecx,(%eax)
  800f63:	74 33                	je     800f98 <dev_lookup+0x4a>
  800f65:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800f68:	8b 02                	mov    (%edx),%eax
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	75 f3                	jne    800f61 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6e:	a1 04 40 80 00       	mov    0x804004,%eax
  800f73:	8b 40 48             	mov    0x48(%eax),%eax
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	51                   	push   %ecx
  800f7a:	50                   	push   %eax
  800f7b:	68 cc 22 80 00       	push   $0x8022cc
  800f80:	e8 6b f2 ff ff       	call   8001f0 <cprintf>
	*dev = 0;
  800f85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    
			*dev = devtab[i];
  800f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	eb f2                	jmp    800f96 <dev_lookup+0x48>

00800fa4 <fd_close>:
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 1c             	sub    $0x1c,%esp
  800fad:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fb6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fb7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fbd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fc0:	50                   	push   %eax
  800fc1:	e8 32 ff ff ff       	call   800ef8 <fd_lookup>
  800fc6:	89 c3                	mov    %eax,%ebx
  800fc8:	83 c4 08             	add    $0x8,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 05                	js     800fd4 <fd_close+0x30>
	    || fd != fd2)
  800fcf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800fd2:	74 16                	je     800fea <fd_close+0x46>
		return (must_exist ? r : 0);
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	84 c0                	test   %al,%al
  800fd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdd:	0f 44 d8             	cmove  %eax,%ebx
}
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 36                	pushl  (%esi)
  800ff3:	e8 56 ff ff ff       	call   800f4e <dev_lookup>
  800ff8:	89 c3                	mov    %eax,%ebx
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 15                	js     801016 <fd_close+0x72>
		if (dev->dev_close)
  801001:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801004:	8b 40 10             	mov    0x10(%eax),%eax
  801007:	85 c0                	test   %eax,%eax
  801009:	74 1b                	je     801026 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	56                   	push   %esi
  80100f:	ff d0                	call   *%eax
  801011:	89 c3                	mov    %eax,%ebx
  801013:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	56                   	push   %esi
  80101a:	6a 00                	push   $0x0
  80101c:	e8 6c fc ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	eb ba                	jmp    800fe0 <fd_close+0x3c>
			r = 0;
  801026:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102b:	eb e9                	jmp    801016 <fd_close+0x72>

0080102d <close>:

int
close(int fdnum)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801033:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801036:	50                   	push   %eax
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 b9 fe ff ff       	call   800ef8 <fd_lookup>
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 10                	js     801056 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801046:	83 ec 08             	sub    $0x8,%esp
  801049:	6a 01                	push   $0x1
  80104b:	ff 75 f4             	pushl  -0xc(%ebp)
  80104e:	e8 51 ff ff ff       	call   800fa4 <fd_close>
  801053:	83 c4 10             	add    $0x10,%esp
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <close_all>:

void
close_all(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	53                   	push   %ebx
  80105c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	53                   	push   %ebx
  801068:	e8 c0 ff ff ff       	call   80102d <close>
	for (i = 0; i < MAXFD; i++)
  80106d:	83 c3 01             	add    $0x1,%ebx
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	83 fb 20             	cmp    $0x20,%ebx
  801076:	75 ec                	jne    801064 <close_all+0xc>
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801086:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	e8 66 fe ff ff       	call   800ef8 <fd_lookup>
  801092:	89 c3                	mov    %eax,%ebx
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	0f 88 81 00 00 00    	js     801120 <dup+0xa3>
		return r;
	close(newfdnum);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	ff 75 0c             	pushl  0xc(%ebp)
  8010a5:	e8 83 ff ff ff       	call   80102d <close>

	newfd = INDEX2FD(newfdnum);
  8010aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ad:	c1 e6 0c             	shl    $0xc,%esi
  8010b0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010b6:	83 c4 04             	add    $0x4,%esp
  8010b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bc:	e8 d1 fd ff ff       	call   800e92 <fd2data>
  8010c1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8010c3:	89 34 24             	mov    %esi,(%esp)
  8010c6:	e8 c7 fd ff ff       	call   800e92 <fd2data>
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010d0:	89 d8                	mov    %ebx,%eax
  8010d2:	c1 e8 16             	shr    $0x16,%eax
  8010d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010dc:	a8 01                	test   $0x1,%al
  8010de:	74 11                	je     8010f1 <dup+0x74>
  8010e0:	89 d8                	mov    %ebx,%eax
  8010e2:	c1 e8 0c             	shr    $0xc,%eax
  8010e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ec:	f6 c2 01             	test   $0x1,%dl
  8010ef:	75 39                	jne    80112a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f4:	89 d0                	mov    %edx,%eax
  8010f6:	c1 e8 0c             	shr    $0xc,%eax
  8010f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	25 07 0e 00 00       	and    $0xe07,%eax
  801108:	50                   	push   %eax
  801109:	56                   	push   %esi
  80110a:	6a 00                	push   $0x0
  80110c:	52                   	push   %edx
  80110d:	6a 00                	push   $0x0
  80110f:	e8 37 fb ff ff       	call   800c4b <sys_page_map>
  801114:	89 c3                	mov    %eax,%ebx
  801116:	83 c4 20             	add    $0x20,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 31                	js     80114e <dup+0xd1>
		goto err;

	return newfdnum;
  80111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801120:	89 d8                	mov    %ebx,%eax
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80112a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	25 07 0e 00 00       	and    $0xe07,%eax
  801139:	50                   	push   %eax
  80113a:	57                   	push   %edi
  80113b:	6a 00                	push   $0x0
  80113d:	53                   	push   %ebx
  80113e:	6a 00                	push   $0x0
  801140:	e8 06 fb ff ff       	call   800c4b <sys_page_map>
  801145:	89 c3                	mov    %eax,%ebx
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	79 a3                	jns    8010f1 <dup+0x74>
	sys_page_unmap(0, newfd);
  80114e:	83 ec 08             	sub    $0x8,%esp
  801151:	56                   	push   %esi
  801152:	6a 00                	push   $0x0
  801154:	e8 34 fb ff ff       	call   800c8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801159:	83 c4 08             	add    $0x8,%esp
  80115c:	57                   	push   %edi
  80115d:	6a 00                	push   $0x0
  80115f:	e8 29 fb ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	eb b7                	jmp    801120 <dup+0xa3>

00801169 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	53                   	push   %ebx
  80116d:	83 ec 14             	sub    $0x14,%esp
  801170:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801176:	50                   	push   %eax
  801177:	53                   	push   %ebx
  801178:	e8 7b fd ff ff       	call   800ef8 <fd_lookup>
  80117d:	83 c4 08             	add    $0x8,%esp
  801180:	85 c0                	test   %eax,%eax
  801182:	78 3f                	js     8011c3 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118e:	ff 30                	pushl  (%eax)
  801190:	e8 b9 fd ff ff       	call   800f4e <dev_lookup>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 27                	js     8011c3 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119f:	8b 42 08             	mov    0x8(%edx),%eax
  8011a2:	83 e0 03             	and    $0x3,%eax
  8011a5:	83 f8 01             	cmp    $0x1,%eax
  8011a8:	74 1e                	je     8011c8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ad:	8b 40 08             	mov    0x8(%eax),%eax
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	74 35                	je     8011e9 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	ff 75 10             	pushl  0x10(%ebp)
  8011ba:	ff 75 0c             	pushl  0xc(%ebp)
  8011bd:	52                   	push   %edx
  8011be:	ff d0                	call   *%eax
  8011c0:	83 c4 10             	add    $0x10,%esp
}
  8011c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c6:	c9                   	leave  
  8011c7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cd:	8b 40 48             	mov    0x48(%eax),%eax
  8011d0:	83 ec 04             	sub    $0x4,%esp
  8011d3:	53                   	push   %ebx
  8011d4:	50                   	push   %eax
  8011d5:	68 0d 23 80 00       	push   $0x80230d
  8011da:	e8 11 f0 ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e7:	eb da                	jmp    8011c3 <read+0x5a>
		return -E_NOT_SUPP;
  8011e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ee:	eb d3                	jmp    8011c3 <read+0x5a>

008011f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801204:	39 f3                	cmp    %esi,%ebx
  801206:	73 25                	jae    80122d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801208:	83 ec 04             	sub    $0x4,%esp
  80120b:	89 f0                	mov    %esi,%eax
  80120d:	29 d8                	sub    %ebx,%eax
  80120f:	50                   	push   %eax
  801210:	89 d8                	mov    %ebx,%eax
  801212:	03 45 0c             	add    0xc(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	57                   	push   %edi
  801217:	e8 4d ff ff ff       	call   801169 <read>
		if (m < 0)
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 08                	js     80122b <readn+0x3b>
			return m;
		if (m == 0)
  801223:	85 c0                	test   %eax,%eax
  801225:	74 06                	je     80122d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801227:	01 c3                	add    %eax,%ebx
  801229:	eb d9                	jmp    801204 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80122b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80122d:	89 d8                	mov    %ebx,%eax
  80122f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	83 ec 14             	sub    $0x14,%esp
  80123e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801241:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801244:	50                   	push   %eax
  801245:	53                   	push   %ebx
  801246:	e8 ad fc ff ff       	call   800ef8 <fd_lookup>
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	85 c0                	test   %eax,%eax
  801250:	78 3a                	js     80128c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801252:	83 ec 08             	sub    $0x8,%esp
  801255:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125c:	ff 30                	pushl  (%eax)
  80125e:	e8 eb fc ff ff       	call   800f4e <dev_lookup>
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	78 22                	js     80128c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801271:	74 1e                	je     801291 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801273:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801276:	8b 52 0c             	mov    0xc(%edx),%edx
  801279:	85 d2                	test   %edx,%edx
  80127b:	74 35                	je     8012b2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80127d:	83 ec 04             	sub    $0x4,%esp
  801280:	ff 75 10             	pushl  0x10(%ebp)
  801283:	ff 75 0c             	pushl  0xc(%ebp)
  801286:	50                   	push   %eax
  801287:	ff d2                	call   *%edx
  801289:	83 c4 10             	add    $0x10,%esp
}
  80128c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128f:	c9                   	leave  
  801290:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801291:	a1 04 40 80 00       	mov    0x804004,%eax
  801296:	8b 40 48             	mov    0x48(%eax),%eax
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	53                   	push   %ebx
  80129d:	50                   	push   %eax
  80129e:	68 29 23 80 00       	push   $0x802329
  8012a3:	e8 48 ef ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b0:	eb da                	jmp    80128c <write+0x55>
		return -E_NOT_SUPP;
  8012b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b7:	eb d3                	jmp    80128c <write+0x55>

008012b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	ff 75 08             	pushl  0x8(%ebp)
  8012c6:	e8 2d fc ff ff       	call   800ef8 <fd_lookup>
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 0e                	js     8012e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 14             	sub    $0x14,%esp
  8012e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	53                   	push   %ebx
  8012f1:	e8 02 fc ff ff       	call   800ef8 <fd_lookup>
  8012f6:	83 c4 08             	add    $0x8,%esp
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 37                	js     801334 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	ff 30                	pushl  (%eax)
  801309:	e8 40 fc ff ff       	call   800f4e <dev_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 1f                	js     801334 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801315:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801318:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131c:	74 1b                	je     801339 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80131e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801321:	8b 52 18             	mov    0x18(%edx),%edx
  801324:	85 d2                	test   %edx,%edx
  801326:	74 32                	je     80135a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801328:	83 ec 08             	sub    $0x8,%esp
  80132b:	ff 75 0c             	pushl  0xc(%ebp)
  80132e:	50                   	push   %eax
  80132f:	ff d2                	call   *%edx
  801331:	83 c4 10             	add    $0x10,%esp
}
  801334:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801337:	c9                   	leave  
  801338:	c3                   	ret    
			thisenv->env_id, fdnum);
  801339:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133e:	8b 40 48             	mov    0x48(%eax),%eax
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	53                   	push   %ebx
  801345:	50                   	push   %eax
  801346:	68 ec 22 80 00       	push   $0x8022ec
  80134b:	e8 a0 ee ff ff       	call   8001f0 <cprintf>
		return -E_INVAL;
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801358:	eb da                	jmp    801334 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80135a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80135f:	eb d3                	jmp    801334 <ftruncate+0x52>

00801361 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	53                   	push   %ebx
  801365:	83 ec 14             	sub    $0x14,%esp
  801368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 81 fb ff ff       	call   800ef8 <fd_lookup>
  801377:	83 c4 08             	add    $0x8,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 4b                	js     8013c9 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801388:	ff 30                	pushl  (%eax)
  80138a:	e8 bf fb ff ff       	call   800f4e <dev_lookup>
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	78 33                	js     8013c9 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801399:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80139d:	74 2f                	je     8013ce <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80139f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a9:	00 00 00 
	stat->st_isdir = 0;
  8013ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b3:	00 00 00 
	stat->st_dev = dev;
  8013b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c3:	ff 50 14             	call   *0x14(%eax)
  8013c6:	83 c4 10             	add    $0x10,%esp
}
  8013c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    
		return -E_NOT_SUPP;
  8013ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d3:	eb f4                	jmp    8013c9 <fstat+0x68>

008013d5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	6a 00                	push   $0x0
  8013df:	ff 75 08             	pushl  0x8(%ebp)
  8013e2:	e8 e7 01 00 00       	call   8015ce <open>
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 1b                	js     80140b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	50                   	push   %eax
  8013f7:	e8 65 ff ff ff       	call   801361 <fstat>
  8013fc:	89 c6                	mov    %eax,%esi
	close(fd);
  8013fe:	89 1c 24             	mov    %ebx,(%esp)
  801401:	e8 27 fc ff ff       	call   80102d <close>
	return r;
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	89 f3                	mov    %esi,%ebx
}
  80140b:	89 d8                	mov    %ebx,%eax
  80140d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	89 c6                	mov    %eax,%esi
  80141b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801424:	74 27                	je     80144d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801426:	6a 07                	push   $0x7
  801428:	68 00 50 80 00       	push   $0x805000
  80142d:	56                   	push   %esi
  80142e:	ff 35 00 40 80 00    	pushl  0x804000
  801434:	e8 93 07 00 00       	call   801bcc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801439:	83 c4 0c             	add    $0xc,%esp
  80143c:	6a 00                	push   $0x0
  80143e:	53                   	push   %ebx
  80143f:	6a 00                	push   $0x0
  801441:	e8 25 07 00 00       	call   801b6b <ipc_recv>
}
  801446:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	6a 01                	push   $0x1
  801452:	e8 c2 07 00 00       	call   801c19 <ipc_find_env>
  801457:	a3 00 40 80 00       	mov    %eax,0x804000
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	eb c5                	jmp    801426 <fsipc+0x12>

00801461 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801467:	8b 45 08             	mov    0x8(%ebp),%eax
  80146a:	8b 40 0c             	mov    0xc(%eax),%eax
  80146d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801472:	8b 45 0c             	mov    0xc(%ebp),%eax
  801475:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80147a:	ba 00 00 00 00       	mov    $0x0,%edx
  80147f:	b8 02 00 00 00       	mov    $0x2,%eax
  801484:	e8 8b ff ff ff       	call   801414 <fsipc>
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <devfile_flush>:
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	8b 40 0c             	mov    0xc(%eax),%eax
  801497:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149c:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a6:	e8 69 ff ff ff       	call   801414 <fsipc>
}
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <devfile_stat>:
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 04             	sub    $0x4,%esp
  8014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8014cc:	e8 43 ff ff ff       	call   801414 <fsipc>
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 2c                	js     801501 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	68 00 50 80 00       	push   $0x805000
  8014dd:	53                   	push   %ebx
  8014de:	e8 2c f3 ff ff       	call   80080f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e3:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ee:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801501:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801504:	c9                   	leave  
  801505:	c3                   	ret    

00801506 <devfile_write>:
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  80150f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801514:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801519:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151c:	8b 55 08             	mov    0x8(%ebp),%edx
  80151f:	8b 52 0c             	mov    0xc(%edx),%edx
  801522:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801528:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  80152d:	50                   	push   %eax
  80152e:	ff 75 0c             	pushl  0xc(%ebp)
  801531:	68 08 50 80 00       	push   $0x805008
  801536:	e8 62 f4 ff ff       	call   80099d <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 04 00 00 00       	mov    $0x4,%eax
  801545:	e8 ca fe ff ff       	call   801414 <fsipc>
}
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <devfile_read>:
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	8b 40 0c             	mov    0xc(%eax),%eax
  80155a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801565:	ba 00 00 00 00       	mov    $0x0,%edx
  80156a:	b8 03 00 00 00       	mov    $0x3,%eax
  80156f:	e8 a0 fe ff ff       	call   801414 <fsipc>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 1f                	js     801599 <devfile_read+0x4d>
	assert(r <= n);
  80157a:	39 f0                	cmp    %esi,%eax
  80157c:	77 24                	ja     8015a2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80157e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801583:	7f 33                	jg     8015b8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	50                   	push   %eax
  801589:	68 00 50 80 00       	push   $0x805000
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	e8 07 f4 ff ff       	call   80099d <memmove>
	return r;
  801596:	83 c4 10             	add    $0x10,%esp
}
  801599:	89 d8                	mov    %ebx,%eax
  80159b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    
	assert(r <= n);
  8015a2:	68 58 23 80 00       	push   $0x802358
  8015a7:	68 5f 23 80 00       	push   $0x80235f
  8015ac:	6a 7d                	push   $0x7d
  8015ae:	68 74 23 80 00       	push   $0x802374
  8015b3:	e8 5d eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  8015b8:	68 7f 23 80 00       	push   $0x80237f
  8015bd:	68 5f 23 80 00       	push   $0x80235f
  8015c2:	6a 7e                	push   $0x7e
  8015c4:	68 74 23 80 00       	push   $0x802374
  8015c9:	e8 47 eb ff ff       	call   800115 <_panic>

008015ce <open>:
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 1c             	sub    $0x1c,%esp
  8015d6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015d9:	56                   	push   %esi
  8015da:	e8 f9 f1 ff ff       	call   8007d8 <strlen>
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e7:	0f 8f 96 00 00 00    	jg     801683 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	e8 b0 f8 ff ff       	call   800ea9 <fd_alloc>
  8015f9:	89 c3                	mov    %eax,%ebx
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 66                	js     801668 <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801602:	83 ec 08             	sub    $0x8,%esp
  801605:	56                   	push   %esi
  801606:	68 00 50 80 00       	push   $0x805000
  80160b:	e8 ff f1 ff ff       	call   80080f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801610:	8b 45 0c             	mov    0xc(%ebp),%eax
  801613:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801618:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80161b:	b8 01 00 00 00       	mov    $0x1,%eax
  801620:	e8 ef fd ff ff       	call   801414 <fsipc>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 43                	js     801671 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	ff 75 f4             	pushl  -0xc(%ebp)
  801634:	e8 49 f8 ff ff       	call   800e82 <fd2num>
  801639:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163c:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801642:	8b 49 48             	mov    0x48(%ecx),%ecx
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	50                   	push   %eax
  801649:	52                   	push   %edx
  80164a:	ff 32                	pushl  (%edx)
  80164c:	56                   	push   %esi
  80164d:	51                   	push   %ecx
  80164e:	68 8c 23 80 00       	push   $0x80238c
  801653:	e8 98 eb ff ff       	call   8001f0 <cprintf>
	return fd2num(fd);
  801658:	83 c4 14             	add    $0x14,%esp
  80165b:	ff 75 f4             	pushl  -0xc(%ebp)
  80165e:	e8 1f f8 ff ff       	call   800e82 <fd2num>
  801663:	89 c3                	mov    %eax,%ebx
  801665:	83 c4 10             	add    $0x10,%esp
}
  801668:	89 d8                	mov    %ebx,%eax
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    
		fd_close(fd, 0);
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	6a 00                	push   $0x0
  801676:	ff 75 f4             	pushl  -0xc(%ebp)
  801679:	e8 26 f9 ff ff       	call   800fa4 <fd_close>
		return r;
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	eb e5                	jmp    801668 <open+0x9a>
		return -E_BAD_PATH;
  801683:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801688:	eb de                	jmp    801668 <open+0x9a>

0080168a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	b8 08 00 00 00       	mov    $0x8,%eax
  80169a:	e8 75 fd ff ff       	call   801414 <fsipc>
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 de f7 ff ff       	call   800e92 <fd2data>
  8016b4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016b6:	83 c4 08             	add    $0x8,%esp
  8016b9:	68 cc 23 80 00       	push   $0x8023cc
  8016be:	53                   	push   %ebx
  8016bf:	e8 4b f1 ff ff       	call   80080f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016c4:	8b 46 04             	mov    0x4(%esi),%eax
  8016c7:	2b 06                	sub    (%esi),%eax
  8016c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d6:	00 00 00 
	stat->st_dev = &devpipe;
  8016d9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016e0:	30 80 00 
	return 0;
}
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 0c             	sub    $0xc,%esp
  8016f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016f9:	53                   	push   %ebx
  8016fa:	6a 00                	push   $0x0
  8016fc:	e8 8c f5 ff ff       	call   800c8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801701:	89 1c 24             	mov    %ebx,(%esp)
  801704:	e8 89 f7 ff ff       	call   800e92 <fd2data>
  801709:	83 c4 08             	add    $0x8,%esp
  80170c:	50                   	push   %eax
  80170d:	6a 00                	push   $0x0
  80170f:	e8 79 f5 ff ff       	call   800c8d <sys_page_unmap>
}
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <_pipeisclosed>:
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	57                   	push   %edi
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	83 ec 1c             	sub    $0x1c,%esp
  801722:	89 c7                	mov    %eax,%edi
  801724:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801726:	a1 04 40 80 00       	mov    0x804004,%eax
  80172b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80172e:	83 ec 0c             	sub    $0xc,%esp
  801731:	57                   	push   %edi
  801732:	e8 1b 05 00 00       	call   801c52 <pageref>
  801737:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80173a:	89 34 24             	mov    %esi,(%esp)
  80173d:	e8 10 05 00 00       	call   801c52 <pageref>
		nn = thisenv->env_runs;
  801742:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801748:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	39 cb                	cmp    %ecx,%ebx
  801750:	74 1b                	je     80176d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801752:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801755:	75 cf                	jne    801726 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801757:	8b 42 58             	mov    0x58(%edx),%eax
  80175a:	6a 01                	push   $0x1
  80175c:	50                   	push   %eax
  80175d:	53                   	push   %ebx
  80175e:	68 d3 23 80 00       	push   $0x8023d3
  801763:	e8 88 ea ff ff       	call   8001f0 <cprintf>
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	eb b9                	jmp    801726 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80176d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801770:	0f 94 c0             	sete   %al
  801773:	0f b6 c0             	movzbl %al,%eax
}
  801776:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5f                   	pop    %edi
  80177c:	5d                   	pop    %ebp
  80177d:	c3                   	ret    

0080177e <devpipe_write>:
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	57                   	push   %edi
  801782:	56                   	push   %esi
  801783:	53                   	push   %ebx
  801784:	83 ec 28             	sub    $0x28,%esp
  801787:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80178a:	56                   	push   %esi
  80178b:	e8 02 f7 ff ff       	call   800e92 <fd2data>
  801790:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	bf 00 00 00 00       	mov    $0x0,%edi
  80179a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80179d:	74 4f                	je     8017ee <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80179f:	8b 43 04             	mov    0x4(%ebx),%eax
  8017a2:	8b 0b                	mov    (%ebx),%ecx
  8017a4:	8d 51 20             	lea    0x20(%ecx),%edx
  8017a7:	39 d0                	cmp    %edx,%eax
  8017a9:	72 14                	jb     8017bf <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8017ab:	89 da                	mov    %ebx,%edx
  8017ad:	89 f0                	mov    %esi,%eax
  8017af:	e8 65 ff ff ff       	call   801719 <_pipeisclosed>
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	75 3a                	jne    8017f2 <devpipe_write+0x74>
			sys_yield();
  8017b8:	e8 2c f4 ff ff       	call   800be9 <sys_yield>
  8017bd:	eb e0                	jmp    80179f <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017c6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017c9:	89 c2                	mov    %eax,%edx
  8017cb:	c1 fa 1f             	sar    $0x1f,%edx
  8017ce:	89 d1                	mov    %edx,%ecx
  8017d0:	c1 e9 1b             	shr    $0x1b,%ecx
  8017d3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017d6:	83 e2 1f             	and    $0x1f,%edx
  8017d9:	29 ca                	sub    %ecx,%edx
  8017db:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017e3:	83 c0 01             	add    $0x1,%eax
  8017e6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017e9:	83 c7 01             	add    $0x1,%edi
  8017ec:	eb ac                	jmp    80179a <devpipe_write+0x1c>
	return i;
  8017ee:	89 f8                	mov    %edi,%eax
  8017f0:	eb 05                	jmp    8017f7 <devpipe_write+0x79>
				return 0;
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5f                   	pop    %edi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <devpipe_read>:
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	57                   	push   %edi
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	83 ec 18             	sub    $0x18,%esp
  801808:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80180b:	57                   	push   %edi
  80180c:	e8 81 f6 ff ff       	call   800e92 <fd2data>
  801811:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801813:	83 c4 10             	add    $0x10,%esp
  801816:	be 00 00 00 00       	mov    $0x0,%esi
  80181b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80181e:	74 47                	je     801867 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801820:	8b 03                	mov    (%ebx),%eax
  801822:	3b 43 04             	cmp    0x4(%ebx),%eax
  801825:	75 22                	jne    801849 <devpipe_read+0x4a>
			if (i > 0)
  801827:	85 f6                	test   %esi,%esi
  801829:	75 14                	jne    80183f <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80182b:	89 da                	mov    %ebx,%edx
  80182d:	89 f8                	mov    %edi,%eax
  80182f:	e8 e5 fe ff ff       	call   801719 <_pipeisclosed>
  801834:	85 c0                	test   %eax,%eax
  801836:	75 33                	jne    80186b <devpipe_read+0x6c>
			sys_yield();
  801838:	e8 ac f3 ff ff       	call   800be9 <sys_yield>
  80183d:	eb e1                	jmp    801820 <devpipe_read+0x21>
				return i;
  80183f:	89 f0                	mov    %esi,%eax
}
  801841:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5f                   	pop    %edi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801849:	99                   	cltd   
  80184a:	c1 ea 1b             	shr    $0x1b,%edx
  80184d:	01 d0                	add    %edx,%eax
  80184f:	83 e0 1f             	and    $0x1f,%eax
  801852:	29 d0                	sub    %edx,%eax
  801854:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80185c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80185f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801862:	83 c6 01             	add    $0x1,%esi
  801865:	eb b4                	jmp    80181b <devpipe_read+0x1c>
	return i;
  801867:	89 f0                	mov    %esi,%eax
  801869:	eb d6                	jmp    801841 <devpipe_read+0x42>
				return 0;
  80186b:	b8 00 00 00 00       	mov    $0x0,%eax
  801870:	eb cf                	jmp    801841 <devpipe_read+0x42>

00801872 <pipe>:
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	56                   	push   %esi
  801876:	53                   	push   %ebx
  801877:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	50                   	push   %eax
  80187e:	e8 26 f6 ff ff       	call   800ea9 <fd_alloc>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 5b                	js     8018e7 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	68 07 04 00 00       	push   $0x407
  801894:	ff 75 f4             	pushl  -0xc(%ebp)
  801897:	6a 00                	push   $0x0
  801899:	e8 6a f3 ff ff       	call   800c08 <sys_page_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 40                	js     8018e7 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ad:	50                   	push   %eax
  8018ae:	e8 f6 f5 ff ff       	call   800ea9 <fd_alloc>
  8018b3:	89 c3                	mov    %eax,%ebx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 1b                	js     8018d7 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018bc:	83 ec 04             	sub    $0x4,%esp
  8018bf:	68 07 04 00 00       	push   $0x407
  8018c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 3a f3 ff ff       	call   800c08 <sys_page_alloc>
  8018ce:	89 c3                	mov    %eax,%ebx
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	79 19                	jns    8018f0 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dd:	6a 00                	push   $0x0
  8018df:	e8 a9 f3 ff ff       	call   800c8d <sys_page_unmap>
  8018e4:	83 c4 10             	add    $0x10,%esp
}
  8018e7:	89 d8                	mov    %ebx,%eax
  8018e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ec:	5b                   	pop    %ebx
  8018ed:	5e                   	pop    %esi
  8018ee:	5d                   	pop    %ebp
  8018ef:	c3                   	ret    
	va = fd2data(fd0);
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	e8 97 f5 ff ff       	call   800e92 <fd2data>
  8018fb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fd:	83 c4 0c             	add    $0xc,%esp
  801900:	68 07 04 00 00       	push   $0x407
  801905:	50                   	push   %eax
  801906:	6a 00                	push   $0x0
  801908:	e8 fb f2 ff ff       	call   800c08 <sys_page_alloc>
  80190d:	89 c3                	mov    %eax,%ebx
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	0f 88 8c 00 00 00    	js     8019a6 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	ff 75 f0             	pushl  -0x10(%ebp)
  801920:	e8 6d f5 ff ff       	call   800e92 <fd2data>
  801925:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80192c:	50                   	push   %eax
  80192d:	6a 00                	push   $0x0
  80192f:	56                   	push   %esi
  801930:	6a 00                	push   $0x0
  801932:	e8 14 f3 ff ff       	call   800c4b <sys_page_map>
  801937:	89 c3                	mov    %eax,%ebx
  801939:	83 c4 20             	add    $0x20,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 58                	js     801998 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801943:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801949:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801958:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80195e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801963:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80196a:	83 ec 0c             	sub    $0xc,%esp
  80196d:	ff 75 f4             	pushl  -0xc(%ebp)
  801970:	e8 0d f5 ff ff       	call   800e82 <fd2num>
  801975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801978:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80197a:	83 c4 04             	add    $0x4,%esp
  80197d:	ff 75 f0             	pushl  -0x10(%ebp)
  801980:	e8 fd f4 ff ff       	call   800e82 <fd2num>
  801985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801988:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801993:	e9 4f ff ff ff       	jmp    8018e7 <pipe+0x75>
	sys_page_unmap(0, va);
  801998:	83 ec 08             	sub    $0x8,%esp
  80199b:	56                   	push   %esi
  80199c:	6a 00                	push   $0x0
  80199e:	e8 ea f2 ff ff       	call   800c8d <sys_page_unmap>
  8019a3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 da f2 ff ff       	call   800c8d <sys_page_unmap>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	e9 1c ff ff ff       	jmp    8018d7 <pipe+0x65>

008019bb <pipeisclosed>:
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	ff 75 08             	pushl  0x8(%ebp)
  8019c8:	e8 2b f5 ff ff       	call   800ef8 <fd_lookup>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 18                	js     8019ec <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019da:	e8 b3 f4 ff ff       	call   800e92 <fd2data>
	return _pipeisclosed(fd, p);
  8019df:	89 c2                	mov    %eax,%edx
  8019e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e4:	e8 30 fd ff ff       	call   801719 <_pipeisclosed>
  8019e9:	83 c4 10             	add    $0x10,%esp
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019fe:	68 eb 23 80 00       	push   $0x8023eb
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	e8 04 ee ff ff       	call   80080f <strcpy>
	return 0;
}
  801a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devcons_write>:
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	57                   	push   %edi
  801a16:	56                   	push   %esi
  801a17:	53                   	push   %ebx
  801a18:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a1e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a23:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a29:	eb 2f                	jmp    801a5a <devcons_write+0x48>
		m = n - tot;
  801a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a2e:	29 f3                	sub    %esi,%ebx
  801a30:	83 fb 7f             	cmp    $0x7f,%ebx
  801a33:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a38:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a3b:	83 ec 04             	sub    $0x4,%esp
  801a3e:	53                   	push   %ebx
  801a3f:	89 f0                	mov    %esi,%eax
  801a41:	03 45 0c             	add    0xc(%ebp),%eax
  801a44:	50                   	push   %eax
  801a45:	57                   	push   %edi
  801a46:	e8 52 ef ff ff       	call   80099d <memmove>
		sys_cputs(buf, m);
  801a4b:	83 c4 08             	add    $0x8,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	57                   	push   %edi
  801a50:	e8 f7 f0 ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a55:	01 de                	add    %ebx,%esi
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a5d:	72 cc                	jb     801a2b <devcons_write+0x19>
}
  801a5f:	89 f0                	mov    %esi,%eax
  801a61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <devcons_read>:
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a78:	75 07                	jne    801a81 <devcons_read+0x18>
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    
		sys_yield();
  801a7c:	e8 68 f1 ff ff       	call   800be9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a81:	e8 e4 f0 ff ff       	call   800b6a <sys_cgetc>
  801a86:	85 c0                	test   %eax,%eax
  801a88:	74 f2                	je     801a7c <devcons_read+0x13>
	if (c < 0)
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 ec                	js     801a7a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801a8e:	83 f8 04             	cmp    $0x4,%eax
  801a91:	74 0c                	je     801a9f <devcons_read+0x36>
	*(char*)vbuf = c;
  801a93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a96:	88 02                	mov    %al,(%edx)
	return 1;
  801a98:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9d:	eb db                	jmp    801a7a <devcons_read+0x11>
		return 0;
  801a9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa4:	eb d4                	jmp    801a7a <devcons_read+0x11>

00801aa6 <cputchar>:
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ab2:	6a 01                	push   $0x1
  801ab4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	e8 8f f0 ff ff       	call   800b4c <sys_cputs>
}
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <getchar>:
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ac8:	6a 01                	push   $0x1
  801aca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	6a 00                	push   $0x0
  801ad0:	e8 94 f6 ff ff       	call   801169 <read>
	if (r < 0)
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 08                	js     801ae4 <getchar+0x22>
	if (r < 1)
  801adc:	85 c0                	test   %eax,%eax
  801ade:	7e 06                	jle    801ae6 <getchar+0x24>
	return c;
  801ae0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    
		return -E_EOF;
  801ae6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801aeb:	eb f7                	jmp    801ae4 <getchar+0x22>

00801aed <iscons>:
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	ff 75 08             	pushl  0x8(%ebp)
  801afa:	e8 f9 f3 ff ff       	call   800ef8 <fd_lookup>
  801aff:	83 c4 10             	add    $0x10,%esp
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 11                	js     801b17 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b0f:	39 10                	cmp    %edx,(%eax)
  801b11:	0f 94 c0             	sete   %al
  801b14:	0f b6 c0             	movzbl %al,%eax
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <opencons>:
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b22:	50                   	push   %eax
  801b23:	e8 81 f3 ff ff       	call   800ea9 <fd_alloc>
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 3a                	js     801b69 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b2f:	83 ec 04             	sub    $0x4,%esp
  801b32:	68 07 04 00 00       	push   $0x407
  801b37:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3a:	6a 00                	push   $0x0
  801b3c:	e8 c7 f0 ff ff       	call   800c08 <sys_page_alloc>
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	85 c0                	test   %eax,%eax
  801b46:	78 21                	js     801b69 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b51:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	50                   	push   %eax
  801b61:	e8 1c f3 ff ff       	call   800e82 <fd2num>
  801b66:	83 c4 10             	add    $0x10,%esp
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	8b 75 08             	mov    0x8(%ebp),%esi
  801b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b80:	0f 44 c2             	cmove  %edx,%eax
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	50                   	push   %eax
  801b87:	e8 2c f2 ff ff       	call   800db8 <sys_ipc_recv>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 2b                	js     801bbe <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  801b93:	85 f6                	test   %esi,%esi
  801b95:	74 0a                	je     801ba1 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  801b97:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9c:	8b 40 74             	mov    0x74(%eax),%eax
  801b9f:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  801ba1:	85 db                	test   %ebx,%ebx
  801ba3:	74 0a                	je     801baf <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  801ba5:	a1 04 40 80 00       	mov    0x804004,%eax
  801baa:	8b 40 78             	mov    0x78(%eax),%eax
  801bad:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  801baf:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    
        *from_env_store = 0;
  801bbe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  801bc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  801bca:	eb eb                	jmp    801bb7 <ipc_recv+0x4c>

00801bcc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  801bde:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  801be0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801be5:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  801be8:	ff 75 14             	pushl  0x14(%ebp)
  801beb:	53                   	push   %ebx
  801bec:	56                   	push   %esi
  801bed:	57                   	push   %edi
  801bee:	e8 a2 f1 ff ff       	call   800d95 <sys_ipc_try_send>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	74 17                	je     801c11 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  801bfa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bfd:	74 e9                	je     801be8 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  801bff:	50                   	push   %eax
  801c00:	68 f7 23 80 00       	push   $0x8023f7
  801c05:	6a 3e                	push   $0x3e
  801c07:	68 09 24 80 00       	push   $0x802409
  801c0c:	e8 04 e5 ff ff       	call   800115 <_panic>
        }
    }
}
  801c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2d:	8b 52 50             	mov    0x50(%edx),%edx
  801c30:	39 ca                	cmp    %ecx,%edx
  801c32:	74 11                	je     801c45 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801c34:	83 c0 01             	add    $0x1,%eax
  801c37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c3c:	75 e6                	jne    801c24 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c43:	eb 0b                	jmp    801c50 <ipc_find_env+0x37>
			return envs[i].env_id;
  801c45:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c48:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c4d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c58:	89 d0                	mov    %edx,%eax
  801c5a:	c1 e8 16             	shr    $0x16,%eax
  801c5d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801c69:	f6 c1 01             	test   $0x1,%cl
  801c6c:	74 1d                	je     801c8b <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801c6e:	c1 ea 0c             	shr    $0xc,%edx
  801c71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c78:	f6 c2 01             	test   $0x1,%dl
  801c7b:	74 0e                	je     801c8b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c7d:	c1 ea 0c             	shr    $0xc,%edx
  801c80:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c87:	ef 
  801c88:	0f b7 c0             	movzwl %ax,%eax
}
  801c8b:	5d                   	pop    %ebp
  801c8c:	c3                   	ret    
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	75 35                	jne    801ce0 <__udivdi3+0x50>
  801cab:	39 f3                	cmp    %esi,%ebx
  801cad:	0f 87 bd 00 00 00    	ja     801d70 <__udivdi3+0xe0>
  801cb3:	85 db                	test   %ebx,%ebx
  801cb5:	89 d9                	mov    %ebx,%ecx
  801cb7:	75 0b                	jne    801cc4 <__udivdi3+0x34>
  801cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f3                	div    %ebx
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	31 d2                	xor    %edx,%edx
  801cc6:	89 f0                	mov    %esi,%eax
  801cc8:	f7 f1                	div    %ecx
  801cca:	89 c6                	mov    %eax,%esi
  801ccc:	89 e8                	mov    %ebp,%eax
  801cce:	89 f7                	mov    %esi,%edi
  801cd0:	f7 f1                	div    %ecx
  801cd2:	89 fa                	mov    %edi,%edx
  801cd4:	83 c4 1c             	add    $0x1c,%esp
  801cd7:	5b                   	pop    %ebx
  801cd8:	5e                   	pop    %esi
  801cd9:	5f                   	pop    %edi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    
  801cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	39 f2                	cmp    %esi,%edx
  801ce2:	77 7c                	ja     801d60 <__udivdi3+0xd0>
  801ce4:	0f bd fa             	bsr    %edx,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0xf8>
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf7:	29 f8                	sub    %edi,%eax
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	89 da                	mov    %ebx,%edx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d09:	09 d1                	or     %edx,%ecx
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e3                	shl    %cl,%ebx
  801d15:	89 c1                	mov    %eax,%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	89 f9                	mov    %edi,%ecx
  801d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d1f:	d3 e6                	shl    %cl,%esi
  801d21:	89 eb                	mov    %ebp,%ebx
  801d23:	89 c1                	mov    %eax,%ecx
  801d25:	d3 eb                	shr    %cl,%ebx
  801d27:	09 de                	or     %ebx,%esi
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	f7 74 24 08          	divl   0x8(%esp)
  801d2f:	89 d6                	mov    %edx,%esi
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	f7 64 24 0c          	mull   0xc(%esp)
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	72 0c                	jb     801d47 <__udivdi3+0xb7>
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e5                	shl    %cl,%ebp
  801d3f:	39 c5                	cmp    %eax,%ebp
  801d41:	73 5d                	jae    801da0 <__udivdi3+0x110>
  801d43:	39 d6                	cmp    %edx,%esi
  801d45:	75 59                	jne    801da0 <__udivdi3+0x110>
  801d47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d4a:	31 ff                	xor    %edi,%edi
  801d4c:	89 fa                	mov    %edi,%edx
  801d4e:	83 c4 1c             	add    $0x1c,%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5f                   	pop    %edi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    
  801d56:	8d 76 00             	lea    0x0(%esi),%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	31 ff                	xor    %edi,%edi
  801d62:	31 c0                	xor    %eax,%eax
  801d64:	89 fa                	mov    %edi,%edx
  801d66:	83 c4 1c             	add    $0x1c,%esp
  801d69:	5b                   	pop    %ebx
  801d6a:	5e                   	pop    %esi
  801d6b:	5f                   	pop    %edi
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    
  801d6e:	66 90                	xchg   %ax,%ax
  801d70:	31 ff                	xor    %edi,%edi
  801d72:	89 e8                	mov    %ebp,%eax
  801d74:	89 f2                	mov    %esi,%edx
  801d76:	f7 f3                	div    %ebx
  801d78:	89 fa                	mov    %edi,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	72 06                	jb     801d92 <__udivdi3+0x102>
  801d8c:	31 c0                	xor    %eax,%eax
  801d8e:	39 eb                	cmp    %ebp,%ebx
  801d90:	77 d2                	ja     801d64 <__udivdi3+0xd4>
  801d92:	b8 01 00 00 00       	mov    $0x1,%eax
  801d97:	eb cb                	jmp    801d64 <__udivdi3+0xd4>
  801d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801da0:	89 d8                	mov    %ebx,%eax
  801da2:	31 ff                	xor    %edi,%edi
  801da4:	eb be                	jmp    801d64 <__udivdi3+0xd4>
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 ed                	test   %ebp,%ebp
  801dc9:	89 f0                	mov    %esi,%eax
  801dcb:	89 da                	mov    %ebx,%edx
  801dcd:	75 19                	jne    801de8 <__umoddi3+0x38>
  801dcf:	39 df                	cmp    %ebx,%edi
  801dd1:	0f 86 b1 00 00 00    	jbe    801e88 <__umoddi3+0xd8>
  801dd7:	f7 f7                	div    %edi
  801dd9:	89 d0                	mov    %edx,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	83 c4 1c             	add    $0x1c,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	39 dd                	cmp    %ebx,%ebp
  801dea:	77 f1                	ja     801ddd <__umoddi3+0x2d>
  801dec:	0f bd cd             	bsr    %ebp,%ecx
  801def:	83 f1 1f             	xor    $0x1f,%ecx
  801df2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801df6:	0f 84 b4 00 00 00    	je     801eb0 <__umoddi3+0x100>
  801dfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801e01:	89 c2                	mov    %eax,%edx
  801e03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e07:	29 c2                	sub    %eax,%edx
  801e09:	89 c1                	mov    %eax,%ecx
  801e0b:	89 f8                	mov    %edi,%eax
  801e0d:	d3 e5                	shl    %cl,%ebp
  801e0f:	89 d1                	mov    %edx,%ecx
  801e11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e15:	d3 e8                	shr    %cl,%eax
  801e17:	09 c5                	or     %eax,%ebp
  801e19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e1d:	89 c1                	mov    %eax,%ecx
  801e1f:	d3 e7                	shl    %cl,%edi
  801e21:	89 d1                	mov    %edx,%ecx
  801e23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801e27:	89 df                	mov    %ebx,%edi
  801e29:	d3 ef                	shr    %cl,%edi
  801e2b:	89 c1                	mov    %eax,%ecx
  801e2d:	89 f0                	mov    %esi,%eax
  801e2f:	d3 e3                	shl    %cl,%ebx
  801e31:	89 d1                	mov    %edx,%ecx
  801e33:	89 fa                	mov    %edi,%edx
  801e35:	d3 e8                	shr    %cl,%eax
  801e37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e3c:	09 d8                	or     %ebx,%eax
  801e3e:	f7 f5                	div    %ebp
  801e40:	d3 e6                	shl    %cl,%esi
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	f7 64 24 08          	mull   0x8(%esp)
  801e48:	39 d1                	cmp    %edx,%ecx
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	89 d7                	mov    %edx,%edi
  801e4e:	72 06                	jb     801e56 <__umoddi3+0xa6>
  801e50:	75 0e                	jne    801e60 <__umoddi3+0xb0>
  801e52:	39 c6                	cmp    %eax,%esi
  801e54:	73 0a                	jae    801e60 <__umoddi3+0xb0>
  801e56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801e5a:	19 ea                	sbb    %ebp,%edx
  801e5c:	89 d7                	mov    %edx,%edi
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	89 ca                	mov    %ecx,%edx
  801e62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801e67:	29 de                	sub    %ebx,%esi
  801e69:	19 fa                	sbb    %edi,%edx
  801e6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801e6f:	89 d0                	mov    %edx,%eax
  801e71:	d3 e0                	shl    %cl,%eax
  801e73:	89 d9                	mov    %ebx,%ecx
  801e75:	d3 ee                	shr    %cl,%esi
  801e77:	d3 ea                	shr    %cl,%edx
  801e79:	09 f0                	or     %esi,%eax
  801e7b:	83 c4 1c             	add    $0x1c,%esp
  801e7e:	5b                   	pop    %ebx
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    
  801e83:	90                   	nop
  801e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e88:	85 ff                	test   %edi,%edi
  801e8a:	89 f9                	mov    %edi,%ecx
  801e8c:	75 0b                	jne    801e99 <__umoddi3+0xe9>
  801e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e93:	31 d2                	xor    %edx,%edx
  801e95:	f7 f7                	div    %edi
  801e97:	89 c1                	mov    %eax,%ecx
  801e99:	89 d8                	mov    %ebx,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f1                	div    %ecx
  801e9f:	89 f0                	mov    %esi,%eax
  801ea1:	f7 f1                	div    %ecx
  801ea3:	e9 31 ff ff ff       	jmp    801dd9 <__umoddi3+0x29>
  801ea8:	90                   	nop
  801ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	39 dd                	cmp    %ebx,%ebp
  801eb2:	72 08                	jb     801ebc <__umoddi3+0x10c>
  801eb4:	39 f7                	cmp    %esi,%edi
  801eb6:	0f 87 21 ff ff ff    	ja     801ddd <__umoddi3+0x2d>
  801ebc:	89 da                	mov    %ebx,%edx
  801ebe:	89 f0                	mov    %esi,%eax
  801ec0:	29 f8                	sub    %edi,%eax
  801ec2:	19 ea                	sbb    %ebp,%edx
  801ec4:	e9 14 ff ff ff       	jmp    801ddd <__umoddi3+0x2d>
