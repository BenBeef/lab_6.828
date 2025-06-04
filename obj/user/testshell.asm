
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 46 05 00 00       	call   800577 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 1e 1a 00 00       	call   801a6d <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 14 1a 00 00       	call   801a6d <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  800060:	e8 4d 06 00 00       	call   8006b2 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 5e 2d 80 00 	movl   $0x802d5e,(%esp)
  80006c:	e8 41 06 00 00       	call   8006b2 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 8b 0f 00 00       	call   80100e <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 8b 18 00 00       	call   80191d <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 6d 2d 80 00       	push   $0x802d6d
  8000a1:	e8 0c 06 00 00       	call   8006b2 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 56 0f 00 00       	call   80100e <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 56 18 00 00       	call   80191d <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 68 2d 80 00       	push   $0x802d68
  8000d6:	e8 d7 05 00 00       	call   8006b2 <cprintf>
	exit();
  8000db:	e8 dd 04 00 00       	call   8005bd <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 e6 16 00 00       	call   8017e1 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 da 16 00 00       	call   8017e1 <close>
	opencons();
  800107:	e8 19 04 00 00       	call   800525 <opencons>
	opencons();
  80010c:	e8 14 04 00 00       	call   800525 <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 7b 2d 80 00       	push   $0x802d7b
  80011b:	e8 62 1c 00 00       	call   801d82 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 02 01 00 00    	js     80022f <umain+0x144>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 7f 25 00 00       	call   8026b8 <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 fd 00 00 00    	js     800241 <umain+0x156>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 04 2c 80 00       	push   $0x802c04
  80014f:	e8 5e 05 00 00       	call   8006b2 <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 68 13 00 00       	call   8014c1 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 ef 00 00 00    	js     800253 <umain+0x168>
	if (r == 0) {
  800164:	85 c0                	test   %eax,%eax
  800166:	75 6f                	jne    8001d7 <umain+0xec>
		dup(rfd, 0);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	6a 00                	push   $0x0
  80016d:	53                   	push   %ebx
  80016e:	e8 be 16 00 00       	call   801831 <dup>
		dup(wfd, 1);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	6a 01                	push   $0x1
  800178:	56                   	push   %esi
  800179:	e8 b3 16 00 00       	call   801831 <dup>
		close(rfd);
  80017e:	89 1c 24             	mov    %ebx,(%esp)
  800181:	e8 5b 16 00 00       	call   8017e1 <close>
		close(wfd);
  800186:	89 34 24             	mov    %esi,(%esp)
  800189:	e8 53 16 00 00       	call   8017e1 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018e:	6a 00                	push   $0x0
  800190:	68 c1 2d 80 00       	push   $0x802dc1
  800195:	68 85 2d 80 00       	push   $0x802d85
  80019a:	68 c4 2d 80 00       	push   $0x802dc4
  80019f:	e8 7d 22 00 00       	call   802421 <spawnl>
  8001a4:	89 c7                	mov    %eax,%edi
  8001a6:	83 c4 20             	add    $0x20,%esp
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	0f 88 b4 00 00 00    	js     800265 <umain+0x17a>
		close(0);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	e8 26 16 00 00       	call   8017e1 <close>
		close(1);
  8001bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c2:	e8 1a 16 00 00       	call   8017e1 <close>
		wait(r);
  8001c7:	89 3c 24             	mov    %edi,(%esp)
  8001ca:	e8 65 26 00 00       	call   802834 <wait>
		exit();
  8001cf:	e8 e9 03 00 00       	call   8005bd <exit>
  8001d4:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	53                   	push   %ebx
  8001db:	e8 01 16 00 00       	call   8017e1 <close>
	close(wfd);
  8001e0:	89 34 24             	mov    %esi,(%esp)
  8001e3:	e8 f9 15 00 00       	call   8017e1 <close>
	rfd = pfds[0];
  8001e8:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	6a 00                	push   $0x0
  8001f0:	68 d2 2d 80 00       	push   $0x802dd2
  8001f5:	e8 88 1b 00 00       	call   801d82 <open>
  8001fa:	89 c3                	mov    %eax,%ebx
  8001fc:	83 c4 10             	add    $0x10,%esp
  8001ff:	85 c0                	test   %eax,%eax
  800201:	78 74                	js     800277 <umain+0x18c>
    cprintf("[%08x] after ---------------------- \n", thisenv->env_id);
  800203:	a1 04 50 80 00       	mov    0x805004,%eax
  800208:	8b 40 48             	mov    0x48(%eax),%eax
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	50                   	push   %eax
  80020f:	68 4c 2c 80 00       	push   $0x802c4c
  800214:	e8 99 04 00 00       	call   8006b2 <cprintf>
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
	nloff = 0;
  800223:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  80022a:	e9 a4 00 00 00       	jmp    8002d3 <umain+0x1e8>
		panic("open testshell.sh: %e", rfd);
  80022f:	50                   	push   %eax
  800230:	68 88 2d 80 00       	push   $0x802d88
  800235:	6a 13                	push   $0x13
  800237:	68 9e 2d 80 00       	push   $0x802d9e
  80023c:	e8 96 03 00 00       	call   8005d7 <_panic>
		panic("pipe: %e", wfd);
  800241:	50                   	push   %eax
  800242:	68 af 2d 80 00       	push   $0x802daf
  800247:	6a 15                	push   $0x15
  800249:	68 9e 2d 80 00       	push   $0x802d9e
  80024e:	e8 84 03 00 00       	call   8005d7 <_panic>
		panic("fork: %e", r);
  800253:	50                   	push   %eax
  800254:	68 b8 2d 80 00       	push   $0x802db8
  800259:	6a 1a                	push   $0x1a
  80025b:	68 9e 2d 80 00       	push   $0x802d9e
  800260:	e8 72 03 00 00       	call   8005d7 <_panic>
			panic("spawn: %e", r);
  800265:	50                   	push   %eax
  800266:	68 c8 2d 80 00       	push   $0x802dc8
  80026b:	6a 21                	push   $0x21
  80026d:	68 9e 2d 80 00       	push   $0x802d9e
  800272:	e8 60 03 00 00       	call   8005d7 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  800277:	50                   	push   %eax
  800278:	68 28 2c 80 00       	push   $0x802c28
  80027d:	6a 2c                	push   $0x2c
  80027f:	68 9e 2d 80 00       	push   $0x802d9e
  800284:	e8 4e 03 00 00       	call   8005d7 <_panic>
			panic("reading testshell.out: %e", n1);
  800289:	56                   	push   %esi
  80028a:	68 e0 2d 80 00       	push   $0x802de0
  80028f:	6a 40                	push   $0x40
  800291:	68 9e 2d 80 00       	push   $0x802d9e
  800296:	e8 3c 03 00 00       	call   8005d7 <_panic>
			panic("reading testshell.key: %e", n2);
  80029b:	50                   	push   %eax
  80029c:	68 fa 2d 80 00       	push   $0x802dfa
  8002a1:	6a 42                	push   $0x42
  8002a3:	68 9e 2d 80 00       	push   $0x802d9e
  8002a8:	e8 2a 03 00 00       	call   8005d7 <_panic>
			wrong(rfd, kfd, nloff);
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002b3:	53                   	push   %ebx
  8002b4:	57                   	push   %edi
  8002b5:	e8 79 fd ff ff       	call   800033 <wrong>
  8002ba:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002bd:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8002c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002c7:	0f 44 c8             	cmove  %eax,%ecx
  8002ca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002cd:	83 c0 01             	add    $0x1,%eax
  8002d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
        fd_lookup(kfd, &fdk);
  8002d3:	83 ec 08             	sub    $0x8,%esp
  8002d6:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8002d9:	50                   	push   %eax
  8002da:	53                   	push   %ebx
  8002db:	e8 cc 13 00 00       	call   8016ac <fd_lookup>
        cprintf("[%08x] ----------- test-shell 1 dev_id=%x \n", thisenv->env_id, fdk->fd_dev_id);
  8002e0:	a1 04 50 80 00       	mov    0x805004,%eax
  8002e5:	8b 40 48             	mov    0x48(%eax),%eax
  8002e8:	83 c4 0c             	add    $0xc,%esp
  8002eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ee:	ff 32                	pushl  (%edx)
  8002f0:	50                   	push   %eax
  8002f1:	68 74 2c 80 00       	push   $0x802c74
  8002f6:	e8 b7 03 00 00       	call   8006b2 <cprintf>
        cprintf("[%08x] ----------- pageref 1 ref=%x \n", thisenv->env_id, pageref((void *)0xd0002000));
  8002fb:	c7 04 24 00 20 00 d0 	movl   $0xd0002000,(%esp)
  800302:	e8 4e 1b 00 00       	call   801e55 <pageref>
  800307:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80030d:	8b 52 48             	mov    0x48(%edx),%edx
  800310:	83 c4 0c             	add    $0xc,%esp
  800313:	50                   	push   %eax
  800314:	52                   	push   %edx
  800315:	68 a0 2c 80 00       	push   $0x802ca0
  80031a:	e8 93 03 00 00       	call   8006b2 <cprintf>
		n1 = read(rfd, &c1, 1);
  80031f:	83 c4 0c             	add    $0xc,%esp
  800322:	6a 01                	push   $0x1
  800324:	8d 45 e7             	lea    -0x19(%ebp),%eax
  800327:	50                   	push   %eax
  800328:	57                   	push   %edi
  800329:	e8 ef 15 00 00       	call   80191d <read>
  80032e:	89 c6                	mov    %eax,%esi
        cprintf("[%08x] ----------- pageref 2 ref=%x \n", thisenv->env_id, pageref((void *)0xd0002000));
  800330:	c7 04 24 00 20 00 d0 	movl   $0xd0002000,(%esp)
  800337:	e8 19 1b 00 00       	call   801e55 <pageref>
  80033c:	8b 15 04 50 80 00    	mov    0x805004,%edx
  800342:	8b 52 48             	mov    0x48(%edx),%edx
  800345:	83 c4 0c             	add    $0xc,%esp
  800348:	50                   	push   %eax
  800349:	52                   	push   %edx
  80034a:	68 c8 2c 80 00       	push   $0x802cc8
  80034f:	e8 5e 03 00 00       	call   8006b2 <cprintf>
        fd_lookup(kfd, &fdk);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80035a:	50                   	push   %eax
  80035b:	53                   	push   %ebx
  80035c:	e8 4b 13 00 00       	call   8016ac <fd_lookup>
        cprintf("[%08x] ----------- test-shell 2 dev_id_addr=%x \n", thisenv->env_id, &fdk->fd_dev_id);
  800361:	a1 04 50 80 00       	mov    0x805004,%eax
  800366:	8b 40 48             	mov    0x48(%eax),%eax
  800369:	83 c4 0c             	add    $0xc,%esp
  80036c:	ff 75 d8             	pushl  -0x28(%ebp)
  80036f:	50                   	push   %eax
  800370:	68 f0 2c 80 00       	push   $0x802cf0
  800375:	e8 38 03 00 00       	call   8006b2 <cprintf>
        cprintf("[%08x] ----------- test-shell 3 rfd/kfd=%d/%d, dev_id=%s\n", thisenv->env_id, rfd, kfd, (char *)(&fdk->fd_dev_id));
  80037a:	a1 04 50 80 00       	mov    0x805004,%eax
  80037f:	8b 40 48             	mov    0x48(%eax),%eax
  800382:	83 c4 04             	add    $0x4,%esp
  800385:	ff 75 d8             	pushl  -0x28(%ebp)
  800388:	53                   	push   %ebx
  800389:	57                   	push   %edi
  80038a:	50                   	push   %eax
  80038b:	68 24 2d 80 00       	push   $0x802d24
  800390:	e8 1d 03 00 00       	call   8006b2 <cprintf>
		n2 = read(kfd, &c2, 1);
  800395:	83 c4 1c             	add    $0x1c,%esp
  800398:	6a 01                	push   $0x1
  80039a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  80039d:	50                   	push   %eax
  80039e:	53                   	push   %ebx
  80039f:	e8 79 15 00 00       	call   80191d <read>
		if (n1 < 0)
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	85 f6                	test   %esi,%esi
  8003a9:	0f 88 da fe ff ff    	js     800289 <umain+0x19e>
		if (n2 < 0)
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	0f 88 e4 fe ff ff    	js     80029b <umain+0x1b0>
		if (n1 == 0 && n2 == 0)
  8003b7:	89 f1                	mov    %esi,%ecx
  8003b9:	09 c1                	or     %eax,%ecx
  8003bb:	74 24                	je     8003e1 <umain+0x2f6>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8003bd:	83 fe 01             	cmp    $0x1,%esi
  8003c0:	0f 85 e7 fe ff ff    	jne    8002ad <umain+0x1c2>
  8003c6:	83 f8 01             	cmp    $0x1,%eax
  8003c9:	0f 85 de fe ff ff    	jne    8002ad <umain+0x1c2>
  8003cf:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8003d3:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8003d6:	0f 85 d1 fe ff ff    	jne    8002ad <umain+0x1c2>
  8003dc:	e9 dc fe ff ff       	jmp    8002bd <umain+0x1d2>
	cprintf("shell ran correctly\n");
  8003e1:	83 ec 0c             	sub    $0xc,%esp
  8003e4:	68 14 2e 80 00       	push   $0x802e14
  8003e9:	e8 c4 02 00 00       	call   8006b2 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8003ee:	cc                   	int3   
}
  8003ef:	83 c4 10             	add    $0x10,%esp
  8003f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f5:	5b                   	pop    %ebx
  8003f6:	5e                   	pop    %esi
  8003f7:	5f                   	pop    %edi
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80040a:	68 29 2e 80 00       	push   $0x802e29
  80040f:	ff 75 0c             	pushl  0xc(%ebp)
  800412:	e8 ba 08 00 00       	call   800cd1 <strcpy>
	return 0;
}
  800417:	b8 00 00 00 00       	mov    $0x0,%eax
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <devcons_write>:
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	57                   	push   %edi
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80042a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80042f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800435:	eb 2f                	jmp    800466 <devcons_write+0x48>
		m = n - tot;
  800437:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80043a:	29 f3                	sub    %esi,%ebx
  80043c:	83 fb 7f             	cmp    $0x7f,%ebx
  80043f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800444:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800447:	83 ec 04             	sub    $0x4,%esp
  80044a:	53                   	push   %ebx
  80044b:	89 f0                	mov    %esi,%eax
  80044d:	03 45 0c             	add    0xc(%ebp),%eax
  800450:	50                   	push   %eax
  800451:	57                   	push   %edi
  800452:	e8 08 0a 00 00       	call   800e5f <memmove>
		sys_cputs(buf, m);
  800457:	83 c4 08             	add    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	57                   	push   %edi
  80045c:	e8 ad 0b 00 00       	call   80100e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800461:	01 de                	add    %ebx,%esi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	3b 75 10             	cmp    0x10(%ebp),%esi
  800469:	72 cc                	jb     800437 <devcons_write+0x19>
}
  80046b:	89 f0                	mov    %esi,%eax
  80046d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800470:	5b                   	pop    %ebx
  800471:	5e                   	pop    %esi
  800472:	5f                   	pop    %edi
  800473:	5d                   	pop    %ebp
  800474:	c3                   	ret    

00800475 <devcons_read>:
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800480:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800484:	75 07                	jne    80048d <devcons_read+0x18>
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    
		sys_yield();
  800488:	e8 1e 0c 00 00       	call   8010ab <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80048d:	e8 9a 0b 00 00       	call   80102c <sys_cgetc>
  800492:	85 c0                	test   %eax,%eax
  800494:	74 f2                	je     800488 <devcons_read+0x13>
	if (c < 0)
  800496:	85 c0                	test   %eax,%eax
  800498:	78 ec                	js     800486 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80049a:	83 f8 04             	cmp    $0x4,%eax
  80049d:	74 0c                	je     8004ab <devcons_read+0x36>
	*(char*)vbuf = c;
  80049f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a2:	88 02                	mov    %al,(%edx)
	return 1;
  8004a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8004a9:	eb db                	jmp    800486 <devcons_read+0x11>
		return 0;
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	eb d4                	jmp    800486 <devcons_read+0x11>

008004b2 <cputchar>:
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8004be:	6a 01                	push   $0x1
  8004c0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	e8 45 0b 00 00       	call   80100e <sys_cputs>
}
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    

008004ce <getchar>:
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8004d4:	6a 01                	push   $0x1
  8004d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8004d9:	50                   	push   %eax
  8004da:	6a 00                	push   $0x0
  8004dc:	e8 3c 14 00 00       	call   80191d <read>
	if (r < 0)
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	78 08                	js     8004f0 <getchar+0x22>
	if (r < 1)
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	7e 06                	jle    8004f2 <getchar+0x24>
	return c;
  8004ec:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    
		return -E_EOF;
  8004f2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8004f7:	eb f7                	jmp    8004f0 <getchar+0x22>

008004f9 <iscons>:
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 75 08             	pushl  0x8(%ebp)
  800506:	e8 a1 11 00 00       	call   8016ac <fd_lookup>
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	85 c0                	test   %eax,%eax
  800510:	78 11                	js     800523 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800515:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051b:	39 10                	cmp    %edx,(%eax)
  80051d:	0f 94 c0             	sete   %al
  800520:	0f b6 c0             	movzbl %al,%eax
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <opencons>:
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	e8 29 11 00 00       	call   80165d <fd_alloc>
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 c0                	test   %eax,%eax
  800539:	78 3a                	js     800575 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80053b:	83 ec 04             	sub    $0x4,%esp
  80053e:	68 07 04 00 00       	push   $0x407
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	6a 00                	push   $0x0
  800548:	e8 7d 0b 00 00       	call   8010ca <sys_page_alloc>
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	85 c0                	test   %eax,%eax
  800552:	78 21                	js     800575 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800554:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800557:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80055d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80055f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800562:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	50                   	push   %eax
  80056d:	e8 c4 10 00 00       	call   801636 <fd2num>
  800572:	83 c4 10             	add    $0x10,%esp
}
  800575:	c9                   	leave  
  800576:	c3                   	ret    

00800577 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	56                   	push   %esi
  80057b:	53                   	push   %ebx
  80057c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80057f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800582:	e8 05 0b 00 00       	call   80108c <sys_getenvid>
  800587:	25 ff 03 00 00       	and    $0x3ff,%eax
  80058c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80058f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800594:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800599:	85 db                	test   %ebx,%ebx
  80059b:	7e 07                	jle    8005a4 <libmain+0x2d>
		binaryname = argv[0];
  80059d:	8b 06                	mov    (%esi),%eax
  80059f:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
  8005a9:	e8 3d fb ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8005ae:	e8 0a 00 00 00       	call   8005bd <exit>
}
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005b9:	5b                   	pop    %ebx
  8005ba:	5e                   	pop    %esi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005c3:	e8 44 12 00 00       	call   80180c <close_all>
	sys_env_destroy(0);
  8005c8:	83 ec 0c             	sub    $0xc,%esp
  8005cb:	6a 00                	push   $0x0
  8005cd:	e8 79 0a 00 00       	call   80104b <sys_env_destroy>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    

008005d7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	56                   	push   %esi
  8005db:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005df:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8005e5:	e8 a2 0a 00 00       	call   80108c <sys_getenvid>
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	ff 75 08             	pushl  0x8(%ebp)
  8005f3:	56                   	push   %esi
  8005f4:	50                   	push   %eax
  8005f5:	68 40 2e 80 00       	push   $0x802e40
  8005fa:	e8 b3 00 00 00       	call   8006b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005ff:	83 c4 18             	add    $0x18,%esp
  800602:	53                   	push   %ebx
  800603:	ff 75 10             	pushl  0x10(%ebp)
  800606:	e8 56 00 00 00       	call   800661 <vcprintf>
	cprintf("\n");
  80060b:	c7 04 24 6b 2d 80 00 	movl   $0x802d6b,(%esp)
  800612:	e8 9b 00 00 00       	call   8006b2 <cprintf>
  800617:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80061a:	cc                   	int3   
  80061b:	eb fd                	jmp    80061a <_panic+0x43>

0080061d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	53                   	push   %ebx
  800621:	83 ec 04             	sub    $0x4,%esp
  800624:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800627:	8b 13                	mov    (%ebx),%edx
  800629:	8d 42 01             	lea    0x1(%edx),%eax
  80062c:	89 03                	mov    %eax,(%ebx)
  80062e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800631:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800635:	3d ff 00 00 00       	cmp    $0xff,%eax
  80063a:	74 09                	je     800645 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80063c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800643:	c9                   	leave  
  800644:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	68 ff 00 00 00       	push   $0xff
  80064d:	8d 43 08             	lea    0x8(%ebx),%eax
  800650:	50                   	push   %eax
  800651:	e8 b8 09 00 00       	call   80100e <sys_cputs>
		b->idx = 0;
  800656:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb db                	jmp    80063c <putch+0x1f>

00800661 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80066a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800671:	00 00 00 
	b.cnt = 0;
  800674:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80067b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	ff 75 08             	pushl  0x8(%ebp)
  800684:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80068a:	50                   	push   %eax
  80068b:	68 1d 06 80 00       	push   $0x80061d
  800690:	e8 1a 01 00 00       	call   8007af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80069e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	e8 64 09 00 00       	call   80100e <sys_cputs>

	return b.cnt;
}
  8006aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006bb:	50                   	push   %eax
  8006bc:	ff 75 08             	pushl  0x8(%ebp)
  8006bf:	e8 9d ff ff ff       	call   800661 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	57                   	push   %edi
  8006ca:	56                   	push   %esi
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 1c             	sub    $0x1c,%esp
  8006cf:	89 c7                	mov    %eax,%edi
  8006d1:	89 d6                	mov    %edx,%esi
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ea:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006ed:	39 d3                	cmp    %edx,%ebx
  8006ef:	72 05                	jb     8006f6 <printnum+0x30>
  8006f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006f4:	77 7a                	ja     800770 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006f6:	83 ec 0c             	sub    $0xc,%esp
  8006f9:	ff 75 18             	pushl  0x18(%ebp)
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800702:	53                   	push   %ebx
  800703:	ff 75 10             	pushl  0x10(%ebp)
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	ff 75 e4             	pushl  -0x1c(%ebp)
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	ff 75 dc             	pushl  -0x24(%ebp)
  800712:	ff 75 d8             	pushl  -0x28(%ebp)
  800715:	e8 76 22 00 00       	call   802990 <__udivdi3>
  80071a:	83 c4 18             	add    $0x18,%esp
  80071d:	52                   	push   %edx
  80071e:	50                   	push   %eax
  80071f:	89 f2                	mov    %esi,%edx
  800721:	89 f8                	mov    %edi,%eax
  800723:	e8 9e ff ff ff       	call   8006c6 <printnum>
  800728:	83 c4 20             	add    $0x20,%esp
  80072b:	eb 13                	jmp    800740 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	56                   	push   %esi
  800731:	ff 75 18             	pushl  0x18(%ebp)
  800734:	ff d7                	call   *%edi
  800736:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800739:	83 eb 01             	sub    $0x1,%ebx
  80073c:	85 db                	test   %ebx,%ebx
  80073e:	7f ed                	jg     80072d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	56                   	push   %esi
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074a:	ff 75 e0             	pushl  -0x20(%ebp)
  80074d:	ff 75 dc             	pushl  -0x24(%ebp)
  800750:	ff 75 d8             	pushl  -0x28(%ebp)
  800753:	e8 58 23 00 00       	call   802ab0 <__umoddi3>
  800758:	83 c4 14             	add    $0x14,%esp
  80075b:	0f be 80 63 2e 80 00 	movsbl 0x802e63(%eax),%eax
  800762:	50                   	push   %eax
  800763:	ff d7                	call   *%edi
}
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    
  800770:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800773:	eb c4                	jmp    800739 <printnum+0x73>

00800775 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80077b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80077f:	8b 10                	mov    (%eax),%edx
  800781:	3b 50 04             	cmp    0x4(%eax),%edx
  800784:	73 0a                	jae    800790 <sprintputch+0x1b>
		*b->buf++ = ch;
  800786:	8d 4a 01             	lea    0x1(%edx),%ecx
  800789:	89 08                	mov    %ecx,(%eax)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	88 02                	mov    %al,(%edx)
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <printfmt>:
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80079b:	50                   	push   %eax
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	ff 75 08             	pushl  0x8(%ebp)
  8007a5:	e8 05 00 00 00       	call   8007af <vprintfmt>
}
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <vprintfmt>:
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	57                   	push   %edi
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	83 ec 2c             	sub    $0x2c,%esp
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007c1:	e9 c1 03 00 00       	jmp    800b87 <vprintfmt+0x3d8>
		padc = ' ';
  8007c6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8007ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8007d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8007d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007df:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007e4:	8d 47 01             	lea    0x1(%edi),%eax
  8007e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ea:	0f b6 17             	movzbl (%edi),%edx
  8007ed:	8d 42 dd             	lea    -0x23(%edx),%eax
  8007f0:	3c 55                	cmp    $0x55,%al
  8007f2:	0f 87 12 04 00 00    	ja     800c0a <vprintfmt+0x45b>
  8007f8:	0f b6 c0             	movzbl %al,%eax
  8007fb:	ff 24 85 a0 2f 80 00 	jmp    *0x802fa0(,%eax,4)
  800802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800805:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800809:	eb d9                	jmp    8007e4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80080b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80080e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800812:	eb d0                	jmp    8007e4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800814:	0f b6 d2             	movzbl %dl,%edx
  800817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800822:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800825:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800829:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80082c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80082f:	83 f9 09             	cmp    $0x9,%ecx
  800832:	77 55                	ja     800889 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800834:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800837:	eb e9                	jmp    800822 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80084a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80084d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800851:	79 91                	jns    8007e4 <vprintfmt+0x35>
				width = precision, precision = -1;
  800853:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800856:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800859:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800860:	eb 82                	jmp    8007e4 <vprintfmt+0x35>
  800862:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800865:	85 c0                	test   %eax,%eax
  800867:	ba 00 00 00 00       	mov    $0x0,%edx
  80086c:	0f 49 d0             	cmovns %eax,%edx
  80086f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800875:	e9 6a ff ff ff       	jmp    8007e4 <vprintfmt+0x35>
  80087a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80087d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800884:	e9 5b ff ff ff       	jmp    8007e4 <vprintfmt+0x35>
  800889:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80088c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80088f:	eb bc                	jmp    80084d <vprintfmt+0x9e>
			lflag++;
  800891:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800894:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800897:	e9 48 ff ff ff       	jmp    8007e4 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 78 04             	lea    0x4(%eax),%edi
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	ff 30                	pushl  (%eax)
  8008a8:	ff d6                	call   *%esi
			break;
  8008aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8008ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8008b0:	e9 cf 02 00 00       	jmp    800b84 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8008b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b8:	8d 78 04             	lea    0x4(%eax),%edi
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	99                   	cltd   
  8008be:	31 d0                	xor    %edx,%eax
  8008c0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008c2:	83 f8 0f             	cmp    $0xf,%eax
  8008c5:	7f 23                	jg     8008ea <vprintfmt+0x13b>
  8008c7:	8b 14 85 00 31 80 00 	mov    0x803100(,%eax,4),%edx
  8008ce:	85 d2                	test   %edx,%edx
  8008d0:	74 18                	je     8008ea <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8008d2:	52                   	push   %edx
  8008d3:	68 75 33 80 00       	push   $0x803375
  8008d8:	53                   	push   %ebx
  8008d9:	56                   	push   %esi
  8008da:	e8 b3 fe ff ff       	call   800792 <printfmt>
  8008df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8008e2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8008e5:	e9 9a 02 00 00       	jmp    800b84 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8008ea:	50                   	push   %eax
  8008eb:	68 7b 2e 80 00       	push   $0x802e7b
  8008f0:	53                   	push   %ebx
  8008f1:	56                   	push   %esi
  8008f2:	e8 9b fe ff ff       	call   800792 <printfmt>
  8008f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8008fa:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8008fd:	e9 82 02 00 00       	jmp    800b84 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800902:	8b 45 14             	mov    0x14(%ebp),%eax
  800905:	83 c0 04             	add    $0x4,%eax
  800908:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800910:	85 ff                	test   %edi,%edi
  800912:	b8 74 2e 80 00       	mov    $0x802e74,%eax
  800917:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80091a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091e:	0f 8e bd 00 00 00    	jle    8009e1 <vprintfmt+0x232>
  800924:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800928:	75 0e                	jne    800938 <vprintfmt+0x189>
  80092a:	89 75 08             	mov    %esi,0x8(%ebp)
  80092d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800930:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800933:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800936:	eb 6d                	jmp    8009a5 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800938:	83 ec 08             	sub    $0x8,%esp
  80093b:	ff 75 d0             	pushl  -0x30(%ebp)
  80093e:	57                   	push   %edi
  80093f:	e8 6e 03 00 00       	call   800cb2 <strnlen>
  800944:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800947:	29 c1                	sub    %eax,%ecx
  800949:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80094c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80094f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800953:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800956:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800959:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80095b:	eb 0f                	jmp    80096c <vprintfmt+0x1bd>
					putch(padc, putdat);
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	53                   	push   %ebx
  800961:	ff 75 e0             	pushl  -0x20(%ebp)
  800964:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800966:	83 ef 01             	sub    $0x1,%edi
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	85 ff                	test   %edi,%edi
  80096e:	7f ed                	jg     80095d <vprintfmt+0x1ae>
  800970:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800973:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800976:	85 c9                	test   %ecx,%ecx
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	0f 49 c1             	cmovns %ecx,%eax
  800980:	29 c1                	sub    %eax,%ecx
  800982:	89 75 08             	mov    %esi,0x8(%ebp)
  800985:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800988:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80098b:	89 cb                	mov    %ecx,%ebx
  80098d:	eb 16                	jmp    8009a5 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80098f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800993:	75 31                	jne    8009c6 <vprintfmt+0x217>
					putch(ch, putdat);
  800995:	83 ec 08             	sub    $0x8,%esp
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	50                   	push   %eax
  80099c:	ff 55 08             	call   *0x8(%ebp)
  80099f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009a2:	83 eb 01             	sub    $0x1,%ebx
  8009a5:	83 c7 01             	add    $0x1,%edi
  8009a8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8009ac:	0f be c2             	movsbl %dl,%eax
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	74 59                	je     800a0c <vprintfmt+0x25d>
  8009b3:	85 f6                	test   %esi,%esi
  8009b5:	78 d8                	js     80098f <vprintfmt+0x1e0>
  8009b7:	83 ee 01             	sub    $0x1,%esi
  8009ba:	79 d3                	jns    80098f <vprintfmt+0x1e0>
  8009bc:	89 df                	mov    %ebx,%edi
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c4:	eb 37                	jmp    8009fd <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8009c6:	0f be d2             	movsbl %dl,%edx
  8009c9:	83 ea 20             	sub    $0x20,%edx
  8009cc:	83 fa 5e             	cmp    $0x5e,%edx
  8009cf:	76 c4                	jbe    800995 <vprintfmt+0x1e6>
					putch('?', putdat);
  8009d1:	83 ec 08             	sub    $0x8,%esp
  8009d4:	ff 75 0c             	pushl  0xc(%ebp)
  8009d7:	6a 3f                	push   $0x3f
  8009d9:	ff 55 08             	call   *0x8(%ebp)
  8009dc:	83 c4 10             	add    $0x10,%esp
  8009df:	eb c1                	jmp    8009a2 <vprintfmt+0x1f3>
  8009e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8009ed:	eb b6                	jmp    8009a5 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	53                   	push   %ebx
  8009f3:	6a 20                	push   $0x20
  8009f5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8009f7:	83 ef 01             	sub    $0x1,%edi
  8009fa:	83 c4 10             	add    $0x10,%esp
  8009fd:	85 ff                	test   %edi,%edi
  8009ff:	7f ee                	jg     8009ef <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800a01:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a04:	89 45 14             	mov    %eax,0x14(%ebp)
  800a07:	e9 78 01 00 00       	jmp    800b84 <vprintfmt+0x3d5>
  800a0c:	89 df                	mov    %ebx,%edi
  800a0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a14:	eb e7                	jmp    8009fd <vprintfmt+0x24e>
	if (lflag >= 2)
  800a16:	83 f9 01             	cmp    $0x1,%ecx
  800a19:	7e 3f                	jle    800a5a <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1e:	8b 50 04             	mov    0x4(%eax),%edx
  800a21:	8b 00                	mov    (%eax),%eax
  800a23:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a26:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a29:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2c:	8d 40 08             	lea    0x8(%eax),%eax
  800a2f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800a32:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a36:	79 5c                	jns    800a94 <vprintfmt+0x2e5>
				putch('-', putdat);
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	53                   	push   %ebx
  800a3c:	6a 2d                	push   $0x2d
  800a3e:	ff d6                	call   *%esi
				num = -(long long) num;
  800a40:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a43:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800a46:	f7 da                	neg    %edx
  800a48:	83 d1 00             	adc    $0x0,%ecx
  800a4b:	f7 d9                	neg    %ecx
  800a4d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800a50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a55:	e9 10 01 00 00       	jmp    800b6a <vprintfmt+0x3bb>
	else if (lflag)
  800a5a:	85 c9                	test   %ecx,%ecx
  800a5c:	75 1b                	jne    800a79 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800a5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a61:	8b 00                	mov    (%eax),%eax
  800a63:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a66:	89 c1                	mov    %eax,%ecx
  800a68:	c1 f9 1f             	sar    $0x1f,%ecx
  800a6b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a71:	8d 40 04             	lea    0x4(%eax),%eax
  800a74:	89 45 14             	mov    %eax,0x14(%ebp)
  800a77:	eb b9                	jmp    800a32 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8b 00                	mov    (%eax),%eax
  800a7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a81:	89 c1                	mov    %eax,%ecx
  800a83:	c1 f9 1f             	sar    $0x1f,%ecx
  800a86:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8d 40 04             	lea    0x4(%eax),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a92:	eb 9e                	jmp    800a32 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800a94:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800a97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800a9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a9f:	e9 c6 00 00 00       	jmp    800b6a <vprintfmt+0x3bb>
	if (lflag >= 2)
  800aa4:	83 f9 01             	cmp    $0x1,%ecx
  800aa7:	7e 18                	jle    800ac1 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800aa9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aac:	8b 10                	mov    (%eax),%edx
  800aae:	8b 48 04             	mov    0x4(%eax),%ecx
  800ab1:	8d 40 08             	lea    0x8(%eax),%eax
  800ab4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800ab7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800abc:	e9 a9 00 00 00       	jmp    800b6a <vprintfmt+0x3bb>
	else if (lflag)
  800ac1:	85 c9                	test   %ecx,%ecx
  800ac3:	75 1a                	jne    800adf <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800ac5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac8:	8b 10                	mov    (%eax),%edx
  800aca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acf:	8d 40 04             	lea    0x4(%eax),%eax
  800ad2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800ad5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ada:	e9 8b 00 00 00       	jmp    800b6a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800adf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae2:	8b 10                	mov    (%eax),%edx
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	8d 40 04             	lea    0x4(%eax),%eax
  800aec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800aef:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af4:	eb 74                	jmp    800b6a <vprintfmt+0x3bb>
	if (lflag >= 2)
  800af6:	83 f9 01             	cmp    $0x1,%ecx
  800af9:	7e 15                	jle    800b10 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8b 10                	mov    (%eax),%edx
  800b00:	8b 48 04             	mov    0x4(%eax),%ecx
  800b03:	8d 40 08             	lea    0x8(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800b09:	b8 08 00 00 00       	mov    $0x8,%eax
  800b0e:	eb 5a                	jmp    800b6a <vprintfmt+0x3bb>
	else if (lflag)
  800b10:	85 c9                	test   %ecx,%ecx
  800b12:	75 17                	jne    800b2b <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800b14:	8b 45 14             	mov    0x14(%ebp),%eax
  800b17:	8b 10                	mov    (%eax),%edx
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	8d 40 04             	lea    0x4(%eax),%eax
  800b21:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800b24:	b8 08 00 00 00       	mov    $0x8,%eax
  800b29:	eb 3f                	jmp    800b6a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8b 10                	mov    (%eax),%edx
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8d 40 04             	lea    0x4(%eax),%eax
  800b38:	89 45 14             	mov    %eax,0x14(%ebp)
                        base = 8;
  800b3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800b40:	eb 28                	jmp    800b6a <vprintfmt+0x3bb>
			putch('0', putdat);
  800b42:	83 ec 08             	sub    $0x8,%esp
  800b45:	53                   	push   %ebx
  800b46:	6a 30                	push   $0x30
  800b48:	ff d6                	call   *%esi
			putch('x', putdat);
  800b4a:	83 c4 08             	add    $0x8,%esp
  800b4d:	53                   	push   %ebx
  800b4e:	6a 78                	push   $0x78
  800b50:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b52:	8b 45 14             	mov    0x14(%ebp),%eax
  800b55:	8b 10                	mov    (%eax),%edx
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800b5c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800b5f:	8d 40 04             	lea    0x4(%eax),%eax
  800b62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b65:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b71:	57                   	push   %edi
  800b72:	ff 75 e0             	pushl  -0x20(%ebp)
  800b75:	50                   	push   %eax
  800b76:	51                   	push   %ecx
  800b77:	52                   	push   %edx
  800b78:	89 da                	mov    %ebx,%edx
  800b7a:	89 f0                	mov    %esi,%eax
  800b7c:	e8 45 fb ff ff       	call   8006c6 <printnum>
			break;
  800b81:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800b84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b87:	83 c7 01             	add    $0x1,%edi
  800b8a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b8e:	83 f8 25             	cmp    $0x25,%eax
  800b91:	0f 84 2f fc ff ff    	je     8007c6 <vprintfmt+0x17>
			if (ch == '\0')
  800b97:	85 c0                	test   %eax,%eax
  800b99:	0f 84 8b 00 00 00    	je     800c2a <vprintfmt+0x47b>
			putch(ch, putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	53                   	push   %ebx
  800ba3:	50                   	push   %eax
  800ba4:	ff d6                	call   *%esi
  800ba6:	83 c4 10             	add    $0x10,%esp
  800ba9:	eb dc                	jmp    800b87 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800bab:	83 f9 01             	cmp    $0x1,%ecx
  800bae:	7e 15                	jle    800bc5 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb3:	8b 10                	mov    (%eax),%edx
  800bb5:	8b 48 04             	mov    0x4(%eax),%ecx
  800bb8:	8d 40 08             	lea    0x8(%eax),%eax
  800bbb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bbe:	b8 10 00 00 00       	mov    $0x10,%eax
  800bc3:	eb a5                	jmp    800b6a <vprintfmt+0x3bb>
	else if (lflag)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	75 17                	jne    800be0 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800bc9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcc:	8b 10                	mov    (%eax),%edx
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	8d 40 04             	lea    0x4(%eax),%eax
  800bd6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bd9:	b8 10 00 00 00       	mov    $0x10,%eax
  800bde:	eb 8a                	jmp    800b6a <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800be0:	8b 45 14             	mov    0x14(%ebp),%eax
  800be3:	8b 10                	mov    (%eax),%edx
  800be5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bea:	8d 40 04             	lea    0x4(%eax),%eax
  800bed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf0:	b8 10 00 00 00       	mov    $0x10,%eax
  800bf5:	e9 70 ff ff ff       	jmp    800b6a <vprintfmt+0x3bb>
			putch(ch, putdat);
  800bfa:	83 ec 08             	sub    $0x8,%esp
  800bfd:	53                   	push   %ebx
  800bfe:	6a 25                	push   $0x25
  800c00:	ff d6                	call   *%esi
			break;
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	e9 7a ff ff ff       	jmp    800b84 <vprintfmt+0x3d5>
			putch('%', putdat);
  800c0a:	83 ec 08             	sub    $0x8,%esp
  800c0d:	53                   	push   %ebx
  800c0e:	6a 25                	push   $0x25
  800c10:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	89 f8                	mov    %edi,%eax
  800c17:	eb 03                	jmp    800c1c <vprintfmt+0x46d>
  800c19:	83 e8 01             	sub    $0x1,%eax
  800c1c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c20:	75 f7                	jne    800c19 <vprintfmt+0x46a>
  800c22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c25:	e9 5a ff ff ff       	jmp    800b84 <vprintfmt+0x3d5>
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 18             	sub    $0x18,%esp
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	74 26                	je     800c79 <vsnprintf+0x47>
  800c53:	85 d2                	test   %edx,%edx
  800c55:	7e 22                	jle    800c79 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c57:	ff 75 14             	pushl  0x14(%ebp)
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c60:	50                   	push   %eax
  800c61:	68 75 07 80 00       	push   $0x800775
  800c66:	e8 44 fb ff ff       	call   8007af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c74:	83 c4 10             	add    $0x10,%esp
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    
		return -E_INVAL;
  800c79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c7e:	eb f7                	jmp    800c77 <vsnprintf+0x45>

00800c80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c86:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c89:	50                   	push   %eax
  800c8a:	ff 75 10             	pushl  0x10(%ebp)
  800c8d:	ff 75 0c             	pushl  0xc(%ebp)
  800c90:	ff 75 08             	pushl  0x8(%ebp)
  800c93:	e8 9a ff ff ff       	call   800c32 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca5:	eb 03                	jmp    800caa <strlen+0x10>
		n++;
  800ca7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800caa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cae:	75 f7                	jne    800ca7 <strlen+0xd>
	return n;
}
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc0:	eb 03                	jmp    800cc5 <strnlen+0x13>
		n++;
  800cc2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc5:	39 d0                	cmp    %edx,%eax
  800cc7:	74 06                	je     800ccf <strnlen+0x1d>
  800cc9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ccd:	75 f3                	jne    800cc2 <strnlen+0x10>
	return n;
}
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	53                   	push   %ebx
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	83 c1 01             	add    $0x1,%ecx
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ce7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cea:	84 db                	test   %bl,%bl
  800cec:	75 ef                	jne    800cdd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cee:	5b                   	pop    %ebx
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	53                   	push   %ebx
  800cf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cf8:	53                   	push   %ebx
  800cf9:	e8 9c ff ff ff       	call   800c9a <strlen>
  800cfe:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d01:	ff 75 0c             	pushl  0xc(%ebp)
  800d04:	01 d8                	add    %ebx,%eax
  800d06:	50                   	push   %eax
  800d07:	e8 c5 ff ff ff       	call   800cd1 <strcpy>
	return dst;
}
  800d0c:	89 d8                	mov    %ebx,%eax
  800d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	89 f3                	mov    %esi,%ebx
  800d20:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d23:	89 f2                	mov    %esi,%edx
  800d25:	eb 0f                	jmp    800d36 <strncpy+0x23>
		*dst++ = *src;
  800d27:	83 c2 01             	add    $0x1,%edx
  800d2a:	0f b6 01             	movzbl (%ecx),%eax
  800d2d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d30:	80 39 01             	cmpb   $0x1,(%ecx)
  800d33:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800d36:	39 da                	cmp    %ebx,%edx
  800d38:	75 ed                	jne    800d27 <strncpy+0x14>
	}
	return ret;
}
  800d3a:	89 f0                	mov    %esi,%eax
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	8b 75 08             	mov    0x8(%ebp),%esi
  800d48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d4e:	89 f0                	mov    %esi,%eax
  800d50:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d54:	85 c9                	test   %ecx,%ecx
  800d56:	75 0b                	jne    800d63 <strlcpy+0x23>
  800d58:	eb 17                	jmp    800d71 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d5a:	83 c2 01             	add    $0x1,%edx
  800d5d:	83 c0 01             	add    $0x1,%eax
  800d60:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800d63:	39 d8                	cmp    %ebx,%eax
  800d65:	74 07                	je     800d6e <strlcpy+0x2e>
  800d67:	0f b6 0a             	movzbl (%edx),%ecx
  800d6a:	84 c9                	test   %cl,%cl
  800d6c:	75 ec                	jne    800d5a <strlcpy+0x1a>
		*dst = '\0';
  800d6e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d71:	29 f0                	sub    %esi,%eax
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d80:	eb 06                	jmp    800d88 <strcmp+0x11>
		p++, q++;
  800d82:	83 c1 01             	add    $0x1,%ecx
  800d85:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800d88:	0f b6 01             	movzbl (%ecx),%eax
  800d8b:	84 c0                	test   %al,%al
  800d8d:	74 04                	je     800d93 <strcmp+0x1c>
  800d8f:	3a 02                	cmp    (%edx),%al
  800d91:	74 ef                	je     800d82 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d93:	0f b6 c0             	movzbl %al,%eax
  800d96:	0f b6 12             	movzbl (%edx),%edx
  800d99:	29 d0                	sub    %edx,%eax
}
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	53                   	push   %ebx
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dac:	eb 06                	jmp    800db4 <strncmp+0x17>
		n--, p++, q++;
  800dae:	83 c0 01             	add    $0x1,%eax
  800db1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800db4:	39 d8                	cmp    %ebx,%eax
  800db6:	74 16                	je     800dce <strncmp+0x31>
  800db8:	0f b6 08             	movzbl (%eax),%ecx
  800dbb:	84 c9                	test   %cl,%cl
  800dbd:	74 04                	je     800dc3 <strncmp+0x26>
  800dbf:	3a 0a                	cmp    (%edx),%cl
  800dc1:	74 eb                	je     800dae <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc3:	0f b6 00             	movzbl (%eax),%eax
  800dc6:	0f b6 12             	movzbl (%edx),%edx
  800dc9:	29 d0                	sub    %edx,%eax
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
		return 0;
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd3:	eb f6                	jmp    800dcb <strncmp+0x2e>

00800dd5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ddf:	0f b6 10             	movzbl (%eax),%edx
  800de2:	84 d2                	test   %dl,%dl
  800de4:	74 09                	je     800def <strchr+0x1a>
		if (*s == c)
  800de6:	38 ca                	cmp    %cl,%dl
  800de8:	74 0a                	je     800df4 <strchr+0x1f>
	for (; *s; s++)
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	eb f0                	jmp    800ddf <strchr+0xa>
			return (char *) s;
	return 0;
  800def:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e00:	eb 03                	jmp    800e05 <strfind+0xf>
  800e02:	83 c0 01             	add    $0x1,%eax
  800e05:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e08:	38 ca                	cmp    %cl,%dl
  800e0a:	74 04                	je     800e10 <strfind+0x1a>
  800e0c:	84 d2                	test   %dl,%dl
  800e0e:	75 f2                	jne    800e02 <strfind+0xc>
			break;
	return (char *) s;
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e1e:	85 c9                	test   %ecx,%ecx
  800e20:	74 13                	je     800e35 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e22:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e28:	75 05                	jne    800e2f <memset+0x1d>
  800e2a:	f6 c1 03             	test   $0x3,%cl
  800e2d:	74 0d                	je     800e3c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	fc                   	cld    
  800e33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e35:	89 f8                	mov    %edi,%eax
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
		c &= 0xFF;
  800e3c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e40:	89 d3                	mov    %edx,%ebx
  800e42:	c1 e3 08             	shl    $0x8,%ebx
  800e45:	89 d0                	mov    %edx,%eax
  800e47:	c1 e0 18             	shl    $0x18,%eax
  800e4a:	89 d6                	mov    %edx,%esi
  800e4c:	c1 e6 10             	shl    $0x10,%esi
  800e4f:	09 f0                	or     %esi,%eax
  800e51:	09 c2                	or     %eax,%edx
  800e53:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800e55:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800e58:	89 d0                	mov    %edx,%eax
  800e5a:	fc                   	cld    
  800e5b:	f3 ab                	rep stos %eax,%es:(%edi)
  800e5d:	eb d6                	jmp    800e35 <memset+0x23>

00800e5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	57                   	push   %edi
  800e63:	56                   	push   %esi
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e6d:	39 c6                	cmp    %eax,%esi
  800e6f:	73 35                	jae    800ea6 <memmove+0x47>
  800e71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e74:	39 c2                	cmp    %eax,%edx
  800e76:	76 2e                	jbe    800ea6 <memmove+0x47>
		s += n;
		d += n;
  800e78:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7b:	89 d6                	mov    %edx,%esi
  800e7d:	09 fe                	or     %edi,%esi
  800e7f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e85:	74 0c                	je     800e93 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e87:	83 ef 01             	sub    $0x1,%edi
  800e8a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800e8d:	fd                   	std    
  800e8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e90:	fc                   	cld    
  800e91:	eb 21                	jmp    800eb4 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e93:	f6 c1 03             	test   $0x3,%cl
  800e96:	75 ef                	jne    800e87 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e98:	83 ef 04             	sub    $0x4,%edi
  800e9b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ea1:	fd                   	std    
  800ea2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ea4:	eb ea                	jmp    800e90 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea6:	89 f2                	mov    %esi,%edx
  800ea8:	09 c2                	or     %eax,%edx
  800eaa:	f6 c2 03             	test   $0x3,%dl
  800ead:	74 09                	je     800eb8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800eaf:	89 c7                	mov    %eax,%edi
  800eb1:	fc                   	cld    
  800eb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eb8:	f6 c1 03             	test   $0x3,%cl
  800ebb:	75 f2                	jne    800eaf <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ebd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ec0:	89 c7                	mov    %eax,%edi
  800ec2:	fc                   	cld    
  800ec3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec5:	eb ed                	jmp    800eb4 <memmove+0x55>

00800ec7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800eca:	ff 75 10             	pushl  0x10(%ebp)
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	ff 75 08             	pushl  0x8(%ebp)
  800ed3:	e8 87 ff ff ff       	call   800e5f <memmove>
}
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 c6                	mov    %eax,%esi
  800ee7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eea:	39 f0                	cmp    %esi,%eax
  800eec:	74 1c                	je     800f0a <memcmp+0x30>
		if (*s1 != *s2)
  800eee:	0f b6 08             	movzbl (%eax),%ecx
  800ef1:	0f b6 1a             	movzbl (%edx),%ebx
  800ef4:	38 d9                	cmp    %bl,%cl
  800ef6:	75 08                	jne    800f00 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ef8:	83 c0 01             	add    $0x1,%eax
  800efb:	83 c2 01             	add    $0x1,%edx
  800efe:	eb ea                	jmp    800eea <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800f00:	0f b6 c1             	movzbl %cl,%eax
  800f03:	0f b6 db             	movzbl %bl,%ebx
  800f06:	29 d8                	sub    %ebx,%eax
  800f08:	eb 05                	jmp    800f0f <memcmp+0x35>
	}

	return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f21:	39 d0                	cmp    %edx,%eax
  800f23:	73 09                	jae    800f2e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f25:	38 08                	cmp    %cl,(%eax)
  800f27:	74 05                	je     800f2e <memfind+0x1b>
	for (; s < ends; s++)
  800f29:	83 c0 01             	add    $0x1,%eax
  800f2c:	eb f3                	jmp    800f21 <memfind+0xe>
			break;
	return (void *) s;
}
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f3c:	eb 03                	jmp    800f41 <strtol+0x11>
		s++;
  800f3e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800f41:	0f b6 01             	movzbl (%ecx),%eax
  800f44:	3c 20                	cmp    $0x20,%al
  800f46:	74 f6                	je     800f3e <strtol+0xe>
  800f48:	3c 09                	cmp    $0x9,%al
  800f4a:	74 f2                	je     800f3e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800f4c:	3c 2b                	cmp    $0x2b,%al
  800f4e:	74 2e                	je     800f7e <strtol+0x4e>
	int neg = 0;
  800f50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f55:	3c 2d                	cmp    $0x2d,%al
  800f57:	74 2f                	je     800f88 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f5f:	75 05                	jne    800f66 <strtol+0x36>
  800f61:	80 39 30             	cmpb   $0x30,(%ecx)
  800f64:	74 2c                	je     800f92 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f66:	85 db                	test   %ebx,%ebx
  800f68:	75 0a                	jne    800f74 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800f6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f72:	74 28                	je     800f9c <strtol+0x6c>
		base = 10;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f7c:	eb 50                	jmp    800fce <strtol+0x9e>
		s++;
  800f7e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f81:	bf 00 00 00 00       	mov    $0x0,%edi
  800f86:	eb d1                	jmp    800f59 <strtol+0x29>
		s++, neg = 1;
  800f88:	83 c1 01             	add    $0x1,%ecx
  800f8b:	bf 01 00 00 00       	mov    $0x1,%edi
  800f90:	eb c7                	jmp    800f59 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f92:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f96:	74 0e                	je     800fa6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f98:	85 db                	test   %ebx,%ebx
  800f9a:	75 d8                	jne    800f74 <strtol+0x44>
		s++, base = 8;
  800f9c:	83 c1 01             	add    $0x1,%ecx
  800f9f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800fa4:	eb ce                	jmp    800f74 <strtol+0x44>
		s += 2, base = 16;
  800fa6:	83 c1 02             	add    $0x2,%ecx
  800fa9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fae:	eb c4                	jmp    800f74 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800fb0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fb3:	89 f3                	mov    %esi,%ebx
  800fb5:	80 fb 19             	cmp    $0x19,%bl
  800fb8:	77 29                	ja     800fe3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800fba:	0f be d2             	movsbl %dl,%edx
  800fbd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fc0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fc3:	7d 30                	jge    800ff5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800fc5:	83 c1 01             	add    $0x1,%ecx
  800fc8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fcc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800fce:	0f b6 11             	movzbl (%ecx),%edx
  800fd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fd4:	89 f3                	mov    %esi,%ebx
  800fd6:	80 fb 09             	cmp    $0x9,%bl
  800fd9:	77 d5                	ja     800fb0 <strtol+0x80>
			dig = *s - '0';
  800fdb:	0f be d2             	movsbl %dl,%edx
  800fde:	83 ea 30             	sub    $0x30,%edx
  800fe1:	eb dd                	jmp    800fc0 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800fe3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fe6:	89 f3                	mov    %esi,%ebx
  800fe8:	80 fb 19             	cmp    $0x19,%bl
  800feb:	77 08                	ja     800ff5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800fed:	0f be d2             	movsbl %dl,%edx
  800ff0:	83 ea 37             	sub    $0x37,%edx
  800ff3:	eb cb                	jmp    800fc0 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ff5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff9:	74 05                	je     801000 <strtol+0xd0>
		*endptr = (char *) s;
  800ffb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ffe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801000:	89 c2                	mov    %eax,%edx
  801002:	f7 da                	neg    %edx
  801004:	85 ff                	test   %edi,%edi
  801006:	0f 45 c2             	cmovne %edx,%eax
}
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
	asm volatile("int %1\n"
  801014:	b8 00 00 00 00       	mov    $0x0,%eax
  801019:	8b 55 08             	mov    0x8(%ebp),%edx
  80101c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101f:	89 c3                	mov    %eax,%ebx
  801021:	89 c7                	mov    %eax,%edi
  801023:	89 c6                	mov    %eax,%esi
  801025:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <sys_cgetc>:

int
sys_cgetc(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
	asm volatile("int %1\n"
  801032:	ba 00 00 00 00       	mov    $0x0,%edx
  801037:	b8 01 00 00 00       	mov    $0x1,%eax
  80103c:	89 d1                	mov    %edx,%ecx
  80103e:	89 d3                	mov    %edx,%ebx
  801040:	89 d7                	mov    %edx,%edi
  801042:	89 d6                	mov    %edx,%esi
  801044:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801054:	b9 00 00 00 00       	mov    $0x0,%ecx
  801059:	8b 55 08             	mov    0x8(%ebp),%edx
  80105c:	b8 03 00 00 00       	mov    $0x3,%eax
  801061:	89 cb                	mov    %ecx,%ebx
  801063:	89 cf                	mov    %ecx,%edi
  801065:	89 ce                	mov    %ecx,%esi
  801067:	cd 30                	int    $0x30
	if(check && ret > 0)
  801069:	85 c0                	test   %eax,%eax
  80106b:	7f 08                	jg     801075 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80106d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5f                   	pop    %edi
  801073:	5d                   	pop    %ebp
  801074:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	50                   	push   %eax
  801079:	6a 03                	push   $0x3
  80107b:	68 5f 31 80 00       	push   $0x80315f
  801080:	6a 23                	push   $0x23
  801082:	68 7c 31 80 00       	push   $0x80317c
  801087:	e8 4b f5 ff ff       	call   8005d7 <_panic>

0080108c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	asm volatile("int %1\n"
  801092:	ba 00 00 00 00       	mov    $0x0,%edx
  801097:	b8 02 00 00 00       	mov    $0x2,%eax
  80109c:	89 d1                	mov    %edx,%ecx
  80109e:	89 d3                	mov    %edx,%ebx
  8010a0:	89 d7                	mov    %edx,%edi
  8010a2:	89 d6                	mov    %edx,%esi
  8010a4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_yield>:

void
sys_yield(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010bb:	89 d1                	mov    %edx,%ecx
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 d7                	mov    %edx,%edi
  8010c1:	89 d6                	mov    %edx,%esi
  8010c3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010d3:	be 00 00 00 00       	mov    $0x0,%esi
  8010d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010de:	b8 04 00 00 00       	mov    $0x4,%eax
  8010e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010e6:	89 f7                	mov    %esi,%edi
  8010e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	7f 08                	jg     8010f6 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	6a 04                	push   $0x4
  8010fc:	68 5f 31 80 00       	push   $0x80315f
  801101:	6a 23                	push   $0x23
  801103:	68 7c 31 80 00       	push   $0x80317c
  801108:	e8 ca f4 ff ff       	call   8005d7 <_panic>

0080110d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111c:	b8 05 00 00 00       	mov    $0x5,%eax
  801121:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801124:	8b 7d 14             	mov    0x14(%ebp),%edi
  801127:	8b 75 18             	mov    0x18(%ebp),%esi
  80112a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80112c:	85 c0                	test   %eax,%eax
  80112e:	7f 08                	jg     801138 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801130:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801133:	5b                   	pop    %ebx
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	50                   	push   %eax
  80113c:	6a 05                	push   $0x5
  80113e:	68 5f 31 80 00       	push   $0x80315f
  801143:	6a 23                	push   $0x23
  801145:	68 7c 31 80 00       	push   $0x80317c
  80114a:	e8 88 f4 ff ff       	call   8005d7 <_panic>

0080114f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801158:	bb 00 00 00 00       	mov    $0x0,%ebx
  80115d:	8b 55 08             	mov    0x8(%ebp),%edx
  801160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801163:	b8 06 00 00 00       	mov    $0x6,%eax
  801168:	89 df                	mov    %ebx,%edi
  80116a:	89 de                	mov    %ebx,%esi
  80116c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80116e:	85 c0                	test   %eax,%eax
  801170:	7f 08                	jg     80117a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	50                   	push   %eax
  80117e:	6a 06                	push   $0x6
  801180:	68 5f 31 80 00       	push   $0x80315f
  801185:	6a 23                	push   $0x23
  801187:	68 7c 31 80 00       	push   $0x80317c
  80118c:	e8 46 f4 ff ff       	call   8005d7 <_panic>

00801191 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80119a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	b8 08 00 00 00       	mov    $0x8,%eax
  8011aa:	89 df                	mov    %ebx,%edi
  8011ac:	89 de                	mov    %ebx,%esi
  8011ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	7f 08                	jg     8011bc <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b7:	5b                   	pop    %ebx
  8011b8:	5e                   	pop    %esi
  8011b9:	5f                   	pop    %edi
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	50                   	push   %eax
  8011c0:	6a 08                	push   $0x8
  8011c2:	68 5f 31 80 00       	push   $0x80315f
  8011c7:	6a 23                	push   $0x23
  8011c9:	68 7c 31 80 00       	push   $0x80317c
  8011ce:	e8 04 f4 ff ff       	call   8005d7 <_panic>

008011d3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e7:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ec:	89 df                	mov    %ebx,%edi
  8011ee:	89 de                	mov    %ebx,%esi
  8011f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	7f 08                	jg     8011fe <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	50                   	push   %eax
  801202:	6a 09                	push   $0x9
  801204:	68 5f 31 80 00       	push   $0x80315f
  801209:	6a 23                	push   $0x23
  80120b:	68 7c 31 80 00       	push   $0x80317c
  801210:	e8 c2 f3 ff ff       	call   8005d7 <_panic>

00801215 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80121e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801229:	b8 0a 00 00 00       	mov    $0xa,%eax
  80122e:	89 df                	mov    %ebx,%edi
  801230:	89 de                	mov    %ebx,%esi
  801232:	cd 30                	int    $0x30
	if(check && ret > 0)
  801234:	85 c0                	test   %eax,%eax
  801236:	7f 08                	jg     801240 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801240:	83 ec 0c             	sub    $0xc,%esp
  801243:	50                   	push   %eax
  801244:	6a 0a                	push   $0xa
  801246:	68 5f 31 80 00       	push   $0x80315f
  80124b:	6a 23                	push   $0x23
  80124d:	68 7c 31 80 00       	push   $0x80317c
  801252:	e8 80 f3 ff ff       	call   8005d7 <_panic>

00801257 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	57                   	push   %edi
  80125b:	56                   	push   %esi
  80125c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80125d:	8b 55 08             	mov    0x8(%ebp),%edx
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	b8 0c 00 00 00       	mov    $0xc,%eax
  801268:	be 00 00 00 00       	mov    $0x0,%esi
  80126d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801270:	8b 7d 14             	mov    0x14(%ebp),%edi
  801273:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801275:	5b                   	pop    %ebx
  801276:	5e                   	pop    %esi
  801277:	5f                   	pop    %edi
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	57                   	push   %edi
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801283:	b9 00 00 00 00       	mov    $0x0,%ecx
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
  80128b:	b8 0d 00 00 00       	mov    $0xd,%eax
  801290:	89 cb                	mov    %ecx,%ebx
  801292:	89 cf                	mov    %ecx,%edi
  801294:	89 ce                	mov    %ecx,%esi
  801296:	cd 30                	int    $0x30
	if(check && ret > 0)
  801298:	85 c0                	test   %eax,%eax
  80129a:	7f 08                	jg     8012a4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80129c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	50                   	push   %eax
  8012a8:	6a 0d                	push   $0xd
  8012aa:	68 5f 31 80 00       	push   $0x80315f
  8012af:	6a 23                	push   $0x23
  8012b1:	68 7c 31 80 00       	push   $0x80317c
  8012b6:	e8 1c f3 ff ff       	call   8005d7 <_panic>

008012bb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 04             	sub    $0x4,%esp
  8012c2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8012c5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8012c7:	8b 40 04             	mov    0x4(%eax),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
    if (!(err & FEC_WR) || !(uvpt[PGNUM(addr)] & PTE_COW))
  8012ca:	a8 02                	test   $0x2,%al
  8012cc:	0f 84 89 00 00 00    	je     80135b <pgfault+0xa0>
  8012d2:	89 da                	mov    %ebx,%edx
  8012d4:	c1 ea 0c             	shr    $0xc,%edx
  8012d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012de:	f6 c6 08             	test   $0x8,%dh
  8012e1:	74 78                	je     80135b <pgfault+0xa0>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
    if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	6a 07                	push   $0x7
  8012e8:	68 00 f0 7f 00       	push   $0x7ff000
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 d6 fd ff ff       	call   8010ca <sys_page_alloc>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	0f 88 8b 00 00 00    	js     80138a <pgfault+0xcf>
        panic("sys_page_alloc error %e", r);
    memmove(PFTEMP, addr, PGSIZE);
  8012ff:	83 ec 04             	sub    $0x4,%esp
  801302:	68 00 10 00 00       	push   $0x1000
  801307:	53                   	push   %ebx
  801308:	68 00 f0 7f 00       	push   $0x7ff000
  80130d:	e8 4d fb ff ff       	call   800e5f <memmove>
    if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  801312:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801319:	53                   	push   %ebx
  80131a:	6a 00                	push   $0x0
  80131c:	68 00 f0 7f 00       	push   $0x7ff000
  801321:	6a 00                	push   $0x0
  801323:	e8 e5 fd ff ff       	call   80110d <sys_page_map>
  801328:	83 c4 20             	add    $0x20,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 6d                	js     80139c <pgfault+0xe1>
        panic("sys_page_map error %e", r);
    if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	68 00 f0 7f 00       	push   $0x7ff000
  801337:	6a 00                	push   $0x0
  801339:	e8 11 fe ff ff       	call   80114f <sys_page_unmap>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 69                	js     8013ae <pgfault+0xf3>
        panic("sys_page_unmap error %e", r);

    cprintf("[fix] fix a cow page, addr: %X \n", addr);
  801345:	83 ec 08             	sub    $0x8,%esp
  801348:	53                   	push   %ebx
  801349:	68 e8 31 80 00       	push   $0x8031e8
  80134e:	e8 5f f3 ff ff       	call   8006b2 <cprintf>

}
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801359:	c9                   	leave  
  80135a:	c3                   	ret    
        panic("Not write to copy-on-write page, err: %x, perm %x, uvpt: %x, utf_fault_va: %x, envid: %x", err, uvpt[PGNUM(addr)], uvpt, addr, thisenv->env_id);
  80135b:	8b 15 04 50 80 00    	mov    0x805004,%edx
  801361:	8b 4a 48             	mov    0x48(%edx),%ecx
  801364:	89 da                	mov    %ebx,%edx
  801366:	c1 ea 0c             	shr    $0xc,%edx
  801369:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801370:	51                   	push   %ecx
  801371:	53                   	push   %ebx
  801372:	68 00 00 40 ef       	push   $0xef400000
  801377:	52                   	push   %edx
  801378:	50                   	push   %eax
  801379:	68 8c 31 80 00       	push   $0x80318c
  80137e:	6a 1e                	push   $0x1e
  801380:	68 09 32 80 00       	push   $0x803209
  801385:	e8 4d f2 ff ff       	call   8005d7 <_panic>
        panic("sys_page_alloc error %e", r);
  80138a:	50                   	push   %eax
  80138b:	68 14 32 80 00       	push   $0x803214
  801390:	6a 28                	push   $0x28
  801392:	68 09 32 80 00       	push   $0x803209
  801397:	e8 3b f2 ff ff       	call   8005d7 <_panic>
        panic("sys_page_map error %e", r);
  80139c:	50                   	push   %eax
  80139d:	68 2c 32 80 00       	push   $0x80322c
  8013a2:	6a 2b                	push   $0x2b
  8013a4:	68 09 32 80 00       	push   $0x803209
  8013a9:	e8 29 f2 ff ff       	call   8005d7 <_panic>
        panic("sys_page_unmap error %e", r);
  8013ae:	50                   	push   %eax
  8013af:	68 42 32 80 00       	push   $0x803242
  8013b4:	6a 2d                	push   $0x2d
  8013b6:	68 09 32 80 00       	push   $0x803209
  8013bb:	e8 17 f2 ff ff       	call   8005d7 <_panic>

008013c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013c6:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8013cd:	74 23                	je     8013f2 <set_pgfault_handler+0x32>
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
            panic("sys_page_alloc: %e", r);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d2:	a3 08 50 80 00       	mov    %eax,0x805008
    sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8013d7:	a1 04 50 80 00       	mov    0x805004,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 08             	sub    $0x8,%esp
  8013e2:	68 83 28 80 00       	push   $0x802883
  8013e7:	50                   	push   %eax
  8013e8:	e8 28 fe ff ff       	call   801215 <sys_env_set_pgfault_upcall>
}
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    
        if ((r = sys_page_alloc(thisenv->env_id, (void * )(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0)
  8013f2:	a1 04 50 80 00       	mov    0x805004,%eax
  8013f7:	8b 40 48             	mov    0x48(%eax),%eax
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	6a 07                	push   $0x7
  8013ff:	68 00 f0 bf ee       	push   $0xeebff000
  801404:	50                   	push   %eax
  801405:	e8 c0 fc ff ff       	call   8010ca <sys_page_alloc>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 c0                	test   %eax,%eax
  80140f:	79 be                	jns    8013cf <set_pgfault_handler+0xf>
            panic("sys_page_alloc: %e", r);
  801411:	50                   	push   %eax
  801412:	68 5a 32 80 00       	push   $0x80325a
  801417:	6a 21                	push   $0x21
  801419:	68 6d 32 80 00       	push   $0x80326d
  80141e:	e8 b4 f1 ff ff       	call   8005d7 <_panic>

00801423 <copy_to>:
	return 0;
}

void
copy_to(envid_t dstenv, void *addr)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	8b 75 08             	mov    0x8(%ebp),%esi
  80142b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    int r;

    // This is NOT what you should do in your fork.
    if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80142e:	83 ec 04             	sub    $0x4,%esp
  801431:	6a 07                	push   $0x7
  801433:	53                   	push   %ebx
  801434:	56                   	push   %esi
  801435:	e8 90 fc ff ff       	call   8010ca <sys_page_alloc>
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	85 c0                	test   %eax,%eax
  80143f:	78 4a                	js     80148b <copy_to+0x68>
        panic("sys_page_alloc: %e", r);
    if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801441:	83 ec 0c             	sub    $0xc,%esp
  801444:	6a 07                	push   $0x7
  801446:	68 00 00 40 00       	push   $0x400000
  80144b:	6a 00                	push   $0x0
  80144d:	53                   	push   %ebx
  80144e:	56                   	push   %esi
  80144f:	e8 b9 fc ff ff       	call   80110d <sys_page_map>
  801454:	83 c4 20             	add    $0x20,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 42                	js     80149d <copy_to+0x7a>
        panic("sys_page_map: %e", r);
    memmove(UTEMP, addr, PGSIZE);
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	68 00 10 00 00       	push   $0x1000
  801463:	53                   	push   %ebx
  801464:	68 00 00 40 00       	push   $0x400000
  801469:	e8 f1 f9 ff ff       	call   800e5f <memmove>
    if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	68 00 00 40 00       	push   $0x400000
  801476:	6a 00                	push   $0x0
  801478:	e8 d2 fc ff ff       	call   80114f <sys_page_unmap>
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 2b                	js     8014af <copy_to+0x8c>
        panic("sys_page_unmap: %e", r);
}
  801484:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    
        panic("sys_page_alloc: %e", r);
  80148b:	50                   	push   %eax
  80148c:	68 5a 32 80 00       	push   $0x80325a
  801491:	6a 63                	push   $0x63
  801493:	68 09 32 80 00       	push   $0x803209
  801498:	e8 3a f1 ff ff       	call   8005d7 <_panic>
        panic("sys_page_map: %e", r);
  80149d:	50                   	push   %eax
  80149e:	68 7d 32 80 00       	push   $0x80327d
  8014a3:	6a 65                	push   $0x65
  8014a5:	68 09 32 80 00       	push   $0x803209
  8014aa:	e8 28 f1 ff ff       	call   8005d7 <_panic>
        panic("sys_page_unmap: %e", r);
  8014af:	50                   	push   %eax
  8014b0:	68 8e 32 80 00       	push   $0x80328e
  8014b5:	6a 68                	push   $0x68
  8014b7:	68 09 32 80 00       	push   $0x803209
  8014bc:	e8 16 f1 ff ff       	call   8005d7 <_panic>

008014c1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	57                   	push   %edi
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
    envid_t envid;
    int r;
    // 1- set up pgfault handler
    if (thisenv->env_pgfault_upcall == NULL) {
  8014ca:	a1 04 50 80 00       	mov    0x805004,%eax
  8014cf:	8b 40 64             	mov    0x64(%eax),%eax
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	74 1f                	je     8014f5 <fork+0x34>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8014d6:	b8 07 00 00 00       	mov    $0x7,%eax
  8014db:	cd 30                	int    $0x30
  8014dd:	89 c3                	mov    %eax,%ebx
        set_pgfault_handler(pgfault);
    }

    // 2- create a child process
    if ((envid = sys_exofork()) == 0) {
  8014df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	74 21                	je     801507 <fork+0x46>
        return 0;
    }

    // 3- map pages
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
        if (i  == PGNUM(&_pgfault_handler) ){
  8014e6:	be 08 50 80 00       	mov    $0x805008,%esi
  8014eb:	c1 ee 0c             	shr    $0xc,%esi
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f3:	eb 7b                	jmp    801570 <fork+0xaf>
        set_pgfault_handler(pgfault);
  8014f5:	83 ec 0c             	sub    $0xc,%esp
  8014f8:	68 bb 12 80 00       	push   $0x8012bb
  8014fd:	e8 be fe ff ff       	call   8013c0 <set_pgfault_handler>
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb cf                	jmp    8014d6 <fork+0x15>
        set_pgfault_handler(pgfault);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	68 bb 12 80 00       	push   $0x8012bb
  80150f:	e8 ac fe ff ff       	call   8013c0 <set_pgfault_handler>
        thisenv = &envs[ENVX(sys_getenvid())];
  801514:	e8 73 fb ff ff       	call   80108c <sys_getenvid>
  801519:	25 ff 03 00 00       	and    $0x3ff,%eax
  80151e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801521:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801526:	a3 04 50 80 00       	mov    %eax,0x805004
        return 0;
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	e9 ca 00 00 00       	jmp    8015fd <fork+0x13c>
    perm = pte & PTE_SYSCALL;
  801533:	89 d1                	mov    %edx,%ecx
  801535:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
        perm = perm & (PTE_COW | PTE_W) ? perm | PTE_COW : perm;
  80153b:	81 e2 02 08 00 00    	and    $0x802,%edx
  801541:	89 cf                	mov    %ecx,%edi
  801543:	81 cf 00 08 00 00    	or     $0x800,%edi
  801549:	85 d2                	test   %edx,%edx
  80154b:	0f 45 cf             	cmovne %edi,%ecx
    if ((r = sys_page_map(0, va, envid, va, perm)) < 0)
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	51                   	push   %ecx
  801552:	50                   	push   %eax
  801553:	ff 75 e4             	pushl  -0x1c(%ebp)
  801556:	50                   	push   %eax
  801557:	6a 00                	push   $0x0
  801559:	e8 af fb ff ff       	call   80110d <sys_page_map>
  80155e:	83 c4 20             	add    $0x20,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	78 45                	js     8015aa <fork+0xe9>
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  801565:	83 c3 01             	add    $0x1,%ebx
  801568:	81 fb fd eb 0e 00    	cmp    $0xeebfd,%ebx
  80156e:	74 4c                	je     8015bc <fork+0xfb>
        if (i  == PGNUM(&_pgfault_handler) ){
  801570:	39 de                	cmp    %ebx,%esi
  801572:	74 f1                	je     801565 <fork+0xa4>
  801574:	89 d8                	mov    %ebx,%eax
  801576:	c1 e0 0c             	shl    $0xc,%eax
    pde = (pte_t)uvpd[PDX(va)];
  801579:	89 c2                	mov    %eax,%edx
  80157b:	c1 ea 16             	shr    $0x16,%edx
  80157e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
    if (!(pde & (PTE_U | PTE_P))) {
  801585:	f6 c2 05             	test   $0x5,%dl
  801588:	74 db                	je     801565 <fork+0xa4>
    pte = (pte_t)uvpt[PGNUM(va)];
  80158a:	89 c2                	mov    %eax,%edx
  80158c:	c1 ea 0c             	shr    $0xc,%edx
  80158f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
    if (!(pte & PTE_U)) {
  801596:	f6 c2 04             	test   $0x4,%dl
  801599:	74 ca                	je     801565 <fork+0xa4>
    if (perm & PTE_SHARE) {
  80159b:	f6 c6 04             	test   $0x4,%dh
  80159e:	74 93                	je     801533 <fork+0x72>
        perm &= ~PTE_COW;
  8015a0:	89 d1                	mov    %edx,%ecx
  8015a2:	81 e1 07 06 00 00    	and    $0x607,%ecx
  8015a8:	eb a4                	jmp    80154e <fork+0x8d>
        panic("sys_page_map error %e", r);
  8015aa:	50                   	push   %eax
  8015ab:	68 2c 32 80 00       	push   $0x80322c
  8015b0:	6a 57                	push   $0x57
  8015b2:	68 09 32 80 00       	push   $0x803209
  8015b7:	e8 1b f0 ff ff       	call   8005d7 <_panic>
        }
        duppage(envid, i);
    }

    // 4- copy stack page
    copy_to(envid, ROUNDDOWN(&_pgfault_handler, PGSIZE));
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	b8 08 50 80 00       	mov    $0x805008,%eax
  8015c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015cd:	e8 51 fe ff ff       	call   801423 <copy_to>
    copy_to(envid, ROUNDDOWN(&envid, PGSIZE));
  8015d2:	83 c4 08             	add    $0x8,%esp
  8015d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8015dd:	50                   	push   %eax
  8015de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e1:	e8 3d fe ff ff       	call   801423 <copy_to>


    // Start the child environment running
    if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8015e6:	83 c4 08             	add    $0x8,%esp
  8015e9:	6a 02                	push   $0x2
  8015eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ee:	e8 9e fb ff ff       	call   801191 <sys_env_set_status>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 0d                	js     801607 <fork+0x146>
        panic("sys_env_set_status: %e", r);

    return envid;
  8015fa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
}
  8015fd:	89 d8                	mov    %ebx,%eax
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    
        panic("sys_env_set_status: %e", r);
  801607:	50                   	push   %eax
  801608:	68 a1 32 80 00       	push   $0x8032a1
  80160d:	68 a0 00 00 00       	push   $0xa0
  801612:	68 09 32 80 00       	push   $0x803209
  801617:	e8 bb ef ff ff       	call   8005d7 <_panic>

0080161c <sfork>:

// Challenge!
int
sfork(void)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801622:	68 b8 32 80 00       	push   $0x8032b8
  801627:	68 a9 00 00 00       	push   $0xa9
  80162c:	68 09 32 80 00       	push   $0x803209
  801631:	e8 a1 ef ff ff       	call   8005d7 <_panic>

00801636 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801639:	8b 45 08             	mov    0x8(%ebp),%eax
  80163c:	05 00 00 00 30       	add    $0x30000000,%eax
  801641:	c1 e8 0c             	shr    $0xc,%eax
}
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801651:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801656:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    

0080165d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801663:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801668:	89 c2                	mov    %eax,%edx
  80166a:	c1 ea 16             	shr    $0x16,%edx
  80166d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801674:	f6 c2 01             	test   $0x1,%dl
  801677:	74 2a                	je     8016a3 <fd_alloc+0x46>
  801679:	89 c2                	mov    %eax,%edx
  80167b:	c1 ea 0c             	shr    $0xc,%edx
  80167e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801685:	f6 c2 01             	test   $0x1,%dl
  801688:	74 19                	je     8016a3 <fd_alloc+0x46>
  80168a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80168f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801694:	75 d2                	jne    801668 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801696:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80169c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8016a1:	eb 07                	jmp    8016aa <fd_alloc+0x4d>
			*fd_store = fd;
  8016a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016b2:	83 f8 1f             	cmp    $0x1f,%eax
  8016b5:	77 36                	ja     8016ed <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016b7:	c1 e0 0c             	shl    $0xc,%eax
  8016ba:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	c1 ea 16             	shr    $0x16,%edx
  8016c4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016cb:	f6 c2 01             	test   $0x1,%dl
  8016ce:	74 24                	je     8016f4 <fd_lookup+0x48>
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	c1 ea 0c             	shr    $0xc,%edx
  8016d5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016dc:	f6 c2 01             	test   $0x1,%dl
  8016df:	74 1a                	je     8016fb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e4:	89 02                	mov    %eax,(%edx)
	return 0;
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    
		return -E_INVAL;
  8016ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f2:	eb f7                	jmp    8016eb <fd_lookup+0x3f>
		return -E_INVAL;
  8016f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f9:	eb f0                	jmp    8016eb <fd_lookup+0x3f>
  8016fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801700:	eb e9                	jmp    8016eb <fd_lookup+0x3f>

00801702 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170b:	ba 4c 33 80 00       	mov    $0x80334c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801710:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801715:	39 08                	cmp    %ecx,(%eax)
  801717:	74 33                	je     80174c <dev_lookup+0x4a>
  801719:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80171c:	8b 02                	mov    (%edx),%eax
  80171e:	85 c0                	test   %eax,%eax
  801720:	75 f3                	jne    801715 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801722:	a1 04 50 80 00       	mov    0x805004,%eax
  801727:	8b 40 48             	mov    0x48(%eax),%eax
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	51                   	push   %ecx
  80172e:	50                   	push   %eax
  80172f:	68 d0 32 80 00       	push   $0x8032d0
  801734:	e8 79 ef ff ff       	call   8006b2 <cprintf>
	*dev = 0;
  801739:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80174a:	c9                   	leave  
  80174b:	c3                   	ret    
			*dev = devtab[i];
  80174c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801751:	b8 00 00 00 00       	mov    $0x0,%eax
  801756:	eb f2                	jmp    80174a <dev_lookup+0x48>

00801758 <fd_close>:
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	8b 75 08             	mov    0x8(%ebp),%esi
  801764:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801767:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80176a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80176b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801771:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801774:	50                   	push   %eax
  801775:	e8 32 ff ff ff       	call   8016ac <fd_lookup>
  80177a:	89 c3                	mov    %eax,%ebx
  80177c:	83 c4 08             	add    $0x8,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 05                	js     801788 <fd_close+0x30>
	    || fd != fd2)
  801783:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801786:	74 16                	je     80179e <fd_close+0x46>
		return (must_exist ? r : 0);
  801788:	89 f8                	mov    %edi,%eax
  80178a:	84 c0                	test   %al,%al
  80178c:	b8 00 00 00 00       	mov    $0x0,%eax
  801791:	0f 44 d8             	cmove  %eax,%ebx
}
  801794:	89 d8                	mov    %ebx,%eax
  801796:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5f                   	pop    %edi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	ff 36                	pushl  (%esi)
  8017a7:	e8 56 ff ff ff       	call   801702 <dev_lookup>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 15                	js     8017ca <fd_close+0x72>
		if (dev->dev_close)
  8017b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b8:	8b 40 10             	mov    0x10(%eax),%eax
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	74 1b                	je     8017da <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	56                   	push   %esi
  8017c3:	ff d0                	call   *%eax
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	56                   	push   %esi
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 7a f9 ff ff       	call   80114f <sys_page_unmap>
	return r;
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	eb ba                	jmp    801794 <fd_close+0x3c>
			r = 0;
  8017da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017df:	eb e9                	jmp    8017ca <fd_close+0x72>

008017e1 <close>:

int
close(int fdnum)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 08             	pushl  0x8(%ebp)
  8017ee:	e8 b9 fe ff ff       	call   8016ac <fd_lookup>
  8017f3:	83 c4 08             	add    $0x8,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 10                	js     80180a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	6a 01                	push   $0x1
  8017ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801802:	e8 51 ff ff ff       	call   801758 <fd_close>
  801807:	83 c4 10             	add    $0x10,%esp
}
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    

0080180c <close_all>:

void
close_all(void)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	53                   	push   %ebx
  801810:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801813:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801818:	83 ec 0c             	sub    $0xc,%esp
  80181b:	53                   	push   %ebx
  80181c:	e8 c0 ff ff ff       	call   8017e1 <close>
	for (i = 0; i < MAXFD; i++)
  801821:	83 c3 01             	add    $0x1,%ebx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	83 fb 20             	cmp    $0x20,%ebx
  80182a:	75 ec                	jne    801818 <close_all+0xc>
}
  80182c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182f:	c9                   	leave  
  801830:	c3                   	ret    

00801831 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	57                   	push   %edi
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80183a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	ff 75 08             	pushl  0x8(%ebp)
  801841:	e8 66 fe ff ff       	call   8016ac <fd_lookup>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	83 c4 08             	add    $0x8,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	0f 88 81 00 00 00    	js     8018d4 <dup+0xa3>
		return r;
	close(newfdnum);
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	ff 75 0c             	pushl  0xc(%ebp)
  801859:	e8 83 ff ff ff       	call   8017e1 <close>

	newfd = INDEX2FD(newfdnum);
  80185e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801861:	c1 e6 0c             	shl    $0xc,%esi
  801864:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80186a:	83 c4 04             	add    $0x4,%esp
  80186d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801870:	e8 d1 fd ff ff       	call   801646 <fd2data>
  801875:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801877:	89 34 24             	mov    %esi,(%esp)
  80187a:	e8 c7 fd ff ff       	call   801646 <fd2data>
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801884:	89 d8                	mov    %ebx,%eax
  801886:	c1 e8 16             	shr    $0x16,%eax
  801889:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801890:	a8 01                	test   $0x1,%al
  801892:	74 11                	je     8018a5 <dup+0x74>
  801894:	89 d8                	mov    %ebx,%eax
  801896:	c1 e8 0c             	shr    $0xc,%eax
  801899:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018a0:	f6 c2 01             	test   $0x1,%dl
  8018a3:	75 39                	jne    8018de <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018a8:	89 d0                	mov    %edx,%eax
  8018aa:	c1 e8 0c             	shr    $0xc,%eax
  8018ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018b4:	83 ec 0c             	sub    $0xc,%esp
  8018b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8018bc:	50                   	push   %eax
  8018bd:	56                   	push   %esi
  8018be:	6a 00                	push   $0x0
  8018c0:	52                   	push   %edx
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 45 f8 ff ff       	call   80110d <sys_page_map>
  8018c8:	89 c3                	mov    %eax,%ebx
  8018ca:	83 c4 20             	add    $0x20,%esp
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 31                	js     801902 <dup+0xd1>
		goto err;

	return newfdnum;
  8018d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8018d4:	89 d8                	mov    %ebx,%eax
  8018d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d9:	5b                   	pop    %ebx
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ed:	50                   	push   %eax
  8018ee:	57                   	push   %edi
  8018ef:	6a 00                	push   $0x0
  8018f1:	53                   	push   %ebx
  8018f2:	6a 00                	push   $0x0
  8018f4:	e8 14 f8 ff ff       	call   80110d <sys_page_map>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	83 c4 20             	add    $0x20,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	79 a3                	jns    8018a5 <dup+0x74>
	sys_page_unmap(0, newfd);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	56                   	push   %esi
  801906:	6a 00                	push   $0x0
  801908:	e8 42 f8 ff ff       	call   80114f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80190d:	83 c4 08             	add    $0x8,%esp
  801910:	57                   	push   %edi
  801911:	6a 00                	push   $0x0
  801913:	e8 37 f8 ff ff       	call   80114f <sys_page_unmap>
	return r;
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	eb b7                	jmp    8018d4 <dup+0xa3>

0080191d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 14             	sub    $0x14,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801927:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192a:	50                   	push   %eax
  80192b:	53                   	push   %ebx
  80192c:	e8 7b fd ff ff       	call   8016ac <fd_lookup>
  801931:	83 c4 08             	add    $0x8,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 3f                	js     801977 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	50                   	push   %eax
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	ff 30                	pushl  (%eax)
  801944:	e8 b9 fd ff ff       	call   801702 <dev_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 27                	js     801977 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801950:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801953:	8b 42 08             	mov    0x8(%edx),%eax
  801956:	83 e0 03             	and    $0x3,%eax
  801959:	83 f8 01             	cmp    $0x1,%eax
  80195c:	74 1e                	je     80197c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80195e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801961:	8b 40 08             	mov    0x8(%eax),%eax
  801964:	85 c0                	test   %eax,%eax
  801966:	74 35                	je     80199d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	ff 75 10             	pushl  0x10(%ebp)
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	52                   	push   %edx
  801972:	ff d0                	call   *%eax
  801974:	83 c4 10             	add    $0x10,%esp
}
  801977:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80197c:	a1 04 50 80 00       	mov    0x805004,%eax
  801981:	8b 40 48             	mov    0x48(%eax),%eax
  801984:	83 ec 04             	sub    $0x4,%esp
  801987:	53                   	push   %ebx
  801988:	50                   	push   %eax
  801989:	68 11 33 80 00       	push   $0x803311
  80198e:	e8 1f ed ff ff       	call   8006b2 <cprintf>
		return -E_INVAL;
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80199b:	eb da                	jmp    801977 <read+0x5a>
		return -E_NOT_SUPP;
  80199d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a2:	eb d3                	jmp    801977 <read+0x5a>

008019a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b8:	39 f3                	cmp    %esi,%ebx
  8019ba:	73 25                	jae    8019e1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019bc:	83 ec 04             	sub    $0x4,%esp
  8019bf:	89 f0                	mov    %esi,%eax
  8019c1:	29 d8                	sub    %ebx,%eax
  8019c3:	50                   	push   %eax
  8019c4:	89 d8                	mov    %ebx,%eax
  8019c6:	03 45 0c             	add    0xc(%ebp),%eax
  8019c9:	50                   	push   %eax
  8019ca:	57                   	push   %edi
  8019cb:	e8 4d ff ff ff       	call   80191d <read>
		if (m < 0)
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 08                	js     8019df <readn+0x3b>
			return m;
		if (m == 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	74 06                	je     8019e1 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8019db:	01 c3                	add    %eax,%ebx
  8019dd:	eb d9                	jmp    8019b8 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019df:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8019e1:	89 d8                	mov    %ebx,%eax
  8019e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5f                   	pop    %edi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	53                   	push   %ebx
  8019ef:	83 ec 14             	sub    $0x14,%esp
  8019f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f8:	50                   	push   %eax
  8019f9:	53                   	push   %ebx
  8019fa:	e8 ad fc ff ff       	call   8016ac <fd_lookup>
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 3a                	js     801a40 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a10:	ff 30                	pushl  (%eax)
  801a12:	e8 eb fc ff ff       	call   801702 <dev_lookup>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 22                	js     801a40 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a21:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a25:	74 1e                	je     801a45 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a2a:	8b 52 0c             	mov    0xc(%edx),%edx
  801a2d:	85 d2                	test   %edx,%edx
  801a2f:	74 35                	je     801a66 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a31:	83 ec 04             	sub    $0x4,%esp
  801a34:	ff 75 10             	pushl  0x10(%ebp)
  801a37:	ff 75 0c             	pushl  0xc(%ebp)
  801a3a:	50                   	push   %eax
  801a3b:	ff d2                	call   *%edx
  801a3d:	83 c4 10             	add    $0x10,%esp
}
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a45:	a1 04 50 80 00       	mov    0x805004,%eax
  801a4a:	8b 40 48             	mov    0x48(%eax),%eax
  801a4d:	83 ec 04             	sub    $0x4,%esp
  801a50:	53                   	push   %ebx
  801a51:	50                   	push   %eax
  801a52:	68 2d 33 80 00       	push   $0x80332d
  801a57:	e8 56 ec ff ff       	call   8006b2 <cprintf>
		return -E_INVAL;
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a64:	eb da                	jmp    801a40 <write+0x55>
		return -E_NOT_SUPP;
  801a66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a6b:	eb d3                	jmp    801a40 <write+0x55>

00801a6d <seek>:

int
seek(int fdnum, off_t offset)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a73:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	ff 75 08             	pushl  0x8(%ebp)
  801a7a:	e8 2d fc ff ff       	call   8016ac <fd_lookup>
  801a7f:	83 c4 08             	add    $0x8,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 0e                	js     801a94 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a8c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 14             	sub    $0x14,%esp
  801a9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa3:	50                   	push   %eax
  801aa4:	53                   	push   %ebx
  801aa5:	e8 02 fc ff ff       	call   8016ac <fd_lookup>
  801aaa:	83 c4 08             	add    $0x8,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 37                	js     801ae8 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab1:	83 ec 08             	sub    $0x8,%esp
  801ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abb:	ff 30                	pushl  (%eax)
  801abd:	e8 40 fc ff ff       	call   801702 <dev_lookup>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 1f                	js     801ae8 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad0:	74 1b                	je     801aed <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801ad2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad5:	8b 52 18             	mov    0x18(%edx),%edx
  801ad8:	85 d2                	test   %edx,%edx
  801ada:	74 32                	je     801b0e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801adc:	83 ec 08             	sub    $0x8,%esp
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	50                   	push   %eax
  801ae3:	ff d2                	call   *%edx
  801ae5:	83 c4 10             	add    $0x10,%esp
}
  801ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    
			thisenv->env_id, fdnum);
  801aed:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801af2:	8b 40 48             	mov    0x48(%eax),%eax
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	53                   	push   %ebx
  801af9:	50                   	push   %eax
  801afa:	68 f0 32 80 00       	push   $0x8032f0
  801aff:	e8 ae eb ff ff       	call   8006b2 <cprintf>
		return -E_INVAL;
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b0c:	eb da                	jmp    801ae8 <ftruncate+0x52>
		return -E_NOT_SUPP;
  801b0e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b13:	eb d3                	jmp    801ae8 <ftruncate+0x52>

00801b15 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 14             	sub    $0x14,%esp
  801b1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b22:	50                   	push   %eax
  801b23:	ff 75 08             	pushl  0x8(%ebp)
  801b26:	e8 81 fb ff ff       	call   8016ac <fd_lookup>
  801b2b:	83 c4 08             	add    $0x8,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 4b                	js     801b7d <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b32:	83 ec 08             	sub    $0x8,%esp
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	50                   	push   %eax
  801b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3c:	ff 30                	pushl  (%eax)
  801b3e:	e8 bf fb ff ff       	call   801702 <dev_lookup>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 33                	js     801b7d <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b51:	74 2f                	je     801b82 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b53:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b56:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b5d:	00 00 00 
	stat->st_isdir = 0;
  801b60:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b67:	00 00 00 
	stat->st_dev = dev;
  801b6a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b70:	83 ec 08             	sub    $0x8,%esp
  801b73:	53                   	push   %ebx
  801b74:	ff 75 f0             	pushl  -0x10(%ebp)
  801b77:	ff 50 14             	call   *0x14(%eax)
  801b7a:	83 c4 10             	add    $0x10,%esp
}
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    
		return -E_NOT_SUPP;
  801b82:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b87:	eb f4                	jmp    801b7d <fstat+0x68>

00801b89 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	56                   	push   %esi
  801b8d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b8e:	83 ec 08             	sub    $0x8,%esp
  801b91:	6a 00                	push   $0x0
  801b93:	ff 75 08             	pushl  0x8(%ebp)
  801b96:	e8 e7 01 00 00       	call   801d82 <open>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	78 1b                	js     801bbf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801ba4:	83 ec 08             	sub    $0x8,%esp
  801ba7:	ff 75 0c             	pushl  0xc(%ebp)
  801baa:	50                   	push   %eax
  801bab:	e8 65 ff ff ff       	call   801b15 <fstat>
  801bb0:	89 c6                	mov    %eax,%esi
	close(fd);
  801bb2:	89 1c 24             	mov    %ebx,(%esp)
  801bb5:	e8 27 fc ff ff       	call   8017e1 <close>
	return r;
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	89 f3                	mov    %esi,%ebx
}
  801bbf:	89 d8                	mov    %ebx,%eax
  801bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	89 c6                	mov    %eax,%esi
  801bcf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801bd1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801bd8:	74 27                	je     801c01 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bda:	6a 07                	push   $0x7
  801bdc:	68 00 60 80 00       	push   $0x806000
  801be1:	56                   	push   %esi
  801be2:	ff 35 00 50 80 00    	pushl  0x805000
  801be8:	e8 1d 0d 00 00       	call   80290a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bed:	83 c4 0c             	add    $0xc,%esp
  801bf0:	6a 00                	push   $0x0
  801bf2:	53                   	push   %ebx
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 af 0c 00 00       	call   8028a9 <ipc_recv>
}
  801bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c01:	83 ec 0c             	sub    $0xc,%esp
  801c04:	6a 01                	push   $0x1
  801c06:	e8 4c 0d 00 00       	call   802957 <ipc_find_env>
  801c0b:	a3 00 50 80 00       	mov    %eax,0x805000
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	eb c5                	jmp    801bda <fsipc+0x12>

00801c15 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c15:	55                   	push   %ebp
  801c16:	89 e5                	mov    %esp,%ebp
  801c18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c21:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c29:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c33:	b8 02 00 00 00       	mov    $0x2,%eax
  801c38:	e8 8b ff ff ff       	call   801bc8 <fsipc>
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    

00801c3f <devfile_flush>:
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c45:	8b 45 08             	mov    0x8(%ebp),%eax
  801c48:	8b 40 0c             	mov    0xc(%eax),%eax
  801c4b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801c50:	ba 00 00 00 00       	mov    $0x0,%edx
  801c55:	b8 06 00 00 00       	mov    $0x6,%eax
  801c5a:	e8 69 ff ff ff       	call   801bc8 <fsipc>
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <devfile_stat>:
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	53                   	push   %ebx
  801c65:	83 ec 04             	sub    $0x4,%esp
  801c68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c76:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7b:	b8 05 00 00 00       	mov    $0x5,%eax
  801c80:	e8 43 ff ff ff       	call   801bc8 <fsipc>
  801c85:	85 c0                	test   %eax,%eax
  801c87:	78 2c                	js     801cb5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c89:	83 ec 08             	sub    $0x8,%esp
  801c8c:	68 00 60 80 00       	push   $0x806000
  801c91:	53                   	push   %ebx
  801c92:	e8 3a f0 ff ff       	call   800cd1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c97:	a1 80 60 80 00       	mov    0x806080,%eax
  801c9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ca2:	a1 84 60 80 00       	mov    0x806084,%eax
  801ca7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cad:	83 c4 10             	add    $0x10,%esp
  801cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb8:	c9                   	leave  
  801cb9:	c3                   	ret    

00801cba <devfile_write>:
{
  801cba:	55                   	push   %ebp
  801cbb:	89 e5                	mov    %esp,%ebp
  801cbd:	83 ec 0c             	sub    $0xc,%esp
  801cc0:	8b 45 10             	mov    0x10(%ebp),%eax
    n = MIN(n, PGSIZE - (sizeof(int) + sizeof(size_t)));
  801cc3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801cc8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ccd:	0f 47 c2             	cmova  %edx,%eax
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  801cd3:	8b 52 0c             	mov    0xc(%edx),%edx
  801cd6:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  801cdc:	a3 04 60 80 00       	mov    %eax,0x806004
    memmove(fsipcbuf.write.req_buf, buf, n);
  801ce1:	50                   	push   %eax
  801ce2:	ff 75 0c             	pushl  0xc(%ebp)
  801ce5:	68 08 60 80 00       	push   $0x806008
  801cea:	e8 70 f1 ff ff       	call   800e5f <memmove>
    return fsipc(FSREQ_WRITE, NULL);
  801cef:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf4:	b8 04 00 00 00       	mov    $0x4,%eax
  801cf9:	e8 ca fe ff ff       	call   801bc8 <fsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <devfile_read>:
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801d0e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d13:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d19:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1e:	b8 03 00 00 00       	mov    $0x3,%eax
  801d23:	e8 a0 fe ff ff       	call   801bc8 <fsipc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 1f                	js     801d4d <devfile_read+0x4d>
	assert(r <= n);
  801d2e:	39 f0                	cmp    %esi,%eax
  801d30:	77 24                	ja     801d56 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801d32:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d37:	7f 33                	jg     801d6c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	50                   	push   %eax
  801d3d:	68 00 60 80 00       	push   $0x806000
  801d42:	ff 75 0c             	pushl  0xc(%ebp)
  801d45:	e8 15 f1 ff ff       	call   800e5f <memmove>
	return r;
  801d4a:	83 c4 10             	add    $0x10,%esp
}
  801d4d:	89 d8                	mov    %ebx,%eax
  801d4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    
	assert(r <= n);
  801d56:	68 5c 33 80 00       	push   $0x80335c
  801d5b:	68 63 33 80 00       	push   $0x803363
  801d60:	6a 7d                	push   $0x7d
  801d62:	68 78 33 80 00       	push   $0x803378
  801d67:	e8 6b e8 ff ff       	call   8005d7 <_panic>
	assert(r <= PGSIZE);
  801d6c:	68 83 33 80 00       	push   $0x803383
  801d71:	68 63 33 80 00       	push   $0x803363
  801d76:	6a 7e                	push   $0x7e
  801d78:	68 78 33 80 00       	push   $0x803378
  801d7d:	e8 55 e8 ff ff       	call   8005d7 <_panic>

00801d82 <open>:
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	83 ec 1c             	sub    $0x1c,%esp
  801d8a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801d8d:	56                   	push   %esi
  801d8e:	e8 07 ef ff ff       	call   800c9a <strlen>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d9b:	0f 8f 96 00 00 00    	jg     801e37 <open+0xb5>
	if ((r = fd_alloc(&fd)) < 0)
  801da1:	83 ec 0c             	sub    $0xc,%esp
  801da4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da7:	50                   	push   %eax
  801da8:	e8 b0 f8 ff ff       	call   80165d <fd_alloc>
  801dad:	89 c3                	mov    %eax,%ebx
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 66                	js     801e1c <open+0x9a>
	strcpy(fsipcbuf.open.req_path, path);
  801db6:	83 ec 08             	sub    $0x8,%esp
  801db9:	56                   	push   %esi
  801dba:	68 00 60 80 00       	push   $0x806000
  801dbf:	e8 0d ef ff ff       	call   800cd1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801dcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dcf:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd4:	e8 ef fd ff ff       	call   801bc8 <fsipc>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 43                	js     801e25 <open+0xa3>
    cprintf("[%08x] ----------- open 1 path=%s, dev_id=%x, addr:%x, fd:%d \n", thisenv->env_id, path, fd->fd_dev_id, fd,  fd2num(fd));
  801de2:	83 ec 0c             	sub    $0xc,%esp
  801de5:	ff 75 f4             	pushl  -0xc(%ebp)
  801de8:	e8 49 f8 ff ff       	call   801636 <fd2num>
  801ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df0:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  801df6:	8b 49 48             	mov    0x48(%ecx),%ecx
  801df9:	83 c4 08             	add    $0x8,%esp
  801dfc:	50                   	push   %eax
  801dfd:	52                   	push   %edx
  801dfe:	ff 32                	pushl  (%edx)
  801e00:	56                   	push   %esi
  801e01:	51                   	push   %ecx
  801e02:	68 90 33 80 00       	push   $0x803390
  801e07:	e8 a6 e8 ff ff       	call   8006b2 <cprintf>
	return fd2num(fd);
  801e0c:	83 c4 14             	add    $0x14,%esp
  801e0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e12:	e8 1f f8 ff ff       	call   801636 <fd2num>
  801e17:	89 c3                	mov    %eax,%ebx
  801e19:	83 c4 10             	add    $0x10,%esp
}
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    
		fd_close(fd, 0);
  801e25:	83 ec 08             	sub    $0x8,%esp
  801e28:	6a 00                	push   $0x0
  801e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2d:	e8 26 f9 ff ff       	call   801758 <fd_close>
		return r;
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	eb e5                	jmp    801e1c <open+0x9a>
		return -E_BAD_PATH;
  801e37:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e3c:	eb de                	jmp    801e1c <open+0x9a>

00801e3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e44:	ba 00 00 00 00       	mov    $0x0,%edx
  801e49:	b8 08 00 00 00       	mov    $0x8,%eax
  801e4e:	e8 75 fd ff ff       	call   801bc8 <fsipc>
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	c1 e8 16             	shr    $0x16,%eax
  801e60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e67:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e6c:	f6 c1 01             	test   $0x1,%cl
  801e6f:	74 1d                	je     801e8e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e71:	c1 ea 0c             	shr    $0xc,%edx
  801e74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e7b:	f6 c2 01             	test   $0x1,%dl
  801e7e:	74 0e                	je     801e8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e80:	c1 ea 0c             	shr    $0xc,%edx
  801e83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e8a:	ef 
  801e8b:	0f b7 c0             	movzwl %ax,%eax
}
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	57                   	push   %edi
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801e9c:	6a 00                	push   $0x0
  801e9e:	ff 75 08             	pushl  0x8(%ebp)
  801ea1:	e8 dc fe ff ff       	call   801d82 <open>
  801ea6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	0f 88 40 03 00 00    	js     8021f7 <spawn+0x367>
  801eb7:	89 c1                	mov    %eax,%ecx
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801eb9:	83 ec 04             	sub    $0x4,%esp
  801ebc:	68 00 02 00 00       	push   $0x200
  801ec1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ec7:	50                   	push   %eax
  801ec8:	51                   	push   %ecx
  801ec9:	e8 d6 fa ff ff       	call   8019a4 <readn>
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ed6:	75 5d                	jne    801f35 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  801ed8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801edf:	45 4c 46 
  801ee2:	75 51                	jne    801f35 <spawn+0xa5>
  801ee4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ee9:	cd 30                	int    $0x30
  801eeb:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801ef1:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	0f 88 79 04 00 00    	js     802378 <spawn+0x4e8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801eff:	25 ff 03 00 00       	and    $0x3ff,%eax
  801f04:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801f07:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801f0d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801f13:	b9 11 00 00 00       	mov    $0x11,%ecx
  801f18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f1a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f20:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801f26:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801f2b:	be 00 00 00 00       	mov    $0x0,%esi
  801f30:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f33:	eb 4b                	jmp    801f80 <spawn+0xf0>
		close(fd);
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f3e:	e8 9e f8 ff ff       	call   8017e1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f43:	83 c4 0c             	add    $0xc,%esp
  801f46:	68 7f 45 4c 46       	push   $0x464c457f
  801f4b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801f51:	68 cf 33 80 00       	push   $0x8033cf
  801f56:	e8 57 e7 ff ff       	call   8006b2 <cprintf>
		return -E_NOT_EXEC;
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801f65:	ff ff ff 
  801f68:	e9 8a 02 00 00       	jmp    8021f7 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	50                   	push   %eax
  801f71:	e8 24 ed ff ff       	call   800c9a <strlen>
  801f76:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801f7a:	83 c3 01             	add    $0x1,%ebx
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801f87:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	75 df                	jne    801f6d <spawn+0xdd>
  801f8e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801f94:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801f9a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801f9f:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801fa1:	89 fa                	mov    %edi,%edx
  801fa3:	83 e2 fc             	and    $0xfffffffc,%edx
  801fa6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801fad:	29 c2                	sub    %eax,%edx
  801faf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801fb5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801fb8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801fbd:	0f 86 c6 03 00 00    	jbe    802389 <spawn+0x4f9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801fc3:	83 ec 04             	sub    $0x4,%esp
  801fc6:	6a 07                	push   $0x7
  801fc8:	68 00 00 40 00       	push   $0x400000
  801fcd:	6a 00                	push   $0x0
  801fcf:	e8 f6 f0 ff ff       	call   8010ca <sys_page_alloc>
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	0f 88 af 03 00 00    	js     80238e <spawn+0x4fe>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801fdf:	be 00 00 00 00       	mov    $0x0,%esi
  801fe4:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801fea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801fed:	eb 30                	jmp    80201f <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801fef:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801ff5:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801ffb:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802004:	57                   	push   %edi
  802005:	e8 c7 ec ff ff       	call   800cd1 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80200a:	83 c4 04             	add    $0x4,%esp
  80200d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802010:	e8 85 ec ff ff       	call   800c9a <strlen>
  802015:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802019:	83 c6 01             	add    $0x1,%esi
  80201c:	83 c4 10             	add    $0x10,%esp
  80201f:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  802025:	7f c8                	jg     801fef <spawn+0x15f>
	}
	argv_store[argc] = 0;
  802027:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80202d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802033:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80203a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802040:	0f 85 8c 00 00 00    	jne    8020d2 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802046:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80204c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802052:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802055:	89 f8                	mov    %edi,%eax
  802057:	8b 8d 88 fd ff ff    	mov    -0x278(%ebp),%ecx
  80205d:	89 4f f8             	mov    %ecx,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802060:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802065:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80206b:	83 ec 0c             	sub    $0xc,%esp
  80206e:	6a 07                	push   $0x7
  802070:	68 00 d0 bf ee       	push   $0xeebfd000
  802075:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80207b:	68 00 00 40 00       	push   $0x400000
  802080:	6a 00                	push   $0x0
  802082:	e8 86 f0 ff ff       	call   80110d <sys_page_map>
  802087:	89 c3                	mov    %eax,%ebx
  802089:	83 c4 20             	add    $0x20,%esp
  80208c:	85 c0                	test   %eax,%eax
  80208e:	0f 88 70 03 00 00    	js     802404 <spawn+0x574>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802094:	83 ec 08             	sub    $0x8,%esp
  802097:	68 00 00 40 00       	push   $0x400000
  80209c:	6a 00                	push   $0x0
  80209e:	e8 ac f0 ff ff       	call   80114f <sys_page_unmap>
  8020a3:	89 c3                	mov    %eax,%ebx
  8020a5:	83 c4 10             	add    $0x10,%esp
  8020a8:	85 c0                	test   %eax,%eax
  8020aa:	0f 88 54 03 00 00    	js     802404 <spawn+0x574>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8020b0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8020b6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8020bd:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8020c3:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8020ca:	00 00 00 
  8020cd:	e9 56 01 00 00       	jmp    802228 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8020d2:	68 44 34 80 00       	push   $0x803444
  8020d7:	68 63 33 80 00       	push   $0x803363
  8020dc:	68 f6 00 00 00       	push   $0xf6
  8020e1:	68 e9 33 80 00       	push   $0x8033e9
  8020e6:	e8 ec e4 ff ff       	call   8005d7 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020eb:	83 ec 04             	sub    $0x4,%esp
  8020ee:	6a 07                	push   $0x7
  8020f0:	68 00 00 40 00       	push   $0x400000
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 ce ef ff ff       	call   8010ca <sys_page_alloc>
  8020fc:	83 c4 10             	add    $0x10,%esp
  8020ff:	85 c0                	test   %eax,%eax
  802101:	0f 88 92 02 00 00    	js     802399 <spawn+0x509>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802107:	83 ec 08             	sub    $0x8,%esp
  80210a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802110:	01 f0                	add    %esi,%eax
  802112:	50                   	push   %eax
  802113:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802119:	e8 4f f9 ff ff       	call   801a6d <seek>
  80211e:	83 c4 10             	add    $0x10,%esp
  802121:	85 c0                	test   %eax,%eax
  802123:	0f 88 77 02 00 00    	js     8023a0 <spawn+0x510>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802129:	83 ec 04             	sub    $0x4,%esp
  80212c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802132:	29 f0                	sub    %esi,%eax
  802134:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802139:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80213e:	0f 47 c1             	cmova  %ecx,%eax
  802141:	50                   	push   %eax
  802142:	68 00 00 40 00       	push   $0x400000
  802147:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80214d:	e8 52 f8 ff ff       	call   8019a4 <readn>
  802152:	83 c4 10             	add    $0x10,%esp
  802155:	85 c0                	test   %eax,%eax
  802157:	0f 88 4a 02 00 00    	js     8023a7 <spawn+0x517>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80215d:	83 ec 0c             	sub    $0xc,%esp
  802160:	57                   	push   %edi
  802161:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  802167:	56                   	push   %esi
  802168:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80216e:	68 00 00 40 00       	push   $0x400000
  802173:	6a 00                	push   $0x0
  802175:	e8 93 ef ff ff       	call   80110d <sys_page_map>
  80217a:	83 c4 20             	add    $0x20,%esp
  80217d:	85 c0                	test   %eax,%eax
  80217f:	0f 88 80 00 00 00    	js     802205 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  802185:	83 ec 08             	sub    $0x8,%esp
  802188:	68 00 00 40 00       	push   $0x400000
  80218d:	6a 00                	push   $0x0
  80218f:	e8 bb ef ff ff       	call   80114f <sys_page_unmap>
  802194:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802197:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80219d:	89 de                	mov    %ebx,%esi
  80219f:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8021a5:	76 73                	jbe    80221a <spawn+0x38a>
		if (i >= filesz) {
  8021a7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8021ad:	0f 87 38 ff ff ff    	ja     8020eb <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8021b3:	83 ec 04             	sub    $0x4,%esp
  8021b6:	57                   	push   %edi
  8021b7:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  8021bd:	56                   	push   %esi
  8021be:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8021c4:	e8 01 ef ff ff       	call   8010ca <sys_page_alloc>
  8021c9:	83 c4 10             	add    $0x10,%esp
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	79 c7                	jns    802197 <spawn+0x307>
  8021d0:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8021d2:	83 ec 0c             	sub    $0xc,%esp
  8021d5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8021db:	e8 6b ee ff ff       	call   80104b <sys_env_destroy>
	close(fd);
  8021e0:	83 c4 04             	add    $0x4,%esp
  8021e3:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8021e9:	e8 f3 f5 ff ff       	call   8017e1 <close>
	return r;
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  8021f7:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8021fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  802205:	50                   	push   %eax
  802206:	68 f5 33 80 00       	push   $0x8033f5
  80220b:	68 29 01 00 00       	push   $0x129
  802210:	68 e9 33 80 00       	push   $0x8033e9
  802215:	e8 bd e3 ff ff       	call   8005d7 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80221a:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  802221:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  802228:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80222f:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802235:	7e 71                	jle    8022a8 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  802237:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  80223d:	83 3a 01             	cmpl   $0x1,(%edx)
  802240:	75 d8                	jne    80221a <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802242:	8b 42 18             	mov    0x18(%edx),%eax
  802245:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802248:	83 f8 01             	cmp    $0x1,%eax
  80224b:	19 ff                	sbb    %edi,%edi
  80224d:	83 e7 fe             	and    $0xfffffffe,%edi
  802250:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802253:	8b 72 04             	mov    0x4(%edx),%esi
  802256:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80225c:	8b 5a 10             	mov    0x10(%edx),%ebx
  80225f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802265:	8b 42 14             	mov    0x14(%edx),%eax
  802268:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80226e:	8b 4a 08             	mov    0x8(%edx),%ecx
  802271:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  802277:	89 c8                	mov    %ecx,%eax
  802279:	25 ff 0f 00 00       	and    $0xfff,%eax
  80227e:	74 1e                	je     80229e <spawn+0x40e>
		va -= i;
  802280:	29 c1                	sub    %eax,%ecx
  802282:	89 8d 88 fd ff ff    	mov    %ecx,-0x278(%ebp)
		memsz += i;
  802288:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  80228e:	01 c3                	add    %eax,%ebx
  802290:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  802296:	29 c6                	sub    %eax,%esi
  802298:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80229e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022a3:	e9 f5 fe ff ff       	jmp    80219d <spawn+0x30d>
	close(fd);
  8022a8:	83 ec 0c             	sub    $0xc,%esp
  8022ab:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8022b1:	e8 2b f5 ff ff       	call   8017e1 <close>
  8022b6:	83 c4 10             	add    $0x10,%esp
  8022b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022be:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8022c4:	eb 12                	jmp    8022d8 <spawn+0x448>
  8022c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// LAB 5: Your code here.
    uint32_t *va;
    pte_t pte;
    int perm, r;
    for (int i = 0; i < PGNUM(USTACKTOP - PGSIZE); i++) {
  8022cc:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8022d2:	0f 84 d6 00 00 00    	je     8023ae <spawn+0x51e>
        va = (void *)(i*PGSIZE);
        if (!(uvpd[PDX(va)] & PTE_P) || !(uvpt[PGNUM(va)] & PTE_P))
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	c1 e8 16             	shr    $0x16,%eax
  8022dd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8022e4:	a8 01                	test   $0x1,%al
  8022e6:	74 de                	je     8022c6 <spawn+0x436>
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	c1 e8 0c             	shr    $0xc,%eax
  8022ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8022f4:	f6 c2 01             	test   $0x1,%dl
  8022f7:	74 cd                	je     8022c6 <spawn+0x436>
            continue;
        pte = (pte_t)uvpt[PGNUM(va)];
  8022f9:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
        if (!(pte & PTE_SHARE))
  802300:	f7 c7 00 04 00 00    	test   $0x400,%edi
  802306:	74 be                	je     8022c6 <spawn+0x436>
            continue;
        cprintf("[%08x] -------- shared --------- va=%x \n", thisenv->env_id, va);
  802308:	a1 04 50 80 00       	mov    0x805004,%eax
  80230d:	8b 40 48             	mov    0x48(%eax),%eax
  802310:	83 ec 04             	sub    $0x4,%esp
  802313:	53                   	push   %ebx
  802314:	50                   	push   %eax
  802315:	68 6c 34 80 00       	push   $0x80346c
  80231a:	e8 93 e3 ff ff       	call   8006b2 <cprintf>
        perm = pte & PTE_SYSCALL;
  80231f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
        if ((r = sys_page_map(0, va, child, va, perm)) < 0)
  802325:	89 3c 24             	mov    %edi,(%esp)
  802328:	53                   	push   %ebx
  802329:	56                   	push   %esi
  80232a:	53                   	push   %ebx
  80232b:	6a 00                	push   $0x0
  80232d:	e8 db ed ff ff       	call   80110d <sys_page_map>
  802332:	83 c4 20             	add    $0x20,%esp
  802335:	85 c0                	test   %eax,%eax
  802337:	79 8d                	jns    8022c6 <spawn+0x436>
		panic("copy_shared_pages: %e", r);
  802339:	50                   	push   %eax
  80233a:	68 2c 34 80 00       	push   $0x80342c
  80233f:	68 82 00 00 00       	push   $0x82
  802344:	68 e9 33 80 00       	push   $0x8033e9
  802349:	e8 89 e2 ff ff       	call   8005d7 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  80234e:	50                   	push   %eax
  80234f:	68 12 34 80 00       	push   $0x803412
  802354:	68 86 00 00 00       	push   $0x86
  802359:	68 e9 33 80 00       	push   $0x8033e9
  80235e:	e8 74 e2 ff ff       	call   8005d7 <_panic>
		panic("sys_env_set_status: %e", r);
  802363:	50                   	push   %eax
  802364:	68 a1 32 80 00       	push   $0x8032a1
  802369:	68 89 00 00 00       	push   $0x89
  80236e:	68 e9 33 80 00       	push   $0x8033e9
  802373:	e8 5f e2 ff ff       	call   8005d7 <_panic>
		return r;
  802378:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80237e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802384:	e9 6e fe ff ff       	jmp    8021f7 <spawn+0x367>
		return -E_NO_MEM;
  802389:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  80238e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802394:	e9 5e fe ff ff       	jmp    8021f7 <spawn+0x367>
  802399:	89 c7                	mov    %eax,%edi
  80239b:	e9 32 fe ff ff       	jmp    8021d2 <spawn+0x342>
  8023a0:	89 c7                	mov    %eax,%edi
  8023a2:	e9 2b fe ff ff       	jmp    8021d2 <spawn+0x342>
  8023a7:	89 c7                	mov    %eax,%edi
  8023a9:	e9 24 fe ff ff       	jmp    8021d2 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8023ae:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8023b5:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8023b8:	83 ec 08             	sub    $0x8,%esp
  8023bb:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8023c1:	50                   	push   %eax
  8023c2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8023c8:	e8 06 ee ff ff       	call   8011d3 <sys_env_set_trapframe>
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	0f 88 76 ff ff ff    	js     80234e <spawn+0x4be>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8023d8:	83 ec 08             	sub    $0x8,%esp
  8023db:	6a 02                	push   $0x2
  8023dd:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8023e3:	e8 a9 ed ff ff       	call   801191 <sys_env_set_status>
  8023e8:	83 c4 10             	add    $0x10,%esp
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	0f 88 70 ff ff ff    	js     802363 <spawn+0x4d3>
	return child;
  8023f3:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8023f9:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8023ff:	e9 f3 fd ff ff       	jmp    8021f7 <spawn+0x367>
	sys_page_unmap(0, UTEMP);
  802404:	83 ec 08             	sub    $0x8,%esp
  802407:	68 00 00 40 00       	push   $0x400000
  80240c:	6a 00                	push   $0x0
  80240e:	e8 3c ed ff ff       	call   80114f <sys_page_unmap>
  802413:	83 c4 10             	add    $0x10,%esp
  802416:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80241c:	e9 d6 fd ff ff       	jmp    8021f7 <spawn+0x367>

00802421 <spawnl>:
{
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	57                   	push   %edi
  802425:	56                   	push   %esi
  802426:	53                   	push   %ebx
  802427:	83 ec 1c             	sub    $0x1c,%esp
	va_start(vl, arg0);
  80242a:	8d 45 10             	lea    0x10(%ebp),%eax
	int argc=0;
  80242d:	bb 00 00 00 00       	mov    $0x0,%ebx
	while(va_arg(vl, void *) != NULL)
  802432:	eb 05                	jmp    802439 <spawnl+0x18>
		argc++;
  802434:	83 c3 01             	add    $0x1,%ebx
	while(va_arg(vl, void *) != NULL)
  802437:	89 d0                	mov    %edx,%eax
  802439:	8d 50 04             	lea    0x4(%eax),%edx
  80243c:	83 38 00             	cmpl   $0x0,(%eax)
  80243f:	75 f3                	jne    802434 <spawnl+0x13>
	const char *argv[argc+2];
  802441:	8d 04 9d 1a 00 00 00 	lea    0x1a(,%ebx,4),%eax
  802448:	83 e0 f0             	and    $0xfffffff0,%eax
  80244b:	29 c4                	sub    %eax,%esp
  80244d:	8d 44 24 03          	lea    0x3(%esp),%eax
  802451:	c1 e8 02             	shr    $0x2,%eax
  802454:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
  80245b:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80245e:	89 f7                	mov    %esi,%edi
	argv[0] = arg0;
  802460:	8b 55 0c             	mov    0xc(%ebp),%edx
  802463:	89 14 85 00 00 00 00 	mov    %edx,0x0(,%eax,4)
	argv[argc+1] = NULL;
  80246a:	c7 44 9e 04 00 00 00 	movl   $0x0,0x4(%esi,%ebx,4)
  802471:	00 
	va_start(vl, arg0);
  802472:	8d 75 10             	lea    0x10(%ebp),%esi
    cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[0]);
  802475:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80247b:	8b 52 48             	mov    0x48(%edx),%edx
  80247e:	83 ec 04             	sub    $0x4,%esp
  802481:	ff 34 85 00 00 00 00 	pushl  0x0(,%eax,4)
  802488:	52                   	push   %edx
  802489:	68 98 34 80 00       	push   $0x803498
  80248e:	e8 1f e2 ff ff       	call   8006b2 <cprintf>
  802493:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for(i=0;i<argc;i++) {
  802496:	83 c4 10             	add    $0x10,%esp
  802499:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249e:	89 f0                	mov    %esi,%eax
  8024a0:	89 fe                	mov    %edi,%esi
  8024a2:	eb 28                	jmp    8024cc <spawnl+0xab>
        argv[i+1] = va_arg(vl, const char *);
  8024a4:	83 c3 01             	add    $0x1,%ebx
  8024a7:	8d 78 04             	lea    0x4(%eax),%edi
  8024aa:	8b 00                	mov    (%eax),%eax
  8024ac:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
        cprintf("[%08x] -------------------- arg:%s \n", thisenv->env_id, argv[i+1]);
  8024af:	8b 15 04 50 80 00    	mov    0x805004,%edx
  8024b5:	8b 52 48             	mov    0x48(%edx),%edx
  8024b8:	83 ec 04             	sub    $0x4,%esp
  8024bb:	50                   	push   %eax
  8024bc:	52                   	push   %edx
  8024bd:	68 98 34 80 00       	push   $0x803498
  8024c2:	e8 eb e1 ff ff       	call   8006b2 <cprintf>
	for(i=0;i<argc;i++) {
  8024c7:	83 c4 10             	add    $0x10,%esp
        argv[i+1] = va_arg(vl, const char *);
  8024ca:	89 f8                	mov    %edi,%eax
	for(i=0;i<argc;i++) {
  8024cc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
  8024cf:	75 d3                	jne    8024a4 <spawnl+0x83>
	return spawn(prog, argv);
  8024d1:	83 ec 08             	sub    $0x8,%esp
  8024d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8024d7:	ff 75 08             	pushl  0x8(%ebp)
  8024da:	e8 b1 f9 ff ff       	call   801e90 <spawn>
}
  8024df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024e2:	5b                   	pop    %ebx
  8024e3:	5e                   	pop    %esi
  8024e4:	5f                   	pop    %edi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    

008024e7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024e7:	55                   	push   %ebp
  8024e8:	89 e5                	mov    %esp,%ebp
  8024ea:	56                   	push   %esi
  8024eb:	53                   	push   %ebx
  8024ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024ef:	83 ec 0c             	sub    $0xc,%esp
  8024f2:	ff 75 08             	pushl  0x8(%ebp)
  8024f5:	e8 4c f1 ff ff       	call   801646 <fd2data>
  8024fa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024fc:	83 c4 08             	add    $0x8,%esp
  8024ff:	68 c0 34 80 00       	push   $0x8034c0
  802504:	53                   	push   %ebx
  802505:	e8 c7 e7 ff ff       	call   800cd1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80250a:	8b 46 04             	mov    0x4(%esi),%eax
  80250d:	2b 06                	sub    (%esi),%eax
  80250f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802515:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80251c:	00 00 00 
	stat->st_dev = &devpipe;
  80251f:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802526:	40 80 00 
	return 0;
}
  802529:	b8 00 00 00 00       	mov    $0x0,%eax
  80252e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    

00802535 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802535:	55                   	push   %ebp
  802536:	89 e5                	mov    %esp,%ebp
  802538:	53                   	push   %ebx
  802539:	83 ec 0c             	sub    $0xc,%esp
  80253c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80253f:	53                   	push   %ebx
  802540:	6a 00                	push   $0x0
  802542:	e8 08 ec ff ff       	call   80114f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802547:	89 1c 24             	mov    %ebx,(%esp)
  80254a:	e8 f7 f0 ff ff       	call   801646 <fd2data>
  80254f:	83 c4 08             	add    $0x8,%esp
  802552:	50                   	push   %eax
  802553:	6a 00                	push   $0x0
  802555:	e8 f5 eb ff ff       	call   80114f <sys_page_unmap>
}
  80255a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80255d:	c9                   	leave  
  80255e:	c3                   	ret    

0080255f <_pipeisclosed>:
{
  80255f:	55                   	push   %ebp
  802560:	89 e5                	mov    %esp,%ebp
  802562:	57                   	push   %edi
  802563:	56                   	push   %esi
  802564:	53                   	push   %ebx
  802565:	83 ec 1c             	sub    $0x1c,%esp
  802568:	89 c7                	mov    %eax,%edi
  80256a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80256c:	a1 04 50 80 00       	mov    0x805004,%eax
  802571:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802574:	83 ec 0c             	sub    $0xc,%esp
  802577:	57                   	push   %edi
  802578:	e8 d8 f8 ff ff       	call   801e55 <pageref>
  80257d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802580:	89 34 24             	mov    %esi,(%esp)
  802583:	e8 cd f8 ff ff       	call   801e55 <pageref>
		nn = thisenv->env_runs;
  802588:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80258e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802591:	83 c4 10             	add    $0x10,%esp
  802594:	39 cb                	cmp    %ecx,%ebx
  802596:	74 1b                	je     8025b3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802598:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80259b:	75 cf                	jne    80256c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80259d:	8b 42 58             	mov    0x58(%edx),%eax
  8025a0:	6a 01                	push   $0x1
  8025a2:	50                   	push   %eax
  8025a3:	53                   	push   %ebx
  8025a4:	68 c7 34 80 00       	push   $0x8034c7
  8025a9:	e8 04 e1 ff ff       	call   8006b2 <cprintf>
  8025ae:	83 c4 10             	add    $0x10,%esp
  8025b1:	eb b9                	jmp    80256c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8025b3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8025b6:	0f 94 c0             	sete   %al
  8025b9:	0f b6 c0             	movzbl %al,%eax
}
  8025bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    

008025c4 <devpipe_write>:
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
  8025c7:	57                   	push   %edi
  8025c8:	56                   	push   %esi
  8025c9:	53                   	push   %ebx
  8025ca:	83 ec 28             	sub    $0x28,%esp
  8025cd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8025d0:	56                   	push   %esi
  8025d1:	e8 70 f0 ff ff       	call   801646 <fd2data>
  8025d6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025d8:	83 c4 10             	add    $0x10,%esp
  8025db:	bf 00 00 00 00       	mov    $0x0,%edi
  8025e0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025e3:	74 4f                	je     802634 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025e5:	8b 43 04             	mov    0x4(%ebx),%eax
  8025e8:	8b 0b                	mov    (%ebx),%ecx
  8025ea:	8d 51 20             	lea    0x20(%ecx),%edx
  8025ed:	39 d0                	cmp    %edx,%eax
  8025ef:	72 14                	jb     802605 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  8025f1:	89 da                	mov    %ebx,%edx
  8025f3:	89 f0                	mov    %esi,%eax
  8025f5:	e8 65 ff ff ff       	call   80255f <_pipeisclosed>
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	75 3a                	jne    802638 <devpipe_write+0x74>
			sys_yield();
  8025fe:	e8 a8 ea ff ff       	call   8010ab <sys_yield>
  802603:	eb e0                	jmp    8025e5 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802605:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802608:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80260c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80260f:	89 c2                	mov    %eax,%edx
  802611:	c1 fa 1f             	sar    $0x1f,%edx
  802614:	89 d1                	mov    %edx,%ecx
  802616:	c1 e9 1b             	shr    $0x1b,%ecx
  802619:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80261c:	83 e2 1f             	and    $0x1f,%edx
  80261f:	29 ca                	sub    %ecx,%edx
  802621:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802625:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802629:	83 c0 01             	add    $0x1,%eax
  80262c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80262f:	83 c7 01             	add    $0x1,%edi
  802632:	eb ac                	jmp    8025e0 <devpipe_write+0x1c>
	return i;
  802634:	89 f8                	mov    %edi,%eax
  802636:	eb 05                	jmp    80263d <devpipe_write+0x79>
				return 0;
  802638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80263d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802640:	5b                   	pop    %ebx
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    

00802645 <devpipe_read>:
{
  802645:	55                   	push   %ebp
  802646:	89 e5                	mov    %esp,%ebp
  802648:	57                   	push   %edi
  802649:	56                   	push   %esi
  80264a:	53                   	push   %ebx
  80264b:	83 ec 18             	sub    $0x18,%esp
  80264e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802651:	57                   	push   %edi
  802652:	e8 ef ef ff ff       	call   801646 <fd2data>
  802657:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802659:	83 c4 10             	add    $0x10,%esp
  80265c:	be 00 00 00 00       	mov    $0x0,%esi
  802661:	3b 75 10             	cmp    0x10(%ebp),%esi
  802664:	74 47                	je     8026ad <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802666:	8b 03                	mov    (%ebx),%eax
  802668:	3b 43 04             	cmp    0x4(%ebx),%eax
  80266b:	75 22                	jne    80268f <devpipe_read+0x4a>
			if (i > 0)
  80266d:	85 f6                	test   %esi,%esi
  80266f:	75 14                	jne    802685 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802671:	89 da                	mov    %ebx,%edx
  802673:	89 f8                	mov    %edi,%eax
  802675:	e8 e5 fe ff ff       	call   80255f <_pipeisclosed>
  80267a:	85 c0                	test   %eax,%eax
  80267c:	75 33                	jne    8026b1 <devpipe_read+0x6c>
			sys_yield();
  80267e:	e8 28 ea ff ff       	call   8010ab <sys_yield>
  802683:	eb e1                	jmp    802666 <devpipe_read+0x21>
				return i;
  802685:	89 f0                	mov    %esi,%eax
}
  802687:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80268a:	5b                   	pop    %ebx
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80268f:	99                   	cltd   
  802690:	c1 ea 1b             	shr    $0x1b,%edx
  802693:	01 d0                	add    %edx,%eax
  802695:	83 e0 1f             	and    $0x1f,%eax
  802698:	29 d0                	sub    %edx,%eax
  80269a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80269f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8026a5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8026a8:	83 c6 01             	add    $0x1,%esi
  8026ab:	eb b4                	jmp    802661 <devpipe_read+0x1c>
	return i;
  8026ad:	89 f0                	mov    %esi,%eax
  8026af:	eb d6                	jmp    802687 <devpipe_read+0x42>
				return 0;
  8026b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8026b6:	eb cf                	jmp    802687 <devpipe_read+0x42>

008026b8 <pipe>:
{
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	56                   	push   %esi
  8026bc:	53                   	push   %ebx
  8026bd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8026c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026c3:	50                   	push   %eax
  8026c4:	e8 94 ef ff ff       	call   80165d <fd_alloc>
  8026c9:	89 c3                	mov    %eax,%ebx
  8026cb:	83 c4 10             	add    $0x10,%esp
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	78 5b                	js     80272d <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026d2:	83 ec 04             	sub    $0x4,%esp
  8026d5:	68 07 04 00 00       	push   $0x407
  8026da:	ff 75 f4             	pushl  -0xc(%ebp)
  8026dd:	6a 00                	push   $0x0
  8026df:	e8 e6 e9 ff ff       	call   8010ca <sys_page_alloc>
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	83 c4 10             	add    $0x10,%esp
  8026e9:	85 c0                	test   %eax,%eax
  8026eb:	78 40                	js     80272d <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  8026ed:	83 ec 0c             	sub    $0xc,%esp
  8026f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026f3:	50                   	push   %eax
  8026f4:	e8 64 ef ff ff       	call   80165d <fd_alloc>
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	83 c4 10             	add    $0x10,%esp
  8026fe:	85 c0                	test   %eax,%eax
  802700:	78 1b                	js     80271d <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802702:	83 ec 04             	sub    $0x4,%esp
  802705:	68 07 04 00 00       	push   $0x407
  80270a:	ff 75 f0             	pushl  -0x10(%ebp)
  80270d:	6a 00                	push   $0x0
  80270f:	e8 b6 e9 ff ff       	call   8010ca <sys_page_alloc>
  802714:	89 c3                	mov    %eax,%ebx
  802716:	83 c4 10             	add    $0x10,%esp
  802719:	85 c0                	test   %eax,%eax
  80271b:	79 19                	jns    802736 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80271d:	83 ec 08             	sub    $0x8,%esp
  802720:	ff 75 f4             	pushl  -0xc(%ebp)
  802723:	6a 00                	push   $0x0
  802725:	e8 25 ea ff ff       	call   80114f <sys_page_unmap>
  80272a:	83 c4 10             	add    $0x10,%esp
}
  80272d:	89 d8                	mov    %ebx,%eax
  80272f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802732:	5b                   	pop    %ebx
  802733:	5e                   	pop    %esi
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    
	va = fd2data(fd0);
  802736:	83 ec 0c             	sub    $0xc,%esp
  802739:	ff 75 f4             	pushl  -0xc(%ebp)
  80273c:	e8 05 ef ff ff       	call   801646 <fd2data>
  802741:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802743:	83 c4 0c             	add    $0xc,%esp
  802746:	68 07 04 00 00       	push   $0x407
  80274b:	50                   	push   %eax
  80274c:	6a 00                	push   $0x0
  80274e:	e8 77 e9 ff ff       	call   8010ca <sys_page_alloc>
  802753:	89 c3                	mov    %eax,%ebx
  802755:	83 c4 10             	add    $0x10,%esp
  802758:	85 c0                	test   %eax,%eax
  80275a:	0f 88 8c 00 00 00    	js     8027ec <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802760:	83 ec 0c             	sub    $0xc,%esp
  802763:	ff 75 f0             	pushl  -0x10(%ebp)
  802766:	e8 db ee ff ff       	call   801646 <fd2data>
  80276b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802772:	50                   	push   %eax
  802773:	6a 00                	push   $0x0
  802775:	56                   	push   %esi
  802776:	6a 00                	push   $0x0
  802778:	e8 90 e9 ff ff       	call   80110d <sys_page_map>
  80277d:	89 c3                	mov    %eax,%ebx
  80277f:	83 c4 20             	add    $0x20,%esp
  802782:	85 c0                	test   %eax,%eax
  802784:	78 58                	js     8027de <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  802786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802789:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80278f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802794:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  80279b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80279e:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8027a4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8027a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027a9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8027b0:	83 ec 0c             	sub    $0xc,%esp
  8027b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8027b6:	e8 7b ee ff ff       	call   801636 <fd2num>
  8027bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027be:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8027c0:	83 c4 04             	add    $0x4,%esp
  8027c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8027c6:	e8 6b ee ff ff       	call   801636 <fd2num>
  8027cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027ce:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8027d1:	83 c4 10             	add    $0x10,%esp
  8027d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d9:	e9 4f ff ff ff       	jmp    80272d <pipe+0x75>
	sys_page_unmap(0, va);
  8027de:	83 ec 08             	sub    $0x8,%esp
  8027e1:	56                   	push   %esi
  8027e2:	6a 00                	push   $0x0
  8027e4:	e8 66 e9 ff ff       	call   80114f <sys_page_unmap>
  8027e9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8027ec:	83 ec 08             	sub    $0x8,%esp
  8027ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8027f2:	6a 00                	push   $0x0
  8027f4:	e8 56 e9 ff ff       	call   80114f <sys_page_unmap>
  8027f9:	83 c4 10             	add    $0x10,%esp
  8027fc:	e9 1c ff ff ff       	jmp    80271d <pipe+0x65>

00802801 <pipeisclosed>:
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80280a:	50                   	push   %eax
  80280b:	ff 75 08             	pushl  0x8(%ebp)
  80280e:	e8 99 ee ff ff       	call   8016ac <fd_lookup>
  802813:	83 c4 10             	add    $0x10,%esp
  802816:	85 c0                	test   %eax,%eax
  802818:	78 18                	js     802832 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80281a:	83 ec 0c             	sub    $0xc,%esp
  80281d:	ff 75 f4             	pushl  -0xc(%ebp)
  802820:	e8 21 ee ff ff       	call   801646 <fd2data>
	return _pipeisclosed(fd, p);
  802825:	89 c2                	mov    %eax,%edx
  802827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80282a:	e8 30 fd ff ff       	call   80255f <_pipeisclosed>
  80282f:	83 c4 10             	add    $0x10,%esp
}
  802832:	c9                   	leave  
  802833:	c3                   	ret    

00802834 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802834:	55                   	push   %ebp
  802835:	89 e5                	mov    %esp,%ebp
  802837:	56                   	push   %esi
  802838:	53                   	push   %ebx
  802839:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80283c:	85 f6                	test   %esi,%esi
  80283e:	74 13                	je     802853 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802840:	89 f3                	mov    %esi,%ebx
  802842:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802848:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80284b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802851:	eb 1b                	jmp    80286e <wait+0x3a>
	assert(envid != 0);
  802853:	68 df 34 80 00       	push   $0x8034df
  802858:	68 63 33 80 00       	push   $0x803363
  80285d:	6a 09                	push   $0x9
  80285f:	68 ea 34 80 00       	push   $0x8034ea
  802864:	e8 6e dd ff ff       	call   8005d7 <_panic>
		sys_yield();
  802869:	e8 3d e8 ff ff       	call   8010ab <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80286e:	8b 43 48             	mov    0x48(%ebx),%eax
  802871:	39 f0                	cmp    %esi,%eax
  802873:	75 07                	jne    80287c <wait+0x48>
  802875:	8b 43 54             	mov    0x54(%ebx),%eax
  802878:	85 c0                	test   %eax,%eax
  80287a:	75 ed                	jne    802869 <wait+0x35>
}
  80287c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80287f:	5b                   	pop    %ebx
  802880:	5e                   	pop    %esi
  802881:	5d                   	pop    %ebp
  802882:	c3                   	ret    

00802883 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802883:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802884:	a1 08 50 80 00       	mov    0x805008,%eax
	call *%eax
  802889:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80288b:	83 c4 04             	add    $0x4,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

    // skip utf_fault_va + utf_err
    addl $8, %esp
  80288e:	83 c4 08             	add    $0x8,%esp

    // move eip to old_esp - 4
    movl 40(%esp), %eax
  802891:	8b 44 24 28          	mov    0x28(%esp),%eax
    movl 32(%esp), %ebx
  802895:	8b 5c 24 20          	mov    0x20(%esp),%ebx
    subl $4, %eax
  802899:	83 e8 04             	sub    $0x4,%eax
    movl %eax, 40(%esp)
  80289c:	89 44 24 28          	mov    %eax,0x28(%esp)
    movl %ebx, 0(%eax)
  8028a0:	89 18                	mov    %ebx,(%eax)

    popal
  8028a2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
    addl $4, %esp
  8028a3:	83 c4 04             	add    $0x4,%esp
    popfl
  8028a6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
    popl %esp
  8028a7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
    ret
  8028a8:	c3                   	ret    

008028a9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	56                   	push   %esi
  8028ad:	53                   	push   %ebx
  8028ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8028b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    int code;
    if ((code = sys_ipc_recv(pg == NULL ? (void *)UTOP:pg)) < 0) {
  8028b7:	85 c0                	test   %eax,%eax
  8028b9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8028be:	0f 44 c2             	cmove  %edx,%eax
  8028c1:	83 ec 0c             	sub    $0xc,%esp
  8028c4:	50                   	push   %eax
  8028c5:	e8 b0 e9 ff ff       	call   80127a <sys_ipc_recv>
  8028ca:	83 c4 10             	add    $0x10,%esp
  8028cd:	85 c0                	test   %eax,%eax
  8028cf:	78 2b                	js     8028fc <ipc_recv+0x53>
        *from_env_store = 0;
        *perm_store = 0;
        return code;
    }
    if (from_env_store != NULL) {
  8028d1:	85 f6                	test   %esi,%esi
  8028d3:	74 0a                	je     8028df <ipc_recv+0x36>
        *from_env_store = thisenv->env_ipc_from;
  8028d5:	a1 04 50 80 00       	mov    0x805004,%eax
  8028da:	8b 40 74             	mov    0x74(%eax),%eax
  8028dd:	89 06                	mov    %eax,(%esi)
    }
    if (perm_store != NULL) {
  8028df:	85 db                	test   %ebx,%ebx
  8028e1:	74 0a                	je     8028ed <ipc_recv+0x44>
        *perm_store = thisenv->env_ipc_perm;
  8028e3:	a1 04 50 80 00       	mov    0x805004,%eax
  8028e8:	8b 40 78             	mov    0x78(%eax),%eax
  8028eb:	89 03                	mov    %eax,(%ebx)
    }

	return (int32_t)thisenv->env_ipc_value;
  8028ed:	a1 04 50 80 00       	mov    0x805004,%eax
  8028f2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8028f8:	5b                   	pop    %ebx
  8028f9:	5e                   	pop    %esi
  8028fa:	5d                   	pop    %ebp
  8028fb:	c3                   	ret    
        *from_env_store = 0;
  8028fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        *perm_store = 0;
  802902:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
        return code;
  802908:	eb eb                	jmp    8028f5 <ipc_recv+0x4c>

0080290a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80290a:	55                   	push   %ebp
  80290b:	89 e5                	mov    %esp,%ebp
  80290d:	57                   	push   %edi
  80290e:	56                   	push   %esi
  80290f:	53                   	push   %ebx
  802910:	83 ec 0c             	sub    $0xc,%esp
  802913:	8b 7d 08             	mov    0x8(%ebp),%edi
  802916:	8b 75 0c             	mov    0xc(%ebp),%esi
  802919:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
    void *src_va;
    int code;
    src_va = pg;
	if (src_va == NULL) {
  80291c:	85 db                	test   %ebx,%ebx
        src_va = (void *)UTOP;
  80291e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802923:	0f 44 d8             	cmove  %eax,%ebx
    }
    while ((code = sys_ipc_try_send(to_env, val, src_va, perm)) != 0) {
  802926:	ff 75 14             	pushl  0x14(%ebp)
  802929:	53                   	push   %ebx
  80292a:	56                   	push   %esi
  80292b:	57                   	push   %edi
  80292c:	e8 26 e9 ff ff       	call   801257 <sys_ipc_try_send>
  802931:	83 c4 10             	add    $0x10,%esp
  802934:	85 c0                	test   %eax,%eax
  802936:	74 17                	je     80294f <ipc_send+0x45>
        if (code != -E_IPC_NOT_RECV) {
  802938:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80293b:	74 e9                	je     802926 <ipc_send+0x1c>
            panic("ipc_send error %e", code);
  80293d:	50                   	push   %eax
  80293e:	68 f5 34 80 00       	push   $0x8034f5
  802943:	6a 3e                	push   $0x3e
  802945:	68 07 35 80 00       	push   $0x803507
  80294a:	e8 88 dc ff ff       	call   8005d7 <_panic>
        }
    }
}
  80294f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802952:	5b                   	pop    %ebx
  802953:	5e                   	pop    %esi
  802954:	5f                   	pop    %edi
  802955:	5d                   	pop    %ebp
  802956:	c3                   	ret    

00802957 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802957:	55                   	push   %ebp
  802958:	89 e5                	mov    %esp,%ebp
  80295a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80295d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802962:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802965:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80296b:	8b 52 50             	mov    0x50(%edx),%edx
  80296e:	39 ca                	cmp    %ecx,%edx
  802970:	74 11                	je     802983 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802972:	83 c0 01             	add    $0x1,%eax
  802975:	3d 00 04 00 00       	cmp    $0x400,%eax
  80297a:	75 e6                	jne    802962 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80297c:	b8 00 00 00 00       	mov    $0x0,%eax
  802981:	eb 0b                	jmp    80298e <ipc_find_env+0x37>
			return envs[i].env_id;
  802983:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802986:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80298b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80298e:	5d                   	pop    %ebp
  80298f:	c3                   	ret    

00802990 <__udivdi3>:
  802990:	55                   	push   %ebp
  802991:	57                   	push   %edi
  802992:	56                   	push   %esi
  802993:	53                   	push   %ebx
  802994:	83 ec 1c             	sub    $0x1c,%esp
  802997:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80299b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80299f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8029a3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8029a7:	85 d2                	test   %edx,%edx
  8029a9:	75 35                	jne    8029e0 <__udivdi3+0x50>
  8029ab:	39 f3                	cmp    %esi,%ebx
  8029ad:	0f 87 bd 00 00 00    	ja     802a70 <__udivdi3+0xe0>
  8029b3:	85 db                	test   %ebx,%ebx
  8029b5:	89 d9                	mov    %ebx,%ecx
  8029b7:	75 0b                	jne    8029c4 <__udivdi3+0x34>
  8029b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8029be:	31 d2                	xor    %edx,%edx
  8029c0:	f7 f3                	div    %ebx
  8029c2:	89 c1                	mov    %eax,%ecx
  8029c4:	31 d2                	xor    %edx,%edx
  8029c6:	89 f0                	mov    %esi,%eax
  8029c8:	f7 f1                	div    %ecx
  8029ca:	89 c6                	mov    %eax,%esi
  8029cc:	89 e8                	mov    %ebp,%eax
  8029ce:	89 f7                	mov    %esi,%edi
  8029d0:	f7 f1                	div    %ecx
  8029d2:	89 fa                	mov    %edi,%edx
  8029d4:	83 c4 1c             	add    $0x1c,%esp
  8029d7:	5b                   	pop    %ebx
  8029d8:	5e                   	pop    %esi
  8029d9:	5f                   	pop    %edi
  8029da:	5d                   	pop    %ebp
  8029db:	c3                   	ret    
  8029dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e0:	39 f2                	cmp    %esi,%edx
  8029e2:	77 7c                	ja     802a60 <__udivdi3+0xd0>
  8029e4:	0f bd fa             	bsr    %edx,%edi
  8029e7:	83 f7 1f             	xor    $0x1f,%edi
  8029ea:	0f 84 98 00 00 00    	je     802a88 <__udivdi3+0xf8>
  8029f0:	89 f9                	mov    %edi,%ecx
  8029f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8029f7:	29 f8                	sub    %edi,%eax
  8029f9:	d3 e2                	shl    %cl,%edx
  8029fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8029ff:	89 c1                	mov    %eax,%ecx
  802a01:	89 da                	mov    %ebx,%edx
  802a03:	d3 ea                	shr    %cl,%edx
  802a05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802a09:	09 d1                	or     %edx,%ecx
  802a0b:	89 f2                	mov    %esi,%edx
  802a0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a11:	89 f9                	mov    %edi,%ecx
  802a13:	d3 e3                	shl    %cl,%ebx
  802a15:	89 c1                	mov    %eax,%ecx
  802a17:	d3 ea                	shr    %cl,%edx
  802a19:	89 f9                	mov    %edi,%ecx
  802a1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802a1f:	d3 e6                	shl    %cl,%esi
  802a21:	89 eb                	mov    %ebp,%ebx
  802a23:	89 c1                	mov    %eax,%ecx
  802a25:	d3 eb                	shr    %cl,%ebx
  802a27:	09 de                	or     %ebx,%esi
  802a29:	89 f0                	mov    %esi,%eax
  802a2b:	f7 74 24 08          	divl   0x8(%esp)
  802a2f:	89 d6                	mov    %edx,%esi
  802a31:	89 c3                	mov    %eax,%ebx
  802a33:	f7 64 24 0c          	mull   0xc(%esp)
  802a37:	39 d6                	cmp    %edx,%esi
  802a39:	72 0c                	jb     802a47 <__udivdi3+0xb7>
  802a3b:	89 f9                	mov    %edi,%ecx
  802a3d:	d3 e5                	shl    %cl,%ebp
  802a3f:	39 c5                	cmp    %eax,%ebp
  802a41:	73 5d                	jae    802aa0 <__udivdi3+0x110>
  802a43:	39 d6                	cmp    %edx,%esi
  802a45:	75 59                	jne    802aa0 <__udivdi3+0x110>
  802a47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802a4a:	31 ff                	xor    %edi,%edi
  802a4c:	89 fa                	mov    %edi,%edx
  802a4e:	83 c4 1c             	add    $0x1c,%esp
  802a51:	5b                   	pop    %ebx
  802a52:	5e                   	pop    %esi
  802a53:	5f                   	pop    %edi
  802a54:	5d                   	pop    %ebp
  802a55:	c3                   	ret    
  802a56:	8d 76 00             	lea    0x0(%esi),%esi
  802a59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802a60:	31 ff                	xor    %edi,%edi
  802a62:	31 c0                	xor    %eax,%eax
  802a64:	89 fa                	mov    %edi,%edx
  802a66:	83 c4 1c             	add    $0x1c,%esp
  802a69:	5b                   	pop    %ebx
  802a6a:	5e                   	pop    %esi
  802a6b:	5f                   	pop    %edi
  802a6c:	5d                   	pop    %ebp
  802a6d:	c3                   	ret    
  802a6e:	66 90                	xchg   %ax,%ax
  802a70:	31 ff                	xor    %edi,%edi
  802a72:	89 e8                	mov    %ebp,%eax
  802a74:	89 f2                	mov    %esi,%edx
  802a76:	f7 f3                	div    %ebx
  802a78:	89 fa                	mov    %edi,%edx
  802a7a:	83 c4 1c             	add    $0x1c,%esp
  802a7d:	5b                   	pop    %ebx
  802a7e:	5e                   	pop    %esi
  802a7f:	5f                   	pop    %edi
  802a80:	5d                   	pop    %ebp
  802a81:	c3                   	ret    
  802a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a88:	39 f2                	cmp    %esi,%edx
  802a8a:	72 06                	jb     802a92 <__udivdi3+0x102>
  802a8c:	31 c0                	xor    %eax,%eax
  802a8e:	39 eb                	cmp    %ebp,%ebx
  802a90:	77 d2                	ja     802a64 <__udivdi3+0xd4>
  802a92:	b8 01 00 00 00       	mov    $0x1,%eax
  802a97:	eb cb                	jmp    802a64 <__udivdi3+0xd4>
  802a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802aa0:	89 d8                	mov    %ebx,%eax
  802aa2:	31 ff                	xor    %edi,%edi
  802aa4:	eb be                	jmp    802a64 <__udivdi3+0xd4>
  802aa6:	66 90                	xchg   %ax,%ax
  802aa8:	66 90                	xchg   %ax,%ax
  802aaa:	66 90                	xchg   %ax,%ax
  802aac:	66 90                	xchg   %ax,%ax
  802aae:	66 90                	xchg   %ax,%ax

00802ab0 <__umoddi3>:
  802ab0:	55                   	push   %ebp
  802ab1:	57                   	push   %edi
  802ab2:	56                   	push   %esi
  802ab3:	53                   	push   %ebx
  802ab4:	83 ec 1c             	sub    $0x1c,%esp
  802ab7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802abb:	8b 74 24 30          	mov    0x30(%esp),%esi
  802abf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802ac3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802ac7:	85 ed                	test   %ebp,%ebp
  802ac9:	89 f0                	mov    %esi,%eax
  802acb:	89 da                	mov    %ebx,%edx
  802acd:	75 19                	jne    802ae8 <__umoddi3+0x38>
  802acf:	39 df                	cmp    %ebx,%edi
  802ad1:	0f 86 b1 00 00 00    	jbe    802b88 <__umoddi3+0xd8>
  802ad7:	f7 f7                	div    %edi
  802ad9:	89 d0                	mov    %edx,%eax
  802adb:	31 d2                	xor    %edx,%edx
  802add:	83 c4 1c             	add    $0x1c,%esp
  802ae0:	5b                   	pop    %ebx
  802ae1:	5e                   	pop    %esi
  802ae2:	5f                   	pop    %edi
  802ae3:	5d                   	pop    %ebp
  802ae4:	c3                   	ret    
  802ae5:	8d 76 00             	lea    0x0(%esi),%esi
  802ae8:	39 dd                	cmp    %ebx,%ebp
  802aea:	77 f1                	ja     802add <__umoddi3+0x2d>
  802aec:	0f bd cd             	bsr    %ebp,%ecx
  802aef:	83 f1 1f             	xor    $0x1f,%ecx
  802af2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802af6:	0f 84 b4 00 00 00    	je     802bb0 <__umoddi3+0x100>
  802afc:	b8 20 00 00 00       	mov    $0x20,%eax
  802b01:	89 c2                	mov    %eax,%edx
  802b03:	8b 44 24 04          	mov    0x4(%esp),%eax
  802b07:	29 c2                	sub    %eax,%edx
  802b09:	89 c1                	mov    %eax,%ecx
  802b0b:	89 f8                	mov    %edi,%eax
  802b0d:	d3 e5                	shl    %cl,%ebp
  802b0f:	89 d1                	mov    %edx,%ecx
  802b11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802b15:	d3 e8                	shr    %cl,%eax
  802b17:	09 c5                	or     %eax,%ebp
  802b19:	8b 44 24 04          	mov    0x4(%esp),%eax
  802b1d:	89 c1                	mov    %eax,%ecx
  802b1f:	d3 e7                	shl    %cl,%edi
  802b21:	89 d1                	mov    %edx,%ecx
  802b23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802b27:	89 df                	mov    %ebx,%edi
  802b29:	d3 ef                	shr    %cl,%edi
  802b2b:	89 c1                	mov    %eax,%ecx
  802b2d:	89 f0                	mov    %esi,%eax
  802b2f:	d3 e3                	shl    %cl,%ebx
  802b31:	89 d1                	mov    %edx,%ecx
  802b33:	89 fa                	mov    %edi,%edx
  802b35:	d3 e8                	shr    %cl,%eax
  802b37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802b3c:	09 d8                	or     %ebx,%eax
  802b3e:	f7 f5                	div    %ebp
  802b40:	d3 e6                	shl    %cl,%esi
  802b42:	89 d1                	mov    %edx,%ecx
  802b44:	f7 64 24 08          	mull   0x8(%esp)
  802b48:	39 d1                	cmp    %edx,%ecx
  802b4a:	89 c3                	mov    %eax,%ebx
  802b4c:	89 d7                	mov    %edx,%edi
  802b4e:	72 06                	jb     802b56 <__umoddi3+0xa6>
  802b50:	75 0e                	jne    802b60 <__umoddi3+0xb0>
  802b52:	39 c6                	cmp    %eax,%esi
  802b54:	73 0a                	jae    802b60 <__umoddi3+0xb0>
  802b56:	2b 44 24 08          	sub    0x8(%esp),%eax
  802b5a:	19 ea                	sbb    %ebp,%edx
  802b5c:	89 d7                	mov    %edx,%edi
  802b5e:	89 c3                	mov    %eax,%ebx
  802b60:	89 ca                	mov    %ecx,%edx
  802b62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802b67:	29 de                	sub    %ebx,%esi
  802b69:	19 fa                	sbb    %edi,%edx
  802b6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  802b6f:	89 d0                	mov    %edx,%eax
  802b71:	d3 e0                	shl    %cl,%eax
  802b73:	89 d9                	mov    %ebx,%ecx
  802b75:	d3 ee                	shr    %cl,%esi
  802b77:	d3 ea                	shr    %cl,%edx
  802b79:	09 f0                	or     %esi,%eax
  802b7b:	83 c4 1c             	add    $0x1c,%esp
  802b7e:	5b                   	pop    %ebx
  802b7f:	5e                   	pop    %esi
  802b80:	5f                   	pop    %edi
  802b81:	5d                   	pop    %ebp
  802b82:	c3                   	ret    
  802b83:	90                   	nop
  802b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b88:	85 ff                	test   %edi,%edi
  802b8a:	89 f9                	mov    %edi,%ecx
  802b8c:	75 0b                	jne    802b99 <__umoddi3+0xe9>
  802b8e:	b8 01 00 00 00       	mov    $0x1,%eax
  802b93:	31 d2                	xor    %edx,%edx
  802b95:	f7 f7                	div    %edi
  802b97:	89 c1                	mov    %eax,%ecx
  802b99:	89 d8                	mov    %ebx,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	f7 f1                	div    %ecx
  802b9f:	89 f0                	mov    %esi,%eax
  802ba1:	f7 f1                	div    %ecx
  802ba3:	e9 31 ff ff ff       	jmp    802ad9 <__umoddi3+0x29>
  802ba8:	90                   	nop
  802ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	39 dd                	cmp    %ebx,%ebp
  802bb2:	72 08                	jb     802bbc <__umoddi3+0x10c>
  802bb4:	39 f7                	cmp    %esi,%edi
  802bb6:	0f 87 21 ff ff ff    	ja     802add <__umoddi3+0x2d>
  802bbc:	89 da                	mov    %ebx,%edx
  802bbe:	89 f0                	mov    %esi,%eax
  802bc0:	29 f8                	sub    %edi,%eax
  802bc2:	19 ea                	sbb    %ebp,%edx
  802bc4:	e9 14 ff ff ff       	jmp    802add <__umoddi3+0x2d>
