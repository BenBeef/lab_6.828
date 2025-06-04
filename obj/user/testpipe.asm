
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 60 	movl   $0x802460,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 37 1d 00 00       	call   801d85 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1f 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 c0 11 00 00       	call   801220 <fork>
  800060:	89 c3                	mov    %eax,%ebx
  800062:	85 c0                	test   %eax,%eax
  800064:	0f 88 22 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006a:	85 c0                	test   %eax,%eax
  80006c:	0f 85 58 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800072:	a1 04 40 80 00       	mov    0x804004,%eax
  800077:	8b 40 48             	mov    0x48(%eax),%eax
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	ff 75 90             	pushl  -0x70(%ebp)
  800080:	50                   	push   %eax
  800081:	68 8e 24 80 00       	push   $0x80248e
  800086:	e8 86 03 00 00       	call   800411 <cprintf>
		close(p[1]);
  80008b:	83 c4 04             	add    $0x4,%esp
  80008e:	ff 75 90             	pushl  -0x70(%ebp)
  800091:	e8 aa 14 00 00       	call   801540 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800096:	a1 04 40 80 00       	mov    0x804004,%eax
  80009b:	8b 40 48             	mov    0x48(%eax),%eax
  80009e:	83 c4 0c             	add    $0xc,%esp
  8000a1:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a4:	50                   	push   %eax
  8000a5:	68 ab 24 80 00       	push   $0x8024ab
  8000aa:	e8 62 03 00 00       	call   800411 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 63                	push   $0x63
  8000b4:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bb:	e8 43 16 00 00       	call   801703 <readn>
  8000c0:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	0f 88 d1 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cd:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	ff 35 00 30 80 00    	pushl  0x803000
  8000db:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000de:	50                   	push   %eax
  8000df:	e8 f2 09 00 00       	call   800ad6 <strcmp>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	0f 85 c1 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 d1 24 80 00       	push   $0x8024d1
  8000f7:	e8 15 03 00 00       	call   800411 <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  8000ff:	e8 18 02 00 00       	call   80031c <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	53                   	push   %ebx
  800108:	e8 f4 1d 00 00       	call   801f01 <wait>

	binaryname = "pipewriteeof";
  80010d:	c7 05 04 30 80 00 27 	movl   $0x802527,0x803004
  800114:	25 80 00 
	if ((i = pipe(p)) < 0)
  800117:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 63 1c 00 00       	call   801d85 <pipe>
  800122:	89 c6                	mov    %eax,%esi
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	85 c0                	test   %eax,%eax
  800129:	0f 88 34 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012f:	e8 ec 10 00 00       	call   801220 <fork>
  800134:	89 c3                	mov    %eax,%ebx
  800136:	85 c0                	test   %eax,%eax
  800138:	0f 88 37 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  80013e:	85 c0                	test   %eax,%eax
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 ef 13 00 00       	call   801540 <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 e4 13 00 00       	call   801540 <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 9d 1d 00 00       	call   801f01 <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 55 25 80 00 	movl   $0x802555,(%esp)
  80016b:	e8 a1 02 00 00       	call   800411 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 6c 24 80 00       	push   $0x80246c
  800180:	6a 0e                	push   $0xe
  800182:	68 75 24 80 00       	push   $0x802475
  800187:	e8 aa 01 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 85 24 80 00       	push   $0x802485
  800192:	6a 11                	push   $0x11
  800194:	68 75 24 80 00       	push   $0x802475
  800199:	e8 98 01 00 00       	call   800336 <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 c8 24 80 00       	push   $0x8024c8
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 75 24 80 00       	push   $0x802475
  8001ab:	e8 86 01 00 00       	call   800336 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 ed 24 80 00       	push   $0x8024ed
  8001bd:	e8 4f 02 00 00       	call   800411 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 35 ff ff ff       	jmp    8000ff <umain+0xcc>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 8e 24 80 00       	push   $0x80248e
  8001de:	e8 2e 02 00 00       	call   800411 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 52 13 00 00       	call   801540 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 00 25 80 00       	push   $0x802500
  800202:	e8 0a 02 00 00       	call   800411 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 30 80 00    	pushl  0x803000
  800210:	e8 e4 07 00 00       	call   8009f9 <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 30 80 00    	pushl  0x803000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 23 15 00 00       	call   80174a <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 30 80 00    	pushl  0x803000
  800232:	e8 c2 07 00 00       	call   8009f9 <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 f7 12 00 00       	call   801540 <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b3 fe ff ff       	jmp    800104 <umain+0xd1>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 1d 25 80 00       	push   $0x80251d
  800257:	6a 25                	push   $0x25
  800259:	68 75 24 80 00       	push   $0x802475
  80025e:	e8 d3 00 00 00       	call   800336 <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 6c 24 80 00       	push   $0x80246c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 75 24 80 00       	push   $0x802475
  800270:	e8 c1 00 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 85 24 80 00       	push   $0x802485
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 75 24 80 00       	push   $0x802475
  800282:	e8 af 00 00 00       	call   800336 <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 ae 12 00 00       	call   801540 <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 34 25 80 00       	push   $0x802534
  80029d:	e8 6f 01 00 00       	call   800411 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 36 25 80 00       	push   $0x802536
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 96 14 00 00       	call   80174a <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 38 25 80 00       	push   $0x802538
  8002c4:	e8 48 01 00 00       	call   800411 <cprintf>
		exit();
  8002c9:	e8 4e 00 00 00       	call   80031c <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8002e1:	e8 05 0b 00 00       	call   800deb <sys_getenvid>
  8002e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7e 07                	jle    800303 <libmain+0x2d>
		binaryname = argv[0];
  8002fc:	8b 06                	mov    (%esi),%eax
  8002fe:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	e8 26 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800322:	e8 44 12 00 00       	call   80156b <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 79 0a 00 00       	call   800daa <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800344:	e8 a2 0a 00 00       	call   800deb <sys_getenvid>
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	56                   	push   %esi
  800353:	50                   	push   %eax
  800354:	68 b8 25 80 00       	push   $0x8025b8
  800359:	e8 b3 00 00 00       	call   800411 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035e:	83 c4 18             	add    $0x18,%esp
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	e8 56 00 00 00       	call   8003c0 <vcprintf>
	cprintf("\n");
  80036a:	c7 04 24 a9 24 80 00 	movl   $0x8024a9,(%esp)
  800371:	e8 9b 00 00 00       	call   800411 <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800379:	cc                   	int3   
  80037a:	eb fd                	jmp    800379 <_panic+0x43>

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	74 09                	je     8003a4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	68 ff 00 00 00       	push   $0xff
  8003ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8003af:	50                   	push   %eax
  8003b0:	e8 b8 09 00 00       	call   800d6d <sys_cputs>
		b->idx = 0;
  8003b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bb:	83 c4 10             	add    $0x10,%esp
  8003be:	eb db                	jmp    80039b <putch+0x1f>

008003c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d0:	00 00 00 
	b.cnt = 0;
  8003d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dd:	ff 75 0c             	pushl  0xc(%ebp)
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e9:	50                   	push   %eax
  8003ea:	68 7c 03 80 00       	push   $0x80037c
  8003ef:	e8 1a 01 00 00       	call   80050e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f4:	83 c4 08             	add    $0x8,%esp
  8003f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800403:	50                   	push   %eax
  800404:	e8 64 09 00 00       	call   800d6d <sys_cputs>

	return b.cnt;
}
  800409:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800417:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041a:	50                   	push   %eax
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 9d ff ff ff       	call   8003c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
  80042b:	83 ec 1c             	sub    $0x1c,%esp
  80042e:	89 c7                	mov    %eax,%edi
  800430:	89 d6                	mov    %edx,%esi
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800441:	bb 00 00 00 00       	mov    $0x0,%ebx
  800446:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044c:	39 d3                	cmp    %edx,%ebx
  80044e:	72 05                	jb     800455 <printnum+0x30>
  800450:	39 45 10             	cmp    %eax,0x10(%ebp)
  800453:	77 7a                	ja     8004cf <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	ff 75 18             	pushl  0x18(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800461:	53                   	push   %ebx
  800462:	ff 75 10             	pushl  0x10(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 75 dc             	pushl  -0x24(%ebp)
  800471:	ff 75 d8             	pushl  -0x28(%ebp)
  800474:	e8 a7 1d 00 00       	call   802220 <__udivdi3>
  800479:	83 c4 18             	add    $0x18,%esp
  80047c:	52                   	push   %edx
  80047d:	50                   	push   %eax
  80047e:	89 f2                	mov    %esi,%edx
  800480:	89 f8                	mov    %edi,%eax
  800482:	e8 9e ff ff ff       	call   800425 <printnum>
  800487:	83 c4 20             	add    $0x20,%esp
  80048a:	eb 13                	jmp    80049f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	56                   	push   %esi
  800490:	ff 75 18             	pushl  0x18(%ebp)
  800493:	ff d7                	call   *%edi
  800495:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	85 db                	test   %ebx,%ebx
  80049d:	7f ed                	jg     80048c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	83 ec 04             	sub    $0x4,%esp
  8004a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8004af:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b2:	e8 89 1e 00 00       	call   802340 <__umoddi3>
  8004b7:	83 c4 14             	add    $0x14,%esp
  8004ba:	0f be 80 db 25 80 00 	movsbl 0x8025db(%eax),%eax
  8004c1:	50                   	push   %eax
  8004c2:	ff d7                	call   *%edi
}
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5e                   	pop    %esi
  8004cc:	5f                   	pop    %edi
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    
  8004cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d2:	eb c4                	jmp    800498 <printnum+0x73>

008004d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e3:	73 0a                	jae    8004ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	88 02                	mov    %al,(%edx)
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <printfmt>:
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 10             	pushl  0x10(%ebp)
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 05 00 00 00       	call   80050e <vprintfmt>
}
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    

0080050e <vprintfmt>:
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	53                   	push   %ebx
  800514:	83 ec 2c             	sub    $0x2c,%esp
  800517:	8b 75 08             	mov    0x8(%ebp),%esi
  80051a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800520:	e9 c1 03 00 00       	jmp    8008e6 <vprintfmt+0x3d8>
		padc = ' ';
  800525:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800529:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800530:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800537:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80053e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8d 47 01             	lea    0x1(%edi),%eax
  800546:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800549:	0f b6 17             	movzbl (%edi),%edx
  80054c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054f:	3c 55                	cmp    $0x55,%al
  800551:	0f 87 12 04 00 00    	ja     800969 <vprintfmt+0x45b>
  800557:	0f b6 c0             	movzbl %al,%eax
  80055a:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800564:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800568:	eb d9                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80056d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800571:	eb d0                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800573:	0f b6 d2             	movzbl %dl,%edx
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800579:	b8 00 00 00 00       	mov    $0x0,%eax
  80057e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800581:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800584:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800588:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80058b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80058e:	83 f9 09             	cmp    $0x9,%ecx
  800591:	77 55                	ja     8005e8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800593:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800596:	eb e9                	jmp    800581 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 40 04             	lea    0x4(%eax),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b0:	79 91                	jns    800543 <vprintfmt+0x35>
				width = precision, precision = -1;
  8005b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005bf:	eb 82                	jmp    800543 <vprintfmt+0x35>
  8005c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cb:	0f 49 d0             	cmovns %eax,%edx
  8005ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	e9 6a ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e3:	e9 5b ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ee:	eb bc                	jmp    8005ac <vprintfmt+0x9e>
			lflag++;
  8005f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f6:	e9 48 ff ff ff       	jmp    800543 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 78 04             	lea    0x4(%eax),%edi
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	ff 30                	pushl  (%eax)
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80060c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060f:	e9 cf 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 78 04             	lea    0x4(%eax),%edi
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	99                   	cltd   
  80061d:	31 d0                	xor    %edx,%eax
  80061f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800621:	83 f8 0f             	cmp    $0xf,%eax
  800624:	7f 23                	jg     800649 <vprintfmt+0x13b>
  800626:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 18                	je     800649 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800631:	52                   	push   %edx
  800632:	68 f5 2a 80 00       	push   $0x802af5
  800637:	53                   	push   %ebx
  800638:	56                   	push   %esi
  800639:	e8 b3 fe ff ff       	call   8004f1 <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800641:	89 7d 14             	mov    %edi,0x14(%ebp)
  800644:	e9 9a 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800649:	50                   	push   %eax
  80064a:	68 f3 25 80 00       	push   $0x8025f3
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	e8 9b fe ff ff       	call   8004f1 <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800659:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80065c:	e9 82 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	83 c0 04             	add    $0x4,%eax
  800667:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80066f:	85 ff                	test   %edi,%edi
  800671:	b8 ec 25 80 00       	mov    $0x8025ec,%eax
  800676:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	0f 8e bd 00 00 00    	jle    800740 <vprintfmt+0x232>
  800683:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800687:	75 0e                	jne    800697 <vprintfmt+0x189>
  800689:	89 75 08             	mov    %esi,0x8(%ebp)
  80068c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800692:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800695:	eb 6d                	jmp    800704 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	ff 75 d0             	pushl  -0x30(%ebp)
  80069d:	57                   	push   %edi
  80069e:	e8 6e 03 00 00       	call   800a11 <strnlen>
  8006a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a6:	29 c1                	sub    %eax,%ecx
  8006a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ba:	eb 0f                	jmp    8006cb <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 ef 01             	sub    $0x1,%edi
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 ff                	test   %edi,%edi
  8006cd:	7f ed                	jg     8006bc <vprintfmt+0x1ae>
  8006cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d5:	85 c9                	test   %ecx,%ecx
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	0f 49 c1             	cmovns %ecx,%eax
  8006df:	29 c1                	sub    %eax,%ecx
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	89 cb                	mov    %ecx,%ebx
  8006ec:	eb 16                	jmp    800704 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f2:	75 31                	jne    800725 <vprintfmt+0x217>
					putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	50                   	push   %eax
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	83 eb 01             	sub    $0x1,%ebx
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80070b:	0f be c2             	movsbl %dl,%eax
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 59                	je     80076b <vprintfmt+0x25d>
  800712:	85 f6                	test   %esi,%esi
  800714:	78 d8                	js     8006ee <vprintfmt+0x1e0>
  800716:	83 ee 01             	sub    $0x1,%esi
  800719:	79 d3                	jns    8006ee <vprintfmt+0x1e0>
  80071b:	89 df                	mov    %ebx,%edi
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800723:	eb 37                	jmp    80075c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800725:	0f be d2             	movsbl %dl,%edx
  800728:	83 ea 20             	sub    $0x20,%edx
  80072b:	83 fa 5e             	cmp    $0x5e,%edx
  80072e:	76 c4                	jbe    8006f4 <vprintfmt+0x1e6>
					putch('?', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	6a 3f                	push   $0x3f
  800738:	ff 55 08             	call   *0x8(%ebp)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb c1                	jmp    800701 <vprintfmt+0x1f3>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800749:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074c:	eb b6                	jmp    800704 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 20                	push   $0x20
  800754:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 ff                	test   %edi,%edi
  80075e:	7f ee                	jg     80074e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800760:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
  800766:	e9 78 01 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
  80076b:	89 df                	mov    %ebx,%edi
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800773:	eb e7                	jmp    80075c <vprintfmt+0x24e>
	if (lflag >= 2)
  800775:	83 f9 01             	cmp    $0x1,%ecx
  800778:	7e 3f                	jle    8007b9 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 50 04             	mov    0x4(%eax),%edx
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800785:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 40 08             	lea    0x8(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800791:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800795:	79 5c                	jns    8007f3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 2d                	push   $0x2d
  80079d:	ff d6                	call   *%esi
				num = -(long long) num;
  80079f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007a5:	f7 da                	neg    %edx
  8007a7:	83 d1 00             	adc    $0x0,%ecx
  8007aa:	f7 d9                	neg    %ecx
  8007ac:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b4:	e9 10 01 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	75 1b                	jne    8007d8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d6:	eb b9                	jmp    800791 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 c1                	mov    %eax,%ecx
  8007e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f1:	eb 9e                	jmp    800791 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fe:	e9 c6 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800803:	83 f9 01             	cmp    $0x1,%ecx
  800806:	7e 18                	jle    800820 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	8b 48 04             	mov    0x4(%eax),%ecx
  800810:	8d 40 08             	lea    0x8(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	e9 a9 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800820:	85 c9                	test   %ecx,%ecx
  800822:	75 1a                	jne    80083e <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
  800839:	e9 8b 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	eb 74                	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7e 15                	jle    80086f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	8b 48 04             	mov    0x4(%eax),%ecx
  800862:	8d 40 08             	lea    0x8(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800868:	b8 08 00 00 00       	mov    $0x8,%eax
  80086d:	eb 5a                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  80086f:	85 c9                	test   %ecx,%ecx
  800871:	75 17                	jne    80088a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
  800888:	eb 3f                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800894:	8d 40 04             	lea    0x4(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  80089a:	b8 08 00 00 00       	mov    $0x8,%eax
  80089f:	eb 28                	jmp    8008c9 <vprintfmt+0x3bb>
			putch('0', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 30                	push   $0x30
  8008a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 78                	push   $0x78
  8008af:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8b 10                	mov    (%eax),%edx
  8008b6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008bb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008be:	8d 40 04             	lea    0x4(%eax),%eax
  8008c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c9:	83 ec 0c             	sub    $0xc,%esp
  8008cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d0:	57                   	push   %edi
  8008d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d4:	50                   	push   %eax
  8008d5:	51                   	push   %ecx
  8008d6:	52                   	push   %edx
  8008d7:	89 da                	mov    %ebx,%edx
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	e8 45 fb ff ff       	call   800425 <printnum>
			break;
  8008e0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e6:	83 c7 01             	add    $0x1,%edi
  8008e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ed:	83 f8 25             	cmp    $0x25,%eax
  8008f0:	0f 84 2f fc ff ff    	je     800525 <vprintfmt+0x17>
			if (ch == '\0')
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	0f 84 8b 00 00 00    	je     800989 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	53                   	push   %ebx
  800902:	50                   	push   %eax
  800903:	ff d6                	call   *%esi
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb dc                	jmp    8008e6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80090a:	83 f9 01             	cmp    $0x1,%ecx
  80090d:	7e 15                	jle    800924 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	8b 48 04             	mov    0x4(%eax),%ecx
  800917:	8d 40 08             	lea    0x8(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
  800922:	eb a5                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	75 17                	jne    80093f <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	b8 10 00 00 00       	mov    $0x10,%eax
  80093d:	eb 8a                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8b 10                	mov    (%eax),%edx
  800944:	b9 00 00 00 00       	mov    $0x0,%ecx
  800949:	8d 40 04             	lea    0x4(%eax),%eax
  80094c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094f:	b8 10 00 00 00       	mov    $0x10,%eax
  800954:	e9 70 ff ff ff       	jmp    8008c9 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800959:	83 ec 08             	sub    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	6a 25                	push   $0x25
  80095f:	ff d6                	call   *%esi
			break;
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	e9 7a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	6a 25                	push   $0x25
  80096f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	89 f8                	mov    %edi,%eax
  800976:	eb 03                	jmp    80097b <vprintfmt+0x46d>
  800978:	83 e8 01             	sub    $0x1,%eax
  80097b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80097f:	75 f7                	jne    800978 <vprintfmt+0x46a>
  800981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800984:	e9 5a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
}
  800989:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 18             	sub    $0x18,%esp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	74 26                	je     8009d8 <vsnprintf+0x47>
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	7e 22                	jle    8009d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b6:	ff 75 14             	pushl  0x14(%ebp)
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bf:	50                   	push   %eax
  8009c0:	68 d4 04 80 00       	push   $0x8004d4
  8009c5:	e8 44 fb ff ff       	call   80050e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d3:	83 c4 10             	add    $0x10,%esp
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    
		return -E_INVAL;
  8009d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009dd:	eb f7                	jmp    8009d6 <vsnprintf+0x45>

008009df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 9a ff ff ff       	call   800991 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 03                	jmp    800a09 <strlen+0x10>
		n++;
  800a06:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0d:	75 f7                	jne    800a06 <strlen+0xd>
	return n;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 03                	jmp    800a24 <strnlen+0x13>
		n++;
  800a21:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	74 06                	je     800a2e <strnlen+0x1d>
  800a28:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2c:	75 f3                	jne    800a21 <strnlen+0x10>
	return n;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a46:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a49:	84 db                	test   %bl,%bl
  800a4b:	75 ef                	jne    800a3c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a57:	53                   	push   %ebx
  800a58:	e8 9c ff ff ff       	call   8009f9 <strlen>
  800a5d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	01 d8                	add    %ebx,%eax
  800a65:	50                   	push   %eax
  800a66:	e8 c5 ff ff ff       	call   800a30 <strcpy>
	return dst;
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	89 f2                	mov    %esi,%edx
  800a84:	eb 0f                	jmp    800a95 <strncpy+0x23>
		*dst++ = *src;
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a92:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a95:	39 da                	cmp    %ebx,%edx
  800a97:	75 ed                	jne    800a86 <strncpy+0x14>
	}
	return ret;
}
  800a99:	89 f0                	mov    %esi,%eax
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab3:	85 c9                	test   %ecx,%ecx
  800ab5:	75 0b                	jne    800ac2 <strlcpy+0x23>
  800ab7:	eb 17                	jmp    800ad0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ac2:	39 d8                	cmp    %ebx,%eax
  800ac4:	74 07                	je     800acd <strlcpy+0x2e>
  800ac6:	0f b6 0a             	movzbl (%edx),%ecx
  800ac9:	84 c9                	test   %cl,%cl
  800acb:	75 ec                	jne    800ab9 <strlcpy+0x1a>
		*dst = '\0';
  800acd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad0:	29 f0                	sub    %esi,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adf:	eb 06                	jmp    800ae7 <strcmp+0x11>
		p++, q++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	84 c0                	test   %al,%al
  800aec:	74 04                	je     800af2 <strcmp+0x1c>
  800aee:	3a 02                	cmp    (%edx),%al
  800af0:	74 ef                	je     800ae1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af2:	0f b6 c0             	movzbl %al,%eax
  800af5:	0f b6 12             	movzbl (%edx),%edx
  800af8:	29 d0                	sub    %edx,%eax
}
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b0b:	eb 06                	jmp    800b13 <strncmp+0x17>
		n--, p++, q++;
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b13:	39 d8                	cmp    %ebx,%eax
  800b15:	74 16                	je     800b2d <strncmp+0x31>
  800b17:	0f b6 08             	movzbl (%eax),%ecx
  800b1a:	84 c9                	test   %cl,%cl
  800b1c:	74 04                	je     800b22 <strncmp+0x26>
  800b1e:	3a 0a                	cmp    (%edx),%cl
  800b20:	74 eb                	je     800b0d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	0f b6 12             	movzbl (%edx),%edx
  800b28:	29 d0                	sub    %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb f6                	jmp    800b2a <strncmp+0x2e>

00800b34 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3e:	0f b6 10             	movzbl (%eax),%edx
  800b41:	84 d2                	test   %dl,%dl
  800b43:	74 09                	je     800b4e <strchr+0x1a>
		if (*s == c)
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	74 0a                	je     800b53 <strchr+0x1f>
	for (; *s; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	eb f0                	jmp    800b3e <strchr+0xa>
			return (char *) s;
	return 0;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5f:	eb 03                	jmp    800b64 <strfind+0xf>
  800b61:	83 c0 01             	add    $0x1,%eax
  800b64:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b67:	38 ca                	cmp    %cl,%dl
  800b69:	74 04                	je     800b6f <strfind+0x1a>
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0xc>
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 13                	je     800b94 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 05                	jne    800b8e <memset+0x1d>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	74 0d                	je     800b9b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	fc                   	cld    
  800b92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b94:	89 f8                	mov    %edi,%eax
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		c &= 0xFF;
  800b9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	c1 e3 08             	shl    $0x8,%ebx
  800ba4:	89 d0                	mov    %edx,%eax
  800ba6:	c1 e0 18             	shl    $0x18,%eax
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	c1 e6 10             	shl    $0x10,%esi
  800bae:	09 f0                	or     %esi,%eax
  800bb0:	09 c2                	or     %eax,%edx
  800bb2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	fc                   	cld    
  800bba:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbc:	eb d6                	jmp    800b94 <memset+0x23>

00800bbe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bcc:	39 c6                	cmp    %eax,%esi
  800bce:	73 35                	jae    800c05 <memmove+0x47>
  800bd0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd3:	39 c2                	cmp    %eax,%edx
  800bd5:	76 2e                	jbe    800c05 <memmove+0x47>
		s += n;
		d += n;
  800bd7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	09 fe                	or     %edi,%esi
  800bde:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be4:	74 0c                	je     800bf2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be6:	83 ef 01             	sub    $0x1,%edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 21                	jmp    800c13 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f6 c1 03             	test   $0x3,%cl
  800bf5:	75 ef                	jne    800be6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf7:	83 ef 04             	sub    $0x4,%edi
  800bfa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c00:	fd                   	std    
  800c01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c03:	eb ea                	jmp    800bef <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c05:	89 f2                	mov    %esi,%edx
  800c07:	09 c2                	or     %eax,%edx
  800c09:	f6 c2 03             	test   $0x3,%dl
  800c0c:	74 09                	je     800c17 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 f2                	jne    800c0e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c1f:	89 c7                	mov    %eax,%edi
  800c21:	fc                   	cld    
  800c22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c24:	eb ed                	jmp    800c13 <memmove+0x55>

00800c26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c29:	ff 75 10             	pushl  0x10(%ebp)
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	ff 75 08             	pushl  0x8(%ebp)
  800c32:	e8 87 ff ff ff       	call   800bbe <memmove>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c44:	89 c6                	mov    %eax,%esi
  800c46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c49:	39 f0                	cmp    %esi,%eax
  800c4b:	74 1c                	je     800c69 <memcmp+0x30>
		if (*s1 != *s2)
  800c4d:	0f b6 08             	movzbl (%eax),%ecx
  800c50:	0f b6 1a             	movzbl (%edx),%ebx
  800c53:	38 d9                	cmp    %bl,%cl
  800c55:	75 08                	jne    800c5f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	eb ea                	jmp    800c49 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c5f:	0f b6 c1             	movzbl %cl,%eax
  800c62:	0f b6 db             	movzbl %bl,%ebx
  800c65:	29 d8                	sub    %ebx,%eax
  800c67:	eb 05                	jmp    800c6e <memcmp+0x35>
	}

	return 0;
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	73 09                	jae    800c8d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c84:	38 08                	cmp    %cl,(%eax)
  800c86:	74 05                	je     800c8d <memfind+0x1b>
	for (; s < ends; s++)
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	eb f3                	jmp    800c80 <memfind+0xe>
			break;
	return (void *) s;
}
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	eb 03                	jmp    800ca0 <strtol+0x11>
		s++;
  800c9d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 01             	movzbl (%ecx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 f6                	je     800c9d <strtol+0xe>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	74 f2                	je     800c9d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cab:	3c 2b                	cmp    $0x2b,%al
  800cad:	74 2e                	je     800cdd <strtol+0x4e>
	int neg = 0;
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cb4:	3c 2d                	cmp    $0x2d,%al
  800cb6:	74 2f                	je     800ce7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cbe:	75 05                	jne    800cc5 <strtol+0x36>
  800cc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc3:	74 2c                	je     800cf1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	85 db                	test   %ebx,%ebx
  800cc7:	75 0a                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cce:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd1:	74 28                	je     800cfb <strtol+0x6c>
		base = 10;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cdb:	eb 50                	jmp    800d2d <strtol+0x9e>
		s++;
  800cdd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce5:	eb d1                	jmp    800cb8 <strtol+0x29>
		s++, neg = 1;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	bf 01 00 00 00       	mov    $0x1,%edi
  800cef:	eb c7                	jmp    800cb8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf5:	74 0e                	je     800d05 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	75 d8                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
  800cfb:	83 c1 01             	add    $0x1,%ecx
  800cfe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d03:	eb ce                	jmp    800cd3 <strtol+0x44>
		s += 2, base = 16;
  800d05:	83 c1 02             	add    $0x2,%ecx
  800d08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d0d:	eb c4                	jmp    800cd3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 29                	ja     800d42 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d22:	7d 30                	jge    800d54 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d2b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d2d:	0f b6 11             	movzbl (%ecx),%edx
  800d30:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	80 fb 09             	cmp    $0x9,%bl
  800d38:	77 d5                	ja     800d0f <strtol+0x80>
			dig = *s - '0';
  800d3a:	0f be d2             	movsbl %dl,%edx
  800d3d:	83 ea 30             	sub    $0x30,%edx
  800d40:	eb dd                	jmp    800d1f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d45:	89 f3                	mov    %esi,%ebx
  800d47:	80 fb 19             	cmp    $0x19,%bl
  800d4a:	77 08                	ja     800d54 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d4c:	0f be d2             	movsbl %dl,%edx
  800d4f:	83 ea 37             	sub    $0x37,%edx
  800d52:	eb cb                	jmp    800d1f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d58:	74 05                	je     800d5f <strtol+0xd0>
		*endptr = (char *) s;
  800d5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	f7 da                	neg    %edx
  800d63:	85 ff                	test   %edi,%edi
  800d65:	0f 45 c2             	cmovne %edx,%eax
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	89 c7                	mov    %eax,%edi
  800d82:	89 c6                	mov    %eax,%esi
  800d84:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	89 d1                	mov    %edx,%ecx
  800d9d:	89 d3                	mov    %edx,%ebx
  800d9f:	89 d7                	mov    %edx,%edi
  800da1:	89 d6                	mov    %edx,%esi
  800da3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 03                	push   $0x3
  800dda:	68 df 28 80 00       	push   $0x8028df
  800ddf:	6a 23                	push   $0x23
  800de1:	68 fc 28 80 00       	push   $0x8028fc
  800de6:	e8 4b f5 ff ff       	call   800336 <_panic>

00800deb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_yield>:

void
sys_yield(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	89 f7                	mov    %esi,%edi
  800e47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7f 08                	jg     800e55 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 04                	push   $0x4
  800e5b:	68 df 28 80 00       	push   $0x8028df
  800e60:	6a 23                	push   $0x23
  800e62:	68 fc 28 80 00       	push   $0x8028fc
  800e67:	e8 ca f4 ff ff       	call   800336 <_panic>

00800e6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e86:	8b 75 18             	mov    0x18(%ebp),%esi
  800e89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7f 08                	jg     800e97 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 05                	push   $0x5
  800e9d:	68 df 28 80 00       	push   $0x8028df
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 fc 28 80 00       	push   $0x8028fc
  800ea9:	e8 88 f4 ff ff       	call   800336 <_panic>

00800eae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7f 08                	jg     800ed9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	50                   	push   %eax
  800edd:	6a 06                	push   $0x6
  800edf:	68 df 28 80 00       	push   $0x8028df
  800ee4:	6a 23                	push   $0x23
  800ee6:	68 fc 28 80 00       	push   $0x8028fc
  800eeb:	e8 46 f4 ff ff       	call   800336 <_panic>

00800ef0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	b8 08 00 00 00       	mov    $0x8,%eax
  800f09:	89 df                	mov    %ebx,%edi
  800f0b:	89 de                	mov    %ebx,%esi
  800f0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7f 08                	jg     800f1b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	50                   	push   %eax
  800f1f:	6a 08                	push   $0x8
  800f21:	68 df 28 80 00       	push   $0x8028df
  800f26:	6a 23                	push   $0x23
  800f28:	68 fc 28 80 00       	push   $0x8028fc
  800f2d:	e8 04 f4 ff ff       	call   800336 <_panic>

00800f32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4b:	89 df                	mov    %ebx,%edi
  800f4d:	89 de                	mov    %ebx,%esi
  800f4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	7f 08                	jg     800f5d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	50                   	push   %eax
  800f61:	6a 09                	push   $0x9
  800f63:	68 df 28 80 00       	push   $0x8028df
  800f68:	6a 23                	push   $0x23
  800f6a:	68 fc 28 80 00       	push   $0x8028fc
  800f6f:	e8 c2 f3 ff ff       	call   800336 <_panic>

00800f74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8d:	89 df                	mov    %ebx,%edi
  800f8f:	89 de                	mov    %ebx,%esi
  800f91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	7f 08                	jg     800f9f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	50                   	push   %eax
  800fa3:	6a 0a                	push   $0xa
  800fa5:	68 df 28 80 00       	push   $0x8028df
  800faa:	6a 23                	push   $0x23
  800fac:	68 fc 28 80 00       	push   $0x8028fc
  800fb1:	e8 80 f3 ff ff       	call   800336 <_panic>

00800fb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc7:	be 00 00 00 00       	mov    $0x0,%esi
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7f 08                	jg     801003 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ffb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	6a 0d                	push   $0xd
  801009:	68 df 28 80 00       	push   $0x8028df
  80100e:	6a 23                	push   $0x23
  801010:	68 fc 28 80 00       	push   $0x8028fc
  801015:	e8 1c f3 ff ff       	call   800336 <_panic>

0080101a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	53                   	push   %ebx
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801024:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801026:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801029:	a8 02                	test   $0x2,%al
  80102b:	0f 84 89 00 00 00    	je     8010ba <pgfault+0xa0>
  801031:	89 da                	mov    %ebx,%edx
  801033:	c1 ea 0c             	shr    $0xc,%edx
  801036:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80103d:	f6 c6 08             	test   $0x8,%dh
  801040:	74 78                	je     8010ba <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	6a 07                	push   $0x7
  801047:	68 00 f0 7f 00       	push   $0x7ff000
  80104c:	6a 00                	push   $0x0
  80104e:	e8 d6 fd ff ff       	call   800e29 <sys_page_alloc>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	0f 88 8b 00 00 00    	js     8010e9 <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	68 00 10 00 00       	push   $0x1000
  801066:	53                   	push   %ebx
  801067:	68 00 f0 7f 00       	push   $0x7ff000
  80106c:	e8 4d fb ff ff       	call   800bbe <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801071:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801078:	53                   	push   %ebx
  801079:	6a 00                	push   $0x0
  80107b:	68 00 f0 7f 00       	push   $0x7ff000
  801080:	6a 00                	push   $0x0
  801082:	e8 e5 fd ff ff       	call   800e6c <sys_page_map>
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 6d                	js     8010fb <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80108e:	83 ec 08             	sub    $0x8,%esp
  801091:	68 00 f0 7f 00       	push   $0x7ff000
  801096:	6a 00                	push   $0x0
  801098:	e8 11 fe ff ff       	call   800eae <sys_page_unmap>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 69                	js     80110d <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	53                   	push   %ebx
  8010a8:	68 68 29 80 00       	push   $0x802968
  8010ad:	e8 5f f3 ff ff       	call   800411 <cprintf>

}
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  8010ba:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010c0:	8b 4a 48             	mov    0x48(%edx),%ecx
  8010c3:	89 da                	mov    %ebx,%edx
  8010c5:	c1 ea 0c             	shr    $0xc,%edx
  8010c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cf:	51                   	push   %ecx
  8010d0:	53                   	push   %ebx
  8010d1:	68 00 00 40 ef       	push   $0xef400000
  8010d6:	52                   	push   %edx
  8010d7:	50                   	push   %eax
  8010d8:	68 0c 29 80 00       	push   $0x80290c
  8010dd:	6a 1e                	push   $0x1e
  8010df:	68 89 29 80 00       	push   $0x802989
  8010e4:	e8 4d f2 ff ff       	call   800336 <_panic>
        panic("sys_page_alloc error %e", r);
  8010e9:	50                   	push   %eax
  8010ea:	68 94 29 80 00       	push   $0x802994
  8010ef:	6a 28                	push   $0x28
  8010f1:	68 89 29 80 00       	push   $0x802989
  8010f6:	e8 3b f2 ff ff       	call   800336 <_panic>
        panic("sys_page_map error %e", r);
  8010fb:	50                   	push   %eax
  8010fc:	68 ac 29 80 00       	push   $0x8029ac
  801101:	6a 2b                	push   $0x2b
  801103:	68 89 29 80 00       	push   $0x802989
  801108:	e8 29 f2 ff ff       	call   800336 <_panic>
        panic("sys_page_unmap error %e", r);
  80110d:	50                   	push   %eax
  80110e:	68 c2 29 80 00       	push   $0x8029c2
  801113:	6a 2d                	push   $0x2d
  801115:	68 89 29 80 00       	push   $0x802989
  80111a:	e8 17 f2 ff ff       	call   800336 <_panic>

0080111f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801125:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  80112c:	74 23                	je     801151 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	a3 08 40 80 00       	mov    %eax,0x804008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801136:	a1 04 40 80 00       	mov    0x804004,%eax
  80113b:	8b 40 48             	mov    0x48(%eax),%eax
  80113e:	83 ec 08             	sub    $0x8,%esp
  801141:	68 cd 20 80 00       	push   $0x8020cd
  801146:	50                   	push   %eax
  801147:	e8 28 fe ff ff       	call   800f74 <sys_env_set_pgfault_upcall>
}
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	c9                   	leave  
  801150:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  801151:	a1 04 40 80 00       	mov    0x804004,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	6a 07                	push   $0x7
  80115e:	68 00 f0 bf ee       	push   $0xeebff000
  801163:	50                   	push   %eax
  801164:	e8 c0 fc ff ff       	call   800e29 <sys_page_alloc>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	79 be                	jns    80112e <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  801170:	50                   	push   %eax
  801171:	68 da 29 80 00       	push   $0x8029da
  801176:	6a 21                	push   $0x21
  801178:	68 ed 29 80 00       	push   $0x8029ed
  80117d:	e8 b4 f1 ff ff       	call   800336 <_panic>

00801182 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	56                   	push   %esi
  801186:	53                   	push   %ebx
  801187:	8b 75 08             	mov    0x8(%ebp),%esi
  80118a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	6a 07                	push   $0x7
  801192:	53                   	push   %ebx
  801193:	56                   	push   %esi
  801194:	e8 90 fc ff ff       	call   800e29 <sys_page_alloc>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 4a                	js     8011ea <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	6a 07                	push   $0x7
  8011a5:	68 00 00 40 00       	push   $0x400000
  8011aa:	6a 00                	push   $0x0
  8011ac:	53                   	push   %ebx
  8011ad:	56                   	push   %esi
  8011ae:	e8 b9 fc ff ff       	call   800e6c <sys_page_map>
  8011b3:	83 c4 20             	add    $0x20,%esp
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 42                	js     8011fc <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	68 00 10 00 00       	push   $0x1000
  8011c2:	53                   	push   %ebx
  8011c3:	68 00 00 40 00       	push   $0x400000
  8011c8:	e8 f1 f9 ff ff       	call   800bbe <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	68 00 00 40 00       	push   $0x400000
  8011d5:	6a 00                	push   $0x0
  8011d7:	e8 d2 fc ff ff       	call   800eae <sys_page_unmap>
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 2b                	js     80120e <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  8011e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  8011ea:	50                   	push   %eax
  8011eb:	68 da 29 80 00       	push   $0x8029da
  8011f0:	6a 63                	push   $0x63
  8011f2:	68 89 29 80 00       	push   $0x802989
  8011f7:	e8 3a f1 ff ff       	call   800336 <_panic>
        panic("sys_page_map: %e", r);
  8011fc:	50                   	push   %eax
  8011fd:	68 fd 29 80 00       	push   $0x8029fd
  801202:	6a 65                	push   $0x65
  801204:	68 89 29 80 00       	push   $0x802989
  801209:	e8 28 f1 ff ff       	call   800336 <_panic>
        panic("sys_page_unmap: %e", r);
  80120e:	50                   	push   %eax
  80120f:	68 0e 2a 80 00       	push   $0x802a0e
  801214:	6a 68                	push   $0x68
  801216:	68 89 29 80 00       	push   $0x802989
  80121b:	e8 16 f1 ff ff       	call   800336 <_panic>

00801220 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	57                   	push   %edi
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  801229:	a1 04 40 80 00       	mov    0x804004,%eax
  80122e:	8b 40 64             	mov    0x64(%eax),%eax
  801231:	85 c0                	test   %eax,%eax
  801233:	74 1f                	je     801254 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801235:	b8 07 00 00 00       	mov    $0x7,%eax
  80123a:	cd 30                	int    $0x30
  80123c:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  80123e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801241:	85 c0                	test   %eax,%eax
  801243:	74 21                	je     801266 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  801245:	be 08 40 80 00       	mov    $0x804008,%esi
  80124a:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  80124d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801252:	eb 7b                	jmp    8012cf <fork+0xaf>
        set_pgfault_handler(pgfault);
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	68 1a 10 80 00       	push   $0x80101a
  80125c:	e8 be fe ff ff       	call   80111f <set_pgfault_handler>
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	eb cf                	jmp    801235 <fork+0x15>
        set_pgfault_handler(pgfault);
  801266:	83 ec 0c             	sub    $0xc,%esp
  801269:	68 1a 10 80 00       	push   $0x80101a
  80126e:	e8 ac fe ff ff       	call   80111f <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801273:	e8 73 fb ff ff       	call   800deb <sys_getenvid>
  801278:	25 ff 03 00 00       	and    $0x3ff,%eax
  80127d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801280:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801285:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	e9 ca 00 00 00       	jmp    80135c <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801292:	89 d1                	mov    %edx,%ecx
  801294:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  80129a:	81 e2 02 08 00 00    	and    $0x802,%edx
  8012a0:	89 cf                	mov    %ecx,%edi
  8012a2:	81 cf 00 08 00 00    	or     $0x800,%edi
  8012a8:	85 d2                	test   %edx,%edx
  8012aa:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  8012ad:	83 ec 0c             	sub    $0xc,%esp
  8012b0:	51                   	push   %ecx
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b5:	50                   	push   %eax
  8012b6:	6a 00                	push   $0x0
  8012b8:	e8 af fb ff ff       	call   800e6c <sys_page_map>
  8012bd:	83 c4 20             	add    $0x20,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 45                	js     801309 <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8012c4:	83 c3 01             	add    $0x1,%ebx
  8012c7:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  8012cd:	74 4c                	je     80131b <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  8012cf:	39 de                	cmp    %ebx,%esi
  8012d1:	74 f1                	je     8012c4 <fork+0xa4>
  8012d3:	89 d8                	mov    %ebx,%eax
  8012d5:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	c1 ea 16             	shr    $0x16,%edx
  8012dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  8012e4:	f6 c2 05             	test   $0x5,%dl
  8012e7:	74 db                	je     8012c4 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	c1 ea 0c             	shr    $0xc,%edx
  8012ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  8012f5:	f6 c2 04             	test   $0x4,%dl
  8012f8:	74 ca                	je     8012c4 <fork+0xa4>
    if (perm & PTE_SHARE) {
  8012fa:	f6 c6 04             	test   $0x4,%dh
  8012fd:	74 93                	je     801292 <fork+0x72>
        perm &= ~PTE_COW;
  8012ff:	89 d1                	mov    %edx,%ecx
  801301:	81 e1 07 06 00 00    	and    $0x607,%ecx
  801307:	eb a4                	jmp    8012ad <fork+0x8d>
        panic("sys_page_map error %e", r);
  801309:	50                   	push   %eax
  80130a:	68 ac 29 80 00       	push   $0x8029ac
  80130f:	6a 57                	push   $0x57
  801311:	68 89 29 80 00       	push   $0x802989
  801316:	e8 1b f0 ff ff       	call   800336 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	b8 08 40 80 00       	mov    $0x804008,%eax
  801323:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801328:	50                   	push   %eax
  801329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132c:	e8 51 fe ff ff       	call   801182 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  801331:	83 c4 08             	add    $0x8,%esp
  801334:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801337:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133c:	50                   	push   %eax
  80133d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801340:	e8 3d fe ff ff       	call   801182 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	6a 02                	push   $0x2
  80134a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80134d:	e8 9e fb ff ff       	call   800ef0 <sys_env_set_status>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	78 0d                	js     801366 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  801359:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801366:	50                   	push   %eax
  801367:	68 21 2a 80 00       	push   $0x802a21
  80136c:	68 a0 00 00 00       	push   $0xa0
  801371:	68 89 29 80 00       	push   $0x802989
  801376:	e8 bb ef ff ff       	call   800336 <_panic>

0080137b <sfork>:

// Challenge!
int
sfork(void)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801381:	68 38 2a 80 00       	push   $0x802a38
  801386:	68 a9 00 00 00       	push   $0xa9
  80138b:	68 89 29 80 00       	push   $0x802989
  801390:	e8 a1 ef ff ff       	call   800336 <_panic>

00801395 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801398:	8b 45 08             	mov    0x8(%ebp),%eax
  80139b:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a0:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013b5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c7:	89 c2                	mov    %eax,%edx
  8013c9:	c1 ea 16             	shr    $0x16,%edx
  8013cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d3:	f6 c2 01             	test   $0x1,%dl
  8013d6:	74 2a                	je     801402 <fd_alloc+0x46>
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	c1 ea 0c             	shr    $0xc,%edx
  8013dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e4:	f6 c2 01             	test   $0x1,%dl
  8013e7:	74 19                	je     801402 <fd_alloc+0x46>
  8013e9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f3:	75 d2                	jne    8013c7 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801400:	eb 07                	jmp    801409 <fd_alloc+0x4d>
			*fd_store = fd;
  801402:	89 01                	mov    %eax,(%ecx)
			return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801411:	83 f8 1f             	cmp    $0x1f,%eax
  801414:	77 36                	ja     80144c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801416:	c1 e0 0c             	shl    $0xc,%eax
  801419:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80141e:	89 c2                	mov    %eax,%edx
  801420:	c1 ea 16             	shr    $0x16,%edx
  801423:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142a:	f6 c2 01             	test   $0x1,%dl
  80142d:	74 24                	je     801453 <fd_lookup+0x48>
  80142f:	89 c2                	mov    %eax,%edx
  801431:	c1 ea 0c             	shr    $0xc,%edx
  801434:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143b:	f6 c2 01             	test   $0x1,%dl
  80143e:	74 1a                	je     80145a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801440:	8b 55 0c             	mov    0xc(%ebp),%edx
  801443:	89 02                	mov    %eax,(%edx)
	return 0;
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
		return -E_INVAL;
  80144c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801451:	eb f7                	jmp    80144a <fd_lookup+0x3f>
		return -E_INVAL;
  801453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801458:	eb f0                	jmp    80144a <fd_lookup+0x3f>
  80145a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145f:	eb e9                	jmp    80144a <fd_lookup+0x3f>

00801461 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146a:	ba cc 2a 80 00       	mov    $0x802acc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80146f:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  801474:	39 08                	cmp    %ecx,(%eax)
  801476:	74 33                	je     8014ab <dev_lookup+0x4a>
  801478:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80147b:	8b 02                	mov    (%edx),%eax
  80147d:	85 c0                	test   %eax,%eax
  80147f:	75 f3                	jne    801474 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801481:	a1 04 40 80 00       	mov    0x804004,%eax
  801486:	8b 40 48             	mov    0x48(%eax),%eax
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	51                   	push   %ecx
  80148d:	50                   	push   %eax
  80148e:	68 50 2a 80 00       	push   $0x802a50
  801493:	e8 79 ef ff ff       	call   800411 <cprintf>
	*dev = 0;
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014a9:	c9                   	leave  
  8014aa:	c3                   	ret    
			*dev = devtab[i];
  8014ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b5:	eb f2                	jmp    8014a9 <dev_lookup+0x48>

008014b7 <fd_close>:
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	57                   	push   %edi
  8014bb:	56                   	push   %esi
  8014bc:	53                   	push   %ebx
  8014bd:	83 ec 1c             	sub    $0x1c,%esp
  8014c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014c6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014c9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014ca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014d0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014d3:	50                   	push   %eax
  8014d4:	e8 32 ff ff ff       	call   80140b <fd_lookup>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	83 c4 08             	add    $0x8,%esp
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 05                	js     8014e7 <fd_close+0x30>
	    || fd != fd2)
  8014e2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014e5:	74 16                	je     8014fd <fd_close+0x46>
		return (must_exist ? r : 0);
  8014e7:	89 f8                	mov    %edi,%eax
  8014e9:	84 c0                	test   %al,%al
  8014eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f0:	0f 44 d8             	cmove  %eax,%ebx
}
  8014f3:	89 d8                	mov    %ebx,%eax
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	ff 36                	pushl  (%esi)
  801506:	e8 56 ff ff ff       	call   801461 <dev_lookup>
  80150b:	89 c3                	mov    %eax,%ebx
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	85 c0                	test   %eax,%eax
  801512:	78 15                	js     801529 <fd_close+0x72>
		if (dev->dev_close)
  801514:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801517:	8b 40 10             	mov    0x10(%eax),%eax
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 1b                	je     801539 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	56                   	push   %esi
  801522:	ff d0                	call   *%eax
  801524:	89 c3                	mov    %eax,%ebx
  801526:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801529:	83 ec 08             	sub    $0x8,%esp
  80152c:	56                   	push   %esi
  80152d:	6a 00                	push   $0x0
  80152f:	e8 7a f9 ff ff       	call   800eae <sys_page_unmap>
	return r;
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb ba                	jmp    8014f3 <fd_close+0x3c>
			r = 0;
  801539:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153e:	eb e9                	jmp    801529 <fd_close+0x72>

00801540 <close>:

int
close(int fdnum)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 b9 fe ff ff       	call   80140b <fd_lookup>
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 10                	js     801569 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	6a 01                	push   $0x1
  80155e:	ff 75 f4             	pushl  -0xc(%ebp)
  801561:	e8 51 ff ff ff       	call   8014b7 <fd_close>
  801566:	83 c4 10             	add    $0x10,%esp
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <close_all>:

void
close_all(void)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801572:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	53                   	push   %ebx
  80157b:	e8 c0 ff ff ff       	call   801540 <close>
	for (i = 0; i < MAXFD; i++)
  801580:	83 c3 01             	add    $0x1,%ebx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	83 fb 20             	cmp    $0x20,%ebx
  801589:	75 ec                	jne    801577 <close_all+0xc>
}
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801599:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	ff 75 08             	pushl  0x8(%ebp)
  8015a0:	e8 66 fe ff ff       	call   80140b <fd_lookup>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	0f 88 81 00 00 00    	js     801633 <dup+0xa3>
		return r;
	close(newfdnum);
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	e8 83 ff ff ff       	call   801540 <close>

	newfd = INDEX2FD(newfdnum);
  8015bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015c0:	c1 e6 0c             	shl    $0xc,%esi
  8015c3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015c9:	83 c4 04             	add    $0x4,%esp
  8015cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015cf:	e8 d1 fd ff ff       	call   8013a5 <fd2data>
  8015d4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015d6:	89 34 24             	mov    %esi,(%esp)
  8015d9:	e8 c7 fd ff ff       	call   8013a5 <fd2data>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015e3:	89 d8                	mov    %ebx,%eax
  8015e5:	c1 e8 16             	shr    $0x16,%eax
  8015e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ef:	a8 01                	test   $0x1,%al
  8015f1:	74 11                	je     801604 <dup+0x74>
  8015f3:	89 d8                	mov    %ebx,%eax
  8015f5:	c1 e8 0c             	shr    $0xc,%eax
  8015f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ff:	f6 c2 01             	test   $0x1,%dl
  801602:	75 39                	jne    80163d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801607:	89 d0                	mov    %edx,%eax
  801609:	c1 e8 0c             	shr    $0xc,%eax
  80160c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	25 07 0e 00 00       	and    $0xe07,%eax
  80161b:	50                   	push   %eax
  80161c:	56                   	push   %esi
  80161d:	6a 00                	push   $0x0
  80161f:	52                   	push   %edx
  801620:	6a 00                	push   $0x0
  801622:	e8 45 f8 ff ff       	call   800e6c <sys_page_map>
  801627:	89 c3                	mov    %eax,%ebx
  801629:	83 c4 20             	add    $0x20,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 31                	js     801661 <dup+0xd1>
		goto err;

	return newfdnum;
  801630:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801633:	89 d8                	mov    %ebx,%eax
  801635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801638:	5b                   	pop    %ebx
  801639:	5e                   	pop    %esi
  80163a:	5f                   	pop    %edi
  80163b:	5d                   	pop    %ebp
  80163c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80163d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801644:	83 ec 0c             	sub    $0xc,%esp
  801647:	25 07 0e 00 00       	and    $0xe07,%eax
  80164c:	50                   	push   %eax
  80164d:	57                   	push   %edi
  80164e:	6a 00                	push   $0x0
  801650:	53                   	push   %ebx
  801651:	6a 00                	push   $0x0
  801653:	e8 14 f8 ff ff       	call   800e6c <sys_page_map>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	83 c4 20             	add    $0x20,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	79 a3                	jns    801604 <dup+0x74>
	sys_page_unmap(0, newfd);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	56                   	push   %esi
  801665:	6a 00                	push   $0x0
  801667:	e8 42 f8 ff ff       	call   800eae <sys_page_unmap>
	sys_page_unmap(0, nva);
  80166c:	83 c4 08             	add    $0x8,%esp
  80166f:	57                   	push   %edi
  801670:	6a 00                	push   $0x0
  801672:	e8 37 f8 ff ff       	call   800eae <sys_page_unmap>
	return r;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb b7                	jmp    801633 <dup+0xa3>

0080167c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 14             	sub    $0x14,%esp
  801683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801686:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801689:	50                   	push   %eax
  80168a:	53                   	push   %ebx
  80168b:	e8 7b fd ff ff       	call   80140b <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 3f                	js     8016d6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a1:	ff 30                	pushl  (%eax)
  8016a3:	e8 b9 fd ff ff       	call   801461 <dev_lookup>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 27                	js     8016d6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016b2:	8b 42 08             	mov    0x8(%edx),%eax
  8016b5:	83 e0 03             	and    $0x3,%eax
  8016b8:	83 f8 01             	cmp    $0x1,%eax
  8016bb:	74 1e                	je     8016db <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	8b 40 08             	mov    0x8(%eax),%eax
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	74 35                	je     8016fc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016c7:	83 ec 04             	sub    $0x4,%esp
  8016ca:	ff 75 10             	pushl  0x10(%ebp)
  8016cd:	ff 75 0c             	pushl  0xc(%ebp)
  8016d0:	52                   	push   %edx
  8016d1:	ff d0                	call   *%eax
  8016d3:	83 c4 10             	add    $0x10,%esp
}
  8016d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016db:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e0:	8b 40 48             	mov    0x48(%eax),%eax
  8016e3:	83 ec 04             	sub    $0x4,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	50                   	push   %eax
  8016e8:	68 91 2a 80 00       	push   $0x802a91
  8016ed:	e8 1f ed ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fa:	eb da                	jmp    8016d6 <read+0x5a>
		return -E_NOT_SUPP;
  8016fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801701:	eb d3                	jmp    8016d6 <read+0x5a>

00801703 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	57                   	push   %edi
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	83 ec 0c             	sub    $0xc,%esp
  80170c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801712:	bb 00 00 00 00       	mov    $0x0,%ebx
  801717:	39 f3                	cmp    %esi,%ebx
  801719:	73 25                	jae    801740 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171b:	83 ec 04             	sub    $0x4,%esp
  80171e:	89 f0                	mov    %esi,%eax
  801720:	29 d8                	sub    %ebx,%eax
  801722:	50                   	push   %eax
  801723:	89 d8                	mov    %ebx,%eax
  801725:	03 45 0c             	add    0xc(%ebp),%eax
  801728:	50                   	push   %eax
  801729:	57                   	push   %edi
  80172a:	e8 4d ff ff ff       	call   80167c <read>
		if (m < 0)
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	85 c0                	test   %eax,%eax
  801734:	78 08                	js     80173e <readn+0x3b>
			return m;
		if (m == 0)
  801736:	85 c0                	test   %eax,%eax
  801738:	74 06                	je     801740 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80173a:	01 c3                	add    %eax,%ebx
  80173c:	eb d9                	jmp    801717 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801740:	89 d8                	mov    %ebx,%eax
  801742:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5f                   	pop    %edi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 14             	sub    $0x14,%esp
  801751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	53                   	push   %ebx
  801759:	e8 ad fc ff ff       	call   80140b <fd_lookup>
  80175e:	83 c4 08             	add    $0x8,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	78 3a                	js     80179f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176f:	ff 30                	pushl  (%eax)
  801771:	e8 eb fc ff ff       	call   801461 <dev_lookup>
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 22                	js     80179f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80177d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801780:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801784:	74 1e                	je     8017a4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801786:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801789:	8b 52 0c             	mov    0xc(%edx),%edx
  80178c:	85 d2                	test   %edx,%edx
  80178e:	74 35                	je     8017c5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801790:	83 ec 04             	sub    $0x4,%esp
  801793:	ff 75 10             	pushl  0x10(%ebp)
  801796:	ff 75 0c             	pushl  0xc(%ebp)
  801799:	50                   	push   %eax
  80179a:	ff d2                	call   *%edx
  80179c:	83 c4 10             	add    $0x10,%esp
}
  80179f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a9:	8b 40 48             	mov    0x48(%eax),%eax
  8017ac:	83 ec 04             	sub    $0x4,%esp
  8017af:	53                   	push   %ebx
  8017b0:	50                   	push   %eax
  8017b1:	68 ad 2a 80 00       	push   $0x802aad
  8017b6:	e8 56 ec ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c3:	eb da                	jmp    80179f <write+0x55>
		return -E_NOT_SUPP;
  8017c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ca:	eb d3                	jmp    80179f <write+0x55>

008017cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d5:	50                   	push   %eax
  8017d6:	ff 75 08             	pushl  0x8(%ebp)
  8017d9:	e8 2d fc ff ff       	call   80140b <fd_lookup>
  8017de:	83 c4 08             	add    $0x8,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 0e                	js     8017f3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f3:	c9                   	leave  
  8017f4:	c3                   	ret    

008017f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 14             	sub    $0x14,%esp
  8017fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801802:	50                   	push   %eax
  801803:	53                   	push   %ebx
  801804:	e8 02 fc ff ff       	call   80140b <fd_lookup>
  801809:	83 c4 08             	add    $0x8,%esp
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 37                	js     801847 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	ff 30                	pushl  (%eax)
  80181c:	e8 40 fc ff ff       	call   801461 <dev_lookup>
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	78 1f                	js     801847 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80182f:	74 1b                	je     80184c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801831:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801834:	8b 52 18             	mov    0x18(%edx),%edx
  801837:	85 d2                	test   %edx,%edx
  801839:	74 32                	je     80186d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80183b:	83 ec 08             	sub    $0x8,%esp
  80183e:	ff 75 0c             	pushl  0xc(%ebp)
  801841:	50                   	push   %eax
  801842:	ff d2                	call   *%edx
  801844:	83 c4 10             	add    $0x10,%esp
}
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80184c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801851:	8b 40 48             	mov    0x48(%eax),%eax
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	53                   	push   %ebx
  801858:	50                   	push   %eax
  801859:	68 70 2a 80 00       	push   $0x802a70
  80185e:	e8 ae eb ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80186b:	eb da                	jmp    801847 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80186d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801872:	eb d3                	jmp    801847 <ftruncate+0x52>

00801874 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	53                   	push   %ebx
  801878:	83 ec 14             	sub    $0x14,%esp
  80187b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	ff 75 08             	pushl  0x8(%ebp)
  801885:	e8 81 fb ff ff       	call   80140b <fd_lookup>
  80188a:	83 c4 08             	add    $0x8,%esp
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 4b                	js     8018dc <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189b:	ff 30                	pushl  (%eax)
  80189d:	e8 bf fb ff ff       	call   801461 <dev_lookup>
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	78 33                	js     8018dc <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8018a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018b0:	74 2f                	je     8018e1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018bc:	00 00 00 
	stat->st_isdir = 0;
  8018bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018c6:	00 00 00 
	stat->st_dev = dev;
  8018c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d6:	ff 50 14             	call   *0x14(%eax)
  8018d9:	83 c4 10             	add    $0x10,%esp
}
  8018dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    
		return -E_NOT_SUPP;
  8018e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018e6:	eb f4                	jmp    8018dc <fstat+0x68>

008018e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	6a 00                	push   $0x0
  8018f2:	ff 75 08             	pushl  0x8(%ebp)
  8018f5:	e8 e7 01 00 00       	call   801ae1 <open>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 1b                	js     80191e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	50                   	push   %eax
  80190a:	e8 65 ff ff ff       	call   801874 <fstat>
  80190f:	89 c6                	mov    %eax,%esi
	close(fd);
  801911:	89 1c 24             	mov    %ebx,(%esp)
  801914:	e8 27 fc ff ff       	call   801540 <close>
	return r;
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	89 f3                	mov    %esi,%ebx
}
  80191e:	89 d8                	mov    %ebx,%eax
  801920:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801923:	5b                   	pop    %ebx
  801924:	5e                   	pop    %esi
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	89 c6                	mov    %eax,%esi
  80192e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801930:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801937:	74 27                	je     801960 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801939:	6a 07                	push   $0x7
  80193b:	68 00 50 80 00       	push   $0x805000
  801940:	56                   	push   %esi
  801941:	ff 35 00 40 80 00    	pushl  0x804000
  801947:	e8 08 08 00 00       	call   802154 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80194c:	83 c4 0c             	add    $0xc,%esp
  80194f:	6a 00                	push   $0x0
  801951:	53                   	push   %ebx
  801952:	6a 00                	push   $0x0
  801954:	e8 9a 07 00 00       	call   8020f3 <ipc_recv>
}
  801959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195c:	5b                   	pop    %ebx
  80195d:	5e                   	pop    %esi
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	6a 01                	push   $0x1
  801965:	e8 37 08 00 00       	call   8021a1 <ipc_find_env>
  80196a:	a3 00 40 80 00       	mov    %eax,0x804000
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	eb c5                	jmp    801939 <fsipc+0x12>

00801974 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80197a:	8b 45 08             	mov    0x8(%ebp),%eax
  80197d:	8b 40 0c             	mov    0xc(%eax),%eax
  801980:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801985:	8b 45 0c             	mov    0xc(%ebp),%eax
  801988:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 02 00 00 00       	mov    $0x2,%eax
  801997:	e8 8b ff ff ff       	call   801927 <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_flush>:
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8019aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b9:	e8 69 ff ff ff       	call   801927 <fsipc>
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devfile_stat>:
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 04             	sub    $0x4,%esp
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 05 00 00 00       	mov    $0x5,%eax
  8019df:	e8 43 ff ff ff       	call   801927 <fsipc>
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 2c                	js     801a14 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	68 00 50 80 00       	push   $0x805000
  8019f0:	53                   	push   %ebx
  8019f1:	e8 3a f0 ff ff       	call   800a30 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8019fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a01:	a1 84 50 80 00       	mov    0x805084,%eax
  801a06:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <devfile_write>:
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801a22:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a27:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a2c:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a2f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a32:	8b 52 0c             	mov    0xc(%edx),%edx
  801a35:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801a3b:	a3 04 50 80 00       	mov    %eax,0x805004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801a40:	50                   	push   %eax
  801a41:	ff 75 0c             	pushl  0xc(%ebp)
  801a44:	68 08 50 80 00       	push   $0x805008
  801a49:	e8 70 f1 ff ff       	call   800bbe <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801a4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a53:	b8 04 00 00 00       	mov    $0x4,%eax
  801a58:	e8 ca fe ff ff       	call   801927 <fsipc>
}
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <devfile_read>:
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	56                   	push   %esi
  801a63:	53                   	push   %ebx
  801a64:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a72:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a78:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7d:	b8 03 00 00 00       	mov    $0x3,%eax
  801a82:	e8 a0 fe ff ff       	call   801927 <fsipc>
  801a87:	89 c3                	mov    %eax,%ebx
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 1f                	js     801aac <devfile_read+0x4d>
	assert(r <= n);
  801a8d:	39 f0                	cmp    %esi,%eax
  801a8f:	77 24                	ja     801ab5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a91:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a96:	7f 33                	jg     801acb <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	50                   	push   %eax
  801a9c:	68 00 50 80 00       	push   $0x805000
  801aa1:	ff 75 0c             	pushl  0xc(%ebp)
  801aa4:	e8 15 f1 ff ff       	call   800bbe <memmove>
	return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
}
  801aac:	89 d8                	mov    %ebx,%eax
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    
	assert(r <= n);
  801ab5:	68 dc 2a 80 00       	push   $0x802adc
  801aba:	68 e3 2a 80 00       	push   $0x802ae3
  801abf:	6a 7d                	push   $0x7d
  801ac1:	68 f8 2a 80 00       	push   $0x802af8
  801ac6:	e8 6b e8 ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  801acb:	68 03 2b 80 00       	push   $0x802b03
  801ad0:	68 e3 2a 80 00       	push   $0x802ae3
  801ad5:	6a 7e                	push   $0x7e
  801ad7:	68 f8 2a 80 00       	push   $0x802af8
  801adc:	e8 55 e8 ff ff       	call   800336 <_panic>

00801ae1 <open>:
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 1c             	sub    $0x1c,%esp
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801aec:	56                   	push   %esi
  801aed:	e8 07 ef ff ff       	call   8009f9 <strlen>
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801afa:	0f 8f 96 00 00 00    	jg     801b96 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	e8 b0 f8 ff ff       	call   8013bc <fd_alloc>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 66                	js     801b7b <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801b15:	83 ec 08             	sub    $0x8,%esp
  801b18:	56                   	push   %esi
  801b19:	68 00 50 80 00       	push   $0x805000
  801b1e:	e8 0d ef ff ff       	call   800a30 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b26:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801b33:	e8 ef fd ff ff       	call   801927 <fsipc>
  801b38:	89 c3                	mov    %eax,%ebx
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 43                	js     801b84 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 f4             	pushl  -0xc(%ebp)
  801b47:	e8 49 f8 ff ff       	call   801395 <fd2num>
  801b4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b4f:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801b55:	8b 49 48             	mov    0x48(%ecx),%ecx
  801b58:	83 c4 08             	add    $0x8,%esp
  801b5b:	50                   	push   %eax
  801b5c:	52                   	push   %edx
  801b5d:	ff 32                	pushl  (%edx)
  801b5f:	56                   	push   %esi
  801b60:	51                   	push   %ecx
  801b61:	68 10 2b 80 00       	push   $0x802b10
  801b66:	e8 a6 e8 ff ff       	call   800411 <cprintf>
	return fd2num(fd);
  801b6b:	83 c4 14             	add    $0x14,%esp
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	e8 1f f8 ff ff       	call   801395 <fd2num>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 10             	add    $0x10,%esp
}
  801b7b:	89 d8                	mov    %ebx,%eax
  801b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    
		fd_close(fd, 0);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	6a 00                	push   $0x0
  801b89:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8c:	e8 26 f9 ff ff       	call   8014b7 <fd_close>
		return r;
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	eb e5                	jmp    801b7b <open+0x9a>
		return -E_BAD_PATH;
  801b96:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b9b:	eb de                	jmp    801b7b <open+0x9a>

00801b9d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba8:	b8 08 00 00 00       	mov    $0x8,%eax
  801bad:	e8 75 fd ff ff       	call   801927 <fsipc>
}
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	56                   	push   %esi
  801bb8:	53                   	push   %ebx
  801bb9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bbc:	83 ec 0c             	sub    $0xc,%esp
  801bbf:	ff 75 08             	pushl  0x8(%ebp)
  801bc2:	e8 de f7 ff ff       	call   8013a5 <fd2data>
  801bc7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bc9:	83 c4 08             	add    $0x8,%esp
  801bcc:	68 50 2b 80 00       	push   $0x802b50
  801bd1:	53                   	push   %ebx
  801bd2:	e8 59 ee ff ff       	call   800a30 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bd7:	8b 46 04             	mov    0x4(%esi),%eax
  801bda:	2b 06                	sub    (%esi),%eax
  801bdc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801be2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be9:	00 00 00 
	stat->st_dev = &devpipe;
  801bec:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801bf3:	30 80 00 
	return 0;
}
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	53                   	push   %ebx
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c0c:	53                   	push   %ebx
  801c0d:	6a 00                	push   $0x0
  801c0f:	e8 9a f2 ff ff       	call   800eae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c14:	89 1c 24             	mov    %ebx,(%esp)
  801c17:	e8 89 f7 ff ff       	call   8013a5 <fd2data>
  801c1c:	83 c4 08             	add    $0x8,%esp
  801c1f:	50                   	push   %eax
  801c20:	6a 00                	push   $0x0
  801c22:	e8 87 f2 ff ff       	call   800eae <sys_page_unmap>
}
  801c27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <_pipeisclosed>:
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	57                   	push   %edi
  801c30:	56                   	push   %esi
  801c31:	53                   	push   %ebx
  801c32:	83 ec 1c             	sub    $0x1c,%esp
  801c35:	89 c7                	mov    %eax,%edi
  801c37:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c39:	a1 04 40 80 00       	mov    0x804004,%eax
  801c3e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	57                   	push   %edi
  801c45:	e8 90 05 00 00       	call   8021da <pageref>
  801c4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c4d:	89 34 24             	mov    %esi,(%esp)
  801c50:	e8 85 05 00 00       	call   8021da <pageref>
		nn = thisenv->env_runs;
  801c55:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c5b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c5e:	83 c4 10             	add    $0x10,%esp
  801c61:	39 cb                	cmp    %ecx,%ebx
  801c63:	74 1b                	je     801c80 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c65:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c68:	75 cf                	jne    801c39 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c6a:	8b 42 58             	mov    0x58(%edx),%eax
  801c6d:	6a 01                	push   $0x1
  801c6f:	50                   	push   %eax
  801c70:	53                   	push   %ebx
  801c71:	68 57 2b 80 00       	push   $0x802b57
  801c76:	e8 96 e7 ff ff       	call   800411 <cprintf>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	eb b9                	jmp    801c39 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c83:	0f 94 c0             	sete   %al
  801c86:	0f b6 c0             	movzbl %al,%eax
}
  801c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devpipe_write>:
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	57                   	push   %edi
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	83 ec 28             	sub    $0x28,%esp
  801c9a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c9d:	56                   	push   %esi
  801c9e:	e8 02 f7 ff ff       	call   8013a5 <fd2data>
  801ca3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cad:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb0:	74 4f                	je     801d01 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cb2:	8b 43 04             	mov    0x4(%ebx),%eax
  801cb5:	8b 0b                	mov    (%ebx),%ecx
  801cb7:	8d 51 20             	lea    0x20(%ecx),%edx
  801cba:	39 d0                	cmp    %edx,%eax
  801cbc:	72 14                	jb     801cd2 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801cbe:	89 da                	mov    %ebx,%edx
  801cc0:	89 f0                	mov    %esi,%eax
  801cc2:	e8 65 ff ff ff       	call   801c2c <_pipeisclosed>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	75 3a                	jne    801d05 <devpipe_write+0x74>
			sys_yield();
  801ccb:	e8 3a f1 ff ff       	call   800e0a <sys_yield>
  801cd0:	eb e0                	jmp    801cb2 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cd9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cdc:	89 c2                	mov    %eax,%edx
  801cde:	c1 fa 1f             	sar    $0x1f,%edx
  801ce1:	89 d1                	mov    %edx,%ecx
  801ce3:	c1 e9 1b             	shr    $0x1b,%ecx
  801ce6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ce9:	83 e2 1f             	and    $0x1f,%edx
  801cec:	29 ca                	sub    %ecx,%edx
  801cee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cf2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cf6:	83 c0 01             	add    $0x1,%eax
  801cf9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cfc:	83 c7 01             	add    $0x1,%edi
  801cff:	eb ac                	jmp    801cad <devpipe_write+0x1c>
	return i;
  801d01:	89 f8                	mov    %edi,%eax
  801d03:	eb 05                	jmp    801d0a <devpipe_write+0x79>
				return 0;
  801d05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <devpipe_read>:
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 18             	sub    $0x18,%esp
  801d1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d1e:	57                   	push   %edi
  801d1f:	e8 81 f6 ff ff       	call   8013a5 <fd2data>
  801d24:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	be 00 00 00 00       	mov    $0x0,%esi
  801d2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d31:	74 47                	je     801d7a <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801d33:	8b 03                	mov    (%ebx),%eax
  801d35:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d38:	75 22                	jne    801d5c <devpipe_read+0x4a>
			if (i > 0)
  801d3a:	85 f6                	test   %esi,%esi
  801d3c:	75 14                	jne    801d52 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801d3e:	89 da                	mov    %ebx,%edx
  801d40:	89 f8                	mov    %edi,%eax
  801d42:	e8 e5 fe ff ff       	call   801c2c <_pipeisclosed>
  801d47:	85 c0                	test   %eax,%eax
  801d49:	75 33                	jne    801d7e <devpipe_read+0x6c>
			sys_yield();
  801d4b:	e8 ba f0 ff ff       	call   800e0a <sys_yield>
  801d50:	eb e1                	jmp    801d33 <devpipe_read+0x21>
				return i;
  801d52:	89 f0                	mov    %esi,%eax
}
  801d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d5c:	99                   	cltd   
  801d5d:	c1 ea 1b             	shr    $0x1b,%edx
  801d60:	01 d0                	add    %edx,%eax
  801d62:	83 e0 1f             	and    $0x1f,%eax
  801d65:	29 d0                	sub    %edx,%eax
  801d67:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d6f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d72:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d75:	83 c6 01             	add    $0x1,%esi
  801d78:	eb b4                	jmp    801d2e <devpipe_read+0x1c>
	return i;
  801d7a:	89 f0                	mov    %esi,%eax
  801d7c:	eb d6                	jmp    801d54 <devpipe_read+0x42>
				return 0;
  801d7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d83:	eb cf                	jmp    801d54 <devpipe_read+0x42>

00801d85 <pipe>:
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d90:	50                   	push   %eax
  801d91:	e8 26 f6 ff ff       	call   8013bc <fd_alloc>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	83 c4 10             	add    $0x10,%esp
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 5b                	js     801dfa <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9f:	83 ec 04             	sub    $0x4,%esp
  801da2:	68 07 04 00 00       	push   $0x407
  801da7:	ff 75 f4             	pushl  -0xc(%ebp)
  801daa:	6a 00                	push   $0x0
  801dac:	e8 78 f0 ff ff       	call   800e29 <sys_page_alloc>
  801db1:	89 c3                	mov    %eax,%ebx
  801db3:	83 c4 10             	add    $0x10,%esp
  801db6:	85 c0                	test   %eax,%eax
  801db8:	78 40                	js     801dfa <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801dba:	83 ec 0c             	sub    $0xc,%esp
  801dbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	e8 f6 f5 ff ff       	call   8013bc <fd_alloc>
  801dc6:	89 c3                	mov    %eax,%ebx
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 1b                	js     801dea <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcf:	83 ec 04             	sub    $0x4,%esp
  801dd2:	68 07 04 00 00       	push   $0x407
  801dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801dda:	6a 00                	push   $0x0
  801ddc:	e8 48 f0 ff ff       	call   800e29 <sys_page_alloc>
  801de1:	89 c3                	mov    %eax,%ebx
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	85 c0                	test   %eax,%eax
  801de8:	79 19                	jns    801e03 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801dea:	83 ec 08             	sub    $0x8,%esp
  801ded:	ff 75 f4             	pushl  -0xc(%ebp)
  801df0:	6a 00                	push   $0x0
  801df2:	e8 b7 f0 ff ff       	call   800eae <sys_page_unmap>
  801df7:	83 c4 10             	add    $0x10,%esp
}
  801dfa:	89 d8                	mov    %ebx,%eax
  801dfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
	va = fd2data(fd0);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	ff 75 f4             	pushl  -0xc(%ebp)
  801e09:	e8 97 f5 ff ff       	call   8013a5 <fd2data>
  801e0e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e10:	83 c4 0c             	add    $0xc,%esp
  801e13:	68 07 04 00 00       	push   $0x407
  801e18:	50                   	push   %eax
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 09 f0 ff ff       	call   800e29 <sys_page_alloc>
  801e20:	89 c3                	mov    %eax,%ebx
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	85 c0                	test   %eax,%eax
  801e27:	0f 88 8c 00 00 00    	js     801eb9 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	ff 75 f0             	pushl  -0x10(%ebp)
  801e33:	e8 6d f5 ff ff       	call   8013a5 <fd2data>
  801e38:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e3f:	50                   	push   %eax
  801e40:	6a 00                	push   $0x0
  801e42:	56                   	push   %esi
  801e43:	6a 00                	push   $0x0
  801e45:	e8 22 f0 ff ff       	call   800e6c <sys_page_map>
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	83 c4 20             	add    $0x20,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 58                	js     801eab <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e5c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e61:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e6b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e71:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e76:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e7d:	83 ec 0c             	sub    $0xc,%esp
  801e80:	ff 75 f4             	pushl  -0xc(%ebp)
  801e83:	e8 0d f5 ff ff       	call   801395 <fd2num>
  801e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e8b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e8d:	83 c4 04             	add    $0x4,%esp
  801e90:	ff 75 f0             	pushl  -0x10(%ebp)
  801e93:	e8 fd f4 ff ff       	call   801395 <fd2num>
  801e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ea6:	e9 4f ff ff ff       	jmp    801dfa <pipe+0x75>
	sys_page_unmap(0, va);
  801eab:	83 ec 08             	sub    $0x8,%esp
  801eae:	56                   	push   %esi
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 f8 ef ff ff       	call   800eae <sys_page_unmap>
  801eb6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801eb9:	83 ec 08             	sub    $0x8,%esp
  801ebc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebf:	6a 00                	push   $0x0
  801ec1:	e8 e8 ef ff ff       	call   800eae <sys_page_unmap>
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	e9 1c ff ff ff       	jmp    801dea <pipe+0x65>

00801ece <pipeisclosed>:
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	ff 75 08             	pushl  0x8(%ebp)
  801edb:	e8 2b f5 ff ff       	call   80140b <fd_lookup>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 18                	js     801eff <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ee7:	83 ec 0c             	sub    $0xc,%esp
  801eea:	ff 75 f4             	pushl  -0xc(%ebp)
  801eed:	e8 b3 f4 ff ff       	call   8013a5 <fd2data>
	return _pipeisclosed(fd, p);
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	e8 30 fd ff ff       	call   801c2c <_pipeisclosed>
  801efc:	83 c4 10             	add    $0x10,%esp
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	56                   	push   %esi
  801f05:	53                   	push   %ebx
  801f06:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f09:	85 f6                	test   %esi,%esi
  801f0b:	74 13                	je     801f20 <wait+0x1f>
	e = &envs[ENVX(envid)];
  801f0d:	89 f3                	mov    %esi,%ebx
  801f0f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f15:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801f18:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801f1e:	eb 1b                	jmp    801f3b <wait+0x3a>
	assert(envid != 0);
  801f20:	68 6f 2b 80 00       	push   $0x802b6f
  801f25:	68 e3 2a 80 00       	push   $0x802ae3
  801f2a:	6a 09                	push   $0x9
  801f2c:	68 7a 2b 80 00       	push   $0x802b7a
  801f31:	e8 00 e4 ff ff       	call   800336 <_panic>
		sys_yield();
  801f36:	e8 cf ee ff ff       	call   800e0a <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f3b:	8b 43 48             	mov    0x48(%ebx),%eax
  801f3e:	39 f0                	cmp    %esi,%eax
  801f40:	75 07                	jne    801f49 <wait+0x48>
  801f42:	8b 43 54             	mov    0x54(%ebx),%eax
  801f45:	85 c0                	test   %eax,%eax
  801f47:	75 ed                	jne    801f36 <wait+0x35>
}
  801f49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
  801f58:	5d                   	pop    %ebp
  801f59:	c3                   	ret    

00801f5a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f60:	68 85 2b 80 00       	push   $0x802b85
  801f65:	ff 75 0c             	pushl  0xc(%ebp)
  801f68:	e8 c3 ea ff ff       	call   800a30 <strcpy>
	return 0;
}
  801f6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f72:	c9                   	leave  
  801f73:	c3                   	ret    

00801f74 <devcons_write>:
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f80:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f85:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f8b:	eb 2f                	jmp    801fbc <devcons_write+0x48>
		m = n - tot;
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f90:	29 f3                	sub    %esi,%ebx
  801f92:	83 fb 7f             	cmp    $0x7f,%ebx
  801f95:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f9a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f9d:	83 ec 04             	sub    $0x4,%esp
  801fa0:	53                   	push   %ebx
  801fa1:	89 f0                	mov    %esi,%eax
  801fa3:	03 45 0c             	add    0xc(%ebp),%eax
  801fa6:	50                   	push   %eax
  801fa7:	57                   	push   %edi
  801fa8:	e8 11 ec ff ff       	call   800bbe <memmove>
		sys_cputs(buf, m);
  801fad:	83 c4 08             	add    $0x8,%esp
  801fb0:	53                   	push   %ebx
  801fb1:	57                   	push   %edi
  801fb2:	e8 b6 ed ff ff       	call   800d6d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fb7:	01 de                	add    %ebx,%esi
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fbf:	72 cc                	jb     801f8d <devcons_write+0x19>
}
  801fc1:	89 f0                	mov    %esi,%eax
  801fc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc6:	5b                   	pop    %ebx
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    

00801fcb <devcons_read>:
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 08             	sub    $0x8,%esp
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fda:	75 07                	jne    801fe3 <devcons_read+0x18>
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    
		sys_yield();
  801fde:	e8 27 ee ff ff       	call   800e0a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801fe3:	e8 a3 ed ff ff       	call   800d8b <sys_cgetc>
  801fe8:	85 c0                	test   %eax,%eax
  801fea:	74 f2                	je     801fde <devcons_read+0x13>
	if (c < 0)
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 ec                	js     801fdc <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801ff0:	83 f8 04             	cmp    $0x4,%eax
  801ff3:	74 0c                	je     802001 <devcons_read+0x36>
	*(char*)vbuf = c;
  801ff5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff8:	88 02                	mov    %al,(%edx)
	return 1;
  801ffa:	b8 01 00 00 00       	mov    $0x1,%eax
  801fff:	eb db                	jmp    801fdc <devcons_read+0x11>
		return 0;
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
  802006:	eb d4                	jmp    801fdc <devcons_read+0x11>

00802008 <cputchar>:
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802014:	6a 01                	push   $0x1
  802016:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802019:	50                   	push   %eax
  80201a:	e8 4e ed ff ff       	call   800d6d <sys_cputs>
}
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <getchar>:
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80202a:	6a 01                	push   $0x1
  80202c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80202f:	50                   	push   %eax
  802030:	6a 00                	push   $0x0
  802032:	e8 45 f6 ff ff       	call   80167c <read>
	if (r < 0)
  802037:	83 c4 10             	add    $0x10,%esp
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 08                	js     802046 <getchar+0x22>
	if (r < 1)
  80203e:	85 c0                	test   %eax,%eax
  802040:	7e 06                	jle    802048 <getchar+0x24>
	return c;
  802042:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    
		return -E_EOF;
  802048:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80204d:	eb f7                	jmp    802046 <getchar+0x22>

0080204f <iscons>:
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802055:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802058:	50                   	push   %eax
  802059:	ff 75 08             	pushl  0x8(%ebp)
  80205c:	e8 aa f3 ff ff       	call   80140b <fd_lookup>
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	85 c0                	test   %eax,%eax
  802066:	78 11                	js     802079 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802071:	39 10                	cmp    %edx,(%eax)
  802073:	0f 94 c0             	sete   %al
  802076:	0f b6 c0             	movzbl %al,%eax
}
  802079:	c9                   	leave  
  80207a:	c3                   	ret    

0080207b <opencons>:
{
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802081:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802084:	50                   	push   %eax
  802085:	e8 32 f3 ff ff       	call   8013bc <fd_alloc>
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 3a                	js     8020cb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802091:	83 ec 04             	sub    $0x4,%esp
  802094:	68 07 04 00 00       	push   $0x407
  802099:	ff 75 f4             	pushl  -0xc(%ebp)
  80209c:	6a 00                	push   $0x0
  80209e:	e8 86 ed ff ff       	call   800e29 <sys_page_alloc>
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 21                	js     8020cb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8020aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ad:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020b3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020bf:	83 ec 0c             	sub    $0xc,%esp
  8020c2:	50                   	push   %eax
  8020c3:	e8 cd f2 ff ff       	call   801395 <fd2num>
  8020c8:	83 c4 10             	add    $0x10,%esp
}
  8020cb:	c9                   	leave  
  8020cc:	c3                   	ret    

008020cd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020cd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ce:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  8020d3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020d5:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  8020d8:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  8020db:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  8020df:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  8020e3:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  8020e6:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  8020ea:	89 18                	mov    %ebx,(%eax)

    popal
  8020ec:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  8020ed:	83 c4 04             	add    $0x4,%esp
    popfl
  8020f0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  8020f1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8020f2:	c3                   	ret    

008020f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  802101:	85 c0                	test   %eax,%eax
  802103:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802108:	0f 44 c2             	cmove  %edx,%eax
  80210b:	83 ec 0c             	sub    $0xc,%esp
  80210e:	50                   	push   %eax
  80210f:	e8 c5 ee ff ff       	call   800fd9 <sys_ipc_recv>
  802114:	83 c4 10             	add    $0x10,%esp
  802117:	85 c0                	test   %eax,%eax
  802119:	78 2b                	js     802146 <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  80211b:	85 f6                	test   %esi,%esi
  80211d:	74 0a                	je     802129 <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  80211f:	a1 04 40 80 00       	mov    0x804004,%eax
  802124:	8b 40 74             	mov    0x74(%eax),%eax
  802127:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  802129:	85 db                	test   %ebx,%ebx
  80212b:	74 0a                	je     802137 <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  80212d:	a1 04 40 80 00       	mov    0x804004,%eax
  802132:	8b 40 78             	mov    0x78(%eax),%eax
  802135:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  802137:	a1 04 40 80 00       	mov    0x804004,%eax
  80213c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80213f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802142:	5b                   	pop    %ebx
  802143:	5e                   	pop    %esi
  802144:	5d                   	pop    %ebp
  802145:	c3                   	ret    
        *from_env_store = 0;
  802146:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  80214c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802152:	eb eb                	jmp    80213f <ipc_recv+0x4c>

00802154 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	57                   	push   %edi
  802158:	56                   	push   %esi
  802159:	53                   	push   %ebx
  80215a:	83 ec 0c             	sub    $0xc,%esp
  80215d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802160:	8b 75 0c             	mov    0xc(%ebp),%esi
  802163:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  802166:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  802168:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80216d:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802170:	ff 75 14             	pushl  0x14(%ebp)
  802173:	53                   	push   %ebx
  802174:	56                   	push   %esi
  802175:	57                   	push   %edi
  802176:	e8 3b ee ff ff       	call   800fb6 <sys_ipc_try_send>
  80217b:	83 c4 10             	add    $0x10,%esp
  80217e:	85 c0                	test   %eax,%eax
  802180:	74 17                	je     802199 <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802182:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802185:	74 e9                	je     802170 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  802187:	50                   	push   %eax
  802188:	68 91 2b 80 00       	push   $0x802b91
  80218d:	6a 3e                	push   $0x3e
  80218f:	68 a3 2b 80 00       	push   $0x802ba3
  802194:	e8 9d e1 ff ff       	call   800336 <_panic>
        }
    }
}
  802199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219c:	5b                   	pop    %ebx
  80219d:	5e                   	pop    %esi
  80219e:	5f                   	pop    %edi
  80219f:	5d                   	pop    %ebp
  8021a0:	c3                   	ret    

008021a1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021b5:	8b 52 50             	mov    0x50(%edx),%edx
  8021b8:	39 ca                	cmp    %ecx,%edx
  8021ba:	74 11                	je     8021cd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8021bc:	83 c0 01             	add    $0x1,%eax
  8021bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021c4:	75 e6                	jne    8021ac <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8021c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cb:	eb 0b                	jmp    8021d8 <ipc_find_env+0x37>
			return envs[i].env_id;
  8021cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021d5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    

008021da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021da:	55                   	push   %ebp
  8021db:	89 e5                	mov    %esp,%ebp
  8021dd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e0:	89 d0                	mov    %edx,%eax
  8021e2:	c1 e8 16             	shr    $0x16,%eax
  8021e5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021f1:	f6 c1 01             	test   $0x1,%cl
  8021f4:	74 1d                	je     802213 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021f6:	c1 ea 0c             	shr    $0xc,%edx
  8021f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802200:	f6 c2 01             	test   $0x1,%dl
  802203:	74 0e                	je     802213 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802205:	c1 ea 0c             	shr    $0xc,%edx
  802208:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80220f:	ef 
  802210:	0f b7 c0             	movzwl %ax,%eax
}
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    
  802215:	66 90                	xchg   %ax,%ax
  802217:	66 90                	xchg   %ax,%ax
  802219:	66 90                	xchg   %ax,%ax
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802237:	85 d2                	test   %edx,%edx
  802239:	75 35                	jne    802270 <__udivdi3+0x50>
  80223b:	39 f3                	cmp    %esi,%ebx
  80223d:	0f 87 bd 00 00 00    	ja     802300 <__udivdi3+0xe0>
  802243:	85 db                	test   %ebx,%ebx
  802245:	89 d9                	mov    %ebx,%ecx
  802247:	75 0b                	jne    802254 <__udivdi3+0x34>
  802249:	b8 01 00 00 00       	mov    $0x1,%eax
  80224e:	31 d2                	xor    %edx,%edx
  802250:	f7 f3                	div    %ebx
  802252:	89 c1                	mov    %eax,%ecx
  802254:	31 d2                	xor    %edx,%edx
  802256:	89 f0                	mov    %esi,%eax
  802258:	f7 f1                	div    %ecx
  80225a:	89 c6                	mov    %eax,%esi
  80225c:	89 e8                	mov    %ebp,%eax
  80225e:	89 f7                	mov    %esi,%edi
  802260:	f7 f1                	div    %ecx
  802262:	89 fa                	mov    %edi,%edx
  802264:	83 c4 1c             	add    $0x1c,%esp
  802267:	5b                   	pop    %ebx
  802268:	5e                   	pop    %esi
  802269:	5f                   	pop    %edi
  80226a:	5d                   	pop    %ebp
  80226b:	c3                   	ret    
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	39 f2                	cmp    %esi,%edx
  802272:	77 7c                	ja     8022f0 <__udivdi3+0xd0>
  802274:	0f bd fa             	bsr    %edx,%edi
  802277:	83 f7 1f             	xor    $0x1f,%edi
  80227a:	0f 84 98 00 00 00    	je     802318 <__udivdi3+0xf8>
  802280:	89 f9                	mov    %edi,%ecx
  802282:	b8 20 00 00 00       	mov    $0x20,%eax
  802287:	29 f8                	sub    %edi,%eax
  802289:	d3 e2                	shl    %cl,%edx
  80228b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80228f:	89 c1                	mov    %eax,%ecx
  802291:	89 da                	mov    %ebx,%edx
  802293:	d3 ea                	shr    %cl,%edx
  802295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802299:	09 d1                	or     %edx,%ecx
  80229b:	89 f2                	mov    %esi,%edx
  80229d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e3                	shl    %cl,%ebx
  8022a5:	89 c1                	mov    %eax,%ecx
  8022a7:	d3 ea                	shr    %cl,%edx
  8022a9:	89 f9                	mov    %edi,%ecx
  8022ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022af:	d3 e6                	shl    %cl,%esi
  8022b1:	89 eb                	mov    %ebp,%ebx
  8022b3:	89 c1                	mov    %eax,%ecx
  8022b5:	d3 eb                	shr    %cl,%ebx
  8022b7:	09 de                	or     %ebx,%esi
  8022b9:	89 f0                	mov    %esi,%eax
  8022bb:	f7 74 24 08          	divl   0x8(%esp)
  8022bf:	89 d6                	mov    %edx,%esi
  8022c1:	89 c3                	mov    %eax,%ebx
  8022c3:	f7 64 24 0c          	mull   0xc(%esp)
  8022c7:	39 d6                	cmp    %edx,%esi
  8022c9:	72 0c                	jb     8022d7 <__udivdi3+0xb7>
  8022cb:	89 f9                	mov    %edi,%ecx
  8022cd:	d3 e5                	shl    %cl,%ebp
  8022cf:	39 c5                	cmp    %eax,%ebp
  8022d1:	73 5d                	jae    802330 <__udivdi3+0x110>
  8022d3:	39 d6                	cmp    %edx,%esi
  8022d5:	75 59                	jne    802330 <__udivdi3+0x110>
  8022d7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022da:	31 ff                	xor    %edi,%edi
  8022dc:	89 fa                	mov    %edi,%edx
  8022de:	83 c4 1c             	add    $0x1c,%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5f                   	pop    %edi
  8022e4:	5d                   	pop    %ebp
  8022e5:	c3                   	ret    
  8022e6:	8d 76 00             	lea    0x0(%esi),%esi
  8022e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022f0:	31 ff                	xor    %edi,%edi
  8022f2:	31 c0                	xor    %eax,%eax
  8022f4:	89 fa                	mov    %edi,%edx
  8022f6:	83 c4 1c             	add    $0x1c,%esp
  8022f9:	5b                   	pop    %ebx
  8022fa:	5e                   	pop    %esi
  8022fb:	5f                   	pop    %edi
  8022fc:	5d                   	pop    %ebp
  8022fd:	c3                   	ret    
  8022fe:	66 90                	xchg   %ax,%ax
  802300:	31 ff                	xor    %edi,%edi
  802302:	89 e8                	mov    %ebp,%eax
  802304:	89 f2                	mov    %esi,%edx
  802306:	f7 f3                	div    %ebx
  802308:	89 fa                	mov    %edi,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	72 06                	jb     802322 <__udivdi3+0x102>
  80231c:	31 c0                	xor    %eax,%eax
  80231e:	39 eb                	cmp    %ebp,%ebx
  802320:	77 d2                	ja     8022f4 <__udivdi3+0xd4>
  802322:	b8 01 00 00 00       	mov    $0x1,%eax
  802327:	eb cb                	jmp    8022f4 <__udivdi3+0xd4>
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d8                	mov    %ebx,%eax
  802332:	31 ff                	xor    %edi,%edi
  802334:	eb be                	jmp    8022f4 <__udivdi3+0xd4>
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80234b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80234f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 ed                	test   %ebp,%ebp
  802359:	89 f0                	mov    %esi,%eax
  80235b:	89 da                	mov    %ebx,%edx
  80235d:	75 19                	jne    802378 <__umoddi3+0x38>
  80235f:	39 df                	cmp    %ebx,%edi
  802361:	0f 86 b1 00 00 00    	jbe    802418 <__umoddi3+0xd8>
  802367:	f7 f7                	div    %edi
  802369:	89 d0                	mov    %edx,%eax
  80236b:	31 d2                	xor    %edx,%edx
  80236d:	83 c4 1c             	add    $0x1c,%esp
  802370:	5b                   	pop    %ebx
  802371:	5e                   	pop    %esi
  802372:	5f                   	pop    %edi
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    
  802375:	8d 76 00             	lea    0x0(%esi),%esi
  802378:	39 dd                	cmp    %ebx,%ebp
  80237a:	77 f1                	ja     80236d <__umoddi3+0x2d>
  80237c:	0f bd cd             	bsr    %ebp,%ecx
  80237f:	83 f1 1f             	xor    $0x1f,%ecx
  802382:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802386:	0f 84 b4 00 00 00    	je     802440 <__umoddi3+0x100>
  80238c:	b8 20 00 00 00       	mov    $0x20,%eax
  802391:	89 c2                	mov    %eax,%edx
  802393:	8b 44 24 04          	mov    0x4(%esp),%eax
  802397:	29 c2                	sub    %eax,%edx
  802399:	89 c1                	mov    %eax,%ecx
  80239b:	89 f8                	mov    %edi,%eax
  80239d:	d3 e5                	shl    %cl,%ebp
  80239f:	89 d1                	mov    %edx,%ecx
  8023a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023a5:	d3 e8                	shr    %cl,%eax
  8023a7:	09 c5                	or     %eax,%ebp
  8023a9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023ad:	89 c1                	mov    %eax,%ecx
  8023af:	d3 e7                	shl    %cl,%edi
  8023b1:	89 d1                	mov    %edx,%ecx
  8023b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8023b7:	89 df                	mov    %ebx,%edi
  8023b9:	d3 ef                	shr    %cl,%edi
  8023bb:	89 c1                	mov    %eax,%ecx
  8023bd:	89 f0                	mov    %esi,%eax
  8023bf:	d3 e3                	shl    %cl,%ebx
  8023c1:	89 d1                	mov    %edx,%ecx
  8023c3:	89 fa                	mov    %edi,%edx
  8023c5:	d3 e8                	shr    %cl,%eax
  8023c7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023cc:	09 d8                	or     %ebx,%eax
  8023ce:	f7 f5                	div    %ebp
  8023d0:	d3 e6                	shl    %cl,%esi
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	f7 64 24 08          	mull   0x8(%esp)
  8023d8:	39 d1                	cmp    %edx,%ecx
  8023da:	89 c3                	mov    %eax,%ebx
  8023dc:	89 d7                	mov    %edx,%edi
  8023de:	72 06                	jb     8023e6 <__umoddi3+0xa6>
  8023e0:	75 0e                	jne    8023f0 <__umoddi3+0xb0>
  8023e2:	39 c6                	cmp    %eax,%esi
  8023e4:	73 0a                	jae    8023f0 <__umoddi3+0xb0>
  8023e6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8023ea:	19 ea                	sbb    %ebp,%edx
  8023ec:	89 d7                	mov    %edx,%edi
  8023ee:	89 c3                	mov    %eax,%ebx
  8023f0:	89 ca                	mov    %ecx,%edx
  8023f2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8023f7:	29 de                	sub    %ebx,%esi
  8023f9:	19 fa                	sbb    %edi,%edx
  8023fb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8023ff:	89 d0                	mov    %edx,%eax
  802401:	d3 e0                	shl    %cl,%eax
  802403:	89 d9                	mov    %ebx,%ecx
  802405:	d3 ee                	shr    %cl,%esi
  802407:	d3 ea                	shr    %cl,%edx
  802409:	09 f0                	or     %esi,%eax
  80240b:	83 c4 1c             	add    $0x1c,%esp
  80240e:	5b                   	pop    %ebx
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    
  802413:	90                   	nop
  802414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802418:	85 ff                	test   %edi,%edi
  80241a:	89 f9                	mov    %edi,%ecx
  80241c:	75 0b                	jne    802429 <__umoddi3+0xe9>
  80241e:	b8 01 00 00 00       	mov    $0x1,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f7                	div    %edi
  802427:	89 c1                	mov    %eax,%ecx
  802429:	89 d8                	mov    %ebx,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f1                	div    %ecx
  80242f:	89 f0                	mov    %esi,%eax
  802431:	f7 f1                	div    %ecx
  802433:	e9 31 ff ff ff       	jmp    802369 <__umoddi3+0x29>
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 dd                	cmp    %ebx,%ebp
  802442:	72 08                	jb     80244c <__umoddi3+0x10c>
  802444:	39 f7                	cmp    %esi,%edi
  802446:	0f 87 21 ff ff ff    	ja     80236d <__umoddi3+0x2d>
  80244c:	89 da                	mov    %ebx,%edx
  80244e:	89 f0                	mov    %esi,%eax
  802450:	29 f8                	sub    %edi,%eax
  802452:	19 ea                	sbb    %ebp,%edx
  802454:	e9 14 ff ff ff       	jmp    80236d <__umoddi3+0x2d>
