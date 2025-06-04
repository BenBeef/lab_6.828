
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 04 02 00 00       	call   800235 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 11 16 00 00       	call   801662 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 4b                	jne    8000a4 <primeproc+0x71>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	pushl  -0x20(%ebp)
  80005f:	68 c1 23 80 00       	push   $0x8023c1
  800064:	e8 07 03 00 00       	call   800370 <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 73 1c 00 00       	call   801ce4 <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 49                	js     8000c4 <primeproc+0x91>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 ff 10 00 00       	call   80117f <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 52                	js     8000d6 <primeproc+0xa3>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	85 c0                	test   %eax,%eax
  800086:	75 60                	jne    8000e8 <primeproc+0xb5>
		close(fd);
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	53                   	push   %ebx
  80008c:	e8 0e 14 00 00       	call   80149f <close>
		close(pfd[1]);
  800091:	83 c4 04             	add    $0x4,%esp
  800094:	ff 75 dc             	pushl  -0x24(%ebp)
  800097:	e8 03 14 00 00       	call   80149f <close>
		fd = pfd[0];
  80009c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb a1                	jmp    800045 <primeproc+0x12>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	85 c0                	test   %eax,%eax
  8000a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ae:	0f 4e d0             	cmovle %eax,%edx
  8000b1:	52                   	push   %edx
  8000b2:	50                   	push   %eax
  8000b3:	68 80 23 80 00       	push   $0x802380
  8000b8:	6a 15                	push   $0x15
  8000ba:	68 af 23 80 00       	push   $0x8023af
  8000bf:	e8 d1 01 00 00       	call   800295 <_panic>
		panic("pipe: %e", i);
  8000c4:	50                   	push   %eax
  8000c5:	68 c5 23 80 00       	push   $0x8023c5
  8000ca:	6a 1b                	push   $0x1b
  8000cc:	68 af 23 80 00       	push   $0x8023af
  8000d1:	e8 bf 01 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8000d6:	50                   	push   %eax
  8000d7:	68 ce 23 80 00       	push   $0x8023ce
  8000dc:	6a 1d                	push   $0x1d
  8000de:	68 af 23 80 00       	push   $0x8023af
  8000e3:	e8 ad 01 00 00       	call   800295 <_panic>
	}

	close(pfd[0]);
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8000ee:	e8 ac 13 00 00       	call   80149f <close>
	wfd = pfd[1];
  8000f3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f6:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000f9:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	6a 04                	push   $0x4
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	e8 5a 15 00 00       	call   801662 <readn>
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	83 f8 04             	cmp    $0x4,%eax
  80010e:	75 42                	jne    800152 <primeproc+0x11f>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800113:	99                   	cltd   
  800114:	f7 7d e0             	idivl  -0x20(%ebp)
  800117:	85 d2                	test   %edx,%edx
  800119:	74 e1                	je     8000fc <primeproc+0xc9>
			if ((r=write(wfd, &i, 4)) != 4)
  80011b:	83 ec 04             	sub    $0x4,%esp
  80011e:	6a 04                	push   $0x4
  800120:	56                   	push   %esi
  800121:	57                   	push   %edi
  800122:	e8 82 15 00 00       	call   8016a9 <write>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	83 f8 04             	cmp    $0x4,%eax
  80012d:	74 cd                	je     8000fc <primeproc+0xc9>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	85 c0                	test   %eax,%eax
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	0f 4e d0             	cmovle %eax,%edx
  80013c:	52                   	push   %edx
  80013d:	50                   	push   %eax
  80013e:	ff 75 e0             	pushl  -0x20(%ebp)
  800141:	68 f3 23 80 00       	push   $0x8023f3
  800146:	6a 2e                	push   $0x2e
  800148:	68 af 23 80 00       	push   $0x8023af
  80014d:	e8 43 01 00 00       	call   800295 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800152:	83 ec 04             	sub    $0x4,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	0f 4e d0             	cmovle %eax,%edx
  80015f:	52                   	push   %edx
  800160:	50                   	push   %eax
  800161:	53                   	push   %ebx
  800162:	ff 75 e0             	pushl  -0x20(%ebp)
  800165:	68 d7 23 80 00       	push   $0x8023d7
  80016a:	6a 2b                	push   $0x2b
  80016c:	68 af 23 80 00       	push   $0x8023af
  800171:	e8 1f 01 00 00       	call   800295 <_panic>

00800176 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	53                   	push   %ebx
  80017a:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  80017d:	c7 05 00 30 80 00 0d 	movl   $0x80240d,0x803000
  800184:	24 80 00 

	if ((i=pipe(p)) < 0)
  800187:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 54 1b 00 00       	call   801ce4 <pipe>
  800190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	78 23                	js     8001bd <umain+0x47>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80019a:	e8 e0 0f 00 00       	call   80117f <fork>
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	78 2c                	js     8001cf <umain+0x59>
		panic("fork: %e", id);

	if (id == 0) {
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	75 3a                	jne    8001e1 <umain+0x6b>
		close(p[1]);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8001ad:	e8 ed 12 00 00       	call   80149f <close>
		primeproc(p[0]);
  8001b2:	83 c4 04             	add    $0x4,%esp
  8001b5:	ff 75 ec             	pushl  -0x14(%ebp)
  8001b8:	e8 76 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001bd:	50                   	push   %eax
  8001be:	68 c5 23 80 00       	push   $0x8023c5
  8001c3:	6a 3a                	push   $0x3a
  8001c5:	68 af 23 80 00       	push   $0x8023af
  8001ca:	e8 c6 00 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8001cf:	50                   	push   %eax
  8001d0:	68 ce 23 80 00       	push   $0x8023ce
  8001d5:	6a 3e                	push   $0x3e
  8001d7:	68 af 23 80 00       	push   $0x8023af
  8001dc:	e8 b4 00 00 00       	call   800295 <_panic>
	}

	close(p[0]);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e7:	e8 b3 12 00 00       	call   80149f <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ec:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f3:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f6:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001f9:	83 ec 04             	sub    $0x4,%esp
  8001fc:	6a 04                	push   $0x4
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 f0             	pushl  -0x10(%ebp)
  800202:	e8 a2 14 00 00       	call   8016a9 <write>
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	83 f8 04             	cmp    $0x4,%eax
  80020d:	75 06                	jne    800215 <umain+0x9f>
	for (i=2;; i++)
  80020f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800213:	eb e4                	jmp    8001f9 <umain+0x83>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	85 c0                	test   %eax,%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
  80021f:	0f 4e d0             	cmovle %eax,%edx
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	68 18 24 80 00       	push   $0x802418
  800229:	6a 4a                	push   $0x4a
  80022b:	68 af 23 80 00       	push   $0x8023af
  800230:	e8 60 00 00 00       	call   800295 <_panic>

00800235 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80023d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800240:	e8 05 0b 00 00       	call   800d4a <sys_getenvid>
  800245:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80024d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800252:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800257:	85 db                	test   %ebx,%ebx
  800259:	7e 07                	jle    800262 <libmain+0x2d>
		binaryname = argv[0];
  80025b:	8b 06                	mov    (%esi),%eax
  80025d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	e8 0a ff ff ff       	call   800176 <umain>

	// exit gracefully
	exit();
  80026c:	e8 0a 00 00 00       	call   80027b <exit>
}
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800281:	e8 44 12 00 00       	call   8014ca <close_all>
	sys_env_destroy(0);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	6a 00                	push   $0x0
  80028b:	e8 79 0a 00 00       	call   800d09 <sys_env_destroy>
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a3:	e8 a2 0a 00 00       	call   800d4a <sys_getenvid>
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	56                   	push   %esi
  8002b2:	50                   	push   %eax
  8002b3:	68 3c 24 80 00       	push   $0x80243c
  8002b8:	e8 b3 00 00 00       	call   800370 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	53                   	push   %ebx
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	e8 56 00 00 00       	call   80031f <vcprintf>
	cprintf("\n");
  8002c9:	c7 04 24 c3 23 80 00 	movl   $0x8023c3,(%esp)
  8002d0:	e8 9b 00 00 00       	call   800370 <cprintf>
  8002d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d8:	cc                   	int3   
  8002d9:	eb fd                	jmp    8002d8 <_panic+0x43>

008002db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	53                   	push   %ebx
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e5:	8b 13                	mov    (%ebx),%edx
  8002e7:	8d 42 01             	lea    0x1(%edx),%eax
  8002ea:	89 03                	mov    %eax,(%ebx)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f8:	74 09                	je     800303 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800301:	c9                   	leave  
  800302:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	68 ff 00 00 00       	push   $0xff
  80030b:	8d 43 08             	lea    0x8(%ebx),%eax
  80030e:	50                   	push   %eax
  80030f:	e8 b8 09 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	eb db                	jmp    8002fa <putch+0x1f>

0080031f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800328:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032f:	00 00 00 
	b.cnt = 0;
  800332:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800339:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	50                   	push   %eax
  800349:	68 db 02 80 00       	push   $0x8002db
  80034e:	e8 1a 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	83 c4 08             	add    $0x8,%esp
  800356:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	e8 64 09 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  800368:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800376:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 9d ff ff ff       	call   80031f <vcprintf>
	va_end(ap);

	return cnt;
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 1c             	sub    $0x1c,%esp
  80038d:	89 c7                	mov    %eax,%edi
  80038f:	89 d6                	mov    %edx,%esi
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	8b 55 0c             	mov    0xc(%ebp),%edx
  800397:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ab:	39 d3                	cmp    %edx,%ebx
  8003ad:	72 05                	jb     8003b4 <printnum+0x30>
  8003af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b2:	77 7a                	ja     80042e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	ff 75 18             	pushl  0x18(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c0:	53                   	push   %ebx
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d3:	e8 58 1d 00 00       	call   802130 <__udivdi3>
  8003d8:	83 c4 18             	add    $0x18,%esp
  8003db:	52                   	push   %edx
  8003dc:	50                   	push   %eax
  8003dd:	89 f2                	mov    %esi,%edx
  8003df:	89 f8                	mov    %edi,%eax
  8003e1:	e8 9e ff ff ff       	call   800384 <printnum>
  8003e6:	83 c4 20             	add    $0x20,%esp
  8003e9:	eb 13                	jmp    8003fe <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	ff 75 18             	pushl  0x18(%ebp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f7:	83 eb 01             	sub    $0x1,%ebx
  8003fa:	85 db                	test   %ebx,%ebx
  8003fc:	7f ed                	jg     8003eb <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	56                   	push   %esi
  800402:	83 ec 04             	sub    $0x4,%esp
  800405:	ff 75 e4             	pushl  -0x1c(%ebp)
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff 75 dc             	pushl  -0x24(%ebp)
  80040e:	ff 75 d8             	pushl  -0x28(%ebp)
  800411:	e8 3a 1e 00 00       	call   802250 <__umoddi3>
  800416:	83 c4 14             	add    $0x14,%esp
  800419:	0f be 80 5f 24 80 00 	movsbl 0x80245f(%eax),%eax
  800420:	50                   	push   %eax
  800421:	ff d7                	call   *%edi
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800431:	eb c4                	jmp    8003f7 <printnum+0x73>

00800433 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800439:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	3b 50 04             	cmp    0x4(%eax),%edx
  800442:	73 0a                	jae    80044e <sprintputch+0x1b>
		*b->buf++ = ch;
  800444:	8d 4a 01             	lea    0x1(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	88 02                	mov    %al,(%edx)
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <printfmt>:
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800459:	50                   	push   %eax
  80045a:	ff 75 10             	pushl  0x10(%ebp)
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	e8 05 00 00 00       	call   80046d <vprintfmt>
}
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 2c             	sub    $0x2c,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047f:	e9 c1 03 00 00       	jmp    800845 <vprintfmt+0x3d8>
		padc = ' ';
  800484:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800488:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80048f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800496:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8d 47 01             	lea    0x1(%edi),%eax
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	0f b6 17             	movzbl (%edi),%edx
  8004ab:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 12 04 00 00    	ja     8008c8 <vprintfmt+0x45b>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004c7:	eb d9                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8004cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d0:	eb d0                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	0f b6 d2             	movzbl %dl,%edx
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ed:	83 f9 09             	cmp    $0x9,%ecx
  8004f0:	77 55                	ja     800547 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 40 04             	lea    0x4(%eax),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80050b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050f:	79 91                	jns    8004a2 <vprintfmt+0x35>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	eb 82                	jmp    8004a2 <vprintfmt+0x35>
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	0f 49 d0             	cmovns %eax,%edx
  80052d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 6a ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80053b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800542:	e9 5b ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800547:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80054a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054d:	eb bc                	jmp    80050b <vprintfmt+0x9e>
			lflag++;
  80054f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800555:	e9 48 ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 78 04             	lea    0x4(%eax),%edi
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	ff 30                	pushl  (%eax)
  800566:	ff d6                	call   *%esi
			break;
  800568:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80056b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80056e:	e9 cf 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 78 04             	lea    0x4(%eax),%edi
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	99                   	cltd   
  80057c:	31 d0                	xor    %edx,%eax
  80057e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 f8 0f             	cmp    $0xf,%eax
  800583:	7f 23                	jg     8005a8 <vprintfmt+0x13b>
  800585:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 18                	je     8005a8 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800590:	52                   	push   %edx
  800591:	68 75 29 80 00       	push   $0x802975
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 b3 fe ff ff       	call   800450 <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005a0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005a3:	e9 9a 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8005a8:	50                   	push   %eax
  8005a9:	68 77 24 80 00       	push   $0x802477
  8005ae:	53                   	push   %ebx
  8005af:	56                   	push   %esi
  8005b0:	e8 9b fe ff ff       	call   800450 <printfmt>
  8005b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005bb:	e9 82 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	83 c0 04             	add    $0x4,%eax
  8005c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	b8 70 24 80 00       	mov    $0x802470,%eax
  8005d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dc:	0f 8e bd 00 00 00    	jle    80069f <vprintfmt+0x232>
  8005e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e6:	75 0e                	jne    8005f6 <vprintfmt+0x189>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 6d                	jmp    800663 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005fc:	57                   	push   %edi
  8005fd:	e8 6e 03 00 00       	call   800970 <strnlen>
  800602:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800605:	29 c1                	sub    %eax,%ecx
  800607:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80060a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800611:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800614:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800617:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	eb 0f                	jmp    80062a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 75 e0             	pushl  -0x20(%ebp)
  800622:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 ef 01             	sub    $0x1,%edi
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	85 ff                	test   %edi,%edi
  80062c:	7f ed                	jg     80061b <vprintfmt+0x1ae>
  80062e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800631:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800634:	85 c9                	test   %ecx,%ecx
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	0f 49 c1             	cmovns %ecx,%eax
  80063e:	29 c1                	sub    %eax,%ecx
  800640:	89 75 08             	mov    %esi,0x8(%ebp)
  800643:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800646:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800649:	89 cb                	mov    %ecx,%ebx
  80064b:	eb 16                	jmp    800663 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80064d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800651:	75 31                	jne    800684 <vprintfmt+0x217>
					putch(ch, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	ff 75 0c             	pushl  0xc(%ebp)
  800659:	50                   	push   %eax
  80065a:	ff 55 08             	call   *0x8(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	83 eb 01             	sub    $0x1,%ebx
  800663:	83 c7 01             	add    $0x1,%edi
  800666:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80066a:	0f be c2             	movsbl %dl,%eax
  80066d:	85 c0                	test   %eax,%eax
  80066f:	74 59                	je     8006ca <vprintfmt+0x25d>
  800671:	85 f6                	test   %esi,%esi
  800673:	78 d8                	js     80064d <vprintfmt+0x1e0>
  800675:	83 ee 01             	sub    $0x1,%esi
  800678:	79 d3                	jns    80064d <vprintfmt+0x1e0>
  80067a:	89 df                	mov    %ebx,%edi
  80067c:	8b 75 08             	mov    0x8(%ebp),%esi
  80067f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800682:	eb 37                	jmp    8006bb <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800684:	0f be d2             	movsbl %dl,%edx
  800687:	83 ea 20             	sub    $0x20,%edx
  80068a:	83 fa 5e             	cmp    $0x5e,%edx
  80068d:	76 c4                	jbe    800653 <vprintfmt+0x1e6>
					putch('?', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	6a 3f                	push   $0x3f
  800697:	ff 55 08             	call   *0x8(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb c1                	jmp    800660 <vprintfmt+0x1f3>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb b6                	jmp    800663 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 20                	push   $0x20
  8006b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	7f ee                	jg     8006ad <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c5:	e9 78 01 00 00       	jmp    800842 <vprintfmt+0x3d5>
  8006ca:	89 df                	mov    %ebx,%edi
  8006cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d2:	eb e7                	jmp    8006bb <vprintfmt+0x24e>
	if (lflag >= 2)
  8006d4:	83 f9 01             	cmp    $0x1,%ecx
  8006d7:	7e 3f                	jle    800718 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f4:	79 5c                	jns    800752 <vprintfmt+0x2e5>
				putch('-', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 2d                	push   $0x2d
  8006fc:	ff d6                	call   *%esi
				num = -(long long) num;
  8006fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800701:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800704:	f7 da                	neg    %edx
  800706:	83 d1 00             	adc    $0x0,%ecx
  800709:	f7 d9                	neg    %ecx
  80070b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	e9 10 01 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	75 1b                	jne    800737 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	89 c1                	mov    %eax,%ecx
  800726:	c1 f9 1f             	sar    $0x1f,%ecx
  800729:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
  800735:	eb b9                	jmp    8006f0 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 c1                	mov    %eax,%ecx
  800741:	c1 f9 1f             	sar    $0x1f,%ecx
  800744:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	eb 9e                	jmp    8006f0 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800752:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800755:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	e9 c6 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7e 18                	jle    80077f <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8b 48 04             	mov    0x4(%eax),%ecx
  80076f:	8d 40 08             	lea    0x8(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 a9 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	75 1a                	jne    80079d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800793:	b8 0a 00 00 00       	mov    $0xa,%eax
  800798:	e9 8b 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	eb 74                	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007b4:	83 f9 01             	cmp    $0x1,%ecx
  8007b7:	7e 15                	jle    8007ce <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c1:	8d 40 08             	lea    0x8(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8007c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cc:	eb 5a                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	75 17                	jne    8007e9 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 10                	mov    (%eax),%edx
  8007d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dc:	8d 40 04             	lea    0x4(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8007e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e7:	eb 3f                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  8007f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8007fe:	eb 28                	jmp    800828 <vprintfmt+0x3bb>
			putch('0', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	6a 30                	push   $0x30
  800806:	ff d6                	call   *%esi
			putch('x', putdat);
  800808:	83 c4 08             	add    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	6a 78                	push   $0x78
  80080e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80081a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80081d:	8d 40 04             	lea    0x4(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800823:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80082f:	57                   	push   %edi
  800830:	ff 75 e0             	pushl  -0x20(%ebp)
  800833:	50                   	push   %eax
  800834:	51                   	push   %ecx
  800835:	52                   	push   %edx
  800836:	89 da                	mov    %ebx,%edx
  800838:	89 f0                	mov    %esi,%eax
  80083a:	e8 45 fb ff ff       	call   800384 <printnum>
			break;
  80083f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800845:	83 c7 01             	add    $0x1,%edi
  800848:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80084c:	83 f8 25             	cmp    $0x25,%eax
  80084f:	0f 84 2f fc ff ff    	je     800484 <vprintfmt+0x17>
			if (ch == '\0')
  800855:	85 c0                	test   %eax,%eax
  800857:	0f 84 8b 00 00 00    	je     8008e8 <vprintfmt+0x47b>
			putch(ch, putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	50                   	push   %eax
  800862:	ff d6                	call   *%esi
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb dc                	jmp    800845 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800869:	83 f9 01             	cmp    $0x1,%ecx
  80086c:	7e 15                	jle    800883 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8b 48 04             	mov    0x4(%eax),%ecx
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80087c:	b8 10 00 00 00       	mov    $0x10,%eax
  800881:	eb a5                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	75 17                	jne    80089e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8b 10                	mov    (%eax),%edx
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800891:	8d 40 04             	lea    0x4(%eax),%eax
  800894:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800897:	b8 10 00 00 00       	mov    $0x10,%eax
  80089c:	eb 8a                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b3:	e9 70 ff ff ff       	jmp    800828 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d6                	call   *%esi
			break;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	e9 7a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
			putch('%', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	6a 25                	push   $0x25
  8008ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f8                	mov    %edi,%eax
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x46d>
  8008d7:	83 e8 01             	sub    $0x1,%eax
  8008da:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x46a>
  8008e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e3:	e9 5a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
}
  8008e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 18             	sub    $0x18,%esp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800903:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800906:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	74 26                	je     800937 <vsnprintf+0x47>
  800911:	85 d2                	test   %edx,%edx
  800913:	7e 22                	jle    800937 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800915:	ff 75 14             	pushl  0x14(%ebp)
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091e:	50                   	push   %eax
  80091f:	68 33 04 80 00       	push   $0x800433
  800924:	e8 44 fb ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800929:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800932:	83 c4 10             	add    $0x10,%esp
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    
		return -E_INVAL;
  800937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093c:	eb f7                	jmp    800935 <vsnprintf+0x45>

0080093e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800944:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800947:	50                   	push   %eax
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	ff 75 08             	pushl  0x8(%ebp)
  800951:	e8 9a ff ff ff       	call   8008f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb 03                	jmp    800968 <strlen+0x10>
		n++;
  800965:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800968:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096c:	75 f7                	jne    800965 <strlen+0xd>
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 03                	jmp    800983 <strnlen+0x13>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800983:	39 d0                	cmp    %edx,%eax
  800985:	74 06                	je     80098d <strnlen+0x1d>
  800987:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80098b:	75 f3                	jne    800980 <strnlen+0x10>
	return n;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800999:	89 c2                	mov    %eax,%edx
  80099b:	83 c1 01             	add    $0x1,%ecx
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	75 ef                	jne    80099b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b6:	53                   	push   %ebx
  8009b7:	e8 9c ff ff ff       	call   800958 <strlen>
  8009bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	01 d8                	add    %ebx,%eax
  8009c4:	50                   	push   %eax
  8009c5:	e8 c5 ff ff ff       	call   80098f <strcpy>
	return dst;
}
  8009ca:	89 d8                	mov    %ebx,%eax
  8009cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dc:	89 f3                	mov    %esi,%ebx
  8009de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e1:	89 f2                	mov    %esi,%edx
  8009e3:	eb 0f                	jmp    8009f4 <strncpy+0x23>
		*dst++ = *src;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	0f b6 01             	movzbl (%ecx),%eax
  8009eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009f4:	39 da                	cmp    %ebx,%edx
  8009f6:	75 ed                	jne    8009e5 <strncpy+0x14>
	}
	return ret;
}
  8009f8:	89 f0                	mov    %esi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 75 08             	mov    0x8(%ebp),%esi
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a0c:	89 f0                	mov    %esi,%eax
  800a0e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	75 0b                	jne    800a21 <strlcpy+0x23>
  800a16:	eb 17                	jmp    800a2f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a21:	39 d8                	cmp    %ebx,%eax
  800a23:	74 07                	je     800a2c <strlcpy+0x2e>
  800a25:	0f b6 0a             	movzbl (%edx),%ecx
  800a28:	84 c9                	test   %cl,%cl
  800a2a:	75 ec                	jne    800a18 <strlcpy+0x1a>
		*dst = '\0';
  800a2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2f:	29 f0                	sub    %esi,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3e:	eb 06                	jmp    800a46 <strcmp+0x11>
		p++, q++;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 04                	je     800a51 <strcmp+0x1c>
  800a4d:	3a 02                	cmp    (%edx),%al
  800a4f:	74 ef                	je     800a40 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 c0             	movzbl %al,%eax
  800a54:	0f b6 12             	movzbl (%edx),%edx
  800a57:	29 d0                	sub    %edx,%eax
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strncmp+0x17>
		n--, p++, q++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 16                	je     800a8c <strncmp+0x31>
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	74 04                	je     800a81 <strncmp+0x26>
  800a7d:	3a 0a                	cmp    (%edx),%cl
  800a7f:	74 eb                	je     800a6c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
		return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb f6                	jmp    800a89 <strncmp+0x2e>

00800a93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	74 09                	je     800aad <strchr+0x1a>
		if (*s == c)
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <strchr+0x1f>
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	eb f0                	jmp    800a9d <strchr+0xa>
			return (char *) s;
	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abe:	eb 03                	jmp    800ac3 <strfind+0xf>
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 04                	je     800ace <strfind+0x1a>
  800aca:	84 d2                	test   %dl,%dl
  800acc:	75 f2                	jne    800ac0 <strfind+0xc>
			break;
	return (char *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 13                	je     800af3 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae6:	75 05                	jne    800aed <memset+0x1d>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	74 0d                	je     800afa <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	fc                   	cld    
  800af1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
		c &= 0xFF;
  800afa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	c1 e3 08             	shl    $0x8,%ebx
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	c1 e0 18             	shl    $0x18,%eax
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	c1 e6 10             	shl    $0x10,%esi
  800b0d:	09 f0                	or     %esi,%eax
  800b0f:	09 c2                	or     %eax,%edx
  800b11:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b13:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	fc                   	cld    
  800b19:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1b:	eb d6                	jmp    800af3 <memset+0x23>

00800b1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2b:	39 c6                	cmp    %eax,%esi
  800b2d:	73 35                	jae    800b64 <memmove+0x47>
  800b2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b32:	39 c2                	cmp    %eax,%edx
  800b34:	76 2e                	jbe    800b64 <memmove+0x47>
		s += n;
		d += n;
  800b36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	09 fe                	or     %edi,%esi
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	74 0c                	je     800b51 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b45:	83 ef 01             	sub    $0x1,%edi
  800b48:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b4b:	fd                   	std    
  800b4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4e:	fc                   	cld    
  800b4f:	eb 21                	jmp    800b72 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 ef                	jne    800b45 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b56:	83 ef 04             	sub    $0x4,%edi
  800b59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b5f:	fd                   	std    
  800b60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b62:	eb ea                	jmp    800b4e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	89 f2                	mov    %esi,%edx
  800b66:	09 c2                	or     %eax,%edx
  800b68:	f6 c2 03             	test   $0x3,%dl
  800b6b:	74 09                	je     800b76 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	fc                   	cld    
  800b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 f2                	jne    800b6d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	fc                   	cld    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb ed                	jmp    800b72 <memmove+0x55>

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 87 ff ff ff       	call   800b1d <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	74 1c                	je     800bc8 <memcmp+0x30>
		if (*s1 != *s2)
  800bac:	0f b6 08             	movzbl (%eax),%ecx
  800baf:	0f b6 1a             	movzbl (%edx),%ebx
  800bb2:	38 d9                	cmp    %bl,%cl
  800bb4:	75 08                	jne    800bbe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	eb ea                	jmp    800ba8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bbe:	0f b6 c1             	movzbl %cl,%eax
  800bc1:	0f b6 db             	movzbl %bl,%ebx
  800bc4:	29 d8                	sub    %ebx,%eax
  800bc6:	eb 05                	jmp    800bcd <memcmp+0x35>
	}

	return 0;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bdf:	39 d0                	cmp    %edx,%eax
  800be1:	73 09                	jae    800bec <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be3:	38 08                	cmp    %cl,(%eax)
  800be5:	74 05                	je     800bec <memfind+0x1b>
	for (; s < ends; s++)
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	eb f3                	jmp    800bdf <memfind+0xe>
			break;
	return (void *) s;
}
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	eb 03                	jmp    800bff <strtol+0x11>
		s++;
  800bfc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bff:	0f b6 01             	movzbl (%ecx),%eax
  800c02:	3c 20                	cmp    $0x20,%al
  800c04:	74 f6                	je     800bfc <strtol+0xe>
  800c06:	3c 09                	cmp    $0x9,%al
  800c08:	74 f2                	je     800bfc <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c0a:	3c 2b                	cmp    $0x2b,%al
  800c0c:	74 2e                	je     800c3c <strtol+0x4e>
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c13:	3c 2d                	cmp    $0x2d,%al
  800c15:	74 2f                	je     800c46 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1d:	75 05                	jne    800c24 <strtol+0x36>
  800c1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c22:	74 2c                	je     800c50 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	75 0a                	jne    800c32 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c30:	74 28                	je     800c5a <strtol+0x6c>
		base = 10;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c3a:	eb 50                	jmp    800c8c <strtol+0x9e>
		s++;
  800c3c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c44:	eb d1                	jmp    800c17 <strtol+0x29>
		s++, neg = 1;
  800c46:	83 c1 01             	add    $0x1,%ecx
  800c49:	bf 01 00 00 00       	mov    $0x1,%edi
  800c4e:	eb c7                	jmp    800c17 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c54:	74 0e                	je     800c64 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c56:	85 db                	test   %ebx,%ebx
  800c58:	75 d8                	jne    800c32 <strtol+0x44>
		s++, base = 8;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c62:	eb ce                	jmp    800c32 <strtol+0x44>
		s += 2, base = 16;
  800c64:	83 c1 02             	add    $0x2,%ecx
  800c67:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6c:	eb c4                	jmp    800c32 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 29                	ja     800ca1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c81:	7d 30                	jge    800cb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c8c:	0f b6 11             	movzbl (%ecx),%edx
  800c8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c92:	89 f3                	mov    %esi,%ebx
  800c94:	80 fb 09             	cmp    $0x9,%bl
  800c97:	77 d5                	ja     800c6e <strtol+0x80>
			dig = *s - '0';
  800c99:	0f be d2             	movsbl %dl,%edx
  800c9c:	83 ea 30             	sub    $0x30,%edx
  800c9f:	eb dd                	jmp    800c7e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ca1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca4:	89 f3                	mov    %esi,%ebx
  800ca6:	80 fb 19             	cmp    $0x19,%bl
  800ca9:	77 08                	ja     800cb3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cab:	0f be d2             	movsbl %dl,%edx
  800cae:	83 ea 37             	sub    $0x37,%edx
  800cb1:	eb cb                	jmp    800c7e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb7:	74 05                	je     800cbe <strtol+0xd0>
		*endptr = (char *) s;
  800cb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cbe:	89 c2                	mov    %eax,%edx
  800cc0:	f7 da                	neg    %edx
  800cc2:	85 ff                	test   %edi,%edi
  800cc4:	0f 45 c2             	cmovne %edx,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	89 c3                	mov    %eax,%ebx
  800cdf:	89 c7                	mov    %eax,%edi
  800ce1:	89 c6                	mov    %eax,%esi
  800ce3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_cgetc>:

int
sys_cgetc(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7f 08                	jg     800d33 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 03                	push   $0x3
  800d39:	68 5f 27 80 00       	push   $0x80275f
  800d3e:	6a 23                	push   $0x23
  800d40:	68 7c 27 80 00       	push   $0x80277c
  800d45:	e8 4b f5 ff ff       	call   800295 <_panic>

00800d4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5a:	89 d1                	mov    %edx,%ecx
  800d5c:	89 d3                	mov    %edx,%ebx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	89 d6                	mov    %edx,%esi
  800d62:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_yield>:

void
sys_yield(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d79:	89 d1                	mov    %edx,%ecx
  800d7b:	89 d3                	mov    %edx,%ebx
  800d7d:	89 d7                	mov    %edx,%edi
  800d7f:	89 d6                	mov    %edx,%esi
  800d81:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d91:	be 00 00 00 00       	mov    $0x0,%esi
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	89 f7                	mov    %esi,%edi
  800da6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7f 08                	jg     800db4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 04                	push   $0x4
  800dba:	68 5f 27 80 00       	push   $0x80275f
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 7c 27 80 00       	push   $0x80277c
  800dc6:	e8 ca f4 ff ff       	call   800295 <_panic>

00800dcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de5:	8b 75 18             	mov    0x18(%ebp),%esi
  800de8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7f 08                	jg     800df6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 05                	push   $0x5
  800dfc:	68 5f 27 80 00       	push   $0x80275f
  800e01:	6a 23                	push   $0x23
  800e03:	68 7c 27 80 00       	push   $0x80277c
  800e08:	e8 88 f4 ff ff       	call   800295 <_panic>

00800e0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	b8 06 00 00 00       	mov    $0x6,%eax
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7f 08                	jg     800e38 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 06                	push   $0x6
  800e3e:	68 5f 27 80 00       	push   $0x80275f
  800e43:	6a 23                	push   $0x23
  800e45:	68 7c 27 80 00       	push   $0x80277c
  800e4a:	e8 46 f4 ff ff       	call   800295 <_panic>

00800e4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	b8 08 00 00 00       	mov    $0x8,%eax
  800e68:	89 df                	mov    %ebx,%edi
  800e6a:	89 de                	mov    %ebx,%esi
  800e6c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	7f 08                	jg     800e7a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	50                   	push   %eax
  800e7e:	6a 08                	push   $0x8
  800e80:	68 5f 27 80 00       	push   $0x80275f
  800e85:	6a 23                	push   $0x23
  800e87:	68 7c 27 80 00       	push   $0x80277c
  800e8c:	e8 04 f4 ff ff       	call   800295 <_panic>

00800e91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7f 08                	jg     800ebc <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	50                   	push   %eax
  800ec0:	6a 09                	push   $0x9
  800ec2:	68 5f 27 80 00       	push   $0x80275f
  800ec7:	6a 23                	push   $0x23
  800ec9:	68 7c 27 80 00       	push   $0x80277c
  800ece:	e8 c2 f3 ff ff       	call   800295 <_panic>

00800ed3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eec:	89 df                	mov    %ebx,%edi
  800eee:	89 de                	mov    %ebx,%esi
  800ef0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7f 08                	jg     800efe <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	50                   	push   %eax
  800f02:	6a 0a                	push   $0xa
  800f04:	68 5f 27 80 00       	push   $0x80275f
  800f09:	6a 23                	push   $0x23
  800f0b:	68 7c 27 80 00       	push   $0x80277c
  800f10:	e8 80 f3 ff ff       	call   800295 <_panic>

00800f15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f31:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4e:	89 cb                	mov    %ecx,%ebx
  800f50:	89 cf                	mov    %ecx,%edi
  800f52:	89 ce                	mov    %ecx,%esi
  800f54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7f 08                	jg     800f62 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	50                   	push   %eax
  800f66:	6a 0d                	push   $0xd
  800f68:	68 5f 27 80 00       	push   $0x80275f
  800f6d:	6a 23                	push   $0x23
  800f6f:	68 7c 27 80 00       	push   $0x80277c
  800f74:	e8 1c f3 ff ff       	call   800295 <_panic>

00800f79 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f83:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f85:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  800f88:	a8 02                	test   $0x2,%al
  800f8a:	0f 84 89 00 00 00    	je     801019 <pgfault+0xa0>
  800f90:	89 da                	mov    %ebx,%edx
  800f92:	c1 ea 0c             	shr    $0xc,%edx
  800f95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f9c:	f6 c6 08             	test   $0x8,%dh
  800f9f:	74 78                	je     801019 <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fa1:	83 ec 04             	sub    $0x4,%esp
  800fa4:	6a 07                	push   $0x7
  800fa6:	68 00 f0 7f 00       	push   $0x7ff000
  800fab:	6a 00                	push   $0x0
  800fad:	e8 d6 fd ff ff       	call   800d88 <sys_page_alloc>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	0f 88 8b 00 00 00    	js     801048 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	68 00 10 00 00       	push   $0x1000
  800fc5:	53                   	push   %ebx
  800fc6:	68 00 f0 7f 00       	push   $0x7ff000
  800fcb:	e8 4d fb ff ff       	call   800b1d <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fd0:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fd7:	53                   	push   %ebx
  800fd8:	6a 00                	push   $0x0
  800fda:	68 00 f0 7f 00       	push   $0x7ff000
  800fdf:	6a 00                	push   $0x0
  800fe1:	e8 e5 fd ff ff       	call   800dcb <sys_page_map>
  800fe6:	83 c4 20             	add    $0x20,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 6d                	js     80105a <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  800fed:	83 ec 08             	sub    $0x8,%esp
  800ff0:	68 00 f0 7f 00       	push   $0x7ff000
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 11 fe ff ff       	call   800e0d <sys_page_unmap>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 69                	js     80106c <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	53                   	push   %ebx
  801007:	68 e8 27 80 00       	push   $0x8027e8
  80100c:	e8 5f f3 ff ff       	call   800370 <cprintf>

}
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801017:	c9                   	leave  
  801018:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  801019:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80101f:	8b 4a 48             	mov    0x48(%edx),%ecx
  801022:	89 da                	mov    %ebx,%edx
  801024:	c1 ea 0c             	shr    $0xc,%edx
  801027:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80102e:	51                   	push   %ecx
  80102f:	53                   	push   %ebx
  801030:	68 00 00 40 ef       	push   $0xef400000
  801035:	52                   	push   %edx
  801036:	50                   	push   %eax
  801037:	68 8c 27 80 00       	push   $0x80278c
  80103c:	6a 1e                	push   $0x1e
  80103e:	68 09 28 80 00       	push   $0x802809
  801043:	e8 4d f2 ff ff       	call   800295 <_panic>
        panic("sys_page_alloc error %e", r);
  801048:	50                   	push   %eax
  801049:	68 14 28 80 00       	push   $0x802814
  80104e:	6a 28                	push   $0x28
  801050:	68 09 28 80 00       	push   $0x802809
  801055:	e8 3b f2 ff ff       	call   800295 <_panic>
        panic("sys_page_map error %e", r);
  80105a:	50                   	push   %eax
  80105b:	68 2c 28 80 00       	push   $0x80282c
  801060:	6a 2b                	push   $0x2b
  801062:	68 09 28 80 00       	push   $0x802809
  801067:	e8 29 f2 ff ff       	call   800295 <_panic>
        panic("sys_page_unmap error %e", r);
  80106c:	50                   	push   %eax
  80106d:	68 42 28 80 00       	push   $0x802842
  801072:	6a 2d                	push   $0x2d
  801074:	68 09 28 80 00       	push   $0x802809
  801079:	e8 17 f2 ff ff       	call   800295 <_panic>

0080107e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801084:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80108b:	74 23                	je     8010b0 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801095:	a1 04 40 80 00       	mov    0x804004,%eax
  80109a:	8b 40 48             	mov    0x48(%eax),%eax
  80109d:	83 ec 08             	sub    $0x8,%esp
  8010a0:	68 dd 1f 80 00       	push   $0x801fdd
  8010a5:	50                   	push   %eax
  8010a6:	e8 28 fe ff ff       	call   800ed3 <sys_env_set_pgfault_upcall>
}
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  8010b0:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b5:	8b 40 48             	mov    0x48(%eax),%eax
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	6a 07                	push   $0x7
  8010bd:	68 00 f0 bf ee       	push   $0xeebff000
  8010c2:	50                   	push   %eax
  8010c3:	e8 c0 fc ff ff       	call   800d88 <sys_page_alloc>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 be                	jns    80108d <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  8010cf:	50                   	push   %eax
  8010d0:	68 5a 28 80 00       	push   $0x80285a
  8010d5:	6a 21                	push   $0x21
  8010d7:	68 6d 28 80 00       	push   $0x80286d
  8010dc:	e8 b4 f1 ff ff       	call   800295 <_panic>

008010e1 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  8010ec:	83 ec 04             	sub    $0x4,%esp
  8010ef:	6a 07                	push   $0x7
  8010f1:	53                   	push   %ebx
  8010f2:	56                   	push   %esi
  8010f3:	e8 90 fc ff ff       	call   800d88 <sys_page_alloc>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 4a                	js     801149 <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8010ff:	83 ec 0c             	sub    $0xc,%esp
  801102:	6a 07                	push   $0x7
  801104:	68 00 00 40 00       	push   $0x400000
  801109:	6a 00                	push   $0x0
  80110b:	53                   	push   %ebx
  80110c:	56                   	push   %esi
  80110d:	e8 b9 fc ff ff       	call   800dcb <sys_page_map>
  801112:	83 c4 20             	add    $0x20,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 42                	js     80115b <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	68 00 10 00 00       	push   $0x1000
  801121:	53                   	push   %ebx
  801122:	68 00 00 40 00       	push   $0x400000
  801127:	e8 f1 f9 ff ff       	call   800b1d <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80112c:	83 c4 08             	add    $0x8,%esp
  80112f:	68 00 00 40 00       	push   $0x400000
  801134:	6a 00                	push   $0x0
  801136:	e8 d2 fc ff ff       	call   800e0d <sys_page_unmap>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 2b                	js     80116d <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  801142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801145:	5b                   	pop    %ebx
  801146:	5e                   	pop    %esi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  801149:	50                   	push   %eax
  80114a:	68 5a 28 80 00       	push   $0x80285a
  80114f:	6a 63                	push   $0x63
  801151:	68 09 28 80 00       	push   $0x802809
  801156:	e8 3a f1 ff ff       	call   800295 <_panic>
        panic("sys_page_map: %e", r);
  80115b:	50                   	push   %eax
  80115c:	68 7d 28 80 00       	push   $0x80287d
  801161:	6a 65                	push   $0x65
  801163:	68 09 28 80 00       	push   $0x802809
  801168:	e8 28 f1 ff ff       	call   800295 <_panic>
        panic("sys_page_unmap: %e", r);
  80116d:	50                   	push   %eax
  80116e:	68 8e 28 80 00       	push   $0x80288e
  801173:	6a 68                	push   $0x68
  801175:	68 09 28 80 00       	push   $0x802809
  80117a:	e8 16 f1 ff ff       	call   800295 <_panic>

0080117f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801188:	a1 04 40 80 00       	mov    0x804004,%eax
  80118d:	8b 40 64             	mov    0x64(%eax),%eax
  801190:	85 c0                	test   %eax,%eax
  801192:	74 1f                	je     8011b3 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801194:	b8 07 00 00 00       	mov    $0x7,%eax
  801199:	cd 30                	int    $0x30
  80119b:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  80119d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	74 21                	je     8011c5 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  8011a4:	be 08 40 80 00       	mov    $0x804008,%esi
  8011a9:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	eb 7b                	jmp    80122e <fork+0xaf>
        set_pgfault_handler(pgfault);
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	68 79 0f 80 00       	push   $0x800f79
  8011bb:	e8 be fe ff ff       	call   80107e <set_pgfault_handler>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	eb cf                	jmp    801194 <fork+0x15>
        set_pgfault_handler(pgfault);
  8011c5:	83 ec 0c             	sub    $0xc,%esp
  8011c8:	68 79 0f 80 00       	push   $0x800f79
  8011cd:	e8 ac fe ff ff       	call   80107e <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  8011d2:	e8 73 fb ff ff       	call   800d4a <sys_getenvid>
  8011d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e4:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	e9 ca 00 00 00       	jmp    8012bb <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  8011f1:	89 d1                	mov    %edx,%ecx
  8011f3:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  8011f9:	81 e2 02 08 00 00    	and    $0x802,%edx
  8011ff:	89 cf                	mov    %ecx,%edi
  801201:	81 cf 00 08 00 00    	or     $0x800,%edi
  801207:	85 d2                	test   %edx,%edx
  801209:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	51                   	push   %ecx
  801210:	50                   	push   %eax
  801211:	ff 75 e4             	pushl  -0x1c(%ebp)
  801214:	50                   	push   %eax
  801215:	6a 00                	push   $0x0
  801217:	e8 af fb ff ff       	call   800dcb <sys_page_map>
  80121c:	83 c4 20             	add    $0x20,%esp
  80121f:	85 c0                	test   %eax,%eax
  801221:	78 45                	js     801268 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801223:	83 c3 01             	add    $0x1,%ebx
  801226:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  80122c:	74 4c                	je     80127a <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  80122e:	39 de                	cmp    %ebx,%esi
  801230:	74 f1                	je     801223 <fork+0xa4>
  801232:	89 d8                	mov    %ebx,%eax
  801234:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  801237:	89 c2                	mov    %eax,%edx
  801239:	c1 ea 16             	shr    $0x16,%edx
  80123c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801243:	f6 c2 05             	test   $0x5,%dl
  801246:	74 db                	je     801223 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  801248:	89 c2                	mov    %eax,%edx
  80124a:	c1 ea 0c             	shr    $0xc,%edx
  80124d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801254:	f6 c2 04             	test   $0x4,%dl
  801257:	74 ca                	je     801223 <fork+0xa4>
    if (perm & PTE_SHARE) {
  801259:	f6 c6 04             	test   $0x4,%dh
  80125c:	74 93                	je     8011f1 <fork+0x72>
        perm &= ~PTE_COW;
  80125e:	89 d1                	mov    %edx,%ecx
  801260:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801266:	eb a4                	jmp    80120c <fork+0x8d>
        panic("sys_page_map error %e", r);
  801268:	50                   	push   %eax
  801269:	68 2c 28 80 00       	push   $0x80282c
  80126e:	6a 57                	push   $0x57
  801270:	68 09 28 80 00       	push   $0x802809
  801275:	e8 1b f0 ff ff       	call   800295 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	b8 08 40 80 00       	mov    $0x804008,%eax
  801282:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801287:	50                   	push   %eax
  801288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80128b:	e8 51 fe ff ff       	call   8010e1 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801290:	83 c4 08             	add    $0x8,%esp
  801293:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801296:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129b:	50                   	push   %eax
  80129c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80129f:	e8 3d fe ff ff       	call   8010e1 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	6a 02                	push   $0x2
  8012a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ac:	e8 9e fb ff ff       	call   800e4f <sys_env_set_status>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 0d                	js     8012c5 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8012b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  8012c5:	50                   	push   %eax
  8012c6:	68 a1 28 80 00       	push   $0x8028a1
  8012cb:	68 a0 00 00 00       	push   $0xa0
  8012d0:	68 09 28 80 00       	push   $0x802809
  8012d5:	e8 bb ef ff ff       	call   800295 <_panic>

008012da <sfork>:

// Challenge!
int
sfork(void)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012e0:	68 b8 28 80 00       	push   $0x8028b8
  8012e5:	68 a9 00 00 00       	push   $0xa9
  8012ea:	68 09 28 80 00       	push   $0x802809
  8012ef:	e8 a1 ef ff ff       	call   800295 <_panic>

008012f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801307:	8b 45 08             	mov    0x8(%ebp),%eax
  80130a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80130f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801314:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801321:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801326:	89 c2                	mov    %eax,%edx
  801328:	c1 ea 16             	shr    $0x16,%edx
  80132b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801332:	f6 c2 01             	test   $0x1,%dl
  801335:	74 2a                	je     801361 <fd_alloc+0x46>
  801337:	89 c2                	mov    %eax,%edx
  801339:	c1 ea 0c             	shr    $0xc,%edx
  80133c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801343:	f6 c2 01             	test   $0x1,%dl
  801346:	74 19                	je     801361 <fd_alloc+0x46>
  801348:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80134d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801352:	75 d2                	jne    801326 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801354:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80135a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80135f:	eb 07                	jmp    801368 <fd_alloc+0x4d>
			*fd_store = fd;
  801361:	89 01                	mov    %eax,(%ecx)
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801368:	5d                   	pop    %ebp
  801369:	c3                   	ret    

0080136a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801370:	83 f8 1f             	cmp    $0x1f,%eax
  801373:	77 36                	ja     8013ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801375:	c1 e0 0c             	shl    $0xc,%eax
  801378:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	c1 ea 16             	shr    $0x16,%edx
  801382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801389:	f6 c2 01             	test   $0x1,%dl
  80138c:	74 24                	je     8013b2 <fd_lookup+0x48>
  80138e:	89 c2                	mov    %eax,%edx
  801390:	c1 ea 0c             	shr    $0xc,%edx
  801393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80139a:	f6 c2 01             	test   $0x1,%dl
  80139d:	74 1a                	je     8013b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80139f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8013a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
		return -E_INVAL;
  8013ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b0:	eb f7                	jmp    8013a9 <fd_lookup+0x3f>
		return -E_INVAL;
  8013b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b7:	eb f0                	jmp    8013a9 <fd_lookup+0x3f>
  8013b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013be:	eb e9                	jmp    8013a9 <fd_lookup+0x3f>

008013c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c9:	ba 4c 29 80 00       	mov    $0x80294c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013ce:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013d3:	39 08                	cmp    %ecx,(%eax)
  8013d5:	74 33                	je     80140a <dev_lookup+0x4a>
  8013d7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013da:	8b 02                	mov    (%edx),%eax
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	75 f3                	jne    8013d3 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8013e5:	8b 40 48             	mov    0x48(%eax),%eax
  8013e8:	83 ec 04             	sub    $0x4,%esp
  8013eb:	51                   	push   %ecx
  8013ec:	50                   	push   %eax
  8013ed:	68 d0 28 80 00       	push   $0x8028d0
  8013f2:	e8 79 ef ff ff       	call   800370 <cprintf>
	*dev = 0;
  8013f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801400:	83 c4 10             	add    $0x10,%esp
  801403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    
			*dev = devtab[i];
  80140a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80140d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80140f:	b8 00 00 00 00       	mov    $0x0,%eax
  801414:	eb f2                	jmp    801408 <dev_lookup+0x48>

00801416 <fd_close>:
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	83 ec 1c             	sub    $0x1c,%esp
  80141f:	8b 75 08             	mov    0x8(%ebp),%esi
  801422:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801425:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801428:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801429:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801432:	50                   	push   %eax
  801433:	e8 32 ff ff ff       	call   80136a <fd_lookup>
  801438:	89 c3                	mov    %eax,%ebx
  80143a:	83 c4 08             	add    $0x8,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 05                	js     801446 <fd_close+0x30>
	    || fd != fd2)
  801441:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801444:	74 16                	je     80145c <fd_close+0x46>
		return (must_exist ? r : 0);
  801446:	89 f8                	mov    %edi,%eax
  801448:	84 c0                	test   %al,%al
  80144a:	b8 00 00 00 00       	mov    $0x0,%eax
  80144f:	0f 44 d8             	cmove  %eax,%ebx
}
  801452:	89 d8                	mov    %ebx,%eax
  801454:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	ff 36                	pushl  (%esi)
  801465:	e8 56 ff ff ff       	call   8013c0 <dev_lookup>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 15                	js     801488 <fd_close+0x72>
		if (dev->dev_close)
  801473:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801476:	8b 40 10             	mov    0x10(%eax),%eax
  801479:	85 c0                	test   %eax,%eax
  80147b:	74 1b                	je     801498 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	56                   	push   %esi
  801481:	ff d0                	call   *%eax
  801483:	89 c3                	mov    %eax,%ebx
  801485:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	56                   	push   %esi
  80148c:	6a 00                	push   $0x0
  80148e:	e8 7a f9 ff ff       	call   800e0d <sys_page_unmap>
	return r;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	eb ba                	jmp    801452 <fd_close+0x3c>
			r = 0;
  801498:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149d:	eb e9                	jmp    801488 <fd_close+0x72>

0080149f <close>:

int
close(int fdnum)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	ff 75 08             	pushl  0x8(%ebp)
  8014ac:	e8 b9 fe ff ff       	call   80136a <fd_lookup>
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 10                	js     8014c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	6a 01                	push   $0x1
  8014bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c0:	e8 51 ff ff ff       	call   801416 <fd_close>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <close_all>:

void
close_all(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	53                   	push   %ebx
  8014da:	e8 c0 ff ff ff       	call   80149f <close>
	for (i = 0; i < MAXFD; i++)
  8014df:	83 c3 01             	add    $0x1,%ebx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	83 fb 20             	cmp    $0x20,%ebx
  8014e8:	75 ec                	jne    8014d6 <close_all+0xc>
}
  8014ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	57                   	push   %edi
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014fb:	50                   	push   %eax
  8014fc:	ff 75 08             	pushl  0x8(%ebp)
  8014ff:	e8 66 fe ff ff       	call   80136a <fd_lookup>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	83 c4 08             	add    $0x8,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	0f 88 81 00 00 00    	js     801592 <dup+0xa3>
		return r;
	close(newfdnum);
  801511:	83 ec 0c             	sub    $0xc,%esp
  801514:	ff 75 0c             	pushl  0xc(%ebp)
  801517:	e8 83 ff ff ff       	call   80149f <close>

	newfd = INDEX2FD(newfdnum);
  80151c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80151f:	c1 e6 0c             	shl    $0xc,%esi
  801522:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801528:	83 c4 04             	add    $0x4,%esp
  80152b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80152e:	e8 d1 fd ff ff       	call   801304 <fd2data>
  801533:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801535:	89 34 24             	mov    %esi,(%esp)
  801538:	e8 c7 fd ff ff       	call   801304 <fd2data>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801542:	89 d8                	mov    %ebx,%eax
  801544:	c1 e8 16             	shr    $0x16,%eax
  801547:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80154e:	a8 01                	test   $0x1,%al
  801550:	74 11                	je     801563 <dup+0x74>
  801552:	89 d8                	mov    %ebx,%eax
  801554:	c1 e8 0c             	shr    $0xc,%eax
  801557:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80155e:	f6 c2 01             	test   $0x1,%dl
  801561:	75 39                	jne    80159c <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801563:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801566:	89 d0                	mov    %edx,%eax
  801568:	c1 e8 0c             	shr    $0xc,%eax
  80156b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	25 07 0e 00 00       	and    $0xe07,%eax
  80157a:	50                   	push   %eax
  80157b:	56                   	push   %esi
  80157c:	6a 00                	push   $0x0
  80157e:	52                   	push   %edx
  80157f:	6a 00                	push   $0x0
  801581:	e8 45 f8 ff ff       	call   800dcb <sys_page_map>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 20             	add    $0x20,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 31                	js     8015c0 <dup+0xd1>
		goto err;

	return newfdnum;
  80158f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801592:	89 d8                	mov    %ebx,%eax
  801594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80159c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ab:	50                   	push   %eax
  8015ac:	57                   	push   %edi
  8015ad:	6a 00                	push   $0x0
  8015af:	53                   	push   %ebx
  8015b0:	6a 00                	push   $0x0
  8015b2:	e8 14 f8 ff ff       	call   800dcb <sys_page_map>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	83 c4 20             	add    $0x20,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	79 a3                	jns    801563 <dup+0x74>
	sys_page_unmap(0, newfd);
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	56                   	push   %esi
  8015c4:	6a 00                	push   $0x0
  8015c6:	e8 42 f8 ff ff       	call   800e0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	57                   	push   %edi
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 37 f8 ff ff       	call   800e0d <sys_page_unmap>
	return r;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	eb b7                	jmp    801592 <dup+0xa3>

008015db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 14             	sub    $0x14,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	53                   	push   %ebx
  8015ea:	e8 7b fd ff ff       	call   80136a <fd_lookup>
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	78 3f                	js     801635 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f6:	83 ec 08             	sub    $0x8,%esp
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	ff 30                	pushl  (%eax)
  801602:	e8 b9 fd ff ff       	call   8013c0 <dev_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 27                	js     801635 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80160e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801611:	8b 42 08             	mov    0x8(%edx),%eax
  801614:	83 e0 03             	and    $0x3,%eax
  801617:	83 f8 01             	cmp    $0x1,%eax
  80161a:	74 1e                	je     80163a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80161c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161f:	8b 40 08             	mov    0x8(%eax),%eax
  801622:	85 c0                	test   %eax,%eax
  801624:	74 35                	je     80165b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	ff 75 10             	pushl  0x10(%ebp)
  80162c:	ff 75 0c             	pushl  0xc(%ebp)
  80162f:	52                   	push   %edx
  801630:	ff d0                	call   *%eax
  801632:	83 c4 10             	add    $0x10,%esp
}
  801635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801638:	c9                   	leave  
  801639:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163a:	a1 04 40 80 00       	mov    0x804004,%eax
  80163f:	8b 40 48             	mov    0x48(%eax),%eax
  801642:	83 ec 04             	sub    $0x4,%esp
  801645:	53                   	push   %ebx
  801646:	50                   	push   %eax
  801647:	68 11 29 80 00       	push   $0x802911
  80164c:	e8 1f ed ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801659:	eb da                	jmp    801635 <read+0x5a>
		return -E_NOT_SUPP;
  80165b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801660:	eb d3                	jmp    801635 <read+0x5a>

00801662 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80166e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801671:	bb 00 00 00 00       	mov    $0x0,%ebx
  801676:	39 f3                	cmp    %esi,%ebx
  801678:	73 25                	jae    80169f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80167a:	83 ec 04             	sub    $0x4,%esp
  80167d:	89 f0                	mov    %esi,%eax
  80167f:	29 d8                	sub    %ebx,%eax
  801681:	50                   	push   %eax
  801682:	89 d8                	mov    %ebx,%eax
  801684:	03 45 0c             	add    0xc(%ebp),%eax
  801687:	50                   	push   %eax
  801688:	57                   	push   %edi
  801689:	e8 4d ff ff ff       	call   8015db <read>
		if (m < 0)
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 08                	js     80169d <readn+0x3b>
			return m;
		if (m == 0)
  801695:	85 c0                	test   %eax,%eax
  801697:	74 06                	je     80169f <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801699:	01 c3                	add    %eax,%ebx
  80169b:	eb d9                	jmp    801676 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80169d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80169f:	89 d8                	mov    %ebx,%eax
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 14             	sub    $0x14,%esp
  8016b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b6:	50                   	push   %eax
  8016b7:	53                   	push   %ebx
  8016b8:	e8 ad fc ff ff       	call   80136a <fd_lookup>
  8016bd:	83 c4 08             	add    $0x8,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 3a                	js     8016fe <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	ff 30                	pushl  (%eax)
  8016d0:	e8 eb fc ff ff       	call   8013c0 <dev_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 22                	js     8016fe <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e3:	74 1e                	je     801703 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8016eb:	85 d2                	test   %edx,%edx
  8016ed:	74 35                	je     801724 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ef:	83 ec 04             	sub    $0x4,%esp
  8016f2:	ff 75 10             	pushl  0x10(%ebp)
  8016f5:	ff 75 0c             	pushl  0xc(%ebp)
  8016f8:	50                   	push   %eax
  8016f9:	ff d2                	call   *%edx
  8016fb:	83 c4 10             	add    $0x10,%esp
}
  8016fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801701:	c9                   	leave  
  801702:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801703:	a1 04 40 80 00       	mov    0x804004,%eax
  801708:	8b 40 48             	mov    0x48(%eax),%eax
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	53                   	push   %ebx
  80170f:	50                   	push   %eax
  801710:	68 2d 29 80 00       	push   $0x80292d
  801715:	e8 56 ec ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801722:	eb da                	jmp    8016fe <write+0x55>
		return -E_NOT_SUPP;
  801724:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801729:	eb d3                	jmp    8016fe <write+0x55>

0080172b <seek>:

int
seek(int fdnum, off_t offset)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801731:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	ff 75 08             	pushl  0x8(%ebp)
  801738:	e8 2d fc ff ff       	call   80136a <fd_lookup>
  80173d:	83 c4 08             	add    $0x8,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 0e                	js     801752 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801744:	8b 55 0c             	mov    0xc(%ebp),%edx
  801747:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80174a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	c9                   	leave  
  801753:	c3                   	ret    

00801754 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	83 ec 14             	sub    $0x14,%esp
  80175b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	53                   	push   %ebx
  801763:	e8 02 fc ff ff       	call   80136a <fd_lookup>
  801768:	83 c4 08             	add    $0x8,%esp
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 37                	js     8017a6 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	ff 30                	pushl  (%eax)
  80177b:	e8 40 fc ff ff       	call   8013c0 <dev_lookup>
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 1f                	js     8017a6 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80178e:	74 1b                	je     8017ab <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801790:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801793:	8b 52 18             	mov    0x18(%edx),%edx
  801796:	85 d2                	test   %edx,%edx
  801798:	74 32                	je     8017cc <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	ff 75 0c             	pushl  0xc(%ebp)
  8017a0:	50                   	push   %eax
  8017a1:	ff d2                	call   *%edx
  8017a3:	83 c4 10             	add    $0x10,%esp
}
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017ab:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b0:	8b 40 48             	mov    0x48(%eax),%eax
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	53                   	push   %ebx
  8017b7:	50                   	push   %eax
  8017b8:	68 f0 28 80 00       	push   $0x8028f0
  8017bd:	e8 ae eb ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ca:	eb da                	jmp    8017a6 <ftruncate+0x52>
		return -E_NOT_SUPP;
  8017cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d1:	eb d3                	jmp    8017a6 <ftruncate+0x52>

008017d3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	53                   	push   %ebx
  8017d7:	83 ec 14             	sub    $0x14,%esp
  8017da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e0:	50                   	push   %eax
  8017e1:	ff 75 08             	pushl  0x8(%ebp)
  8017e4:	e8 81 fb ff ff       	call   80136a <fd_lookup>
  8017e9:	83 c4 08             	add    $0x8,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 4b                	js     80183b <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f0:	83 ec 08             	sub    $0x8,%esp
  8017f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f6:	50                   	push   %eax
  8017f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fa:	ff 30                	pushl  (%eax)
  8017fc:	e8 bf fb ff ff       	call   8013c0 <dev_lookup>
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	85 c0                	test   %eax,%eax
  801806:	78 33                	js     80183b <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180f:	74 2f                	je     801840 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801811:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801814:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181b:	00 00 00 
	stat->st_isdir = 0;
  80181e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801825:	00 00 00 
	stat->st_dev = dev;
  801828:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	53                   	push   %ebx
  801832:	ff 75 f0             	pushl  -0x10(%ebp)
  801835:	ff 50 14             	call   *0x14(%eax)
  801838:	83 c4 10             	add    $0x10,%esp
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    
		return -E_NOT_SUPP;
  801840:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801845:	eb f4                	jmp    80183b <fstat+0x68>

00801847 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	6a 00                	push   $0x0
  801851:	ff 75 08             	pushl  0x8(%ebp)
  801854:	e8 e7 01 00 00       	call   801a40 <open>
  801859:	89 c3                	mov    %eax,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 1b                	js     80187d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	50                   	push   %eax
  801869:	e8 65 ff ff ff       	call   8017d3 <fstat>
  80186e:	89 c6                	mov    %eax,%esi
	close(fd);
  801870:	89 1c 24             	mov    %ebx,(%esp)
  801873:	e8 27 fc ff ff       	call   80149f <close>
	return r;
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	89 f3                	mov    %esi,%ebx
}
  80187d:	89 d8                	mov    %ebx,%eax
  80187f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801882:	5b                   	pop    %ebx
  801883:	5e                   	pop    %esi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	89 c6                	mov    %eax,%esi
  80188d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80188f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801896:	74 27                	je     8018bf <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801898:	6a 07                	push   $0x7
  80189a:	68 00 50 80 00       	push   $0x805000
  80189f:	56                   	push   %esi
  8018a0:	ff 35 00 40 80 00    	pushl  0x804000
  8018a6:	e8 b9 07 00 00       	call   802064 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018ab:	83 c4 0c             	add    $0xc,%esp
  8018ae:	6a 00                	push   $0x0
  8018b0:	53                   	push   %ebx
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 4b 07 00 00       	call   802003 <ipc_recv>
}
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	6a 01                	push   $0x1
  8018c4:	e8 e8 07 00 00       	call   8020b1 <ipc_find_env>
  8018c9:	a3 00 40 80 00       	mov    %eax,0x804000
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	eb c5                	jmp    801898 <fsipc+0x12>

008018d3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018df:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f1:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f6:	e8 8b ff ff ff       	call   801886 <fsipc>
}
  8018fb:	c9                   	leave  
  8018fc:	c3                   	ret    

008018fd <devfile_flush>:
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801903:	8b 45 08             	mov    0x8(%ebp),%eax
  801906:	8b 40 0c             	mov    0xc(%eax),%eax
  801909:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190e:	ba 00 00 00 00       	mov    $0x0,%edx
  801913:	b8 06 00 00 00       	mov    $0x6,%eax
  801918:	e8 69 ff ff ff       	call   801886 <fsipc>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <devfile_stat>:
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	53                   	push   %ebx
  801923:	83 ec 04             	sub    $0x4,%esp
  801926:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	8b 40 0c             	mov    0xc(%eax),%eax
  80192f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
  801939:	b8 05 00 00 00       	mov    $0x5,%eax
  80193e:	e8 43 ff ff ff       	call   801886 <fsipc>
  801943:	85 c0                	test   %eax,%eax
  801945:	78 2c                	js     801973 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801947:	83 ec 08             	sub    $0x8,%esp
  80194a:	68 00 50 80 00       	push   $0x805000
  80194f:	53                   	push   %ebx
  801950:	e8 3a f0 ff ff       	call   80098f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801955:	a1 80 50 80 00       	mov    0x805080,%eax
  80195a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801960:	a1 84 50 80 00       	mov    0x805084,%eax
  801965:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devfile_write>:
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801981:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801986:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80198b:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80198e:	8b 55 08             	mov    0x8(%ebp),%edx
  801991:	8b 52 0c             	mov    0xc(%edx),%edx
  801994:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80199a:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  80199f:	50                   	push   %eax
  8019a0:	ff 75 0c             	pushl  0xc(%ebp)
  8019a3:	68 08 50 80 00       	push   $0x805008
  8019a8:	e8 70 f1 ff ff       	call   800b1d <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  8019ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b7:	e8 ca fe ff ff       	call   801886 <fsipc>
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <devfile_read>:
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	56                   	push   %esi
  8019c2:	53                   	push   %ebx
  8019c3:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019d1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e1:	e8 a0 fe ff ff       	call   801886 <fsipc>
  8019e6:	89 c3                	mov    %eax,%ebx
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 1f                	js     801a0b <devfile_read+0x4d>
	assert(r <= n);
  8019ec:	39 f0                	cmp    %esi,%eax
  8019ee:	77 24                	ja     801a14 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019f0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f5:	7f 33                	jg     801a2a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019f7:	83 ec 04             	sub    $0x4,%esp
  8019fa:	50                   	push   %eax
  8019fb:	68 00 50 80 00       	push   $0x805000
  801a00:	ff 75 0c             	pushl  0xc(%ebp)
  801a03:	e8 15 f1 ff ff       	call   800b1d <memmove>
	return r;
  801a08:	83 c4 10             	add    $0x10,%esp
}
  801a0b:	89 d8                	mov    %ebx,%eax
  801a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    
	assert(r <= n);
  801a14:	68 5c 29 80 00       	push   $0x80295c
  801a19:	68 63 29 80 00       	push   $0x802963
  801a1e:	6a 7d                	push   $0x7d
  801a20:	68 78 29 80 00       	push   $0x802978
  801a25:	e8 6b e8 ff ff       	call   800295 <_panic>
	assert(r <= PGSIZE);
  801a2a:	68 83 29 80 00       	push   $0x802983
  801a2f:	68 63 29 80 00       	push   $0x802963
  801a34:	6a 7e                	push   $0x7e
  801a36:	68 78 29 80 00       	push   $0x802978
  801a3b:	e8 55 e8 ff ff       	call   800295 <_panic>

00801a40 <open>:
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 1c             	sub    $0x1c,%esp
  801a48:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a4b:	56                   	push   %esi
  801a4c:	e8 07 ef ff ff       	call   800958 <strlen>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a59:	0f 8f 96 00 00 00    	jg     801af5 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	e8 b0 f8 ff ff       	call   80131b <fd_alloc>
  801a6b:	89 c3                	mov    %eax,%ebx
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 66                	js     801ada <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801a74:	83 ec 08             	sub    $0x8,%esp
  801a77:	56                   	push   %esi
  801a78:	68 00 50 80 00       	push   $0x805000
  801a7d:	e8 0d ef ff ff       	call   80098f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a85:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a92:	e8 ef fd ff ff       	call   801886 <fsipc>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	83 c4 10             	add    $0x10,%esp
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 43                	js     801ae3 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa6:	e8 49 f8 ff ff       	call   8012f4 <fd2num>
  801aab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aae:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801ab4:	8b 49 48             	mov    0x48(%ecx),%ecx
  801ab7:	83 c4 08             	add    $0x8,%esp
  801aba:	50                   	push   %eax
  801abb:	52                   	push   %edx
  801abc:	ff 32                	pushl  (%edx)
  801abe:	56                   	push   %esi
  801abf:	51                   	push   %ecx
  801ac0:	68 90 29 80 00       	push   $0x802990
  801ac5:	e8 a6 e8 ff ff       	call   800370 <cprintf>
	return fd2num(fd);
  801aca:	83 c4 14             	add    $0x14,%esp
  801acd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad0:	e8 1f f8 ff ff       	call   8012f4 <fd2num>
  801ad5:	89 c3                	mov    %eax,%ebx
  801ad7:	83 c4 10             	add    $0x10,%esp
}
  801ada:	89 d8                	mov    %ebx,%eax
  801adc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    
		fd_close(fd, 0);
  801ae3:	83 ec 08             	sub    $0x8,%esp
  801ae6:	6a 00                	push   $0x0
  801ae8:	ff 75 f4             	pushl  -0xc(%ebp)
  801aeb:	e8 26 f9 ff ff       	call   801416 <fd_close>
		return r;
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	eb e5                	jmp    801ada <open+0x9a>
		return -E_BAD_PATH;
  801af5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801afa:	eb de                	jmp    801ada <open+0x9a>

00801afc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b02:	ba 00 00 00 00       	mov    $0x0,%edx
  801b07:	b8 08 00 00 00       	mov    $0x8,%eax
  801b0c:	e8 75 fd ff ff       	call   801886 <fsipc>
}
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b1b:	83 ec 0c             	sub    $0xc,%esp
  801b1e:	ff 75 08             	pushl  0x8(%ebp)
  801b21:	e8 de f7 ff ff       	call   801304 <fd2data>
  801b26:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b28:	83 c4 08             	add    $0x8,%esp
  801b2b:	68 d0 29 80 00       	push   $0x8029d0
  801b30:	53                   	push   %ebx
  801b31:	e8 59 ee ff ff       	call   80098f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b36:	8b 46 04             	mov    0x4(%esi),%eax
  801b39:	2b 06                	sub    (%esi),%eax
  801b3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b41:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b48:	00 00 00 
	stat->st_dev = &devpipe;
  801b4b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b52:	30 80 00 
	return 0;
}
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5d                   	pop    %ebp
  801b60:	c3                   	ret    

00801b61 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	53                   	push   %ebx
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b6b:	53                   	push   %ebx
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 9a f2 ff ff       	call   800e0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b73:	89 1c 24             	mov    %ebx,(%esp)
  801b76:	e8 89 f7 ff ff       	call   801304 <fd2data>
  801b7b:	83 c4 08             	add    $0x8,%esp
  801b7e:	50                   	push   %eax
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 87 f2 ff ff       	call   800e0d <sys_page_unmap>
}
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <_pipeisclosed>:
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 1c             	sub    $0x1c,%esp
  801b94:	89 c7                	mov    %eax,%edi
  801b96:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b98:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	57                   	push   %edi
  801ba4:	e8 41 05 00 00       	call   8020ea <pageref>
  801ba9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bac:	89 34 24             	mov    %esi,(%esp)
  801baf:	e8 36 05 00 00       	call   8020ea <pageref>
		nn = thisenv->env_runs;
  801bb4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801bba:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	39 cb                	cmp    %ecx,%ebx
  801bc2:	74 1b                	je     801bdf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bc4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bc7:	75 cf                	jne    801b98 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bc9:	8b 42 58             	mov    0x58(%edx),%eax
  801bcc:	6a 01                	push   $0x1
  801bce:	50                   	push   %eax
  801bcf:	53                   	push   %ebx
  801bd0:	68 d7 29 80 00       	push   $0x8029d7
  801bd5:	e8 96 e7 ff ff       	call   800370 <cprintf>
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	eb b9                	jmp    801b98 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bdf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801be2:	0f 94 c0             	sete   %al
  801be5:	0f b6 c0             	movzbl %al,%eax
}
  801be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <devpipe_write>:
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	57                   	push   %edi
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	83 ec 28             	sub    $0x28,%esp
  801bf9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bfc:	56                   	push   %esi
  801bfd:	e8 02 f7 ff ff       	call   801304 <fd2data>
  801c02:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	bf 00 00 00 00       	mov    $0x0,%edi
  801c0c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c0f:	74 4f                	je     801c60 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c11:	8b 43 04             	mov    0x4(%ebx),%eax
  801c14:	8b 0b                	mov    (%ebx),%ecx
  801c16:	8d 51 20             	lea    0x20(%ecx),%edx
  801c19:	39 d0                	cmp    %edx,%eax
  801c1b:	72 14                	jb     801c31 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c1d:	89 da                	mov    %ebx,%edx
  801c1f:	89 f0                	mov    %esi,%eax
  801c21:	e8 65 ff ff ff       	call   801b8b <_pipeisclosed>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	75 3a                	jne    801c64 <devpipe_write+0x74>
			sys_yield();
  801c2a:	e8 3a f1 ff ff       	call   800d69 <sys_yield>
  801c2f:	eb e0                	jmp    801c11 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c34:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c38:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c3b:	89 c2                	mov    %eax,%edx
  801c3d:	c1 fa 1f             	sar    $0x1f,%edx
  801c40:	89 d1                	mov    %edx,%ecx
  801c42:	c1 e9 1b             	shr    $0x1b,%ecx
  801c45:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c48:	83 e2 1f             	and    $0x1f,%edx
  801c4b:	29 ca                	sub    %ecx,%edx
  801c4d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c51:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c55:	83 c0 01             	add    $0x1,%eax
  801c58:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c5b:	83 c7 01             	add    $0x1,%edi
  801c5e:	eb ac                	jmp    801c0c <devpipe_write+0x1c>
	return i;
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	eb 05                	jmp    801c69 <devpipe_write+0x79>
				return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5f                   	pop    %edi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <devpipe_read>:
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	57                   	push   %edi
  801c75:	56                   	push   %esi
  801c76:	53                   	push   %ebx
  801c77:	83 ec 18             	sub    $0x18,%esp
  801c7a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c7d:	57                   	push   %edi
  801c7e:	e8 81 f6 ff ff       	call   801304 <fd2data>
  801c83:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	be 00 00 00 00       	mov    $0x0,%esi
  801c8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c90:	74 47                	je     801cd9 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c92:	8b 03                	mov    (%ebx),%eax
  801c94:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c97:	75 22                	jne    801cbb <devpipe_read+0x4a>
			if (i > 0)
  801c99:	85 f6                	test   %esi,%esi
  801c9b:	75 14                	jne    801cb1 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c9d:	89 da                	mov    %ebx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	e8 e5 fe ff ff       	call   801b8b <_pipeisclosed>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	75 33                	jne    801cdd <devpipe_read+0x6c>
			sys_yield();
  801caa:	e8 ba f0 ff ff       	call   800d69 <sys_yield>
  801caf:	eb e1                	jmp    801c92 <devpipe_read+0x21>
				return i;
  801cb1:	89 f0                	mov    %esi,%eax
}
  801cb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb6:	5b                   	pop    %ebx
  801cb7:	5e                   	pop    %esi
  801cb8:	5f                   	pop    %edi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cbb:	99                   	cltd   
  801cbc:	c1 ea 1b             	shr    $0x1b,%edx
  801cbf:	01 d0                	add    %edx,%eax
  801cc1:	83 e0 1f             	and    $0x1f,%eax
  801cc4:	29 d0                	sub    %edx,%eax
  801cc6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cce:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cd1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cd4:	83 c6 01             	add    $0x1,%esi
  801cd7:	eb b4                	jmp    801c8d <devpipe_read+0x1c>
	return i;
  801cd9:	89 f0                	mov    %esi,%eax
  801cdb:	eb d6                	jmp    801cb3 <devpipe_read+0x42>
				return 0;
  801cdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce2:	eb cf                	jmp    801cb3 <devpipe_read+0x42>

00801ce4 <pipe>:
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cef:	50                   	push   %eax
  801cf0:	e8 26 f6 ff ff       	call   80131b <fd_alloc>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 5b                	js     801d59 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	68 07 04 00 00       	push   $0x407
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 78 f0 ff ff       	call   800d88 <sys_page_alloc>
  801d10:	89 c3                	mov    %eax,%ebx
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 40                	js     801d59 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1f:	50                   	push   %eax
  801d20:	e8 f6 f5 ff ff       	call   80131b <fd_alloc>
  801d25:	89 c3                	mov    %eax,%ebx
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 1b                	js     801d49 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2e:	83 ec 04             	sub    $0x4,%esp
  801d31:	68 07 04 00 00       	push   $0x407
  801d36:	ff 75 f0             	pushl  -0x10(%ebp)
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 48 f0 ff ff       	call   800d88 <sys_page_alloc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 c0                	test   %eax,%eax
  801d47:	79 19                	jns    801d62 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d49:	83 ec 08             	sub    $0x8,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 b7 f0 ff ff       	call   800e0d <sys_page_unmap>
  801d56:	83 c4 10             	add    $0x10,%esp
}
  801d59:	89 d8                	mov    %ebx,%eax
  801d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
	va = fd2data(fd0);
  801d62:	83 ec 0c             	sub    $0xc,%esp
  801d65:	ff 75 f4             	pushl  -0xc(%ebp)
  801d68:	e8 97 f5 ff ff       	call   801304 <fd2data>
  801d6d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6f:	83 c4 0c             	add    $0xc,%esp
  801d72:	68 07 04 00 00       	push   $0x407
  801d77:	50                   	push   %eax
  801d78:	6a 00                	push   $0x0
  801d7a:	e8 09 f0 ff ff       	call   800d88 <sys_page_alloc>
  801d7f:	89 c3                	mov    %eax,%ebx
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	0f 88 8c 00 00 00    	js     801e18 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8c:	83 ec 0c             	sub    $0xc,%esp
  801d8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d92:	e8 6d f5 ff ff       	call   801304 <fd2data>
  801d97:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d9e:	50                   	push   %eax
  801d9f:	6a 00                	push   $0x0
  801da1:	56                   	push   %esi
  801da2:	6a 00                	push   $0x0
  801da4:	e8 22 f0 ff ff       	call   800dcb <sys_page_map>
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	83 c4 20             	add    $0x20,%esp
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 58                	js     801e0a <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dbb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801dc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dd5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ddc:	83 ec 0c             	sub    $0xc,%esp
  801ddf:	ff 75 f4             	pushl  -0xc(%ebp)
  801de2:	e8 0d f5 ff ff       	call   8012f4 <fd2num>
  801de7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dea:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dec:	83 c4 04             	add    $0x4,%esp
  801def:	ff 75 f0             	pushl  -0x10(%ebp)
  801df2:	e8 fd f4 ff ff       	call   8012f4 <fd2num>
  801df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfa:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e05:	e9 4f ff ff ff       	jmp    801d59 <pipe+0x75>
	sys_page_unmap(0, va);
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	56                   	push   %esi
  801e0e:	6a 00                	push   $0x0
  801e10:	e8 f8 ef ff ff       	call   800e0d <sys_page_unmap>
  801e15:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 e8 ef ff ff       	call   800e0d <sys_page_unmap>
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	e9 1c ff ff ff       	jmp    801d49 <pipe+0x65>

00801e2d <pipeisclosed>:
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	ff 75 08             	pushl  0x8(%ebp)
  801e3a:	e8 2b f5 ff ff       	call   80136a <fd_lookup>
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 18                	js     801e5e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4c:	e8 b3 f4 ff ff       	call   801304 <fd2data>
	return _pipeisclosed(fd, p);
  801e51:	89 c2                	mov    %eax,%edx
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	e8 30 fd ff ff       	call   801b8b <_pipeisclosed>
  801e5b:	83 c4 10             	add    $0x10,%esp
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e70:	68 ea 29 80 00       	push   $0x8029ea
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	e8 12 eb ff ff       	call   80098f <strcpy>
	return 0;
}
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devcons_write>:
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	57                   	push   %edi
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e90:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e9b:	eb 2f                	jmp    801ecc <devcons_write+0x48>
		m = n - tot;
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ea0:	29 f3                	sub    %esi,%ebx
  801ea2:	83 fb 7f             	cmp    $0x7f,%ebx
  801ea5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eaa:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	53                   	push   %ebx
  801eb1:	89 f0                	mov    %esi,%eax
  801eb3:	03 45 0c             	add    0xc(%ebp),%eax
  801eb6:	50                   	push   %eax
  801eb7:	57                   	push   %edi
  801eb8:	e8 60 ec ff ff       	call   800b1d <memmove>
		sys_cputs(buf, m);
  801ebd:	83 c4 08             	add    $0x8,%esp
  801ec0:	53                   	push   %ebx
  801ec1:	57                   	push   %edi
  801ec2:	e8 05 ee ff ff       	call   800ccc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ec7:	01 de                	add    %ebx,%esi
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ecf:	72 cc                	jb     801e9d <devcons_write+0x19>
}
  801ed1:	89 f0                	mov    %esi,%eax
  801ed3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <devcons_read>:
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 08             	sub    $0x8,%esp
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ee6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eea:	75 07                	jne    801ef3 <devcons_read+0x18>
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    
		sys_yield();
  801eee:	e8 76 ee ff ff       	call   800d69 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801ef3:	e8 f2 ed ff ff       	call   800cea <sys_cgetc>
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	74 f2                	je     801eee <devcons_read+0x13>
	if (c < 0)
  801efc:	85 c0                	test   %eax,%eax
  801efe:	78 ec                	js     801eec <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f00:	83 f8 04             	cmp    $0x4,%eax
  801f03:	74 0c                	je     801f11 <devcons_read+0x36>
	*(char*)vbuf = c;
  801f05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f08:	88 02                	mov    %al,(%edx)
	return 1;
  801f0a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0f:	eb db                	jmp    801eec <devcons_read+0x11>
		return 0;
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
  801f16:	eb d4                	jmp    801eec <devcons_read+0x11>

00801f18 <cputchar>:
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f21:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f24:	6a 01                	push   $0x1
  801f26:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f29:	50                   	push   %eax
  801f2a:	e8 9d ed ff ff       	call   800ccc <sys_cputs>
}
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    

00801f34 <getchar>:
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f3a:	6a 01                	push   $0x1
  801f3c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3f:	50                   	push   %eax
  801f40:	6a 00                	push   $0x0
  801f42:	e8 94 f6 ff ff       	call   8015db <read>
	if (r < 0)
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 08                	js     801f56 <getchar+0x22>
	if (r < 1)
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	7e 06                	jle    801f58 <getchar+0x24>
	return c;
  801f52:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    
		return -E_EOF;
  801f58:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f5d:	eb f7                	jmp    801f56 <getchar+0x22>

00801f5f <iscons>:
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f68:	50                   	push   %eax
  801f69:	ff 75 08             	pushl  0x8(%ebp)
  801f6c:	e8 f9 f3 ff ff       	call   80136a <fd_lookup>
  801f71:	83 c4 10             	add    $0x10,%esp
  801f74:	85 c0                	test   %eax,%eax
  801f76:	78 11                	js     801f89 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f81:	39 10                	cmp    %edx,(%eax)
  801f83:	0f 94 c0             	sete   %al
  801f86:	0f b6 c0             	movzbl %al,%eax
}
  801f89:	c9                   	leave  
  801f8a:	c3                   	ret    

00801f8b <opencons>:
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	e8 81 f3 ff ff       	call   80131b <fd_alloc>
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 3a                	js     801fdb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa1:	83 ec 04             	sub    $0x4,%esp
  801fa4:	68 07 04 00 00       	push   $0x407
  801fa9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fac:	6a 00                	push   $0x0
  801fae:	e8 d5 ed ff ff       	call   800d88 <sys_page_alloc>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	78 21                	js     801fdb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fcf:	83 ec 0c             	sub    $0xc,%esp
  801fd2:	50                   	push   %eax
  801fd3:	e8 1c f3 ff ff       	call   8012f4 <fd2num>
  801fd8:	83 c4 10             	add    $0x10,%esp
}
  801fdb:	c9                   	leave  
  801fdc:	c3                   	ret    

00801fdd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fdd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fde:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801fe3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe5:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  801fe8:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  801feb:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  801fef:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  801ff3:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  801ff6:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  801ffa:	89 18                	mov    %ebx,(%eax)

    popal
  801ffc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  801ffd:	83 c4 04             	add    $0x4,%esp
    popfl
  802000:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  802001:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  802002:	c3                   	ret    

00802003 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	8b 75 08             	mov    0x8(%ebp),%esi
  80200b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  802011:	85 c0                	test   %eax,%eax
  802013:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802018:	0f 44 c2             	cmove  %edx,%eax
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	50                   	push   %eax
  80201f:	e8 14 ef ff ff       	call   800f38 <sys_ipc_recv>
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 c0                	test   %eax,%eax
  802029:	78 2b                	js     802056 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  80202b:	85 f6                	test   %esi,%esi
  80202d:	74 0a                	je     802039 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  80202f:	a1 04 40 80 00       	mov    0x804004,%eax
  802034:	8b 40 74             	mov    0x74(%eax),%eax
  802037:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  802039:	85 db                	test   %ebx,%ebx
  80203b:	74 0a                	je     802047 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  80203d:	a1 04 40 80 00       	mov    0x804004,%eax
  802042:	8b 40 78             	mov    0x78(%eax),%eax
  802045:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  802047:	a1 04 40 80 00       	mov    0x804004,%eax
  80204c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80204f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802052:	5b                   	pop    %ebx
  802053:	5e                   	pop    %esi
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    
        *from_env_store = 0;
  802056:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  80205c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802062:	eb eb                	jmp    80204f <ipc_recv+0x4c>

00802064 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	57                   	push   %edi
  802068:	56                   	push   %esi
  802069:	53                   	push   %ebx
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802070:	8b 75 0c             	mov    0xc(%ebp),%esi
  802073:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  802076:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  802078:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80207d:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802080:	ff 75 14             	pushl  0x14(%ebp)
  802083:	53                   	push   %ebx
  802084:	56                   	push   %esi
  802085:	57                   	push   %edi
  802086:	e8 8a ee ff ff       	call   800f15 <sys_ipc_try_send>
  80208b:	83 c4 10             	add    $0x10,%esp
  80208e:	85 c0                	test   %eax,%eax
  802090:	74 17                	je     8020a9 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802092:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802095:	74 e9                	je     802080 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  802097:	50                   	push   %eax
  802098:	68 f6 29 80 00       	push   $0x8029f6
  80209d:	6a 3e                	push   $0x3e
  80209f:	68 08 2a 80 00       	push   $0x802a08
  8020a4:	e8 ec e1 ff ff       	call   800295 <_panic>
        }
    }
}
  8020a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ac:	5b                   	pop    %ebx
  8020ad:	5e                   	pop    %esi
  8020ae:	5f                   	pop    %edi
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    

008020b1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020bc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020bf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c5:	8b 52 50             	mov    0x50(%edx),%edx
  8020c8:	39 ca                	cmp    %ecx,%edx
  8020ca:	74 11                	je     8020dd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020cc:	83 c0 01             	add    $0x1,%eax
  8020cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d4:	75 e6                	jne    8020bc <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020db:	eb 0b                	jmp    8020e8 <ipc_find_env+0x37>
			return envs[i].env_id;
  8020dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020e5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    

008020ea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f0:	89 d0                	mov    %edx,%eax
  8020f2:	c1 e8 16             	shr    $0x16,%eax
  8020f5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020fc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802101:	f6 c1 01             	test   $0x1,%cl
  802104:	74 1d                	je     802123 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802106:	c1 ea 0c             	shr    $0xc,%edx
  802109:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802110:	f6 c2 01             	test   $0x1,%dl
  802113:	74 0e                	je     802123 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802115:	c1 ea 0c             	shr    $0xc,%edx
  802118:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80211f:	ef 
  802120:	0f b7 c0             	movzwl %ax,%eax
}
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	66 90                	xchg   %ax,%ax
  802127:	66 90                	xchg   %ax,%ax
  802129:	66 90                	xchg   %ax,%ax
  80212b:	66 90                	xchg   %ax,%ax
  80212d:	66 90                	xchg   %ax,%ax
  80212f:	90                   	nop

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80213b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80213f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802143:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802147:	85 d2                	test   %edx,%edx
  802149:	75 35                	jne    802180 <__udivdi3+0x50>
  80214b:	39 f3                	cmp    %esi,%ebx
  80214d:	0f 87 bd 00 00 00    	ja     802210 <__udivdi3+0xe0>
  802153:	85 db                	test   %ebx,%ebx
  802155:	89 d9                	mov    %ebx,%ecx
  802157:	75 0b                	jne    802164 <__udivdi3+0x34>
  802159:	b8 01 00 00 00       	mov    $0x1,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f3                	div    %ebx
  802162:	89 c1                	mov    %eax,%ecx
  802164:	31 d2                	xor    %edx,%edx
  802166:	89 f0                	mov    %esi,%eax
  802168:	f7 f1                	div    %ecx
  80216a:	89 c6                	mov    %eax,%esi
  80216c:	89 e8                	mov    %ebp,%eax
  80216e:	89 f7                	mov    %esi,%edi
  802170:	f7 f1                	div    %ecx
  802172:	89 fa                	mov    %edi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 f2                	cmp    %esi,%edx
  802182:	77 7c                	ja     802200 <__udivdi3+0xd0>
  802184:	0f bd fa             	bsr    %edx,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0xf8>
  802190:	89 f9                	mov    %edi,%ecx
  802192:	b8 20 00 00 00       	mov    $0x20,%eax
  802197:	29 f8                	sub    %edi,%eax
  802199:	d3 e2                	shl    %cl,%edx
  80219b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 da                	mov    %ebx,%edx
  8021a3:	d3 ea                	shr    %cl,%edx
  8021a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021a9:	09 d1                	or     %edx,%ecx
  8021ab:	89 f2                	mov    %esi,%edx
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e3                	shl    %cl,%ebx
  8021b5:	89 c1                	mov    %eax,%ecx
  8021b7:	d3 ea                	shr    %cl,%edx
  8021b9:	89 f9                	mov    %edi,%ecx
  8021bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021bf:	d3 e6                	shl    %cl,%esi
  8021c1:	89 eb                	mov    %ebp,%ebx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	d3 eb                	shr    %cl,%ebx
  8021c7:	09 de                	or     %ebx,%esi
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	f7 74 24 08          	divl   0x8(%esp)
  8021cf:	89 d6                	mov    %edx,%esi
  8021d1:	89 c3                	mov    %eax,%ebx
  8021d3:	f7 64 24 0c          	mull   0xc(%esp)
  8021d7:	39 d6                	cmp    %edx,%esi
  8021d9:	72 0c                	jb     8021e7 <__udivdi3+0xb7>
  8021db:	89 f9                	mov    %edi,%ecx
  8021dd:	d3 e5                	shl    %cl,%ebp
  8021df:	39 c5                	cmp    %eax,%ebp
  8021e1:	73 5d                	jae    802240 <__udivdi3+0x110>
  8021e3:	39 d6                	cmp    %edx,%esi
  8021e5:	75 59                	jne    802240 <__udivdi3+0x110>
  8021e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ea:	31 ff                	xor    %edi,%edi
  8021ec:	89 fa                	mov    %edi,%edx
  8021ee:	83 c4 1c             	add    $0x1c,%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5f                   	pop    %edi
  8021f4:	5d                   	pop    %ebp
  8021f5:	c3                   	ret    
  8021f6:	8d 76 00             	lea    0x0(%esi),%esi
  8021f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802200:	31 ff                	xor    %edi,%edi
  802202:	31 c0                	xor    %eax,%eax
  802204:	89 fa                	mov    %edi,%edx
  802206:	83 c4 1c             	add    $0x1c,%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    
  80220e:	66 90                	xchg   %ax,%ax
  802210:	31 ff                	xor    %edi,%edi
  802212:	89 e8                	mov    %ebp,%eax
  802214:	89 f2                	mov    %esi,%edx
  802216:	f7 f3                	div    %ebx
  802218:	89 fa                	mov    %edi,%edx
  80221a:	83 c4 1c             	add    $0x1c,%esp
  80221d:	5b                   	pop    %ebx
  80221e:	5e                   	pop    %esi
  80221f:	5f                   	pop    %edi
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
  802222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	72 06                	jb     802232 <__udivdi3+0x102>
  80222c:	31 c0                	xor    %eax,%eax
  80222e:	39 eb                	cmp    %ebp,%ebx
  802230:	77 d2                	ja     802204 <__udivdi3+0xd4>
  802232:	b8 01 00 00 00       	mov    $0x1,%eax
  802237:	eb cb                	jmp    802204 <__udivdi3+0xd4>
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 d8                	mov    %ebx,%eax
  802242:	31 ff                	xor    %edi,%edi
  802244:	eb be                	jmp    802204 <__udivdi3+0xd4>
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80225b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80225f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 ed                	test   %ebp,%ebp
  802269:	89 f0                	mov    %esi,%eax
  80226b:	89 da                	mov    %ebx,%edx
  80226d:	75 19                	jne    802288 <__umoddi3+0x38>
  80226f:	39 df                	cmp    %ebx,%edi
  802271:	0f 86 b1 00 00 00    	jbe    802328 <__umoddi3+0xd8>
  802277:	f7 f7                	div    %edi
  802279:	89 d0                	mov    %edx,%eax
  80227b:	31 d2                	xor    %edx,%edx
  80227d:	83 c4 1c             	add    $0x1c,%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    
  802285:	8d 76 00             	lea    0x0(%esi),%esi
  802288:	39 dd                	cmp    %ebx,%ebp
  80228a:	77 f1                	ja     80227d <__umoddi3+0x2d>
  80228c:	0f bd cd             	bsr    %ebp,%ecx
  80228f:	83 f1 1f             	xor    $0x1f,%ecx
  802292:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802296:	0f 84 b4 00 00 00    	je     802350 <__umoddi3+0x100>
  80229c:	b8 20 00 00 00       	mov    $0x20,%eax
  8022a1:	89 c2                	mov    %eax,%edx
  8022a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022a7:	29 c2                	sub    %eax,%edx
  8022a9:	89 c1                	mov    %eax,%ecx
  8022ab:	89 f8                	mov    %edi,%eax
  8022ad:	d3 e5                	shl    %cl,%ebp
  8022af:	89 d1                	mov    %edx,%ecx
  8022b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022b5:	d3 e8                	shr    %cl,%eax
  8022b7:	09 c5                	or     %eax,%ebp
  8022b9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022bd:	89 c1                	mov    %eax,%ecx
  8022bf:	d3 e7                	shl    %cl,%edi
  8022c1:	89 d1                	mov    %edx,%ecx
  8022c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8022c7:	89 df                	mov    %ebx,%edi
  8022c9:	d3 ef                	shr    %cl,%edi
  8022cb:	89 c1                	mov    %eax,%ecx
  8022cd:	89 f0                	mov    %esi,%eax
  8022cf:	d3 e3                	shl    %cl,%ebx
  8022d1:	89 d1                	mov    %edx,%ecx
  8022d3:	89 fa                	mov    %edi,%edx
  8022d5:	d3 e8                	shr    %cl,%eax
  8022d7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022dc:	09 d8                	or     %ebx,%eax
  8022de:	f7 f5                	div    %ebp
  8022e0:	d3 e6                	shl    %cl,%esi
  8022e2:	89 d1                	mov    %edx,%ecx
  8022e4:	f7 64 24 08          	mull   0x8(%esp)
  8022e8:	39 d1                	cmp    %edx,%ecx
  8022ea:	89 c3                	mov    %eax,%ebx
  8022ec:	89 d7                	mov    %edx,%edi
  8022ee:	72 06                	jb     8022f6 <__umoddi3+0xa6>
  8022f0:	75 0e                	jne    802300 <__umoddi3+0xb0>
  8022f2:	39 c6                	cmp    %eax,%esi
  8022f4:	73 0a                	jae    802300 <__umoddi3+0xb0>
  8022f6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022fa:	19 ea                	sbb    %ebp,%edx
  8022fc:	89 d7                	mov    %edx,%edi
  8022fe:	89 c3                	mov    %eax,%ebx
  802300:	89 ca                	mov    %ecx,%edx
  802302:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802307:	29 de                	sub    %ebx,%esi
  802309:	19 fa                	sbb    %edi,%edx
  80230b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80230f:	89 d0                	mov    %edx,%eax
  802311:	d3 e0                	shl    %cl,%eax
  802313:	89 d9                	mov    %ebx,%ecx
  802315:	d3 ee                	shr    %cl,%esi
  802317:	d3 ea                	shr    %cl,%edx
  802319:	09 f0                	or     %esi,%eax
  80231b:	83 c4 1c             	add    $0x1c,%esp
  80231e:	5b                   	pop    %ebx
  80231f:	5e                   	pop    %esi
  802320:	5f                   	pop    %edi
  802321:	5d                   	pop    %ebp
  802322:	c3                   	ret    
  802323:	90                   	nop
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	85 ff                	test   %edi,%edi
  80232a:	89 f9                	mov    %edi,%ecx
  80232c:	75 0b                	jne    802339 <__umoddi3+0xe9>
  80232e:	b8 01 00 00 00       	mov    $0x1,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f7                	div    %edi
  802337:	89 c1                	mov    %eax,%ecx
  802339:	89 d8                	mov    %ebx,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f1                	div    %ecx
  80233f:	89 f0                	mov    %esi,%eax
  802341:	f7 f1                	div    %ecx
  802343:	e9 31 ff ff ff       	jmp    802279 <__umoddi3+0x29>
  802348:	90                   	nop
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	39 dd                	cmp    %ebx,%ebp
  802352:	72 08                	jb     80235c <__umoddi3+0x10c>
  802354:	39 f7                	cmp    %esi,%edi
  802356:	0f 87 21 ff ff ff    	ja     80227d <__umoddi3+0x2d>
  80235c:	89 da                	mov    %ebx,%edx
  80235e:	89 f0                	mov    %esi,%eax
  802360:	29 f8                	sub    %edi,%eax
  802362:	19 ea                	sbb    %ebp,%edx
  802364:	e9 14 ff ff ff       	jmp    80227d <__umoddi3+0x2d>
